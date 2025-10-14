<?php

namespace Modules\Sales\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Exception;

class SalesController extends Controller
{
    // List sales
    public function index()
    {
        $sales = DB::select("
            SELECT s.*, u.name AS cashier_name, c.name AS customer_name
            FROM pos_sales s
            LEFT JOIN usr_users u ON s.user_id = u.id
            LEFT JOIN pos_customers c ON s.customer_id = c.id
            ORDER BY s.created_at DESC
        ");
        return response()->json(['status'=>'success','data'=>$sales]);
    }

    // Show sale with items
    public function show($id)
    {
        $sale = DB::selectOne("SELECT s.*, u.name AS cashier_name FROM pos_sales s LEFT JOIN usr_users u ON s.user_id = u.id WHERE s.id = ?", [$id]);
        if (!$sale) return response()->json(['status'=>'error','message'=>'Not found'], 404);

        $items = DB::select("SELECT si.*, p.name AS product_name FROM pos_sale_items si LEFT JOIN inv_products p ON si.product_id = p.id WHERE si.sale_id = ?", [$id]);
        return response()->json(['status'=>'success','data'=>['sale'=>$sale,'items'=>$items]]);
    }

    // ✅ NEW: Get sale details for receipt
    public function getSaleDetails($id)
    {
        try {
            $sale = DB::selectOne("
                SELECT 
                    s.id,
                    s.receipt_no,
                    s.total_amount,
                    s.payment_method,
                    s.created_at,
                    u.name AS cashier_name,
                    c.name AS customer_name
                FROM pos_sales s
                LEFT JOIN usr_users u ON s.user_id = u.id
                LEFT JOIN pos_customers c ON s.customer_id = c.id
                WHERE s.id = ?
            ", [$id]);

            if (!$sale) {
                return response()->json(['status' => 'error', 'message' => 'Sale not found'], 404);
            }

            $items = DB::select("
                SELECT 
                    si.id,
                    si.quantity,
                    si.unit_price,
                    si.subtotal,
                    p.name AS product_name
                FROM pos_sale_items si
                LEFT JOIN inv_products p ON si.product_id = p.id
                WHERE si.sale_id = ?
            ", [$id]);

            return response()->json([
                'status' => 'success',
                'data' => [
                    'sale' => $sale,
                    'items' => $items
                ]
            ]);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // Create sale (transactional, locks stock)
    public function onCreateSale(Request $request)
    {
        $request->validate([
            'user_id' => 'required|integer',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|integer',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.unit_price' => 'required|numeric',
            'payment_method' => 'required|string',
            'customer_id' => 'nullable|integer'
        ]);

        return DB::transaction(function() use ($request) {
            $userId = $request->user_id;
            $paymentMethod = $request->payment_method;
            $customerId = $request->customer_id ?? null;

            $total = 0;
            foreach ($request->items as $it) {
                $total += $it['unit_price'] * $it['quantity'];
            }

            $date = now()->format('Ymd');
            $countToday = DB::table('pos_sales')
                ->whereDate('created_at', now()->toDateString())
                ->count();
            $receiptNo = 'RCPT-' . $date . '-' . str_pad($countToday + 1, 4, '0', STR_PAD_LEFT);

            $sale = DB::selectOne("
                INSERT INTO pos_sales (user_id, total_amount, payment_method, customer_id, receipt_no, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, NOW(), NOW())
                RETURNING id
            ", [$userId, $total, $paymentMethod, $customerId, $receiptNo]);

            if (!$sale) throw new Exception('Failed to create sale');
            $saleId = $sale->id;

            foreach ($request->items as $it) {
                $productId = $it['product_id'];
                $qty = (int)$it['quantity'];
                $unitPrice = $it['unit_price'];
                $subtotal = $unitPrice * $qty;

                $prod = DB::selectOne("SELECT id, stock_quantity FROM inv_products WHERE id = ? FOR UPDATE", [$productId]);
                if (!$prod) throw new Exception("Product $productId not found");
                if ($prod->stock_quantity < $qty) throw new Exception("Insufficient stock for product $productId");

                DB::update("UPDATE inv_products SET stock_quantity = stock_quantity - ?, updated_at = NOW() WHERE id = ?", [$qty, $productId]);

                DB::insert("
                    INSERT INTO pos_sale_items (sale_id, product_id, quantity, unit_price, subtotal)
                    VALUES (?, ?, ?, ?, ?)
                ", [$saleId, $productId, $qty, $unitPrice, $subtotal]);
            }

            $saleData = DB::selectOne("
                SELECT s.*, u.name AS cashier_name
                FROM pos_sales s
                LEFT JOIN usr_users u ON s.user_id = u.id
                WHERE s.id = ?
            ", [$saleId]);

            $items = DB::select("
                SELECT si.*, p.name AS product_name
                FROM pos_sale_items si
                LEFT JOIN inv_products p ON si.product_id = p.id
                WHERE si.sale_id = ?
            ", [$saleId]);

            return response()->json([
                'status' => 'success',
                'data' => [
                    'sale_id' => $saleId,
                    'sale' => $saleData,
                    'items' => $items
                ]
            ]);
        }, 5);
    }

    // Refund sale
    public function refund($id)
    {
        return DB::transaction(function() use ($id) {
            $items = DB::select("SELECT product_id, quantity FROM pos_sale_items WHERE sale_id = ?", [$id]);
            if (empty($items)) return response()->json(['status'=>'error','message'=>'Sale not found or no items'], 404);

            foreach ($items as $it) {
                DB::update("UPDATE inv_products SET stock_quantity = stock_quantity + ?, updated_at = NOW() WHERE id = ?", [$it->quantity, $it->product_id]);
            }

            DB::delete("DELETE FROM pos_sale_items WHERE sale_id = ?", [$id]);
            DB::delete("DELETE FROM pos_sales WHERE id = ?", [$id]);

            return response()->json(['status'=>'success','message'=>'Sale refunded and removed (stock restored)']);
        });
    }

    // Sales reports: daily, monthly, top products
    public function dailyReport()
    {
        $rows = DB::select("
            SELECT DATE(created_at) AS date, COUNT(*) AS total_sales, SUM(total_amount)::numeric(12,2) AS total_revenue
            FROM pos_sales
            GROUP BY DATE(created_at)
            ORDER BY DATE(created_at) DESC
            LIMIT 30
        ");
        return response()->json(['status'=>'success','data'=>$rows]);
    }

    public function monthlyReport()
    {
        $rows = DB::select("
            SELECT TO_CHAR(created_at, 'YYYY-MM') AS month, COUNT(*) AS total_sales, SUM(total_amount)::numeric(12,2) AS total_revenue
            FROM pos_sales
            GROUP BY TO_CHAR(created_at, 'YYYY-MM')
            ORDER BY month DESC
            LIMIT 12
        ");
        return response()->json(['status'=>'success','data'=>$rows]);
    }

    public function topProducts()
    {
        $rows = DB::select("
            SELECT p.name AS product_name, SUM(si.quantity) AS total_sold, SUM(si.subtotal)::numeric(12,2) AS total_revenue
            FROM pos_sale_items si
            LEFT JOIN inv_products p ON si.product_id = p.id
            GROUP BY p.name
            ORDER BY total_sold DESC
            LIMIT 10
        ");
        return response()->json(['status'=>'success','data'=>$rows]);
    }
}

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
                    si.unit_id,
                    si.unit_price,
                    si.subtotal,
                    p.name AS product_name,
                    pu.name AS unit_name

                FROM pos_sale_items si
                LEFT JOIN inv_products p ON si.product_id = p.id
                LEFT JOIN inv_product_units pu ON si.unit_id = pu.id
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
    // public function onCreateSale(Request $request)
    // {
    //     $request->validate([
    //         'user_id' => 'required|integer',
    //         'items' => 'required|array|min:1',
    //         'items.*.product_id' => 'required|integer',
    //         'items.*.quantity' => 'required|integer|min:1',
    //         'items.*.unit_price' => 'required|numeric',
    //         'payment_method' => 'required|string',
    //         'customer_id' => 'nullable|integer'
    //     ]);

    //     return DB::transaction(function() use ($request) {
    //         $userId = $request->user_id;
    //         $paymentMethod = $request->payment_method;
    //         $customerId = $request->customer_id ?? null;

    //         $total = 0;
    //         foreach ($request->items as $it) {
    //             $total += $it['unit_price'] * $it['quantity'];
    //         }

    //         $date = now()->format('Ymd');
    //         $countToday = DB::table('pos_sales')
    //             ->whereDate('created_at', now()->toDateString())
    //             ->count();
    //         $receiptNo = 'RCPT-' . $date . '-' . str_pad($countToday + 1, 4, '0', STR_PAD_LEFT);

    //         $sale = DB::selectOne("
    //             INSERT INTO pos_sales (user_id, total_amount, payment_method, customer_id, receipt_no, created_at, updated_at)
    //             VALUES (?, ?, ?, ?, ?, NOW(), NOW())
    //             RETURNING id
    //         ", [$userId, $total, $paymentMethod, $customerId, $receiptNo]);

    //         if (!$sale) throw new Exception('Failed to create sale');
    //         $saleId = $sale->id;

    //         foreach ($request->items as $it) {
    //             $productId = $it['product_id'];
    //             $qty = (int)$it['quantity'];
    //             $unitPrice = $it['unit_price'];
    //             $subtotal = $unitPrice * $qty;

    //             $prod = DB::selectOne("SELECT id, stock_quantity FROM inv_products WHERE id = ? FOR UPDATE", [$productId]);
    //             if (!$prod) throw new Exception("Product $productId not found");
    //             if ($prod->stock_quantity < $qty) throw new Exception("Insufficient stock for product $productId");

    //             DB::update("UPDATE inv_products SET stock_quantity = stock_quantity - ?, updated_at = NOW() WHERE id = ?", [$qty, $productId]);

    //             DB::insert("
    //                 INSERT INTO pos_sale_items (sale_id, product_id, quantity, unit_price, subtotal)
    //                 VALUES (?, ?, ?, ?, ?)
    //             ", [$saleId, $productId, $qty, $unitPrice, $subtotal]);
    //         }

    //         $saleData = DB::selectOne("
    //             SELECT s.*, u.name AS cashier_name
    //             FROM pos_sales s
    //             LEFT JOIN usr_users u ON s.user_id = u.id
    //             WHERE s.id = ?
    //         ", [$saleId]);

    //         $items = DB::select("
    //             SELECT si.*, p.name AS product_name
    //             FROM pos_sale_items si
    //             LEFT JOIN inv_products p ON si.product_id = p.id
    //             WHERE si.sale_id = ?
    //         ", [$saleId]);

    //         return response()->json([
    //             'status' => 'success',
    //             'data' => [
    //                 'sale_id' => $saleId,
    //                 'sale' => $saleData,
    //                 'items' => $items
    //             ]
    //         ]);
    //     }, 5);
    // }
public function onCreateSale(Request $request)
{
    $request->validate([
        'items' => 'required|array|min:1',
        'items.*.product_id' => 'required|integer',
        'items.*.quantity' => 'required|integer|min:1',
        'items.*.unit_id' => 'nullable|integer',
        'items.*.unit_price' => 'required|numeric',
        'payment_method' => 'required|string',
        'customer_id' => 'nullable|integer'
    ]);

    // Use logged-in user ID dynamically
    $userId = auth()->id(); // ✅ dynamic user ID

    return DB::transaction(function() use ($request, $userId) {
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

        // Insert sale
        $sale = DB::selectOne("
            INSERT INTO pos_sales (user_id, total_amount, payment_method, customer_id, receipt_no, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, NOW(), NOW())
            RETURNING id
        ", [$userId, $total, $paymentMethod, $customerId, $receiptNo]);

        if (!$sale) throw new Exception('Failed to create sale');
        $saleId = $sale->id;

        // Insert sale items and update stock
        foreach ($request->items as $it) {
            $productId = $it['product_id'];
            $qty = (int)$it['quantity'];
            $unitId = $it['unit_id'];
            $unitPrice = $it['unit_price'];
            $subtotal = $unitPrice * $qty;

            $prod = DB::selectOne("SELECT id, stock_quantity FROM inv_products WHERE id = ? FOR UPDATE", [$productId]);
            if (!$prod) throw new Exception("Product $productId not found");
            if ($prod->stock_quantity < $qty) throw new Exception("Insufficient stock for product $productId");

            DB::update("UPDATE inv_products SET stock_quantity = stock_quantity - ?, updated_at = NOW() WHERE id = ?", [$qty, $productId]);

            DB::insert("
                INSERT INTO pos_sale_items (sale_id, product_id,quantity, unit_id, unit_price, subtotal)
                VALUES (?, ?, ?, ?, ?, ?)
            ", [$saleId, $productId, $qty, $unitId, $unitPrice, $subtotal]);
        }

        // Return created sale with items
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

public function dashboardReport()
{
    try {
        // --- Daily Sales (last 7 days) ---
        $dailySales = DB::select("
            SELECT 
                DATE(s.created_at) AS date,
                COUNT(*) AS total_sales,
                SUM(s.total_amount)::numeric(12,2) AS total_revenue,
                SUM(si.quantity) AS total_quantity_sold,
                ROUND(SUM(s.total_amount)/NULLIF(COUNT(*),0),2) AS avg_sale_value
            FROM pos_sales s
            LEFT JOIN pos_sale_items si ON s.id = si.sale_id
            WHERE s.created_at >= NOW() - INTERVAL '7 days'
            GROUP BY DATE(s.created_at)
            ORDER BY DATE(s.created_at) ASC
        ");

        // --- Monthly Sales (last 6 months) ---
        $monthlySales = DB::select("
            SELECT 
                TO_CHAR(s.created_at, 'YYYY-MM') AS month,
                COUNT(*) AS total_sales,
                SUM(s.total_amount)::numeric(12,2) AS total_revenue,
                SUM(si.quantity) AS total_quantity_sold,
                ROUND(SUM(s.total_amount)/NULLIF(COUNT(*),0),2) AS avg_sale_value
            FROM pos_sales s
            LEFT JOIN pos_sale_items si ON s.id = si.sale_id
            WHERE s.created_at >= DATE_TRUNC('month', NOW()) - INTERVAL '6 months'
            GROUP BY TO_CHAR(s.created_at, 'YYYY-MM')
            ORDER BY month ASC
        ");

        // --- Top 10 Products (by quantity sold) including unit and category ---
        $topProducts = DB::select("
            SELECT 
                p.id,
                p.name AS product_name,
                c.id AS category_id,
                c.name AS category_name,
                u.id AS unit_id,
                u.name AS unit_name,
                SUM(si.quantity) AS total_sold,
                SUM(si.subtotal)::numeric(12,2) AS total_revenue,
                p.stock_quantity AS remaining_stock
            FROM pos_sale_items si
            LEFT JOIN inv_products p ON si.product_id = p.id
            LEFT JOIN inv_categories c ON p.category_id = c.id
            LEFT JOIN inv_product_units u ON p.unit_id = u.id
            GROUP BY p.id, p.name, c.id, c.name, u.id, u.name, p.stock_quantity
            ORDER BY total_sold DESC
            LIMIT 10
        ");

        // --- Category-wise Sales ---
        $categorySales = DB::select("
            SELECT 
                c.id AS category_id,
                c.name AS category_name,
                SUM(si.quantity) AS total_quantity_sold,
                SUM(si.subtotal)::numeric(12,2) AS total_revenue
            FROM pos_sale_items si
            LEFT JOIN inv_products p ON si.product_id = p.id
            LEFT JOIN inv_categories c ON p.category_id = c.id
            GROUP BY c.id, c.name
            ORDER BY total_revenue DESC
        ");

        // --- Low Stock Products (with unit and category) ---
        $lowStockProducts = DB::select("
            SELECT 
                p.id,
                p.name AS product_name,
                c.id AS category_id,
                c.name AS category_name,
                u.id AS unit_id,
                u.name AS unit_name,
                p.stock_quantity,
                p.low_stock_threshold
            FROM inv_products p
            LEFT JOIN inv_categories c ON p.category_id = c.id
            LEFT JOIN inv_product_units u ON p.unit_id = u.id
            WHERE p.stock_quantity <= p.low_stock_threshold OR p.stock_quantity <= 10
            ORDER BY p.stock_quantity ASC
        ");

        // --- Total Inventory Value ---
        $totalInventoryValue = DB::selectOne("
            SELECT SUM(stock_quantity * unit_price)::numeric(12,2) AS total_value
            FROM inv_products
        ");

        // --- Total Products ---
        $totalProducts = DB::table('inv_products')->count();

        // --- Summary metrics ---
        $summary = [
            'totalProducts' => $totalProducts,
            'lowStockCount' => count($lowStockProducts),
            'totalInventoryValue' => $totalInventoryValue->total_value ?? 0,
        ];

        return response()->json([
            'status' => 'success',
            'data' => [
                'summary' => $summary,
                'dailySales' => $dailySales,
                'monthlySales' => $monthlySales,
                'topProducts' => $topProducts,
                'categorySales' => $categorySales,
                'lowStockProducts' => $lowStockProducts,
            ]
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage()
        ], 500);
    }
}


}

<?php

namespace Modules\Inventory\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class InventoryController extends Controller
{
    public function index()
    {
        $products = DB::select("
            SELECT p.*, c.name AS category_name
            FROM inv_products p
            LEFT JOIN inv_categories c ON p.category_id = c.id
            ORDER BY p.created_at DESC
        ");
        return response()->json(['status' => 'success', 'data' => $products]);
    }

    public function show($id)
    {
        $p = DB::selectOne("
            SELECT p.*, c.name AS category_name 
            FROM inv_products p 
            LEFT JOIN inv_categories c ON p.category_id = c.id 
            WHERE p.id = ?
        ", [$id]);

        if (!$p) {
            return response()->json(['status' => 'error', 'message' => 'Not found'], 404);
        }

        return response()->json(['status' => 'success', 'data' => $p]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'category_id' => 'nullable|integer',
            'name' => 'required|string',
            'sku' => 'nullable|string',
            'unit_price' => 'required|numeric',
            'stock_quantity' => 'required|integer'
        ]);

        $now = now();
        DB::insert("
            INSERT INTO inv_products (category_id, name, description, unit_price, stock_quantity, is_enabled, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, TRUE, ?, ?)
        ", [
            $request->category_id,
            $request->name,
            $request->description ?? null,
            $request->unit_price,
            $request->stock_quantity,
            $now,
            $now
        ]);

        return response()->json(['status' => 'success', 'message' => 'Product created']);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'category_id' => 'nullable|integer',
            'name' => 'required|string',
            'unit_price' => 'required|numeric',
            'stock_quantity' => 'required|integer',
            'is_enabled' => 'nullable|boolean'
        ]);

        DB::update("
            UPDATE inv_products 
            SET category_id = ?, name = ?, description = ?, unit_price = ?, stock_quantity = ?, is_enabled = ?, updated_at = NOW()
            WHERE id = ?
        ", [
            $request->category_id,
            $request->name,
            $request->description ?? null,
            $request->unit_price,
            $request->stock_quantity,
            $request->is_enabled ?? true,
            $id
        ]);

        return response()->json(['status' => 'success', 'message' => 'Product updated']);
    }

    public function destroy($id)
    {
        DB::delete("DELETE FROM inv_products WHERE id = ?", [$id]);
        return response()->json(['status' => 'success', 'message' => 'Product deleted']);
    }

    // 🔹 Adjust stock atomically (increment/decrement) + record movement
 public function adjustStock(Request $request, $id)
{
    $request->validate([
        'delta' => 'required|integer',
        'reason' => 'nullable|string',
        'user' => 'nullable|string'
    ]);

    $delta = (int)$request->delta;
    $reason = $request->reason ?? 'Manual Adjustment';
    $user = $request->user ?? 'Admin';

    return DB::transaction(function() use ($id, $delta, $reason, $user) {
        $row = DB::selectOne("SELECT id, stock_quantity FROM inv_products WHERE id = ? FOR UPDATE", [$id]);
        if (!$row) return response()->json(['status'=>'error','message'=>'Product not found'], 404);

        $prevQty = (int)$row->stock_quantity;
        $newQty = $prevQty + $delta;
        if ($newQty < 0) return response()->json(['status'=>'error','message'=>'Insufficient stock'], 422);

        DB::update("UPDATE inv_products SET stock_quantity = ?, updated_at = NOW() WHERE id = ?", [$newQty, $id]);

        // log to history
        DB::insert("
            INSERT INTO inv_stock_history (product_id, delta, previous_quantity, new_quantity, reason, adjusted_by, created_at)
            VALUES (?, ?, ?, ?, ?, ?, NOW())
        ", [$id, $delta, $prevQty, $newQty, $reason, $user]);

        return response()->json([
            'status' => 'success',
            'id' => $id,
            'quantity' => $newQty
        ]);
    });
}



public function stockHistory($productId)
{
    $history = DB::select("
        SELECT h.*, p.name AS product_name
        FROM inv_stock_history h
        LEFT JOIN inv_products p ON h.product_id = p.id
        WHERE h.product_id = ?
        ORDER BY h.created_at DESC
    ", [$productId]);

    return response()->json(['status'=>'success','data'=>$history]);
}


    // 🔹 View low stock items
    public function lowStock(Request $request)
    {
        $threshold = (int)($request->query('limit', 10));

        $products = DB::select("
            SELECT p.*, c.name AS category_name
            FROM inv_products p
            LEFT JOIN inv_categories c ON p.category_id = c.id
            WHERE p.stock_quantity < ?
            ORDER BY p.stock_quantity ASC
        ", [$threshold]);

        return response()->json([
            'status' => 'success',
            'threshold' => $threshold,
            'count' => count($products),
            'data' => $products
        ]);
    }

   public function getCategories()
{
    try {
        $categories = DB::table('inv_categories')
            ->select('id', 'name', 'description', 'is_enabled')
            ->orderBy('name', 'asc')
            ->get();

        return response()->json([
            'status' => 'success',
            'count' => $categories->count(),
            'data' => $categories
        ], 200);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Failed to load categories',
            'error' => $e->getMessage()
        ], 500);
    }
}

public function addNewStock(Request $request, $id)
{
    $request->validate([
        'quantity' => 'required|integer|min:1',
        'reason' => 'nullable|string',
        'user' => 'nullable|string'
    ]);

    $quantity = (int)$request->quantity;
    $reason = $request->reason ?? 'New Stock Received';
    $user = $request->user ?? 'Admin';

    return DB::transaction(function () use ($id, $quantity, $reason, $user) {
        $product = DB::selectOne("SELECT id, stock_quantity FROM inv_products WHERE id = ? FOR UPDATE", [$id]);
        if (!$product) {
            return response()->json(['status' => 'error', 'message' => 'Product not found'], 404);
        }

        $previousQty = (int)$product->stock_quantity;
        $newQty = $previousQty + $quantity;

        DB::update("UPDATE inv_products SET stock_quantity = ?, updated_at = NOW() WHERE id = ?", [$newQty, $id]);

        // record stock history
        DB::insert("
            INSERT INTO inv_stock_history (product_id, delta, previous_quantity, new_quantity, reason, adjusted_by, created_at)
            VALUES (?, ?, ?, ?, ?, ?, NOW())
        ", [$id, $quantity, $previousQty, $newQty, $reason, $user]);

        return response()->json([
            'status' => 'success',
            'message' => 'Stock added successfully',
            'new_quantity' => $newQty
        ]);
    });
}



}

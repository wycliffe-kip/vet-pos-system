<?php

namespace Modules\Inventory\Http\Controllers;
use Illuminate\Support\Facades\Storage;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Schema;

class InventoryController extends Controller
{
    /** 🔹 Get all products */
    public function getAllProductData()
    {
        try {
            $products = DB::select("
                SELECT p.*, c.name AS category_name, u.name AS unit_name
                FROM inv_products p
                LEFT JOIN inv_categories c ON p.category_id = c.id
                LEFT JOIN inv_product_units u ON p.unit_id = u.id
                ORDER BY p.created_at DESC
            ");
            return response()->json(['status' => 'success', 'data' => $products]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Failed to load products', 'error' => $e->getMessage()], 500);
        }
    }

    /** 🔹 Get a single product */
    public function show($id)
    {
        try {
            $product = DB::selectOne("
                SELECT p.*, c.name AS category_name, u.name AS unit_name 
                FROM inv_products p 
                LEFT JOIN inv_categories c ON p.category_id = c.id 
                LEFT JOIN inv_product_units u ON p.unit_id = u.id
                WHERE p.id = ?
            ", [$id]);

            if (!$product) {
                return response()->json(['status' => 'error', 'message' => 'Product not found'], 404);
            }

            return response()->json(['status' => 'success', 'data' => $product]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Error fetching product', 'error' => $e->getMessage()], 500);
        }
    }


    /** 🔹 Create a new product */
public function createNewProduct(Request $request)
    {
        try {
            $request->validate([
                'category_id' => 'nullable|integer',
                'unit_id' => 'nullable|integer',
                'name' => 'required|string',
                'sku' => 'nullable|string',
                'buying_price' => 'nullable|numeric',
                'unit_price' => 'required|numeric',
                'stock_quantity' => 'required|integer',
                'low_stock_threshold' => 'nullable|integer',
                'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            ]);

            $now = now();
            $imagePath = null;

            /** ✅ Handle Image Upload (stored in storage/app/public/products) */
            if ($request->hasFile('image')) {
                $image = $request->file('image');
                $fileName = uniqid('product_') . '.' . $image->getClientOriginalExtension();
                $image->storeAs('products', $fileName); // uses public disk by default
                $imagePath = 'storage/products/' . $fileName; // public URL path
            }

            /** ✅ Insert product */
            DB::table('inv_products')->insert([
                'category_id' => $request->category_id,
                'name' => $request->name,
                'description' => $request->description ?? null,
                'unit_id' => $request->unit_id,
                'buying_price' => $request->buying_price,
                'unit_price' => $request->unit_price,
                'stock_quantity' => $request->stock_quantity,
                'low_stock_threshold' => $request->low_stock_threshold ?? 10,
                'image' => $imagePath,
                'is_enabled' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Product created successfully'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to create product',
                'error' => $e->getMessage()
            ], 500);
        }
    }

/** 🔹 Update product details */
public function updateProduct(Request $request, $id)
    {
        try {
            $request->validate([
                'category_id' => 'nullable|integer',
                'name' => 'required|string',
                'unit_id' => 'nullable|integer',
                'description' => 'nullable|string',
                'buying_price' => 'nullable|numeric',
                'unit_price' => 'required|numeric',
                'stock_quantity' => 'required|integer',
                'low_stock_threshold' => 'nullable|integer',
                'is_enabled' => 'nullable',
                'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            ]);

            $isEnabled = filter_var($request->input('is_enabled', true), FILTER_VALIDATE_BOOLEAN);
            $imagePath = null;

            /** ✅ Handle image replacement */
            if ($request->hasFile('image')) {
                $product = DB::table('inv_products')->where('id', $id)->first();

                // Delete old image if exists
                if ($product && $product->image && Storage::exists(str_replace('storage/', '', $product->image))) {
                    Storage::delete(str_replace('storage/', '', $product->image));
                }

                // Upload new one
                $image = $request->file('image');
                $fileName = uniqid('product_') . '.' . $image->getClientOriginalExtension();
                $image->storeAs('products', $fileName);
                $imagePath = 'storage/products/' . $fileName;

                DB::table('inv_products')->where('id', $id)->update(['image' => $imagePath]);
            }

            /** ✅ Update product info */
            DB::table('inv_products')->where('id', $id)->update([
                'category_id' => $request->category_id,
                'name' => $request->name,
                'description' => $request->description ?? null,
                'unit_id' => $request->unit_id,
                'buying_price' => $request->buying_price,
                'unit_price' => $request->unit_price,
                'stock_quantity' => $request->stock_quantity,
                'low_stock_threshold' => $request->low_stock_threshold ?? 10,
                'is_enabled' => $isEnabled,
                'updated_at' => now(),
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Product updated successfully'
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update product',
                'error' => $e->getMessage(),
            ], 500);
        }
    }


/** 🔹 Delete a product and its image */
public function deleteProduct($id)
{
    try {
        // ✅ Find product
        $product = DB::table('inv_products')->where('id', $id)->first();

        if (!$product) {
            return response()->json([
                'status' => 'error',
                'message' => 'Product not found'
            ], 404);
        }

        // ✅ Delete image if it exists in storage
        if ($product->image) {
            // Convert 'storage/products/image.jpg' → 'public/products/image.jpg'
            $relativePath = str_replace('storage/', 'public/', $product->image);

            if (Storage::exists($relativePath)) {
                Storage::delete($relativePath);
            }
        }

        // ✅ Delete the product record
        DB::table('inv_products')->where('id', $id)->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Product and image deleted successfully'
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Failed to delete product',
            'error' => $e->getMessage(),
        ], 500);
    }
}


  /** 🔹 Delete product */
    public function destroy($id)
    {
        try {
            DB::delete("DELETE FROM inv_products WHERE id = ?", [$id]);
            return response()->json(['status' => 'success', 'message' => 'Product deleted successfully']);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Failed to delete product', 'error' => $e->getMessage()], 500);
        }
    }

    /** ✅ NEW: Public product listing (only enabled + with image URLs) */
    /** 🔹 Public product listing (only enabled) */
    public function onGetProducts()
    {
        try {
            $products = DB::select("
                SELECT p.id, p.name, p.unit_price, p.description, p.image,
                       c.name AS category_name, u.name AS unit_name
                FROM inv_products p
                LEFT JOIN inv_categories c ON p.category_id = c.id
                LEFT JOIN inv_product_units u ON p.unit_id = u.id
                WHERE p.is_enabled = TRUE
                ORDER BY p.name ASC
            ");

            $products = array_map(function ($p) {
                $p->image_url = $p->image
                    ? asset($p->image)
                    : asset('images/no-image.png');
                return $p;
            }, $products);

            return response()->json([
                'status' => 'success',
                'count' => count($products),
                'data' => $products
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Failed to load public products', 'error' => $e->getMessage()], 500);
        }
    }

    /** 🔹 Adjust stock quantity */
    public function adjustStock(Request $request, $id)
    {
        try {
            $request->validate([
                'delta' => 'required|integer',
                'reason' => 'nullable|string',
                'user' => 'nullable|string'
            ]);

            $delta = (int)$request->delta;
            $reason = $request->reason ?? 'Manual Adjustment';
            $user = $request->user ?? 'Admin';

            return DB::transaction(function () use ($id, $delta, $reason, $user) {
                $row = DB::selectOne("SELECT id, stock_quantity FROM inv_products WHERE id = ? FOR UPDATE", [$id]);
                if (!$row) return response()->json(['status' => 'error', 'message' => 'Product not found'], 404);

                $prevQty = (int)$row->stock_quantity;
                $newQty = $prevQty + $delta;
                if ($newQty < 0) return response()->json(['status' => 'error', 'message' => 'Insufficient stock'], 422);

                DB::update("UPDATE inv_products SET stock_quantity = ?, updated_at = NOW() WHERE id = ?", [$newQty, $id]);

                DB::insert("
                    INSERT INTO inv_stock_history (product_id, delta, previous_quantity, new_quantity, reason, adjusted_by, created_at)
                    VALUES (?, ?, ?, ?, ?, ?, NOW())
                ", [$id, $delta, $prevQty, $newQty, $reason, $user]);

                return response()->json(['status' => 'success', 'id' => $id, 'quantity' => $newQty]);
            });
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Stock adjustment failed', 'error' => $e->getMessage()], 500);
        }
    }

 /** 🔹 Stock history */
    public function stockHistory($productId)
    {
        try {
            $history = DB::select("
                SELECT h.*, p.name AS product_name
                FROM inv_stock_history h
                LEFT JOIN inv_products p ON h.product_id = p.id
                WHERE h.product_id = ?
                ORDER BY h.created_at DESC
            ", [$productId]);

            return response()->json(['status' => 'success', 'data' => $history]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Failed to load stock history', 'error' => $e->getMessage()], 500);
        }
    }

    /** 🔹 View low stock items */
    public function lowStock(Request $request)
    {
        try {
            $threshold = (int)($request->query('limit', 10));

            $products = DB::select("
                SELECT p.*, c.name AS category_name, u.name AS unit_name
                FROM inv_products p
                LEFT JOIN inv_categories c ON p.category_id = c.id
                LEFT JOIN inv_product_units u ON p.unit_id = u.id
                WHERE p.stock_quantity < ?
                ORDER BY p.stock_quantity ASC
            ", [$threshold]);

            return response()->json([
                'status' => 'success',
                'threshold' => $threshold,
                'count' => count($products),
                'data' => $products
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Failed to load low stock items', 'error' => $e->getMessage()], 500);
        }
    }
    /** 🔹 Get product categories */
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
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Failed to load categories', 'error' => $e->getMessage()], 500);
        }
    }


  /** 🔹 Get product units */
    public function getUnits()
    {
        try {
            $units = DB::table('inv_product_units')
                ->select('id', 'name', 'description', 'is_enabled')
                ->orderBy('name', 'asc')
                ->get();

            return response()->json([
                'status' => 'success',
                'count' => $units->count(),
                'data' => $units
            ]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Failed to load units', 'error' => $e->getMessage()], 500);
        }
    }

/** 🔹 Add new stock (with weighted avg price) */
    public function addNewStock(Request $request, $id)
    {
        try {
            $request->validate([
                'quantity' => 'required|integer|min:1',
                'buying_price' => 'required|numeric|min:0',
                'reason' => 'nullable|string',
                'user' => 'nullable|string'
            ]);

            $quantity = (int)$request->quantity;
            $buyingPrice = (float)$request->buying_price;
            $reason = $request->reason ?? 'New Stock Received';
            $user = $request->user ?? 'Admin';

            return DB::transaction(function () use ($id, $quantity, $buyingPrice, $reason, $user) {
                $product = DB::selectOne("SELECT id, stock_quantity, buying_price FROM inv_products WHERE id = ? FOR UPDATE", [$id]);
                if (!$product) {
                    return response()->json(['status' => 'error', 'message' => 'Product not found'], 404);
                }

                $previousQty = (int)$product->stock_quantity;
                $newQty = $previousQty + $quantity;
                $totalCost = $buyingPrice * $quantity;

                $currentValue = $previousQty * (float)$product->buying_price;
                $newValue = $currentValue + $totalCost;
                $averageBuyingPrice = $newQty > 0 ? $newValue / $newQty : $buyingPrice;

                DB::update("
                    UPDATE inv_products 
                    SET stock_quantity = ?, buying_price = ?, updated_at = NOW()
                    WHERE id = ?
                ", [$newQty, $averageBuyingPrice, $id]);

                DB::insert("
                    INSERT INTO inv_stock_purchases (product_id, quantity, buying_price, total_cost, reason, added_by, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())
                ", [$id, $quantity, $buyingPrice, $totalCost, $reason, $user]);

                DB::insert("
                    INSERT INTO inv_stock_history (product_id, delta, previous_quantity, new_quantity, reason, adjusted_by, created_at)
                    VALUES (?, ?, ?, ?, ?, ?, NOW())
                ", [$id, $quantity, $previousQty, $newQty, $reason, $user]);

                return response()->json([
                    'status' => 'success',
                    'message' => 'Stock added successfully',
                    'new_quantity' => $newQty,
                    'average_buying_price' => $averageBuyingPrice
                ]);
            });
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Failed to add new stock', 'error' => $e->getMessage()], 500);
        }
    }

    /** 🔹 Purchase history */
    public function purchaseHistory($productId)
    {
        try {
            $purchases = DB::select("
                SELECT ph.*, p.name AS product_name
                FROM inv_stock_purchases ph
                LEFT JOIN inv_products p ON ph.product_id = p.id
                WHERE ph.product_id = ?
                ORDER BY ph.created_at DESC
            ", [$productId]);

            return response()->json(['status' => 'success', 'data' => $purchases]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Failed to load purchase history', 'error' => $e->getMessage()], 500);
        }
    }

        /**
     * 🔹 Load any POS config dynamically
     */
    public function loadConfig(Request $req)
    {
        try {
            $tableName = $req->input('table_name');
            $filters = $req->input('filter', []);

            if (!$tableName) {
                return response()->json([
                    'success' => false,
                    'message' => 'No table specified'
                ]);
            }

            // 🔹 Check if table is blocked
         

            $sql = DB::table($tableName);

            if (!empty($filters)) {
                foreach ($filters as $field => $value) {
                    $sql->where($field, $value);
                }
            }

            $sql->orderBy('name', 'asc');
            $data = $sql->get();

            return response()->json([
                'success' => true,
                'count' => count($data),
                'data' => $data
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error loading config',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * 🔹 Create or Update POS Config dynamically (Upsert)
     */
    public function saveConfig(Request $req)
    {
        try {
            $req->validate([
                'table_name' => 'required|string',
                'name' => 'required|string',
                'description' => 'nullable|string',
                'is_enabled' => 'nullable|boolean',
                'id' => 'nullable|integer'
            ]);

            $tableName = $req->table_name;
            $isEnabled = $req->input('is_enabled', true);
            $id = $req->input('id');

            if ($id) {
                // 🔹 Update existing config
                $updated = DB::table($tableName)
                    ->where('id', $id)
                    ->update([
                        'name' => $req->name,
                        'description' => $req->description ?? null,
                        'is_enabled' => $isEnabled,
                        'updated_at' => now()
                    ]);

                if (!$updated) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Config item not found'
                    ], 404);
                }

                return response()->json([
                    'success' => true,
                    'message' => 'Config item updated successfully'
                ]);
            } else {
                // 🔹 Create new config
                DB::table($tableName)->insert([
                    'name' => $req->name,
                    'description' => $req->description ?? null,
                    'is_enabled' => $isEnabled,
                    'created_at' => now(),
                    'updated_at' => now()
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Config item created successfully'
                ]);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to save config',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * 🔹 Delete a config item dynamically
     */
    public function deleteConfig(Request $req, $id)
    {
        try {
            $req->validate(['table_name' => 'required|string']);
            $tableName = $req->table_name;

            $deleted = DB::table($tableName)->where('id', $id)->delete();

            if (!$deleted) {
                return response()->json([
                    'success' => false,
                    'message' => 'Config item not found'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'message' => 'Config item deleted successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete config',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
 * 🔹 Return available config tables
 */
public function getConfigTables()
{
    // You can define allowed tables here
    $tables = [
        ['table_name' => 'inv_categories', 'display_name' => 'Categories'],
        ['table_name' => 'inv_product_units', 'display_name' => 'Units'],
        ['table_name' => 'inv_products', 'display_name' => 'Products']
        // Add more tables here
    ];

    return response()->json([
        'success' => true,
        'data' => $tables
    ]);
}

/**
 * 🔹 Get columns for a table dynamically
 */
public function getTableColumns(Request $req)
{
    $tableName = $req->query('table_name');

    if (!$tableName || !Schema::hasTable($tableName)) {
        return response()->json([
            'success' => false,
            'message' => 'Invalid table'
        ], 400);
    }

    $columns = Schema::getColumnListing($tableName); // Get all columns
    $data = [];

    foreach ($columns as $col) {
        $data[] = [
            'name' => $col,
            'type' => DB::getSchemaBuilder()->getColumnType($tableName, $col)
        ];
    }

    return response()->json([
        'success' => true,
        'data' => $data
    ]);
}

}
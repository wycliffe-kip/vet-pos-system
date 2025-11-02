<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PrintReceiptJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected int $saleId;

    public function __construct(int $saleId)
    {
        $this->saleId = $saleId;
    }

    public function handle(): void
    {
        $sale = DB::selectOne("
            SELECT s.*, u.name AS cashier_name, c.name AS customer_name
            FROM pos_sales s
            LEFT JOIN usr_users u ON s.user_id = u.id
            LEFT JOIN pos_customers c ON s.customer_id = c.id
            WHERE s.id = ?
        ", [$this->saleId]);

        $items = DB::select("
            SELECT si.*, p.name AS product_name, pu.name AS unit_name
            FROM pos_sale_items si
            LEFT JOIN inv_products p ON si.product_id = p.id
            LEFT JOIN inv_product_units pu ON si.unit_id = pu.id
            WHERE si.sale_id = ?
        ", [$this->saleId]);

        if (!$sale) {
            Log::warning("Receipt job: sale not found for ID {$this->saleId}");
            return;
        }

        // Here you can integrate with printer or PDF generator
        Log::info("🧾 Printing receipt for Sale #{$sale->receipt_no}, Total: {$sale->total_amount}");

        foreach ($items as $item) {
            Log::info("- {$item->product_name} x {$item->quantity} @ {$item->unit_price}");
        }

        // Optionally send to printer / email / PDF generator
    }
}

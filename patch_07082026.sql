-- AGD Demand Planner — data patch 07/08/2026
-- Run in Supabase SQL editor (yxaebxkkclbjezffmerw)
-- Fixes: (1) QLD stock zeroed — all stock in NSW, (2) open SO committed cartons, (3) default weekly rates for forecast
-- =====================================================================

-- Step 1: Schema additions
ALTER TABLE agd_stock_on_hand ADD COLUMN IF NOT EXISTS committed_cartons int NOT NULL DEFAULT 0;
ALTER TABLE agd_skus          ADD COLUMN IF NOT EXISTS default_weekly_cartons numeric(10,2) NOT NULL DEFAULT 0;

-- Step 2: Correct SOH — all stock is in NSW. QLD = 0 until Sept 2026.
-- Source: NS extract 07/08/2026 (units ÷ carton_units)
UPDATE agd_stock_on_hand SET cartons_qld=0, cartons_nsw=7383, as_at_date='2026-08-07', notes='NS extract 07/08/2026 — all NSW' WHERE sku_code='FG 61737';
UPDATE agd_stock_on_hand SET cartons_qld=0, cartons_nsw=355,  as_at_date='2026-08-07', notes='NS extract 07/08/2026 — all NSW' WHERE sku_code='FG 61739';
UPDATE agd_stock_on_hand SET cartons_qld=0, cartons_nsw=907,  as_at_date='2026-08-07', notes='NS extract 07/08/2026 — all NSW' WHERE sku_code='FG 61740';
UPDATE agd_stock_on_hand SET cartons_qld=0, cartons_nsw=400,  as_at_date='2026-08-07', notes='NS extract 07/08/2026 — all NSW' WHERE sku_code='FG 62059';
UPDATE agd_stock_on_hand SET cartons_qld=0, cartons_nsw=233,  as_at_date='2026-08-07', notes='NS extract 07/08/2026 — all NSW' WHERE sku_code='FG 62060';
UPDATE agd_stock_on_hand SET cartons_qld=0, cartons_nsw=631,  as_at_date='2026-08-07', notes='NS extract 07/08/2026 — all NSW' WHERE sku_code='FG 62106';
UPDATE agd_stock_on_hand SET cartons_qld=0, cartons_nsw=643,  as_at_date='2026-08-07', notes='NS extract 07/08/2026 — all NSW' WHERE sku_code='FG 62108';
UPDATE agd_stock_on_hand SET cartons_qld=0, cartons_nsw=0,    as_at_date='2026-08-07', notes='NS extract 07/08/2026 — verify actual' WHERE sku_code='FG 62322';
UPDATE agd_stock_on_hand SET cartons_qld=0, cartons_nsw=0,    as_at_date='2026-08-07', notes='Update with actual stock' WHERE sku_code='FG PerfTed';

-- Step 3: Committed cartons from open sales orders (NS extract 07/08/2026)
-- These are open/unfulfilled SOs — stock committed but not yet dispatched
UPDATE agd_stock_on_hand SET committed_cartons=2437 WHERE sku_code='FG 61737'; -- 14,625 units ÷ 6
UPDATE agd_stock_on_hand SET committed_cartons=184  WHERE sku_code='FG 61739'; -- 1,108 units ÷ 6
UPDATE agd_stock_on_hand SET committed_cartons=70   WHERE sku_code='FG 61740'; -- 420 units ÷ 6
UPDATE agd_stock_on_hand SET committed_cartons=136  WHERE sku_code='FG 62059'; -- 684 units ÷ 5
UPDATE agd_stock_on_hand SET committed_cartons=0    WHERE sku_code='FG 62060'; -- no open SOs
UPDATE agd_stock_on_hand SET committed_cartons=46   WHERE sku_code='FG 62106'; -- 280 units ÷ 6
UPDATE agd_stock_on_hand SET committed_cartons=793  WHERE sku_code='FG 62108'; -- 4,760 units ÷ 6  ← SHORTFALL
UPDATE agd_stock_on_hand SET committed_cartons=163  WHERE sku_code='FG 62322'; -- 980 units ÷ 6   ← SHORTFALL
UPDATE agd_stock_on_hand SET committed_cartons=0    WHERE sku_code='FG PerfTed';

-- Step 4: Default weekly carton rates (derived from recent SO patterns — update as actuals accumulate)
-- Rate applies 10% growth in the JS layer. Enter actual sales history via the Sales History tab.
UPDATE agd_skus SET default_weekly_cartons=174  WHERE code='FG 61737';
UPDATE agd_skus SET default_weekly_cartons=14   WHERE code='FG 61739';
UPDATE agd_skus SET default_weekly_cartons=5    WHERE code='FG 61740';
UPDATE agd_skus SET default_weekly_cartons=30   WHERE code='FG 62059'; -- conservative (single large WW order in extract)
UPDATE agd_skus SET default_weekly_cartons=0    WHERE code='FG 62060'; -- no history — enter via UI
UPDATE agd_skus SET default_weekly_cartons=4    WHERE code='FG 62106';
UPDATE agd_skus SET default_weekly_cartons=113  WHERE code='FG 62108';
UPDATE agd_skus SET default_weekly_cartons=33   WHERE code='FG 62322';
-- PerfectTed — all zero until actuals confirmed with Richard
UPDATE agd_skus SET default_weekly_cartons=0 WHERE code='FG PerfectTed Vanilla Matcha Powder 75g';
UPDATE agd_skus SET default_weekly_cartons=0 WHERE code='FG PerfectTed Strawberry Matcha Powder 75g';
UPDATE agd_skus SET default_weekly_cartons=0 WHERE code='FG PerfectTed Original Matcha Powder 30g';
UPDATE agd_skus SET default_weekly_cartons=0 WHERE code='FG PerfectTed Matcha Non Organic 250g';
UPDATE agd_skus SET default_weekly_cartons=0 WHERE code='FG PerfectTed Matcha Latte Vanilla 250ml';
UPDATE agd_skus SET default_weekly_cartons=0 WHERE code='FG PerfectTed - Apple Raspberry 250ml';
UPDATE agd_skus SET default_weekly_cartons=0 WHERE code='FG PerfectTed - Juicy Peach 250ml';

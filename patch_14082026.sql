-- ═══════════════════════════════════════════════════════════════════════════
-- AGD Demand Planner — NS Sync Patch 14/08/2026
-- Source: NS customsearch5808 (AGD - M&N Pending Fulfilment Sales Orders)
-- Queried: 14/08/2026 by Nike (daemon session)
-- Applied: 14/08/2026 by Nike (daemon session)
-- ═══════════════════════════════════════════════════════════════════════════

-- ── 1. Update committed_cartons for PerfectTed open SOs ──────────────────
-- UoM rule: 1 NS Shipper = 1 carton per Richard Carlick 11/08/2026
-- FG 61737 committed (12,680) and FG PerfectTed Matcha Latte Vanilla (10)
-- were already correct — no change required.

UPDATE agd_stock_on_hand
SET committed_cartons = 540,
    notes = 'NS extract 14/08/2026 — committed from open SOs SOAGD2654+SOAGD2655+SOAGD2656 (180+180+180=540 cartons; UoM Shipper=1 carton per RC 11/08/2026)'
WHERE sku_code = 'FG PerfectTed - Apple Raspberry 250ml';

UPDATE agd_stock_on_hand
SET committed_cartons = 434,
    notes = 'NS extract 14/08/2026 — committed from open SOs SOAGD2654+SOAGD2655+SOAGD2656 (146+144+144=434 cartons; UoM Shipper=1 carton per RC 11/08/2026)'
WHERE sku_code = 'FG PerfectTed - Juicy Peach 250ml';

-- ── 2. Full refresh of agd_open_sales_orders ─────────────────────────────
-- All 14 open SO lines from NS customsearch5808 as at 14/08/2026 AEST.
-- Customer column uses NS entity ID (NS-NNNN) — names not resolved this session.
-- SOAGD2569 / FG 61739 included: still pendingFulfillment in NS, overdue 31/07/2026.

DELETE FROM agd_open_sales_orders;

INSERT INTO agd_open_sales_orders
  (so_number, customer, sku_code, sku_name, qty_ordered, qty_remaining, expected_ship_date, status)
VALUES
  ('SOAGD2569', 'NS-6962', 'FG 61739',                                'Oatly Organic 1L (deactivated)',       620,  620,  '2026-07-31', 'pendingFulfillment'),
  ('SOAGD2651', 'NS-6978', 'FG 61737',                                'Oatly Barista 1L',                     140,  140,  '2026-08-17', 'pendingFulfillment'),
  ('SOAGD2644', 'NS-6972', 'FG 61737',                                'Oatly Barista 1L',                     140,  140,  '2026-08-19', 'pendingFulfillment'),
  ('SOAGD2646', 'NS-6971', 'FG 61737',                                'Oatly Barista 1L',                    3100, 3100,  '2026-08-19', 'pendingFulfillment'),
  ('SOAGD2654', 'NS-7236', 'FG PerfectTed - Apple Raspberry 250ml',   'PerfectTed Apple Raspberry 250ml',    180,  180,  '2026-08-19', 'pendingFulfillment'),
  ('SOAGD2654', 'NS-7236', 'FG PerfectTed - Juicy Peach 250ml',       'PerfectTed Juicy Peach 250ml',        146,  146,  '2026-08-19', 'pendingFulfillment'),
  ('SOAGD2655', 'NS-7630', 'FG PerfectTed - Apple Raspberry 250ml',   'PerfectTed Apple Raspberry 250ml',    180,  180,  '2026-08-19', 'pendingFulfillment'),
  ('SOAGD2655', 'NS-7630', 'FG PerfectTed - Juicy Peach 250ml',       'PerfectTed Juicy Peach 250ml',        144,  144,  '2026-08-19', 'pendingFulfillment'),
  ('SOAGD2656', 'NS-7238', 'FG PerfectTed - Apple Raspberry 250ml',   'PerfectTed Apple Raspberry 250ml',    180,  180,  '2026-08-19', 'pendingFulfillment'),
  ('SOAGD2656', 'NS-7238', 'FG PerfectTed - Juicy Peach 250ml',       'PerfectTed Juicy Peach 250ml',        144,  144,  '2026-08-19', 'pendingFulfillment'),
  ('SOAGD2423', 'NS-6971', 'FG 61737',                                'Oatly Barista 1L',                   3100, 3100,  '2026-09-24', 'pendingFulfillment'),
  ('SOAGD2572', 'NS-7388', 'FG PerfectTed Matcha Latte Vanilla 250ml','PerfectTed Matcha Latte Vanilla 250ml', 10,  10,  '2026-10-01', 'pendingFulfillment'),
  ('SOAGD2424', 'NS-6971', 'FG 61737',                                'Oatly Barista 1L',                   3100, 3100,  '2026-10-15', 'pendingFulfillment'),
  ('SOAGD2425', 'NS-6971', 'FG 61737',                                'Oatly Barista 1L',                   3100, 3100,  '2026-11-12', 'pendingFulfillment');

-- ── Verification ─────────────────────────────────────────────────────────
SELECT sku_code, committed_cartons FROM agd_stock_on_hand
WHERE sku_code IN (
  'FG 61737',
  'FG PerfectTed - Apple Raspberry 250ml',
  'FG PerfectTed - Juicy Peach 250ml',
  'FG PerfectTed Matcha Latte Vanilla 250ml'
) ORDER BY sku_code;

SELECT so_number, sku_code, qty_ordered, expected_ship_date
FROM agd_open_sales_orders ORDER BY expected_ship_date NULLS LAST, so_number;
-- Expected: 14 rows

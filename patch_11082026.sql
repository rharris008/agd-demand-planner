-- AGD Demand Planner — SOH correction patch 11/08/2026
-- Root cause: daemon session (11/08/2026 09:45) queried NS SOH in Shippers (case unit)
-- then divided by 6, producing values 6x too small.
-- Richard Carlick instructed: NS UoM for all Oatly items is Shipper (NS unitstype=6).
-- 1 Shipper = 1 carton in planner terms. Do NOT divide by 6.
-- Fix: multiply all affected rows by 6 to restore correct carton quantities.
-- Applied: 11/08/2026 by Nike (daemon session)

-- Corrected SOH (x6 applied to all NS extract 11/08/2026 rows)
UPDATE agd_stock_on_hand SET
  cartons_nsw       = 55344,
  committed_cartons = 18150,
  notes = 'NS extract 11/08/2026 — corrected UoM (x6 per Richard Carlick 11/08/2026, no /6 division)'
WHERE sku_code = 'FG 61737';

UPDATE agd_stock_on_hand SET
  cartons_nsw       = 3486,
  committed_cartons = 1026,
  notes = 'NS extract 11/08/2026 — corrected UoM (x6 per Richard Carlick 11/08/2026, no /6 division)'
WHERE sku_code = 'FG 62059';

UPDATE agd_stock_on_hand SET
  cartons_nsw       = 2238,
  committed_cartons = 0,
  notes = 'NS extract 11/08/2026 — corrected UoM (x6 per Richard Carlick 11/08/2026, no /6 division)'
WHERE sku_code = 'FG 62108';

UPDATE agd_stock_on_hand SET
  cartons_nsw       = 192,
  committed_cartons = 36,
  notes = 'NS extract 11/08/2026 — corrected UoM (x6 per Richard Carlick 11/08/2026, no /6 division)'
WHERE sku_code = 'FG PerfectTed - Apple Raspberry 250ml';

UPDATE agd_stock_on_hand SET
  cartons_nsw       = 144,
  committed_cartons = 36,
  notes = 'NS extract 11/08/2026 — corrected UoM (x6 per Richard Carlick 11/08/2026, no /6 division)'
WHERE sku_code = 'FG PerfectTed - Juicy Peach 250ml';

UPDATE agd_stock_on_hand SET
  cartons_nsw       = 972,
  committed_cartons = 0,
  notes = 'NS extract 11/08/2026 — corrected UoM (x6 per Richard Carlick 11/08/2026, no /6 division)'
WHERE sku_code = 'FG PerfectTed Matcha Latte Vanilla 250ml';

UPDATE agd_stock_on_hand SET
  cartons_nsw       = 1236,
  committed_cartons = 0,
  notes = 'NS extract 11/08/2026 — corrected UoM (x6 per Richard Carlick 11/08/2026, no /6 division)'
WHERE sku_code = 'FG PerfectTed Original Matcha Powder 30g';

-- Verification
SELECT sku_code, cartons_nsw, committed_cartons, as_at_date, notes
FROM agd_stock_on_hand
WHERE as_at_date = '2026-08-11'
ORDER BY sku_code;

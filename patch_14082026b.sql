-- ═══════════════════════════════════════════════════════════════════════════
-- AGD Demand Planner — Patch 14/08/2026 (b)
-- Planned Orders: carton quantity correction
-- Applied: 14/08/2026 by Nike (daemon session)
-- Authorised by: Richard Carlick (email 14/08/2026 "They order in cases")
-- ═══════════════════════════════════════════════════════════════════════════

-- Root cause (same as patch_11082026.sql SOH fix):
-- Oatly NS UoM is "Shipper" = 1 carton. Source order plan files (AGD ORDER
-- PLAN.xlsm, AGD Oatly Planned orders 120826.xlsx) express quantities in cases.
-- The original import (patch_10082026.sql data load) treated these as individual
-- units and divided by 6, producing fractional carton values (e.g. 466.667,
-- 23.333, 93.333). Richard Carlick confirmed 14/08/2026: "They order in cases."
-- Fix: cartons = units (source quantity is already in cases/cartons, no division).
-- Scope: all Oatly 1L rows where units is divisible by 140 (pallet = 140 cartons).

-- ── Applied fix ──────────────────────────────────────────────────────────
-- 67 rows updated (8 Coles Barista 1L, 6 Coles Organic 1L, 53 WW Barista 1L)
UPDATE agd_retailer_planned_orders
SET cartons = units
WHERE (sku_name ILIKE '%oatly%1L%' OR sku_code = 'FG 61737')
  AND (units % 140 = 0)
  AND cartons != units;

-- ── Import rule for future uploads ───────────────────────────────────────
-- When loading Oatly order plan files (Coles xlsm or WW xlsx):
-- The quantity column is in CASES (cartons). Do NOT divide by any case size.
-- cartons = raw_quantity_from_file (1:1, no conversion)
-- This matches the same rule applied to NS SOH queries (patch_11082026.sql).

-- ── Verification ─────────────────────────────────────────────────────────
-- After applying: all Oatly 1L cartons values should be whole numbers
-- divisible by 140. Sample check:
-- SELECT id, retailer, sku_name, delivery_date, units, cartons,
--        cartons::int % 140 AS remainder
-- FROM agd_retailer_planned_orders
-- WHERE sku_name ILIKE '%oatly%1L%'
-- ORDER BY delivery_date;

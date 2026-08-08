-- AGD Demand Planner — SKU deactivation patch 08/08/2026
-- Source: Sharon Salt email 08/08/2026
-- FG 61739, FG 61740, FG 62060, FG 62106 discontinued — NIL SOH
-- Active Oatly SKUs: FG 61737, FG 62059, FG 62108 (retain SOH), FG 62322
-- =====================================================================

-- Deactivate discontinued Oatly SKUs
UPDATE agd_skus SET active = false WHERE code IN ('FG 61739','FG 61740','FG 62060','FG 62106');

-- Verify
SELECT code, active FROM agd_skus ORDER BY brand, code;

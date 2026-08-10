-- ═══════════════════════════════════════════════════════════════════════════
-- AGD Demand Planner — Patch 10/08/2026
-- Retailer Planned Orders: table, SKUs, data load
-- Applied: 10/08/2026 by Nike (daemon session)
-- ═══════════════════════════════════════════════════════════════════════════

-- ── 1. Create agd_retailer_planned_orders table ───────────────────────────
create table if not exists agd_retailer_planned_orders (
  id            serial primary key,
  retailer      text not null,
  sku_code      text not null,
  sku_name      text,
  coles_item_id bigint,
  delivery_date date not null,
  units         int not null default 0,
  cartons       numeric(10,3) not null default 0,
  date_loaded   date not null default current_date,
  source_file   text,
  constraint agd_rpo_unique unique (retailer, sku_code, delivery_date)
);

-- Row-level security
alter table agd_retailer_planned_orders enable row level security;
create policy agd_rpo_all on agd_retailer_planned_orders
  for all using (true) with check (true);

-- ── 2. Add PerfectTed SKUs (specific codes) ──────────────────────────────
-- Note: carton_units are assumed (24 for 250ml cans, 6 for 30g powder)
-- Confirm with Richard Carlick before relying on carton conversions.
insert into agd_skus (code, brand, description, carton_units, active, default_weekly_cartons)
values
  ('FG PerfectTed - Apple Raspberry 250ml', 'PerfectTed', 'Apple Raspberry 250ml', 24, true, 0),
  ('FG PerfectTed - Juicy Peach 250ml',     'PerfectTed', 'Juicy Peach 250ml',     24, true, 0),
  ('FG PerfectTed Matcha Latte Vanilla 250ml','PerfectTed','Matcha Latte Vanilla 250ml',24,true,0),
  ('FG PerfectTed Original Matcha Powder 30g','PerfectTed','Original Matcha Powder 30g', 6,true,0)
on conflict (code) do update set
  brand = excluded.brand,
  description = excluded.description,
  carton_units = excluded.carton_units,
  active = excluded.active;

-- Add SOH rows for new PerfectTed SKUs (zero stock until actuals provided)
insert into agd_stock_on_hand (sku_code, cartons_on_hand, committed_cartons, as_of_date)
values
  ('FG PerfectTed - Apple Raspberry 250ml',  0, 0, current_date),
  ('FG PerfectTed - Juicy Peach 250ml',      0, 0, current_date),
  ('FG PerfectTed Matcha Latte Vanilla 250ml',0, 0, current_date),
  ('FG PerfectTed Original Matcha Powder 30g',0, 0, current_date)
on conflict (sku_code) do nothing;

-- ── 3. Load Coles order plan (10/08–07/09/2026) ──────────────────────────
-- Source: AGD ORDER PLAN.xlsm, received via email 10/08/2026
-- Total: 20,548 units across 6 SKUs, 8 delivery windows
insert into agd_retailer_planned_orders
  (retailer, sku_code, sku_name, coles_item_id, delivery_date, units, cartons, date_loaded, source_file)
values
  -- Oatly Barista 1L (FG 61737, 6/carton) — Coles item 3488980
  ('Coles','FG 61737','Oatly Barista 1L',3488980,'2026-08-10',2800,466.667,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61737','Oatly Barista 1L',3488980,'2026-08-12', 140, 23.333,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61737','Oatly Barista 1L',3488980,'2026-08-17',3360,560.000,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61737','Oatly Barista 1L',3488980,'2026-08-19', 140, 23.333,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61737','Oatly Barista 1L',3488980,'2026-08-24',2380,396.667,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61737','Oatly Barista 1L',3488980,'2026-08-31',2240,373.333,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61737','Oatly Barista 1L',3488980,'2026-09-02', 280, 46.667,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61737','Oatly Barista 1L',3488980,'2026-09-07',3640,606.667,'2026-08-10','AGD ORDER PLAN.xlsm'),
  -- Oatly Organic 1L (FG 61739, 6/carton) — Coles item 3478807
  -- Note: FG 61739 is currently deactivated in agd_skus. Loaded here regardless;
  -- it will not appear in Planning Grid unless reactivated. Flag to Richard.
  ('Coles','FG 61739','Oatly Organic 1L',3478807,'2026-08-10', 560, 93.333,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61739','Oatly Organic 1L',3478807,'2026-08-17', 560, 93.333,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61739','Oatly Organic 1L',3478807,'2026-08-24', 560, 93.333,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61739','Oatly Organic 1L',3478807,'2026-08-31', 420, 70.000,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61739','Oatly Organic 1L',3478807,'2026-09-02', 140, 23.333,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG 61739','Oatly Organic 1L',3478807,'2026-09-07', 560, 93.333,'2026-08-10','AGD ORDER PLAN.xlsm'),
  -- PerfectTed Apple Raspberry 250ml (FG PerfectTed - Apple Raspberry 250ml, 24/carton — assumed)
  -- Coles item 1032793
  ('Coles','FG PerfectTed - Apple Raspberry 250ml','PerfectTed Apple Raspberry 250ml',1032793,'2026-08-10',288,12.000,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG PerfectTed - Apple Raspberry 250ml','PerfectTed Apple Raspberry 250ml',1032793,'2026-08-12', 36, 1.500,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG PerfectTed - Apple Raspberry 250ml','PerfectTed Apple Raspberry 250ml',1032793,'2026-08-24',216, 9.000,'2026-08-10','AGD ORDER PLAN.xlsm'),
  -- PerfectTed Juicy Peach 250ml (FG PerfectTed - Juicy Peach 250ml, 24/carton — assumed)
  -- Coles item 1032807
  ('Coles','FG PerfectTed - Juicy Peach 250ml','PerfectTed Juicy Peach 250ml',1032807,'2026-08-10',216, 9.000,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG PerfectTed - Juicy Peach 250ml','PerfectTed Juicy Peach 250ml',1032807,'2026-08-17', 72, 3.000,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG PerfectTed - Juicy Peach 250ml','PerfectTed Juicy Peach 250ml',1032807,'2026-08-19', 36, 1.500,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG PerfectTed - Juicy Peach 250ml','PerfectTed Juicy Peach 250ml',1032807,'2026-08-24', 72, 3.000,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG PerfectTed - Juicy Peach 250ml','PerfectTed Juicy Peach 250ml',1032807,'2026-08-31', 72, 3.000,'2026-08-10','AGD ORDER PLAN.xlsm'),
  -- PerfectTed Matcha Latte Vanilla 250ml (24/carton — assumed) — Coles item 1602610
  ('Coles','FG PerfectTed Matcha Latte Vanilla 250ml','PerfectTed Matcha Latte Vanilla 250ml',1602610,'2026-08-10',504,21.000,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG PerfectTed Matcha Latte Vanilla 250ml','PerfectTed Matcha Latte Vanilla 250ml',1602610,'2026-08-17',576,24.000,'2026-08-10','AGD ORDER PLAN.xlsm'),
  ('Coles','FG PerfectTed Matcha Latte Vanilla 250ml','PerfectTed Matcha Latte Vanilla 250ml',1602610,'2026-08-24',576,24.000,'2026-08-10','AGD ORDER PLAN.xlsm'),
  -- PerfectTed Original Matcha Powder 30g (6/carton — assumed) — Coles item 1789985
  ('Coles','FG PerfectTed Original Matcha Powder 30g','PerfectTed Original Matcha Powder 30g',1789985,'2026-08-17',104,17.333,'2026-08-10','AGD ORDER PLAN.xlsm')
on conflict (retailer, sku_code, delivery_date) do update set
  units = excluded.units,
  cartons = excluded.cartons,
  sku_name = excluded.sku_name;

-- ── Verification query ────────────────────────────────────────────────────
-- select sku_code, sum(units) as total_units, count(*) as rows
-- from agd_retailer_planned_orders
-- where retailer='Coles'
-- group by sku_code order by sku_code;
-- Expected grand total: 20,548 units

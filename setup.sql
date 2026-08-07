-- AGD Demand Planner — Supabase setup
-- Run once in the Supabase SQL editor (yxaebxkkclbjezffmerw)
-- =====================================================================

create table if not exists agd_skus (
  id           serial primary key,
  code         text unique not null,
  description  text not null,
  carton_units int  not null default 6,
  supplier     text,
  lead_min_wks int  not null default 12,
  lead_max_wks int  not null default 16,
  safety_wks   int  not null default 6,
  brand        text not null default 'Oatly',
  active       bool not null default true,
  created_at   timestamptz default now()
);

create table if not exists agd_stock_on_hand (
  id              serial primary key,
  sku_code        text not null references agd_skus(code) on delete cascade,
  cartons_qld     int  not null default 0,
  cartons_nsw     int  not null default 0,
  as_at_date      date not null default current_date,
  notes           text,
  updated_at      timestamptz default now(),
  constraint agd_soh_sku_unique unique (sku_code)
);

create table if not exists agd_purchase_orders (
  id             serial primary key,
  po_number      text not null,
  sku_code       text not null references agd_skus(code) on delete cascade,
  supplier       text,
  cartons_qld    int  not null default 0,
  cartons_nsw    int  not null default 0,
  order_date     date,
  eta_date       date,
  status         text not null default 'Placed' check (status in ('Placed','On Water','Arrived','Cancelled')),
  notes          text,
  created_at     timestamptz default now()
);

create table if not exists agd_sales_history (
  id           serial primary key,
  sku_code     text not null references agd_skus(code) on delete cascade,
  retailer     text not null,
  week_date    date not null,
  cartons_sold numeric(10,2) not null default 0,
  constraint agd_sales_hist_unique unique (sku_code, retailer, week_date)
);

create table if not exists agd_promos (
  id           serial primary key,
  sku_code     text not null references agd_skus(code) on delete cascade,
  retailer     text not null,
  promo_week   date not null,
  uplift_type  text not null default 'pct' check (uplift_type in ('pct','cartons')),
  uplift_value numeric(10,2) not null default 0,
  notes        text,
  created_at   timestamptz default now()
);

-- Enable RLS (row-level security) — anon key gets full access for this planner
alter table agd_skus           enable row level security;
alter table agd_stock_on_hand  enable row level security;
alter table agd_purchase_orders enable row level security;
alter table agd_sales_history  enable row level security;
alter table agd_promos         enable row level security;

-- Open policies (internal tool — no auth required)
drop policy if exists agd_skus_all            on agd_skus;
drop policy if exists agd_soh_all             on agd_stock_on_hand;
drop policy if exists agd_po_all              on agd_purchase_orders;
drop policy if exists agd_sales_all           on agd_sales_history;
drop policy if exists agd_promos_all          on agd_promos;

create policy agd_skus_all            on agd_skus            for all to anon using (true) with check (true);
create policy agd_soh_all             on agd_stock_on_hand   for all to anon using (true) with check (true);
create policy agd_po_all              on agd_purchase_orders  for all to anon using (true) with check (true);
create policy agd_sales_all           on agd_sales_history    for all to anon using (true) with check (true);
create policy agd_promos_all          on agd_promos           for all to anon using (true) with check (true);

-- ── Seed SKU master ──────────────────────────────────────────────────────────
insert into agd_skus (code,description,carton_units,supplier,lead_min_wks,lead_max_wks,safety_wks,brand) values
  ('FG 61737','Oatly Oat Milk Barista Edition 1L',  6,'Oatly EMEA AB',12,16,6,'Oatly'),
  ('FG 61739','Oatly Oat Milk Organic 1L',          6,'Oatly EMEA AB',12,16,6,'Oatly'),
  ('FG 61740','Oatly Oat Milk Chocolate 1L',        6,'Oatly EMEA AB',12,16,6,'Oatly'),
  ('FG 62059','Oatly Oat Milk Barista Edition 500ml',5,'Oatly EMEA AB',12,16,6,'Oatly'),
  ('FG 62060','Oatly Oat Milk Vanilla Flavour 1L',  6,'Oatly EMEA AB',12,16,6,'Oatly'),
  ('FG 62106','Oatly Oat Milk Low Sugar 1L',        6,'Oatly EMEA AB',12,16,6,'Oatly'),
  ('FG 62108','Oatly Oat Milk Full 2.8% Fat 1L',    6,'Oatly EMEA AB',12,16,6,'Oatly'),
  ('FG 62322','Oatly Oat Milk Barista Organic 1L',  6,'Oatly EMEA AB',12,16,6,'Oatly'),
  ('FG PerfTed','PerfectTed Matcha Energy Powder 75g',1,'PerfectTed Ltd',12,16,6,'PerfectTed')
on conflict (code) do nothing;

-- ── Seed stock on hand (NS extract 07/08/2026 — update via UI) ──────────────
insert into agd_stock_on_hand (sku_code,cartons_qld,cartons_nsw,as_at_date,notes) values
  ('FG 61737', 1500, 5874, '2026-08-07','NS extract 07/08/2026 — split estimated'),
  ('FG 61739',  355, 1778, '2026-08-07','NS extract 07/08/2026 — split estimated'),
  ('FG 61740',  180,  727, '2026-08-07','NS extract 07/08/2026 — split estimated'),
  ('FG 62059',   65,  335, '2026-08-07','NS extract 07/08/2026 — split estimated'),
  ('FG 62060',   45,  234, '2026-08-07','NS extract 07/08/2026 — split estimated'),
  ('FG 62106',  125,  632, '2026-08-07','NS extract 07/08/2026 — split estimated'),
  ('FG 62108',  128,  644, '2026-08-07','NS extract 07/08/2026 — split estimated'),
  ('FG 62322',  190,  952, '2026-08-07','NS extract 07/08/2026 — split estimated'),
  ('FG PerfTed',  0,    0, '2026-08-07','Update with actual stock')
on conflict (sku_code) do nothing;

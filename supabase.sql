-- Run this entire script in Supabase Dashboard > SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 category text not null check (category in ('Eco Meal','South Indian','Thali','Sweets','Snacks','Delhi Ki Chaat','Beverages','Shakes')),
 price numeric(10,2) not null check (price >= 0),
 unit text not null default '1 plate',
 description text,
 image_url text,
 is_available boolean not null default true,
 created_at timestamptz not null default now()
);
create table if not exists public.orders (
 id uuid primary key default gen_random_uuid(),
 order_number text unique not null,
 customer_name text not null,
 customer_phone text not null,
 customer_address text not null,
 items jsonb not null,
 total_amount numeric(10,2) not null check (total_amount >= 0),
 status text not null default 'New' check (status in ('New','Preparing','Done','Cancelled')),
 payment_status text not null default 'Unpaid' check (payment_status in ('Unpaid','Paid')),
 created_at timestamptz not null default now()
);
-- Admin allowlist: only authenticated Supabase Auth users whose phone is listed here can manage data.
create table if not exists public.admin_users (
 user_id uuid primary key references auth.users(id) on delete cascade,
 phone text unique not null,
 created_at timestamptz not null default now()
);
create or replace function public.is_shop_admin() returns boolean
language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.admin_users a where a.user_id = (select auth.uid()));
$$;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.admin_users enable row level security;
drop policy if exists "Anyone can view available products" on public.products;
create policy "Anyone can view available products" on public.products for select using (is_available = true or public.is_shop_admin());
drop policy if exists "Admins manage products" on public.products;
create policy "Admins manage products" on public.products for all using (public.is_shop_admin()) with check (public.is_shop_admin());
drop policy if exists "Customers can place orders" on public.orders;
create policy "Customers can place orders" on public.orders for insert with check (true);
drop policy if exists "Admins view orders" on public.orders;
create policy "Admins view orders" on public.orders for select using (public.is_shop_admin());
drop policy if exists "Admins update orders" on public.orders;
create policy "Admins update orders" on public.orders for update using (public.is_shop_admin()) with check (public.is_shop_admin());
drop policy if exists "Admins view own admin row" on public.admin_users;
create policy "Admins view own admin row" on public.admin_users for select using (user_id = (select auth.uid()));
-- Add your own admin user after the first successful OTP login:
-- insert into public.admin_users (user_id, phone)
-- select id, phone from auth.users where phone = '+919801265197';
-- IMPORTANT: Keep the anon/publishable key in the frontend; NEVER expose service_role keys.

-- ============================================================
-- lupilup — Initial Schema
-- ============================================================

-- ============================================================
-- yarn_stash
-- ============================================================

create table public.yarn_stash (
  id                  uuid        primary key default gen_random_uuid(),
  user_id             uuid        not null references auth.users on delete cascade,
  type                text        not null check (type in ('skein', 'bobbin', 'blend')),
  brand               text,
  name                text,
  color_name          text,
  color_hex           text,
  fiber_content       text,
  length_m_per_100g   integer,
  current_weight_g    float,
  original_weight_g   float,
  lot                 text,
  parent_ids          uuid[],
  source              text        not null check (source in ('manual', 'scan', 'ravelry')),
  created_at          timestamptz not null default now()
);

alter table public.yarn_stash enable row level security;

-- Index on user_id: used in RLS policy and every app query
create index yarn_stash_user_id_idx on public.yarn_stash (user_id);

-- Partial index to speed up duplicate detection (brand + color_name + lot lookup)
create index yarn_stash_dupe_check_idx
  on public.yarn_stash (user_id, brand, color_name, lot)
  where lot is not null;

-- RLS policies — wrap auth.uid() in SELECT so it is evaluated once per query
create policy "yarn_stash: users read own rows" on public.yarn_stash
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "yarn_stash: users insert own rows" on public.yarn_stash
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "yarn_stash: users update own rows" on public.yarn_stash
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "yarn_stash: users delete own rows" on public.yarn_stash
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);


-- ============================================================
-- projects
-- ============================================================

create table public.projects (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null references auth.users on delete cascade,
  title       text        not null,
  status      text        not null check (status in ('active', 'finished', 'on_hold')),
  current_row integer     not null default 0,
  yarn_ids    uuid[],
  created_at  timestamptz not null default now()
);

alter table public.projects enable row level security;

create index projects_user_id_idx on public.projects (user_id);

-- Partial index: most app queries filter by active status
create index projects_user_active_idx
  on public.projects (user_id, created_at desc)
  where status = 'active';

create policy "projects: users read own rows" on public.projects
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "projects: users insert own rows" on public.projects
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "projects: users update own rows" on public.projects
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "projects: users delete own rows" on public.projects
  for delete
  to authenticated
  using ((select auth.uid()) = user_id);


-- ============================================================
-- user_settings
-- ============================================================

create table public.user_settings (
  user_id         uuid        primary key references auth.users on delete cascade,
  unit_system     text        not null check (unit_system in ('metric', 'imperial')) default 'metric',
  ai_scans_used   integer     not null default 0,
  is_premium      boolean     not null default false,
  ravelry_token   text,
  created_at      timestamptz not null default now()
);

alter table public.user_settings enable row level security;

-- No separate index needed — user_id is the primary key

create policy "user_settings: users read own row" on public.user_settings
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "user_settings: users insert own row" on public.user_settings
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "user_settings: users update own row" on public.user_settings
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- Settings row is not deletable by the user — deleted via cascade when auth.users is deleted

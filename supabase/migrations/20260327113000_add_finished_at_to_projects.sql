alter table public.projects
  add column if not exists finished_at timestamptz;

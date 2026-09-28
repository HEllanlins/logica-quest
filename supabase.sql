-- Rode este arquivo inteiro no Supabase: SQL Editor > New query > Run

create table public.progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  done jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint done_pequeno check (pg_column_size(done) < 2000)
);

-- Liga a segurança por linha: sem policy, ninguém acessa nada
alter table public.progress enable row level security;

create policy "ler o proprio progresso" on public.progress
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "criar o proprio progresso" on public.progress
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "editar o proprio progresso" on public.progress
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "apagar o proprio progresso" on public.progress
  for delete to authenticated
  using ((select auth.uid()) = user_id);

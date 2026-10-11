-- Run this file in Supabase SQL Editor for the surprise gift section.
create table if not exists public.academy_gift (
  id integer primary key check (id = 1),
  is_open boolean not null default false,
  prize_title text not null default 'هدية مفاجئة',
  gift_code text not null default '',
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id) on delete set null
);

insert into public.academy_gift (id, is_open, prize_title, gift_code)
values (1, false, 'هدية مفاجئة', '')
on conflict (id) do nothing;

alter table public.academy_gift enable row level security;
grant usage on schema public to anon, authenticated;
grant select on public.academy_gift to anon, authenticated;
grant insert, update on public.academy_gift to authenticated;

drop policy if exists "Public can read gift status" on public.academy_gift;
create policy "Public can read gift status"
on public.academy_gift for select
to anon, authenticated
using (is_open = true);

drop policy if exists "Admins manage surprise gift" on public.academy_gift;
create policy "Admins manage surprise gift"
on public.academy_gift for all
to authenticated
using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
)
with check (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);

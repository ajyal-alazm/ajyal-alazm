-- إعداد ميزة نجوم وأوسمة أكاديمية أجيال العزم
-- شغّل هذا الملف مرة واحدة في Supabase > SQL Editor.

create table if not exists public.academy_awards (
  award_type text primary key check (award_type in ('day','week','month')),
  player_id uuid references public.players(id) on delete set null,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id) on delete set null
);

alter table public.academy_awards enable row level security;

drop policy if exists "Public can view academy awards" on public.academy_awards;
create policy "Public can view academy awards"
on public.academy_awards for select
to anon, authenticated
using (true);

drop policy if exists "Admins can manage academy awards" on public.academy_awards;
create policy "Admins can manage academy awards"
on public.academy_awards for all
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
)
with check (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);

-- منح صلاحيات SQL اللازمة؛ سياسات RLS أعلاه تظل مسؤولة عن تحديد الصفوف المسموح بها.
grant select on table public.academy_awards to anon, authenticated;
grant insert, update, delete on table public.academy_awards to authenticated;

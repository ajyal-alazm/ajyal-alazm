-- إضافات أخبار العزم وألبوم الصور
-- نفّذ هذا الملف في Supabase > SQL Editor بحساب مالك المشروع.
create table if not exists public.academy_news (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  image_url text not null,
  published boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
create table if not exists public.academy_gallery (
  id uuid primary key default gen_random_uuid(),
  image_url text not null,
  caption text,
  published boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
alter table public.academy_news enable row level security;
alter table public.academy_gallery enable row level security;

drop policy if exists "Public can read published academy news" on public.academy_news;
create policy "Public can read published academy news"
on public.academy_news for select to anon, authenticated
using (published = true);

drop policy if exists "Admins manage academy news" on public.academy_news;
create policy "Admins manage academy news"
on public.academy_news for all to authenticated
using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'))
with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

drop policy if exists "Public can read published academy gallery" on public.academy_gallery;
create policy "Public can read published academy gallery"
on public.academy_gallery for select to anon, authenticated
using (published = true);

drop policy if exists "Admins manage academy gallery" on public.academy_gallery;
create policy "Admins manage academy gallery"
on public.academy_gallery for all to authenticated
using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'))
with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

-- تأكد أن bucket player-images موجود ومضبوط وفق سياسات التخزين الحالية.

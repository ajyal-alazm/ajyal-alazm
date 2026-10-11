-- إصلاح permission denied للأخبار وألبوم الصور
-- نفّذ هذا الملف مرة واحدة في Supabase > SQL Editor.
-- المنح لا تتجاوز RLS؛ سيظل الزوار قادرين على قراءة المنشور فقط.

grant usage on schema public to anon, authenticated;
grant select on table public.academy_news to anon, authenticated;
grant select on table public.academy_gallery to anon, authenticated;
grant insert, update, delete on table public.academy_news to authenticated;
grant insert, update, delete on table public.academy_gallery to authenticated;

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

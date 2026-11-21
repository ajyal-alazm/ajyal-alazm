-- إصلاح صلاحيات تحميل اللاعبين في موقع أكاديمية أجيال العزم
-- آمن للتشغيل أكثر من مرة، ولا يحذف أي بيانات.

grant usage on schema public to anon, authenticated;

-- الزوار والمستخدمون المسجلون يمكنهم القراءة فقط؛ وتتحكم RLS بما يظهر لهم.
grant select on table
  public.players,
  public.player_assessments,
  public.player_photos,
  public.parent_reviews
to anon, authenticated;

-- التعديل والإضافة والحذف للمستخدمين المسجلين فقط، مع بقاء RLS حاجز الصلاحيات.
grant select, insert, update, delete on table
  public.players,
  public.player_assessments,
  public.player_photos,
  public.parent_reviews,
  public.profiles
to authenticated;

grant execute on function public.is_admin() to authenticated;

alter table public.players enable row level security;
alter table public.player_assessments enable row level security;
alter table public.player_photos enable row level security;
alter table public.parent_reviews enable row level security;
alter table public.profiles enable row level security;

-- إعادة تثبيت سياسات القراءة العامة دون السماح بقراءة الملفات غير المنشورة.
drop policy if exists "Public reads published players" on public.players;
create policy "Public reads published players"
on public.players for select to anon, authenticated
using (published = true);

drop policy if exists "Public reads assessments for published players" on public.player_assessments;
create policy "Public reads assessments for published players"
on public.player_assessments for select to anon, authenticated
using (exists (
  select 1 from public.players p
  where p.id = player_id and p.published = true
));

drop policy if exists "Public reads published photos" on public.player_photos;
create policy "Public reads published photos"
on public.player_photos for select to anon, authenticated
using (published = true and exists (
  select 1 from public.players p
  where p.id = player_id and p.published = true
));

drop policy if exists "Public reads published reviews" on public.parent_reviews;
create policy "Public reads published reviews"
on public.parent_reviews for select to anon, authenticated
using (published = true);

-- صلاحيات الإدارة تبقى محصورة بحساب يحمل role = 'admin'.
drop policy if exists "Admins manage players" on public.players;
create policy "Admins manage players"
on public.players for all to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Admins manage assessments" on public.player_assessments;
create policy "Admins manage assessments"
on public.player_assessments for all to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Admins manage photos" on public.player_photos;
create policy "Admins manage photos"
on public.player_photos for all to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Admins manage reviews" on public.parent_reviews;
create policy "Admins manage reviews"
on public.parent_reviews for all to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Users read own profile" on public.profiles;
create policy "Users read own profile"
on public.profiles for select to authenticated
using (id = (select auth.uid()) or public.is_admin());

drop policy if exists "Admins manage profiles" on public.profiles;
create policy "Admins manage profiles"
on public.profiles for all to authenticated
using (public.is_admin())
with check (public.is_admin());

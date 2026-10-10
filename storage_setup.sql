-- Run this once in Supabase SQL Editor to enable public player images and admin uploads.
-- This does NOT replace the tables/RLS policies you already created.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('player-images', 'player-images', true, 5242880, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = true, file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif'];

drop policy if exists "Public can view academy player images" on storage.objects;
create policy "Public can view academy player images"
on storage.objects for select to anon, authenticated
using (bucket_id = 'player-images');

drop policy if exists "Academy admins upload player images" on storage.objects;
create policy "Academy admins upload player images"
on storage.objects for insert to authenticated
with check (bucket_id = 'player-images' and public.is_admin());

drop policy if exists "Academy admins update player images" on storage.objects;
create policy "Academy admins update player images"
on storage.objects for update to authenticated
using (bucket_id = 'player-images' and public.is_admin())
with check (bucket_id = 'player-images' and public.is_admin());

drop policy if exists "Academy admins delete player images" on storage.objects;
create policy "Academy admins delete player images"
on storage.objects for delete to authenticated
using (bucket_id = 'player-images' and public.is_admin());

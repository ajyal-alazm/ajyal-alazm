-- Supabase starter schema for Ajyal Alazm Football Academy
-- Run in the Supabase SQL Editor. Review and test all policies before production.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  role text not null default 'parent' check (role in ('admin','parent')),
  created_at timestamptz not null default now()
);

create table if not exists public.players (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  birth_year integer,
  category text check (category in ('الصغار','الوسط','الكبار')),
  position text,
  branch text check (branch in ('مادبا','خلدا','ذيبان')),
  coach_name text,
  photo_url text,
  published boolean not null default false,
  public_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.player_assessments (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references public.players(id) on delete cascade,
  assessment_date date not null default current_date,
  speed integer not null default 0 check (speed between 0 and 100),
  shooting integer not null default 0 check (shooting between 0 and 100),
  passing integer not null default 0 check (passing between 0 and 100),
  flexibility integer not null default 0 check (flexibility between 0 and 100),
  balance integer not null default 0 check (balance between 0 and 100),
  endurance integer not null default 0 check (endurance between 0 and 100),
  teamwork integer not null default 0 check (teamwork between 0 and 100),
  individual_skills integer not null default 0 check (individual_skills between 0 and 100),
  discipline integer not null default 0 check (discipline between 0 and 100),
  overall integer not null default 0 check (overall between 0 and 100),
  coach_notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.player_photos (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references public.players(id) on delete cascade,
  image_url text not null,
  caption text,
  taken_at date,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.parent_reviews (
  id uuid primary key default gen_random_uuid(),
  parent_display_name text not null,
  player_id uuid references public.players(id) on delete set null,
  review_text text not null,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.role = 'admin'
  );
$$;

alter table public.profiles enable row level security;
alter table public.players enable row level security;
alter table public.player_assessments enable row level security;
alter table public.player_photos enable row level security;
alter table public.parent_reviews enable row level security;

-- Public can only read published player profiles.
create policy "Public reads published players"
on public.players for select
to anon, authenticated
using (published = true);

create policy "Admins manage players"
on public.players for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- Public can read assessments only for published players.
create policy "Public reads assessments for published players"
on public.player_assessments for select
to anon, authenticated
using (exists (
  select 1 from public.players p
  where p.id = player_id and p.published = true
));

create policy "Admins manage assessments"
on public.player_assessments for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "Public reads published photos"
on public.player_photos for select
to anon, authenticated
using (published = true and exists (
  select 1 from public.players p
  where p.id = player_id and p.published = true
));

create policy "Admins manage photos"
on public.player_photos for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "Public reads published reviews"
on public.parent_reviews for select
to anon, authenticated
using (published = true);

create policy "Admins manage reviews"
on public.parent_reviews for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "Users read own profile"
on public.profiles for select
to authenticated
using (id = (select auth.uid()) or public.is_admin());

create policy "Admins manage profiles"
on public.profiles for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- IMPORTANT:
-- Create the first admin account through Supabase Auth, then assign its role:
-- update public.profiles set role = 'admin' where id = '<AUTH_USER_UUID>';
-- Create the matching profiles row for that auth user first.
-- Do not expose service_role keys in browser code.

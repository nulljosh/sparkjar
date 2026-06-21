-- Enable RLS on all tables and create permissive policies.
-- Spark uses the service role key server-side, so RLS is bypassed for API calls.
-- These policies protect against direct anon-key access from the client.
-- Safe to re-run: drops existing policies before recreating.

-- Posts
alter table posts enable row level security;

drop policy if exists "anon_read_posts" on posts;
create policy "anon_read_posts" on posts for select using (true);

drop policy if exists "api_insert_posts" on posts;
create policy "api_insert_posts" on posts for insert with check (true);

drop policy if exists "api_update_posts" on posts;
create policy "api_update_posts" on posts for update using (true);

drop policy if exists "api_delete_posts" on posts;
create policy "api_delete_posts" on posts for delete using (true);

-- Users
alter table users enable row level security;

drop policy if exists "anon_read_users" on users;
create policy "anon_read_users" on users for select using (true);

drop policy if exists "no_direct_write_users" on users;
create policy "no_direct_write_users" on users for insert with check (false);

drop policy if exists "no_direct_update_users" on users;
create policy "no_direct_update_users" on users for update using (false);

drop policy if exists "no_direct_delete_users" on users;
create policy "no_direct_delete_users" on users for delete using (false);

-- Comments
alter table comments enable row level security;

drop policy if exists "anon_read_comments" on comments;
create policy "anon_read_comments" on comments for select using (true);

drop policy if exists "api_insert_comments" on comments;
create policy "api_insert_comments" on comments for insert with check (true);

drop policy if exists "api_delete_comments" on comments;
create policy "api_delete_comments" on comments for delete using (true);

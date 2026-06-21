-- Tighten RLS policies: only authenticated users can write, only authors can update/delete.
-- Safe to re-run: drops existing policies before recreating.

-- Posts
drop policy if exists "api_insert_posts" on posts;
create policy "authenticated_insert_posts" on posts for insert
  to authenticated
  with check (auth.uid()::text = author_user_id);

drop policy if exists "api_update_posts" on posts;
create policy "author_update_posts" on posts for update
  to authenticated
  using (auth.uid()::text = author_user_id);

drop policy if exists "api_delete_posts" on posts;
create policy "author_delete_posts" on posts for delete
  to authenticated
  using (auth.uid()::text = author_user_id);

-- Comments
drop policy if exists "api_insert_comments" on comments;
create policy "authenticated_insert_comments" on comments for insert
  to authenticated
  with check (auth.uid()::text = user_id);

drop policy if exists "api_delete_comments" on comments;
create policy "author_delete_comments" on comments for delete
  to authenticated
  using (auth.uid()::text = user_id);

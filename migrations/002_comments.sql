-- Adds comments table for post comment threads

create table if not exists comments (
  id text primary key,
  post_id text not null references posts(id) on delete cascade,
  user_id text not null,
  username text not null,
  content text not null,
  created_at timestamptz default now()
);

create index if not exists idx_comments_post_id on comments(post_id);
create index if not exists idx_comments_created on comments(created_at desc);

-- RLS
alter table comments enable row level security;
create policy "anon_read_comments" on comments for select using (true);
create policy "api_insert_comments" on comments for insert with check (true);
create policy "api_delete_comments" on comments for delete using (true);

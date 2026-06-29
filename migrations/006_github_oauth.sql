-- Add GitHub OAuth support to users table
alter table users add column if not exists github_id text unique;
alter table users add column if not exists avatar_url text;
-- Allow null password fields for OAuth-only users
alter table users alter column password_salt drop not null;
alter table users alter column password_hash drop not null;
create index if not exists idx_users_github_id on users(github_id) where github_id is not null;

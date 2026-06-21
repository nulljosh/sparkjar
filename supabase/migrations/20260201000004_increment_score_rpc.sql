-- RPC function for atomic score increment (avoids read-modify-write race condition)
create or replace function increment_score(post_id text, delta integer)
returns integer
language sql
security definer
as $$
  update posts
  set score = score + delta
  where id = post_id
  returning score;
$$;

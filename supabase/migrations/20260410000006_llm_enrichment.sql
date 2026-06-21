-- LLM Enrichment + IdeaBase system
-- Adds enrichment columns to posts and creates idea_bases table

ALTER TABLE posts
  ADD COLUMN IF NOT EXISTS enriched boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS enrichment_plan text,
  ADD COLUMN IF NOT EXISTS enrichment_spec text,
  ADD COLUMN IF NOT EXISTS linked_repo text,
  ADD COLUMN IF NOT EXISTS enrichment_requested_at timestamptz,
  ADD COLUMN IF NOT EXISTS enrichment_completed_at timestamptz;

CREATE TABLE IF NOT EXISTS idea_bases (
  id text PRIMARY KEY DEFAULT 'ib-' || extract(epoch from now())::bigint::text || '-' || left(md5(random()::text), 6),
  topic text NOT NULL,
  description text,
  post_ids text[] DEFAULT '{}',
  pending boolean DEFAULT true,
  created_by text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_posts_needs_enrichment
  ON posts(created_at DESC)
  WHERE enriched = false AND enrichment_requested_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_idea_bases_pending
  ON idea_bases(created_at DESC)
  WHERE pending = true;

-- RLS for idea_bases: anyone can read, authenticated users can insert
ALTER TABLE idea_bases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "idea_bases_read_all" ON idea_bases
  FOR SELECT USING (true);

CREATE POLICY "idea_bases_insert_auth" ON idea_bases
  FOR INSERT WITH CHECK (true);

CREATE POLICY "idea_bases_update_daemon" ON idea_bases
  FOR UPDATE USING (true);

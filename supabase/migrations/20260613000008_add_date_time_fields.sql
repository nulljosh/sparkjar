-- Add date and time fields to posts and idea_bases tables

ALTER TABLE posts ADD COLUMN IF NOT EXISTS date date DEFAULT NULL;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS time time DEFAULT NULL;

ALTER TABLE idea_bases ADD COLUMN IF NOT EXISTS date date DEFAULT NULL;
ALTER TABLE idea_bases ADD COLUMN IF NOT EXISTS time time DEFAULT NULL;

-- Add indexes for efficient date filtering/sorting
CREATE INDEX IF NOT EXISTS idx_posts_date ON posts(date DESC);
CREATE INDEX IF NOT EXISTS idx_idea_bases_date ON idea_bases(date DESC);

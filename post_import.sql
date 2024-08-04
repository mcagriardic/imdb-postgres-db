-- Clean up title.basics
UPDATE title_basics
SET is_adult = CASE WHEN is_adult = '1' THEN 'true'
                    WHEN is_adult = '0' THEN 'false'
                    ELSE NULL END;

ALTER TABLE title_basics
ALTER COLUMN is_adult TYPE BOOLEAN USING is_adult::boolean;

-- Clean up title.principals
UPDATE title_principals
SET characters = regexp_replace(characters, '^\[(.*)\]$', '\1', 'g');

-- Remove any remaining double quotes
UPDATE title_principals
SET characters = replace(characters, '"', '');

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_name_basics_primary_name ON name_basics(primary_name);
CREATE INDEX IF NOT EXISTS idx_title_basics_primary_title ON title_basics(primary_title);
CREATE INDEX IF NOT EXISTS idx_title_basics_start_year ON title_basics(start_year);
CREATE INDEX IF NOT EXISTS idx_title_ratings_average_rating ON title_ratings(average_rating);
CREATE INDEX IF NOT EXISTS idx_title_episode_parent_tconst ON title_episode(parent_tconst);
CREATE INDEX IF NOT EXISTS idx_title_principals_nconst ON title_principals(nconst);

-- These take a looong time. Execute at your own risk...
-- CREATE INDEX IF NOT EXISTS idx_name_basics_nconst ON name_basics(nconst);
-- CREATE INDEX IF NOT EXISTS idx_title_principals_tconst ON title_principals(tconst);
-- CREATE INDEX IF NOT EXISTS idx_title_akas_tconst ON title_akas(tconst);
-- CREATE INDEX IF NOT EXISTS idx_title_crew_tconst ON title_crew(tconst);
-- CREATE INDEX IF NOT EXISTS idx_title_basics_tconst ON title_basics(tconst);
-- CREATE INDEX IF NOT EXISTS idx_title_episode_tconst ON title_episode(tconst);
-- CREATE INDEX IF NOT EXISTS idx_title_ratings_tconst ON title_ratings(tconst);

-- Add foreign key constraints
ALTER TABLE title_episode ADD CONSTRAINT fk_title_episode_parent 
FOREIGN KEY (parent_tconst) REFERENCES title_basics(tconst);

ALTER TABLE title_principals ADD CONSTRAINT fk_title_principals_title 
FOREIGN KEY (tconst) REFERENCES title_basics(tconst);

ALTER TABLE title_principals ADD CONSTRAINT fk_title_principals_name 
FOREIGN KEY (nconst) REFERENCES name_basics(nconst);

ALTER TABLE title_crew ADD CONSTRAINT fk_title_crew_title 
FOREIGN KEY (tconst) REFERENCES title_basics(tconst);

ALTER TABLE title_ratings ADD CONSTRAINT fk_title_ratings_title 
FOREIGN KEY (tconst) REFERENCES title_basics(tconst);

-- This title doesn't exist in title_basics for some reason...
DELETE FROM title_akas
WHERE tconst = 'tt16275710';
ALTER TABLE title_akas ADD CONSTRAINT fk_title_akas_title 
FOREIGN KEY (tconst) REFERENCES title_basics(tconst);

-- some titles in title_crew don't exist on title_basic for some reason...
DELETE FROM title_crew
WHERE tconst IN (
	SELECT tc.tconst
		FROM title_crew AS tc
	LEFT JOIN title_basics AS tb 
		ON tc.tconst = tb.tconst
	WHERE tb.tconst IS NULL
);
ALTER TABLE title_crew  ADD CONSTRAINT fk_title_crew_title 
FOREIGN KEY (tconst) REFERENCES title_basics(tconst);

-- Create a function to convert comma-separated strings to arrays
CREATE OR REPLACE FUNCTION string_to_array_nullsafe(text) 
RETURNS text[] LANGUAGE SQL IMMUTABLE AS $$
    SELECT CASE WHEN $1 IS NULL OR $1 = '\N' THEN NULL 
           ELSE string_to_array($1, ',') END;
$$;

-- Convert text columns to arrays after data import
ALTER TABLE name_basics 
ALTER COLUMN primary_profession TYPE TEXT[] USING string_to_array_nullsafe(primary_profession),
ALTER COLUMN known_for_titles TYPE TEXT[] USING string_to_array_nullsafe(known_for_titles);

ALTER TABLE title_akas 
ALTER COLUMN types TYPE TEXT[] USING string_to_array_nullsafe(types),
ALTER COLUMN attributes TYPE TEXT[] USING string_to_array_nullsafe(attributes);

ALTER TABLE title_basics 
ALTER COLUMN genres TYPE TEXT[] USING string_to_array_nullsafe(genres);

ALTER TABLE title_crew 
ALTER COLUMN directors TYPE TEXT[] USING string_to_array_nullsafe(directors),
ALTER COLUMN writers TYPE TEXT[] USING string_to_array_nullsafe(writers);

ALTER TABLE title_principals
ALTER COLUMN characters TYPE TEXT[] USING string_to_array_nullsafe(characters);
ALTER COLUMN jobs TYPE TEXT[] USING string_to_array_nullsafe(jobs);
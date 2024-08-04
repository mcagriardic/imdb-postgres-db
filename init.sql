-- name.basics
CREATE TABLE IF NOT EXISTS name_basics (
    nconst VARCHAR(10) PRIMARY KEY,
    primary_name TEXT,
    birth_year INTEGER,
    death_year INTEGER,
    primary_profession TEXT,
    known_for_titles TEXT
);

-- title.akas
CREATE TABLE IF NOT EXISTS title_akas (
    tconst VARCHAR(10),
    ordering INTEGER,
    title TEXT,
    region VARCHAR(4),
    language VARCHAR(3),
    types TEXT,
    attributes TEXT,
    is_original_title BOOLEAN,
    PRIMARY KEY (tconst, ordering)
);

-- title.basics
CREATE TABLE IF NOT EXISTS title_basics (
    tconst VARCHAR(10) PRIMARY KEY,
    title_type VARCHAR(20),
    primary_title TEXT,
    original_title TEXT,
    is_adult TEXT,
    start_year INTEGER,
    end_year INTEGER,
    runtime_minutes INTEGER,
    genres TEXT
);

-- title.crew
CREATE TABLE IF NOT EXISTS title_crew (
    tconst VARCHAR(10) PRIMARY KEY,
    directors TEXT,
    writers TEXT
);

-- title.episode
CREATE TABLE IF NOT EXISTS title_episode (
    tconst VARCHAR(10) PRIMARY KEY,
    parent_tconst VARCHAR(10),
    season_number INTEGER,
    episode_number INTEGER
);

-- title.principals
CREATE TABLE IF NOT EXISTS title_principals (
    tconst VARCHAR(10),
    ordering INTEGER,
    nconst VARCHAR(10),
    category VARCHAR(50),
    jobs TEXT,
    characters TEXT,
    PRIMARY KEY (tconst, ordering)
);

-- title.ratings
CREATE TABLE IF NOT EXISTS title_ratings (
    tconst VARCHAR(10) PRIMARY KEY,
    average_rating NUMERIC(3,1),
    num_votes INTEGER
);
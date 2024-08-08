# A Noble Quest for Data Mastery in the Realm of SQL

Hear ye, fellow data seekers! Long have I scoured the digital lands for a most coveted treasure - a vast, perfectly normalized database, where one might forge joins between tables with but a command. My heart yearned not merely for the basic incantations of SQL, but for the arcane power to craft queries so efficient they might challenge the very gods of information themselves.

In my journeys through tomes both physical and digital, I discovered that while the fundamental syntax of SQL could be gleaned from sacred texts, true mastery of efficient query-craft remained as elusive as capturing stardust. The hallowed manuscripts I encountered proved as insubstantial as morning mist when faced with the challenge of advanced practice beyond mere joins.

To my brethren in the Halls of Data and the Forges of Software: indeed, we all wield the arts of SQL in our daily labors. Yet, in my experience, the tables we encounter are often denormalized by the high wizards of upstream teams, their intricate design hidden from our mortal eyes. This serves us little in honing our craft or in facing the trials of the dreaded Interview Dragons.

The schemas of our tables have been altered slightly from the original IMDb scrolls, as if by digital sorcery. Some columns that once held mere text have been transmuted into arrays, like quivers holding multiple arrows of information. An example of an enhancement applied to the 'jobs' (renamed from 'job') and 'characters' inscriptions in the scroll of title_principals.

Let our quest for mastery of SQL and the mystical arts of efficient data manipulation commence!

# How to run?
Just `docker-compose up &`. Everything is handled automatically.

# The IMDb Dataset: A Treasure Trove of Movie Data

Fellow data enthusiasts, gather 'round! We've acquired a gem in the world of datasets - the renowned IMDb database. This valuable resource was sourced from https://developer.imdb.com/non-commercial-datasets/ and downloaded to our local environment in August 2024.

At the time of acquisition, the IMDb page provided crucial information about the structure of their tables. Let's unveil the details of these data treasures as they were presented to us:

## IMDb Non-Commercial Datasets

Subsets of IMDb data are available for access to customers for personal and non-commercial use. You can hold local copies of this data, and it is subject to our terms and conditions. Please refer to the Non-Commercial Licensing and copyright/license and verify compliance.

### Notice

As of March 18, 2024 the datasets on this page are backed by a new data source. There has been no change in location or schema, but if you encounter issues with the datasets following the March 18th update, please contact imdb-data-interest@imdb.com.

### Data Location

The dataset files can be accessed and downloaded from https://datasets.imdbws.com/. The data is refreshed daily.

### IMDb Dataset Details

Each dataset is contained in a gzipped, tab-separated-values (TSV) formatted file in the UTF-8 character set. The first line in each file contains headers that describe what is in each column. A '\N' is used to denote that a particular field is missing or null for that title/name. The available datasets are as follows:

#### title.akas.tsv.gz

- `titleId` (string) - a tconst, an alphanumeric unique identifier of the title
- `ordering` (integer) – a number to uniquely identify rows for a given titleId
- `title` (string) – the localized title
- `region` (string) - the region for this version of the title
- `language` (string) - the language of the title
- `types` (array) - Enumerated set of attributes for this alternative title. One or more of the following: "alternative", "dvd", "festival", "tv", "video", "working", "original", "imdbDisplay". New values may be added in the future without warning
- `attributes` (array) - Additional terms to describe this alternative title, not enumerated
- `isOriginalTitle` (boolean) – 0: not original title; 1: original title

#### title.basics.tsv.gz

- `tconst` (string) - alphanumeric unique identifier of the title
- `titleType` (string) – the type/format of the title (e.g. movie, short, tvseries, tvepisode, video, etc)
- `primaryTitle` (string) – the more popular title / the title used by the filmmakers on promotional materials at the point of release
- `originalTitle` (string) - original title, in the original language
- `isAdult` (boolean) - 0: non-adult title; 1: adult title
- `startYear` (YYYY) – represents the release year of a title. In the case of TV Series, it is the series start year
- `endYear` (YYYY) – TV Series end year. '\N' for all other title types
- `runtimeMinutes` – primary runtime of the title, in minutes
- `genres` (string array) – includes up to three genres associated with the title

#### title.crew.tsv.gz

- `tconst` (string) - alphanumeric unique identifier of the title
- `directors` (array of nconsts) - director(s) of the given title
- `writers` (array of nconsts) – writer(s) of the given title

#### title.episode.tsv.gz

- `tconst` (string) - alphanumeric identifier of episode
- `parentTconst` (string) - alphanumeric identifier of the parent TV Series
- `seasonNumber` (integer) – season number the episode belongs to
- `episodeNumber` (integer) – episode number of the tconst in the TV series

#### title.principals.tsv.gz

- `tconst` (string) - alphanumeric unique identifier of the title
- `ordering` (integer) – a number to uniquely identify rows for a given titleId
- `nconst` (string) - alphanumeric unique identifier of the name/person
- `category` (string) - the category of job that person was in
- `job` (string) - the specific job title if applicable, else '\N'
- `characters` (string) - the name of the character played if applicable, else '\N'

#### title.ratings.tsv.gz

- `tconst` (string) - alphanumeric unique identifier of the title
- `averageRating` – weighted average of all the individual user ratings
- `numVotes` - number of votes the title has received

#### name.basics.tsv.gz

- `nconst` (string) - alphanumeric unique identifier of the name/person
- `primaryName` (string)– name by which the person is most often credited
- `birthYear` – in YYYY format
- `deathYear` – in YYYY format if applicable, else '\N'
- `primaryProfession` (array of strings)– the top-3 professions of the person
- `knownForTitles` (array of tconsts) – titles the person is known for


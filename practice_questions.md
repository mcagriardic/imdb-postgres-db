1. Find all the TV series that started in the year 2020.

```sql
SELECT 
	primary_title 
FROM title_basics
WHERE title_type = 'tvSeries' 
	AND start_year = 2020
```

2. Retrieve the top 10 highest-rated TV episodes, displaying the series name, episode name, and average rating for each.

```sql
SELECT 
	tb_series.primary_title AS series_name,
	tb_episode.primary_title AS episode_name,
	tr.average_rating 
FROM title_basics AS tb_episode
LEFT JOIN title_episode AS te
	ON tb_episode.tconst = te.tconst
LEFT JOIN title_ratings AS tr
	ON tr.tconst = tb_episode.tconst
LEFT JOIN title_basics AS tb_series
	ON tb_series.tconst = te.parent_tconst
WHERE tb_episode.title_type = 'tvEpisode' 
	AND average_rating IS NOT NULL
ORDER BY average_rating DESC
LIMIT 10
```

3. Find the top 5 actors/actresses who have appeared in the most number of movies (not including TV shows or other media types)? Include their name and the count of movies they've been in.

```sql
SELECT 
	nb.primary_name AS actor_actress_name,
	COUNT(DISTINCT tb.tconst) AS movie_count -- IF an actor appears ON multiple roles
FROM title_basics AS tb
LEFT JOIN title_principals AS tp
	ON tb.tconst = tp.tconst
LEFT JOIN name_basics AS nb
	ON tp.nconst = nb.nconst
WHERE tb.title_type='movie' 
	AND nb.primary_name IS NOT NULL
GROUP BY actor_actress_name
ORDER BY movie_count DESC
LIMIT 5
```


4. Find the top 5 genres with the highest average rating for movies made in the last 10 years with at least 1000 votes.

```sql
WITH genres_flattened AS (
	SELECT
		tb.tconst,
		tb.start_year,
		tr.average_rating AS rating,
		UNNEST(tb.genres) AS genre
	FROM title_basics tb 
	INNER JOIN title_ratings tr
		ON tb.tconst = tr.tconst
	WHERE start_year IN (SELECT GENERATE_SERIES(2014, 2024))
		AND tr.num_votes > 1000
		AND tb.title_type = 'movie'
)
SELECT 
	gf.genre,
	COUNT(*) AS movie_count,
	AVG(gf.rating) AS rating
FROM genres_flattened gf
GROUP BY genre
ORDER BY rating DESC
LIMIT 5
```

5. Find the top 3 directors who have directed the highest-rated movies (average rating > 8.0) in the last 5 years (assuming the current year is 2024). Include the director's name, the number of such highly-rated movies they've directed, and their highest-rated movie title along with the highest rated movie's title.

```sql
WITH director_movies AS (
  SELECT 
    UNNEST(tc.directors) AS director_nconst,
    tb.tconst AS title_id,
    tb.primary_title AS movie_name,
    tr.average_rating AS rating,
    tb.start_year AS start_year
  FROM title_crew AS tc
  JOIN title_basics AS tb ON tc.tconst = tb.tconst
  JOIN title_ratings AS tr ON tb.tconst = tr.tconst
  WHERE tb.title_type = 'movie'
    AND tb.start_year IN (2020, 2021, 2022, 2023, 2024)
    AND tr.average_rating > 8.0
),
ranked_movies AS (
	SELECT
		dm. *,
		nb.primary_name AS director_name,
		ROW_NUMBER() OVER (PARTITION BY nb.primary_name ORDER BY dm.rating DESC) AS rank
	FROM director_movies AS dm
	JOIN name_basics AS nb
		ON dm.director_nconst = nb.nconst 
)
SELECT 
	director_name,
	(CASE WHEN rank = 1 THEN movie_name END) AS highest_rated_movie,
	(CASE WHEN rank = 1 THEN rating END) AS highest_rated_movie,
	COUNT(director_name) AS movies_directed
FROM ranked_movies
GROUP BY director_name
ORDER BY movies_directed DESC
LIMIT 3
```

6. Create a report that shows the distribution of movie ratings for each genre. For each genre, show:

   * The genre name
   * The total number of movies
   * The average rating (rounded to 2 decimal places)
   * A categorization of the average rating:
     * 'Poor' if < 5.0
     * 'Average' if between 5.0 and 7.0
     * 'Good' if > 7.0
   * A list of the top 3 movie titles in that genre (based on rating)
   
   Only include movies with at least 1000 votes, and genres that have at least 10 movies. Order the results by the number of movies in each genre in descending order.


```sql
WITH genres_flattened AS (
    SELECT
        tb.tconst,
        tb.primary_title AS movie_title,
        tr.average_rating AS rating,
        UNNEST(tb.genres) AS genre
    FROM title_basics tb
    LEFT JOIN title_ratings tr ON tb.tconst = tr.tconst
    WHERE tb.title_type = 'movie' AND tr.num_votes > 1000
),
genres_grouped_and_filtered AS (
    SELECT
        gf.genre,
        AVG(gf.rating) AS average_rating
    FROM genres_flattened gf
    GROUP BY gf.genre
    HAVING COUNT(DISTINCT gf.tconst) > 10
),
genre_quality_categorized AS (
    SELECT
        gf.*,
        ggf.average_rating,
        CASE
            WHEN ggf.average_rating < 5.0 THEN 'Poor'
            WHEN ggf.average_rating >= 5.0 AND ggf.average_rating < 7.0 THEN 'Average'
            ELSE 'Good'
        END AS genre_quality
    FROM genres_flattened gf
    INNER JOIN genres_grouped_and_filtered ggf ON gf.genre = ggf.genre
)
SELECT
    gqc.genre,
    COUNT(*) AS total_number_of_movies,
    ROUND(MAX(gqc.average_rating), 2) AS average_rating,
    MAX(genre_quality) AS genre_quality,
    (ARRAY_AGG(gqc.movie_title ORDER BY gqc.rating DESC))[1:3] AS top_movies
FROM genre_quality_categorized gqc
GROUP BY gqc.genre
ORDER BY total_number_of_movies DESC;
```

Same as above using a seperate column; `movie_rank` instead of array indexing:

```sql
WITH genres_flattened AS (
    SELECT
        tb.tconst,
        tb.primary_title AS movie_title,
        tr.average_rating AS rating,
        UNNEST(tb.genres) AS genre
    FROM title_basics tb
    LEFT JOIN title_ratings tr ON tb.tconst = tr.tconst
    WHERE tb.title_type = 'movie' AND tr.num_votes > 1000
),
genres_grouped_and_filtered AS (
    SELECT
        gf.genre,
        AVG(gf.rating) AS average_rating,
        COUNT(DISTINCT gf.tconst) AS movie_count
    FROM genres_flattened gf
    GROUP BY gf.genre
    HAVING COUNT(DISTINCT gf.tconst) > 10
),
genre_quality_categorized AS (
    SELECT
        gf.*,
        ggf.average_rating,
        ggf.movie_count,
        CASE
            WHEN ggf.average_rating < 5.0 THEN 'Poor'
            WHEN ggf.average_rating >= 5.0 AND ggf.average_rating < 7.0 THEN 'Average'
            WHEN ggf.average_rating > 7.0 THEN 'Good'
        END AS genre_quality,
        ROW_NUMBER() OVER (PARTITION BY gf.genre ORDER BY gf.rating DESC) AS movie_rank
    FROM genres_flattened gf
    INNER JOIN genres_grouped_and_filtered ggf ON gf.genre = ggf.genre
)
SELECT
    genre,
    MAX(movie_count) AS total_number_of_movies,
    ROUND(MAX(average_rating), 2) AS average_rating,
    MAX(genre_quality) AS genre_quality,
    STRING_AGG(
        CASE WHEN movie_rank <= 3 THEN movie_title END,
        ', ' ORDER BY movie_rank
    ) AS top_movies
FROM genre_quality_categorized
GROUP BY genre
ORDER BY total_number_of_movies DESC
```

7. Identify actors/actresses who have shown the most versatility in their careers. Define versatility as appearing in the highest number of distinct genres. Write a query to find the top 5 most versatile actors/actresses. For each person, show their name, the number of distinct genres they've worked in, and the genre in which they've appeared most frequently. Only consider movies (not TV shows or other media types) released in the last 20 years (assume the current year is 2024) that have at least 1000 votes.

```sql
WITH genres_flattaned_filtered AS (
    SELECT
        tb.tconst,
        UNNEST(tb.genres) AS genre
    FROM title_basics tb
    JOIN title_ratings tr ON tb.tconst = tr.tconst
    WHERE tb.title_type = 'movie'
    AND tr.num_votes > 1000
    AND tb.start_year IN (SELECT generate_series(2004, 2024))
), actor_and_actress_names AS (
    SELECT
        tp.tconst,
        nb.primary_name AS actor_actress_name
    FROM title_principals tp
    JOIN name_basics nb ON tp.nconst = nb.nconst
    WHERE tp.category IN ('actor', 'actress')
), genre_counts AS (
    SELECT
        aan.actor_actress_name,
        gff.genre,
        COUNT(*) AS genre_count
    FROM genres_flattaned_filtered gff
    JOIN actor_and_actress_names aan ON gff.tconst = aan.tconst
    GROUP BY aan.actor_actress_name, gff.genre
), actor_genre_stats AS (
    SELECT
        actor_actress_name,
        COUNT(DISTINCT genre) AS distinct_genres,
        ARRAY_AGG(genre ORDER BY genre_count DESC) AS genres,
        ARRAY_AGG(genre_count ORDER BY genre_count DESC) AS genre_counts
    FROM genre_counts
    GROUP BY actor_actress_name
)
SELECT
    actor_actress_name,
    distinct_genres,
    genres[1] AS most_frequent_genre,
    genre_counts[1] AS most_frequent_genre_count
FROM actor_genre_stats
ORDER BY distinct_genres DESC, most_frequent_genre_count DESC
LIMIT 5;
```

8. Identify "breakout years" for directors. A "breakout year" is defined as the year when a director's movie first achieved an average rating of at least 8.0 with at least 10,000 votes. Write a query to find the top 10 directors who had the most successful movies (rating >= 8.0, votes >= 10,000) in the same year as their breakout year. For each director, show their name, breakout year, number of successful movies in that year, and the titles of those movies.

```sql
WITH directors_and_movies AS (
	SELECT
		nb.primary_name AS director_name,
		tb.primary_title AS movie_name,
		tb.start_year AS movie_release_year
	FROM title_basics tb
	JOIN title_ratings tr
		ON tb.tconst = tr.tconst
	JOIN title_principals tp
		ON tb.tconst = tp.tconst
	JOIN name_basics nb
		ON tp.nconst = nb.nconst 
	WHERE tr.average_rating >= 8.0
		AND tr.num_votes >= 10000
		AND tb.title_type = 'movie'
		AND tp.category = 'director'
), director_breakout_year AS (
	SELECT
		director_name,
		MIN(movie_release_year) AS breakout_year
	FROM directors_and_movies
	GROUP BY director_name
), director_most_succesfull_movies AS (
	SELECT 
		dam.director_name,
		breakout_year,
		ARRAY_AGG(dam.movie_name) AS movie_names,
		COUNT(*) AS movies_released
	FROM directors_and_movies dam
	JOIN director_breakout_year dby
		ON dam.director_name = dby.director_name
	WHERE movie_release_year = breakout_year
	GROUP BY dam.director_name, breakout_year
)  SELECT 
		director_name,
		movie_names,
		breakout_year,
		movies_released
	FROM director_most_succesfull_movies
	ORDER BY movies_released DESC, breakout_year DESC
	LIMIT 10
```

9. Find the actors/actresses who have consistently improved their movie ratings over their career. Specifically, retrieve the top 5 actors/actresses who have at least 5 movies, where each subsequent movie has a higher rating than the previous one. Display the actor/actress name, the number of consecutively improving movies, and the ratings of their first and last movie in this sequence.

```sql
WITH RECURSIVE actor_actress_ratings AS (
	SELECT
		nb.nconst AS actor_actress_id,
		ARRAY_AGG(tr.average_rating ORDER BY tb.start_year) AS ratings,
		ARRAY_AGG(tb.primary_title ORDER BY tb.start_year) AS movies
	FROM title_principals tp
	JOIN name_basics nb
		ON tp.nconst = nb.nconst
	JOIN title_ratings tr
		ON tp.tconst  = tr.tconst
	JOIN title_basics tb
		ON tp.tconst = tb.tconst 
	WHERE tp.category IN ('actor', 'actress')
		AND tb.title_type = 'movie'
	GROUP BY nb.nconst	
), increasing_sequence AS (
	SELECT
		actor_actress_id,
		ratings[1] AS current_rating,
		1 AS pos,
		1 AS sequence_length,
		1 AS current_max_sequence_length,
		'N/A' AS first_movie_of_seq,
		'N/A' AS first_movie_of_seq_to_reg,
		'N/A' AS last_movie_of_seq,
		ratings,
		movies
	FROM actor_actress_ratings
	
	UNION ALL
	
	SELECT
		ise.actor_actress_id,
		ise.ratings[pos + 1],
		ise.pos + 1,
		CASE 
			WHEN ise.ratings[ise.pos + 1] > ise.current_rating
			THEN ise.sequence_length + 1
			ELSE 1
		END AS sequence_length,
	    GREATEST(
	      ise.current_max_sequence_length,
	      CASE
	        WHEN ise.ratings[ise.pos + 1] > ise.current_rating THEN ise.sequence_length + 1
	        ELSE 1
	      END
	    ) AS current_max_sequence_length,
		CASE
		  WHEN ise.current_rating >= ise.ratings[ise.pos + 1]
		  THEN movies[ise.pos + 1]
		  ELSE movies[ise.pos]
		END AS first_movie_of_seq,
		CASE
		  WHEN ise.ratings[ise.pos + 1] > ise.current_max_sequence_length
		  THEN ise.first_movie_of_seq
		  ELSE 'N/A'
		END AS first_movie_of_seq_to_reg,
		CASE
		  WHEN ise.ratings[ise.pos + 1] > ise.current_max_sequence_length
		  THEN ise.movies[ise.pos + 1]
		  ELSE ise.movies[ise.pos]
		END AS last_movie_of_seq,
		ise.ratings,
		ise.movies
	FROM increasing_sequence ise
	WHERE ise.pos <= array_length(ise.ratings, 1)
) SELECT DISTINCT ON (actor_actress_id)
  actor_actress_id,
  first_movie_of_seq_to_reg AS first_movie_of_seq,
  last_movie_of_seq,
  current_max_sequence_length AS max_sequence_length,
  UNNEST(ratings),
  UNNEST(movies)
FROM increasing_sequence
WHERE current_max_sequence_length >= 5
ORDER BY actor_actress_id, max_sequence_length DESC
```


SQL processes queries in the order: FROM, JOIN, WHERE, GROUP BY, HAVING, SELECT, DISTINCT, ORDER BY, and finally, LIMIT/OFFSET

In PostgreSQL (and some other SQL databases), there's actually an exception to the standard SQL processing order for GROUP BY. The database allows you to use column aliases defined in the SELECT clause within the GROUP BY clause. This is a PostgreSQL-specific extension to the SQL standard.
So in this query:

```sql
SELECT
    tp.nconst,
    UNNEST(tb.genres) AS genre,
    COUNT(*) AS genre_count
FROM title_basics tb
JOIN title_principals tp ON tb.tconst = tp.tconst
WHERE tb.title_type = 'movie'
AND tp.category IN ('actor', 'actress')
GROUP BY tp.nconst, genre
```

PostgreSQL processes the UNNEST(tb.genres) AS genre part before the GROUP BY, making the 'genre' alias available for use in the GROUP BY clause.
This behavior is not standard SQL, and it won't work in all databases. In standard SQL and many other database systems, you would need to repeat the entire expression in the GROUP BY clause:

```sql
GROUP BY tp.nconst, UNNEST(tb.genres)
```

The reason it doesn't work in the WHERE clause is that this PostgreSQL extension doesn't apply to WHERE. The WHERE clause is still processed before the SELECT clause, so the 'genre' alias isn't available there.
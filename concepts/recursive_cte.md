# Recursive Common Table Expressions (CTEs) in SQL

## Structure
A recursive CTE has two main parts:
- An initial query (anchor member)
- A recursive query (recursive member)
These are typically connected with a UNION ALL.

## Syntax

```sql
WITH RECURSIVE cte_name AS (
  -- Initial query (non-recursive term)
  SELECT ...
  UNION ALL
  -- Recursive query (recursive term)
  SELECT ...
  FROM cte_name
  WHERE <termination_condition>
)
SELECT * FROM cte_name;
```

## Execution Process

1. The `initial query` runs once to create the base result set.
2. The `recursive query` then runs repeatedly:

   * It uses the results from the previous iteration.
Each iteration's results are added to the overall result set.
This continues until the recursive part returns no rows (i.e., the `termination condition` is met).

## Implicit Recursion

* Unlike traditional function-based recursion, SQL recursion is implicit.
* The recursion occurs when the CTE references itself in its definition (`cte_name` from the Syntax block).

## State Management

* Each iteration can access and modify values from the previous iteration.
* This allows for traversal of data structures or generation of sequences.

## Termination

* A `termination condition` in the `WHERE` clause of the recursive part is crucial.
* It prevents infinite recursion.

## Performance Considerations

* Recursive CTEs can be powerful but may be less efficient for very large datasets.
* Some databases have limits on recursion depth.

## Example (a very simple one)
Below example creates sequence of numbers from 1 to 5 using recursive CTE:

```sql
WITH RECURSIVE number_sequence AS (
  -- Initial query: start with 1
  SELECT 1 AS n
  UNION ALL
  -- Recursive query: add 1 to previous number
  SELECT n + 1
  FROM number_sequence
  WHERE n < 5
)
SELECT * FROM number_sequence;
```

This CTE works as follows:

1. It starts with 1 (initial query).
2. In each recursive step, it adds 1 to the previous number.
3. The recursion continues as long as n is less than 5.
4. The result will be: 1, 2, 3, 4, 5.

## MAXRECURSION

* MAXRECURSION is an option used to limit the number of recursion levels in a CTE.
* It helps prevent excessive resource consumption from deeply nested or infinite recursions.
* The syntax varies depending on the database system. In SQL Server, it's used as an option with the main query.

### Example of MAXRECURSION:

```sql
WITH RECURSIVE number_sequence AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1
  FROM number_sequence
  WHERE n < 10
)
SELECT * FROM number_sequence
OPTION (MAXRECURSION 2);
```

In this example:

* The CTE would normally generate numbers from 1 to 10.
* MAXRECURSION 2 limits it to only 2 levels of recursion.
* The result will be: 1, 2, 3 (initial level plus two recursive levels).

*Note:* The exact syntax and availability of MAXRECURSION may vary between different database systems. For example PostgreSQL doesn't have a query-level option like SQL Server's `MAXRECURSION`. Instead, it uses a session or server-wide parameter:

* The `max_recursion_depth` parameter sets the maximum recursion depth.
* Default value is 100.

To set this for the current session:

```sql
SET max_recursion_depth = 2;

WITH RECURSIVE number_sequence AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1
  FROM number_sequence
  WHERE n < 10
)
SELECT * FROM number_sequence;
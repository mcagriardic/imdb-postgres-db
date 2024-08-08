# SQL Window Functions: OVER (PARTITION BY) Explained

## Introduction

Window functions, also known as analytic functions, are a powerful feature in SQL that perform calculations across a set of rows that are related to the current row. The OVER clause, often used with PARTITION BY, is a key component of window functions. This document provides a comprehensive guide to understanding and using OVER (PARTITION BY) in SQL.

## Table of Contents

1. [What are Window Functions?](#what-are-window-functions)
2. [The OVER Clause](#the-over-clause)
3. [PARTITION BY](#partition-by)
4. [Common Window Functions](#common-window-functions)
5. [Advanced Examples](#advanced-examples)
6. [Performance Considerations](#performance-considerations)
7. [Database Compatibility](#database-compatibility)

## What are Window Functions?

Window functions perform calculations across a set of table rows that are somehow related to the current row. They are similar to aggregate functions, but unlike aggregate functions, they don't cause rows to become grouped into a single output row.

## The OVER Clause

The OVER clause defines the window of rows on which the window function operates. It can contain three main components:

1. PARTITION BY: Divides the result set into partitions.
2. ORDER BY: Determines the order of rows within each partition.
3. Frame clause: Specifies the set of rows constituting the window frame.

## PARTITION BY

PARTITION BY divides the result set into partitions (groups) to which the window function is applied. 

Let's use a sample `employees` table for our examples:

<table>
<tr><th>employees Table</th></tr>
<tr><td>

| id | name   | department | salary |
|----|--------|------------|--------|
| 1  | Alice  | HR         | 50000  |
| 2  | Bob    | IT         | 60000  |
| 3  | Carol  | HR         | 55000  |
| 4  | David  | IT         | 65000  |
| 5  | Eva    | Finance    | 62000  |
| 6  | Frank  | IT         | 58000  |

</td></tr>
</table>

### Example 1: Average Salary by Department

```sql
SELECT 
    name,
    department,
    salary,
    AVG(salary) OVER (PARTITION BY department) as avg_dept_salary
FROM 
    employees;
```

Result:

| name   | department | salary | avg_dept_salary |
|--------|------------|--------|-----------------|
| Alice  | HR         | 50000  | 52500           |
| Carol  | HR         | 55000  | 52500           |
| Bob    | IT         | 60000  | 61000           |
| David  | IT         | 65000  | 61000           |
| Frank  | IT         | 58000  | 61000           |
| Eva    | Finance    | 62000  | 62000           |

## Common Window Functions

### 1. ROW_NUMBER()

Assigns a unique number to each row within a partition.

```sql
SELECT 
    name,
    department,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as salary_rank
FROM 
    employees;
```

Result:

| name   | department | salary | salary_rank |
|--------|------------|--------|-------------|
| Carol  | HR         | 55000  | 1           |
| Alice  | HR         | 50000  | 2           |
| David  | IT         | 65000  | 1           |
| Bob    | IT         | 60000  | 2           |
| Frank  | IT         | 58000  | 3           |
| Eva    | Finance    | 62000  | 1           |

### 2. RANK() and DENSE_RANK()

Similar to ROW_NUMBER(), but handles ties differently.

```sql
SELECT 
    name,
    department,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as salary_rank,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dense_salary_rank
FROM 
    employees;
```

### 3. LAG() and LEAD()

Access data from a previous or subsequent row in the partition.

```sql
SELECT 
    name,
    department,
    salary,
    LAG(salary) OVER (PARTITION BY department ORDER BY salary) as prev_salary,
    LEAD(salary) OVER (PARTITION BY department ORDER BY salary) as next_salary
FROM 
    employees;
```

## Advanced Examples

### Example 1: Running Total

Calculate a running total of salaries within each department:

```sql
SELECT 
    name,
    department,
    salary,
    SUM(salary) OVER (PARTITION BY department ORDER BY salary) as running_total
FROM 
    employees;
```

### Example 2: Percentage of Department Total

Calculate each employee's salary as a percentage of their department's total:

```sql
SELECT 
    name,
    department,
    salary,
    salary * 100.0 / SUM(salary) OVER (PARTITION BY department) as pct_of_dept_total
FROM 
    employees;
```

### Example 3: Moving Average

Calculate a 3-row moving average of salaries:

```sql
SELECT 
    name,
    department,
    salary,
    AVG(salary) OVER (
        PARTITION BY department 
        ORDER BY salary 
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) as moving_avg
FROM 
    employees;
```

## Performance Considerations

1. Window functions can be resource-intensive, especially on large datasets.
2. Proper indexing on columns used in PARTITION BY and ORDER BY can improve performance.
3. Try to combine multiple window functions in a single pass when possible.

## Database Compatibility

Window functions are part of the SQL:2003 standard and are supported by most modern database systems, including:

- PostgreSQL
- Oracle
- SQL Server
- MySQL (8.0+)
- SQLite (3.25.0+)

However, the exact syntax and available functions may vary between systems. Always consult your specific database's documentation for the most accurate information.

## GROUP BY vs. Window Functions

Understanding when to use GROUP BY versus window functions is crucial for efficient and effective SQL querying. While both can be used for aggregating data, they serve different purposes and are suitable for different scenarios.

### Comparison Example

Let's use our `employees` table to illustrate the difference:

<table>
<tr><th>employees Table</th></tr>
<tr><td>

| id | name   | department | salary |
|----|--------|------------|--------|
| 1  | Alice  | HR         | 50000  |
| 2  | Bob    | IT         | 60000  |
| 3  | Carol  | HR         | 55000  |
| 4  | David  | IT         | 65000  |
| 5  | Eva    | Finance    | 62000  |
| 6  | Frank  | IT         | 58000  |

</td></tr>
</table>

#### Using Window Function:

```sql
SELECT 
    name,
    department,
    salary,
    AVG(salary) OVER (PARTITION BY department) as avg_dept_salary
FROM 
    employees;
```

Result:

| name   | department | salary | avg_dept_salary |
|--------|------------|--------|-----------------|
| Alice  | HR         | 50000  | 52500           |
| Carol  | HR         | 55000  | 52500           |
| Bob    | IT         | 60000  | 61000           |
| David  | IT         | 65000  | 61000           |
| Frank  | IT         | 58000  | 61000           |
| Eva    | Finance    | 62000  | 62000           |

#### Using GROUP BY with JOIN:

To achieve the same result using GROUP BY, we need to:
1. Calculate the average salary per department using GROUP BY.
2. JOIN this result back to the original table.

Here's how we can do it:

```sql
WITH dept_avg AS (
    SELECT 
        department,
        AVG(salary) as avg_dept_salary
    FROM 
        employees
    GROUP BY 
        department
)
SELECT 
    e.name,
    e.department,
    e.salary,
    da.avg_dept_salary
FROM 
    employees e
JOIN 
    dept_avg da ON e.department = da.department;
```

This query will produce the same result as the window function example.

### Key Differences

1. **Syntax and Complexity**: 
   - Window functions allow for more concise syntax.
   - GROUP BY with JOIN requires a subquery (or CTE) and an additional JOIN, making it more complex.

2. **Result Set**: 
   - Window functions retain all original rows.
   - GROUP BY reduces the rows, requiring a JOIN to bring back the original detail.

3. **Performance**: 
   - Window functions can often be more efficient, especially for simple calculations, as they're done in a single pass over the data.
   - GROUP BY with JOIN requires creating an intermediate result and then joining, which can be less efficient.

4. **Flexibility**: 
   - Window functions allow easy addition of multiple calculations (e.g., row numbers, ranks) in the same query.
   - GROUP BY approach might need additional subqueries and joins for each new calculation.

5. **Readability**: 
   - Window functions are often more readable, especially for those familiar with the syntax.
   - GROUP BY with JOIN follows a more traditional SQL structure, which some might find easier to understand.

### When to Use GROUP BY

1. **Data Reduction**: When you need to reduce the number of rows in your result set.
2. **Simple Aggregations**: For straightforward summary statistics (e.g., total sales per category).
3. **HAVING Clause**: When you need to filter groups based on aggregate conditions.
4. **Compatibility**: When working with systems that don't support window functions.

### When to Use Window Functions

1. **Retain Detail**: When you want to keep all original rows while adding calculated fields.
2. **Row-by-Row Analysis**: For calculations that depend on other rows within a defined window.
3. **Running Totals or Moving Averages**: For cumulative or sliding window calculations.
4. **Ranking or Row Numbering**: When assigning ranks or row numbers within groups.
5. **Complex Analysis**: When you need multiple types of calculations or analysis within groups.

### Choosing Between GROUP BY and Window Functions

- Use window functions when you need to maintain row-level detail while performing group-level calculations.
- Opt for GROUP BY when you need to significantly reduce the dataset or when working with database systems that don't support window functions.
- Consider the complexity of your analysis: window functions often provide more elegant solutions for complex calculations, while GROUP BY might be simpler for basic aggregations.
- In some cases, you might use both in the same query: GROUP BY for overall aggregations and window functions for within-group calculations.

# SQL Conditional Filtering: A Comprehensive Guide

## Introduction

Conditional filtering in SQL allows you to apply conditions to aggregate functions, enabling more precise and efficient data analysis. This document covers the FILTER clause and alternative methods for conditional aggregation, with examples and use cases.

## Table of Contents

1. [The FILTER Clause](#the-filter-clause)
2. [Examples with Common Aggregate Functions](#examples-with-common-aggregate-functions)
3. [Comparing FILTER to CASE Statements](#comparing-filter-to-case-statements)
4. [Multiple Conditions in FILTER](#multiple-conditions-in-filter)
5. [Use Cases](#use-cases)
6. [Database Compatibility](#database-compatibility)
7. [Advanced FILTER Usage with GROUP BY](#advanced-filter-usage-with-group-by)

## The FILTER Clause

The FILTER clause is used with aggregate functions to specify which rows should be included in the aggregation. The general syntax is:

```sql
aggregate_function(expression) FILTER (WHERE condition)
```

## Examples with Common Aggregate Functions

Let's use a sample `sales` table for our examples:

<table>
<tr><th>sales Table</th></tr>
<tr><td>

| id | product | category | amount | date       |
|----|---------|----------|--------|------------|
| 1  | Widget  | A        | 100    | 2023-01-15 |
| 2  | Gadget  | B        | 200    | 2023-01-20 |
| 3  | Widget  | A        | 150    | 2023-02-10 |
| 4  | Doodad  | C        | 300    | 2023-02-15 |
| 5  | Gadget  | B        | 250    | 2023-03-05 |

</td></tr>
</table>

### 1. COUNT with FILTER

Count total sales and high-value sales (over 200):

```sql
SELECT
    COUNT(*) AS total_sales,
    COUNT(*) FILTER (WHERE amount > 200) AS high_value_sales
FROM sales;
```

Result:

| total_sales | high_value_sales |
|-------------|-------------------|
| 5           | 2                 |

### 2. SUM with FILTER

Calculate total revenue and revenue from category A:

```sql
SELECT
    SUM(amount) AS total_revenue,
    SUM(amount) FILTER (WHERE category = 'A') AS category_a_revenue
FROM sales;
```

Result:

| total_revenue | category_a_revenue |
|---------------|---------------------|
| 1000          | 250                 |

### 3. AVG with FILTER

Compare overall average sale amount to average of high-value sales:

```sql
SELECT
    AVG(amount) AS overall_avg,
    AVG(amount) FILTER (WHERE amount > 200) AS high_value_avg
FROM sales;
```

Result:

| overall_avg | high_value_avg |
|-------------|----------------|
| 200         | 275            |

## Comparing FILTER to CASE Statements

The FILTER clause can often replace CASE statements in aggregate functions, leading to more readable and potentially more efficient queries.

### Using FILTER:

```sql
SELECT
    COUNT(*) FILTER (WHERE category = 'A') AS category_a_count,
    COUNT(*) FILTER (WHERE category = 'B') AS category_b_count,
    COUNT(*) FILTER (WHERE category = 'C') AS category_c_count
FROM sales;
```

### Equivalent using CASE:

```sql
SELECT
    COUNT(CASE WHEN category = 'A' THEN 1 END) AS category_a_count,
    COUNT(CASE WHEN category = 'B' THEN 1 END) AS category_b_count,
    COUNT(CASE WHEN category = 'C' THEN 1 END) AS category_c_count
FROM sales;
```

Both queries would produce the same result:

| category_a_count | category_b_count | category_c_count |
|------------------|------------------|------------------|
| 2                | 2                | 1                |

## Multiple Conditions in FILTER

You can use complex conditions in the FILTER clause:

```sql
SELECT
    AVG(amount) AS overall_avg,
    AVG(amount) FILTER (WHERE category = 'A' AND amount > 100) AS filtered_avg
FROM sales;
```

Result:

| overall_avg | filtered_avg |
|-------------|--------------|
| 200         | 150          |

## Use Cases

1. **Time-based comparisons**: Compare metrics across different time periods.

```sql
SELECT
    AVG(amount) FILTER (WHERE date < '2023-02-01') AS jan_avg,
    AVG(amount) FILTER (WHERE date >= '2023-02-01' AND date < '2023-03-01') AS feb_avg,
    AVG(amount) FILTER (WHERE date >= '2023-03-01') AS mar_avg
FROM sales;
```

2. **Cohort analysis**: Analyze different groups within your data.

```sql
SELECT
    category,
    COUNT(*) AS total_sales,
    AVG(amount) AS avg_sale,
    AVG(amount) FILTER (WHERE amount > (SELECT AVG(amount) FROM sales)) AS high_value_avg
FROM sales
GROUP BY category;
```

3. **Conditional ratios**: Calculate proportions based on conditions.

```sql
SELECT
    COUNT(*) FILTER (WHERE amount > 200) * 100.0 / COUNT(*) AS high_value_percentage
FROM sales;
```

## Database Compatibility

The FILTER clause is part of the SQL:2003 standard but is not supported by all database systems. It's well-supported in:

- PostgreSQL
- Oracle (12c and later)
- SQL Server (2022 and later)

For databases that don't support FILTER, you can use the CASE statement method shown earlier.

In MySQL, you can achieve similar results using IF or CASE within the aggregate function:

```sql
SELECT
    COUNT(*) AS total_sales,
    COUNT(IF(amount > 200, 1, NULL)) AS high_value_sales
FROM sales;
```

Always check your specific database system's documentation for the most up-to-date information on feature support and optimal usage.

## Advanced FILTER Usage with GROUP BY

The FILTER clause can be particularly powerful when used in conjunction with GROUP BY, especially when you want to count or aggregate based on conditions that involve columns not in the GROUP BY clause.

Let's extend our `sales` table with a `customer_type` column:

<table>
<tr><th>Extended sales Table</th></tr>
<tr><td>

| id | product | category | amount | date       | customer_type |
|----|---------|----------|--------|------------|---------------|
| 1  | Widget  | A        | 100    | 2023-01-15 | Regular       |
| 2  | Gadget  | B        | 200    | 2023-01-20 | Premium       |
| 3  | Widget  | A        | 150    | 2023-02-10 | Premium       |
| 4  | Doodad  | C        | 300    | 2023-02-15 | Regular       |
| 5  | Gadget  | B        | 250    | 2023-03-05 | Premium       |

</td></tr>
</table>

### Example: Count by Category with Customer Type Filter

Let's say we want to group our sales by category, but for each category, we want to know:
1. The total number of sales
2. The number of sales to Premium customers
3. The number of high-value sales (amount > 200) to Regular customers

Here's how we can do this using the FILTER clause:

```sql
SELECT
    category,
    COUNT(*) AS total_sales,
    COUNT(*) FILTER (WHERE customer_type = 'Premium') AS premium_sales,
    COUNT(*) FILTER (WHERE customer_type = 'Regular' AND amount > 200) AS high_value_regular_sales
FROM sales
GROUP BY category;
```

Result:

| category | total_sales | premium_sales | high_value_regular_sales |
|----------|-------------|---------------|--------------------------|
| A        | 2           | 1             | 0                        |
| B        | 2           | 2             | 0                        |
| C        | 1           | 0             | 1                        |

In this query:
- We're grouping by `category`, which means each row in the result represents a unique category.
- `total_sales` counts all sales for each category.
- `premium_sales` counts only the sales where `customer_type` is 'Premium' for each category.
- `high_value_regular_sales` counts sales where `customer_type` is 'Regular' AND `amount` is greater than 200 for each category.

The power of this approach is that we can count based on conditions involving `customer_type` and `amount`, even though these columns are not part of our GROUP BY clause. This allows for complex aggregations and comparisons within a single, efficient query.

### Benefits of this Approach

1. **Efficiency**: This method is generally more efficient than using subqueries or JOINs to achieve the same result.
2. **Readability**: The query intention is clear and easy to understand at a glance.
3. **Flexibility**: You can easily add or modify conditions without changing the overall structure of the query.
4. **Performance**: Database optimizers can often handle this type of query very efficiently.

### Alternative Using CASE Statements

For databases that don't support the FILTER clause, you can achieve the same result using CASE statements:

```sql
SELECT
    category,
    COUNT(*) AS total_sales,
    COUNT(CASE WHEN customer_type = 'Premium' THEN 1 END) AS premium_sales,
    COUNT(CASE WHEN customer_type = 'Regular' AND amount > 200 THEN 1 END) AS high_value_regular_sales
FROM sales
GROUP BY category;
```

This query will produce the same result as the one using FILTER, but it may be less efficient in some database systems.

By using the FILTER clause with GROUP BY, you can create powerful, efficient queries that provide detailed breakdowns of your data based on multiple conditions, even when those conditions involve columns not in your GROUP BY clause.

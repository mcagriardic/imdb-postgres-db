# SQL Joins Explained with Examples

This document explains various types of SQL joins with simple examples. The joins are ordered by their frequency of use in typical database operations.

## 1. INNER JOIN

The INNER JOIN returns only the rows that have matching values in both tables.

<table>
<tr><th>Left Table (Employees)</th><th>Right Table (Departments)</th></tr>
<tr><td>

| id | name  |
|----|-------|
| 1  | Alice |
| 2  | Bob   |
| 3  | Carol |

</td><td>

| id | department |
|----|------------|
| 2  | HR         |
| 3  | IT         |
| 4  | Finance    |

</td></tr>
</table>

Result of INNER JOIN:
```sql
SELECT 
    * 
FROM Employees e
INNER JOIN Departments d 
    ON e.id = d.id
```

| id | name  | department |
|----|-------|------------|
| 2  | Bob   | HR         |
| 3  | Carol | IT         |

## 2. LEFT JOIN (or LEFT OUTER JOIN)

The LEFT JOIN returns all rows from the left table and the matched rows from the right table. If there's no match, NULL values are returned for right table columns.

<table>
<tr><th>Left Table (Employees)</th><th>Right Table (Departments)</th></tr>
<tr><td>

| id | name  |
|----|-------|
| 1  | Alice |
| 2  | Bob   |
| 3  | Carol |

</td><td>

| id | department |
|----|------------|
| 2  | HR         |
| 3  | IT         |
| 4  | Finance    |

</td></tr>
</table>

Result of LEFT JOIN:
```sql
SELECT 
    * 
FROM Employees e
LEFT JOIN Departments d 
    ON e.id = d.id
```

| id | name  | department |
|----|-------|------------|
| 1  | Alice | NULL       |
| 2  | Bob   | HR         |
| 3  | Carol | IT         |

## 3. RIGHT JOIN (or RIGHT OUTER JOIN)

The RIGHT JOIN returns all rows from the right table and the matched rows from the left table. If there's no match, NULL values are returned for left table columns.

<table>
<tr><th>Left Table (Employees)</th><th>Right Table (Departments)</th></tr>
<tr><td>

| id | name  |
|----|-------|
| 1  | Alice |
| 2  | Bob   |
| 3  | Carol |

</td><td>

| id | department |
|----|------------|
| 2  | HR         |
| 3  | IT         |
| 4  | Finance    |

</td></tr>
</table>

Result of RIGHT JOIN:
```sql
SELECT 
    * 
FROM Employees e
RIGHT JOIN Departments d 
    ON e.id = d.id
```

| id   | name  | department |
|------|-------|------------|
| 2    | Bob   | HR         |
| 3    | Carol | IT         |
| 4    | NULL  | Finance    |

## 4. FULL JOIN (or FULL OUTER JOIN)

The FULL JOIN returns all rows when there's a match in either the left or right table. If there's no match, NULL values are returned for the columns from the table without a match.

<table>
<tr><th>Left Table (Employees)</th><th>Right Table (Departments)</th></tr>
<tr><td>

| id | name  |
|----|-------|
| 1  | Alice |
| 2  | Bob   |
| 3  | Carol |

</td><td>

| id | department |
|----|------------|
| 2  | HR         |
| 3  | IT         |
| 4  | Finance    |

</td></tr>
</table>

Result of FULL JOIN:
```sql
SELECT 
    * 
FROM Employees e
FULL JOIN Departments d 
    ON e.id = d.id
```

| id   | name  | department |
|------|-------|------------|
| 1    | Alice | NULL       |
| 2    | Bob   | HR         |
| 3    | Carol | IT         |
| 4    | NULL  | Finance    |

## 5. CROSS JOIN

The CROSS JOIN returns the Cartesian product of both tables, i.e., each row from the first table is combined with each row from the second table.

<table>
<tr><th>Left Table (Colors)</th><th>Right Table (Sizes)</th></tr>
<tr><td>

| id | color |
|----|-------|
| 1  | Red   |
| 2  | Blue  |

</td><td>

| id | size  |
|----|-------|
| A  | Small |
| B  | Large |

</td></tr>
</table>

Result of CROSS JOIN:
```sql
SELECT 
    * 
FROM Colors c
CROSS JOIN Sizes s
```

| id | color | id | size  |
|----|-------|----|----- |
| 1  | Red   | A  | Small |
| 1  | Red   | B  | Large |
| 2  | Blue  | A  | Small |
| 2  | Blue  | B  | Large |

## 6. SELF JOIN

A SELF JOIN is used to join a table with itself. It's useful when a table has a foreign key referencing its own primary key.

Table (Employees):

| id | name  | manager_id |
|----|-------|------------|
| 1  | Alice | NULL       |
| 2  | Bob   | 1          |
| 3  | Carol | 1          |
| 4  | David | 2          |

Result of SELF JOIN:
```sql
SELECT 
    e.name AS employee,
    m.name AS manager
FROM Employees e
LEFT JOIN Employees m 
    ON e.manager_id = m.id
```

| employee | manager |
|----------|---------|
| Alice    | NULL    |
| Bob      | Alice   |
| Carol    | Alice   |
| David    | Bob     |

These examples cover the main types of SQL joins, including INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN, CROSS JOIN, and SELF JOIN. The order presented roughly corresponds to the frequency of use in typical database operations.
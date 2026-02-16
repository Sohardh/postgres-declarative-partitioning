-- ==========================================
-- LIST PARTITIONING EXAMPLES
-- ==========================================

-- ==========================================
-- 1. Basic Queries and Partition Pruning
-- ==========================================

-- Example 1: Query for a specific country (INDIA)
-- This will only scan the customers_list_india partition
EXPLAIN ANALYZE
SELECT * FROM customers_list WHERE country = 'INDIA';

-- Example 2: Query for a specific country (USA)
-- This will only scan the customers_list_usa partition
EXPLAIN ANALYZE
SELECT * FROM customers_list WHERE country = 'USA';

-- Example 3: Query for a country in the default partition
-- This will only scan the customers_list_default partition
EXPLAIN ANALYZE
SELECT * FROM customers_list WHERE country = 'CANADA';

-- Example 4: Query with IN clause (multiple countries)
-- This will scan the specified partitions (india and usa)
EXPLAIN ANALYZE
SELECT * FROM customers_list 
WHERE country IN ('INDIA', 'USA');

-- Example 5: Query with no partition pruning (scans all partitions)
EXPLAIN ANALYZE
SELECT * FROM customers_list;

-- ==========================================
-- 2. Aggregation and Grouping
-- ==========================================

-- Example 6: Count customers by country
-- This will scan all partitions but demonstrates aggregation across partitions
EXPLAIN ANALYZE
SELECT country, COUNT(*) AS customer_count
FROM customers_list
GROUP BY country
ORDER BY customer_count DESC;

-- Example 7: Find countries with more than 100,000 customers
-- This demonstrates filtering after aggregation
EXPLAIN ANALYZE
SELECT country, COUNT(*) AS customer_count
FROM customers_list
GROUP BY country
HAVING COUNT(*) > 100000
ORDER BY customer_count DESC;

-- ==========================================
-- 3. Joins with Partitioned Tables
-- ==========================================

-- Example 8: Join with the orders_range table
-- This demonstrates joining two partitioned tables
EXPLAIN ANALYZE
SELECT c.name, c.country, o.order_date, o.amount
FROM customers_list c
JOIN orders_range o ON c.customer_id = o.customer_id
WHERE c.country = 'INDIA' AND o.order_date BETWEEN '2024-01-01' AND '2024-01-31'
LIMIT 10;

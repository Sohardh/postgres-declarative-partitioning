-- ==========================================
-- RANGE PARTITIONING EXAMPLES
-- ==========================================

-- ==========================================
-- 1. Basic Queries and Partition Pruning
-- ==========================================

-- Example 1: Query for a specific date (January 15, 2024)
-- This will only scan the orders_range_2024_01 partition
EXPLAIN ANALYZE
SELECT * FROM orders_range WHERE order_date = '2024-01-15';

-- Example 2: Query for a date range within a single partition
-- This will only scan the orders_range_2024_01 partition
EXPLAIN ANALYZE
SELECT * FROM orders_range 
WHERE order_date BETWEEN '2024-01-10' AND '2024-01-20';

-- Example 3: Query for a date range spanning multiple partitions
-- This will scan both orders_range_2024_01 and orders_range_2024_02 partitions
EXPLAIN ANALYZE
SELECT * FROM orders_range 
WHERE order_date BETWEEN '2024-01-25' AND '2024-02-05';

-- Example 4: Query with no partition pruning (scans all partitions)
EXPLAIN ANALYZE
SELECT * FROM orders_range;

-- ==========================================
-- 2. Aggregation Queries
-- ==========================================

-- Example 5: Count orders by day in January 2024
-- This will only scan the orders_range_2024_01 partition
EXPLAIN ANALYZE
SELECT order_date, COUNT(*), SUM(amount) 
FROM orders_range 
WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31'
GROUP BY order_date
ORDER BY order_date;

-- Example 6: Average order amount by month
-- This will scan all partitions but demonstrates aggregation across partitions
EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS order_count,
    AVG(amount) AS avg_amount
FROM orders_range
GROUP BY month
ORDER BY month;


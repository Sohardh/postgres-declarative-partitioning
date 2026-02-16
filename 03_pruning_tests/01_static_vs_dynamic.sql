-- ==========================================
-- STATIC VS DYNAMIC PARTITION PRUNING EXAMPLES
-- ==========================================

-- ==========================================
-- 1. Static Partition Pruning
-- ==========================================

-- Example 1: Static pruning with exact date match
-- This will only scan the orders_range_2024_01 partition
EXPLAIN (ANALYZE, COSTS, BUFFERS, FORMAT TEXT)
SELECT * FROM orders_range WHERE order_date = '2024-01-15';

-- Example 2: Static pruning with date range within a single partition
-- This will only scan the orders_range_2024_01 partition
EXPLAIN (ANALYZE, COSTS, BUFFERS, FORMAT TEXT)
SELECT * FROM orders_range 
WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Example 3: Static pruning with date range spanning multiple partitions
-- This will scan both orders_range_2024_01 and orders_range_2024_02 partitions
EXPLAIN (ANALYZE, COSTS, BUFFERS, FORMAT TEXT)
SELECT * FROM orders_range 
WHERE order_date BETWEEN '2024-01-25' AND '2024-02-05';


-- ==========================================
-- 2. Dynamic Partition Pruning
-- ==========================================

-- Create a temporary table with dates for demonstration
CREATE TEMPORARY TABLE temp_dates (
    some_date DATE
);

INSERT INTO temp_dates VALUES 
    ('2024-01-15'),  -- Will match orders_range_2024_01 partition
    ('2024-02-15'),  -- Will match orders_range_2024_02 partition
    ('2023-12-15');  -- Will match orders_range_default partition

-- Example 5: Dynamic pruning with join condition
-- The planner can't determine which partitions to scan until it knows the values from temp_dates
EXPLAIN (ANALYZE, COSTS, BUFFERS, FORMAT TEXT)
SELECT o.* 
FROM orders_range o
JOIN temp_dates t ON o.order_date = t.some_date;

-- Example 6: Dynamic pruning with IN subquery
-- Similar to the join, the planner needs to evaluate the subquery first
EXPLAIN (ANALYZE, COSTS, BUFFERS, FORMAT TEXT)
SELECT * FROM orders_range
WHERE order_date IN (SELECT some_date FROM temp_dates);

-- Example 7: Dynamic pruning with scalar subquery
-- The planner can't determine which partition to scan until the subquery is evaluated
EXPLAIN (ANALYZE, COSTS, BUFFERS, FORMAT TEXT)
SELECT * FROM orders_range
WHERE order_date = (SELECT some_date FROM temp_dates LIMIT 1);

-- Example 8: Dynamic pruning with prepared statement parameters
-- Create a prepared statement
PREPARE get_orders_by_date(DATE) AS
SELECT * FROM orders_range WHERE order_date = $1;

-- By default, Postgres creates a "Custom Plan" for the first 5 executions,
-- which mimics static pruning. We force a "Generic Plan" here so we can
-- see the true dynamic pruning in action on the very first try.
SET plan_cache_mode = force_generic_plan;

-- Execute with different parameter values (Look for Subplans Removed)
EXPLAIN (ANALYZE, COSTS, BUFFERS, FORMAT TEXT)
EXECUTE get_orders_by_date('2024-01-15');  -- Will scan orders_range_2024_01,

EXPLAIN (ANALYZE, COSTS, BUFFERS, FORMAT TEXT)
EXECUTE get_orders_by_date('2024-02-15');  -- Will scan orders_range_2024_02

-- ==========================================
-- 3. Partition Pruning with Complex Conditions
-- ==========================================

-- Example 12: Pruning with function on the partition key
-- This typically prevents partition pruning because the function modifies the partition key
EXPLAIN (ANALYZE, COSTS, BUFFERS, FORMAT TEXT)
SELECT * FROM orders_range 
WHERE DATE_TRUNC('month', order_date) = DATE_TRUNC('month', '2024-01-15'::DATE);

-- Clean up
DROP TABLE temp_dates;
DEALLOCATE get_orders_by_date;
RESET plan_cache_mode;

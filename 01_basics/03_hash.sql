-- ==========================================
-- HASH PARTITIONING EXAMPLES
-- ==========================================

-- ==========================================
-- 1. Basic Queries and Partition Pruning
-- ==========================================

-- Example 1: Query for a specific session_id
-- This will only scan one partition (determined by hash of the UUID)
EXPLAIN ANALYZE
SELECT * FROM sessions_hash WHERE session_id = 'fec9b215-ea39-4969-a070-4311bea1e48c';

-- Example 2: Query with no partition pruning (scans all partitions)
-- Since there's no condition on the partition key, all partitions must be scanned
EXPLAIN ANALYZE
SELECT * FROM sessions_hash WHERE user_id = 1000;

-- Example 3: Query with multiple session_ids
-- This will scan only the partitions that contain these specific session_ids
EXPLAIN ANALYZE
SELECT * FROM sessions_hash
WHERE session_id IN (
    '4b7dacea-2f07-47a7-a8b8-f36f35a9fd23',
    '0c1417c1-a240-4ad9-9a4e-9d2325541077',
    'a4ed8bf2-782f-475f-9bc3-74ce21d55860'
);

-- ==========================================
-- 2. Understanding Hash Distribution
-- ==========================================

-- Example 4: Check data distribution across hash partitions
-- This should show roughly equal distribution if the hash function is working well
SELECT
    tableoid::regclass AS partition_name,
    COUNT(*) AS row_count
FROM sessions_hash
GROUP BY tableoid
ORDER BY partition_name;


-- ==========================================
-- 3. Performance Considerations
-- ==========================================

-- Example 6: Query with timestamp range (no partition pruning)
-- Hash partitioning doesn't help with range queries on non-partition columns
EXPLAIN ANALYZE
SELECT * FROM sessions_hash 
WHERE login_time BETWEEN NOW() - INTERVAL '1 day' AND NOW()
LIMIT 100;

-- Example 7: Aggregation query (must scan all partitions)
-- Count sessions by user_id
EXPLAIN ANALYZE
SELECT user_id, COUNT(*) AS session_count
FROM sessions_hash
GROUP BY user_id
ORDER BY session_count DESC
LIMIT 10;

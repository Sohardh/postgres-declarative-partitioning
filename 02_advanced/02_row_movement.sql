-- ==========================================
-- ROW MOVEMENT EXAMPLES
-- ==========================================
-- Row movement allows rows to be moved between partitions when the partition key is updated
-- This feature is enabled by default in PostgreSQL 11 and later

-- ==========================================
-- 1. Basic Row Movement with RANGE Partitioning
-- ==========================================

-- Example 1: Create a table partitioned by date range with row movement enabled
CREATE TABLE orders_with_movement (
    order_id SERIAL,
    order_date DATE NOT NULL,
    customer_id INT,
    amount DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_date)
) PARTITION BY RANGE (order_date);

-- Create partitions for different months
CREATE TABLE orders_with_movement_jan PARTITION OF orders_with_movement
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE orders_with_movement_feb PARTITION OF orders_with_movement
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

CREATE TABLE orders_with_movement_mar PARTITION OF orders_with_movement
    FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');

-- Example 2: Insert data and verify partition placement
INSERT INTO orders_with_movement (order_date, customer_id, amount)
VALUES ('2024-01-15', 101, 200.00);

-- Check which partition the row is in
SELECT tableoid::regclass AS partition_name, *
FROM orders_with_movement
WHERE order_date = '2024-01-15';

-- Example 3: Update the partition key to move the row to a different partition
UPDATE orders_with_movement
SET order_date = '2024-02-15'
WHERE order_date = '2024-01-15' AND customer_id = 101;

-- Verify the row has moved to the February partition
SELECT tableoid::regclass AS partition_name, *
FROM orders_with_movement
WHERE customer_id = 101;

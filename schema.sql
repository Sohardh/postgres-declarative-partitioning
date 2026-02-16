-- ==========================================
-- 1. RANGE Partitioning Example
-- ==========================================

-- Range partitioning divides data based on a range of values in the specified column

CREATE TABLE orders_range
(
    order_id    BIGSERIAL,
    order_date  DATE NOT NULL,
    customer_id INT,
    amount      DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_date)
) PARTITION BY RANGE (order_date);

-- January 2024 partition
-- This partition will store all orders with order_date >= '2024-01-01' AND order_date < '2024-02-01'
CREATE TABLE orders_range_2024_01 PARTITION OF orders_range
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- February 2024 partition
-- This partition will store all orders with order_date >= '2024-02-01' AND order_date < '2024-03-01'
CREATE TABLE orders_range_2024_02 PARTITION OF orders_range
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Default partition
-- This will capture any rows that don't match the specific partitions defined above
-- For example, orders with dates before 2024-01-01 or after 2024-03-01
CREATE TABLE orders_range_default PARTITION OF orders_range DEFAULT;

-- ==========================================
-- 2. LIST Partitioning Example
-- ==========================================

-- List partitioning divides data based on discrete values in the specified column

CREATE TABLE customers_list
(
    customer_id BIGSERIAL,
    name        TEXT,
    country     TEXT,
    PRIMARY KEY (customer_id, country)
) PARTITION BY LIST (country);

-- India partition
-- This partition will store all customers with country = 'INDIA'
CREATE TABLE customers_list_india PARTITION OF customers_list
    FOR VALUES IN ('INDIA');

-- USA partition
-- This partition will store all customers with country = 'USA'
CREATE TABLE customers_list_usa PARTITION OF customers_list
    FOR VALUES IN ('USA');

-- Default partition
-- This will capture any rows that don't match the specific partitions defined above
-- For example, customers from countries other than India or USA
CREATE TABLE customers_list_default PARTITION OF customers_list DEFAULT;

-- ==========================================
-- 3. HASH Partitioning Example
-- ==========================================

-- Hash partitioning distributes data evenly across partitions based on a hash value of the specified column

CREATE TABLE sessions_hash
(
    session_id UUID PRIMARY KEY,
    user_id    INT,
    login_time timestamp
) PARTITION BY HASH (session_id);

-- Partition 0
-- This partition will store all sessions where hash(session_id) mod 4 = 0
CREATE TABLE sessions_hash_0 PARTITION OF sessions_hash
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);

-- Partition 1
-- This partition will store all sessions where hash(session_id) mod 4 = 1
CREATE TABLE sessions_hash_1 PARTITION OF sessions_hash
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);

-- Partition 2
-- This partition will store all sessions where hash(session_id) mod 4 = 2
CREATE TABLE sessions_hash_2 PARTITION OF sessions_hash
    FOR VALUES WITH (MODULUS 4, REMAINDER 2);

-- Partition 3
-- This partition will store all sessions where hash(session_id) mod 4 = 3
CREATE TABLE sessions_hash_3 PARTITION OF sessions_hash
    FOR VALUES WITH (MODULUS 4, REMAINDER 3);

-- Verify Tuple Routing worked automatically
SELECT tableoid::regclass AS partition_name, * FROM orders_range;
SELECT tableoid::regclass AS partition_name, * FROM customers_list;
SELECT tableoid::regclass AS partition_name, * FROM sessions_hash;
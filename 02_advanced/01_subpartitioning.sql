-- ==========================================
-- SUBPARTITIONING EXAMPLES
-- ==========================================
-- Subpartitioning (or multi-level partitioning) allows you to further divide partitions into subpartitions

-- ==========================================
-- 1. Creating a Subpartitioned Table
-- ==========================================

-- Example: Sales table partitioned by date (RANGE) and then by region (LIST)
-- This creates a two-level partitioning hierarchy

-- Create the parent table with RANGE partitioning on order_date
CREATE TABLE sales_by_date_region (
    sale_id BIGSERIAL,
    order_date DATE NOT NULL,
    customer_region TEXT NOT NULL,
    amount DECIMAL(10, 2),
    PRIMARY KEY (sale_id, order_date, customer_region)
) PARTITION BY RANGE (order_date);

-- Create partitions for different date ranges (quarters)
-- Each partition is further subpartitioned by customer_region using LIST partitioning
CREATE TABLE sales_q1_2024 PARTITION OF sales_by_date_region
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01')
    PARTITION BY LIST (customer_region);

CREATE TABLE sales_q2_2024 PARTITION OF sales_by_date_region
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01')
    PARTITION BY LIST (customer_region);

-- Create subpartitions for Q1 by region
CREATE TABLE sales_q1_2024_asia PARTITION OF sales_q1_2024
    FOR VALUES IN ('ASIA');

CREATE TABLE sales_q1_2024_europe PARTITION OF sales_q1_2024
    FOR VALUES IN ('EUROPE');

CREATE TABLE sales_q1_2024_americas PARTITION OF sales_q1_2024
    FOR VALUES IN ('AMERICAS');

-- Default subpartition for Q1 (catches all other regions)
CREATE TABLE sales_q1_2024_other PARTITION OF sales_q1_2024 DEFAULT;

-- Create subpartitions for Q2 by region
CREATE TABLE sales_q2_2024_asia PARTITION OF sales_q2_2024
    FOR VALUES IN ('ASIA');

CREATE TABLE sales_q2_2024_europe PARTITION OF sales_q2_2024
    FOR VALUES IN ('EUROPE');

CREATE TABLE sales_q2_2024_americas PARTITION OF sales_q2_2024
    FOR VALUES IN ('AMERICAS');

-- Default subpartition for Q2 (catches all other regions)
CREATE TABLE sales_q2_2024_other PARTITION OF sales_q2_2024 DEFAULT;

-- ==========================================
-- 2. Inserting Data into Subpartitioned Tables
-- ==========================================

-- Insert sample data - PostgreSQL automatically routes rows to the correct subpartition
INSERT INTO sales_by_date_region (order_date, customer_region, amount)
VALUES 
    -- These will go to Q1 subpartitions
    ('2024-01-15', 'ASIA', 500.00),      -- Goes to sales_q1_2024_asia
    ('2024-02-20', 'EUROPE', 750.50),    -- Goes to sales_q1_2024_europe
    ('2024-03-10', 'AMERICAS', 1200.75), -- Goes to sales_q1_2024_americas
    ('2024-03-25', 'AFRICA', 350.25),    -- Goes to sales_q1_2024_other (default)

    -- These will go to Q2 subpartitions
    ('2024-04-05', 'ASIA', 600.00),      -- Goes to sales_q2_2024_asia
    ('2024-05-12', 'EUROPE', 900.50),    -- Goes to sales_q2_2024_europe
    ('2024-06-18', 'AMERICAS', 1500.75), -- Goes to sales_q2_2024_americas
    ('2024-06-30', 'AUSTRALIA', 450.25); -- Goes to sales_q2_2024_other (default)

-- ==========================================
-- 3. Querying Subpartitioned Tables
-- ==========================================

-- Example 1: Query that benefits from both levels of partitioning
-- This will only scan the sales_q1_2024_asia subpartition
EXPLAIN ANALYZE
SELECT * FROM sales_by_date_region 
WHERE order_date BETWEEN '2024-01-01' AND '2024-03-31'
AND customer_region = 'ASIA';

-- Example 2: Query that benefits from first-level partitioning only
-- This will scan all subpartitions of Q1 (all regions)
EXPLAIN ANALYZE
SELECT * FROM sales_by_date_region 
WHERE order_date BETWEEN '2024-01-01' AND '2024-03-31';

-- Example 3: Query that benefits from second-level partitioning only
-- This will scan the ASIA subpartitions for both Q1 and Q2
EXPLAIN ANALYZE
SELECT * FROM sales_by_date_region 
WHERE customer_region = 'ASIA';

-- Example 4: Query with no partition pruning (scans all subpartitions)
EXPLAIN ANALYZE
SELECT * FROM sales_by_date_region;
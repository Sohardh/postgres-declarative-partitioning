-- Data generation script for massive data volume
-- This file contains INSERT statements for all tables defined in schema.sql

-- ==========================================
-- 1. Data for RANGE Partitioning (orders_range)
-- ==========================================

-- Batch insert for January 2024 (will go to orders_range_2024_01 partition)
INSERT INTO orders_range (order_date, customer_id, amount)
SELECT 
    '2024-01-01'::DATE + (random() * 30)::INTEGER,
    (random() * 10000)::INTEGER + 1,
    (random() * 1000)::DECIMAL(10,2)
FROM generate_series(1, 500000);

-- Batch insert for February 2024 (will go to orders_range_2024_02 partition)
INSERT INTO orders_range (order_date, customer_id, amount)
SELECT 
    '2024-02-01'::DATE + (random() * 27)::INTEGER,
    (random() * 10000)::INTEGER + 1,
    (random() * 1000)::DECIMAL(10,2)
FROM generate_series(1, 500000);

-- Batch insert for other dates (will go to orders_range_default partition)
INSERT INTO orders_range (order_date, customer_id, amount)
SELECT 
    CASE 
        WHEN random() < 0.5 THEN '2023-12-01'::DATE + (random() * 30)::INTEGER
        ELSE '2024-03-01'::DATE + (random() * 30)::INTEGER
    END,
    (random() * 10000)::INTEGER + 1,
    (random() * 1000)::DECIMAL(10,2)
FROM generate_series(1, 500000);

-- ==========================================
-- 2. Data for LIST Partitioning (customers_list)
-- ==========================================

-- Batch insert for Indian customers (will go to customers_list_india partition)
INSERT INTO customers_list (name, country)
SELECT 
    'Customer_India_' || i,
    'INDIA'
FROM generate_series(1, 300000) i;

-- Batch insert for USA customers (will go to customers_list_usa partition)
INSERT INTO customers_list (name, country)
SELECT 
    'Customer_USA_' || i,
    'USA'
FROM generate_series(1, 300000) i;

-- Batch insert for other countries (will go to customers_list_default partition)
INSERT INTO customers_list (name, country)
WITH countries AS (
    SELECT unnest(ARRAY['CANADA', 'UK', 'GERMANY', 'FRANCE', 'AUSTRALIA', 'JAPAN', 'BRAZIL', 'MEXICO', 'CHINA', 'RUSSIA']) AS country
)
SELECT 
    'Customer_Other_' || i,
    countries.country
FROM generate_series(1, 400000) i
CROSS JOIN countries
WHERE i % 10 = get_byte(countries.country::bytea, 0) % 10;

-- ==========================================
-- 3. Data for HASH Partitioning (sessions_hash)
-- ==========================================

-- Batch insert for sessions (will be distributed across all hash partitions)
INSERT INTO sessions_hash (session_id, user_id, login_time)
SELECT 
    gen_random_uuid(),
    (random() * 10000)::INTEGER + 1,
    NOW() - (random() * 30 * interval '1 day')
FROM generate_series(1, 1000000);

-- Additional batch to make the data even larger
INSERT INTO sessions_hash (session_id, user_id, login_time)
SELECT 
    gen_random_uuid(),
    (random() * 10000)::INTEGER + 1,
    NOW() - (random() * 30 * interval '1 day')
FROM generate_series(1, 1000000);

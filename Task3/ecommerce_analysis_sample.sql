
-- ecommerce_analysis_sample.sql
-- Sample schema + analysis queries for Task 3: SQL for Data Analysis
-- Engine‑agnostic (MySQL / PostgreSQL / SQLite) with notes where syntax diverges.
------------------------------------------------------------------------------

/* =========================================================================
   1.  SCHEMA  (Run once to create tables if you don't already have the demo
       ecommerce database.  Skip this whole section if you imported a
       ready‑made dataset such as "Ecommerce_SQL_Database.sql".)
   =========================================================================*/
-- Customers table
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    email       VARCHAR(100) UNIQUE,
    created_at  TIMESTAMP
);

-- Products table
CREATE TABLE products (
    product_id  INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    category     VARCHAR(50),
    price        DECIMAL(10,2),
    created_at   TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
    order_id     INTEGER PRIMARY KEY,
    customer_id  INTEGER REFERENCES customers(customer_id),
    order_date   TIMESTAMP,
    status       VARCHAR(20),
    total_amount DECIMAL(12,2)
);

-- Order line items
CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id      INTEGER REFERENCES orders(order_id),
    product_id    INTEGER REFERENCES products(product_id),
    quantity      INTEGER,
    unit_price    DECIMAL(10,2)
);

-- Payments
CREATE TABLE payments (
    payment_id     INTEGER PRIMARY KEY,
    order_id       INTEGER REFERENCES orders(order_id),
    amount         DECIMAL(12,2),
    payment_date   TIMESTAMP,
    payment_method VARCHAR(20)
);

/* =========================================================================
   2.  ANALYSIS QUERIES
   =========================================================================*/

---------------------------------------------------------------------------
-- 2.1  Total sales per month
---------------------------------------------------------------------------
/* MySQL */     SELECT DATE_FORMAT(order_date, '%Y-%m')  AS month,
                       SUM(total_amount)                AS monthly_sales
                 FROM orders
                 GROUP BY month
                 ORDER BY month;

/* PostgreSQL */-- SELECT TO_CHAR(date_trunc('month', order_date), 'YYYY-MM') AS month,
--                       SUM(total_amount)                                  AS monthly_sales
--                FROM   orders
--                GROUP  BY 1
--                ORDER  BY 1;

/* SQLite */    -- SELECT strftime('%Y-%m', order_date)                    AS month,
--                      SUM(total_amount)                                  AS monthly_sales
--               FROM   orders
--               GROUP  BY 1
--               ORDER  BY 1;

---------------------------------------------------------------------------
-- 2.2  Top 10 customers by lifetime spend
---------------------------------------------------------------------------
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name      AS customer,
       SUM(o.total_amount)                     AS total_spent
FROM   customers c
       JOIN orders o ON o.customer_id = c.customer_id
GROUP  BY c.customer_id, customer
ORDER  BY total_spent DESC
LIMIT  10;

---------------------------------------------------------------------------
-- 2.3  Average item value by product category
---------------------------------------------------------------------------
SELECT p.category,
       AVG(oi.quantity * oi.unit_price)        AS avg_item_value
FROM   order_items oi
       JOIN products p ON p.product_id = oi.product_id
GROUP  BY p.category
ORDER  BY avg_item_value DESC;

---------------------------------------------------------------------------
-- 2.4  Products that sell above the overall average units
---------------------------------------------------------------------------
SELECT p.product_id,
       p.product_name,
       SUM(oi.quantity)                        AS units_sold
FROM   products p
       JOIN order_items oi ON oi.product_id = p.product_id
GROUP  BY p.product_id, p.product_name
HAVING SUM(oi.quantity) >
       ( SELECT AVG(product_units)
         FROM ( SELECT SUM(quantity) AS product_units
                FROM   order_items
                GROUP  BY product_id ) AS prod_summary );

---------------------------------------------------------------------------
-- 2.5  Daily sales view
---------------------------------------------------------------------------
/* MySQL / PostgreSQL */  CREATE OR REPLACE VIEW vw_daily_sales AS
                          SELECT DATE(order_date)            AS sales_date,
                                 SUM(total_amount)           AS daily_sales
                          FROM   orders
                          GROUP  BY sales_date;

/* SQLite */              -- CREATE VIEW vw_daily_sales AS
--                            SELECT date(order_date)         AS sales_date,
--                                   SUM(total_amount)        AS daily_sales
--                            FROM   orders
--                            GROUP  BY 1;

---------------------------------------------------------------------------
-- 2.6  Index for faster date filtering
---------------------------------------------------------------------------
/* MySQL / PostgreSQL */  CREATE INDEX idx_orders_date ON orders(order_date);
/* SQLite */              -- CREATE INDEX idx_orders_date ON orders(order_date);

---------------------------------------------------------------------------
-- 2.7  Read the execution plan (example)
---------------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT *
FROM   orders
WHERE  order_date BETWEEN '2025-05-01' AND '2025-05-31';

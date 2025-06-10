CREATE DATABASE online_sales_db;
USE online_sales_db;

CREATE TABLE orders (
	   order_id INT PRIMARY KEY,
       order_date DATE,
       amount DECIMAL(10,2),
       product_id int
       );
       
INSERT INTO orders(order_id, order_date,amount,product_id) VALUES
(1, '2024-01-05', 150.00, 101),
(2, '2024-01-12', 200.00, 102),
(3, '2024-02-15', 180.00, 103),
(4, '2024-02-18', 220.00, 104),
(5, '2024-03-05', 300.00, 105),
(6, '2024-03-22', 250.00, 106),
(7, '2024-04-10', 190.00, 107),
(8, '2024-04-25', 210.00, 108),
(9, '2024-05-03', 400.00, 109),
(10, '2024-05-18', 350.00, 110);


SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(amount) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;    
         
-- select* from orders    

SELECT
   YEAR(order_date) AS order_year,
   MONTH(order_date) AS order_month,
   SUM(amount) AS total_revenue,
   COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_date BETWEEN '2024-03-01' AND '2024-05-31'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year,order_month;   
     
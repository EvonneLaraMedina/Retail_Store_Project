-- Retail Store Project
CREATE DATABASE retail_store;
USE retail_store;

-- Creating a table named customers
CREATE TABLE customers (
customer_id SERIAL PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
city VARCHAR(50),
country VARCHAR(50)
);
-- Creating another table named products
CREATE TABLE products (
product_id SERIAL PRIMARY KEY,
product_name VARCHAR(100),
category VARCHAR(50),
price NUMERIC(10,2)
);
-- Creating another table named orders
CREATE TABLE orders (
order_id SERIAL PRIMARY KEY,
customer_id INT REFERENCES customers(customer_id),
product_id INT REFERENCES products(product_id),
order_date DATE,
quantity INT,
discount NUMERIC(4,2)
);

-- Inserting data into the customers table
INSERT INTO customers (customer_id, first_name, last_name, city, country) VALUES
(1, 'Maria', 'Garcia', 'Miami', 'USA'),
(2, 'James', 'Chen', 'New York', 'USA'),
(3, 'Sophie', 'Martin', 'Paris', 'France'),
(4, 'Liam', 'Patel', 'London', 'UK'),
(5, 'Yuki', 'Tanaka', 'Tokyo', 'Japan'),
(6, 'Carlos', 'Ruiz', 'Madrid', 'Spain'),
(7, 'Anna', 'Kowalski', 'Warsaw', 'Poland'),
(8, 'Kevin', 'Brown', 'Chicago', 'USA');
-- Insert data into the products table
INSERT INTO products (product_id, product_name, category, price) VALUES
(1, 'Wireless Headphones', 'Electronics', 89.99),
(2, 'Running Shoes', 'Footwear', 124.99),
(3, 'Coffee Maker', 'Appliances', 59.99),
(4, 'Yoga Mat', 'Sports', 34.99),
(5, 'Laptop Stand', 'Electronics', 49.99),
(6, 'Winter Jacket', 'Clothing', 199.99),
(7, 'Water Bottle', 'Sports', 24.99),
(8, 'Desk Lamp', 'Appliances', 39.99);

-- Insert data into orders table
INSERT INTO orders (order_id, customer_id, product_id, order_date, quantity, discount)
VALUES
(101, 1, 1, '2024-01-10', 2, 0.00),
(102, 2, 3, '2024-01-15', 1, 0.10),
(103, 3, 6, '2024-02-01', 1, 0.00),
(104, 4, 2, '2024-02-14', 3, 0.05),
(105, 5, 5, '2024-03-05', 2, 0.00),
(106, 6, 4, '2024-03-20', 4, 0.15),
(107, 7, 7, '2024-04-02', 5, 0.00),
(108, 8, 8, '2024-04-18', 1, 0.10),
(109, 1, 2, '2024-05-01', 1, 0.00),
(110, 3, 1, '2024-05-10', 2, 0.20),
(111, 2, 4, '2024-06-01', 3, 0.00),
(112, 5, 6, '2024-06-15', 1, 0.10),
(113, NULL, 3, '2024-07-01', 2, 0.00),
(114, 4, 7, '2024-07-20', 6, 0.05),
(115, 6, 8, '2024-08-01', 1, 0.00);

SELECT * FROM customers; -- should show 8 rows
SELECT * FROM products; -- should show 8 rows
SELECT * FROM orders; -- should show 15 rows
-- Full customer name with NULL handling in case of NULL values
SELECT
customer_id,
CONCAT(first_name, ' ', last_name) AS full_name,
COALESCE(city, 'Unknown') AS city,
COALESCE(country, 'Unknown') AS country
FROM customers;
-- Shows orders with customer and product information
-- LEFT JOIN keeps Order 113 (NULL CustomerID) — COALESCE labels it "Guest".
SELECT
o.order_id,
COALESCE(CONCAT(c.first_name,' ',c.last_name), 'Guest') AS customer_name,
p.product_name,
p.category,
o.quantity,
o.order_date,
ROUND((p.price * o.quantity * (1 - o.discount)),2) AS total_after_discount
FROM orders AS o
INNER JOIN products AS p ON o.product_id = p.product_id
LEFT JOIN customers AS c ON o.customer_id = c.customer_id;
-- Shows sales summary by product category
SELECT
p.category,
COUNT(o.order_id) AS total_orders,
SUM(o.quantity) AS units_sold,
ROUND(AVG(p.price),2) AS avg_price,
ROUND(SUM(p.price * o.quantity * (1-o.discount)),2) AS total_revenue

FROM orders AS o
JOIN products AS p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;
-- Shows order tier classification
SELECT
o.order_id,
p.product_name,
(p.Price * o.quantity) AS gross_amount,
CASE
WHEN (p.price * o.quantity) >= 300 THEN 'High Value'
WHEN (p.price * o.quantity) >= 100 THEN 'Medium Value'
ELSE 'Low Value'
END AS order_tier,
o.discount,
CASE
WHEN o.discount > 0 THEN 'Discounted'
ELSE 'Full Price'
END AS price_type
FROM orders AS o
JOIN products AS p ON o.product_id = p.product_id
WHERE o.order_date >= '2024-01-01'
ORDER BY gross_amount DESC;
-- Shows UNION ALL just to demonstrate the concept
SELECT o.order_id, p.product_name, p.category, 'Electronics' AS source
FROM orders o JOIN products p ON o.product_id = p.product_id
WHERE p.category = 'Electronics'
UNION ALL
SELECT o.order_id, p.product_name, p.category, 'Appliances' AS source
FROM orders o JOIN products p ON o.product_id = p.product_id
WHERE p.category = 'Appliances'
ORDER BY order_id;

-- This combines all three tables into one clean view
CREATE VIEW vw_sales_dashboard AS
SELECT
o.order_id,
o.order_date,
COALESCE(CONCAT(c.first_name, ' ', c.last_name), 'Guest') AS customer_name,
COALESCE(c.country, 'Unknown') AS country,
p.product_name,
p.category,
o.quantity,
p.price,
o.discount,
ROUND(p.price * o.quantity * (1 - o.discount), 2) AS revenue,
CASE
WHEN p.price * o.quantity >= 300 THEN 'High'
WHEN p.price * o.quantity >= 100 THEN 'Medium'
ELSE 'Low'
END AS order_tier

FROM orders AS o
JOIN products AS p ON o.product_id = p.product_id
LEFT JOIN customers AS c ON o.customer_id = c.customer_id;
-- Showing the combined query
SELECT * FROM vw_sales_dashboard;


-- ***********************
-- Student1 Name: Diego Bravo Torres Student1 ID: 138350202
-- Student2 Name: Victor Lozano Alonso Student2 ID: 130720204
-- Date: Oct 18, 2021
-- Purpose: Assignment 1 - DBS311
-- ***********************

--  1. Display the employee number, full employee name, job title, and hire date of all employees
--     hired in September with the most recently hired employees displayed first. 
-- Q1 SOLUTION --
SELECT employee_id "Employee Number", last_name || ', ' || first_name "Full Name", job_title "Job Title", '[' || TO_CHAR(hire_date, 'Month" "ddth" of "yyyy')  || ']' "Start Date"
FROM employees
WHERE TO_CHAR(hire_date, 'MM') = 9
ORDER BY hire_date DESC;


 -- 2. The company wants to see the total sale amount per sales person (salesman) for all orders. 
 --    Assume that online orders do not have any sales representative. For online orders (orders with no salesman ID), consider the salesman ID as 0. 
 --    Display the salesman ID and the total sale amount for the employee for each employee. 
 -- Q2 SOLUTION --
 SELECT COALESCE( salesman_id, 0 ) as "Employee Number" ,TO_CHAR(sum(unit_price * quantity), '$999,999,999.00') as "Total Sale"
 FROM orders o JOIN order_items i
 ON o.order_id = i.order_id
 GROUP BY salesman_id
 ORDER BY  COALESCE( salesman_id, 0 ) ;
 
-- 3.	Display customer Id, customer name and total number of orders for customers that the value of
--    their customer Id is in values from 35 to 45. Include the customers with no orders in your 
--    report if their customer Id falls in the range 35 and 45.  
--    Sort the result by the value of total orders. 
-- Q3 SOLUTION --
SELECT c.customer_id "Customer Id", c.name "Name", COUNT(o.order_id) "Total Orders"
FROM customers c LEFT JOIN orders o
ON c.customer_id = o.customer_id
HAVING c.customer_id >= 35  AND c.customer_id <= 45
GROUP BY c.customer_id, c.name
ORDER BY "Total Orders";

 --  4.	Display customer Id, customer name, and the order id and the order date of all orders for customer whose ID is 44.
 --  a.	Show also the total quantity and the total amount of each customer’s order.
 --  b.	Sort the result from the highest to lowest total order amount.
 -- Q4 SOLUTION --
 SELECT c.customer_id, name, o.order_id, order_date, SUM(quantity) AS total_items,TO_CHAR(sum(unit_price * quantity), '$999,999,999.00') as "Total Amount"
 FROM customers c JOIN orders o 
 ON c.customer_id = o.customer_id 
 JOIN order_items oi 
 ON o.order_id = oi.order_id 
 WHERE c.customer_id = 44 
 GROUP BY c.customer_id, name, o.order_id, o.order_date 
 ORDER BY SUM(oi.quantity * oi.unit_price) DESC;
 
--  5. Display customer Id, name, total number of orders, the total number of items ordered, and the total
--     order amount for customers who have more than 30 orders.
--     Sort the result based on the total number of orders.
-- Q5 SOLUTION --
SELECT c.customer_id "Customer Id", c.name "Name", COUNT(o.order_id) "Total Orders", SUM(oi.quantity) "Total Items", TO_CHAR(SUM(oi.quantity*oi.unit_price), '$999,999,999.00') "Total Amount"
FROM orders o Join order_items oi
ON o.order_id = oi.order_id
JOIN customers c
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING count(oi.order_id) > 30
ORDER BY count(oi.order_id);

 -- 6.	Display Warehouse Id, warehouse name, product category Id, product category name, and the lowest product standard cost for this combination.
 --     In your result, include the rows that the lowest standard cost is less then $200.
 -- 	Also, include the rows that the lowest cost is more than $500.
 -- 	Sort the output according to Warehouse Id, warehouse name and then product category Id, and product category name.
-- Q6 SOLUTION --
 SELECT w.warehouse_id as "Warehouse ID", w.warehouse_name as "Warehouse Name", p.category_id as "Category ID", pc.category_name as "Category Name",' $' || MIN(standard_cost) as "Lowest Cost"
 FROM warehouses w INNER JOIN inventories i
 ON w.warehouse_id = i.warehouse_id
 INNER JOIN products p
 ON p.product_id = i.product_id
 INNER JOIN product_categories pc
 ON pc.category_id = p.category_id
 HAVING MIN(standard_cost) < 200 OR MIN(standard_cost) > 500
 GROUP BY w.warehouse_id, w.warehouse_name, p.category_id,pc.category_name
 ORDER BY w.warehouse_id,w.warehouse_name, p.category_id, pc.category_name;
 
-- 7.	Display the total number of orders per month. Sort the result from January to December.
-- Q7 SOLUTION --
SELECT TO_CHAR(order_date, 'Month') "Month", COUNT(TO_CHAR(order_date, 'Month')) "Number of Orders"
FROM orders
GROUP BY TO_CHAR(order_date, 'Month'), TO_CHAR(order_date, 'mm')
ORDER BY TO_CHAR(order_date, 'mm');

 -- 8.	Display product Id, product name for products that their list price is more than any highest product standard cost per warehouse outside Americas regions.
 --     (You need to find the highest standard cost for each warehouse that is located outside the Americas regions. 
 --     Then you need to return all products that their list price is higher than any highest standard cost of those warehouses.)
 --     Sort the result according to list price.
 -- Q8 SOLUTION --
SELECT product_id as "Product ID", product_name as "Product Name", TO_CHAR(list_price, '$999,999,999.00') as "Price"
FROM products
WHERE list_price > ANY ( SELECT max(p.standard_cost)
                        FROM locations l JOIN countries c
                        ON l.country_id = c.country_id
                        JOIN regions r
                        ON c.region_id = r.region_id
                        JOIN warehouses w
                        ON l.location_id = w.location_id
                        JOIN inventories i
                        ON w.warehouse_id = i.warehouse_id
                        JOIN products p
                        ON i.product_id = p.product_id
                        WHERE c.region_id  NOT LIKE 2
                        GROUP BY w.warehouse_id
                    )
ORDER BY  list_price DESC;

-- 9.	Write a SQL statement to display the most expensive and the cheapest product (list price).
--    Display product ID, product name, and the list price.
-- Q9 SOLUTION --
SELECT product_id "Product Id", product_name "Product Name", TO_CHAR(list_price, '$999,999,999.00') "Price"
FROM products
WHERE list_price <= (SELECT MIN(list_price)
                        FROM products)
                        OR list_price >= (SELECT MAX(list_price)
                                             FROM products);

-- 10.	Write a SQL query to display the number of customers with total order amount over the average amount
-- of all products, the number of customers with total order amount under the average amount of all products, 
-- number of customer with no orders, and the total number of customers.
-- Q10 SOLUTION --
SELECT  'Number of customers with total purchase amount over average: '|| count(*) as "Customer Report"
FROM (SELECT sum(oi.unit_price * oi.quantity) as average
      FROM CUSTOMERS c JOIN ORDERS o
      ON c.customer_id =  o.customer_id
      JOIN order_items oi
      ON o.order_id = oi.order_id
      group by c.customer_id) 
WHERE average > (SELECT avg(quantity * unit_price)
                                    FROM order_items )
UNION ALL
SELECT  'Number of customers with total purchase amount below average: '|| count(*) as "Customer Report"
FROM (SELECT sum(oi.unit_price * oi.quantity) as average
      FROM CUSTOMERS c JOIN ORDERS o
      ON c.customer_id =  o.customer_id
      JOIN order_items oi
      ON o.order_id = oi.order_id
      group by c.customer_id) 
WHERE average < (SELECT avg(quantity * unit_price)
                                    FROM order_items)
UNION ALL
SELECT 'Number of customers with no orders: '|| count(*) as "Customer Report"
FROM customers c LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS null

UNION ALL
SELECT  'Total number of customers: '|| count(*) as "Customer Report"
FROM customers;







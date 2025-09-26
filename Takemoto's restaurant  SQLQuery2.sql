CREATE DATABASE Takemoto_restaurent;

USE restaurent;

CREATE TABLE sales(
	customer_id VARCHAR(1),
	order_date DATE,
	product_id INTEGER
);

INSERT INTO sales
	(customer_id, order_date, product_id)
VALUES
	('A', '2021-01-01', 1),
	('A', '2021-01-01', 2),
	('A', '2021-01-07', 2),
	('A', '2021-01-10', 3),
	('A', '2021-01-11', 3),
	('A', '2021-01-11', 3),
	('B', '2021-01-01', 2),
	('B', '2021-01-02', 2),
	('B', '2021-01-04', 1),
	('B', '2021-01-11', 1),
	('B', '2021-01-16', 3),
	('B', '2021-02-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-07', 3);

CREATE TABLE menu(
	product_id INTEGER,
	product_name VARCHAR(5),
	price INTEGER
);

INSERT INTO menu
	(product_id, product_name, price)
VALUES
	(1, 'sushi', 10),
    (2, 'curry', 15),
    (3, 'ramen', 12);

CREATE TABLE members(
	customer_id VARCHAR(1),
	join_date DATE
);


INSERT INTO members
	(customer_id, join_date)
VALUES
	('A', '2021-01-07'),
    ('B', '2021-01-09');


select * from sales;
select * from menu; 
select * from members; 

/********************************************************************
	SQL STUDY CASE
*********************************************************************/

CREATE DATABASE Takemoto_restaurant;
USE restaurent;

-- Create tables  

CREATE TABLE sales(
	customer_id VARCHAR(1),
	order_date DATE,
	product_id INTEGER
);

CREATE TABLE menu(
	product_id INTEGER,
	product_name VARCHAR(5),
	price INTEGER
);

CREATE TABLE members(
	customer_id VARCHAR(1),
	join_date DATE
);

-- Insert data into tables

INSERT INTO sales
	(customer_id, order_date, product_id)
VALUES
	('A', '2021-01-01', 1),
	('A', '2021-01-01', 2),
	('A', '2021-01-07', 2),
	('A', '2021-01-10', 3),
	('A', '2021-01-11', 3),
	('A', '2021-01-11', 3),
	('B', '2021-01-01', 2),
	('B', '2021-01-02', 2),
	('B', '2021-01-04', 1),
	('B', '2021-01-11', 1),
	('B', '2021-01-16', 3),
	('B', '2021-02-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-07', 3);

INSERT INTO menu
	(product_id, product_name, price)
VALUES
	(1, 'sushi', 10),
    (2, 'curry', 15),
    (3, 'ramen', 12);

INSERT INTO members
	(customer_id, join_date)
VALUES
	('A', '2021-01-07'),
    ('B', '2021-01-09');


/********************************************************************
	Data exploratory
*********************************************************************/

SELECT * FROM members;
SELECT * FROM menu;
SELECT * FROM sales;
-- ON mb.customer_id
-- ON m.product_id
-- ON s.customer_id
-- ON s.product_id

-- What is the total amount spend by customers in the restaurant ?
SELECT 
	SUM(m.price)
FROM sales s
JOIN menu m 
	ON s.product_id = m.product_id 

-- What the running total amount spent of the customers by product item
WITH running_total AS 
(
	SELECT 
		s.customer_id, m.product_name, 
		SUM(m.price) total_spent
	FROM sales s
	JOIN menu m 
		ON s.product_id = m.product_id
	GROUP BY s.customer_id, m.product_name 
)
SELECT 
	customer_id, product_name,total_spent,
	SUM(total_spent) OVER(PARTITION BY customer_id
	ORDER BY product_name) Runiing_total_spent
FROM running_total;

--	=========================================================================
	-- 1. What is the total amount spent by each customer at the restaurant ?
--	=========================================================================  

SELECT 
	s.customer_id, SUM(m.price)
FROM sales s
Left Join menu m
	ON s.product_id = m.product_id 
GROUP BY s.customer_id;

--	=======================================================================
	-- 2. How many days each customer visited the restaurant ?
--	=======================================================================   
 
SELECT 
	customer_id, COUNT(DISTINCT order_date) nb_days_visit
FROM sales
GROUP BY customer_id;

--	=========================================================================
	-- 3. What was the first item purchased from the menu by each customer ?
--  =========================================================================   
  
WITH First_item_purchased AS
(
	SELECT 
		customer_id, 
		MIN(order_date) first_purchased_date
	FROM sales
	GROUP BY  customer_id
)
SELECT 
	f.customer_id, f.first_purchased_date, m.product_name
FROM First_item_purchased f
JOIN sales s 
	ON f.customer_id = s.customer_id AND f.first_purchased_date = s.order_date 
	-- first join the CTE by sales table using common columns (customer_id and first_purchased_date) 
JOIN menu m 
	ON s.product_id = m.product_id; 

--	===========================================================================================================
	-- 4. What is the most purchased item on the menu and how many time was it purchased by all the customers?
--  ===========================================================================================================

SELECT 
	m.product_name, 
	SUM(m.price) total_amount, COUNT(*) Nb_purchased
FROM sales s
JOIN menu m 
	ON s.product_id = m.product_id
GROUP BY  m.product_name
ORDER BY 3 DESC; 

--	===========================================================================
	-- 5. Which item was the most popular for each customer ?
--	===========================================================================   
 
WITH most_popular_item AS
(
	SELECT 
	s.customer_id, m.product_name, COUNT(*) nb_purchased
	FROM sales s
	JOIN menu m 
		ON s.product_id = m.product_id 
	GROUP BY s.customer_id,m.product_name 
), Ranking_popularity AS
(
	SELECT 
		mpi.customer_id,mpi.nb_purchased,
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY  nb_purchased DESC) ranking 
	FROM most_popular_item mpi
)
SELECT rp.*
FROM Ranking_popularity rp 
WHERE ranking = 1;

--	==================================================================================
	-- 6. Which item was purchased first by the customer after they became a member ?
--	==================================================================================   

WITH membership_first_item_purchased AS
(
	SELECT 
		s.customer_id, MIN(s.order_date) first_purchased_date 
	FROM sales s
	JOIN members mb
		ON s.customer_id = mb.customer_id
	WHERE s.order_date >= mb.join_date
	GROUP By s.customer_id
)
SELECT 
	mfip.customer_id, mfip.first_purchased_date, m.product_name
FROM membership_first_item_purchased mfip
JOIN sales s 
	ON mfip.customer_id = s.customer_id AND mfip.first_purchased_date = s.order_date 
JOIN menu m
	ON s.product_id = m.product_id; 

--	==================================================================================
	-- 7. Which item was purchased just before the customer became a member ?
--	==================================================================================  

WITH last_purchased_before_membership AS
(
	SELECT 
		s.customer_id, MAX(s.order_date) last_purchased_date
	FROM sales s 
	JOIN members mb 
		ON s.customer_id = mb.customer_id 
	WHERE s.order_date < mb.join_date
	GROUP BY s.customer_id
)
SELECT 
	lpbm.customer_id, lpbm.last_purchased_date, m.product_name
FROM last_purchased_before_membership lpbm
JOIN sales s
	ON lpbm.customer_id = s.customer_id AND lpbm.last_purchased_date = s.order_date
JOIN menu m 
	ON s.product_id = m.product_id ; 

--	===========================================================================================
	-- 8. What is the total items and amount spent for each member before they became member ?
--	===========================================================================================
SELECT 
	s.customer_id, COUNT(*), SUM(m.price)
FROM sales s
JOIN menu m
	ON  s.product_id =  m.product_id
JOIN members mb
	ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id ;

--	==================================================================================
	-- 9. If the customers spend $1 they earn 20 points for sushi and 10 points 
--	==================================================================================  

SELECT 
	s.customer_id, SUM(
	CASE
		WHEN product_name = 'sushi' THEN m.price * 20
		ELSE m.price * 10
	END ) points
FROM sales s
JOIN menu m
	ON  s.product_id =  m.product_id
GROUP BY s.customer_id;

--	=========================================================================================
	/* 10. If the customers join the membership program within the first week they earn
	2X points on all items.After this period, if the customers spend $1 they earn 20 points 
	for sushi and 10 points. How many points Customers A and B have at the end of January */
--	========================================================================================= 

SELECT 
	s.customer_id, SUM(
	CASE
		WHEN s.order_date BETWEEN mb.join_date AND DATEADD(DAY, 7, mb.join_date)
		THEN m.price * 20
		WHEN product_name = 'sushi' THEN m.price * 20
		ELSE m.price * 10 
	END) total_points
FROM sales s
JOIN menu m
	ON  s.product_id =  m.product_id
LEFT JOIN members mb
	ON s.customer_id = mb.customer_id
WHERE s.customer_id IN ('A','B') -- only customers A & B joined the membership program
	AND s.order_date <= '2021-01-31'
GROUP BY s.customer_id;

--	==================================================================================
	/* 11.  Create an output report using the available data :
	Generate the columns the customer_id, order_date, product_name, price, 
	and  the membership (Yes or N) in a single table. */
--	================================================================================== 

SELECT

	s.customer_id, s.order_date, m.product_name, m.price,
	CASE
		WHEN s.order_date >= mb.join_date THEN 'Yes'
		ELSE 'No'
	END membership
INTO #report_view -- we put the report in atemp table
FROM sales s
JOIN menu m
	ON  s.product_id =  m.product_id
LEFT JOIN members mb
	ON s.customer_id = mb.customer_id
ORDER BY customer_id, order_date; 

SELECT * FROM #report_view; 

/********************************************************************
	The End of the exploratory
*********************************************************************/


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


-- 1.	What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, sum(price) Total_Spent 
FROM sales s
JOIN menu m on s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY 2 DESC;


-- 2.	How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) TIME_VISIT
FROM sales 
GROUP BY customer_id;


-- 3.	What was the first item from the menu purchased by each customer?
WITH FIRST_MENU_PURCHASED AS
(
	-- FIRST TIME CUSTOMER PURCHASED
	SELECT customer_id, MIN(order_date) FIRST_TIME_PURCHASE
	FROM sales 
	GROUP BY customer_id
)
SELECT f.customer_id, f.FIRST_TIME_PURCHASE, m.product_name 
FROM FIRST_MENU_PURCHASED f 
JOIN sales s ON f.customer_id = s.customer_id
AND f.FIRST_TIME_PURCHASE = s.order_date
JOIN menu m ON s.product_id = m.product_id;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(*) MOST_PURCHASED_MENU
FROM sales s 
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY 2 DESC ;


-- 5. Which item was the most popular for each customer?
WITH MOST_POPULAR_MENU AS
(
	SELECT s.customer_id,m.product_name,COUNT(*) MOST_PURCHASED_MENU,
	DENSE_RANK() OVER( PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) RANK
	FROM sales s 
	JOIN menu m ON s.product_id = m.product_id 
	GROUP BY s.customer_id,m.product_name 
)
SELECT * 
FROM MOST_POPULAR_MENU 
WHERE RANK = 1 ; 


-- 6. Which item was purchased first by the customer after they became a member?
WITH FIRST_ITEM AS
(
	SELECT s.customer_id, MIN(s.order_date) FIRST_PURCHASE
	FROM sales s
	JOIN members mb ON s.customer_id = mb.customer_id
	WHERE s.order_date >= mb.join_date
	GROUP BY s.customer_id
)
SELECT fi.customer_id, fi.FIRST_PURCHASE,m.product_name 
FROM FIRST_ITEM fi 
JOIN sales s ON fi.customer_id= s.customer_id 
AND fi.FIRST_PURCHASE = s.order_date
JOIN menu m ON s.product_id=m.product_id;


-- 7. Which item was purchased just before the customer became a member?
WITH PURCHASE_BEFORE_MEMBERSHIP AS
(
	SELECT s.customer_id, MIN(s.order_date) FIRST_PURCHASE
	FROM sales s
	JOIN members mb ON s.customer_id=mb.customer_id
	WHERE s.order_date < mb.join_date
	GROUP BY s.customer_id
)
SELECT pbm.customer_id, pbm.FIRST_PURCHASE,m.product_name 
FROM PURCHASE_BEFORE_MEMBERSHIP pbm 
JOIN sales s ON pbm.customer_id = s.customer_id 
AND pbm.FIRST_PURCHASE = s.order_date
JOIN menu m ON s.product_id = m.product_id; 


-- 8.	What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, SUM(m.price) Total_Spent, COUNT(*) Total_Items
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id=mb.customer_id
GROUP BY s.customer_id
ORDER BY 3 DESC ;


-- 9.	If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
/* how many points would each customer have? */
SELECT s.customer_id, SUM 
(CASE
	WHEN m.product_name = 'sushi' THEN m.price*20
	ELSE m.price*10
END) Total_Points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY 2 DESC;


-- 10.	In the first week after a customer joins the program (including their join date)
-- they earn 2x points on all items, not just sushi;
-- how many points do customer A and B have at the end of January?  
SELECT s.customer_id, SUM
	(CASE
		WHEN s.order_date BETWEEN mb.join_date AND DATEADD(DD,7,mb.join_date) THEN m.price*20
		WHEN m.product_name = 'sushi' THEN m.price*20
		ELSE m.price*10
	END) Total_Points
FROM sales s
JOIN menu m ON s.product_id = m.product_id 
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id ; 


-- 11.	Recreate the table output using the available data
WITH CSV_DATA AS(
	SELECT s.customer_id, m.price, m.product_name,s.order_date, mb.join_date,
	(CASE
		WHEN s.order_date >= mb.join_date THEN 'MEMBER'
		WHEN s.order_date <= mb.join_date THEN 'NOT MEMBER'
		ELSE 'NEVER JOIN MEMBERSHIP'
	END) MEMBERSHIP
	FROM sales s
	JOIN menu m ON s.product_id = m.product_id
	LEFT JOIN members mb ON s.customer_id = mb.customer_id)
-- RANK THE CUSTOMER MEMBERSHIP
SELECT cs.*, (
CASE 
	WHEN MEMBERSHIP = 'NEVER JOIN MEMBERSHIP' THEN NULL 
	ELSE RANK() OVER(PARTITION BY cs.customer_id ORDER BY cs.order_date) 
END) RANKING 
FROM CSV_DATA cs; 


# Customer-Behavior-Analysis

## Overview: 
This project is a SQL study case which analyzed customer spending patterns, purchasing habits to enhance menu offerings and marketing strategies for a Japanese restaurant “Takemoto’s Restaurant”.

## Background:
Takemoto, a passionate food enthusiast, opened a small restaurant in early 2021 serving sushi, curry, and ramen. 
Despite collecting basic operational data, Takemoto’s Restaurant lacked the expertise to leverage this data effectively jeopardizing business sustainability.

## Objectives:
The objective of this project is to answer the following business questions: 

### Business Questions Explored:
1.	What is the total amount each customer spent at the restaurant?
2.	How many days has each customer visited the restaurant?
3.	What was the first item from the menu purchased by each customer?
4.	What is the most purchased item on the menu and how many times was it purchased by all customers?
5.	Which item was the most popular for each customer?
6.	Which item was purchased first by the customer after they became a member?
7.	Which item was purchased just before the customer became a member?
8.	What is the total items and amount spent for each member before they became a member?
9.	If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10.	In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
11.	Recreate the table output using the available data and rank the customers
    
### Challenge: 
Takemoto needed actionable insights to:
- Understand customer visit patterns, spending behavior, and favorite menu items.
- Enhance customer experience and personalize loyalty programs.
- Create accessible datasets for his team to analyze without relying on SQL.

### Contribution: 
The insights enabled Takemoto to: 

-	**Increased repeat visits by 20% through targeted promotions**
-	**Create simplified reporting for staff via automated CSV exports**

### Data Structure

1. Sales Table: *customer_id; order_date and product_id*
2. Menu Table:  *product_id; product_name and Dish name (e.g., "Spicy Ramen", "Salmon Sushi") and price*
3. Members Table: *customer_id and join_date (When they joined the rewards program)*

#### Solution Approach:
Using a sample dataset, we developed SQL queries to:
- Track customer visits and spending trends.
- Identify top-selling menu items.
- Generate user-friendly datasets for non-technical team members.
 
#### Tool Used:
- *SQL Server 2021*

#### Skills Applied:
- *Window Functions*
- *CTEs*
- *Aggregations*
- *JOINs*

## Findings Summary
- High-Value Customers: A & B spent more and visited often.
- Ramen Dominance: The most popular dish overall.
- Membership Impact: A benefited more from the double-points promo.

## Recommendation
Takemoto’s restaurant should focus on promoting ramen and membership benefits to high-spending customers (A & B) to boost loyalty and sales. 
Similarly, offer targeted sushi promotions to increase point redemption and engagement, especially for customer C.



•	Loyalty Potential: B could be incentivized to order more post-signup.


-- Database: order_data
Create database order_data;

-- Create table 
CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(50),
    segment VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(10,2),
    profit DECIMAL(10,2)
);


select * from df_orders;

-------------------------------------------------------
-- find top 10 highest revenue generating products 
select product_id,sum(sale_price) as sales
from df_orders
group by product_id 
order by sum(sale_price) desc
limit 10;

-- find top 5 highest selling products in each region 
with cte as(
select region,product_id,sum(sale_price) as sales
from df_orders
group by region,product_id 
)
select * from (
select *,
        row_number() over(partition by region order by sales desc) as rank_ 
from cte)
where rank_<=5;

-- find month over month growth comparision for 2022 and 2023 sales eg : jan  2022 vs jan 2023
with cte as(
select distinct extract(year from order_date)as order_year,extract(month from order_date) as order_month,sum(sale_price) as sales
from df_orders
group by order_year,order_month
--order by order_year,order_month
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- for each category which month had highest sales 
WITH cte AS (
    SELECT 
        category,
        TO_CHAR(order_date, 'YYYYMM') AS order_year_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, order_year_month
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rank_
    FROM cte
) a
WHERE rank_ = 1;

--which sub category had highest growth by profit in 2023 compare to 2022
with cte as(
select sub_category, extract(year from order_date)as order_year,sum(sale_price) as sales
from df_orders
group by sub_category,order_year
--order by order_year,order_month
)
,cte2 as(
SELECT 
   sub_category,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY sub_category
ORDER BY sub_category
)
select *,
        round((sales_2023 - sales_2022)*100/sales_2022,2) as growth_profit
from cte2
order by growth_profit desc
limit 1;

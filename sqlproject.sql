use electronics;
SELECT * FROM electronic.product;
-- TOP 5 BEST SELLING PRODUCTS--  
select product.Product_Name,
round(sum(((replace(product.Unit_Price_USD,"$"," ")) - (replace(product.Unit_Cost_USD,"$", " " )))*sales.Quantity),2) as profit
from product   
inner join  sales on product.Product_Key = sales.Product_Key 
group by product.product_name
order by profit desc
limit 5;
-- TOP 3 BRANDS-- 
select product.Brand,
round(sum(((replace(product.Unit_Price_USD,"$"," ")) - (replace(product.Unit_Cost_USD,"$", " " )))*sales.Quantity),2) as profit
from product   
join  sales on product.Product_Key = sales.Product_Key 
group by product.brand
order by profit desc
limit 3;
-- TOP CATEGORY ACCORDING TO SALE AND PROFIT -- 
select product.Category,
round(sum(((replace(Unit_Price_USD,"$"," ")) - (replace(Unit_Cost_USD,"$", " " )))*sales.Quantity),2) as profit,
round(sum((replace(product.Unit_Price_USD,"$"," "))*sales.Quantity),2) as sales
from product   
join  sales on product.Product_Key = sales.Product_Key 
group by product.category
order by sales desc
limit 5;
-- TOP STORE ACCORDING TO COUNTRY AND SALES-- 
select store.Store_Key, store.Country,
round(sum(((replace(Unit_Price_USD,"$"," ")) - (replace(Unit_Cost_USD,"$", " " )))*sales.Quantity),2)as profit ,
round(sum(((replace(product.Unit_Price_USD,"$"," ")))*sales.Quantity),2) as sales
 from  product 
inner join sales on product.Product_key=sales.Product_Key
inner join store  on store.store_key=sales.store_key 
group by store.store_key,store.country
order by profit desc  
limit 5;
SELECT * FROM electronics.product;
-- FIND THE PRODUCTS WHICH CUSTOMER DONOT PURCHASED -- 
 use electronics;
 select c.customers_key, c.name, s.customer_key from customers c
left join sales s on c.customers_key = s.customer_key
where s.customer_Key is  null;
-- find top 5 customer by sales
 SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
 select customers.Name,customers.customers_key,
 round(sum(((replace(product.Unit_Price_USD,"$"," ")) - (replace(product.Unit_Cost_USD,"$", " " )))*sales.Quantity),2) as profit
from customers
inner join sales on customers.customers_Key = sales.customer_Key
inner join product on product.Product_Key = sales.Product_Key
group by sales.customer_Key
order by profit desc
limit 5;
use electronics;
-- top  5 products male and female--
SELECT * FROM electronics.customers;
 SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
WITH inventory AS (
  SELECT 
    customers.gender,product.product_name,

    ROW_NUMBER() OVER (
      PARTITION BY customers.gender 
      ORDER BY SUM(((REPLACE(Unit_Price_USD, "$", "") - REPLACE(Unit_Cost_USD, "$", "")) * sales.Quantity)) desc
    ) AS row_num,
        ROUND(SUM(((REPLACE(Unit_Price_USD, "$", "") - REPLACE(Unit_Cost_USD, "$", "")) * sales.Quantity)), 2) AS profit
  FROM customers
  INNER JOIN sales ON customers.customers_key = sales.customer_key
  INNER JOIN product ON sales.product_key = product.product_key
  GROUP BY customers.gender, customers.customers_key
)
SELECT * 
FROM inventory 
WHERE 
  row_num <= 5;
;
-- top 5 customer according to country --
WITH inventory AS (
  SELECT 
    customers.name,customers.country,
   ROW_NUMBER() OVER (
      PARTITION BY customers.country
      ORDER BY SUM(((REPLACE(Unit_Price_USD, "$", "") - REPLACE(Unit_Cost_USD, "$", "")) * sales.Quantity)) desc
    ) AS row_num,
        ROUND(SUM(((REPLACE(Unit_Price_USD, "$", "") - REPLACE(Unit_Cost_USD, "$", "")) * sales.Quantity)), 2) AS profit
  FROM customers
  INNER JOIN sales ON customers.customers_key = sales.customer_key
  INNER JOIN product ON sales.product_key = product.product_key
  GROUP BY customers.country, customers.customers_key
)
SELECT * 
FROM inventory 
WHERE 
  row_num <= 5;
;
-- top 5 customer according to country --
use electronics;
WITH inventory AS (
  SELECT 
    customers.name,customers.country,
   ROW_NUMBER() OVER (
      PARTITION BY customers.country
      ORDER BY SUM(((REPLACE(Unit_Price_USD, "$", "") - REPLACE(Unit_Cost_USD, "$", "")) * sales.Quantity)) desc
    ) AS row_num,
        ROUND(SUM(((REPLACE(Unit_Price_USD, "$", "") - REPLACE(Unit_Cost_USD, "$", "")) * sales.Quantity)), 2) AS profit
  FROM customers
  INNER JOIN sales ON customers.customers_key = sales.customer_key
  INNER JOIN product ON sales.product_key = product.product_key
  GROUP BY customers.country, customers.customers_key
)
SELECT * 
FROM inventory 
WHERE 
  row_num <= 5;
-- TOP PRODUCT FOR EVERY MONTH BY SALES--
select count(*)from sales; 
with inventory AS (
  SELECT 
    monthname(order_date) as order_month,product_name,round(sum((replace(product.Unit_Price_USD,"$"," "))*sales.Quantity),2) as saless,
   ROW_NUMBER() OVER (
      PARTITION BY monthname(order_date)
      ORDER BY  round(sum((replace(product.Unit_Price_USD,"$"," "))*sales.Quantity),2) desc
    ) row_num,
       round(sum((replace(product.Unit_Price_USD,"$"," "))*sales.Quantity),2) as sales
  FROM product
  INNER JOIN sales ON product.product_key = sales.product_key
  GROUP BY monthname(order_date), product.product_key
)
SELECT * 
FROM inventory 
WHERE 
  row_num <=5;
-- TOP PRODUCT AGE GROUP WISE --
WITH customerAgeGroup AS (
    SELECT 
        c.customers_key,  -- Added to avoid aggregation issues
        ROUND(DATEDIFF("2020-01-01", c.birthday) / 365, 0) AS Age,
        CASE
            WHEN (DATEDIFF("2020-01-01", c.birthday) / 365) > 17 
                 AND (DATEDIFF("2020-01-01", c.birthday) / 365) < 31 THEN 'A'
            WHEN (DATEDIFF("2020-01-01", c.birthday) / 365) > 30 
                 AND (DATEDIFF("2020-01-01", c.birthday) / 365) < 50 THEN 'B'
            ELSE 'C'
        END AS AgeGroup,
        ROUND(SUM(CAST(REPLACE(p.Unit_Price_USD, '$', '') AS DECIMAL) * s.Quantity), 2) AS sales,
        ROW_NUMBER() OVER (
            PARTITION BY 
                CASE
                    WHEN (DATEDIFF("2020-01-01", c.birthday) / 365) > 17 
                         AND (DATEDIFF("2020-01-01", c.birthday) / 365) < 31 THEN 'A'
                    WHEN (DATEDIFF("2020-01-01", c.birthday) / 365) > 30 
                         AND (DATEDIFF("2020-01-01", c.birthday) / 365) < 50 THEN 'B'
                    ELSE 'C'
                END
            ORDER BY 
                ROUND(SUM(CAST(REPLACE(p.Unit_Price_USD, '$', '') AS DECIMAL) * s.Quantity), 2) DESC
        ) AS row_num
    FROM customers c  
    JOIN sales s ON c.customers_key = s.customer_key
    INNER JOIN product p ON p.product_key = s.product_key
    GROUP BY c.customers_key, AgeGroup
)
SELECT * FROM customerAgeGroup where row_num <= 5;
  


     
             
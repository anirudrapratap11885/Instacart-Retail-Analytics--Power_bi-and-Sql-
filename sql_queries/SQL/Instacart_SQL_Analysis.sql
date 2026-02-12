--use InstacartDB;

--Analysis
-------------------------------------------------------------------------------------------------------------------------------
/*--Total number of orders and total number of unique customers

select count(order_id) as orders,count(distinct user_id) as customers_count from orders;

--------------------------------------------------------------------------------------------------------------------------------------------

--Average number of orders per customer


with order_count_by_customer as(
 select user_id as customers,count(order_id) as order_count from orders
 group by user_id
)
SELECT AVG(order_count) AS avg_orders_per_customer
FROM order_count_by_customer;

-------------------------------------------------------------------------------------------------------------------------------------


--Top 10 customers by total number of orders



select  Top 10  user_id as customers ,count(*) order_count from orders
group by user_id order by order_count desc;

ALTER TABLE order_products__prior
ADD CONSTRAINT pk_op_prior
PRIMARY KEY (order_id, product_id);

--gives the details of the table
EXEC sp_help order_products__prior;*/



--------------------------------------------------------------------------------------------------------------------------------------



/*Top 10 products by total number of times they were ordered


select Top 10  p.product_id products,p.product_name as product_name,count(o.order_id) order_count
from products p inner join order_products__prior as o on p.product_id=o.product_id
group by p.product_id,p.product_name order by order_count desc ;*/


-------------------------------------------------------------------------------------------------------------------------------------------



--top 10 reorder product


/*SELECT TOP 10
       p.product_id,
       p.product_name,
       SUM(CAST(o.reordered AS INT)) * 1.0 / COUNT(o.order_id) AS reorder_rate
FROM order_products__prior o
JOIN products p
     ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY reorder_rate DESC;*/


---------------------------------------------------------------------------------------------------------------------------------------------------------



/*Top 10 customers by reorder rate

SELECT TOP 10
       o.user_id,
       SUM(CAST(op.reordered AS INT)) * 1.0 / COUNT(*) AS reorder_rate
FROM orders o
JOIN order_products__prior op
     ON o.order_id = op.order_id
GROUP BY o.user_id
ORDER BY reorder_rate DESC;*/





-----------------------------------------------------------------------------------------------------------------------------------------


/*👉 Top 10 customers by BOTH reorder rate and total items purchased

select TOp 10  o.user_id as customer ,count(*) product_purchased , SUM(cast(reordered as int)) * 1.0 / COUNT(*) as reorder_rate 
from orders as o join order_products__prior as p on o.order_id=p.order_id
group by o.user_id order by product_purchased desc ,reorder_rate desc;*/


--------------------------------------------------------------------------------------------------------------------------------------------

/*How many customers placed more than 5 orders?

select count(t.user_id) as customer_count from 
(select user_id,count(order_id) as order_count  from orders
group by user_id
having count(order_id)>5) as t

*/

--in %

/*
SELECT 
    CAST(
        COUNT(CASE WHEN order_count > 5 THEN 1 END) * 100.0 
        / COUNT(*) 
        AS DECIMAL(5,0)
    ) AS percent_customers_5plus_orders
FROM (
    SELECT user_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY user_id
) t;*/



------------------------------------------------------------------------------------------------------------------------------------------


--On which day of the week do customers place the most orders?

/*select case
          when order_dow=0 then 'sunday'
          when order_dow=1 then 'Monday'
          when order_dow=2 then 'Tuesday'
          when order_dow=3 then 'Wednesday'
          when order_dow=4 then 'Thursday'
          when order_dow=5 then 'Friday'
          Else 'Saturday'
          end as Week_day

          ,count(order_id) no_of_orders from orders
group by order_dow order by no_of_orders desc;*/


-----------------------------------------------------------------------------------------------------------------------------------------


--At what hour of the day do customers place the most orders?

/*select order_hour_of_day,count(*) no_of_orders from orders
group by order_hour_of_day order by no_of_orders desc;
*/


-------------------------------------------------------------------------------------------------------------------------------------------------

--Overall Average basket size


/*
with order_product_count as (
    select
        order_id,
        count(*) AS products_per_order
    from order_products__prior
    group by order_id
)

select
    cast(AVG(products_per_order * 1.0) as decimal(5,2)) 
        as avg_basket_size
from order_product_count;
*/



--------------------------------------------------------------------------------------------------------------------------------------


----Average basket size per hour

/*
SELECT
    o.order_hour_of_day,
    AVG(p.products_in_order * 1.0) AS avg_products_per_order
FROM orders o
JOIN (
    SELECT
        order_id,
        COUNT(*) AS products_in_order
    FROM order_products__prior
    GROUP BY order_id
) p
ON o.order_id = p.order_id
GROUP BY o.order_hour_of_day
ORDER BY avg_products_per_order DESC;*/



--------------------------------------------------------------------------------------------------------------------------------------------------------




----Average Basket Size by Day of Week

/*
with order_product_count as (
    select
        order_id,
        count(*) AS products_per_order
    from order_products__prior
    group by order_id
)

select
    o.order_dow,
    cast(avg(opc.products_per_order * 1.0) as decimal(5,2)) 
        as avg_basket_size
from order_product_count opc
join  orders o
    on opc.order_id = o.order_id
group by o.order_dow
order by o.order_dow;*/





------------------------------------------------------------------------------------------------------------------------------------------------------
--order count and reorder_rate by department

/*select  
        d.department_id as department_id,
        d.department as Name_of_department,
        count(*) as total_order,
       cast(sum(case
               when o.reordered=1 then 1 
               else 0
               end )*1.0/count(*) as decimal(5,2)) as reorder_rate
        from departments d join products p 
        on d.department_id=p.department_id
        join order_products__prior o 
        on p.product_id=o.product_id
group by d.department_id,d.department
order by  reorder_rate desc,total_order desc;
*/


--------------------------------------------------------------------------------------------------------------------------------------------------------------



--Order Buckets (1, 2–5, 6–10, 10+)

/*WITH customer_orders AS (
    SELECT 
        user_id,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY user_id
)

SELECT
    CASE
        WHEN order_count = 1 THEN '1 Order'
        WHEN order_count BETWEEN 2 AND 5 THEN '2–5 Orders'
        WHEN order_count BETWEEN 6 AND 10 THEN '6–10 Orders'
        ELSE '10+ Orders'
    END AS customer_segment,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY
    CASE
        WHEN order_count = 1 THEN '1 Order'
        WHEN order_count BETWEEN 2 AND 5 THEN '2–5 Orders'
        WHEN order_count BETWEEN 6 AND 10 THEN '6–10 Orders'
        ELSE '10+ Orders'
    END
ORDER BY customer_count DESC;*/


--------------------------------------------------------------------------------------------------------------------------------------------------------------


--Power Users vs Casual Users



/*WITH customer_orders AS (
    SELECT 
        user_id,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY user_id
)

SELECT
    CASE
        WHEN order_count > 5 THEN 'Power User'
        ELSE 'Casual User'
    END AS user_type,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY
    CASE
        WHEN order_count > 5 THEN 'Power User'
        ELSE 'Casual User'
    END;
*/


---------------------------------------------------------------------------------------------------------------------------------------------


--Top Aisles by Reorder Rate

/*SELECT
    a.aisle_id,
    a.aisle,
    COUNT(*) AS total_orders,
    CAST(
        SUM(CASE 
                WHEN op.reordered = 1 THEN 1 
                ELSE 0 
            END) * 1.0 / COUNT(*)
    AS DECIMAL(5,2)) AS reorder_rate
FROM order_products__prior op
JOIN products p
    ON op.product_id = p.product_id
JOIN aisles a
    ON p.aisle_id = a.aisle_id
GROUP BY a.aisle_id, a.aisle
ORDER BY reorder_rate DESC, total_orders DESC;*/



--------------------------------------------------------------------------------------------------------------------------------------------------------

--Top Aisles by Total Orders

/*SELECT
    a.aisle,
    COUNT(*) AS total_orders
FROM order_products__prior op
JOIN products p
    ON op.product_id = p.product_id
JOIN aisles a
    ON p.aisle_id = a.aisle_id
GROUP BY a.aisle
ORDER BY total_orders DESC;*/


--*************************************************************************************************************************************************************************************************************--

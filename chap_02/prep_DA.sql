# Preparing for Data Analysis

USE sakila;

# SQL Query Structure

SELECT amount, customer_id
	FROM payment
LIMIT 1000;

-- SELECT top 1000,
-- 		customer_id, payment_id
-- 	FROM payment

# Histograms & Frequencies

SELECT rental_id, rental_date, COUNT(inventory_id) AS quantity
	FROM rental
GROUP BY 1;

SELECT first_name, last_name, COUNT(customer_id) AS customer_info
	FROM customer
GROUP BY 1;
    
-- SELECT orders, COUNT(*) AS num_customer
-- 	FROM 
-- 		(SELECT customer_id, COUNT(order_id) AS orders
-- 		 FROM
-- 		 GROUP BY 1
-- 		) AS a
-- 	GROYP BY 1
-- ;

####
-- SELECT LOG() as bin,
-- 		COUNT(cus_id) as cust
-- 	FROM sales
-- GROUP BY 1;
####

# n-Tiles
# window function syntax as follow:

-- function[SUM, COUNT, AVG, MIN, MAX](field_name) OVER (PARITITON BY field_name
-- 							ORDER BY field_name);

#n-tile procedure:
-- NTILE(num_bins) OVER (PARTITION BY...ORDER BY...)

-- SELECT NTILE,
-- 		MIN() AS lower_bound,
--         MAX() AS upper_bound,
--         COUNT(order_id) AS orders
-- 	FROM
-- 		(SELECT customer_id, order_id, arder_amount,
--         NTILE(10) OVER (ORDER BY order_amount) AS ntile
--         FROM orders
--         )
-- GROUP BY 1
-- ;

# percent_rank procedure:
-- PERCENT_RANK() OVER (PARTITION BY... ORDER BY...)

# Detecting Duplicates
-- checking for duplicates:
SELECT customer_id, first_name, last_name
	FROM customer
GROUP BY 1, 2, 3;


SELECT COUNT(*)
	FROM 
		(SELECT customer_id, first_name, last_name
			FROM customer
		GROUP BY 1, 2, 3
        ) AS cust_all
WHERE store_id > 1;


-- SELECT records, COUNT(*)
-- 	FROM
-- 		(SELECT column_a, column_a, column_a..., COUNT(*) AS records
-- 			FROM
-- 		GROUP BY 1, 2, 3...
--         ) AS a
-- WHERE records > 1
-- 	GROUP BY 1


-- SELECT column_a, column_a, column_a..., COUNT(*) AS records
-- 	FROM
-- GROUP BY 1, 2, 3...
-- HAVING COUNT(*) >1;

# Deduplicatio with GROUP BY & DISTINCT

SELECT c.customer_id, c.first_name, c.last_name
	FROM customer AS c
    INNER JOIN payment AS p
		ON P.customer_id = p.customer_id;

SELECT DISTINCT c.customer_id, c.first_name, c.last_name
	FROM customer AS c
    INNER JOIN payment AS p
		ON P.customer_id = p.customer_id;


SELECT customer_id,
		MIN(amount) AS first_transaction_date,
        MAX(amount) AS last_transaction_date,
        COUNT(amount) AS total_amount
	FROM payment
GROUP BY customer_id;


# Preparing: Data Cleaning

# Cleanining data with CASE transformations

-- SELECT rating,
-- 		CASE WHEN rating  = 'PG-13' THEN 'Available'
--         CASE WHEN rating  = 'NC-17' THEN 'Scarse'
--         CASE WHEN rating  = 'R' THEN 'Non-Available'
-- 		ELSE rating
-- 	END AS rating_options
-- 	FROM film;
	
# Type Conversion & Casting

-- cast(1234 AS VARCHAR)

-- CASE order_items WEHN <= 3 THEN order_items::VARCHAR
-- 	ELSE
-- END

-- SELECT REPLACE('$19.99', '$', '');


# Dealing with Nulls: COALESCE, NULLIF, nvl Functions

-- CASE WHEN num_order IS NULL 
-- 	THEN 0 
-- 		ELSE num_order 
-- END

-- COALESCE(num_order, 0)

-- NULLIF(6, 7)

-- NULLIF(date, '1970-01-01')

# Missing Data









###########


-- DROP table if exists public.date_dim;

-- CREATE table public.date_dim
-- AS
-- 	SELECT date::date
-- 			,to_char(date,'yyyymmdd')::int as date_key
-- 			,date_part('day',date)::int as day_of_month
-- 			,date_part('doy',date)::int as day_of_year
-- 			,date_part('dow',date)::int as day_of_week
-- 			,trim(to_char(date, 'Day')) as day_name
-- 			,trim(to_char(date, 'Dy')) as day_short_name
-- 			,date_part('week',date)::int as week_number
-- 			,to_char(date,'W')::int as week_of_month
-- 			,date_trunc('week',date)::date as week
-- 			,date_part('month',date)::int as month_number
-- 			,trim(to_char(date, 'Month')) as month_name
-- 			,trim(to_char(date, 'Mon')) as month_short_name
-- 			,date_trunc('month',date)::date as first_day_of_month
-- 			,(date_trunc('month',date) + interval '1 month' - interval '1 day')::date as last_day_of_month
-- 			,date_part('quarter',date)::int as quarter_number
-- 			,trim('Q' || date_part('quarter',date)::int) as quarter_name
-- 			,date_trunc('quarter',date)::date as first_day_of_quarter
-- 			,(date_trunc('quarter',date) + interval '3 months' - interval '1 day')::date as last_day_of_quarter
-- 			,date_part('year',date)::int as year 
-- 			,date_part('decade',date)::int * 10 as decade
-- 			,date_part('century',date)::int as centurys
-- FROM generate_series('1770-01-01'::date, '2030-12-31'::date, '1 day') as date
-- ;


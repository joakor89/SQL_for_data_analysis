# Time Series Analysis

# Date, Datetime & Time Manipulations

# Time Zone Conventions

SELECT '2020-09-01 00:00:00 -0' AT TIME ZONE 'PST';

SELECT CONVERT_TIMESZONE('pst', '2020-09-01 00:00:00 -0');

# Date & Timestamp Format Conversions

SELECT current_date;

current_timestamp
localtimestamp
get_date()
now()

date_trunc(text, timestamp)

SELECT date_trunc('month', '2020-10-04 12:33:35', '%Y-%m-01') AS date_trunc;

SELECT DATE_PART('day', current_timestamp);
SELECT DATE_PART('month', current_timestamp);
SELECT DATE_PART('hour', current_timestamp);

SELECT EXTRACT('day' FROM current_timestamp);
SELECT EXTRACT('hour' FROM current_timestamp);

SELECT DATE_PART('day', interval '30 days');

SELECT EXTRACT('day' FROM interval '30 days');
SELECT EXTRACT('day' FROM interval '3 month');

SELECT TO_CHAR(current_timestamp, 'Day');
SELECT TO_CHAR(current_timestamp, 'Month');

SELECT DATE '2020-09-01' + TIME '03:00:00' AS TIMESTAMP;

SELECT MAKE_DATE(2020,09,01);

SELECT TO_DATE(CONCAT(2020, '-', 09, '-',01) AS DATE);

# Date Math

SELECT DATE(''2020-06-30) - DATE('2020-05-31') AS DATE;
SELECT DATE('2020-05-31') - DATE('2020-06-30') AS DAYS;

DATEDIFF(INTERVAL_NAME, START_TIMESTAMP, END_TIMESTAMP)
SELECT DATEDIFF('day', date('2020-05-31'), date('20202-06-30')) AS DAYS;

SELECT DATEDIFF('month',
				DATE('2020-01-01'),
                DATE('2020-06-30')
                ) AS months;

SELECT AGE(DATE('2020-06-30'), DATE('2020-01-01'));
SELECT DATE_PART('month', age('2020-06-30', '2020-01-01')) AS months;

# Time Math

SELECT TIME '05:00' + INTERVAL '3 hours' AS new_time;

SELECT TIME '05:00' - INTERVAL '3 hours' AS new_time;

SELECT TIME '05:00' * 2  AS time_multiplied;alter

# The Retail Sales Data Set

-- The information can be retrieved from: (https://www.census.gov/retail/index.html#mrts)

# Trending The Data

# Simple Trends
SELECT sales_month,
		sales
	FROM retail_sales
WHERE kind_of_business = 'Retail and food services sales, total'
ORDER BY 1;

SELECT date_part('year',sales_month) AS sales_year,
		sum(sales) AS sales
	FROM retail_sales
WHERE kind_of_business = 'Retail and food services sales, total'
GROUP BY 1
ORDER BY 1;

# Comparing Components

SELECT date_part('year',sales_month) AS sales_year,
		kind_of_business, 
		sum(sales) AS sales
	FROM retail_sales
WHERE kind_of_business IN ('Book stores','Sporting goods stores','Hobby, toy, and game stores')
GROUP BY 1,2
ORDER BY 1,2;

SELECT sales_month
,kind_of_business
,sales
FROM retail_sales
WHERE kind_of_business IN ('Men''s clothing stores','Women''s clothing stores')
ORDER BY 1,2;

SELECT date_part('year',sales_month) AS sales_year
,kind_of_business
,sum(sales) AS sales
FROM retail_sales
WHERE kind_of_business IN ('Men''s clothing stores','Women''s clothing stores')
GROUP BY 1,2;

SELECT date_part('year',sales_month) AS sales_year,
		sum(CASE WHEN kind_of_business = 'Women''s clothing stores' THEN sales END) AS womens_sales, 
        sum(CASE WHEN kind_of_business = 'Men''s clothing stores' THEN sales END) AS mens_sales
	FROM retail_sales
WHERE kind_of_business IN ('Men''s clothing stores','Women''s clothing stores')
GROUP BY 1
ORDER BY 1;

SELECT sales_year
,womens_sales - mens_sales AS womens_minus_mens
,mens_sales - womens_sales AS mens_minus_womens
FROM
(
        SELECT date_part('year',sales_month) AS sales_year,
        sum(CASE WHEN kind_of_business = 'Women''s clothing stores' THEN sales END) AS womens_sales,
        sum(CASE WHEN kind_of_business = 'Men''s clothing stores' THEN sales END) AS mens_sales
        FROM retail_sales
        WHERE kind_of_business IN ('Men''s clothing stores','Women''s clothing stores')
        and sales_month <= '2019-12-01'
        GROUP BY 1
) AS a
ORDER BY 1;

SELECT date_part('year',sales_month) AS sales_year,
sum(CASE WHEN kind_of_business = 'Women''s clothing stores' THEN sales END) 
 - sum(CASE WHEN kind_of_business = 'Men''s clothing stores' THEN sales END) AS womens_minus_mens
FROM retail_sales
WHERE kind_of_business IN ('Men''s clothing stores'
 ,'Women''s clothing stores')
AND sales_month <= '2019-12-01'
GROUP BY 1
ORDER BY 1;

SELECT sales_year,
		womens_sales / mens_sales AS womens_times_of_mens
	FROM
		(
        SELECT date_part('year',sales_month) AS sales_year
        ,sum(CASE WHEN kind_of_business = 'Women''s clothing stores' THEN sales END) AS womens_sales
        ,sum(CASE WHEN kind_of_business = 'Men''s clothing stores' THEN sales END) AS mens_sales
        FROM retail_sales
        WHERE kind_of_business IN ('Men''s clothing stores','Women''s clothing stores')
        AND sales_month <= '2019-12-01'
        GROUP BY 1
		) AS a
ORDER BY 1;

SELECT sales_year,
		(womens_sales / mens_sales - 1) * 100 AS womens_pct_of_mens
	FROM
		(
        SELECT date_part('year',sales_month) AS sales_year,
        sum(CASE WHEN kind_of_business = 'Women''s clothing stores' 
                  THEN sales 
                  END) as womens_sales,
                  sum(CASE WHEN kind_of_business = 'Men''s clothing stores' 
                  THEN sales 
                  END) AS mens_sales
        FROM retail_sales
        WHERE kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
        and sales_month <= '2019-12-01'
        GROUP BY 1
		) AS a
ORDER BY 1;

# Percent of Total Calculations

SELECT sales_month,
		kind_of_business,
        sales * 100 / total_sales AS pct_total_sales
	FROM
		(
        SELECT a.sales_month
        ,a.kind_of_business
        ,a.sales
        ,sum(b.sales) AS total_sales
        FROM retail_sales a
			JOIN retail_sales b ON a.sales_month = b.sales_month
        AND b.kind_of_business IN ('Men''s clothing stores'
         ,'Women''s clothing stores')
        WHERE a.kind_of_business IN ('Men''s clothing stores','Women''s clothing stores')
        GROUP BY 1,2,3
		) AS aa
ORDER BY 1,2;

SELECT sales_month,
		kind_of_business,
        sales,
        sum(sales) OVER (PARTITION BY sales_month) AS total_sales,
        sales * 100 / sum(sales) OVER (PARTITION BY sales_month) AS pct_total
	FROM retail_sales 
WHERE kind_of_business IN ('Men''s clothing stores','Women''s clothing stores')
ORDER BY 1;

SELECT sales_month,
		kind_of_business,
		sales * 100 / yearly_sales AS pct_yearly
	FROM
		(
        SELECT a.sales_month
        ,a.kind_of_business
        ,a.sales
        ,sum(b.sales) AS yearly_sales
        FROM retail_sales a
			JOIN retail_sales b ON date_part('year',a.sales_month) = date_part('year',b.sales_month)
        AND a.kind_of_business = b.kind_of_business
        AND b.kind_of_business IN ('Men''s clothing stores','Women''s clothing stores')
        WHERE a.kind_of_business IN ('Men''s clothing stores','Women''s clothing stores')
        GROUP BY 1,2,3
		) AS aa
ORDER BY 1,2;

SELECT sales_month, kind_of_business, sales,
		sum(sales) over (PARTITION BY date_part('year',sales_month), kind_of_business) as yearly_sales,
        sales * 100 / sum(sales) over (PARTITION BY date_part('year',sales_month), kind_of_business) as pct_yearly
	FROM retail_sales 
WHERE kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
ORDER BY 1,2;

SELECT sales_year, sales,
		first_value(sales) OVER (order by sales_year) AS index_sales
	FROM
		(
    SELECT date_part('year',sales_month) AS sales_year
    ,sum(sales) as sales
    FROM retail_sales
    WHERE kind_of_business = 'Women''s clothing stores'
    GROUP BY 1
	) AS a;

SELECT sales_year, sales,
		(sales / index_sales - 1) * 100 AS pct_from_index
	FROM
		(
        SELECT date_part('year',aa.sales_month) AS sales_year
        ,bb.index_sales
        ,sum(aa.sales) AS sales
        FROM retail_sales aa
        JOIN 
        (
                SELECT first_year, sum(a.sales) AS index_sales
                FROM retail_sales a
                JOIN 
                (
                        SELECT min(date_part('year',sales_month)) AS first_year
                        FROM retail_sales
                        WHERE kind_of_business = 'Women''s clothing stores'
                ) b on date_part('year',a.sales_month) = b.first_year 
                WHERE a.kind_of_business = 'Women''s clothing stores'
                GROUP BY 1
        ) bb on 1 = 1
        WHERE aa.kind_of_business = 'Women''s clothing stores'
        GROUP BY 1,2
) AS aaa;

SELECT sales_year, kind_of_business, sales,
		(sales / first_value(sales) over (PARTITION BY kind_of_business order by sales_year) - 1) * 100 AS pct_from_index
	FROM
		(
        SELECT date_part('year',sales_month) AS sales_year
        ,kind_of_business
        ,sum(sales) AS sales
        FROM retail_sales
        WHERE kind_of_business IN ('Men''s clothing stores','Women''s clothing stores')  AND sales_month <= '2019-12-31'
GROUP BY 1,2
		) AS a;

# Rolling Time Windows

# Calculating Rolling Time Windows
SELECT a.sales_month, a.sales, 
		b.sales_month AS rolling_sales_month,
        b.sales AS rolling_sales
	FROM retail_sales a
		JOIN retail_sales b ON a.kind_of_business = b.kind_of_business 
			AND b.sales_month BETWEEN a.sales_month - INTERVAL '11 months' 
			AND a.sales_month
			AND b.kind_of_business = 'Women''s clothing stores'
WHERE a.kind_of_business = 'Women''s clothing stores'
	AND a.sales_month = '2019-12-01';

SELECT a.sales_month,
		a.sales,
        AVG(b.sales) AS moving_avg,
        COUNT(b.sales) AS records_count
	FROM retail_sales AS a
		JOIN retail_sales AS b ON a.kind_of_business = b.kind_of_business 
			AND b.sales_month BETWEEN a.sales_month - INTERVAL '11 months' 
			AND a.sales_month
			AND b.kind_of_business = 'Women''s clothing stores'
WHERE a.kind_of_business = 'Women''s clothing stores'
	AND a.sales_month >= '1993-01-01'
GROUP BY 1,2
ORDER BY 1
;

SELECT sales_month,
		AVG(sales) OVER (ORDER BY sales_month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS moving_avg,
        COUNT(sales) OVER (ORDER BY sales_month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS records_count
	FROM retail_sales
WHERE kind_of_business = 'Women''s clothing stores';

# Rolling Time Windows with Sparse Data
SELECT a.date, b.sales_month, b.sales
	FROM date_dim a
		JOIN 
			(
        SELECT sales_month, sales
        FROM retail_sales 
        WHERE kind_of_business = 'Women''s clothing stores' 
        AND date_part('month',sales_month) IN (1,7) -- here we're artificially creating sparse data by limiting the months returned
			) b on b.sales_month BETWEEN a.DATE - INTERVAL '11 months' AND a.DATE
WHERE a.DATE = a.first_day_of_month AND a.DATE BETWEEN '1993-01-01' AND '2020-12-01'
ORDER BY 1,2;

SELECT a.DATE,
		AVG(b.sales) AS moving_avg,
		COUNT(b.sales) AS records
	FROM date_dim a
		JOIN 
			(
        SELECT sales_month, sales
        FROM retail_sales 
        WHERE kind_of_business = 'Women''s clothing stores' AND date_part('month',sales_month) in (1,7)
			) b ON b.sales_month BETWEEN a.DATE - INTERVAL '11 months' AND a.DATE
WHERE a.date = a.first_day_of_month AND a.DATE BETWEEN '1993-01-01' AND '2020-12-01'
GROUP BY 1
ORDER BY 1;

SELECT a.sales_month,
		AVG(b.sales) AS moving_avg
	FROM
		(
        SELECT DISTINCT sales_month
        FROM retail_sales
        WHERE sales_month BETWEEN '1993-01-01' AND '2020-12-01'
		) AS a
JOIN retail_sales b ON b.sales_month BETWEEN a.sales_month - INTERVAL '11 months' AND a.sales_month
AND b.kind_of_business = 'Women''s clothing stores' 
GROUP BY 1;

-- Calculating cumulative values
SELECT sales_month,
		sales,
        SUM(sales) OVER (PARTITION BY date_part('year',sales_month) ORDER BY sales_month) AS sales_ytd
FROM retail_sales
WHERE kind_of_business = 'Women''s clothing stores';

SELECT a.sales_month, a.sales,
		SUM(b.sales) AS sales_ytd
	FROM retail_sales a
		JOIN retail_sales b ON date_part('year',a.sales_month) = date_part('year',b.sales_month)
 and b.sales_month <= a.sales_month
 and b.kind_of_business = 'Women''s clothing stores'
WHERE a.kind_of_business = 'Women''s clothing stores'
GROUP BY 1,2
;

# Analyzing with Seasonality

# Period over Period Comparisons
SELECT kind_of_business, sales_month, sales,
		LAG(sales_month) OVER (PARTITION BY kind_of_business ORDER BY sales_month) AS prev_month,
        LAG(sales) OVER (PARTITION BY kind_of_business ORDER BY sales_month) AS prev_month_sales
	FROM retail_sales
WHERE kind_of_business = 'Book stores';

SELECT kind_of_business, sales_month, sales,
		(sales / LAG(sales) OVER (PARTITION BY kind_of_business ORDER BY sales_month) - 1) * 100 AS pct_growth_from_previous
	FROM retail_sales
WHERE kind_of_business = 'Book stores';

SELECT sales_year, yearly_sales,
		LAG(yearly_sales) OVER (ORDER BY sales_year) AS prev_year_sales,
        (yearly_sales / LAG(yearly_sales) OVER (ORDER BY sales_year) -1) * 100 AS pct_growth_from_previous
FROM
(
        SELECT date_part('year',sales_month) AS sales_year,
        SUM(sales) AS yearly_sales
        FROM retail_sales
        WHERE kind_of_business = 'Book stores'
        GROUP BY 1
) AS a;

# Period over Period Comparisons - Same month vs. Last year
SELECT sales_month,
		date_part('month',sales_month)
	FROM retail_sales
WHERE kind_of_business = 'Book stores';

SELECT sales_month,
		sales,
        LAG(sales_month) OVER (PARTITION BY date_part('month',sales_month) ORDER BY sales_month) AS prev_year_month,
        LAG(sales) OVER (PARTITION BY date_part('month',sales_month) ORDER BY sales_month) AS prev_year_sales
	FROM retail_sales
WHERE kind_of_business = 'Book stores';

SELECT sales_month, sales,
		sales - LAG(sales) OVER (PARTITION BY date_part('month',sales_month) ORDER BY sales_month) AS absolute_diff,
        (sales / LAG(sales) OVER (PARTITION BY date_part('month',sales_month) ORDER BY sales_month) - 1) * 100 AS pct_diff
	FROM retail_sales
WHERE kind_of_business = 'Book stores';

SELECT date_part('month',sales_month) AS month_number,
		to_char(sales_month,'Month') AS month_name,
        MAX(CASE WHEN date_part('year',sales_month) = 1992 THEN sales END) AS sales_1992,
        MAX(CASE WHEN date_part('year',sales_month) = 1993 THEN sales END) AS sales_1993,
        MAX(CASE WHEN date_part('year',sales_month) = 1994 THEN sales END) AS sales_1994
	FROM retail_sales
WHERE kind_of_business = 'Book stores' and sales_month between '1992-01-01' and '1994-12-01'
GROUP BY 1,2;

-- Comparing to multiple prior periods
SELECT sales_month, sales,
		LAG(sales,1) OVER (PARTITION BY date_part('month',sales_month) ORDER BY sales_month) AS prev_sales_1,
        LAG(sales,2) OVER (PARTITION BY date_part('month',sales_month) ORDER BY sales_month) AS prev_sales_2,
        LAG(sales,3) OVER (PARTITION BY date_part('month',sales_month) ORDER BY sales_month) AS prev_sales_3
	FROM retail_sales
WHERE kind_of_business = 'Book stores';

SELECT sales_month, sales,
		sales / AVG(sales) OVER (PARTITION BY date_part('month',sales_month) 
				ORDER BY sales_month ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS pct_of_prev_3
	FROM retail_sales
WHERE kind_of_business = 'Book stores';



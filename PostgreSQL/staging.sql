CREATE SCHEMA staging;

-- Dimension Date
CREATE TABLE staging.dim_date(
    DATE_KEY INTEGER NOT NULL,
    DATE DATE NOT NULL,
    WEEKDAY VARCHAR(9) NOT NULL,
    WEEKDAY_NUM INTEGER NOT NULL,
    DAY_MONTH INTEGER NOT NULL,
    DAY_OF_YEAR INTEGER NOT NULL,
    WEEK_OF_YEAR INTEGER NOT NULL,
    ISO_WEEK CHAR(10) NOT NULL,
    MONTH_NUM INTEGER NOT NULL,
    MONTH_NAME VARCHAR(9) NOT NULL,
    MONTH_NAME_SHORT CHAR(3) NOT NULL,
    QUARTER INTEGER NOT NULL,
    YEAR INTEGER NOT NULL,
    FIRST_DAY_OF_MONTH DATE NOT NULL,
    LAST_DAY_OF_MONTH DATE NOT NULL,
    YYYYMM CHAR(7) NOT NULL,
    WEEKEND_INDR CHAR(10) NOT NULL
);

ALTER TABLE staging.dim_date
ADD PRIMARY KEY (date_key);


INSERT INTO staging.dim_date
SELECT TO_CHAR(datum, 'yyyymmdd')::INT AS DATE_KEY,
datum AS DATE,
TO_CHAR(datum, 'TMDay') AS WEEKDAY,
EXTRACT(ISODOW FROM datum) AS WEEKDAY_NUM,
EXTRACT(DAY FROM datum) AS DAY_MONTH,
EXTRACT(DOY FROM datum) AS DAY_OF_YEAR,
EXTRACT(WEEK FROM datum) AS WEEK_OF_YEAR,
EXTRACT(ISOYEAR FROM datum) || TO_CHAR(datum, '"-W"IW-') || EXTRACT(ISODOW FROM datum) AS ISO_WEEK,
EXTRACT(MONTH FROM datum) AS MONTH,
TO_CHAR(datum, 'TMMonth') AS MONTH_NAME,
TO_CHAR(datum, 'Mon') AS MONTH_NAME_SHORT,
EXTRACT(QUARTER FROM datum) AS QUARTER,
EXTRACT(YEAR FROM datum) AS YEAR,
datum + (1 - EXTRACT(DAY FROM datum))::INT AS FIRST_DAY_OF_MONTH,
(DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE AS LAST_DAY_OF_MONTH,
CONCAT(TO_CHAR(datum, 'yyyy'),'-',TO_CHAR(datum, 'mm')) AS MMYYYY,
CASE
   WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN 'weekend'
   ELSE 'weekday'
   END AS WEEKEND_INDR
FROM (SELECT '2021-01-01'::DATE + SEQUENCE.DAY AS datum
      FROM GENERATE_SERIES(0, 365) AS SEQUENCE (DAY)
      GROUP BY SEQUENCE.DAY) DQ
ORDER BY 1;
-- Dimension Date


-- Dimension Customer
SELECT DISTINCT(CUSTOMER_ID), GENRE, AGE, ANNUAL_INCOME, SPENDING_SCORE
INTO staging.dim_customer
FROM public.total;

ALTER TABLE staging.dim_customer
ADD PRIMARY KEY (CUSTOMER_ID);
-- Dimension Customer



-- Dimension Product
SELECT DISTINCT(MODEL), TYPE, SCREEN_SIZE
INTO staging.dim_product_temp
FROM public.total;

SELECT row_number() over (order by MODEL) as PRODUCT_ID, * 
into staging.dim_product
from staging.dim_product_temp;

ALTER TABLE staging.dim_product
ADD PRIMARY KEY (PRODUCT_ID);

DROP TABLE staging.dim_product_temp;
-- Dimension Product


-- Fact Table
CREATE TABLE IF NOT EXISTS staging.fact_sales_temp AS
SELECT dim_d.DATE_KEY, 
       dim_c.CUSTOMER_ID, 
       dim_p.PRODUCT_ID,
       d.QUANTITY,
       d.UNIT_PRICE
FROM public.total AS d
LEFT JOIN staging.dim_date AS dim_d ON d.DATE = dim_d.DATE
LEFT JOIN staging.dim_customer AS dim_c ON d.CUSTOMER_ID = dim_c.CUSTOMER_ID
LEFT JOIN staging.dim_product AS dim_p ON d.MODEL = dim_p.MODEL
AND d.TYPE = dim_p.TYPE AND d.SCREEN_SIZE = dim_p.SCREEN_SIZE;

SELECT row_number() over (order by DATE_KEY) as SALES_ID, * 
into staging.fact_sales
from staging.fact_sales_temp;

DROP TABLE staging.fact_sales_temp
-- Fact Table



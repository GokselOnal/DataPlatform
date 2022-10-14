CREATE SCHEMA core;

SELECT * 
INTO core.fact_sales
FROM staging.fact_sales;

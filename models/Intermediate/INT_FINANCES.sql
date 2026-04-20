-- models/Intermediate/INT_FINANCES.sql
{{ config(materialized='table') }}

WITH expenses_clean AS (
  SELECT
    TO_DATE("DATE")                                          AS business_date,
    LOWER(TRIM("EXPENSE_TYPE"))                              AS expense_type,
    TRY_TO_DECIMAL(TO_VARCHAR("EXPENSE_AMOUNT"), 18, 2)      AS expense_amount,
    "_FILE",
    "_LINE",
    "_FIVETRAN_SYNCED"
  FROM {{ source('google_drive', 'EXPENSES') }}
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY "_FILE", "_LINE"
    ORDER BY "_FIVETRAN_SYNCED" DESC
  ) = 1
),

orders_clean AS (
  SELECT
    TO_DATE("ORDER_AT")                                      AS business_date,
    "ORDER_ID"                                               AS order_id,
    TRY_TO_DECIMAL(TO_VARCHAR("TAX_RATE"), 8, 4)             AS tax_rate,
    TRY_TO_DECIMAL(TO_VARCHAR("SHIPPING_COST"), 18, 2)       AS shipping_cost
  FROM {{ source('web_schema', 'ORDERS') }}
),

expenses_daily AS (
  SELECT
    business_date,
    SUM(expense_amount) AS total_expense,
    SUM(CASE WHEN expense_type = 'hr' THEN expense_amount ELSE 0 END) AS hr_expense,
    SUM(CASE WHEN expense_type = 'tech tool' THEN expense_amount ELSE 0 END) AS tech_tool_expense,
    SUM(CASE WHEN expense_type = 'warehouse' THEN expense_amount ELSE 0 END) AS warehouse_expense
  FROM expenses_clean
  GROUP BY 1
),

orders_daily AS (
  SELECT
    business_date,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(shipping_cost)       AS total_shipping_cost,
    AVG(tax_rate)            AS avg_tax_rate
  FROM orders_clean
  GROUP BY 1
)

SELECT
  COALESCE(o.business_date, e.business_date) AS business_date,
  o.order_count,
  o.total_shipping_cost,
  o.avg_tax_rate,
  e.total_expense,
  e.hr_expense,
  e.tech_tool_expense,
  e.warehouse_expense
FROM orders_daily o
FULL OUTER JOIN expenses_daily e
  ON o.business_date = e.business_date

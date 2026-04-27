WITH cleaned_item_views AS (
    SELECT
        TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
        TRIM(ITEM_NAME) AS item_name,
        TRY_TO_DECIMAL(REGEXP_REPLACE(PRICE_PER_UNIT, '[^0-9.]', ''), 10, 2) AS price_per_unit,
        TRY_TO_NUMBER(REMOVE_FROM_CART_QUANTITY) AS remove_from_cart_quantity,
        TRY_TO_NUMBER(ADD_TO_CART_QUANTITY) AS add_to_cart_quantity
    FROM LOAD.WEB_SCHEMA.ITEM_VIEWS
),

cleaned_sessions AS (
    SELECT
        TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id
    FROM LOAD.WEB_SCHEMA.SESSIONS
),

cleaned_orders AS (
    SELECT
        TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
        TRIM(ORDER_ID) AS order_id,
        TRY_TO_DECIMAL(REGEXP_REPLACE(SHIPPING_COST, '[^0-9.-]', ''), 10, 2) AS shipping_cost
    FROM LOAD.WEB_SCHEMA.ORDERS
),

session_item_revenue AS (
    SELECT
        session_id,
        SUM(
            COALESCE(price_per_unit, 0) *
            GREATEST(
                COALESCE(add_to_cart_quantity, 0) - COALESCE(remove_from_cart_quantity, 0),
                0
            )
        ) AS gross_item_revenue
    FROM cleaned_item_views
    GROUP BY session_id
),

session_shipping AS (
    SELECT
        session_id,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(COALESCE(shipping_cost, 0)) AS total_shipping_cost
    FROM cleaned_orders
    GROUP BY session_id
)

SELECT
    s.session_id,
    COALESCE(sh.order_count, 0) AS order_count,
    ROUND(COALESCE(r.gross_item_revenue, 0), 2) AS gross_item_revenue,
    ROUND(COALESCE(sh.total_shipping_cost, 0), 2) AS total_shipping_cost,
    ROUND(COALESCE(r.gross_item_revenue, 0) - COALESCE(sh.total_shipping_cost, 0), 2) AS total_revenue_after_shipping
FROM cleaned_sessions s
LEFT JOIN session_item_revenue r
    ON s.session_id = r.session_id
LEFT JOIN session_shipping sh
    ON s.session_id = sh.session_id

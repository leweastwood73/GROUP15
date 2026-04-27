WITH cleaned_item_views AS (
    SELECT
        TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
        TRIM(ITEM_NAME) AS item_name,
        TRY_TO_DECIMAL(REGEXP_REPLACE(PRICE_PER_UNIT, '[^0-9.]', ''), 10, 2) AS price_per_unit,
        ITEM_VIEW_AT AS item_view_at,
        TRY_TO_NUMBER(REMOVE_FROM_CART_QUANTITY) AS remove_from_cart_quantity,
        TRY_TO_NUMBER(ADD_TO_CART_QUANTITY) AS add_to_cart_quantity
    FROM LOAD.WEB_SCHEMA.ITEM_VIEWS
),
cleaned_session_orders AS (
    SELECT
        TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
        TRY_TO_NUMBER(ORDER_COUNT) AS order_count,
        TRY_TO_DECIMAL(REGEXP_REPLACE(TOTAL_SHIPPING_COST, '[^0-9.-]', ''), 10, 2) AS total_shipping_cost
    FROM LOAD.WEB_SCHEMA.SESSIONS
),
item_rollup AS (
    SELECT
        MD5(LOWER(item_name)) AS item_id,
        item_name,
        ARRAY_AGG(DISTINCT price_per_unit) AS price_per_unit_array,
        MIN(item_view_at) AS first_item_view_at,
        MAX(item_view_at) AS last_item_view_at,
        SUM(
            COALESCE(price_per_unit, 0) *
            GREATEST(COALESCE(add_to_cart_quantity, 0) - COALESCE(remove_from_cart_quantity, 0), 0)
        ) AS item_revenue
    FROM cleaned_item_views
    GROUP BY item_name
),
item_session_map AS (
    SELECT DISTINCT session_id, item_name
    FROM cleaned_item_views
),
item_order_rollup AS (
    SELECT
        m.item_name,
        SUM(COALESCE(s.order_count, 0)) AS order_count,
        SUM(COALESCE(s.total_shipping_cost, 0)) AS total_shipping_cost
    FROM item_session_map m
    LEFT JOIN cleaned_session_orders s
        ON m.session_id = s.session_id
    GROUP BY m.item_name
)

SELECT
    r.item_id,
    r.item_name,
    r.price_per_unit_array,
    r.first_item_view_at,
    r.last_item_view_at,
    COALESCE(o.order_count, 0) AS order_count,
    COALESCE(o.total_shipping_cost, 0) AS total_shipping_cost,
    COALESCE(r.item_revenue, 0) AS item_revenue,
    COALESCE(r.item_revenue, 0) + COALESCE(o.total_shipping_cost, 0) AS total_revenue
FROM item_rollup r
LEFT JOIN item_order_rollup o
    ON r.item_name = o.item_name
ORDER BY r.item_name;

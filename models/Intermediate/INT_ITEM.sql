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

item_session_map AS (
    SELECT DISTINCT
        iv.session_id,
        iv.item_name
    FROM cleaned_item_views iv
    INNER JOIN cleaned_sessions s
        ON iv.session_id = s.session_id
),

session_item_revenue AS (
    SELECT
        iv.session_id,
        iv.item_name,
        SUM(
            COALESCE(iv.price_per_unit, 0) *
            GREATEST(
                COALESCE(iv.add_to_cart_quantity, 0) - COALESCE(iv.remove_from_cart_quantity, 0),
                0
            )
        ) AS item_revenue
    FROM cleaned_item_views iv
    GROUP BY iv.session_id, iv.item_name
),

session_gross_revenue AS (
    SELECT
        session_id,
        SUM(item_revenue) AS session_gross_revenue
    FROM session_item_revenue
    GROUP BY session_id
),

session_shipping AS (
    SELECT
        session_id,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(COALESCE(shipping_cost, 0)) AS total_shipping_cost
    FROM cleaned_orders
    GROUP BY session_id
),

item_base AS (
    SELECT
        MD5(LOWER(item_name)) AS item_id,
        item_name,
        ARRAY_AGG(DISTINCT price_per_unit) AS price_per_unit_array,
        MIN(item_view_at) AS first_item_view_at,
        MAX(item_view_at) AS last_item_view_at
    FROM cleaned_item_views
    GROUP BY item_name
),

item_revenue_rollup AS (
    SELECT
        item_name,
        SUM(item_revenue) AS gross_item_revenue
    FROM session_item_revenue
    GROUP BY item_name
),

item_order_rollup AS (
    SELECT
        m.item_name,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM item_session_map m
    LEFT JOIN cleaned_orders o
        ON m.session_id = o.session_id
    GROUP BY m.item_name
),

item_shipping_alloc AS (
    SELECT
        sir.item_name,
        SUM(
            CASE
                WHEN COALESCE(sgr.session_gross_revenue, 0) > 0
                    THEN COALESCE(ss.total_shipping_cost, 0) * (sir.item_revenue / sgr.session_gross_revenue)
                ELSE 0
            END
        ) AS shipping_cost_allocated
    FROM session_item_revenue sir
    LEFT JOIN session_gross_revenue sgr
        ON sir.session_id = sgr.session_id
    LEFT JOIN session_shipping ss
        ON sir.session_id = ss.session_id
    GROUP BY sir.item_name
)

SELECT
    b.item_id,
    b.item_name,
    b.price_per_unit_array,
    b.first_item_view_at,
    b.last_item_view_at,
    COALESCE(o.order_count, 0) AS order_count,
    COALESCE(r.gross_item_revenue, 0) AS gross_item_revenue,
    COALESCE(a.shipping_cost_allocated, 0) AS shipping_cost_allocated,
    COALESCE(r.gross_item_revenue, 0) - COALESCE(a.shipping_cost_allocated, 0) AS total_revenue_after_shipping,
    SUM(COALESCE(r.gross_item_revenue, 0) - COALESCE(a.shipping_cost_allocated, 0)) OVER () AS grand_total_revenue_after_shipping
FROM item_base b
LEFT JOIN item_revenue_rollup r
    ON b.item_name = r.item_name
LEFT JOIN item_order_rollup o
    ON b.item_name = o.item_name
LEFT JOIN item_shipping_alloc a
    ON b.item_name = a.item_name


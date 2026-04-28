WITH base_item_views AS (
    SELECT
        TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
        NULLIF(TRIM(ITEM_NAME), '') AS item_name,
        LOWER(NULLIF(TRIM(ITEM_NAME), '')) AS item_name_key,
        TRY_TO_DECIMAL(REGEXP_REPLACE(PRICE_PER_UNIT, '[^0-9.]', ''), 10, 2) AS price_per_unit,
        ITEM_VIEW_AT AS item_view_at,
        TRY_TO_NUMBER(ADD_TO_CART_QUANTITY) AS add_to_cart_quantity,
        TRY_TO_NUMBER(REMOVE_FROM_CART_QUANTITY) AS remove_from_cart_quantity
    FROM LOAD.WEB_SCHEMA.ITEM_VIEWS
),

base_sessions AS (
    SELECT
        TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
        CLIENT_ID,
        SESSION_AT,
        OS,
        IP
    FROM LOAD.WEB_SCHEMA.SESSIONS
),

item_session_rollup AS (
    SELECT
        session_id,
        item_name_key,
        MIN(item_name) AS item_name,
        ARRAY_AGG(DISTINCT price_per_unit) AS price_per_unit_array,
        MIN(item_view_at) AS first_item_view_at,
        MAX(item_view_at) AS last_item_view_at,
        SUM(
            COALESCE(price_per_unit, 0) *
            GREATEST(COALESCE(add_to_cart_quantity, 0) - COALESCE(remove_from_cart_quantity, 0), 0)
        ) AS item_revenue_in_session
    FROM base_item_views
    WHERE item_name_key IS NOT NULL
    GROUP BY session_id, item_name_key
),

session_gross_revenue AS (
    SELECT
        session_id,
        SUM(item_revenue_in_session) AS gross_revenue
    FROM item_session_rollup
    GROUP BY session_id
)

SELECT
    MD5(i.item_name_key) AS item_id,
    i.item_name,
    i.session_id,
    s.client_id,
    s.session_at,
    s.os,
    s.ip,
    i.price_per_unit_array,
    i.first_item_view_at,
    i.last_item_view_at,
    ROUND(COALESCE(i.item_revenue_in_session, 0), 2) AS item_revenue_in_session,
    ROUND(COALESCE(g.gross_revenue, 0), 2) AS session_gross_revenue
FROM item_session_rollup i
LEFT JOIN base_sessions s
    ON i.session_id = s.session_id
LEFT JOIN session_gross_revenue g
    ON i.session_id = g.session_id



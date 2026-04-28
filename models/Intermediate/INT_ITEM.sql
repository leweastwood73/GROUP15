WITH cleaned_item_views AS (
    SELECT
        TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
        TRY_TO_DECIMAL(REGEXP_REPLACE(PRICE_PER_UNIT, '[^0-9.]', ''), 10, 2) AS price_per_unit,
        TRY_TO_NUMBER(ADD_TO_CART_QUANTITY) AS add_to_cart_quantity,
        TRY_TO_NUMBER(REMOVE_FROM_CART_QUANTITY) AS remove_from_cart_quantity
    FROM LOAD.WEB_SCHEMA.ITEM_VIEWS
),
cleaned_sessions AS (
    SELECT
        TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id
    FROM LOAD.WEB_SCHEMA.SESSIONS
),
session_gross_revenue AS (
    SELECT
        session_id,
        SUM(
            COALESCE(price_per_unit, 0) *
            GREATEST(
                COALESCE(add_to_cart_quantity, 0) - COALESCE(remove_from_cart_quantity, 0),
                0
            )
        ) AS gross_revenue
    FROM cleaned_item_views
    GROUP BY session_id
)

SELECT
    s.session_id,
    ROUND(COALESCE(r.gross_revenue, 0), 2) AS gross_revenue
FROM cleaned_sessions s
LEFT JOIN session_gross_revenue r
    ON s.session_id = r.session_id
ORDER BY s.session_id;

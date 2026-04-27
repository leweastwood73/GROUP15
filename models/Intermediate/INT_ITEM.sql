WITH cleaned_item_views AS (
    SELECT
        TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
        NULLIF(TRIM(ITEM_NAME), '') AS item_name,
        LOWER(NULLIF(TRIM(ITEM_NAME), '')) AS item_name_key,
        TRY_TO_DECIMAL(REGEXP_REPLACE(PRICE_PER_UNIT, '[^0-9.]', ''), 10, 2) AS price_per_unit,
        ITEM_VIEW_AT AS item_view_at,
        TRY_TO_NUMBER(REMOVE_FROM_CART_QUANTITY) AS remove_from_cart_quantity,
        TRY_TO_NUMBER(ADD_TO_CART_QUANTITY) AS add_to_cart_quantity
    FROM LOAD.WEB_SCHEMA.ITEM_VIEWS
),

item_rollup AS (
    SELECT
        MD5(item_name_key) AS item_id,
        MIN(item_name) AS item_name,
        ARRAY_AGG(DISTINCT price_per_unit) AS price_per_unit_array,
        MIN(item_view_at) AS first_item_view_at,
        MAX(item_view_at) AS last_item_view_at,
        SUM(
            COALESCE(price_per_unit, 0) *
            GREATEST(COALESCE(add_to_cart_quantity, 0) - COALESCE(remove_from_cart_quantity, 0), 0)
        ) AS gross_item_revenue
    FROM cleaned_item_views
    WHERE item_name_key IS NOT NULL
    GROUP BY item_name_key
)

SELECT
    item_id,
    item_name,
    price_per_unit_array,
    first_item_view_at,
    last_item_view_at,
    ROUND(COALESCE(gross_item_revenue, 0), 2) AS gross_item_revenue
FROM item_rollup

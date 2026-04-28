-- models/Analytics/DIM_ITEM.sql
WITH base AS (
    SELECT
        item_id,
        NULLIF(TRIM(item_name), '') AS item_name,
        price_per_unit_array,
        first_item_view_at,
        last_item_view_at
    FROM {{ ref('INT_ITEM') }}
    WHERE item_id IS NOT NULL
      AND NULLIF(TRIM(item_name), '') IS NOT NULL
),

one_row_per_item AS (
    SELECT
        item_id,
        item_name,
        price_per_unit_array,
        first_item_view_at,
        last_item_view_at,
        ROW_NUMBER() OVER (
            PARTITION BY item_id
            ORDER BY COALESCE(last_item_view_at, first_item_view_at) DESC
        ) AS rn
    FROM base
)

SELECT
    item_id,
    item_name,
    price_per_unit_array,
    first_item_view_at,
    last_item_view_at
FROM one_row_per_item
WHERE rn = 1


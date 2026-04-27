WITH base AS (
    SELECT
        item_id,
        NULLIF(TRIM(item_name), '') AS item_name,
        price_per_unit_array,
        first_item_view_at,
        last_item_view_at,
        gross_item_revenue
    FROM {{ ref('INT_ITEM') }}
    WHERE item_id IS NOT NULL
      AND NULLIF(TRIM(item_name), '') IS NOT NULL
),

deduped AS (
    SELECT
        item_id,
        item_name,
        price_per_unit_array,
        first_item_view_at,
        last_item_view_at,
        gross_item_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY item_id
            ORDER BY COALESCE(last_item_view_at, first_item_view_at) DESC, item_name
        ) AS rn
    FROM base
)

SELECT
    item_id,
    item_name,
    price_per_unit_array,
    first_item_view_at,
    last_item_view_at,
    gross_item_revenue
FROM deduped
WHERE rn = 1

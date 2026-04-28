-- models/Analytics/DIM_ITEM.sql
SELECT
    item_id,
    item_name,
    session_id,
    client_id,
    session_at,
    os,
    ip,
    price_per_unit_array,
    first_item_view_at,
    last_item_view_at,
    item_revenue_in_session,
    session_gross_revenue,
    session_shipping_cost,
    total_profit_per_session
FROM {{ ref('INT_ITEM') }}
WHERE item_id IS NOT NULL
  AND NULLIF(TRIM(item_name), '') IS NOT NULL



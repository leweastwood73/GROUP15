SELECT
    TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
    TRIM(ITEM_NAME) AS item_name,
    TRY_TO_DECIMAL(REGEXP_REPLACE(PRICE_PER_UNIT, '[^0-9.]', ''), 10, 2) AS price_per_unit,
    ITEM_VIEW_AT AS item_view_at,
    TRY_TO_NUMBER(REMOVE_FROM_CART_QUANTITY) AS remove_from_cart_quantity,
    TRY_TO_NUMBER(ADD_TO_CART_QUANTITY) AS add_to_cart_quantity
FROM LOAD.WEB_SCHEMA.ITEM_VIEWS

SELECT
    "_fivetran_id" AS fivetran_id,
    LOWER(TRIM(PAYMENT_METHOD)) AS payment_method,
    TRIM(SHIPPING_ADDRESS) AS shipping_address,
    TRIM(ORDER_ID) AS order_id,
    CAST(TAX_RATE AS NUMBER(10,4)) AS tax_rate,
    TRIM(CLIENT_NAME) AS client_name,
    ORDER_AT AS order_at,
    TRIM(SESSION_ID) AS session_id,
    TRIM(STATE) AS state,
    TRIM(PHONE) AS phone,
    TRIM(PAYMENT_INFO) AS payment_info,
    TRY_TO_DECIMAL(REGEXP_REPLACE(SHIPPING_COST, '[^0-9.]', ''), 10, 2) AS shipping_cost,
    "_fivetran_deleted" AS fivetran_deleted,
    "_fivetran_synced" AS fivetran_synced
FROM LOAD.WEB_SCHEMA.ORDERS

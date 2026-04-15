SELECT
    _fivetran_id AS fivetran_id,
    LOWER(TRIM(PAYMENT_METHOD)) AS payment_method,
    TRIM(SHIPPING_ADDRESS) AS shipping_address,
    TRY_TO_NUMBER(REGEXP_REPLACE(ORDER_ID, '[^0-9]', '')) AS order_id,
    TRY_TO_DECIMAL(TAX_RATE, 10, 4) AS tax_rate,
    TRIM(CLIENT_NAME) AS client_name,
    TRY_TO_TIMESTAMP_NTZ(ORDER_AT) AS order_at,
    TRY_TO_NUMBER(REGEXP_REPLACE(SESSION_ID, '[^0-9]', '')) AS session_id,
    TRIM(STATE) AS state,
    TRIM(PHONE) AS phone,
    TRIM(PAYMENT_INFO) AS payment_info,
    TRY_TO_DECIMAL(REGEXP_REPLACE(SHIPPING_COST, '[^0-9.]', ''), 10, 2) AS shipping_cost,
    TRY_TO_BOOLEAN(_fivetran_deleted) AS fivetran_deleted,
    TRY_TO_TIMESTAMP_NTZ(REPLACE(_fivetran_synced, ' Z', '')) AS fivetran_synced
FROM LOAD.WEB_SCHEMA.ORDERS

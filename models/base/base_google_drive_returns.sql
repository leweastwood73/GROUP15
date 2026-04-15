SELECT
    _FILE AS file,
    _LINE AS line,
    _MODIFIED AS modified,
    _FIVETRAN_SYNCED AS fivetran_synced,
    RETURNED_AT AS returned_at,
    ORDER_ID AS order_id,
    CASE
        WHEN LOWER(IS_REFUNDED) = 'yes' THEN TRUE
        WHEN LOWER(IS_REFUNDED) = 'no' THEN FALSE
        ELSE NULL
    END AS is_refunded
FROM LOAD.GOOGLE_DRIVE.RETURNS

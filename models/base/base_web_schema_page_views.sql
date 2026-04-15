SELECT
    "_fivetran_id" AS fivetran_id,
    TRIM(PAGE_NAME) AS page_name,
    TRY_TO_TIMESTAMP_NTZ(VIEW_AT) AS view_at,
    TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
    "_fivetran_deleted" AS fivetran_deleted,
    TRY_TO_TIMESTAMP_NTZ(REPLACE("_fivetran_synced", ' Z', '')) AS fivetran_synced
FROM LOAD.WEB_SCHEMA.PAGE_VIEWS

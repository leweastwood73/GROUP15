SELECT
    TRIM(PAGE_NAME) AS page_name,
    VIEW_AT AS view_at,
    TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
    "_fivetran_deleted" AS fivetran_deleted,
    "_fivetran_synced" AS fivetran_synced
FROM LOAD.WEB_SCHEMA.PAGE_VIEWS

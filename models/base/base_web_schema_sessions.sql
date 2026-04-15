SELECT
    "_fivetran_id" AS fivetran_id,
    TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
    USER_ID,
    SESSION_START_AT,
    SESSION_END_AT,
    "_fivetran_deleted" AS fivetran_deleted,
    "_fivetran_synced" AS fivetran_synced
FROM LOAD.WEB_SCHEMA.SESSIONS

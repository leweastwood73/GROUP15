SELECT
    "_fivetran_id" AS fivetran_id,
    TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
    TRIM(USER_ID) AS user_id,
    SESSION_START_AT AS session_start_at,
    SESSION_END_AT AS session_end_at,
    "_fivetran_deleted" AS fivetran_deleted,
    "_fivetran_synced" AS fivetran_synced
FROM LOAD.WEB_SCHEMA.SESSIONS

SELECT
    CLIENT_ID AS client_id,
    TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
    LOWER(TRIM(OS)) AS os,
    TRIM(IP) AS ip,
    SESSION_AT AS session_at,
    "_fivetran_deleted" AS fivetran_deleted,
    "_fivetran_synced" AS fivetran_synced
FROM LOAD.WEB_SCHEMA.SESSIONS

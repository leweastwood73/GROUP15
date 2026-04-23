SELECT
    CLIENT_ID AS client_id,
    TRY_TO_NUMBER(REGEXP_REPLACE(TRIM(SESSION_ID), '^s', '')) AS session_id,
    LOWER(TRIM(OS)) AS os,
    TRIM(IP) AS ip,
    SESSION_AT AS session_at
FROM {{ source('web_schema', 'SESSIONS') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY SESSION_ID ORDER BY "_fivetran_synced" DESC) = 1

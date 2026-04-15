SELECT
    _FILE AS file,
    _LINE AS line,
    _MODIFIED AS modified,
    _FIVETRAN_SYNCED AS fivetran_synced,
    CAST(EMPLOYEE_ID AS NUMBER) AS employee_id,
    TRY_TO_DATE(QUIT_DATE) AS quit_date
FROM LOAD.GOOGLE_DRIVE.HR_QUITS

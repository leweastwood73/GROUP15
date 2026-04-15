SELECT
    _file,
    _line,
    _modified,
    _fivetran_synced,
    EMPLOYEE_ID,
    TRY_TO_DATE(REGEXP_REPLACE(HIRE_DATE, 'day\\s*', '', 1, 0, 'i')) AS HIRE_DATE,
    NAME,
    CITY,
    ADDRESS,
    TITLE,
    ANNUAL_SALARY
FROM LOAD.GOOGLE_DRIVE.HR_JOINS

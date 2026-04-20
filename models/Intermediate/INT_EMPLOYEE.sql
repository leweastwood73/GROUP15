with

hr_joins as (

    select
        employee_id,
        hire_date,
        name,
        city,
        address,
        title,
        annual_salary,
        _modified  as source_modified_at,
        _fivetran_synced as fivetran_synced_at
<<<<<<< HEAD
    from {{ ref('BASE_GOOGLE_DRIVE_HR_JOINS') }}
=======
    from {{ source('google_drive', 'HR_JOINS') }}
>>>>>>> e971b5470f3a9d0e9c607204be400efc2aa2d54f

),

hr_quits as (

    select
        employee_id,
        quit_date
<<<<<<< HEAD
    from {{ ref('BASE_GOOGLE_DRIVE_HR_QUIT') }}
=======
    from {{ source('google_drive', 'HR_QUITS') }}
>>>>>>> e971b5470f3a9d0e9c607204be400efc2aa2d54f

),

employee_roster as (

    select
        j.employee_id,
        j.name,
        j.title,
        j.city,
        j.address,
        j.annual_salary,
        j.hire_date,
        q.quit_date,

        -- Tenure & status
        case
            when q.quit_date is not null then 'inactive'
            else 'active'
        end as employment_status,

        datediff('day', j.hire_date, coalesce(q.quit_date, current_date())) as tenure_days,

        -- Metadata
        j.source_modified_at,
        j.fivetran_synced_at

    from hr_joins as j
    left join hr_quits as q
        on j.employee_id = q.employee_id

)

select * from employee_roster
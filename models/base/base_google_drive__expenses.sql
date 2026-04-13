select
_file,
_line,
_modified,
_fivetran_synced,
DATE,
expense_type,
CAST(REPLACE(REPLACE(expense_amount, '$', ''), ' ', '') AS DECIMAL(10, 2)) as expense_amount
from {{source('google_drive','EXPENSES')}}

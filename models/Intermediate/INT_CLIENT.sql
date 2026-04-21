with sessions as (

    select
        client_id,
        session_id,
        session_at,
        has_order
    from {{ ref('INT_SESSION') }}

),

orders as (

    select
        client_id,
        order_id,
        order_at
    from {{ ref('INT_ORDERS') }}

)

select
    s.client_id,
    min(s.session_at) as first_session_at,
    max(s.session_at) as last_session_at,
    count(distinct s.session_id) as total_sessions,
    count(distinct o.order_id) as total_orders,
    sum(case when s.has_order = 1 then 1 else 0 end) as converted_sessions,
    case
        when count(distinct o.order_id) > 0 then 1
        else 0
    end as has_ever_ordered
from sessions s
left join orders o
    on s.client_id = o.client_id
group by 1
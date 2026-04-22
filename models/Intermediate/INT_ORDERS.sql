with orders as (

    select
        order_id,
        session_id,
        order_at,
        client_name,
        state,
        phone,
        payment_method,
        payment_info,
        shipping_address,
        shipping_cost,
        tax_rate
    from {{ ref('base_web_schema_orders') }}
    qualify row_number() over (partition by order_id order by order_at desc) = 1

),

sessions as (

    select
        session_id,
        client_id
    from {{ ref('base_web_schema_sessions') }}
    qualify row_number() over (partition by session_id order by session_at desc) = 1

)

select
    o.order_id,
    o.session_id,
    s.client_id,
    o.order_at,
    o.client_name,
    o.state,
    o.phone,
    o.payment_method,
    o.payment_info,
    o.shipping_address,
    o.shipping_cost,
    o.tax_rate
from orders o
left join sessions s
    on o.session_id = s.session_id
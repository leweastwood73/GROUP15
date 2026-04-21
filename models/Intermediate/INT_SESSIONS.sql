with sessions as (

    select
        client_id,
        session_id,
        os,
        ip,
        session_at
    from {{ ref('base_web_schema_sessions') }}

),

page_views as (

    select
        session_id,
        count(*) as page_view_count,
        min(view_at) as first_page_view_at,
        max(view_at) as last_page_view_at
    from {{ ref('base_web_schema_page_views') }}
    group by 1

),

item_views as (

    select
        session_id,
        count(*) as item_view_count,
        sum(coalesce(add_to_cart_quantity, 0)) as total_add_to_cart_quantity,
        sum(coalesce(remove_from_cart_quantity, 0)) as total_remove_from_cart_quantity,
        min(item_view_at) as first_item_view_at,
        max(item_view_at) as last_item_view_at
    from {{ ref('base_web_schema_item_views') }}
    group by 1

),

orders as (

    select
        session_id,
        count(distinct order_id) as order_count,
        min(order_at) as first_order_at,
        max(order_at) as last_order_at,
        sum(coalesce(shipping_cost, 0)) as total_shipping_cost
    from {{ ref('base_web_schema_orders') }}
    group by 1

)

select
    s.session_id,
    s.client_id,
    s.session_at,
    s.os,
    s.ip,

    coalesce(p.page_view_count, 0) as page_view_count,
    p.first_page_view_at,
    p.last_page_view_at,

    coalesce(i.item_view_count, 0) as item_view_count,
    coalesce(i.total_add_to_cart_quantity, 0) as total_add_to_cart_quantity,
    coalesce(i.total_remove_from_cart_quantity, 0) as total_remove_from_cart_quantity,
    i.first_item_view_at,
    i.last_item_view_at,

    coalesce(o.order_count, 0) as order_count,
    o.first_order_at,
    o.last_order_at,
    coalesce(o.total_shipping_cost, 0) as total_shipping_cost,

    case
        when coalesce(o.order_count, 0) > 0 then 1
        else 0
    end as has_order

from sessions s
left join page_views p
    on s.session_id = p.session_id
left join item_views i
    on s.session_id = i.session_id
left join orders o
    on s.session_id = o.session_id
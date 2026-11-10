{{ config(distributed_by='order_id') }}

with order_items as (
    select *
    from {{ ref('stg_shop__order_items') }}
),

orders as (
    select
        order_id,
        customer_id,
        order_date,
        is_confirmed
    from {{ ref('fct_orders') }}
)

select
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    o.customer_id,
    o.order_date,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    oi.line_amount,
    o.is_confirmed
from order_items as oi
inner join orders as o
    on oi.order_id = o.order_id
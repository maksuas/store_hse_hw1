{{ config(severity='warn') }}

with confirmed_orders as (
    select order_id,
    paid_amount,
    order_amount
    from {{ref('fct_orders')}}
    where is_confirmed = true
)

select order_id,
    paid_amount,
    order_amount
from confirmed_orders
where paid_amount > order_amount
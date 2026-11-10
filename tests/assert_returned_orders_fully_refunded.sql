with returned_orders as (
    select order_id,
    paid_amount,
    refunded_amount,
    net_paid_amount
    from {{ref('fct_orders')}}
    where order_status = 'returned'
)


select order_id,
    paid_amount,
    refunded_amount,
    net_paid_amount
from returned_orders
where net_paid_amount <> 0

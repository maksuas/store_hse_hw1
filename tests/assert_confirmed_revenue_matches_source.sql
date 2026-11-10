with source_confirmed_orders as (
    select
        o.order_id,
        o.status,
        o.total_amount
    from {{ source('shop', 'orders') }} as o
    where o.status = 'paid'
      and EXISTS (
          select 1
          from {{source('shop', 'payments')}} as p
          where p.order_id = o.order_id and
          p.payment_status = 'success' and 
          p.amount > 0
      )
),

source_revenue_amount as (
    select sum(total_amount) as source_revenue_sum
    from source_confirmed_orders
),

mart_revenue_amount as (
    select sum(order_amount) as mart_revenue_sum
    from {{ref('fct_orders')}} 
    where is_confirmed = true
)

select sr.source_revenue_sum,
mr.mart_revenue_sum
from source_revenue_amount as sr
cross join mart_revenue_amount as mr
where sr.source_revenue_sum <> mr.mart_revenue_sum
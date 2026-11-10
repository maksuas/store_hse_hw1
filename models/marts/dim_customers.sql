{{ config(distributed_replicated=true) }}

with customers as (
    select *
    from {{ ref('stg_shop__customers') }}
),

confirmed_orders as (
    select
        order_id,
        customer_id,
        first_paid_at,
        order_amount
    from {{ ref('fct_orders') }}
    where is_confirmed
),

customer_stats as (
    select
        customer_id,
        count(*) as confirmed_orders_count,
        sum(order_amount) as confirmed_revenue
    from confirmed_orders
    group by customer_id
),

ranked_orders as (
    select
        customer_id,
        order_id,
        first_paid_at,
        row_number() over (
            partition by customer_id
            order by first_paid_at, order_id
        ) as rn
    from confirmed_orders
),

first_orders as (
    select
        customer_id,
        order_id as first_confirmed_order_id,
        first_paid_at as first_confirmed_at
    from ranked_orders
    where rn = 1
)

select
    c.customer_id,
    c.registered_at,
    c.registration_date,
    c.city,
    c.acquisition_channel,

    fo.first_confirmed_order_id,
    fo.first_confirmed_at,

    coalesce(cs.confirmed_orders_count, 0)
        as confirmed_orders_count,

    coalesce(cs.confirmed_revenue, 0)
        as confirmed_revenue,

    coalesce(cs.confirmed_orders_count, 0) > 0
        as is_buyer

from customers as c

left join customer_stats as cs
    on c.customer_id = cs.customer_id

left join first_orders as fo
    on c.customer_id = fo.customer_id
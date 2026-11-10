with item_totals as (
    select
        order_id,
        sum(line_amount) as items_amount
    from {{ ref('fct_order_items') }}
    group by order_id
)

select
    o.order_id,
    o.order_amount,
    coalesce(i.items_amount, 0) as items_amount,
    o.order_amount - coalesce(i.items_amount, 0) as difference
from {{ ref('fct_orders') }} as o
left join item_totals as i
    on o.order_id = i.order_id
where o.order_amount <> coalesce(i.items_amount, 0)
{{ config(distributed_replicated=true) }}

with products as (
    select
        product_id,
        product_name,
        brand,
        category as category_name
    from {{ ref('stg_shop__products') }}
),

category_hierarchy as (
    select
        category_name,
        parent_category_name,
        root_category_name
    from {{ ref('int_product_category_hierarchy') }}
)

select
    p.product_id,
    p.product_name,
    p.brand,
    p.category_name,
    c.parent_category_name,
    c.root_category_name
from products as p
left join category_hierarchy as c
    on p.category_name = c.category_name
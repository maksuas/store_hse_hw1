
{{ config(distributed_replicated=true) }}

{% set start_date %}
    (select min(order_date)::date
     from {{ ref('stg_shop__orders') }})
{% endset %}

{% set end_date %}
    (select (max(order_date)::date + interval '1 day')::date
     from {{ ref('stg_shop__orders') }})
{% endset %}

with calendar as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date=start_date,
        end_date=end_date
    ) }}

)

select
    date_day::date as date_day,
    extract(year from date_day)::integer as year,
    extract(quarter from date_day)::integer as quarter,
    extract(month from date_day)::integer as month,
    extract(isodow from date_day)::integer as day_of_week,
    extract(isodow from date_day) in (6, 7) as is_weekend
from calendar

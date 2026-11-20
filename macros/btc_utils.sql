{% macro convert_to_usd(column_name) %}

{{column_name}} * (
    select CLOSE_PRICE_USD as price
        from  {{ref('btc_usd')}}
        where to_date(replace(EVENT_DATE, ' UTC', '')) = current_date()-2
)

{% endmacro %}

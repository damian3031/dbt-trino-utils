{% macro trino__date_spine(datepart, start_date, end_date) %}


{# call as follows:

date_spine(
    "day",
    "to_date('01/01/2016', 'mm/dd/yyyy')",
    "dateadd(week, 1, current_date)"
) #}


with rawdata as (

    {{dbt_utils.generate_series(
        dbt_utils.get_intervals_between(start_date, end_date, datepart)
    )}}

),

all_periods as (

    select (
        {{
            dateadd(
                datepart,
                "row_number() over (order by 1) - 1",
                "cast(cast(" ~ start_date ~ " as date) as timestamp)"
            )
        }}
    ) as date_{{datepart}}
    from rawdata

),

filtered as (

    select *
    from all_periods
    where date_{{datepart}} <= cast(cast({{ end_date }} as date) as timestamp)

)

select * from filtered

{% endmacro %}

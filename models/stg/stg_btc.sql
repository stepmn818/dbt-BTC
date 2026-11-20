{{ config(materialized='incremental',
    incremental_strategy='merge',
    unique_key='hash_key' )}}

select
    *
from {{source('btc','btc')}}


{% if is_incremental() %}

-- this filter will only be applied on an incremental run
-- (uses >= to include records whose timestamp occurred since the last run of this model)
-- (If event_time is NULL or the table is truncated, the condition will always be true and load all records)
where BLOCK_TIMESTAMP >= (
    select coalesce(max(BLOCK_TIMESTAMP), '1900-01-01'::timestamp)
    from {{ this }}
    )

{% endif %}


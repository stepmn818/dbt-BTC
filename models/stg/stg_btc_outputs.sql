{{ config(materialized='incremental',
    incremental_strategy='append'
    )}}

with flattened_outputs as (

    select
    tx.hash_key,
    tx.block_number,
    tx.block_timestamp,
    tx.is_coinbase,
    f.value:address::string as output_address,
    f.value:value::FLOAT as output_value

from {{ ref('stg_btc')}} tx,

LATERAL FLATTEN( INPUT => outputs) f

WHERE f.value:address is not null

{% if is_incremental() %}

    -- this filter will only be applied on an incremental run
    -- (uses >= to include records whose timestamp occurred since the last run of this model)
    -- (If event_time is NULL or the table is truncated, the condition will always be true and load all records)
and tx.block_timestamp >= (select max(block_timestamp) from {{ this }})

{% endif %}

)

select hash_key, block_number, block_timestamp, is_coinbase, output_address, output_value
from flattened_outputs
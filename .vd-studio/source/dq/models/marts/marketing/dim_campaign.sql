{{
    config(
        materialized='table'
    )
}}

with campaign as (
    select * from {{ ref('stg_salesforce__campaign') }}
),

final as (
    select
        -- Primary key
        campaign_id,

        -- Campaign attributes
        campaign_name,
        campaign_type,
        campaign_status,

        -- Dates
        start_date,
        end_date,

        -- Flags
        is_active,

        -- Foreign keys
        owner_id,

        -- Audit timestamps
        created_at,
        last_modified_at,

        -- Metadata
        extracted_at

    from campaign
)

select * from final

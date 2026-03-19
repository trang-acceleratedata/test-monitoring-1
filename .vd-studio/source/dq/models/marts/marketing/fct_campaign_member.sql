{{
    config(
        materialized='table'
    )
}}

with campaign_member as (
    select * from {{ ref('stg_salesforce__campaign_member') }}
),

final as (
    select
        -- Primary key
        campaign_member_id,

        -- Foreign keys
        campaign_id,
        lead_id,
        contact_id,

        -- Derived member type
        case
            when lead_id is not null then 'Lead'
            when contact_id is not null then 'Contact'
            else 'Unknown'
        end as member_type,

        -- Attributes
        member_status,
        has_responded,

        -- Timestamps
        created_at as member_added_at,
        last_modified_at,

        -- Metadata
        extracted_at

    from campaign_member
)

select * from final

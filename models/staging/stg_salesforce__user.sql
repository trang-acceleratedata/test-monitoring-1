{{
    config(
        materialized='view'
    )
}}

with source as (

    select * from {{ source('salesforce', 'salesforce_User') }}

),

renamed as (

    select
        -- Primary key
        Id as user_id,

        -- User attributes
        Username as username,
        Email as email,
        FirstName as first_name,
        LastName as last_name,

        -- Status
        cast(IsActive as boolean) as is_active,

        -- Timestamps
        CreatedDate as created_date,
        LastModifiedDate as last_modified_date,

        -- Metadata columns (DLT lineage)
        _vd_extracted_at,
        _dlt_load_id,
        _dlt_id

    from source

)

select * from renamed

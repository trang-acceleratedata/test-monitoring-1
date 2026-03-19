with source as (
    select * from {{ source('salesforce', 'salesforce_Campaign') }}
),

renamed as (
    select
        -- Primary key
        Id as campaign_id,

        -- Campaign attributes
        Name as campaign_name,
        Type as campaign_type,
        Status as campaign_status,

        -- Dates
        StartDate as start_date,
        EndDate as end_date,

        -- Flags
        IsActive as is_active,

        -- Foreign keys
        OwnerId as owner_id,

        -- Audit fields
        CreatedDate as created_at,
        LastModifiedDate as last_modified_at,

        -- dlt metadata
        _vd_extracted_at as extracted_at,
        _dlt_load_id as dlt_load_id,
        _dlt_id as dlt_id

    from source
    where IsDeleted = 0  -- Exclude soft-deleted records
)

select * from renamed

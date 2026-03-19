# Design: Salesforce Staging Models

## Source Mapping

| Source Table | Staging Model | Status | Notes |
|-------------|---------------|--------|-------|
| salesforce_User | stg_salesforce__user | ⏳ Pending | System users |
| salesforce_UserRole | stg_salesforce__user_role | ⏳ Pending | Role hierarchy |
| salesforce_Account | stg_salesforce__account | ⏳ Pending | Customer orgs (has soft-delete) |
| salesforce_Contact | stg_salesforce__contact | ⏳ Pending | Individual contacts (has soft-delete) |
| salesforce_Lead | stg_salesforce__lead | ⏳ Pending | Prospects (has soft-delete) |
| salesforce_Opportunity | stg_salesforce__opportunity | ⏳ Pending | Sales deals (has soft-delete) |
| salesforce_OpportunityLineItem | stg_salesforce__opportunity_line_item | ⏳ Pending | Opp products (has soft-delete) |
| salesforce_OpportunityContactRole | stg_salesforce__opportunity_contact_role | ⏳ Pending | Opp-Contact links (has soft-delete) |
| salesforce_Campaign | stg_salesforce__campaign | ⏳ Pending | Marketing campaigns (has soft-delete) |
| salesforce_CampaignMember | stg_salesforce__campaign_member | ⏳ Pending | Campaign participants (has soft-delete) |
| salesforce_Product2 | stg_salesforce__product | ⏳ Pending | Products (has soft-delete) |
| salesforce_Pricebook2 | stg_salesforce__pricebook | ⏳ Pending | Price books (has soft-delete) |
| salesforce_PricebookEntry | stg_salesforce__pricebook_entry | ⏳ Pending | Price book entries (has soft-delete) |
| salesforce_Task | stg_salesforce__task | ⏳ Pending | Activities (has soft-delete) |
| salesforce_Event | stg_salesforce__event | ⏳ Pending | Calendar events (has soft-delete) |

**Total:** 15 staging models

## Model Architecture

```
salesforce (SQLite source)
    ├── salesforce_User                 → stg_salesforce__user
    ├── salesforce_UserRole             → stg_salesforce__user_role
    ├── salesforce_Account              → stg_salesforce__account
    ├── salesforce_Contact              → stg_salesforce__contact
    ├── salesforce_Lead                 → stg_salesforce__lead
    ├── salesforce_Opportunity          → stg_salesforce__opportunity
    ├── salesforce_OpportunityLineItem  → stg_salesforce__opportunity_line_item
    ├── salesforce_OpportunityContactRole → stg_salesforce__opportunity_contact_role
    ├── salesforce_Campaign             → stg_salesforce__campaign
    ├── salesforce_CampaignMember       → stg_salesforce__campaign_member
    ├── salesforce_Product2             → stg_salesforce__product
    ├── salesforce_Pricebook2           → stg_salesforce__pricebook
    ├── salesforce_PricebookEntry       → stg_salesforce__pricebook_entry
    ├── salesforce_Task                 → stg_salesforce__task
    └── salesforce_Event                → stg_salesforce__event
```

### Layer Structure

```
models/
  staging/
    __salesforce_sources.yml          # Source definitions
    stg_salesforce__user.sql
    stg_salesforce__user_role.sql
    stg_salesforce__account.sql
    stg_salesforce__contact.sql
    stg_salesforce__lead.sql
    stg_salesforce__opportunity.sql
    stg_salesforce__opportunity_line_item.sql
    stg_salesforce__opportunity_contact_role.sql
    stg_salesforce__campaign.sql
    stg_salesforce__campaign_member.sql
    stg_salesforce__product.sql
    stg_salesforce__pricebook.sql
    stg_salesforce__pricebook_entry.sql
    stg_salesforce__task.sql
    stg_salesforce__event.sql
```

## Materialization Strategy

All staging models will be materialized as **views** for the following reasons:

1. **Freshness** - Views ensure staging layer always reflects latest source data
2. **Storage Efficiency** - No data duplication at staging layer
3. **Simplicity** - 1:1 relationship with source means minimal transformation overhead
4. **SQLite Target** - Lightweight database doesn't benefit from table materialization at this layer
5. **Pattern Compliance** - Medallion architecture standard for Bronze→Silver transition

### Configuration

```yaml
# dbt_project.yml
models:
  test_1:
    staging:
      +materialized: view
      +schema: staging
```

## Common Transformations

Each staging model will apply:

### 1. Column Renaming (PascalCase → snake_case)

```sql
SELECT
    Id AS {entity}_id,
    Name AS name,
    CreatedDate AS created_date,
    LastModifiedDate AS last_modified_date
    -- ... etc
```

### 2. Soft Delete Filtering (where applicable)

```sql
FROM {{ source('salesforce', 'salesforce_Account') }}
WHERE is_deleted = 0 OR is_deleted IS NULL
```

### 3. Metadata Column Preservation

```sql
    _vd_extracted_at,
    _dlt_load_id,
    _dlt_id
FROM {{ source('salesforce', 'salesforce_Account') }}
```

### 4. Boolean Casting (SQLite INTEGER → boolean convention)

```sql
    CAST(IsActive AS BOOLEAN) AS is_active,
    CAST(IsClosed AS BOOLEAN) AS is_closed
```

## Source YAML Structure

**File:** `models/staging/__salesforce_sources.yml`

```yaml
version: 2

sources:
  - name: salesforce
    database: /home/trangtnt/vd-studio/data/sales.db
    schema: main
    description: Salesforce CRM data via DLT pipeline

    tables:
      - name: salesforce_User
        description: Salesforce users (employees)
        identifier: salesforce_User
        columns:
          - name: Id
            description: Unique user identifier
            tests:
              - not_null
              - unique

      - name: salesforce_Account
        description: Customer and prospect organizations
        identifier: salesforce_Account
        columns:
          - name: Id
            description: Unique account identifier
            tests:
              - not_null
              - unique
          - name: IsDeleted
            description: Soft delete flag

      # ... (similar for all 15 tables)
```

## Validation Approach

### 1. Compilation Validation

```bash
dbt compile --select stg_salesforce__*
```

All 15 models must compile without errors.

### 2. Row Count Validation

For each staging model, validate against source:

```sql
-- Source count
SELECT COUNT(*) FROM salesforce_Account WHERE IsDeleted = 0;

-- Staging count
SELECT COUNT(*) FROM {{ ref('stg_salesforce__account') }};
```

Counts should match exactly (100% accuracy expected for staging layer).

### 3. Primary Key Tests

Every staging model will have schema tests:

```yaml
models:
  - name: stg_salesforce__account
    columns:
      - name: account_id
        tests:
          - not_null
          - unique
```

### 4. Column Mapping Validation

Verify all source columns are mapped (none dropped accidentally):

```bash
dbt run-operation compare_column_counts
```

## Validation Results

_To be populated after model generation_

### Version 1 (Initial Build)

| Model | Compiled | Row Count Match | PK Tests Pass | Notes |
|-------|----------|----------------|---------------|-------|
| stg_salesforce__user | ⏳ | ⏳ | ⏳ | |
| stg_salesforce__account | ⏳ | ⏳ | ⏳ | |
| ... | ⏳ | ⏳ | ⏳ | |

## Change Log

### 2026-03-19 - Initial Design

- Defined 15 staging models for all Salesforce source tables
- Established view materialization strategy
- Documented column renaming and soft-delete filtering standards
- Created source mapping with build status tracking

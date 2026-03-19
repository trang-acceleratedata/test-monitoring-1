# Design: Salesforce Campaign Analytics

## Source Mapping

### Staging Models (1:1 with source)

| Source Table            | Staging Model                | Status      |
| ----------------------- | ---------------------------- | ----------- |
| salesforce_Campaign     | stg_salesforce__campaign     | ✅ Complete  |
| salesforce_CampaignMember | stg_salesforce__campaign_member | 📋 Planned   |
| salesforce_Contact      | stg_salesforce__contact      | 📋 Planned   |
| salesforce_Lead         | stg_salesforce__lead         | 📋 Planned   |

### Mart Models (analytical layer)

| Mart Model            | Type      | Purpose                                    | Status     |
| --------------------- | --------- | ------------------------------------------ | ---------- |
| dim_campaign          | Dimension | Campaign attributes for slicing/dicing    | 📋 Planned  |
| fct_campaign_member   | Fact      | Campaign membership grain (1 row per member) | 📋 Planned  |

## Model Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          SOURCE LAYER (SQLite)                       │
│  salesforce_Campaign  salesforce_CampaignMember  Contact  Lead       │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│                         STAGING LAYER (Views)                        │
│  stg_salesforce__campaign  stg_salesforce__campaign_member           │
│  stg_salesforce__contact   stg_salesforce__lead                      │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│                          MARTS LAYER (Tables)                        │
│                                                                       │
│  dim_campaign (SCD Type 1)                                           │
│    - campaign_id (PK)                                                │
│    - campaign_name, type, status                                     │
│    - start_date, end_date, is_active                                 │
│    - owner_id                                                        │
│                                                                       │
│  fct_campaign_member (Fact)                                          │
│    - campaign_member_id (PK)                                         │
│    - campaign_id (FK → dim_campaign)                                 │
│    - lead_id, contact_id (nullable - one will be populated)          │
│    - member_status, has_responded                                    │
│    - created_at (event timestamp)                                    │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Materialization Strategy

### Staging Layer (All Views)
- **stg_salesforce__campaign**: View ✅
- **stg_salesforce__campaign_member**: View 📋
- **stg_salesforce__contact**: View 📋
- **stg_salesforce__lead**: View 📋
- **Why**: Staging models are always views (1:1 with source, lightweight transformations)
- **Refresh**: On-demand when downstream models run

### Marts Layer (All Tables)
- **dim_campaign**: Table
  - **Why**: Dimension table, relatively small, needs to persist for performance
  - **Refresh**: Full refresh (SCD Type 1 - overwrite on change)

- **fct_campaign_member**: Table
  - **Why**: Fact table, could grow large with many campaigns/members
  - **Refresh**: Full refresh initially, incremental possible if needed
  - **Grain**: One row per campaign member (unique on campaign_member_id)

## Validation Approach

1. **Row Count Check**: Compare source table count (excluding IsDeleted = 1) with staging model
2. **Primary Key Uniqueness**: Verify `campaign_id` is unique
3. **Null Check**: Ensure `campaign_id` has no nulls
4. **Data Type Validation**: Confirm dates are properly cast

### Expected Results
```sql
-- Source count (active only)
SELECT COUNT(*) FROM salesforce_Campaign WHERE IsDeleted = 0;

-- Staging count
SELECT COUNT(*) FROM stg_salesforce__campaign;
```

## Validation Results

### v1 (Complete)
- Build status: ✅ Model created
- SQL syntax: ✅ SQLite-compatible (no explicit casting)
- Source YAML: ✅ Created with full column documentation
- Model YAML: ✅ Created with tests defined
- dbt run: ✅ Successfully executed - view created in database
- Row count: 0 (source table is empty)

**Note**: Source table currently contains 0 records (no sample data loaded yet)

## Mart Specifications

### dim_campaign
**Purpose**: Campaign dimension for slicing/dicing in analysis

**Grain**: One row per campaign

**Source**: `stg_salesforce__campaign`

**Key Transformations**:
- Direct passthrough from staging (no aggregation needed)
- Primary key: `campaign_id`

**Key Columns**:
```sql
- campaign_id (PK)
- campaign_name
- campaign_type
- campaign_status
- start_date, end_date
- is_active
- owner_id
- created_at, last_modified_at
```

### fct_campaign_member
**Purpose**: Campaign membership fact for member-level analysis

**Grain**: One row per campaign member (person added to a campaign)

**Sources**:
- `stg_salesforce__campaign_member` (primary)
- `stg_salesforce__campaign` (for campaign attributes if needed)

**Key Transformations**:
- Join campaign member to campaign dimension
- Determine member type (is_lead vs is_contact based on which ID is populated)

**Key Columns**:
```sql
- campaign_member_id (PK)
- campaign_id (FK)
- lead_id (nullable)
- contact_id (nullable)
- member_type (derived: 'Lead' or 'Contact')
- member_status
- has_responded
- created_at (when member was added to campaign)
```

**Sample Analysis Queries**:
```sql
-- Campaign performance summary
SELECT
    c.campaign_name,
    c.campaign_type,
    COUNT(*) as total_members,
    SUM(CASE WHEN f.has_responded = 1 THEN 1 ELSE 0 END) as total_responses,
    ROUND(100.0 * SUM(CASE WHEN f.has_responded = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) as response_rate
FROM fct_campaign_member f
JOIN dim_campaign c ON f.campaign_id = c.campaign_id
GROUP BY c.campaign_name, c.campaign_type
ORDER BY total_members DESC;

-- Member type distribution by campaign
SELECT
    c.campaign_name,
    f.member_type,
    COUNT(*) as member_count
FROM fct_campaign_member f
JOIN dim_campaign c ON f.campaign_id = c.campaign_id
GROUP BY c.campaign_name, f.member_type;
```

## Change Log

### 2026-03-19 16:00
- 📋 Expanded scope to include full campaign analytics solution
- 📋 Designed dimensional model: dim_campaign + fct_campaign_member
- 📋 Identified additional staging models needed (CampaignMember, Contact, Lead)
- Updated intent.md with business questions and acceptance criteria

### 2026-03-19 14:30
- ✅ Created staging model `stg_salesforce__campaign.sql`
- ✅ Created source YAML `__salesforce_sources.yml`
- ✅ Created model documentation YAML `stg_salesforce__campaign.yml`
- ✅ Added tests: `not_null` and `unique` on `campaign_id`
- ✅ Successfully ran model with `dbt run`
- Fixed SQL syntax to be SQLite-compatible (removed explicit timestamp/boolean casts)

### 2026-03-19 11:27
- Initial design created
- Identified source table structure (14 columns)
- Defined transformation rules (rename, cast, filter)

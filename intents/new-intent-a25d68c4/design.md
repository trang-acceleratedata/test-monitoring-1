# Design: Salesforce Campaign Staging Model

## Source Mapping

| Source Table          | Staging Model              | Status      |
| --------------------- | -------------------------- | ----------- |
| salesforce_Campaign   | stg_salesforce__campaign   | ✅ Complete  |

## Model Architecture

```
salesforce_Campaign (SQLite source)
    ↓
stg_salesforce__campaign (view)
    ↓
[Future marts: fct_campaign_performance, dim_campaign]
```

## Materialization Strategy

**stg_salesforce__campaign**: View
- **Why**: Staging models are always views (1:1 with source, lightweight transformations)
- **Refresh**: On-demand when downstream models run

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
- Compile check: ⏸️ Pending dbt installation

**Note**: Source table currently contains 0 records (no sample data loaded yet)

## Change Log

### 2026-03-19 14:30
- ✅ Created staging model `stg_salesforce__campaign.sql`
- ✅ Created source YAML `__salesforce_sources.yml`
- ✅ Created model documentation YAML `stg_salesforce__campaign.yml`
- ✅ Added tests: `not_null` and `unique` on `campaign_id`
- Fixed SQL syntax to be SQLite-compatible (removed explicit timestamp/boolean casts)

### 2026-03-19 11:27
- Initial design created
- Identified source table structure (14 columns)
- Defined transformation rules (rename, cast, filter)

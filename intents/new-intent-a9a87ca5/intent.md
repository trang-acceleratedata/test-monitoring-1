# Intent: Salesforce Staging Models

## Business Context

Create staging (Bronze → Silver) models for all Salesforce source tables to provide clean, consistent data foundations for downstream analytics and reporting. These staging models will serve as the entry point for all Salesforce data into the data warehouse, applying standardized naming conventions and filtering out deleted records.

**Consumer:** Downstream data analysts, BI developers, and mart builders who need reliable access to Salesforce entities.

## Goals

1. **Complete Coverage** - Create staging models for all 15 Salesforce tables (User, Account, Opportunity, Contact, Lead, Campaign, Product2, etc.)
2. **Data Quality** - Filter soft-deleted records (IsDeleted = 0) from all applicable tables
3. **Consistency** - Apply standard naming conventions (snake_case columns, consistent date handling)
4. **Performance** - Use view materialization for staging models to minimize storage and ensure freshness
5. **Documentation** - Document each staging model with grain, purpose, and key transformations

## Business Rules

### Soft Delete Filtering

All tables with `IsDeleted` column must filter to active records only:

```sql
WHERE is_deleted = 0 OR is_deleted IS NULL
```

### Column Naming

- Convert Salesforce PascalCase to snake_case (e.g., `AccountId` → `account_id`)
- Preserve Id as primary key with suffix pattern (e.g., `Id` → `{entity}_id`)
- Boolean columns use `is_` prefix (e.g., `IsActive` → `is_active`)
- Date columns use `_date` or `_at` suffix (e.g., `CloseDate` → `close_date`)
- Amount columns use `_amount` suffix (e.g., `Amount` → `amount`)

### Metadata Columns

Preserve DLT metadata columns for lineage tracking:
- `_vd_extracted_at` - Extraction timestamp
- `_dlt_load_id` - Load batch identifier
- `_dlt_id` - Unique row identifier

### Primary Keys

All staging models must have:
- `{entity}_id` as the primary key (sourced from `Id` column)
- `not_null` and `unique` tests on primary key

## Acceptance Criteria

- [ ] 15 staging models created (one per source table)
- [ ] All models follow naming convention: `stg_salesforce__{table_name}`
- [ ] All models materialized as views
- [ ] Soft-deleted records filtered out where applicable
- [ ] Column names converted to snake_case
- [ ] Primary key tests added (`not_null`, `unique`)
- [ ] Source YAML created (`models/staging/__salesforce_sources.yml`)
- [ ] All models compile successfully (`dbt compile`)

## Sources

**Salesforce** (SQLite database at `/home/trangtnt/vd-studio/data/sales.db`)

Core tables:
- **User & UserRole** - System users and roles
- **Account** - Customer/prospect organizations
- **Contact** - Individual contacts
- **Lead** - Prospective customers
- **Opportunity** - Sales deals
- **OpportunityLineItem** - Opportunity products
- **OpportunityContactRole** - Opportunity-Contact relationships
- **Campaign** - Marketing campaigns
- **CampaignMember** - Campaign participants
- **Product2** - Products
- **Pricebook2 & PricebookEntry** - Pricing
- **Task & Event** - Activities

## Open Questions

None - schema is well-defined and business rules are standard Salesforce conventions.

## Clarifying Questions Asked

Q: Where is your salesforce data located?
A: User requested to proceed with creating staging models for the pre-configured SQLite database.

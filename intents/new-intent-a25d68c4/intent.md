# Intent: Salesforce Campaign Staging Model

## Business Context

Create a staging model for the Salesforce Campaign table to enable downstream analysis of marketing campaigns, including campaign performance, status tracking, and time-based reporting.

## Goals

1. Create a 1:1 staging view of the `salesforce_Campaign` source table
2. Apply standard transformations (rename columns, filter soft-deletes)
3. Establish foundation for campaign-related downstream marts

## Business Rules

### Soft Delete Filtering
- Exclude records where `IsDeleted = 1`
- Only active campaign records should flow downstream

### Column Standardization
- Rename Salesforce API columns to snake_case
- Cast dates from TEXT to appropriate timestamp types
- Cast boolean integers (0/1) to proper boolean types

## Acceptance Criteria

- [ ] Staging model `stg_salesforce__campaign` created
- [ ] Source YAML `__salesforce_sources.yml` created/updated
- [ ] Model compiles successfully with `dbt compile`
- [ ] All IsDeleted = 1 records are filtered out
- [ ] Column names follow snake_case convention

## Open Questions

None - this is a straightforward staging model creation.

## Sources

**Salesforce Campaign** (`salesforce_Campaign` table in `/home/trangtnt/vd-studio/data/sales.db`)
- Contains marketing campaign master data
- 14 columns including Id, Name, Type, Status, dates, and audit fields

## Clarifying Questions Asked

None - requirement is clear.

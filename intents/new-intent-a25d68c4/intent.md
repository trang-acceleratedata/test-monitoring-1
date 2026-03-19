# Intent: Salesforce Campaign Analytics

## Business Context

Build a complete campaign analytics solution that enables marketing teams to analyze campaign performance, member engagement, and ROI. This includes staging models for all campaign-related tables and analytical marts that answer key business questions about campaign effectiveness.

## Goals

1. ✅ Create staging models for campaign-related tables (Campaign, CampaignMember, Contact, Lead)
2. Build dimensional model for campaign analysis (facts and dimensions)
3. Enable analysis of:
   - Campaign performance (members, responses, conversions)
   - Member engagement by campaign type and status
   - Lead/Contact attribution to campaigns
   - Time-series trends in campaign activity

## Business Rules

### Soft Delete Filtering
- Exclude records where `IsDeleted = 1`
- Only active campaign records should flow downstream

### Column Standardization
- Rename Salesforce API columns to snake_case
- Cast dates from TEXT to appropriate timestamp types
- Cast boolean integers (0/1) to proper boolean types

## Acceptance Criteria

**Staging Layer:**
- [x] Staging model `stg_salesforce__campaign` created
- [x] Source YAML `__salesforce_sources.yml` created/updated
- [ ] Staging models for CampaignMember, Contact, Lead created
- [x] All models compile and run successfully
- [x] All IsDeleted = 1 records filtered out

**Marts Layer:**
- [ ] `dim_campaign` - Campaign dimension table
- [ ] `fct_campaign_member` - Campaign membership fact table
- [ ] All marts tested with sample queries
- [ ] Documentation complete

## Open Questions

1. **Campaign Member Grain**: Should we track campaign members at daily grain or keep it as one row per member per campaign?
2. **Conversion Tracking**: Do we need to track lead-to-opportunity conversions via campaigns?
3. **Metrics Priority**: Which metrics are most important?
   - Member count, response count, response rate
   - Lead conversion rate
   - Campaign ROI (if cost/revenue data available)

## Sources

All sources from `/home/trangtnt/vd-studio/data/sales.db`:

**Primary Sources:**
1. **salesforce_Campaign** - Marketing campaign master data (14 columns)
2. **salesforce_CampaignMember** - Campaign membership (junction table) (12 columns)
3. **salesforce_Contact** - Contact master data (12 columns)
4. **salesforce_Lead** - Lead master data (16 columns)

**Supporting Sources (for future enhancement):**
- salesforce_Opportunity - For conversion tracking
- salesforce_User - For campaign owner names

## Clarifying Questions Asked

None - requirement is clear.

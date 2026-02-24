# dbt Schema Behavior Reference Guide
**Technical Documentation - Schema Resolution & Naming Patterns**

---

## Overview

This guide explains how dbt resolves schema names when you specify (or omit) the `schema` configuration in your models. Understanding this behavior prevents common issues like `analytics_analytics` schema duplication and helps you organize models effectively.

---

## Core Concept: Target Schema vs Custom Schema

### **Target Schema**
- Defined in `profiles.yml` under your target configuration
- Default location for all models (unless overridden)
- Example: `schema: analytics`

### **Custom Schema**
- Specified in model's `{{ config(schema='...') }}`
- Modifies where the model is created
- **Default behavior:** Appends to target schema (not replaces)

---

## Schema Resolution Logic

### **Scenario 1: No Schema Specified (Default)**

**Model Config:**
```sql
{{ config(
    materialized='table'
    -- No schema line
) }}

SELECT * FROM ...
```

**profiles.yml:**
```yaml
target:
  schema: analytics
```

**Result:**
- **Schema Created:** `analytics`
- **Full Table Name:** `project.analytics.model_name`

**Use Case:** Default behavior - use when all models belong in same schema

---

### **Scenario 2: Custom Schema WITHOUT Macro**

**Model Config:**
```sql
{{ config(
    materialized='table',
    schema='analytics'  -- Explicit schema
) }}

SELECT * FROM ...
```

**profiles.yml:**
```yaml
target:
  schema: analytics
```

**Result:**
- **Schema Created:** `analytics_analytics` (target + custom)
- **Full Table Name:** `project.analytics_analytics.model_name`

**dbt Logic:**
```python
schema_name = f"{target_schema}_{custom_schema}"
# analytics + analytics = analytics_analytics
```

**Why This Happens:**
- dbt assumes custom schema means "create separate namespace"
- Prevents accidentally overwriting target schema
- Forces explicit schema separation

**Common Mistake:**
```sql
-- Trying to explicitly use target schema
{{ config(schema='analytics') }}

-- Results in: analytics_analytics ❌
-- Should omit schema line instead ✓
```

---

### **Scenario 3: Custom Schema WITH generate_schema_name Macro**

**Macro File:** `macros/generate_schema_name.sql`
```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}  -- No custom schema → use target
    {%- else -%}
        {{ custom_schema_name | trim }}  -- Custom schema → use as-is
    {%- endif -%}
{%- endmacro %}
```

**Model Config:**
```sql
{{ config(
    materialized='table',
    schema='analytics'
) }}

SELECT * FROM ...
```

**Result:**
- **Schema Created:** `analytics` (exactly as specified)
- **Full Table Name:** `project.analytics.model_name`

**How It Works:**
1. dbt calls `generate_schema_name('analytics', node)`
2. Macro returns `'analytics'` (trimmed, no appending)
3. Model created in `analytics` schema

**Benefit:** Full control over schema naming without appending behavior

---

### **Scenario 4: Separate Schema for Organization**

**Model Config:**
```sql
{{ config(
    materialized='table',
    schema='staging'  -- Separate namespace
) }}

SELECT * FROM ...
```

**profiles.yml:**
```yaml
target:
  schema: analytics
```

**Without Macro:**
- **Result:** `analytics_staging`

**With Macro:**
- **Result:** `staging`

**Use Case:**
- Separate staging area from production
- Isolate test data
- Organize by data layer (raw → staging → marts)

---

## Decision Flowchart

```
┌─────────────────────────────────────────────┐
│ Do all models belong in same schema?        │
└────────────┬────────────────────────────────┘
             │
    ┌────────┴────────┐
    │ YES             │ NO
    │                 │
    ▼                 ▼
┌────────────────┐  ┌──────────────────────────┐
│ Omit schema=   │  │ Do you want appending?   │
│ Uses target    │  └──────┬───────────────────┘
│ schema only    │         │
└────────────────┘  ┌──────┴──────┐
                    │ YES         │ NO
                    │             │
                    ▼             ▼
         ┌─────────────────┐  ┌──────────────────┐
         │ Use schema=     │  │ Add macro to     │
         │ Gets appended   │  │ override default │
         │ (e.g. ana_stg)  │  │ behavior         │
         └─────────────────┘  └──────────────────┘
```

---

## Common Use Cases & Patterns

### **Pattern 1: All Models in Same Schema**

**Goal:** Everything in `analytics` schema

**Solution:** Omit `schema=` config entirely

```sql
-- models/marts/core/fct_orders.sql
{{ config(materialized='table') }}

-- models/marts/core/dim_customers.sql
{{ config(materialized='table') }}

-- Both created in: analytics
```

**✅ Recommended for:** Single-schema projects, portfolio projects, small teams

---

### **Pattern 2: Layered Data Architecture**

**Goal:** Separate raw → staging → marts

**Solution:** Use schema names for each layer

```sql
-- models/staging/stg_orders.sql
{{ config(
    materialized='view',
    schema='staging'
) }}
-- Creates: analytics_staging.stg_orders

-- models/marts/fct_orders.sql
{{ config(
    materialized='table',
    schema='marts'
) }}
-- Creates: analytics_marts.fct_orders
```

**✅ Recommended for:** Large projects, enterprise environments, strict governance

---

### **Pattern 3: Environment Separation**

**Goal:** Isolate dev/test/prod data

**Solution:** Use different target schemas in profiles.yml

```yaml
# profiles.yml
dev:
  schema: analytics_dev
  
test:
  schema: analytics_test
  
prod:
  schema: analytics
```

**All models (no schema config):**
- Dev run: `analytics_dev.model_name`
- Test run: `analytics_test.model_name`
- Prod run: `analytics.model_name`

**✅ Recommended for:** Multi-environment deployments, CI/CD pipelines

---

### **Pattern 4: Custom Schema with Macro (Full Control)**

**Goal:** Explicitly set schema names without appending

**Macro:** `macros/generate_schema_name.sql`
```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
```

**Model:**
```sql
{{ config(schema='analytics') }}
-- Creates: analytics (not analytics_analytics)

{{ config(schema='reporting') }}
-- Creates: reporting (not analytics_reporting)
```

**✅ Recommended for:** Migrating from other tools, strict naming requirements

---

## Macro Execution Flow

### **When Macros Run:**

```
┌─────────────────────────────────────────────┐
│ Step 1: dbt Reads macros/ Folder            │
│ - Loads all .sql files                      │
│ - Stores macros in memory                   │
│ - Happens BEFORE model compilation          │
└────────────┬────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────┐
│ Step 2: dbt Compiles Models                 │
│ - Processes Jinja templates                 │
│ - Calls macros ({{ ... }})                  │
│ - Generates final SQL                       │
└────────────┬────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────┐
│ Step 3: dbt Runs Models                     │
│ - Executes compiled SQL in database         │
│ - Creates tables/views                      │
│ - Database never sees macros                │
└─────────────────────────────────────────────┘
```

### **Example Execution:**

**Macro:**
```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {{ custom_schema_name | trim }}
{%- endmacro %}
```

**Model:**
```sql
{{ config(schema='analytics') }}

SELECT 
    user_id,
    order_date
FROM {{ ref('stg_orders') }}
```

**Compilation Phase (runs locally in dbt):**
```sql
-- dbt calls: generate_schema_name('analytics', node)
-- Macro returns: 'analytics'
-- Schema determined: analytics
```

**Execution Phase (runs in BigQuery):**
```sql
CREATE TABLE `project.analytics.model_name` AS
SELECT 
    user_id,
    order_date
FROM `project.analytics.stg_orders`
```

**Key Point:** Database only sees final SQL, never the macro logic

---

## Troubleshooting

### **Problem 1: Unwanted `analytics_analytics` Schema**

**Symptoms:**
- Model appears in wrong schema
- Schema name duplicated (e.g., `analytics_analytics`)

**Cause:**
```sql
{{ config(schema='analytics') }}
-- When target schema is also 'analytics'
```

**Fix 1: Remove schema config**
```sql
{{ config(materialized='table') }}
-- Omit schema line entirely
```

**Fix 2: Add generate_schema_name macro**
```sql
-- macros/generate_schema_name.sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {{ custom_schema_name | trim }}
{%- endmacro %}
```

**Verification:**
```bash
dbt run --models model_name
# Check logs for: "Creating schema analytics" (not analytics_analytics)
```

---

### **Problem 2: Models in Different Schemas**

**Symptoms:**
- Some models in `analytics`
- Others in `analytics_staging`, `analytics_marts`, etc.

**Cause:** Inconsistent schema config across models

**Fix:** Standardize approach:

**Option A: All in same schema (omit schema)**
```sql
-- All models
{{ config(materialized='table') }}
```

**Option B: Intentional separation (use schema)**
```sql
-- Staging models
{{ config(schema='staging') }}

-- Marts models
{{ config(schema='marts') }}
```

---

### **Problem 3: Schema Not Created**

**Symptoms:**
- `dbt run` succeeds
- Schema doesn't exist in database

**Cause:** Schema creation permissions missing

**Fix:** Grant CREATE SCHEMA permission
```sql
-- BigQuery
GRANT `roles/bigquery.admin` ON PROJECT `project-id` TO 'serviceaccount@project.iam.gserviceaccount.com';

-- PostgreSQL
GRANT CREATE ON DATABASE database_name TO username;
```

**Note:** dbt automatically runs `CREATE SCHEMA IF NOT EXISTS`, so permission is only issue

---

### **Problem 4: Macro Not Applied**

**Symptoms:**
- Added generate_schema_name macro
- Still getting appended schema names

**Causes & Fixes:**

**1. Macro file not in macros/ folder**
```
✅ Correct: macros/generate_schema_name.sql
❌ Wrong: models/macros/generate_schema_name.sql
```

**2. Partial parse cache**
```bash
# Clear cache and recompile
dbt clean
dbt compile
dbt run
```

**3. Syntax error in macro**
```bash
# Check compilation
dbt compile --models model_name

# Look for errors in: target/compiled/project/models/...
```

---

## Best Practices

### ✅ **Do:**

1. **Be consistent:** All models either use schema config or don't
2. **Document intent:** Comment why schema is specified (if used)
3. **Use macros for control:** If you need exact schema names, add generate_schema_name
4. **Test in dev first:** Verify schema behavior before production deployment
5. **Use target.schema:** Leverage profiles.yml for environment differences

### ❌ **Don't:**

1. **Don't specify schema to "be explicit"** - omitting is clearer when using target schema
2. **Don't assume schema='analytics' uses analytics** - it creates analytics_analytics
3. **Don't mix patterns** - some models with schema config, others without (unless intentional)
4. **Don't forget permissions** - dbt needs CREATE SCHEMA rights
5. **Don't skip documentation** - explain schema strategy in README

---

## Comparison Table

| Scenario | Config | Target Schema | Result Schema | Use When |
|----------|--------|---------------|---------------|----------|
| Default | No schema line | `analytics` | `analytics` | All models in one schema |
| Custom (no macro) | `schema='staging'` | `analytics` | `analytics_staging` | Want appending behavior |
| Custom (with macro) | `schema='staging'` | `analytics` | `staging` | Want exact name |
| Multi-env | No schema line | `analytics_dev` | `analytics_dev` | Different schemas per env |
| Explicit target | `schema='analytics'` | `analytics` | `analytics_analytics` | Never (mistake) |

---

## Advanced: Custom Macro Variations

### **Variation 1: Prefix Instead of Suffix**

**Default dbt:** `{target}_{custom}` → `analytics_staging`

**Custom Macro:**
```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name }}_{{ target.schema }}  -- Prefix
    {%- endif -%}
{%- endmacro %}
```

**Result:** `staging_analytics`

---

### **Variation 2: Environment-Based Logic**

```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if target.name == 'prod' -%}
        {%- if custom_schema_name is none -%}
            {{ target.schema }}
        {%- else -%}
            {{ custom_schema_name }}  -- Prod: use exact name
        {%- endif -%}
    {%- else -%}
        {%- if custom_schema_name is none -%}
            {{ target.schema }}
        {%- else -%}
            {{ target.schema }}_{{ custom_schema_name }}  -- Dev: append
        {%- endif -%}
    {%- endif -%}
{%- endmacro %}
```

**Behavior:**
- **Prod:** `schema='staging'` → `staging`
- **Dev:** `schema='staging'` → `analytics_dev_staging`

---

### **Variation 3: Node-Type Based**

```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if node.resource_type == 'model' -%}
        {%- if custom_schema_name is none -%}
            {{ target.schema }}
        {%- else -%}
            {{ custom_schema_name }}
        {%- endif -%}
    {%- elif node.resource_type == 'seed' -%}
        {{ target.schema }}_seeds
    {%- elif node.resource_type == 'snapshot' -%}
        {{ target.schema }}_snapshots
    {%- endif -%}
{%- endmacro %}
```

**Behavior:**
- Models: Use custom schema as-is
- Seeds: Always in `analytics_seeds`
- Snapshots: Always in `analytics_snapshots`

---

## Schema Strategy Recommendations

### **For Portfolio Projects:**
```sql
# profiles.yml
dev:
  schema: analytics

# All models: omit schema config
# Result: Everything in analytics
```

**Why:** Simple, clean, easy to explain in interviews

---

### **For Enterprise Projects:**
```sql
# profiles.yml
prod:
  schema: analytics_prod

# Staging models
{{ config(schema='staging') }}
# Result: analytics_prod_staging

# Marts models
{{ config(schema='marts') }}
# Result: analytics_prod_marts
```

**Why:** Clear data lineage, governance-friendly

---

### **For Multi-Tenant SaaS:**
```sql
# profiles.yml
client_a:
  schema: client_a
client_b:
  schema: client_b

# All models: omit schema config
# Result: client_a.model_name, client_b.model_name
```

**Why:** Data isolation, security, compliance

---

## Quick Reference Commands

### **Check Current Schema Behavior:**
```bash
# Compile without running
dbt compile --models model_name

# Check compiled SQL in:
# target/compiled/project_name/models/.../model_name.sql

# Look for: CREATE TABLE `project.schema_name.model_name`
```

### **Test Schema Creation:**
```bash
# Run single model
dbt run --models model_name

# Check database schema list
# BigQuery: Console → Schema list
# PostgreSQL: \dn in psql
# Snowflake: SHOW SCHEMAS;
```

### **Debug Macro Issues:**
```bash
# Clear cache
dbt clean

# Recompile
dbt compile

# Run with verbose logging
dbt run --models model_name --debug
```

---

## Summary

**Key Takeaways:**

1. **Default behavior:** `schema='X'` → creates `{target_schema}_{X}` (appending)
2. **To use target schema:** Omit `schema=` config entirely
3. **For exact control:** Add `generate_schema_name` macro
4. **Macros run first:** They generate SQL, don't execute in database
5. **Schema auto-creates:** dbt runs `CREATE SCHEMA IF NOT EXISTS`

**Decision Matrix:**

| Goal | Action |
|------|--------|
| All models in one schema | Omit schema config |
| Separate staging/marts | Use schema='staging', schema='marts' (accepts appending) |
| Exact schema names | Add generate_schema_name macro |
| Different envs | Use profiles.yml target schemas |

**Remember:** Schema naming is about organization and governance. Choose the pattern that matches your project's complexity and team's needs.

---

**Reference Guide Complete**

For questions or edge cases, check dbt docs: https://docs.getdbt.com/docs/build/custom-schemas

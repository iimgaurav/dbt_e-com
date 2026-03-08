# 📋 E-Commerce dbt Project - Complete Walkthrough

## Project Overview
This is a dbt (data build tool) project that processes e-commerce sales data using the **Medallion Architecture** (Bronze → Silver → Gold layers). The project transforms raw sales data into clean, structured fact and dimension tables for analytics.

**Project Name**: `dbt_ecom`  
**Profile**: `dbt_ecom`  
**Database**: PostgreSQL (`e_com`)  
**Schema**: `dev_schema`  
**Python/dbt Version**: Python 3.11 / dbt 1.11.6

---

## 📂 Project Structure

```
dbt_project/dbt_ecom/
├── dbt_project.yml          # Project configuration
├── .dbt/
│   └── profiles.yml         # Database credentials & connection config
├── models/                  # SQL transformation files
│   ├── bronze/              # Raw data layer (Views)
│   │   └── br_ecommerce_sales.sql
│   ├── silver/              # Cleaned & validated data (Tables)
│   │   └── sl_ecommerce_sales.sql
│   └── gold/                # Business-ready tables (Tables)
│       ├── fct_order.sql
│       ├── dim_customer.sql
│       └── dim_product.sql
├── seeds/                   # CSV data files
│   └── ecommerce_sales.csv  # Source data (1000 transactions)
├── tests/                   # Data quality tests
├── macros/                  # Reusable SQL functions
├── analyses/                # Ad-hoc analysis queries
└── snapshots/               # Historical data snapshots
```

---

## 🔄 Data Flow & Transformations

### Step 1: Seed Layer (Source Data)
**File**: `seeds/ecommerce_sales.csv`  
**Description**: Raw e-commerce sales data with 1000 transactions  
**Columns**: `transaction_id`, `order_date`, `customer_id`, `customer_name`, `country`, `product_id`, `product_category`, `quantity`, `price`, `order_status`

**Command to load**: `docker compose run --rm dbt seed`

---

### Step 2: BRONZE Layer (Raw Pass-through)
**File**: `models/bronze/br_ecommerce_sales.sql`  
**Materialization**: `VIEW` (lightweight, no storage)  
**Purpose**: Direct reference to seed data—no transformations yet

**SQL Logic**:
```sql
{{ config(materialized='view') }}

select *
from {{ ref('ecommerce_sales') }}
```

**Why a View?**: Bronze is a simple pass-through. Views don't store data, just reference the seed directly.

---

### Step 3: SILVER Layer (Cleaned & Validated)
**File**: `models/silver/sl_ecommerce_sales.sql`  
**Materialization**: `TABLE` (persistent storage)  
**Purpose**: Clean, deduplicate, and validate data

**Transformations Applied**:
1. **Type Casting**: Convert `order_date` from string to DATE
2. **Country Validation**: Standardize country codes (keep only US, UK, IN, DE, FR, CA, AU; others → 'UNKNOWN')
3. **Quantity Validation**: Ensure quantity > 0 (fallback to 1)
4. **Price Validation**: Ensure price > 0 (fallback to 0)
5. **Deduplication**: Remove duplicate transactions (keep latest by `order_date`)
6. **Filtering**: Only include records with non-null `customer_id` and orders before today

**SQL Logic** (full):
```sql
{{config(materialized='table') }}

with clean as(
select 
       transaction_id,
       cast(order_date as date) as order_date,
       customer_id, 
       customer_name,
       case
           when country in ('US', 'UK', 'IN', 'DE', 'FR' , 'CA', 'AU') then country
           else 'UNKNOWN'
       end as country,
         product_id,
         product_category,
         case 
              when quantity > 0 then quantity
              else 1
         end as quantity,
            case 
                when price > 0 then price
                else 0
            end as price,
            order_status
from {{ ref('br_ecommerce_sales') }}
where customer_id is not null
and cast(order_date as date) < current_date
),

deduplicated as(
    select *,
    row_number() over(partition by transaction_id order by order_date desc) as rn
    from clean

)

select * from deduplicated
where rn = 1
```

**Result**: Clean, single source of truth for all downstream models

---

### Step 4: GOLD Layer (Business-Ready Analytics)
The gold layer uses the clean silver data to create **fact and dimension tables** following the Star Schema pattern.

#### A. Fact Table: `fct_order.sql`
**Purpose**: Stores transactional facts (ONE ROW = ONE TRANSACTION)  
**Materialization**: `TABLE`

**Columns**:
- `transaction_id` (PK)
- `order_date`
- `customer_id` (FK to dim_customer)
- `product_id` (FK to dim_product)
- `quantity` (measure)
- `price` (measure)
- `total_amount` (calculated: quantity × price)

**SQL Logic**:
```sql
{{config(materialized='table') }}

select 
     transaction_id,
     order_date,
     customer_id,
     product_id,
     quantity,
     price,
     quantity * price as total_amount
from {{ ref('sl_ecommerce_sales') }}
```

**Use Cases**: Reports on order revenue, quantity sold, trends over time

---

#### B. Dimension Table: `dim_customer.sql`
**Purpose**: Stores customer attributes (ONE ROW = ONE UNIQUE CUSTOMER)  
**Materialization**: `TABLE`

**Columns**:
- `customer_id` (PK)
- `customer_name`
- `country`

**SQL Logic**:
```sql
{{config(materialized='table') }}

select distinct 
     customer_id, 
     customer_name,
     country
from {{ ref('sl_ecommerce_sales') }}
```

**Use Cases**: Customer segmentation, geographic analysis, customer lookup

---

#### C. Dimension Table: `dim_product.sql`
**Purpose**: Stores product attributes (ONE ROW = ONE UNIQUE PRODUCT)  
**Materialization**: `TABLE`

**Columns**:
- `product_id` (PK)
- `product_category`

**SQL Logic**:
```sql
{{config(materialized='table') }}

select distinct 
     product_id, 
     product_category
from {{ ref('sl_ecommerce_sales') }}
```

**Use Cases**: Product performance analysis, category-level reporting

---

## 📊 Data Flow Architecture (Medallion Pattern)

```
┌─────────────────────────────────────┐
│ 🌱 Seed Layer                       │
│ ecommerce_sales.csv                 │
│ (1000 transactions)                 │
└────────────────┬────────────────────┘
                 │ dbt seed
                 ▼
┌─────────────────────────────────────┐
│ 🔵 BRONZE LAYER                     │
│ br_ecommerce_sales                  │
│ (View: Raw data pass-through)       │
└────────────────┬────────────────────┘
                 │ ref transformation
                 ▼
┌─────────────────────────────────────┐
│ 🟢 SILVER LAYER                     │
│ sl_ecommerce_sales                  │
│ (Table: Cleaned & Deduplicated)     │
└────┬────────────────────────────┬───┘
     │                            │
     │ ref transformation         │ ref transformation
     ▼                            ▼
┌──────────────────┐    ┌──────────────────────┐
│ 🟡 GOLD - FACTS  │    │ 🟡 GOLD - DIMENSIONS │
├──────────────────┤    ├──────────────────────┤
│ fct_order        │    │ dim_customer         │
│ • transaction_id │    │ • customer_id        │
│ • order_date     │    │ • customer_name      │
│ • customer_id    │    │ • country            │
│ • product_id     │    └──────────────────────┘
│ • quantity       │
│ • price          │    ┌──────────────────────┐
│ • total_amount   │    │ dim_product          │
└──────────────────┘    ├──────────────────────┤
                        │ • product_id         │
                        │ • product_category   │
                        └──────────────────────┘
```

---

## Entity Relationship Diagram (Star Schema)

```
                    dim_customer
                   ┌────────────────┐
                   │  customer_id   │◄─────────┐
                   │  customer_name │          │
                   │  country       │          │
                   └────────────────┘          │
                                               │
                                           fct_order
                                       ┌───────────────┐
                                       │transaction_id │
                                       │order_date     │
                  ┌─────────────────────│customer_id    │
                  │                     │product_id     ├─────────────────┐
                  │                     │quantity       │                 │
                  │                     │price          │                 │
                  │                     │total_amount   │                 │
                  │                     └───────────────┘                 │
                  │                                                       │
                  │                                                       │
            dim_customer                                            dim_product
         ┌──────────────────┐                                  ┌──────────────────┐
         │  customer_id     │                                  │  product_id      │
         │  customer_name   │                                  │  product_category│
         │  country         │                                  └──────────────────┘
         └──────────────────┘
```

---

## 🚀 How to Run the Project

### 1. Start Services
```powershell
docker compose up postgres -d
```

### 2. Create dev_schema (First Time Only)
```powershell
docker compose exec postgres psql -U gau -d e_com -c "CREATE SCHEMA IF NOT EXISTS dev_schema;"
```

### 3. Load Seed Data
```powershell
docker compose run --rm dbt seed
# Output: Loaded 1000 rows into dev_schema.ecommerce_sales
```

### 4. Run All Models (Bronze → Silver → Gold)
```powershell
docker compose run --rm dbt run
# Builds all models in dependency order:
# 1. br_ecommerce_sales (view)
# 2. sl_ecommerce_sales (table)
# 3. fct_order, dim_customer, dim_product (tables)
```

### 5. Verify Models in Database
```powershell
docker compose exec postgres psql -U gau -d e_com -c "\dt dev_schema.*"
```

**Expected Output**:
```
        List of relations
  Schema    │       Name        │ Type  │ Owner
────────────┼──────────────────┼───────┼───────
 dev_schema │ dim_customer      │ table │ gau
 dev_schema │ dim_product       │ table │ gau
 dev_schema │ ecommerce_sales   │ table │ gau
 dev_schema │ fct_order         │ table │ gau
 dev_schema │ sl_ecommerce_sales│ table │ gau
```

### 6. Test Data Quality
```powershell
docker compose run --rm dbt test
```

### 7. Generate Documentation
```powershell
docker compose run --rm dbt docs generate
docker compose run --rm dbt docs serve  # View at http://localhost:8000
```

---

## 🔍 Key Concepts

| Layer | Type | Materialization | Purpose |
|-------|------|-----------------|---------|
| **Seed** | CSV | — | Raw source data (1000 rows) |
| **Bronze** | SQL View | View | Direct pass-through of seed data |
| **Silver** | SQL Model | Table | Cleaned, validated, deduplicated data |
| **Gold (Fact)** | SQL Model | Table | Transactional data for analysis |
| **Gold (Dimension)** | SQL Model | Table | Reference/lookup data |

---

## 📌 Current Configuration

**Database Connection** (`profiles.yml`):
```yaml
dbt_ecom:
  target: dev
  outputs:
    dev:
      type: postgres
      host: postgres          # Docker container name
      port: 5432              # Standard Postgres port
      user: gau               # From docker-compose.yml
      password: gau@123       # From docker-compose.yml
      dbname: e_com           # Database name
      schema: dev_schema      # Schema name
      threads: 1              # Single-threaded for dev
```

---

## 🎯 Next Steps

1. ✅ Seed data loaded into `dev_schema.ecommerce_sales`
2. ⏳ Run `dbt run` to build all models
3. ⏳ Create `tests/` for data quality checks
4. ⏳ Add `macros/` for reusable SQL functions
5. ⏳ Create `analyses/` for ad-hoc reports

---

## 📝 Model Dependencies

All models use `{{ ref() }}` for dependencies, which ensures dbt builds them in the correct order automatically:

```
ecommerce_sales (seed)
    ↓
br_ecommerce_sales (bronze view)
    ↓
sl_ecommerce_sales (silver table)
    ├→ fct_order (gold fact table)
    ├→ dim_customer (gold dimension table)
    └→ dim_product (gold dimension table)
```

---

**Document Version**: 1.0  
**Last Updated**: March 8, 2026  
**Project Status**: Development

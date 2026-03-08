# E-Commerce dbt Project

A data transformation project using dbt (data build tool) to process e-commerce sales data using the Medallion Architecture pattern.

## 🏗️ Architecture

This project follows the **Medallion Architecture**:
- **Bronze Layer**: Raw data pass-through (Views)
- **Silver Layer**: Cleaned and validated data (Tables)
- **Gold Layer**: Business-ready analytics tables (Fact & Dimension tables)

## 📋 Project Overview

- **Database**: PostgreSQL
- **dbt Version**: 1.11.6
- **Python Version**: 3.11
- **Data Volume**: 1000 e-commerce transactions

See [dbt_project/dbt_ecom/PROJECT_WALKTHROUGH.md](dbt_project/dbt_ecom/PROJECT_WALKTHROUGH.md) for detailed documentation.

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Git

### Setup & Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/iimgaurav/dbt_e-com.git
   cd e-com
   ```

2. **Start PostgreSQL service**
   ```powershell
   docker compose up postgres -d
   ```

3. **Create dev_schema (first time only)**
   ```powershell
   docker compose exec postgres psql -U gau -d e_com -c "CREATE SCHEMA IF NOT EXISTS dev_schema;"
   ```

4. **Load seed data**
   ```powershell
   docker compose run --rm dbt seed
   ```

5. **Run dbt models**
   ```powershell
   docker compose run --rm dbt run
   ```

6. **Run tests**
   ```powershell
   docker compose run --rm dbt test
   ```

7. **Generate documentation** (optional)
   ```powershell
   docker compose run --rm dbt docs generate
   docker compose run --rm dbt docs serve
   ```

## 📁 Project Structure

```
e-com/
├── dbt_project/dbt_ecom/          # Main dbt project
│   ├── models/
│   │   ├── bronze/                # Raw data (views)
│   │   ├── silver/                # Cleaned data (tables)
│   │   └── gold/                  # Analytics tables (tables)
│   ├── seeds/
│   │   └── ecommerce_sales.csv   # Source data (1000 rows)
│   ├── tests/                     # dbt tests for data quality
│   ├── dbt_project.yml            # dbt configuration
│   └── .dbt/profiles.yml          # Database credentials
├── data-source/
│   └── genrate-sales.py           # Python script to generate sample data
├── docker-compose.yml             # Docker services configuration
├── dockerfile                     # dbt Docker image
└── .github/workflows/
    └── dbt-ci-cd.yml              # GitHub Actions CI/CD pipeline
```

## 🔄 Data Models

### Bronze Layer
- `br_ecommerce_sales`: Raw seed data view

### Silver Layer
- `sl_ecommerce_sales`: Cleaned, deduplicated transactions

### Gold Layer (Analytics)
- `fct_order`: Fact table with transaction details
- `dim_customer`: Customer dimension table
- `dim_product`: Product dimension table

## 🧪 Testing

All tests are defined in the `tests/` directory. Run with:
```powershell
docker compose run --rm dbt test
```

## 📊 Documentation

Generate dbt documentation:
```powershell
docker compose run --rm dbt docs generate
docker compose run --rm dbt docs serve
```
Visit `http://localhost:8000` to view the docs.

## 🔐 CI/CD

This project includes automated CI/CD with GitHub Actions. On every push/PR:
- ✅ Validates dbt syntax (`dbt parse`)
- ✅ Loads seed data (`dbt seed`)
- ✅ Builds models (`dbt run`)
- ✅ Tests data quality (`dbt test`)
- ✅ Generates documentation (`dbt docs generate`)

View workflow: [.github/workflows/dbt-ci-cd.yml](.github/workflows/dbt-ci-cd.yml)

## 📝 Common Commands

| Command | Purpose |
|---------|---------|
| `dbt debug` | Test database connection |
| `dbt parse` | Validate dbt syntax |
| `dbt seed` | Load CSV data into database |
| `dbt run` | Execute dbt models |
| `dbt test` | Run data quality tests |
| `dbt docs generate` | Generate documentation |
| `dbt clean` | Remove dbt artifacts |

## 🛠️ Database Configuration

The `profiles.yml` file contains database credentials:
- **Host**: postgres (Docker container)
- **Port**: 5432
- **User**: gau
- **Password**: gau@123
- **Database**: e_com
- **Schema**: dev_schema

> ⚠️ **Security Note**: Never commit actual passwords. Use environment variables in production:
> ```yaml
> password: "{{ env_var('DBT_PASSWORD') }}"
> ```

## 📚 Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Medallion Architecture Pattern](https://www.databricks.com/blog/2022/06/24/easily-build-complex-pipelines-with-databricks-sql-and-delta-live-tables.html)

## 👤 Author

Navneet Gaurav

## 📄 License

This project is open source and available for educational purposes.

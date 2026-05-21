# From Raw Data to Revenue Insight — An E-Commerce Analytics Deep Dive

> *What does a business look like when you strip it down to its data?*
> This project takes six messy, disconnected e-commerce sources and builds a clean,
> integrated analytical system — uncovering revenue patterns, customer segments, and
> product trends through rigorous SQL analysis and Tableau visualisation.


---

## Project Overview

This is an end-to-end data analytics portfolio project built to mirror industry standards. Starting from six raw CSV files spanning two source systems (CRM and ERP), the project progresses through data engineering, statistical exploration, and advanced analytics, culminating in a set of executive-level Tableau dashboards.

The dataset covers **60,000+ e-commerce transactions** across a **4-year period (2010–2014)**, with records spanning customers, products, sales, and geography.

---

## Data Sources

The project draws from two simulated source systems:

**CRM System** — 3 files

| File | Description | Rows |
|---|---|---|
| cust_info.csv | Customer demographics and profile data | 18,000+ |
| prd_info.csv | Product catalogue with pricing and categorisation | 397 |
| sales_details.csv | Transactional sales records | 60,000+ |

**ERP System** — 3 files

| File | Description | Rows |
|---|---|---|
| CUST_AZ12.csv | Customer date of birth and gender | 18,000+ |
| LOC_A101.csv | Customer country and location data | 18,000+ |
| PX_CAT_G1V2.csv | Product category and subcategory mapping | 37 |

---

## Project Requirements

### Specifications

- **Data Sources**: Six raw CSV files from two source systems (CRM and ERP) simulating a real-world multi-system e-commerce environment
- **Data Ingestion**: Load raw data into the data warehouse exactly as-is, preserving source integrity for traceability and debugging
- **Data Transformation**: Clean, standardise, and enrich raw data into an analytical-ready format, resolving all quality issues identified during inspection
- **Data Quality Checks**: Validate all transformations before data integration, ensuring no dirty data reaches the analytical layer
- **Data Integration**: Consolidate data from both source systems into a unified analytical model, resolving key mismatches and structural differences between systems
- **Exploratory Data Analytics**: Profile the data statistically and dimensionally to understand its shape, distribution, and business characteristics before drawing conclusions
- **Advanced Analytics**: Apply analytical techniques including trend analysis, performance benchmarking, customer segmentation, and Pareto analysis to generate actionable business intelligence
- **Documentation**: Provide clear documentation including a data dictionary, architecture diagrams, and inline SQL commentary for both technical and non-technical audiences

---

## 01. Build a Data Warehouse (Data Engineering)

### Objective
Build a data warehouse that consolidates sales data, and supports data analytics and BI reporting.

### Data Architecture

This project is built on the **Medallion Architecture**, a three-layer design that progressively refines raw data into clean, integrated, and business-ready information.

![Data Architecture](docs/01_data_architecture.png)

| Layer | Object Type | Objective |
|---|---|---|
| **Bronze** | Tables | Raw data loaded as-is — traceability & debugging |
| **Silver** | Tables | Cleaned, standardised, and enriched data |
| **Gold** | Views | Business-ready Star Schema for BI & reporting |

### Data Flow

Data moves unidirectionally through the layers. Bronze feeds Silver,
Silver feeds Gold. No layer reads from a layer above it.

![Data Flow](docs/02_data_flow.png)

### Data Integration Model

The data integration model illustrates how the six source tables across the CRM and ERP systems relate to each other, and how they are joined to form the unified gold layer.

![Data Integration Model](docs/03_data_integration.png)

### Data Model

The gold layer is structured as a **Star Schema** — `gold.fact_orders` at the centre, joined to `gold.dim_customers` and `gold.dim_products`.

![Data Model](docs/04_data_model.png)

---

## 02. Analytics & BI Reporting (Data Analytics)

This section of the project is divided into two phases **Exploratory Data Analytics (EDA)** and **Advanced Data Analytics**.

### Objectives
Generate SQL and BI reports that draw insight into:

* **Product Performance**
* **Customer Performance**
* **Sales Trends**

---

## Executive Dashboards

Two interactive Tableau dashboards built directly on the gold report views, designed to give stakeholders a clear, executive-level view of product performance and customer behaviour across the 4-year sales period.

### Dashboard Architecture

The dashboard layout was planned before building — both dashboards follow the same container structure for visual consistency.

![Dashboard Architecture](docs/06_dashboard_architecture.png)

### Sales & Product Performance Dashboard

**Purpose:** Evaluate product profitability, revenue contribution, and margin performance across the active catalogue.

**Key questions answered:**
- How has revenue and profit trended year over year?
- Which categories and subcategories drive the most revenue and profit?
- Where is margin strength and weakness sitting across the catalogue?
- Which products are the top contributors to business performance?

**Core metrics:** Total Revenue · Total Profit · Profit Margin · Total Orders

![Sales & Product Performance Dashboard](reports/01_sales_product_performance_dashboard.png)

### Customer Performance Dashboard

**Purpose:** Assess customer profitability, acquisition trends, retention health, and demographic breakdown.

**Key questions answered:**
- How is the customer base growing and how many are new acquisitions?
- Which countries and demographics drive the most revenue?
- Who are our most valuable customers?
- How are customers distributed across age groups, gender, and marital status?

**Core metrics:** Total Customers · Average Order Value · Average Revenue Per Customer · Acquisition Rate

![Customer Performance Dashboard](reports/02_customer_performance_dashboard.png)

---

## Project Status

| Phase | Status |
|---|---|
| Phase 1 — Project Setup | ✅ Complete |
| Phase 2 — Data Loading | ✅ Complete |
| Phase 3 — Data Quality & Cleaning | ✅ Complete |
| Phase 4 — Data Integration | ✅ Complete |
| Phase 5a — Exploratory Data Analytics | ✅ Complete |
| Phase 5b — Advanced Analytics | ✅ Complete |
| Phase 6 — Tableau Dashboards | ✅ Complete |

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| **SQL Server** | Database engine — data storage, transformation, and all analytics |
| **SSMS** | Interface for interacting with SQL Server |
| **Tableau** | Interactive executive dashboards (coming soon) |
| **GitHub** | Version control and project documentation |
| **Draw.io** | Architecture, data flow, integration model, and data model diagrams |
| **Notion** | Project planning and task management |

---

## License

This project is licensed under the **MIT License**. You are free to use, modify, or share with proper attribution.

---

## About Me

Hi there! I'm **Otusanya Toyib Oluwatimilehin**, an Industrial Chemistry graduate from Olabisi Onabanjo University who made a deliberate pivot into data analytics — driven by a passion for turning raw, complex data into decisions that matter.

With a scientific background that sharpened my analytical thinking and attention to detail, I've been building practical, industry-standard skills across SQL, Tableau, and data modelling. This project represents that journey in action — not just learning tools, but applying them to real business problems the way a professional analyst would.

I'm currently seeking data analyst and data engineering roles where I can contribute rigorous thinking, clean analysis, and clear communication of insights.

📧 toyibotusanya@gmail.com
📞 07082154436












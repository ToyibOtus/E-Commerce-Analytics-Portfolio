# From Raw Data to Revenue Insight — An E-Commerce Analytics Deep Dive

> *What does a business look like when you strip it down to its data?*
> This project takes six messy, disconnected e-commerce sources and builds a clean,
> integrated analytical system — uncovering revenue patterns, customer segments, and
> product trends through rigorous SQL analysis and Tableau visualisation.

---

## 📌 Project Overview

This is an end-to-end data analytics portfolio project built to mirror industry standards.
Starting from six raw CSV files spanning two source systems (CRM and ERP), the project
progresses through data cleaning, integration, exploratory analysis, and advanced analytics —
culminating in a set of executive-level Tableau dashboards.

The dataset covers **60,000+ e-commerce transactions** across a **4-year period (2010–2014)**,
with records spanning customers, products, sales, and geography.

**Core objectives:**
- Apply rigorous data quality checks and resolve real-world data inconsistencies
- Build a clean, integrated analytical layer from multi-source raw data
- Develop strong statistical intuition through applied exploratory analysis
- Answer meaningful business questions using advanced SQL analytical techniques
- Communicate findings through professional Tableau dashboards

---

## 🗂️ Repository Structure

```
├── datasets/                  # Raw source CSV files (CRM + ERP)
│   ├── cust_info.csv
│   ├── prd_info.csv
│   ├── sales_details.csv
│   ├── CUST_AZ12.csv
│   ├── LOC_A101.csv
│   └── PX_CAT_G1V2.csv
│
├── scripts/                   # All SQL scripts, organised by phase
│   ├── 01_data_loading/       # Bulk load scripts for all source tables
│   ├── 02_data_cleaning/      # Cleaning views and transformation logic
│   ├── 03_data_integration/   # Unified dimension and fact views
│   ├── 04_eda/                # Exploratory data analysis queries
│   └── 05_advanced_analytics/ # Advanced analytics and reporting queries
│
├── tests/                     # Data quality validation scripts
│
├── docs/                      # Data dictionary, methodology notes
│
├── reports/                   # Tableau exports, PDF summaries, final report
│
└── README.md
```

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **SQL Server** | Data storage, cleaning, integration, and all analytics |
| **Tableau** | Interactive dashboards and data visualisation |
| **GitHub** | Version control and project documentation |

---

## 📂 Data Sources

The project draws from two simulated source systems:

**CRM System** — 3 files
| File | Description | Rows |
|---|---|---|
| `cust_info.csv` | Customer demographics and profile data | 18,493 |
| `prd_info.csv` | Product catalogue with pricing and categorisation | 397 |
| `sales_details.csv` | Transactional sales records | 60,398 |

**ERP System** — 3 files
| File | Description | Rows |
|---|---|---|
| `CUST_AZ12.csv` | Customer date of birth and gender | 18,484 |
| `LOC_A101.csv` | Customer country/location data | 18,484 |
| `PX_CAT_G1V2.csv` | Product category and subcategory mapping | 37 |

---

## 🔍 Project Phases

### Phase 1 — Project Setup
GitHub repository initialisation, folder structure, branch strategy, and README.

### Phase 2 — Database Setup & Data Loading
SQL Server database creation and bulk loading of all six source CSV files into raw staging tables.

### Phase 3 — Data Quality Checks & Cleaning
Systematic identification and resolution of data quality issues including null handling,
date format standardisation, whitespace trimming, gender value normalisation, and
sales integrity validation.

### Phase 4 — Data Integration
Key harmonisation across CRM and ERP sources, and construction of unified dimension
and fact views — forming the analytical foundation for all subsequent analysis.

### Phase 5a — Exploratory Data Analytics (EDA)
Structured exploration covering database profiling, date ranges, dimension cardinality,
measure distributions, magnitude analysis, and ranking analysis. Statistical techniques
applied include descriptive statistics, distribution analysis, percentiles, and outlier detection.

### Phase 5b — Advanced Data Analytics
Business-focused analytical techniques including change-over-time analysis, cumulative
revenue tracking, performance benchmarking, customer segmentation (RFM), part-to-whole
analysis, and cohort/retention analysis.

### Phase 6 — Tableau Dashboards
Three executive-level dashboards:
- **Sales Overview** — Revenue trends, KPIs, and year-over-year performance
- **Customer Dashboard** — Segments, demographics, geography, and RFM analysis
- **Product Dashboard** — Category performance, rankings, and revenue share

---

## 📈 Status

| Phase | Status |
|---|---|
| Phase 1 — Project Setup | ✅ Complete |
| Phase 2 — Data Loading | 🔄 In Progress |
| Phase 3 — Data Cleaning | ⏳ Pending |
| Phase 4 — Data Integration | ⏳ Pending |
| Phase 5a — EDA | ⏳ Pending |
| Phase 5b — Advanced Analytics | ⏳ Pending |
| Phase 6 — Tableau Dashboards | ⏳ Pending |

---

## 👤 Author
Hi there! I'm **Otusanya Toyib Oluwatimilehin**, a graduate of Industrial Chemistry graduate from Olabisi Onabanjo University 
who made a deliberate pivot into data analytics — driven by a passion for turning raw, complex data into decisions that matter.

<img src="https://cdn-icons-png.flaticon.com/128/724/724664.png" width="18" alt="Phone"/> **07082154436** 
<img src="https://cdn-icons-png.flaticon.com/128/732/732200.png" width="18" alt="E-mail"/> **toyibotusanya@gmail.com**

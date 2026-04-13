# Data Dictionary — Gold Layer

**Project:** From Raw Data to Revenue Insight — An E-Commerce Analytics Deep Dive
**Author:** Otusanya Toyib Oluwatimilehin
**Created:** April 2026
**GitHub:** [github.com/ToyibOtus](https://github.com/ToyibOtus)

---

## Overview

The gold layer is the business-ready tier of the Medallion Architecture, built on top of cleaned and integrated silver layer tables. It is the primary layer consumed for exploratory analysis, advanced analytics, and Tableau dashboard reporting.

All three objects are implemented as **SQL Server views** sitting over the silver layer. They expose clean, business-friendly column names and are structured as a **Star Schema** — the fact table at the centre, joined to dimension tables via surrogate keys.

| Layer | Object Type | Load Method | Objective |
|---|---|---|---|
| Bronze | Tables | Bulk insert | Raw data — traceability & debugging |
| Silver | Tables | Stored procedure | Cleaned & transformed data |
| Gold | Views | On-demand (views) | Business-ready data — Star Schema for BI & reporting |

---

## Objects

- [gold.dim_customers](#01-golddim_customers)
- [gold.dim_products](#02-golddim_products)
- [gold.fact_orders](#03-goldfact_orders)

---

## 01. gold.dim_customers

**Purpose:** Unified customer dimension view combining demographic, geographic, and account information from the CRM and ERP source systems.

| Attribute | Detail |
|---|---|
| Sources | `silver.crm_cust_info` + `silver.erp_cust_az12` + `silver.erp_loc_a101` |
| Join key | `crm_cust_info.cst_key = erp_cust_az12.cid = erp_loc_a101.cid` |
| Grain | One row per unique customer |

| Column | Data Type | Description |
|---|---|---|
| `customer_key` | INT | Surrogate key. System-generated integer that uniquely identifies each customer record in the gold layer. Used as the primary key and referenced by `gold.fact_orders`. |
| `customer_id` | INT | Natural key. Unique numerical identifier assigned to each customer in the source CRM system. |
| `customer_number` | NVARCHAR(50) | Business key. Alphanumeric customer reference code from the CRM system (e.g., AW00011000). |
| `first_name` | NVARCHAR(50) | Customer's first name. Null values from source replaced with `'N/A'`. |
| `last_name` | NVARCHAR(50) | Customer's last name. Null values from source replaced with `'N/A'`. |
| `country` | NVARCHAR(50) | Customer's country of residence, sourced from the ERP location table. Abbreviated codes (e.g., DE, US) expanded to full country names. Null values replaced with `'N/A'`. |
| `gender` | NVARCHAR(50) | Customer's gender. CRM is the primary source; ERP used as fallback where CRM value is missing. Standardised to `'Male'`, `'Female'`, or `'N/A'`. |
| `marital_status` | NVARCHAR(50) | Customer's marital status. Standardised to `'Married'`, `'Single'`, or `'N/A'`. |
| `birth_date` | DATE | Customer's date of birth, sourced from the ERP system. Future dates in the source data have been nullified. |
| `create_date` | DATE | The date the customer record was created in the CRM system. |

---

## 02. gold.dim_products

**Purpose:** Unified product dimension view combining product details from the CRM with category and subcategory classifications from the ERP. Contains only currently active products.

| Attribute | Detail |
|---|---|
| Sources | `silver.crm_prd_info` + `silver.erp_px_cat_g1v2` |
| Join key | `crm_prd_info.cat_id = erp_px_cat_g1v2.id` |
| Filter | `prd_end_dt IS NULL` — active products only, historical versions excluded |
| Grain | One row per active product |

| Column | Data Type | Description |
|---|---|---|
| `product_key` | INT | Surrogate key. System-generated integer that uniquely identifies each product record in the gold layer. Used as the primary key and referenced by `gold.fact_orders`. |
| `product_id` | INT | Natural key. Unique numerical identifier assigned to each product in the source CRM system. |
| `product_number` | NVARCHAR(50) | Business key. Alphanumeric product reference code from the CRM system (e.g., FR-R92B-58). |
| `product_name` | NVARCHAR(250) | Descriptive name of the product as recorded in the CRM system. |
| `product_line` | NVARCHAR(50) | Product line classification. Standardised from source codes: M = Mountain, R = Road, S = Other Sales, T = Touring. Unrecognised codes replaced with `'N/A'`. |
| `category_id` | NVARCHAR(50) | Category reference code derived from the product key, used to join to the ERP category table (e.g., AC_HE, BI_RB). |
| `category` | NVARCHAR(50) | Broad product classification from the ERP category table (e.g., Accessories, Bikes, Clothing, Components). Null values replaced with `'N/A'`. |
| `subcategory` | NVARCHAR(50) | Detailed product classification within each category (e.g., Helmets, Road Bikes, Jerseys). Null values replaced with `'N/A'`. |
| `maintenance` | NVARCHAR(50) | Indicates whether the product requires ongoing maintenance. Values: `'Yes'` or `'No'`. Null values replaced with `'N/A'`. |
| `cost` | INT | The standard cost of one unit of the product as recorded in the CRM system. |
| `start_date` | DATE | The date from which this product version became active in the CRM system. |

---

## 03. gold.fact_orders

**Purpose:** Central fact view containing all transactional sales records. Each row represents a single line item in a sales order. Joins to both dimension views via surrogate keys to enable customer and product analysis.

| Attribute | Detail |
|---|---|
| Source | `silver.crm_sales_details` |
| Joins | `gold.dim_customers` (via customer_id) + `gold.dim_products` (via product_number) |
| Grain | One row per order line item |
| Date range | 2010-12-29 to 2014-01-28 (4 years of transaction history) |

| Column | Data Type | Description |
|---|---|---|
| `order_number` | NVARCHAR(50) | Sales order identifier from the CRM system. A single order number may appear across multiple rows where multiple products were ordered (e.g., SO43697). |
| `product_key` | INT | Foreign key referencing `gold.dim_products`. Links each transaction to the product dimension. |
| `customer_key` | INT | Foreign key referencing `gold.dim_customers`. Links each transaction to the customer dimension. |
| `order_date` | DATE | The date the order was placed by the customer. Source stored as integer (YYYYMMDD) — converted to DATE in the silver layer. Invalid formats nullified. |
| `ship_date` | DATE | The date the order was physically shipped to the customer. |
| `due_date` | DATE | The expected delivery date committed to the customer. |
| `sales_amount` | INT | Total revenue amount for the order line. Where source value was null or inconsistent with quantity × price, recalculated as `ABS(quantity × price)`. |
| `quantity` | INT | Number of product units included in the order line. |
| `price` | INT | Unit selling price of the product for this order line. Negative values converted to absolute value. Null values derived as `sales_amount / quantity`. |

---

## Relationships

The gold layer is structured as a Star Schema. `gold.fact_orders` sits at the centre and connects to both dimension views through surrogate keys.

| Relationship | Fact key | Dimension key | Join type |
|---|---|---|---|
| `fact_orders` → `dim_customers` | `customer_key` | `customer_key` | LEFT JOIN |
| `fact_orders` → `dim_products` | `product_key` | `product_key` | LEFT JOIN |

---

## Data Quality Notes

The following issues were identified in the raw source data and resolved in the silver cleaning layer prior to gold layer integration.

| Source table | Issue | Resolution |
|---|---|---|
| `crm_cust_info` | ~25% null gender values | ERP gender used as fallback; remaining nulls set to `'N/A'` |
| `crm_cust_info` | Whitespace in name fields | `TRIM()` applied to all name fields |
| `crm_cust_info` | Duplicate customer records | Deduplicated using `ROW_NUMBER()` — most recent record retained |
| `crm_cust_info` | Null customer IDs | Rows with null `cst_id` excluded from silver layer |
| `crm_prd_info` | Invalid `prd_end_dt` (before start date) | Corrected using `LEAD()` to derive end date from next version's start date |
| `crm_sales_details` | Dates stored as integers | Converted from YYYYMMDD integer to DATE; invalid formats nullified |
| `crm_sales_details` | 35 rows where sales ≠ qty × price | Sales recalculated as `ABS(quantity × price)` |
| `crm_sales_details` | Null and negative prices | Nulls derived from `sales / quantity`; negatives converted via `ABS()` |
| `erp_cust_az12` | Future birth dates | Dates beyond `GETDATE()` nullified |
| `erp_cust_az12` | Inconsistent gender values | Standardised: Male/M/M → `'Male'`, Female/F/F → `'Female'`, rest → `'N/A'` |
| `erp_cust_az12` | `NAS` prefix in customer key | Prefix stripped to harmonise with CRM customer key format |
| `erp_loc_a101` | Dashes in customer key | Dashes removed to harmonise with CRM customer key format |
| `erp_loc_a101` | Abbreviated country codes | `DE` → Germany, `US`/`USA` → United States |

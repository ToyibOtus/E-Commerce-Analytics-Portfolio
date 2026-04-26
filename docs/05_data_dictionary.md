# Data Dictionary — Gold Layer

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

- gold.dim_customer
- gold.dim_products
- gold.fact_orders

---

## 01. gold.dim_customers

**Purpose:** Unified customer dimension view combining demographic, geographic, and account information from the CRM and ERP source systems.

| Column | Data Type | Description |
|---|---|---|
| customer_key | INT | Surrogate key. System-generated integer that uniquely identifies each customer record in the gold layer. Used as the primary key and referenced by `gold.fact_orders`. |
| customer_id | INT | Natural key. Unique numerical identifier assigned to each customer in the source CRM system. |
| customer_number | NVARCHAR(50) | Business key. Alphanumeric customer reference code from the CRM system (e.g., AW00011000). |
| first_name | NVARCHAR(50) | Customer's first name. Null values from source replaced with `'N/A'`. |
| last_name | NVARCHAR(50) | Customer's last name. Null values from source replaced with `'N/A'`. |
| country | NVARCHAR(50) | Customer's country of residence, sourced from the ERP location table. Abbreviated codes (e.g., DE, US) expanded to full country names. Null values replaced with `'N/A'`. |
| gender | NVARCHAR(50) | Customer's gender. CRM is the primary source; ERP used as fallback where CRM value is missing. Standardised to `'Male'`, `'Female'`, or `'N/A'`. |
| marital_status | NVARCHAR(50) | Customer's marital status. Standardised to `'Married'`, `'Single'`, or `'N/A'`. |
| birth_date | DATE | Customer's date of birth, sourced from the ERP system. Future dates in the source data have been nullified. |
| create_date | DATE | The date the customer record was created in the CRM system. |

---

## 02. gold.dim_products

**Purpose:** Unified product dimension view combining product details from the CRM with category and subcategory classifications from the ERP. Contains only currently active products.

| Column | Data Type | Description |
|---|---|---|
| product_key | INT | Surrogate key. System-generated integer that uniquely identifies each product record in the gold layer. Used as the primary key and referenced by `gold.fact_orders`. |
| product_id | INT | Natural key. Unique numerical identifier assigned to each product in the source CRM system. |
| product_number | NVARCHAR(50) | Business key. Alphanumeric product reference code from the CRM system (e.g., FR-R92B-58). |
| product_name | NVARCHAR(250) | Descriptive name of the product as recorded in the CRM system. |
| product_line | NVARCHAR(50) | Product line classification. Standardised from source codes: M = Mountain, R = Road, S = Other Sales, T = Touring. Unrecognised codes replaced with `'N/A'`. |
| category_id | NVARCHAR(50) | Category reference code derived from the product key, used to join to the ERP category table (e.g., AC_HE, BI_RB). |
| category | NVARCHAR(50) | Broad product classification from the ERP category table (e.g., Accessories, Bikes, Clothing, Components). Null values replaced with `'N/A'`. |
| subcategory | NVARCHAR(50) | Detailed product classification within each category (e.g., Helmets, Road Bikes, Jerseys). Null values replaced with `'N/A'`. |
| maintenance | NVARCHAR(50) | Indicates whether the product requires ongoing maintenance. Values: `'Yes'` or `'No'`. Null values replaced with `'N/A'`. |
| cost | INT | The standard cost of one unit of the product as recorded in the CRM system. |
| start_date | DATE | The date from which this product version became active in the CRM system. |

---

## 03. gold.fact_orders

**Purpose:** Central fact view containing all transactional sales records. Each row represents a single line item in a sales order. Joins to both dimension views via surrogate keys to enable customer and product analysis.

| Column | Data Type | Description |
|---|---|---|
| order_number | NVARCHAR(50) | Sales order identifier from the CRM system. A single order number may appear across multiple rows where multiple products were ordered (e.g., SO43697). |
| product_key | INT | Foreign key referencing `gold.dim_products`. Links each transaction to the product dimension. |
| customer_key | INT | Foreign key referencing `gold.dim_customers`. Links each transaction to the customer dimension. |
| order_date | DATE | The date the order was placed by the customer. Source stored as integer (YYYYMMDD) — converted to DATE in the silver layer. Invalid formats nullified. |
| ship_date | DATE | The date the order was physically shipped to the customer. |
| due_date | DATE | The expected delivery date committed to the customer. |
| sales_amount | INT | Total revenue amount for the order line. Where source value was null or inconsistent with quantity × price, recalculated as `ABS(quantity × price)`. |
| quantity | INT | Number of product units included in the order line. |
| price | INT | Unit selling price of the product for this order line. Negative values converted to absolute value. Null values derived as `sales_amount / quantity`. |



## 04. gold.customer_report

**Purpose:** Comprehensive customer analytics view consolidating demographic, behavioural, financial, and segmentation metrics for every customer. Designed as a direct Tableau data source for customer dashboards, segmentation analysis, and retention reporting.

| Attribute | Detail |
|---|---|
| Sources | `gold.fact_orders` + `gold.dim_customers` + `gold.dim_products` |
| Grain | One row per unique customer |
| Reference date | 2014-01-31 (end of last observed month — used for recency and age calculations) |

### Segmentation Models

**Composite Performance Score** — a weighted `PERCENT_RANK` score across five metrics classifies each customer as VIP, Regular, or New.

| Metric | Weight |
|---|---|
| Revenue | 40% |
| Profit | 30% |
| Orders | 15% |
| Lifespan | 10% |
| Recency | 5% |

| Label | Score Range |
|---|---|
| VIP | ≤ 0.30 |
| Regular | 0.31 – 0.70 |
| New | > 0.70 |

**RFM Segmentation** — threshold-based scoring calibrated to the durable goods nature of the business. All three dimensions use `CASE`-based thresholds rather than `NTILE` due to distribution characteristics identified during measure exploration.


| RFM Segment | Description |
|---|---|
| Champion | Recently active, high frequency, high spend |
| High-Value Loyal Customer | Loyal buyer with premium monetary value |
| Mid-Value Loyal Customer | Loyal buyer with moderate monetary value |
| Low-Value Loyal Customer | Loyal buyer with low monetary value |
| Potential Loyalist | Recent buyer with growth potential |
| Needs Attention | Moderate engagement showing signs of decline |
| Cannot Lose Them | Historically high-value but recently inactive |
| At Risk Customers | Previously active, now lapsing |
| Recent Customer | Very recent first-time buyer |
| Potentially Lost Customers | Low engagement across all three dimensions |

### Columns

| Column | Data Type | Description |
|---|---|---|
| customer_key | BIGINT | Surrogate key referencing `gold.dim_customers`. |
| customer_id | INT | Natural key from the source CRM system. |
| customer_number | NVARCHAR(50) | Alphanumeric business key from the CRM system. |
| customer_name | NVARCHAR(101) | Customer full name. |
| country | NVARCHAR(50) | Customer's country of residence. |
| gender | NVARCHAR(50) | Customer's gender — standardised to `'Male'`, `'Female'`, or `'N/A'`. |
| marital_status | NVARCHAR(50) | Customer's marital status — `'Married'`, `'Single'`, or `'N/A'`. |
| customer_status | VARCHAR(7) | Composite performance segment — `'VIP'`, `'Regular'`, or `'New'`. |
| customer_rfm_segment | VARCHAR(26) | RFM behavioural segment label (see segmentation table above). |
| birth_date | DATE | Customer's date of birth. |
| age | INT | Customer's age as at the reference date (2014-01-31). Accounts for whether the birthday has occurred within the reference year. |
| age_group | VARCHAR(8) | Age bracket — `'Below 20'`, `'20-29'`, `'30-39'`, `'40-49'`, or `'Above 49'`. |
| first_order_date | DATE | Date of the customer's first recorded transaction. |
| last_order_date | DATE | Date of the customer's most recent transaction. |
| lifespan_month | INT | Months between first and last order dates. Indicator of customer tenure and loyalty. |
| recency_month | INT | Months since the customer's last order, relative to the reference date. Lower values indicate more recent activity. |
| total_products | INT | Total number of distinct products ordered by the customer. |
| total_orders | INT | Total number of distinct orders placed across the customer's lifetime. |
| total_quantity | INT | Total units purchased across all orders. |
| total_sales | INT | Total revenue generated by the customer across all transactions. |
| total_profit | INT | Total profit generated, calculated as `total_sales - (cost × quantity)`. |
| avg_order_value | INT | Average revenue per order — `total_sales / total_orders`. Returns 0 if no orders. |
| avg_monthly_spend | INT | Average revenue per month of active lifespan — `total_sales / lifespan_month`. Returns `total_sales` if lifespan is 0 months (single-month customers). |
| percent_profit_margin | FLOAT | Customer's overall profit margin as a percentage — `(total_profit / total_sales) × 100`. Returns 0 if no sales. |
| avg_profit_per_order | INT | Average profit generated per order — `total_profit / total_orders`. Returns 0 if no orders. |
| avg_profit_per_quantity | INT | Average profit generated per unit sold — `total_profit / total_quantity`. Returns 0 if no quantity. |

---

## 05. gold.product_report

**Purpose:** Comprehensive product analytics view consolidating transactional, financial, lifecycle, and segmentation metrics for every active product. Designed as a direct Tableau data source for product performance dashboards, catalogue analysis, and margin reporting.

| Attribute | Detail |
|---|---|
| Sources | `gold.fact_orders` + `gold.dim_products` |
| Grain | One row per active product |
| Reference date | 2014-01-31 (end of last observed month — used for recency calculations) |

### Segmentation Models

**Composite Performance Score** — a weighted `PERCENT_RANK` score across five metrics classifies each product as High, Mid, or Low Performer.

| Metric | Weight |
|---|---|
| Revenue | 40% |
| Profit | 30% |
| Orders | 15% |
| Lifespan | 10% |
| Recency | 5% |

| Label | Score Range |
|---|---|
| High Performer | ≤ 0.30 |
| Mid Performer | 0.31 – 0.70 |
| Low Performer | > 0.70 |

**Cost Tier** — products classified by unit cost into four tiers.

| Label | Cost Range |
|---|---|
| Low Cost Product | ≤ $100 |
| Mid Cost Product | $101 – $500 |
| High Cost Product | $501 – $1,000 |
| Very High Cost Product | > $1,000 |

**Profit Margin Status** — thresholds anchored to the actual margin distribution rather than absolute profitability benchmarks. Since every active product generates a positive margin (range: 22.22% to 75.00%, mean: 44.04%, CV: 27.93%), labels reflect performance relative to catalogue average using statistical boundary points — P25 (36.30%), mean (44.04%), and P75 (50.00%).

| Label | Margin Range | Interpretation |
|---|---|---|
| Low Margin | < 36.30% | Below P25 — bottom quarter of catalogue |
| Below Average Margin | 36.30% – 44.04% | Between P25 and mean — below catalogue average |
| Above Average Margin | 44.04% – 50.00% | Between mean and P75 — above catalogue average |
| High Margin | ≥ 50.00% | Above P75 — top quarter of catalogue |

### Columns

| Column | Data Type | Description |
|---|---|---|
| product_key | INT | Surrogate key referencing `gold.dim_products`. |
| product_id | INT | Natural key from the source CRM system. |
| product_name | NVARCHAR(250) | Descriptive name of the product. |
| product_line | NVARCHAR(50) | Product line classification — Mountain, Road, Other Sales, Touring, or `'N/A'`. |
| category | NVARCHAR(50) | Broad product classification (e.g., Bikes, Accessories, Clothing). |
| subcategory | NVARCHAR(50) | Detailed product classification within each category. |
| maintenance | NVARCHAR(50) | Whether the product requires ongoing maintenance — `'Yes'` or `'No'`. |
| product_performance_status | VARCHAR(14) | Composite performance segment — `'High Performer'`, `'Mid Performer'`, or `'Low Performer'`. |
| profit_margin_status | VARCHAR(20) | Margin classification relative to catalogue distribution — see segmentation table above. |
| product_cost_status | VARCHAR(22) | Cost tier classification — see segmentation table above. |
| cost | INT | Standard unit cost of the product from the CRM system. |
| first_order_date | DATE | Date of the product's first recorded transaction. |
| last_order_date | DATE | Date of the product's most recent transaction. |
| avg_shipping_days | INT | Average number of days between order date and ship date across all transactions. |
| lifespan_month | INT | Months between first and last order dates. Indicator of product maturity and commercial longevity. |
| recency_month | INT | Months since the product's last order, relative to the reference date. Lower values indicate more recently active products. |
| total_customers | INT | Total number of distinct customers who ordered this product. |
| total_orders | INT | Total number of distinct orders containing this product. |
| total_quantity | INT | Total units of this product sold across all orders. |
| total_sales | INT | Total revenue generated by this product across all transactions. |
| total_profit | INT | Total profit generated, calculated as `total_sales - (cost × quantity)`. |
| weighted_avg_price | INT | Volume-weighted average selling price — `total_sales / total_quantity`. More accurate than simple average price when order sizes vary. |
| avg_order_revenue | INT | Average revenue per order — `total_sales / total_orders`. Returns 0 if no orders. |
| avg_monthly_revenue | INT | Average revenue per month of active lifespan — `total_sales / lifespan_month`. Returns `total_sales` if lifespan is 0 months. |
| percent_profit_margin | FLOAT | Product's lifetime profit margin as a percentage — `(total_profit / total_sales) × 100`. Returns 0 if no sales. |
| avg_profit_per_order | INT | Average profit generated per order — `total_profit / total_orders`. Returns 0 if no orders. |
| avg_profit_per_quantity | INT | Average profit generated per unit sold — `total_profit / total_quantity`. Returns 0 if no quantity. |

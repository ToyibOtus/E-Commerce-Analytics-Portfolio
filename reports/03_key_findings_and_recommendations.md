# E-Commerce Analytics — Key Findings & Strategic Recommendations

**Project:** From Raw Data to Revenue Insight; **Author:** Otusanya Toyib Oluwatimilehin; 
**Period Analysed:** 2011 – 2013 (2010 excluded due to incomplete records); **Dashboards:** [View on Tableau Public](https://public.tableau.com/app/profile/toyib.otusanya/viz/ProductCustomerPerformanceDashboards/SalesDashboard)

---

## Executive Summary

Analysis of four years of e-commerce transaction data reveals a business that is growing in volume but structurally fragile. Revenue is overwhelmingly concentrated in a single product category — Bikes — which accounts for 96.46% of total revenue, while nearly half the product catalogue has never been ordered. Customer growth is almost entirely dependent on new acquisitions rather than retention, with 92.37% of customers placing only one or two orders. The most immediate opportunities for sustainable growth lie in catalogue rationalisation, VIP customer retention, and a cross-sell strategy that moves existing bike buyers into accessories and clothing. Without deliberate action on these fronts, the business remains heavily exposed to any disruption in its core bike product segment.

---

## 01. Product Portfolio Analysis

### Findings

More than half the product catalogue has never generated a single order. Of the 295 products in the active catalogue, only 130 — just 44.07% — have ever been purchased. The remaining 165 products (55.93%) have zero transaction history.

Breaking this down by category reveals the full picture:

| Category | Never Ordered | % of Total Portfolio | Notes |
|---|---|---|---|
| Components | 127 | 43.05% | No product in this category has ever been ordered |
| N/A  | 7 | 2.37% | Uncategorised products with no order history |
| Bikes | 9 | 3.05% | Only 9 of 97 Bike products never ordered |
| Accessories | 7 | 2.37% | 7 of 29 Accessories never ordered |
| Clothing | 15 | 5.08% | 15 of 35 Clothing products never ordered |

The Components category is the starkest finding — 127 of the 165 never-ordered products belong here, accounting for 43.05% of the entire product portfolio with zero revenue contribution across the full four-year period. An additional 7 products with unassigned category labels (N/A) have also never been ordered, bringing the total dead weight to 134 products. Bikes, by contrast, have the strongest catalogue utilisation with only 9 of 97 products never ordered.

Revenue concentration is extreme. Bikes account for **96.46% of total revenue**, leaving Accessories and Clothing as marginal contributors despite representing a meaningful share of the catalogue. Pareto analysis confirms this concentration — 26.92% of ordered products generate 80.84% of total revenue.

From a product revenue segmentation perspective, 11 products have individually generated over $1,000,000 in revenue, 5 products have exceeded $500,000, and 37 have exceeded $100,000. These 53 products are the financial backbone of the business.

### Recommendations

**Discontinue or review the entire Components category.** 130 products with zero sales over a four-year period represent dead inventory carrying real costs in storage, supplier relationships, and catalogue management. A formal review should determine whether these products serve a strategic purpose — such as supporting after-sales service for bike purchases — or whether they should be delisted entirely.

**Prioritise the 9 never-ordered Bike products.** Unlike Components, these are in the highest-revenue category and their absence from order history likely reflects a marketing or visibility problem rather than a demand problem. Targeted promotions or bundling with best-selling models could unlock latent demand.

**Accelerate Accessories and Clothing sell-through.** The 7 unordered Accessories and 15 unordered Clothing products should be reviewed for discontinuation or repositioned as cross-sell bundles attached to bike purchases. A customer buying a $2,000 Mountain Bike is a prime target for a helmet, jersey, and cycling shoes — products that currently sit unordered in the catalogue.

**Protect and invest in the top 53 revenue-generating products.** These products drive the overwhelming majority of business revenue. Supply chain reliability, marketing visibility, and inventory depth for these products should be non-negotiable priorities.

---

## 02. Revenue & Sales Trend Analysis

### Findings

The business shows a non-linear growth trajectory. Revenue and profit declined from 2011 to 2012 before recovering sharply in 2013.

The 2011 to 2012 decline is explained by a significant drop in weighted average price — from $3,192 to $1,719 — a reduction of 46%. Although order volume increased from 2,216 to 3,397 during the same period, the volume growth was insufficient to compensate for the pricing decline.

The 2012 to 2013 recovery is even more striking. Weighted average price fell further from $1,719 to $309 — a decline of 82% — yet revenue surged dramatically. This suggests the price reduction triggered a substantial increase in order volume and new customer acquisition, with 77.01% of total orders occurring in 2013, generating 55.77% of total revenue across the entire four-year period.

At the transactional level, the revenue distribution is heavily right-skewed. The average transaction value of $486 is more than sixteen times the median transaction value of $30 — a clear signal that a small number of very large orders are inflating the average. Specifically, 15.87% of transactions exceeded the statistical upper boundary of $1,338 and collectively accounted for 81.22% of total revenue.

### Recommendations

**Investigate the pricing strategy that drove 2013 growth.** The dramatic price reduction that preceded the 2013 revenue surge raises a critical question — was this a deliberate strategic decision or an uncontrolled pricing shift? If deliberate, the elasticity of demand at lower price points should be formally modelled to identify the optimal pricing band that maximises revenue rather than just volume.

**Do not rely on average transaction value as a performance metric.** With a coefficient of variation of 191%, the mean is statistically unreliable. Internal reporting should use median transaction value and revenue-per-segment breakdowns rather than averages, which mask the true distribution of order behaviour.

**Monitor the concentration of annual revenue in 2013.** The fact that 77% of orders and over half of total revenue occurred in a single year is a concentration risk. Whether 2013 represents a structural inflection point or a temporary spike will only become clear with 2014 full-year data — but the business should not plan future resource allocation assuming 2013 performance levels will persist without the conditions that drove them.

---

## 03. Customer Acquisition & Retention Analysis

### Findings

Business growth is almost entirely driven by new customer acquisition rather than repeat purchases. This is consistent with the nature of the product — bikes are durable goods with natural repurchase cycles of three to seven years — but it creates a structurally fragile revenue model.

92.37% of customers have placed only one or two orders. Retention and acquisition analysis confirms that the business acquires new customers each year but retains very few at the transactional level. New customer acquisition accelerated sharply in 2013 in line with the pricing shift, confirming that the revenue surge was acquisition-led.

Customer revenue concentration mirrors the product concentration finding. 80.01% of revenue is generated by 27.86% of customers. VIP customers — classified by composite performance score — represent 30.92% of the total customer base but have contributed 83.17% of total revenue.

RFM analysis of the VIP segment reveals three distinct sub-groups of strategic importance:

| VIP Sub-Segment | % of VIPs | Revenue Contribution |
|---|---|---|
| Potential Loyalists | 78.42% | 57.80% |
| High-Value Loyal Customers | 13.90% | 18.42% |
| Needs Attention (At Risk) | 4.45% | 3.08% |

### Recommendations

**Implement a structured retention programme targeting Potential Loyalists.** This segment represents 78.42% of VIP customers and 57.80% of total revenue — the single largest revenue-at-risk group in the business. These are customers with strong monetary value but low frequency and moderate recency. The priority is to increase purchase frequency through accessory and apparel cross-selling before their natural bike repurchase cycle arrives.

**Act urgently on the Needs Attention VIP segment.** Although this group represents only 4.45% of VIPs and 3.08% of revenue, their trajectory is downward. These are high-value customers showing declining engagement. A targeted win-back campaign — personalised outreach, exclusive offers, or product recommendations based on their previous purchase history — should be launched before they transition to the At Risk or Lost segments.

**Build a cross-sell engine around bike purchases.** Given that 62.86% of customers placed exactly one order and most of those orders were bike purchases, the most accessible retention lever is not convincing them to buy a second bike — it is engaging them for accessories and clothing purchases between their bike upgrade cycles. A post-purchase email sequence recommending helmets, jerseys, and cycling accessories within 30 to 60 days of a bike purchase would directly address the one-time buyer problem without requiring a second high-value purchase decision.

**Reduce dependence on acquisition as the sole growth lever.** A business where 92.37% of customers order only once or twice is perpetually dependent on finding new customers to replace lost ones. Even a modest improvement in retention — converting 10% of one-time buyers into two-time buyers — would meaningfully reduce this dependence and improve the predictability of revenue.

---

## 04. Profitability & Margin Analysis

### Findings

Every active product in the catalogue generates a positive profit margin — the business has no loss-making products. Profit margin ranges from 22.22% to 75.00% across the catalogue, with a mean of 44.04% and a coefficient of variation of 27.93% — a well-behaved, normally distributed metric unlike the heavily skewed revenue distribution.

Using catalogue distribution quartiles as benchmarks, products are classified as follows:

| Margin Status | Threshold | Interpretation |
|---|---|---|
| High Margin | ≥ 50.00% | Top 25% of catalogue |
| Above Average Margin | 44.04% – 50.00% | Between mean and P75 |
| Below Average Margin | 36.30% – 44.04% | Between P25 and mean |
| Low Margin | < 36.30% | Bottom 25% of catalogue |

### Recommendations

**Use margin status alongside revenue in all product prioritisation decisions.** A product can be a high revenue contributor but a low margin performer — these products need pricing attention. Conversely, high margin but low revenue products represent an opportunity to increase volume without sacrificing profitability.

**Explore selective price increases on top-performing Bike products.** Premium sporting goods typically exhibit relatively inelastic demand — customers who want a specific Mountain Bike model are unlikely to abandon the purchase over a 5 to 10% price increase. A targeted price increase on the top 11 products generating over $1,000,000 in revenue could meaningfully improve total profit without requiring additional transaction volume.

---

## Summary of Priority Actions

| Priority | Action | Segment Impacted |
|---|---|---|
| 🔴 Urgent | Launch win-back campaign for At Risk VIP customers | 4.45% of VIPs, 3.08% of revenue |
| 🔴 Urgent | Review and discontinue non-performing Components catalogue | 44.10% of product portfolio |
| 🟡 High | Implement post-purchase cross-sell programme for bike buyers | 62.86% one-time buyers |
| 🟡 High | Increase marketing investment in top 53 revenue-generating products | 90%+ of total revenue |
| 🟡 High | Investigate and promote the 9 never-ordered Bike products | Highest-value category |
| 🟢 Medium | Model price elasticity to optimise pricing on top bike models | Revenue maximisation |
| 🟢 Medium | Review 15 never-ordered Clothing and 7 Accessories products | Catalogue rationalisation |
| 🟢 Medium | Build internal reporting on median transaction value — retire mean | Accurate performance tracking |

---

*This report was generated as part of the From Raw Data to Revenue Insight analytics portfolio project. All findings are derived from SQL-based statistical and advanced analytics performed on a simulated e-commerce dataset covering 2010–2014.*

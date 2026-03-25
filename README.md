<p align="center">
  <img src="images/logo_horizontal.png" width="400">
</p>

# Venturo Electronics — Performance Analysis 2022–2025

## Table of Contents
- [Client Background](#client-background)
- [Executive Summary](#executive-summary)
- [Data Structure & ERD](#data-structure--erd)
- [Insights Deep Dive](#insights-deep-dive)
- [Recommendations](#recommendations)
- [Caveats & Assumptions](#caveats--assumptions)

---

## Client Background

Venturo Electronics is a US-based direct-to-consumer electronics retailer serving a global customer base across four regions — NA, EMEA, LATAM, and APAC. Founded in 2014, the company offers a curated catalog of consumer electronic products spanning premium, mid-tier, and budget price points, distributed exclusively through digital channels. 

Venturo's customer base spans approximately 52,000 customers across 110,000+ transactions, generating $65M+ in revenue. The dataset captures key dimensions, including region, product line, marketing channel, order channel, and loyalty status, and tracks core KPIs such as revenue, average order value (AOV), order volume, customer retention, and refund rate. The business operates in a competitive, macro-sensitive environment — rising inflation, changing consumer spending habits, and growing competition from peer retailers have all shaped Venturo's performance across the four-year period.

This performance review was commissioned for the Head of Operations to comprehensively evaluate Venturo's commercial performance across 2022–2025. The findings are designed to equip internal cross-functional teams with the operational and sales intelligence needed to reduce refund rates, grow loyalty enrollment, improve regional performance, and drive sustainable revenue growth. The insights and recommendations are built around the company's most critical performance metrics and strategic levers, organized across four northstar metrics:

**North Star Metrics**

- **Sales Performance** - Revenue, Order Volume, Average Order Value (AOV) 
- **Product Performance** - Revenue Contribution by Product Line, AOV Trends, Refund Rate Analysis
- **Customer Loyalty** - Loyalty Adoption Rates, Repeat Purchase Behavior, AOV Premium, Customer Retention by Loyalty Status
- **Regional Performance** - Demand Concentration by Region, Fulfillment Performance, Product-Level Revenue Drivers

---

## Executive Summary 

Between 2022 and 2025, Venturo Electronics generated **$63.8M** in revenue across **110,000+ transactions** — moving through a post-pandemic baseline, inflation-driven slowdown, a sharp 2024 contraction, and a broad 2025 recovery. **2024** marks the clear inflection point: the only year in which revenue, average order value (AOV), and order volume declined simultaneously, by **42%**, **24%**, and **23%**, respectively. This contraction was uniform across all products, regions, and quarters, pointing to broad economic pressure as the cause rather than anything broken internally.

While the 2025 recovery was strong — revenue rebounding **56%** to **$16.3M** — performance diverged sharply by customer segment. Loyalty member sales recovered **93%** from their 2024 low versus just **39%** for non-members, with nearly double the retention rate. Two opportunities stand out heading into 2026: expand loyalty adoption — particularly in EMEA, where enrollment trails North America by **12.5** percentage points — and address APAC's delivery times, which run **171%** longer than the NA benchmark.

---

## Data Structure & ERD

The database consists of five tables — `orders`, `customers`, `date_dim`, `geo_lookup`, and `order_status`— comprising 110,542 records. `orders` serves as the central fact table, linking to `customers` via `customer_id`, fulfillment and refund data via `order_id` through `order_status`, time-series dimensions via `date_dim`, and regional classification via `geo_lookup` through `country_code`.

<p align="center">
<img src="images/erd.png" width="750">
</p>

--- 

## Insights Deep Dive

### Sales Performance

<p align="center">
<img src="images/sales_revenue_aov_volume.png" width="750">
</p>


**2024 Was the Only Year All Three Core Metrics Contracted Simultaneously — Macro, Not Operational**
- Revenue, average order value (AOV), and order volume all hit four-year lows in 2024 — monthly revenue troughed at **$0.8M** against a **$1.3M** average, AOV compressed to **$472** against a **$589** average, and order volume bottomed at **1,641** against a **2,200** average.
- On an annual basis, revenue fell **42%** from **$17.8M** to **$10.4M**, AOV dropped **24** from **$638** to **$484**, and order volume declined 23% from **27,859** to **21,483** — uniform across all 10 products, all 4 regions, and all 4 quarters, confirming the cause was economic, not operational.
- Every other year had at least one offsetting metric: 2023 saw AOV rise **6%** despite order volume falling **13%** — pricing power absorbed weaker demand. In 2024, there was no such offset.


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

**Revenue Rebounded 56% in 2025 — But All Three Metrics Remain Below Their Four-Year Averages**
- Revenue rebounded **56%** to **$16.3M**, and AOV strengthened to **$634** — matching 2023 inflation-era highs, with the 2024→2025 Q4→Q1 transition producing a **+45.6%** revenue jump, the strongest positive quarterly transition.
- Order volume recovered to **25,687**, yet all three metrics remain below their four-year averages — the business is trending in the right direction, but hasn't returned to where it was before 2024.
- AOV's recovery to $634 is the strongest signal — customers returning in 2025 are spending at 2023 levels, confirming that loyalty expansion brought back higher-value buyers rather than discount-driven volume.

**January Functions as a Macro Leading Indicator — Monthly Variation Is Noise**
- January year-over-year performance predicted full-year outcomes without exception: a strong 2022 open, a modest 2023 dip, a simultaneous three-metric decline in 2024, and a sharp 2025 recovery — each accurately signaling the full-year outcome from the outset.
- Outside of January, month-over-month revenue averaged just **3%**, and AOV averaged **5%** across the remaining 11 months — single-month variance below those thresholds should not trigger strategic intervention.
- A formal January review costs nothing and gives operations its earliest possible signal before the year's trajectory is locked in.

<p align="center">
<img src="images/order_channel_mix.png" width="750">
</p>

**Mobile Overtook Desktop in 2024 and Widened Its Lead in 2025 — A Four-Year Channel Reversal**
- Desktop held **58%** of order volume in 2022; by 2025, mobile reached **58%** — a precise four-year inversion. The shift was progressive: desktop maintained a majority share through 2023 (52/48) before mobile crossed over in **2024** (53/47) and widened its lead in 2025 (58/42).
- The marketing channel mix was flat across all four years — social media anchored **~46%** of orders as the dominant acquisition channel, while email served as the primary retention and lifecycle channel throughout.
- With mobile now driving the majority of transactions, checkout flow, payment experience, and page performance are baseline operational requirements — any friction directly impacts the majority of revenue.

### Product Performance

<p align="center">
<img src="product_sales_lines.png" width="750">
</p>

<p align="center">
<img src="recovery_rates_table.png" width="750">
</p>

**MacBook Air Anchors Revenue — The Product Hierarchy Held Through Every Market Condition**
- MacBook Air generated **20-21%** of total revenue consistently across all 4 years, all 4 regions, and every market condition — no other product line approaches this revenue concentration.
- The premium tier led the 2025 recovery — MacBook Air (**+80.8%**), Samsung Galaxy S24 (**+77.3%**), and iPhone (**+75.5%**) posted the three highest recovery rates in the catalog, with collective premium AOV rebounding from **$773** in 2024 to **$1,107** in 2025, a **43%** recovery across the tier.
- Amazon Alexa and Anker Power Bank were the only two products that declined in 2025 — their 2024 trade-down gains reversed as customers returned to premium purchases.

<p align="center">
<img src="product_aov_heatmap.png" width="750">
</p>
*Note: each row is scaled to that product's own four-year range — color intensity reflects relative performance within each product line, not absolute AOV comparisons across products*

**AOV Compression in 2024 Was Catalog-Wide — With One Notable Exception Among Budget Product Lines**
- Premium and mid-tier products compressed to four-year AOV lows in 2024, recovering uniformly in 2025 — budget products (Amazon Alexa, Anker Power Bank) ran counter to this trend, likely reflecting a shift toward lower-cost alternatives during the downturn, a pattern that normalized in 2025 as customers returned to premium purchases.
- Premium devices compressed furthest in absolute dollars and rebounded the strongest — confirming that product mix shifts in 2024 were macro-driven, not a structural shift in customer preferences.
- Overall portfolio AOV recovered to **$634** in 2025 — matching the Sales Performance findings and within **$4** of 2023's **$638** high — confirming returning customers are back to purchasing at full premium price points, not trading down.

<p align="center">
<img src="refund_rate_heatmap.png" width="750">
</p>

**The 2024 Refund Spike Was Systemic — Every Product Crossed 10% Simultaneously**
- The overall refund rate rose from **6.5%** in 2022, peaked at **12.0%** in 2024, and fell back to **7.1%** in 2025 — nearly doubling from 2022 before almost fully reversing by 2025.
- Every product breached the 10% refund threshold simultaneously in 2024 — Amazon Alexa peaked at **13.2%**, MacBook Air at **12.5%**, and Anker Power Bank at **12.4%** — no product was insulated from the spike, regardless of tier or category.
- A product quality or operational failure would surface through specific product lines — a simultaneous breach across every price tier in the same year points to customers pulling back financially, not a product or operations problem — and the 2025 return to near-baseline rates confirms the cause was cyclical, not structural.

# E-Commerce Sales Analysis

SQL-based analysis of e-commerce order data to surface revenue trends, product performance, regional breakdowns, and customer behavior patterns.

## Overview

This project analyzes six months of order data across four product categories and four regions. The goal was to identify where revenue is concentrated, which customers drive the most value, and how performance trends month-over-month.

**Key findings:**
- Electronics accounts for ~68% of total revenue despite representing less than half of product SKUs
- The West region leads in total revenue but the East region has the highest order volume
- 70% of customers placed more than one order in the analysis period, indicating strong repeat purchase behavior
- Revenue grew consistently month-over-month with the largest MoM jump occurring in Q1 → Q2 transition

## Dataset

`data/orders.csv` — 60 orders across 10 customers, 6 months (Jan–Jun 2023)

| Column | Description |
|---|---|
| order_id | Unique order identifier |
| customer_id | Customer identifier |
| order_date | Date of order |
| product | Product name |
| category | Product category (Electronics, Furniture, Office Supplies) |
| unit_price | Price per unit |
| quantity | Units ordered |
| region | Sales region (East, West, Central, South) |
| status | Order status (Completed, Cancelled) |

## Queries

All queries are in `queries/analysis.sql` and are written in PostgreSQL syntax.

| Query | Description |
|---|---|
| Total Revenue Overview | High-level KPIs: total orders, unique customers, revenue, avg order value |
| Monthly Revenue Trend | Revenue by month to identify growth patterns |
| Revenue by Category | Category-level breakdown with % share of total revenue |
| Top 5 Products by Revenue | Best performing products by total revenue |
| Regional Performance | Revenue, orders, and avg order value by region |
| Customer Purchase Frequency | Customer segmentation by order frequency and lifetime value |
| Repeat Customer Rate | % of customers who placed more than one order |
| MoM Revenue Growth | Month-over-month revenue growth using window functions |

## Tools

- PostgreSQL (SQL syntax)
- Compatible with SQLite with minor syntax adjustments (replace `TO_CHAR` with `strftime`)

## How to Run

1. Create a `orders` table in your PostgreSQL database
2. Import `data/orders.csv`
3. Run queries from `queries/analysis.sql` in order

## Technical Notes

The month-over-month growth query uses a window function (`LAG`) to calculate the percentage change between periods without requiring a self-join. This approach is more readable and performant at scale. The revenue analysis queries are split across two files — `analysis.sql` for core metrics and `revenue_queries.sql` for extended revenue breakdowns.

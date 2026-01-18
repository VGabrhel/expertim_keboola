# 🎯 Průvodce webinářem - Krok za krokem

## Příprava (před webinářem)

### ✅ Předpoklady
1. **Keboola Account** - přístup k projektu
2. **Dataset** - `superstore_sample.csv` připraven
3. **SQL Dialekt** - BigQuery Standard SQL

## ČÁST 1: Úvod do Keboola (10 min)

### Co je Keboola?
- Cloud-based datová platforma
- End-to-end datové toky (Extract → Transform → Load)
- Podpora 250+ konektorů
- Built-in orchestrace a monitoring

### Architektura projektu
```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Extract   │ --> │  Transform   │ --> │    Load     │
│  (Storage)  │     │     (SQL)    │     │ (Reporting) │
└─────────────┘     └──────────────┘     └─────────────┘
       ↓                    ↓                    ↓
   Superstore       KPI Calculations        Dashboards
```

## ČÁST 2: Nahrání dat do Storage (5 min)

### Krok 1: Vytvoření bucketu
1. Přejděte do **Storage** → **Buckets**
2. Klikněte **New Bucket**
3. Nastavte:
   - Name: `superstore`
   - Stage: `in` (input)
   - Backend: `BigQuery`

### Krok 2: Nahrání CSV
1. V bucketu `in.c-superstore` klikněte **Add Table**
2. Vyberte metodu: **Upload File**
3. Nahrajte `superstore_sample.csv`
4. Název tabulky: `orders`
5. **Primary key:** Ponechte prázdné (pro tento use case není nutný)

### Krok 3: Data Preview
- Klikněte na tabulku `orders`
- Zkontrolujte:
  - Počet řádků: ~9,994
  - Všechny sloupce (21)
  - Preview prvních řádků

## ČÁST 3: Explorace dat

### Workspace - interaktivní SQL explorace
1. **Storage** → **Workspace**
2. Vytvořte nový Workspace
3. Spusťte explorativní dotazy:

```sql
-- Základní přehled dat
SELECT COUNT(*) as total_orders,
       COUNT(DISTINCT `Customer ID`) as unique_customers,
       ROUND(SUM(Sales), 2) as total_sales,
       ROUND(SUM(Profit), 2) as total_profit
FROM `in.c-keboola-ex-google-drive-01kesn1c8hda86aqqm3z5hvvn1.superstore_sample`;

-- Tržby podle kategorií
SELECT Category,
       COUNT(*) as order_count,
       ROUND(SUM(Sales), 2) as total_sales,
       ROUND(SUM(Profit), 2) as total_profit,
       ROUND(AVG(Discount), 3) as avg_discount
FROM `in.c-keboola-ex-google-drive-01kesn1c8hda86aqqm3z5hvvn1.superstore_sample`
GROUP BY Category
ORDER BY total_sales DESC;

-- Top 10 nejziskovějších produktů
SELECT `Product Name`,
       Category,
       COUNT(*) as times_ordered,
       ROUND(SUM(Profit), 2) as total_profit
FROM `in.c-keboola-ex-google-drive-01kesn1c8hda86aqqm3z5hvvn1.superstore_sample`
GROUP BY `Product Name`, Category
ORDER BY total_profit DESC
LIMIT 10;
```

## ČÁST 4: SQL Transformace #1

### Vytvoření transformace
1. **Transformations** → **New Transformation**
2. Název: `01 - Clean and Standardize`
3. Typ: **SQL**
4. Backend: **BigQuery**

### Transformační SQL kód

```sql
-- Block 1: Čištění a standardizace dat
CREATE OR REPLACE TABLE `cleaned_orders` AS
SELECT
  `Row ID`,
  `Order ID`,
  `Order Date`,
  `Ship Date`,
  `Ship Mode`,
  `Customer ID`,
  `Customer Name`,
  `Segment`,
  Country,
  City,
  State,
  `Postal Code`,
  Region,
  `Product ID`,
  Category,
  `Sub-Category`,
  `Product Name`,
  
  -- Metriky - zajištění správných datových typů
  CAST(Sales AS FLOAT64) as Sales,
  CAST(Quantity AS INT64) as Quantity,
  CAST(Discount AS FLOAT64) as Discount,
  CAST(Profit AS FLOAT64) as Profit,
  
  -- Date dimensions
  PARSE_DATE('%m/%d/%Y', `Order Date`) as order_date_parsed,
  EXTRACT(YEAR FROM PARSE_DATE('%m/%d/%Y', `Order Date`)) as order_year,
  EXTRACT(QUARTER FROM PARSE_DATE('%m/%d/%Y', `Order Date`)) as order_quarter,
  EXTRACT(MONTH FROM PARSE_DATE('%m/%d/%Y', `Order Date`)) as order_month,
  FORMAT_DATE('%B', PARSE_DATE('%m/%d/%Y', `Order Date`)) as order_month_name,
  FORMAT_DATE('%A', PARSE_DATE('%m/%d/%Y', `Order Date`)) as order_day_name,
  
  -- Ship date dimensions
  PARSE_DATE('%m/%d/%Y', `Ship Date`) as ship_date_parsed,
  DATE_DIFF(PARSE_DATE('%m/%d/%Y', `Ship Date`), 
            PARSE_DATE('%m/%d/%Y', `Order Date`), DAY) as ship_days,
  
  -- Standardizace kategorií
  UPPER(TRIM(Category)) as category_clean,
  UPPER(TRIM(`Sub-Category`)) as subcategory_clean,
  UPPER(TRIM(Segment)) as segment_clean,
  UPPER(TRIM(Region)) as region_clean

FROM `in.c-keboola-ex-google-drive-01kesn1c8hda86aqqm3z5hvvn1.superstore_sample`
WHERE Sales IS NOT NULL 
  AND Profit IS NOT NULL;
```

### Input/Output Mapping
- **Output:** `out.c-01---Clean-and-Standardize-Superstore-Data.cleaned_orders`

## ČÁST 5: SQL Transformace #2 - KPI Výpočty

### Vytvoření transformace
1. **Transformations** → **New Transformation**
2. Název: `02 - Calculate KPIs`
3. Input: `out.c-01---Clean-and-Standardize-Superstore-Data.cleaned_orders`

### KPI Calculation SQL

```sql
-- Block 1: Výpočet základních KPIs na úrovni řádků
CREATE OR REPLACE TABLE `orders_with_kpis` AS
SELECT
  *,
  
  -- Marže (%)
  CASE 
    WHEN Sales > 0 THEN ROUND((Profit / Sales) * 100, 2)
    ELSE 0 
  END as profit_margin_pct,
  
  -- Náklady
  ROUND(Sales - Profit, 2) as cost,
  
  -- ROI (%)
  CASE 
    WHEN (Sales - Profit) > 0 THEN ROUND((Profit / (Sales - Profit)) * 100, 2)
    ELSE 0 
  END as roi_pct,
  
  -- Profit per unit
  CASE 
    WHEN Quantity > 0 THEN ROUND(Profit / Quantity, 2)
    ELSE 0 
  END as profit_per_unit,
  
  -- Discount impact flag
  CASE
    WHEN Discount > 0 AND Profit < 0 THEN 'Loss with Discount'
    WHEN Discount > 0 AND Profit > 0 THEN 'Profit with Discount'
    WHEN Discount = 0 AND Profit < 0 THEN 'Loss without Discount'
    ELSE 'Profit without Discount'
  END as discount_impact,
  
  -- Revenue per quantity
  CASE 
    WHEN Quantity > 0 THEN ROUND(Sales / Quantity, 2)
    ELSE 0 
  END as revenue_per_unit,
  
  -- Profit classification
  CASE
    WHEN Profit < 0 THEN 'Loss'
    WHEN Profit = 0 THEN 'Break-even'
    WHEN Profit BETWEEN 0 AND 50 THEN 'Low Profit'
    WHEN Profit BETWEEN 50 AND 200 THEN 'Medium Profit'
    ELSE 'High Profit'
  END as profit_category

FROM `out.c-01---Clean-and-Standardize-Superstore-Data.cleaned_orders`;
```

### Output Mapping
- **Output:** `out.c-02---Calculate-KPIs.orders_with_kpis`

## ČÁST 6: SQL Transformace #3 - Finální Datamart

### Vytvoření transformace
1. **Transformations** → **New Transformation**
2. Název: `03 - Final Datamart`
3. Input: `out.c-02---Calculate-KPIs.orders_with_kpis`

### Datamart SQL - Agregace pro reporting

```sql
-- Block 1: Agregace podle regionu a kategorie
CREATE OR REPLACE TABLE `datamart_region_category` AS
SELECT
  region_clean as region,
  category_clean as category,
  subcategory_clean as subcategory,
  
  -- Objednávky
  COUNT(DISTINCT `Order ID`) as total_orders,
  COUNT(*) as total_line_items,
  COUNT(DISTINCT `Customer ID`) as unique_customers,
  
  -- Tržby a profit
  ROUND(SUM(Sales), 2) as total_sales,
  ROUND(SUM(Profit), 2) as total_profit,
  ROUND(AVG(Sales), 2) as avg_sales_per_line,
  ROUND(AVG(Profit), 2) as avg_profit_per_line,
  
  -- Marže
  ROUND(AVG(profit_margin_pct), 2) as avg_profit_margin_pct,
  ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) as overall_margin_pct,
  
  -- ROI
  ROUND(AVG(roi_pct), 2) as avg_roi_pct,
  
  -- Discount analýza
  ROUND(AVG(Discount), 3) as avg_discount,
  ROUND(SUM(Quantity), 0) as total_quantity,
  
  -- Náklady
  ROUND(SUM(cost), 2) as total_cost

FROM `out.c-02---Calculate-KPIs.orders_with_kpis`
GROUP BY region_clean, category_clean, subcategory_clean;

-- Block 2: Time series - tržby podle měsíců
CREATE OR REPLACE TABLE `datamart_time_series` AS
SELECT
  order_year,
  order_quarter,
  order_month,
  order_month_name,
  
  COUNT(DISTINCT `Order ID`) as total_orders,
  ROUND(SUM(Sales), 2) as total_sales,
  ROUND(SUM(Profit), 2) as total_profit,
  ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) as profit_margin_pct,
  COUNT(DISTINCT `Customer ID`) as unique_customers,
  ROUND(AVG(Discount), 3) as avg_discount

FROM `out.c-02---Calculate-KPIs.orders_with_kpis`
GROUP BY order_year, order_quarter, order_month, order_month_name
ORDER BY order_year, order_month;

-- Block 3: Customer Segment Analysis
CREATE OR REPLACE TABLE `datamart_customer_segment` AS
SELECT
  segment_clean as segment,
  
  COUNT(DISTINCT `Customer ID`) as total_customers,
  COUNT(DISTINCT `Order ID`) as total_orders,
  ROUND(SUM(Sales), 2) as total_sales,
  ROUND(SUM(Profit), 2) as total_profit,
  ROUND(AVG(Sales), 2) as avg_order_value,
  ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) as profit_margin_pct,
  
  -- Customer lifetime value (proxy)
  ROUND(SUM(Sales) / COUNT(DISTINCT `Customer ID`), 2) as sales_per_customer,
  ROUND(SUM(Profit) / COUNT(DISTINCT `Customer ID`), 2) as profit_per_customer

FROM `out.c-02---Calculate-KPIs.orders_with_kpis`
GROUP BY segment_clean;

-- Block 4: Top Products Analysis
CREATE OR REPLACE TABLE `datamart_top_products` AS
SELECT
  `Product Name`,
  category_clean as category,
  subcategory_clean as subcategory,
  
  COUNT(*) as times_sold,
  ROUND(SUM(Sales), 2) as total_sales,
  ROUND(SUM(Profit), 2) as total_profit,
  ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) as profit_margin_pct,
  ROUND(SUM(Quantity), 0) as total_quantity,
  ROUND(AVG(Discount), 3) as avg_discount

FROM `out.c-02---Calculate-KPIs.orders_with_kpis`
GROUP BY `Product Name`, category_clean, subcategory_clean
HAVING total_sales > 100  -- Filter out low-volume products
ORDER BY total_profit DESC
LIMIT 100;

-- Block 5: Executive Summary - Overall KPIs
CREATE OR REPLACE TABLE `datamart_executive_summary` AS
SELECT
  'Overall' as metric_scope,
  
  -- Volume metrics
  COUNT(DISTINCT `Order ID`) as total_orders,
  COUNT(DISTINCT `Customer ID`) as total_customers,
  COUNT(*) as total_line_items,
  ROUND(SUM(Quantity), 0) as total_units_sold,
  
  -- Financial metrics
  ROUND(SUM(Sales), 2) as total_sales,
  ROUND(SUM(Profit), 2) as total_profit,
  ROUND(SUM(cost), 2) as total_cost,
  ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) as overall_margin_pct,
  ROUND(AVG(roi_pct), 2) as avg_roi_pct,
  
  -- Average values
  ROUND(AVG(Sales), 2) as avg_sales_per_line,
  ROUND(AVG(Profit), 2) as avg_profit_per_line,
  ROUND(AVG(Discount), 3) as avg_discount,
  
  -- Orders metrics
  ROUND(SUM(Sales) / COUNT(DISTINCT `Order ID`), 2) as avg_order_value,
  ROUND(SUM(Profit) / COUNT(DISTINCT `Order ID`), 2) as avg_profit_per_order,
  
  -- Discount impact
  COUNTIF(discount_impact = 'Loss with Discount') as loss_with_discount_count,
  COUNTIF(discount_impact = 'Profit with Discount') as profit_with_discount_count,
  ROUND(COUNTIF(Discount > 0) / COUNT(*) * 100, 2) as pct_orders_with_discount

FROM `out.c-02---Calculate-KPIs.orders_with_kpis`;
```

### Output Mapping
Vytvořit 5 tabulek v bucketu `01---Clean-and-Standardize-Superstore-Data
`:
1. `datamart_region_category`
2. `datamart_time_series`
3. `datamart_customer_segment`
4. `datamart_top_products`
5. `datamart_executive_summary`

## ČÁST 7: Orchestrace - Conditional Flow

### Vytvoření Flow
1. **Flows** → **New Flow**
2. Název: `Superstore ETL Pipeline`
3. Typ: **Conditional Flow**

### Flow struktura

```yaml
Phases:
  1. Start
     └─> 2. Clean Data
           └─> 3. Calculate KPIs
                 └─> 4. Build Datamart
                       └─> 5. Complete

Tasks v každé fázi:
  - Phase 2: Transformace "01 - Clean and Standardize"
  - Phase 3: Transformace "02 - Calculate KPIs"
  - Phase 4: Transformace "03 - Final Datamart"
```

### Nastavení plánovače
- **Frekvence:** Denně v 6:00 AM
- **Timezone:** Europe/Prague
- **Retry:** 2× při selhání

## ČÁST 8: Reporting a sdílení

### Export do Google Sheets
1. Konfigurujte **Google Sheets Writer**
2. Vyberte finální datamart tabulky
3. Nastavte automatickou synchronizaci

### Looker Studio Dashboard
1. Připojte se k BigQuery datasetu
2. Použijte tabulky z `01---Clean-and-Standardize-Superstore-Data
`
3. Vytvořte dashboard s:
   - KPI cards
   - Time series charts
   - Regional maps
   - Category breakdowns

## ČÁST 9: Diskuze



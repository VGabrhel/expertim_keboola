# 🎤 Prezentační průvodce pro webinář

## Časový plán (90 minut celkem)

---

## ČÁST 1: Úvod

### Představení problému
**"Máte tuto situaci?"**
- 📊 Data v Excel souborech na různých místech
- 🔄 Manuální kopírování a úpravy každý týden
- ⏰ Hodiny strávené přípravou reportů
- ❌ Chyby způsobené manuální prací
- 📉 Neaktuální data pro rozhodování

### Řešení: Automatizace v Keboola
**"Co když by to šlo automaticky?"**
- ✅ Jednou nastavit, navždy automatizovat
- ✅ Aktuální data kdykoliv potřebujete
- ✅ Žádné manuální chyby
- ✅ Čas pro analýzu místo přípravy dat

### Dataset Superstore
- 📦 9,994 objednávek z fiktivního obchodu
- 🌍 4 regiony USA (West, East, Central, South)
- 🏷️ 3 kategorie produktů (Technology, Furniture, Office Supplies)
- 👥 3 zákaznické segmenty (Consumer, Corporate, Home Office)
- 💰 Metriky: Sales, Profit, Quantity, Discount

---

## ČÁST 2: Live Demo - Storage & Explorace

### 🎯 Ukázat Keboola UI

**Navigace:**
```
Keboola Dashboard → Storage → Buckets
```

### Ukázat strukturu buckets:
```
01---Clean-and-Standardize-Superstore-Data         (transformovaná data)
   └─ cleaned_orders             (9,994 řádků)

02---Calculate-KPIs  (výpočet KPIs)
   └─ orders_with_kpis

03---Build-Final-Datamarts (finální datamarty)
   └─ datamart_region_category
   └─ datamart_time_series
   └─ datamart_customer_segment
   └─ datamart_top_products
   └─ datamart_executive_summary
```

### 🔍 Data Preview
**Kliknout na tabulku `orders`**
- Ukázat sloupce
- Ukázat Data Sample

### 💻 Workspace - SQL Explorace

**Vytvořit Workspace:**
```
Storage → Workspace → Create New Workspace
```

**Spustit explorativní SQL:**

```sql
-- Základní přehled
SELECT 
  COUNT(*) as total_rows,
  COUNT(DISTINCT `Order ID`) as unique_orders,
  COUNT(DISTINCT `Customer ID`) as unique_customers
FROM `kbc-use4-5087-8ecb.out_c_01___Clean_and_Standardize_Superstore_Data.cleaned_orders`;
```

```sql
-- Tržby podle kategorií
SELECT 
  Category,
  ROUND(SUM(CAST(Sales AS FLOAT64)), 2) as total_sales,
  ROUND(SUM(CAST(Profit AS FLOAT64)), 2) as total_profit,
  COUNT(*) as order_count
FROM `kbc-use4-5087-8ecb.out_c_01___Clean_and_Standardize_Superstore_Data.cleaned_orders`
GROUP BY Category
ORDER BY total_sales DESC;
```

**Komentář:** "Technology má nejvyšší tržby a Furniture má nízký profit. To je něco, na co se chceme zaměřit v analýze."

---

## ČÁST 3: SQL Transformace #1 - Čištění

### 🎯 Otevřít transformaci

```
Transformations → 01 - Clean and Standardize
```

### Vysvětlit účel:
**"Co děláme v této transformaci?"**
1. ✅ Parsování datumů z textového formátu
2. ✅ Vytvoření časových dimenzí (rok, měsíc, čtvrtletí)
3. ✅ Kontrola datových typů
4. ✅ Standardizace textových hodnot
5. ✅ Výpočet odvozených hodnot (ship_days)

### Projít klíčové části SQL:

**Parsování datumů:**
```sql
PARSE_DATE('%m/%d/%Y', `Order Date`) as order_date_parsed,
EXTRACT(YEAR FROM PARSE_DATE('%m/%d/%Y', `Order Date`)) as order_year,
EXTRACT(QUARTER FROM ...) as order_quarter,
```

**Komentář:** "Datumy jsou v CSV jako text. Parsujeme je a rovnou vytváříme časové dimenze pro reporting."

**Datové typy:**
```sql
CAST(Sales AS FLOAT64) as sales,
CAST(Quantity AS INT64) as quantity,
```

**Komentář:** "CSV má všechno jako text. Převádíme na správné typy pro výpočty."

**Standardizace:**
```sql
UPPER(TRIM(Category)) as category_clean,
```

**Komentář:** "Odstraňujeme mezery a uniformizujeme na velká písmena - předejdeme problémům s 'Technology' vs ' Technology' vs 'TECHNOLOGY'."

### Ukázat Input/Output Mapping
- **Input:** `superstore_all`
- **Output:** `kbc-use4-5087-8ecb.out_c_01___Clean_and_Standardize_Superstore_Data.cleaned_orders`

### ▶️ Spustit transformaci
**Kliknout Run** a sledovat progress.

**Komentář během běhu:** "Transformace běží na BigQuery backendu. Pro 10K řádků to trvá pár sekund. Pro miliony řádků by to bylo stejně rychlé díky síle BigQuery."

---

## ČÁST 4: SQL Transformace #2 - KPI Výpočty

### 🎯 Otevřít transformaci

```
Transformations → 02 - Calculate KPIs
```

### Vysvětlit business metriky:

**Profit Margin:**
```sql
CASE 
  WHEN sales > 0 THEN ROUND((profit / sales) * 100, 2)
  ELSE 0 
END as profit_margin_pct
```

**Komentář:** "Kolik % z tržeb je čistý zisk? 20% marže znamená, že z $100 tržeb máme $20 profitu."

**ROI (Return on Investment):**
```sql
CASE 
  WHEN (sales - profit) > 0 THEN ROUND((profit / (sales - profit)) * 100, 2)
  ELSE 0 
END as roi_pct
```

**Komentář:** "Kolik % jsme vydělali z investovaných nákladů? Pokud jsme investovali $80 a vydělali $20, ROI je 25%."

**Discount Impact:**
```sql
CASE
  WHEN discount > 0 AND profit < 0 THEN 'Loss with Discount'
  WHEN discount > 0 AND profit > 0 THEN 'Profit with Discount'
  WHEN discount = 0 AND profit < 0 THEN 'Loss without Discount'
  ELSE 'Profit without Discount'
END as discount_impact
```

**Komentář:** "Kategorizujeme každou objednávku podle toho, jestli sleva pomohla nebo naopak způsobila ztrátu. To je důležité pro pricing strategii."

**Profit Classification:**
```sql
CASE
  WHEN profit < 0 THEN 'Loss'
  WHEN profit = 0 THEN 'Break-even'
  WHEN profit BETWEEN 0 AND 50 THEN 'Low Profit'
  WHEN profit BETWEEN 50 AND 200 THEN 'Medium Profit'
  ELSE 'High Profit'
END as profit_category
```

**Komentář:** "Rozdělujeme objednávky do kategorií podle ziskovosti. Pomůže to identifikovat nejlepší a nejhorší produkty."

### ▶️ Spustit transformaci

---

## ČÁST 5: SQL Transformace #3 - Datamarts

### 🎯 Otevřít transformaci

```
Transformations → 03 - Build Final Datamarts
```

### Vysvětlit koncept datamartů:

**"Co je to datamart?"**
- 📊 Agregovaná data připravená pro reporting
- 🎯 Každý datamart má specifický účel
- ⚡ Rychlé dotazy (už předpočítané agregace)
- 📈 Připravené pro BI nástroje (Power BI, Tableau, Looker)

### Projít 5 datamartů:

**1. Region & Category:**
```sql
CREATE OR REPLACE TABLE `datamart_region_category` AS
SELECT
  region_clean as region,
  category_clean as category,
  ...
  SUM(sales) as total_sales,
  SUM(profit) as total_profit,
  AVG(profit_margin_pct) as avg_margin
FROM ... GROUP BY region, category, subcategory;
```

**Komentář:** "Pro analýzu podle regionů a kategorií. 'Která kategorie je nejziskovější v každém regionu?'"

**2. Time Series:**
```sql
CREATE OR REPLACE TABLE `datamart_time_series` AS
SELECT
  order_year, order_quarter, order_month,
  SUM(sales) as total_sales,
  ...
GROUP BY order_year, order_quarter, order_month
ORDER BY order_year, order_month;
```

**Komentář:** "Pro časové grafy. 'Jak se vyvíjely tržby v čase? Jsou nějaké sezónní trendy?'"

**3. Customer Segments:**
```sql
CREATE OR REPLACE TABLE `datamart_customer_segment` AS
SELECT
  segment_clean as segment,
  COUNT(DISTINCT customer_id) as total_customers,
  SUM(sales) / COUNT(DISTINCT customer_id) as sales_per_customer
FROM ... GROUP BY segment;
```

**Komentář:** "Pro analýzu zákaznických segmentů. 'Který segment má nejvyšší Customer Lifetime Value?'"

**4. Top Products:**
```sql
CREATE OR REPLACE TABLE `datamart_top_products` AS
SELECT
  product_name, category,
  SUM(profit) as total_profit,
  ...
FROM ... 
GROUP BY product_name, category
ORDER BY total_profit DESC
LIMIT 100;
```

**Komentář:** "Pro identifikaci best sellers. 'Které produkty bychom měli propagovat?'"

**5. Executive Summary:**
```sql
CREATE OR REPLACE TABLE `datamart_executive_summary` AS
SELECT
  'Overall' as metric_scope,
  COUNT(DISTINCT order_id) as total_orders,
  SUM(sales) as total_sales,
  SUM(profit) as total_profit,
  ...
FROM ...;
```

**Komentář:** "Jeden řádek s hlavními KPI pro top management dashboard. 'Jaká je celková výkonnost businessu?'"

### ▶️ Spustit transformaci

**Komentář:** "Tato transformace vytváří 5 tabulek najednou. Každá tabulka je optimalizovaná pro jiný typ analýzy."

---

## ČÁST 6: Orchestrace - Flow (10 minut)

### 🎯 Otevřít Flow

```
Flows → Superstore ETL Pipeline
```

### Vysvětlit strukturu:

**"Co je to Conditional Flow?"**
- 📋 Orchestrace více komponent v správném pořadí
- 🔄 Automatické spouštění podle plánu
- ✅ Error handling a retry logika
- 📧 Notifikace při selhání/úspěchu
- 🌳 Podmíněné větve (if-then-else)

### Ukázat vizuální diagram:
```
Phase 1: Start
    ↓
Phase 2: Clean and Standardize
    ↓
Phase 3: Calculate KPIs
    ↓
Phase 4: Build Datamarts
    ↓
END
```

**Komentář:** "Každá fáze musí skončit úspěšně, než začne další. Pokud Clean selže, KPIs se nespustí."

### Nastavení scheduleru:

**Ukázat schedule config:**
- ⏰ Čas: 6:00 AM denně
- 🌍 Timezone: Europe/Prague
- 🔁 Retry: 2× při selhání
- 📧 Notifikace: email při selhání

**Komentář:** "Toto spouštíme automaticky každé ráno. Data jsou vždy čerstvá, když přijdete do práce."

### ▶️ Spustit Flow

**Kliknout Run** a sledovat progress v real-time.

**Komentář:** "Vidíte, jak postupně zelená každá fáze. Real-time monitoring, vidíte logy, můžete sledovat, co se právě děje."

---

## ČÁST 7: Export a Sdílení

### Google Sheets Writer

**Ukázat konfiguraci:**
```
Writers → Google Sheets
```

**Nastavení:**
- Vybrat datamarty k exportu
- Target Google Sheet
- Sync mode (append/overwrite)
- Schedule (denně po ETL)

**Komentář:** "Pro kolegy, kteří chtějí data v Excelu. Automaticky se updatuje každý den."

### Looker Studio

**Ukázat connection:**
- Direct connection k BigQuery
- Tabulky z `01---Clean-and-Standardize-Superstore-Data`

**Komentář:** "Pro pokročilé dashboardy můžete použít Power BI nebo Looker Studio. Připojí se přímo k datamartům v BigQuery."

---

## ČÁST 8: Best Practices & Tipy

### ✅ Co jsme se naučili:

**1. Modularita**
- Rozdělení do 3 transformací
- Každá má jasný účel
- Snadná údržba a debugging

**2. Dokumentace**
- Popisky u všech komponent
- SQL komentáře
- README soubory

**3. Error handling**
- Flow s retry mechanikou
- Notifikace při selhání
- Logy pro debugging

**4. Optimalizace**
- Datové typy správně nastavené
- Agregace předpočítané v datamartech
- Rychlé dotazy na dashboardu

### 💡 Doporučené rozšíření:

**1. Data Quality Checks**
```sql
-- Validace: Žádné záporné quantity
SELECT COUNT(*) FROM orders WHERE quantity < 0;

-- Validace: Sales a profit konzistence
SELECT COUNT(*) FROM orders WHERE sales < profit;
```

**2. Incremental Loading**
- State files pro tracking
- Načítat jen nová data
- Rychlejší běh pro velké datasety

**3. Alerting**
- Email při poklesu tržeb > 20%
- Slack notifikace při anomáliích
- Monitoring kritických metrik

**4. ML Predikce**
- Python Transformation s sklearn
- Predikce churn rate zákazníků
- Forecast budoucích tržeb

**5. Více datových zdrojů**
- Integrace s Google Analytics
- Napojení CRM (Salesforce)
- Social media data

---

## ČÁST 10: Q&A a Diskuse

### Časté otázky:

**Q: Kolik to stojí?**
A: Keboola má pricing podle credits. Tento workflow spotřebuje minimální množství. Většinou záleží na objemu dat a frekvenci spouštění.

**Q: Můžu použít jiný SQL dialekt než BigQuery?**
A: Ano! Keboola podporuje Snowflake, Redshift, Synapse a další. SQL se může mírně lišit.

**Q: Co když mám data v Excelu?**
A: Použijete Google Sheets Extractor nebo nahrajete CSV přes UI. Pak stejný proces.

**Q: Jak často můžu spouštět ETL?**
A: Libovolně - každou hodinu, každý den, real-time streaming. Záleží na use case.

**Q: Můžu přidat vlastní Python kód?**
A: Ano! Python Transformations nebo Custom Python component pro složitější logiku.

---

## 🎯 Závěrečné shrnutí

### Co jsme vytvořili:

✅ **Automatizovaný ETL proces**
- Z manuální práce na automatickou pipeline
- 3 SQL transformace s business logikou
- 5 datamartů pro různé analytické účely

✅ **Orchestrace a monitoring**
- Conditional Flow pro řízení procesu
- Schedulovaný běh
- Error handling a notifikace

✅ **Vizualizace a sdílení**
- Interaktivní Streamlit dashboard
- Export do Google Sheets
- Připojení pro BI nástroje

### ROI této implementace:

**Před:**
- ⏰ 4 hodiny týdně manuální práce
- ❌ Chyby v manuálních výpočtech
- 📉 Stará data (aktualizace 1× týdně)
- 😰 Stres z reportingu

**Po:**
- ⏰ 0 hodin manuální práce
- ✅ Žádné chyby (automatické výpočty)
- 📈 Aktuální data (denní update)
- 😊 Čas na analýzu a insights

**Úspora:** ~200 hodin ročně = 25 pracovních dní!

---

## 🎤 Closing Statement

**"Děkuji za pozornost!"**

"Viděli jste, jak se dá transformovat manuální proces do plně automatizovaného datového workflow. 

Z Excel chaosu jsme se dostali k standardizovaným, automatizovaným datům připraveným pro rozhodování.

Všechny komponenty, které jsme dnes vytvořili, jsou k dispozici v projektu. Můžete je klonovat a použít ve svých vlastních projektech.

Dokumentace je kompletní - README, WEBINAR_GUIDE, DATA_UPLOAD_INSTRUCTIONS - všechno najdete v repozitáři.

Máte otázky? Jsem tu pro vás!"

**📧 Kontakt:**
- Email: support@keboola.com
- Docs: help.keboola.com
- Community: community.keboola.com
---




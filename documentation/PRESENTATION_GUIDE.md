# 🎤 Prezentační průvodce pro webinář

## Časový plán (90 minut celkem)

---

## ČÁST 1: Úvod (10 minut) ⏰ 0:00 - 0:10

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

## ČÁST 2: Live Demo - Storage & Explorace (10 minut) ⏰ 0:10 - 0:20

### 🎯 Ukázat Keboola UI

**Navigace:**
```
Keboola Dashboard → Storage → Buckets
```

### Ukázat bucket struktur:
```
in.c-superstore          (vstupní data)
   └─ orders             (9,994 řádků)

out.c-superstore-transformed  (transformovaná data)
   └─ cleaned_orders
   └─ orders_with_kpis

01---Clean-and-Standardize-Superstore-Data
     (finální datamarty)
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
- Ukázat Data Profiling (pokud dostupné)

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
FROM `in.c-superstore.orders`;
```

**Komentář:** "Vidíme že máme 9,994 řádků, ale jen 5,009 unikátních objednávek - to znamená, že každá objednávka může mít více položek."

```sql
-- Tržby podle kategorií
SELECT 
  Category,
  ROUND(SUM(CAST(Sales AS FLOAT64)), 2) as total_sales,
  ROUND(SUM(CAST(Profit AS FLOAT64)), 2) as total_profit,
  COUNT(*) as order_count
FROM `in.c-superstore.orders`
GROUP BY Category
ORDER BY total_sales DESC;
```

**Komentář:** "Technology má nejvyšší tržby, ale Furniture má zajímavě nízký profit. To je něco, na co se chceme zaměřit v analýze."

---

## ČÁST 3: SQL Transformace #1 - Čištění (15 minut) ⏰ 0:20 - 0:35

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
- **Input:** `in.c-superstore.orders`
- **Output:** `out.c-superstore-transformed.cleaned_orders`

### ▶️ Spustit transformaci
**Kliknout Run** a sledovat progress.

**Komentář během běhu:** "Transformace běží na BigQuery backendu. Pro 10K řádků to trvá pár sekund. Pro miliony řádků by to bylo stejně rychlé díky síle BigQuery."

---

## ČÁST 4: SQL Transformace #2 - KPI Výpočty (15 minut) ⏰ 0:35 - 0:50

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

## ČÁST 5: SQL Transformace #3 - Datmarty (15 minut) ⏰ 0:50 - 1:05

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

## ČÁST 6: Orchestrace - Flow (10 minut) ⏰ 1:05 - 1:15

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

## ČÁST 7: Streamlit Data App (10 minut) ⏰ 1:15 - 1:25

### 🎯 Otevřít Data App

```
Data Apps → Superstore Analytics Dashboard → OPEN DATA APP
```

### Projít Dashboard sekce:

**1. Executive Summary KPIs:**
```
💰 Celkové tržby: $2.3M
📈 Celkový profit: $286K
🛒 Počet objednávek: 5,009
👥 Zákazníci: 793
```

**Komentář:** "První pohled - hlavní metriky pro management. Okamžitě vidíte celkový stav businessu."

**2. Časový vývoj:**
- Graf tržeb a profitu po měsících
- Dual-axis pro lepší srovnání

**Komentář:** "Vidíme sezónnost - Q4 (konec roku) má výrazně vyšší tržby. To je důležité pro plánování zásob."

**3. Regionální výkonnost:**
- Bar chart profitu podle regionů
- Barevné kódování podle marže

**Komentář:** "West region je jasný lídr. South má nejnižší profit - možná potřebuje jiný marketing approach."

**4. Zákaznické segmenty:**
- Koláčový graf profitu podle segmentů
- Consumer vs Corporate vs Home Office

**Komentář:** "Consumer segment generuje většinu profitu. Corporate má vysoké tržby, ale nižší marže - možná kvůli slevám."

**5. Top 20 produktů:**
- Horizontální bar chart
- Barevné kódování podle marže

**Komentář:** "Canon imageClass kopírka je top seller. Furniture produkty mají často nízkou nebo zápornou marži."

**6. Vliv slev:**
- Koláčový graf: Profit vs Loss with Discount

**Komentář:** "38% objednávek se slevou končí ve ztrátě! To je red flag pro pricing strategii."

### Interaktivita:

**Ukázat:**
- Hover efekty na grafech
- Zoom na časovém grafu
- Automatická aktualizace dat

**Komentář:** "Dashboard je živý - kdykoliv spustíte ETL pipeline, data se aktualizují. Žádný manuální export z Excelu."

---

## ČÁST 8: Export a Sdílení (5 minut) ⏰ 1:25 - 1:30

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

### Looker Studio / Power BI

**Ukázat connection:**
- Direct connection k BigQuery
- Tabulky z `01---Clean-and-Standardize-Superstore-Data
`

**Komentář:** "Pro pokročilé dashboardy můžete použít Power BI nebo Looker Studio. Připojí se přímo k datamartům v BigQuery."

### Data App Sharing

**Autentizace:**
- HTTP Basic Auth (username/password)
- Bezpečné sdílení přes URL

**Komentář:** "Dashboard můžete sdílet s kýmkoliv. Je chráněný heslem, takže data jsou v bezpečí."

---

## ČÁST 9: Best Practices & Tipy (10 minut) ⏰ 1:30 - 1:40

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

## ČÁST 10: Q&A a Diskuse (10 minut) ⏰ 1:40 - 1:50

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

**Q: Je to bezpečné?**
A: Ano - enterprise-grade security, encryption at rest i in transit, SOC 2 compliance.

---

## 🎯 Závěrečné shrnutí (2 minuty) ⏰ 1:50 - 1:52

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

## 📋 Checklist pro přípravu prezentace

### Den před webinářem:
- [ ] Nahrát plná Superstore data do Storage
- [ ] Spustit ETL Pipeline jednou (ověřit, že funguje)
- [ ] Otevřít Dashboard (ověřit, že zobrazuje data)
- [ ] Připravit 2. monitor pro sdílení obrazovky
- [ ] Otevřít všechny potřebné záložky v browseru
- [ ] Ověřit internet connection

### Otevřené záložky v browseru:
1. Keboola Dashboard
2. Storage - Buckets
3. Workspace
4. Transformations list
5. Flow detail
6. Data App Dashboard
7. Prezentační poznámky (tento soubor)

### Backup plán:
- Připravit screenshoty pro případ tech issues
- Nahrát video demo jako backup
- Mít připravené slides s klíčovými momenty

---

**Break a leg! 🎭🚀**


# Automatizace zpracování dat Superstore v Keboola

## 📋 Obsah webináře

Tento projekt demonstruje kompletní automatizaci ETL procesu pro analýzu dat Superstore v platformě Keboola.

### Cíle
- ✅ Automatizovat opakující se manuální operace s daty
- ✅ Vytvořit standardizovaný datový tok (Extract, Transform, Load)
- ✅ Vypočítat klíčové KPIs (tržby, náklady, marže, ROI)
- ✅ Připravit datamart pro reporting (Power BI, Tableau, Looker Studio)
- ✅ Využít LLM a low/no-code nástroje v Keboola

## 🗂️ Struktura projektu

```
expertim_keboola/
├── data/
│   └── superstore_sample.csv       # Vstupní dataset (9994 řádků)
├── README.md                        # Dokumentace
└── WEBINAR_GUIDE.md                 # Průvodce webinářem
```

## 📊 Dataset Superstore

Dataset obsahuje transakční data z fiktivního obchodu:

**Rozměry dat:**
- **Řádků:** 9,994 objednávek
- **Sloupců:** 21

**Klíčové atributy:**
- **Objednávky:** Order ID, Order Date, Ship Date, Ship Mode
- **Zákazníci:** Customer ID, Customer Name, Segment (Consumer/Corporate/Home Office)
- **Lokace:** Country, City, State, Region
- **Produkty:** Product ID, Category, Sub-Category, Product Name
- **Metriky:** Sales, Quantity, Discount, Profit

## 🚀 Implementace v Keboola

### 1. Extract - Načtení dat
Data Superstore budou nahrána do Keboola Storage:
- **Bucket:** `in.c-superstore`
- **Tabulka:** `orders`
- **Backend:** BigQuery

### 2. Transform - Zpracování dat

#### Transformace #1: Čištění a standardizace
- Kontrola datových typů
- Ošetření NULL hodnot
- Parsování datumů
- Vytvoření date dimensí (rok, čtvrtletí, měsíc)
- Standardizace názvů kategorií

#### Transformace #2: Výpočet KPIs
- **Marže (%)** = (Profit / Sales) × 100
- **ROI (%)** = (Profit / (Sales - Profit)) × 100
- **Průměrná hodnota objednávky** = Sales / Počet unikátních objednávek
- **Profit per Unit** = Profit / Quantity
- **Discount Impact** = Korelace mezi slevou a ziskovostí

#### Transformace #3: Finální datamart
Agregované metriky podle:
- Region
- Category & Sub-Category
- Customer Segment
- Časové periody (rok, čtvrtletí, měsíc)

### 3. Load - Export výsledků
- **Looker Studio:** Přímé připojení přes BigQuery
- **Google Sheets:** Export pro sdílení s týmem
- **Streamlit App:** Interaktivní dashboard

### 4. Orchestrace
**Conditional Flow** s fázemi:
1. **Extract:** Načtení dat (simulováno - data jsou již v Storage)
2. **Clean:** Čištění a standardizace
3. **Calculate:** Výpočet KPIs
4. **Aggregate:** Vytvoření datamartu
5. **Notify:** Notifikace o dokončení

## 📈 Očekávané výstupy

### KPI Dashboard metriky:
- **Celkové tržby:** $2.3M+
- **Celkový profit:** $286K+
- **Průměrná marže:** ~12%
- **Top kategorie:** Technology, Furniture, Office Supplies
- **Top region:** West

### Analytické insights:
1. Vliv slev na ziskovost
2. Profitabilita podle zákaznických segmentů
3. Sezónní trendy v tržbách
4. Nejziskovější produktové kategorie
5. Regionální výkonnost

## 🛠️ Technologie

- **Platforma:** Keboola Connection
- **SQL Dialekt:** BigQuery Standard SQL
- **Transformace:** SQL Transformations
- **Orchestrace:** Conditional Flows (keboola.flow)
- **Vizualizace:** Streamlit Data App
- **Export:** Google Sheets, Looker Studio

## 📚 Dokumentace Keboola

- [Transformations](https://help.keboola.com/transformations/)
- [Flows & Orchestration](https://help.keboola.com/orchestrator/)
- [Storage & Tables](https://help.keboola.com/storage/)
- [Data Apps](https://help.keboola.com/components/apps/)

## 👥 Autor

Vytvořeno pro webinář o automatizaci datových procesů v Keboola.

## 📅 Aktualizace

Poslední aktualizace: Leden 2026


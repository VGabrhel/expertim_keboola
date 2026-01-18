# 📤 Instrukce pro nahrání dat Superstore

## Před zahájením webináře

### Krok 1: Nahrání CSV do Keboola Storage

Data Superstore je nutné nahrát do Keboola Storage před spuštěním transformací. Následujte tyto kroky:

#### 1. Vytvoření bucketu
1. Přejděte do vašeho Keboola projektu
2. Klikněte na **Storage** v levém menu
3. Klikněte na **New Bucket**
4. Vyplňte:
   - **Name:** `superstore`
   - **Stage:** `in` (input bucket)
   - **Description:** `Superstore sales data for analytics`
5. Klikněte **Create Bucket**

#### 2. Nahrání CSV souboru
1. V bucketu `in.c-superstore` klikněte na **Add Table**
2. Vyberte **Upload File**
3. Vyberte soubor `data/superstore_sample.csv` z tohoto projektu
4. Nastavte:
   - **Table Name:** `orders`
   - **Primary Key:** (ponechte prázdné - není potřeba pro tento use case)
5. Klikněte **Upload**

#### 3. Ověření dat
Po nahrání by měla tabulka `in.c-keboola-ex-google-drive-01kesn1c8hda86aqqm3z5hvvn1.superstore_sample` obsahovat:
- **Řádků:** 9,994
- **Sloupců:** 21

**Náhled sloupců:**
```
Row ID, Order ID, Order Date, Ship Date, Ship Mode,
Customer ID, Customer Name, Segment, Country, City,
State, Postal Code, Region, Product ID, Category,
Sub-Category, Product Name, Sales, Quantity, Discount, Profit
```

### Krok 2: Alternativa - Nahrání přes Google Sheets Writer

Pokud máte data v Google Sheets, můžete je nahrát do Keboola pomocí [Google Sheets data destination connectoru](https://help.keboola.com/components/writers/storage/google-sheets/):

#### Postup:
1. Nejprve připravte data v Google Sheets s vašimi Superstore daty
2. V Keboola projektu:
   - Přejděte na **Components** → **Data Destination Connectors** → **Storage** → **Google Sheets**
   - Klikněte na **Create New Configuration**
   - Klikněte **Authorize Account** pro autorizaci vašeho Google účtu
3. Nastavte nahrávání:
   - Klikněte **New Table**
   - Vyberte tabulku z Storage (`in.c-keboola-ex-google-drive-01kesn1c8hda86aqqm3z5hvvn1.superstore_sample`)
   - Zvolte, zda chcete vytvořit nový spreadsheet nebo použít existující
   - Vyberte worksheet a metodu zápisu (přepsat nebo připojit řádky)
   - Klikněte **Save Sheet**

**Poznámka:** Google Sheets mají [striktní limity](https://support.google.com/drive/answer/37603) na velikost dokumentu. Pro větší datasety použijte raději přímé nahrání CSV přes UI nebo Google Drive data destination connector.

### Krok 3: Použití Python skriptu (Alternative)

Připravil jsem Custom Python komponentu `Superstore Data Loader`, která obsahuje ukázkový kód. 

**Poznámka:** Tato komponenta v současnosti zapisuje pouze sample data pro demonstraci. Pro webinář doporučuji nahrát plný dataset ručně přes UI, jak je popsáno výše.

## Kontrola po nahrání

Spusťte tento SQL dotaz v Keboola Workspace pro kontrolu:

```sql
SELECT 
  COUNT(*) as total_rows,
  COUNT(DISTINCT `Order ID`) as unique_orders,
  MIN(PARSE_DATE('%m/%d/%Y', `Order Date`)) as earliest_order,
  MAX(PARSE_DATE('%m/%d/%Y', `Order Date`)) as latest_order,
  ROUND(SUM(CAST(Sales AS FLOAT64)), 2) as total_sales,
  ROUND(SUM(CAST(Profit AS FLOAT64)), 2) as total_profit
FROM `in.c-keboola-ex-google-drive-01kesn1c8hda86aqqm3z5hvvn1.superstore_sample`;
```

**Očekávané výsledky:**
- `total_rows`: ~9,994
- `unique_orders`: ~5,009
- `earliest_order`: 2014-01-03
- `latest_order`: 2017-12-30
- `total_sales`: ~$2,297,200
- `total_profit`: ~$286,400

## Troubleshooting

### Problém: Bucket neexistuje
- Zkontrolujte, že jste vytvořili bucket s názvem `superstore` ve stage `in`
- Výsledný ID by měl být: `in.c-superstore`

### Problém: CSV se nenahrává
- Zkontrolujte, že soubor je validní CSV
- Ujistěte se, že má správné kódování (UTF-8)
- Zkontrolujte, že má hlavičku (první řádek jsou názvy sloupců)

### Problém: Chybějící sloupce
- Porovnejte sloupce v nahraném souboru s očekávanými (viz seznam výše)
- Zkontrolujte, že v CSV nejsou extra mezery nebo neočekávané znaky

## Další kroky

Po úspěšném nahrání dat můžete pokračovat s:
1. ✅ Vytvořením SQL transformací
2. ✅ Nastavením orchestrace (Flow)
3. ✅ Vytvořením Data App pro vizualizaci
4. ✅ Exportem do reporting nástrojů

---

📚 **Poznámka:** Tento krok simuluje Extract fázi ETL procesu. V produkčním prostředí by data přicházela automaticky z externích zdrojů (API, databáze, cloud storage) pomocí Keboola extractorů.


# 🔗 Rychlé odkazy - Superstore ETL v Keboola

## 📊 Dashboard a přehled

### Hlavní Dashboard
🏠 **Keboola Project Dashboard**  
https://connection.us-east4.gcp.keboola.com/admin/projects/5087/

---

## 🗄️ Storage - Data

### Buckets
📦 **Storage Overview**  
https://connection.us-east4.gcp.keboola.com/admin/projects/5087/storage/in.c-keboola-ex-google-drive-01kesn1c8hda86aqqm3z5hvvn1/overview

### Vstupní data
📥 **Bucket:** `in.c-superstore`  

### Transformovaná data
🔄 **Bucket:** `out.c-superstore-transformed`  
- Tabulka: `cleaned_orders`
- Tabulka: `orders_with_kpis`

### Finální datamarty
📊 **Bucket:** `01---Clean-and-Standardize-Superstore-Data
`  
- `datamart_region_category`
- `datamart_time_series`
- `datamart_customer_segment`
- `datamart_top_products`
- `datamart_executive_summary`

---

## 🔧 SQL Transformace

### Transformace #1: Clean and Standardize
**ID:** `01kesk822x7kdzessftrxrb4cc`  
**URL:** https://connection.us-east4.gcp.keboola.com/admin/projects/5087/transformations-v2/keboola.google-bigquery-transformation/01kesk822x7kdzessftrxrb4cc

**Funkce:**
- Parsování datumů
- Date dimensions (rok, měsíc, čtvrtletí)
- Datové typy (CAST)
- Standardizace textu
- Výpočet ship_days

**Output:** `out.c-01---Clean-and-Standardize-Superstore-Data.cleaned_orders`

---

### Transformace #2: Calculate KPIs
**ID:** `01kesk8fqxp6b62pzcpttxw7j7`  
**URL:** https://connection.us-east4.gcp.keboola.com/admin/projects/5087/transformations-v2/keboola.google-bigquery-transformation/01kesk8fqxp6b62pzcpttxw7j7

**Funkce:**
- Profit Margin (%)
- ROI (%)
- Cost calculation
- Profit per unit
- Discount impact analysis
- Profit categorization

**Output:** `out.c-02---Calculate-KPIs.orders_with_kpis`

---

### Transformace #3: Build Final Datamarts
**ID:** `01kesk97cfm4fa0d7ax606jzvc`  
**URL:** https://connection.us-east4.gcp.keboola.com/admin/projects/5087/transformations-v2/keboola.google-bigquery-transformation/01kesk97cfm4fa0d7ax606jzvc

**Funkce:**
- Vytvoření 5 agregovaných datamartů
- Regional & category analysis
- Time series data
- Customer segment metrics
- Top products ranking
- Executive summary KPIs

**Outputs:** 5 tabulek v `out.c-03---Build-Final-Datamarts`
`

---

### Všechny transformace
📝 **Transformations Dashboard**  
https://connection.us-east4.gcp.keboola.com/admin/projects/5087/transformations-v2

---

## 🔄 Orchestrace

### Superstore ETL Pipeline (Conditional Flow)
**ID:** `01keskb0s09wfgcwft43pez121`  
**URL:** https://connection.us-east4.gcp.keboola.com/admin/projects/5087/flows-v2/01keskb0s09wfgcwft43pez121

**Struktur:**
```
Start → Clean → Calculate KPIs → Build Datamarts → End
```

**Schedule:** Denně v 6:00 AM (Europe/Prague)

### Všechny flows
🔄 **Flows Dashboard**  
https://connection.us-east4.gcp.keboola.com/admin/projects/5087/flows-v2

---

## 📱 Data App - Dashboard

### Superstore Analytics Dashboard
**Config ID:** `01keskc4afw6vqmr72nt323bg4`  
**Data App ID:** `36555423`

**🌐 Live Dashboard URL:**  
https://superstore-analytics-dashboard-36555423.hub.us-east4.gcp.keboola.com

**Konfigurace:**  
https://connection.us-east4.gcp.keboola.com/admin/projects/5087/data-apps/01keskc4afw6vqmr72nt323bg4

**Status:** ✅ DEPLOYED  
**Auth:** HTTP Basic Auth (credentials v UI)

### Všechny Data Apps
📱 **Data Apps Dashboard**  
https://connection.us-east4.gcp.keboola.com/admin/projects/5087/data-apps

---

## 🐍 Python Komponenty

### Superstore Data Loader (Custom Python)
**ID:** `01kesk2k8znbw14bk70fzzyajx`  
**URL:** https://connection.us-east4.gcp.keboola.com/admin/projects/5087/components/kds-team.app-custom-python/01kesk2k8znbw14bk70fzzyajx

**Účel:** Demonstrační data loader (pro webinář nahrajte data ručně)

---

## 🔍 Workspace pro SQL explorace

### Vytvořit nový Workspace
**URL:** https://connection.us-east4.gcp.keboola.com/admin/projects/5087/workspaces

**Použití:**
- Explorativní SQL dotazy
- Data profiling
- Ad-hoc analýzy
- Testování SQL před vytvořením transformace

---

## 📚 Dokumentace

### Keboola Help Center
📖 **Hlavní dokumentace**  
https://help.keboola.com

**Specifické sekce:**
- Transformations: https://help.keboola.com/transformations/
- Flows: https://help.keboola.com/flows/
- Data Apps: https://help.keboola.com/components/apps/
- Storage: https://help.keboola.com/storage/

### Keboola Community
💬 **Community Forum**  
https://community.keboola.com

### BigQuery SQL Reference
📐 **BigQuery Standard SQL**  
https://cloud.google.com/bigquery/docs/reference/standard-sql/

---

## 🎯 Rychlé akce

### Spustit celý ETL proces
1. Jděte na Flow: https://connection.us-east4.gcp.keboola.com/admin/projects/5087/flows-v2/01keskb0s09wfgcwft43pez121
2. Klikněte **Run**
3. Sledujte progress

### Zobrazit výsledky na Dashboardu
1. Otevřete: https://superstore-analytics-dashboard-36555423.hub.us-east4.gcp.keboola.com
2. Přihlaste se (credentials v config UI)
3. Prohlédněte si interaktivní grafy

### Editovat SQL transformaci
1. Transformations: https://connection.us-east4.gcp.keboola.com/admin/projects/5087/transformations-v2
2. Vyberte transformaci
3. Klikněte **Edit**
4. Upravte SQL
5. **Save** a **Run**

### Zkontrolovat data v Storage
1. Storage: https://connection.us-east4.gcp.keboola.com/admin/projects/5087/storage
2. Vyberte bucket
3. Klikněte na tabulku
4. Prohlédněte si **Data Sample** nebo **Data Profile**

---

## 🚨 Troubleshooting odkazy

### Job History (logy všech běhů)
📜 **Jobs**  
https://connection.us-east4.gcp.keboola.com/admin/projects/5087/jobs

### Component Configurations
⚙️ **All Configurations**  
https://connection.us-east4.gcp.keboola.com/admin/projects/5087/components/configurations

### Project Settings
🛠️ **Settings**  
https://connection.us-east4.gcp.keboola.com/admin/projects/5087/settings

---

## 📧 Kontakt a podpora

### Keboola Support
- **Email:** support@keboola.com
- **Chat:** Dostupný v Keboola UI (pravý dolní roh)
- **Status Page:** https://status.keboola.com

### Pro technické dotazy
- **Stack Overflow:** Tag `keboola`
- **GitHub Issues:** https://github.com/keboola (pro open-source komponenty)

---

## 💾 Export komponent

### Exportovat konfiguraci
Každá konfigurace má možnost **Export to JSON**:
1. Otevřete komponentu
2. Menu → **Export to JSON**
3. Uložte JSON soubor
4. Můžete importovat do jiného projektu

### Git integrace
Pro verzování konfigurací:
- https://help.keboola.com/management/project/export/

---

## 🎓 Learning Resources

### Video tutoriály
🎥 **Keboola Academy**  
https://academy.keboola.com

### Use cases a templates
📦 **Component Templates**  
https://components.keboola.com

### Best Practices
✅ **Best Practices Guide**  
https://help.keboola.com/best-practices/

---

## 📊 Monitoring a metriky

### Project Usage Statistics
📈 **Usage Metrics**  
https://connection.us-east4.gcp.keboola.com/admin/projects/5087/settings/usage

**Co můžete sledovat:**
- Credit consumption
- Storage usage (GB)
- Number of jobs
- Job duration
- Data transfer

---

## ⚡ Zkratky klávesnice v UI

**Globální:**
- `?` - Zobrazit shortcuts help
- `g` + `h` - Home (Dashboard)
- `g` + `s` - Storage
- `g` + `t` - Transformations
- `g` + `f` - Flows

**V editoru SQL:**
- `Cmd/Ctrl` + `Enter` - Run query
- `Cmd/Ctrl` + `S` - Save
- `Cmd/Ctrl` + `F` - Find

---

## 🔖 Záložky pro webinář

**Doporučené pořadí:**

1. 🏠 Dashboard: https://connection.us-east4.gcp.keboola.com/admin/projects/5087/
2. 📦 Storage: https://connection.us-east4.gcp.keboola.com/admin/projects/5087/storage
3. 🔍 Workspace: https://connection.us-east4.gcp.keboola.com/admin/projects/5087/workspaces
4. 📝 Transformations: https://connection.us-east4.gcp.keboola.com/admin/projects/5087/transformations-v2
5. 🔄 Flow: https://connection.us-east4.gcp.keboola.com/admin/projects/5087/flows-v2/01keskb0s09wfgcwft43pez121
6. 📱 Data App: https://superstore-analytics-dashboard-36555423.hub.us-east4.gcp.keboola.com
7. 📋 Tento soubor (pro reference)

---

**Vytvořeno:** Leden 2026  
**Projekt ID:** 5087  
**Status:** ✅ Všechny komponenty aktivní

**Pro aktualizaci tohoto souboru:**  
Pokud vytvoříte nové komponenty, přidejte jejich ID a URL do příslušné sekce.


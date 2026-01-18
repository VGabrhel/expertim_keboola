# 📁 Přehled projektu - Superstore ETL v Keboola

---

## 📂 Struktura projektu

```
expertim_keboola/
│
├── 📊 data/
│   └── superstore_sample.csv         
│   └── ...    
├── 📊 documentation/
     ├── 📖 README.md                        Hlavní dokumentace projektu
     ├── 🎯 WEBINAR_GUIDE.md                 Krok-za-krokem průvodce
     ├── 📤 DATA_UPLOAD_INSTRUCTIONS.md      Jak nahrát data do Keboola
     ├── 📋 SUMMARY.md                       Shrnutí implementace
     ├── 🎤 PRESENTATION_GUIDE.md            Průvodce pro prezentaci
     ├── 🔗 QUICK_LINKS.md                   Všechny URL odkazy
     └── 📄 INDEX.md                         Tento soubor
```

---

## 📚 Dokumentační soubory

### 1. README.md
**Účel:** Hlavní dokumentace projektu  
**Obsahuje:**
- Úvod do projektu
- Popis datasetu Superstore
- Architektura řešení
- Očekávané výstupy
- Technologie

**Čtěte první:** Pro pochopení celkového kontextu projektu

---

### 2. WEBINAR_GUIDE.md
**Účel:** Detailní návod pro webinář  
**Obsahuje:**
- 10 částí s časovým plánem (90 minut)
- Krok-za-krokem instrukce
- SQL kód pro všechny transformace
- Ukázkové SQL dotazy pro exploraaci
- Očekávané metriky

**Čtěte před webinářem:** Pro přípravu obsahu

---

### 3. DATA_UPLOAD_INSTRUCTIONS.md
**Účel:** Jak nahrát Superstore data  
**Obsahuje:**
- Vytvoření bucketu v Storage
- Upload CSV souboru
- Ověření dat
- Troubleshooting

**Použijte první:** Před spuštěním jakýchkoliv transformací

---

### 4. SUMMARY.md
**Účel:** Kompletní přehled vytvořených komponent  
**Obsahuje:**
- Seznam všech 3 SQL transformací (s ID)
- Conditional Flow konfigurace
- Streamlit Data App (s URL)
- Očekávané metriky po spuštění
- Checklist pro webinář
- Troubleshooting tipy

**Reference dokument:** Pro rychlé najití ID a detailů

---

### 5. PRESENTATION_GUIDE.md
**Účel:** Scénář pro prezentaci webináře  
**Obsahuje:**
- Časový plán po minutách (60 min)
- Co ukázat v každé části
- Komentáře k jednotlivým slides
- Demo flow
- Q&A preparation
- Závěrečné shrnutí

**Pro presentera:** Používejte během webináře jako cheat sheet

---

### 6. QUICK_LINKS.md
**Účel:** Všechny URL odkazy na jednom místě  
**Obsahuje:**
- Odkazy na Storage buckets
- URL každé transformace
- Flow configuration
- Data App dashboard
- Dokumentace
- Support contacts

**Snadný přístup:** Pro rychlé otevření komponent

---

## 🔧 Vytvořené komponenty v Keboola

### Extraktor

| Typ | Název | ID | URL |
|-----|-------|----|----|
| Extractor | Extractor - GSheets | `01kesn1c8hda86aqqm3z5hvvn1` | [Extractor - GSheets](https://connection.us-east4.gcp.keboola.com/admin/projects/5087/components/keboola.ex-google-drive/01kesn1c8hda86aqqm3z5hvvn1) |

### SQL Transformace (3×)

| # | Název | ID | Funkce |
|---|-------|----|----|
| 1 | Clean and Standardize | `01kesk822x7kdzessftrxrb4cc` | Čištění, parsování datumů, date dimensions |
| 2 | Calculate KPIs | `01kesk8fqxp6b62pzcpttxw7j7` | Marže, ROI, cost, profit categorization |
| 3 | Build Final Datamarts | `01kesk97cfm4fa0d7ax606jzvc` | 5 agregovaných datamartů pro reporting |

### Writer

| Typ | Název | ID | Účel |
|-----|-------|----|----|
| Writer | Writer - GSheets | `01kesn1c8hda86aqqm3z5hvvn1` | [Writer - GSheets](https://connection.us-east4.gcp.keboola.com/admin/projects/5087/components/keboola.wr-google-sheets/01kf8am3g3t2scq348fr1vphq0) |

### Orchestrace

| Typ | Název | ID | Funkce |
|-----|-------|----|----|
| Conditional Flow | Superstore ETL Pipeline | `01keskb0s09wfgcwft43pez121` | Automatická orchestrace 3 transformací |



---

## 🎯 Rychlý start

### Pro účastníka webináře:

1. **Přečíst:** `README.md` (5 min)
2. **Nahrát data:** Podle `DATA_UPLOAD_INSTRUCTIONS.md` (10 min)
3. **Spustit Flow:** Kliknout Run na Flow (5 min)
4. **Zobrazit výsledky:** Otevřít Dashboard (2 min)

**Celkem:** ~22 minut od začátku k výsledkům!

---

## 📊 Datový tok

```
┌─────────────────────────────────────────────────┐
│          SUPERSTORE Dataset                     │
└──────────────────┬-─────────────────────────────┘
                   │
                   │
        ┌──────────▼───────────┐
        │  Nahrání do Storage  │
        │  in.c-superstore     │
        │      (orders)        │
        └──────────┬───────────┘
                   │
                   │
        ┌──────────▼───────────┐
        │  Nahrání do Storage  │
        │  in.c-superstore     │
        │      (orders)        │
        └─────────┬──-─────────┘
                  │
                  ▼
            ┌───────-─┐
            │Transform│
            │   #1    │
            │ Clean   │
            └────┬─-──┘
                 │
                 ▼
            ┌─────────┐
            │Transform│
            │   #2    │
            │  KPIs   │
            └────┬────┘
                 │
                 ▼
            ┌──────────┐
            │Transform │
            │   #3     │
            │Datamarts │
            └────┬─────┘
                 │
                 ▼
         ┌─────────────┐
         │   Google    │
         │   Sheets    │
         │  (Writer)   │
         └─────────────┘
```

---

## 🎓 Co se naučíte na webináři

✅ Automatizace procesů (ETL) v nástroji Keboola

✅ SQL transformace v Keboola na pozadí BigQuery  

✅ Práci s datovými typy 

✅ Agregace a datamarty  (Business KPIs (marže, ROI, cost analysis))

✅ Reporting strategie  

✅ Dokumentace  

✅ Prezentace technických řešení  

✅ Troubleshooting  

---

## 🛠️ Technologie stack

| Vrstva | Technologie |
|--------|-------------|
| **Platform** | Keboola Connection |
| **SQL Backend** | Google BigQuery |
| **Transformations** | BigQuery Standard SQL |
| **Orchestration** | Conditional Flows (keboola.flow) |
| **Visualization** | Looker Studio |
| **Data Storage** | BigQuery Tables |
| **Scheduling** | Keboola Scheduler |

---

## 📞 Podpora a kontakty

### Po webináři:
- 📖 Dokumentace: https://help.keboola.com
- 💬 Community: https://community.keboola.com
- 📧 Support: support@keboola.com

---

## ✅ Checklist před webinářem

### Pro účastníky (1 den předem):
- [ ] Stáhnout dataset `superstore_sample.csv`
- [ ] Přečíst `README.md`
- [ ] Přihlásit se do Keboola (nebo vytvořit trial account)
- [ ] Připravit otázky

---

## 🎯 Success metrics webináře

### Pro účastníky:
- ✅ Pochopili koncept ETL v Keboola
- ✅ Dokážou vytvořit vlastní transformaci
- ✅ Rozumí orchestraci přes Flows
- ✅ Chápou hodnotu automatizace

---

## 🚀 Co dál po webináři

### Okamžitě:
1. Zkuste klonovat komponenty do svého projektu
2. Experimentujte s SQL dotazy
3. Upravte Dashboard podle svých potřeb

### Tento týden:
1. Identifikujte vlastní use case pro automatizaci
2. Nahrajte vlastní data
3. Vytvořte první transformaci

### Tento měsíc:
1. Vybudujte kompletní ETL pipeline
2. Přidejte další datové zdroje
3. Vytvoříte dashboardy pro stakeholdery

---

## 📖 Doporučené čtení

### Pro začátečníky:
1. **Keboola Basics:** https://help.keboola.com/tutorial/
2. **SQL Transformations:** https://help.keboola.com/transformations/
3. **Flows Guide:** https://help.keboola.com/flows/

### Pro pokročilé:
1. **BigQuery Optimization:** https://cloud.google.com/bigquery/docs/best-practices
2. **Data Modeling:** https://help.keboola.com/tutorial/ad-hoc/data-modeling/
3. **Python Transformations:** https://help.keboola.com/transformations/python-plain/

### Pro experty:
1. **Custom Components:** https://developers.keboola.com/extend/
2. **API Reference:** https://developers.keboola.com/integrate/
3. **Advanced Flows:** https://help.keboola.com/orchestrator/running/

---

## 🎁 Bonus materiály

V projektu najdete:
- ✅ Kompletní SQL kód všech transformací
- ✅ Python kód Streamlit Dashboardu
- ✅ Explorativní SQL dotazy
- ✅ Flow configuration (JSON export možný)
- ✅ Dokumentaci best practices

Můžete použít jako template pro vlastní projekty!

---

## 🌟 Závěrečné myšlenky

**Z Excelu k Enterprise Data Platform za 60 minut!** 🚀

Tento projekt demonstruje, jak lze:
- ✅ Automatizovat repetitivní manuální práci
- ✅ Standardizovat datové procesy
- ✅ Zlepšit kvalitu a dostupnost dat
- ✅ Ušetřit stovky hodin ročně
- ✅ Umožnit data-driven rozhodování

**A to vše bez jediného řádku infrastrukturního kódu!**

Keboola platformu se postará o:
- 🔐 Bezpečnost a encryption
- 📈 Škálování (od KB po PB)
- 🔄 Monitoring a alerting
- 💾 Backup a disaster recovery
- 🌍 Global availability

**Vy se zaměřte na business logiku a value!**

---

**Vytvořeno:** Leden 2026  
**Autor:** Vít Gabrhel  
**Verze dokumentace:** 1.0


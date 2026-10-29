# Lending Guard: Credit Portfolio Quality & Loss Intelligence

![Python](https://img.shields.io/badge/Python-Pandas-3776AB?logo=python&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-CC2927?logo=microsoftsqlserver&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black)

An end-to-end lending risk analytics project: **Python/Pandas** for cleaning, **SQL Server** for analysis and **Power BI** for an interactive dashboard, built on a synthetic multi-table loan dataset.

<img width="446" height="249" alt="Screenshot 2026-10-29 140555" src="https://github.com/user-attachments/assets/968785e9-42d4-4f6c-a19e-5d785e231b44" />

<img width="446" height="249" alt="Screenshot 2026-10-29 140625" src="https://github.com/user-attachments/assets/3026f7c7-3c2e-4cbd-b226-398d242702d9" />




## Table of Contents

- [Problem Statement](#problem-statement)
- [Key Insights](#key-insights)
- [Tech Stack](#tech-stack)
- [Dataset](#dataset)
- [Approach](#approach)
  - [Metric Definitions](#metric-definitions)
- [Dashboard](#dashboard)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Author](#author)

## Problem Statement

Where are loan delinquency and defaults concentrated, which customer, loan and acquisition characteristics are associated with them, and how do credit losses change over time?

[Back to top](#lending-guard-credit-portfolio-quality--loss-intelligence)

## Key Insights

- **Scale:** 120.25K applications led to 77.03K loans, with 3,656 delinquent, 2,989 defaulted and 903 written-off loans.
- **Channels:** Social Media is the riskiest channel (8.78% delinquency / 7.23% default); Email is the safest (1.73% / 1.32%).
- **Customers:** Unemployed borrowers show the highest rates (5.5% delinquency / 4.7% default); contract employees the lowest (4.5% / 3.6%).
- **Loan types:** Differences are small. Personal and Consumer loans run slightly higher than Education and Emergency.
- **Underwriting:** Policy V2 shows a lower default rate than V1 (3.60% vs 4.36%).
- **Cohorts:** The 2025 cohort has lower default (3.75% vs 4.33%) and write-off (1.13% vs 1.30%) rates than 2024, though newer loans have had less time to default.
- **Credit loss:** The monthly trend rises for most of the period, then dips in the latest month. That needs a data-completeness check.
- **Data-quality flag:** The low-risk score showed a higher default rate than the high-risk score, so `risk_score` reliability is treated as unresolved.

> **Note:** This project uses synthetic data. Findings show segments worth investigating, not causes.

[Back to top](#lending-guard-credit-portfolio-quality--loss-intelligence)

## Tech Stack

| Tool | Purpose |
|---|---|
| Python, Pandas | Data loading, cleaning, validation |
| SQL Server | Joins, aggregations, rates, cohort and segment analysis |
| Power BI | Two-page interactive dashboard |

[Back to top](#lending-guard-credit-portfolio-quality--loss-intelligence)

## Dataset

Synthetic lending data in 8 CSV tables: `applications`, `loans`, `customers`, `credit_risk`, `collections`, `repayments` (489K+ rows), `acquisition` and `monthly_business_kpis`.

Loans can have many repayment, collection or risk records, so every metric uses **distinct loan IDs** to avoid inflated counts from one-to-many joins.

Dataset: https://github.com/Mohamedsul/namaa-finance-synthetic-dataset/tree/main/data
[Back to top](#lending-guard-credit-portfolio-quality--loss-intelligence)

## Approach

1. **Validate** the business problem and confirm the data supports it.
2. **Clean** in Pandas: check keys and grain, handle missing values, standardize dates and numbers, separate true duplicates from valid repeated events.
3. **Analyze** in SQL Server: portfolio scale, cohort trends, and risk by customer, loan type, policy and channel.
4. **Visualize** in Power BI with slicers for year, loan type and acquisition channel.
5. **Recommend** next steps, with caveats stated.

### Metric Definitions

| Metric | Definition |
|---|---|
| Default rate | Distinct loans with `loan_status = 'Defaulted'` / loans in scope |
| Delinquency rate | Distinct loans with delinquency in collections (30+/60+/90+ DPD) / loans in scope |
| Written-off rate | Distinct written-off loans / loans in scope |
| Cohort | Year of loan disbursement |

Repayment and collection records disagree in places. Rather than force a reconciliation, the project documents the issue and uses one agreed source per metric.

[Back to top](#lending-guard-credit-portfolio-quality--loss-intelligence)

## Dashboard

**Page 1: Loan Portfolio Overview.** KPI cards, loan status distribution, applications vs. loans over time, and delinquent/default/written-off trends.

<img width="446" height="249" alt="Screenshot 2026-10-29 140555" src="https://github.com/user-attachments/assets/d76e5744-05e0-452a-a916-807b76d9d3b1" />


**Page 2: Delinquency and Default Drivers.** Risk by customer characteristics, loan type or policy, monthly credit loss trend, and risk by acquisition channel.

<img width="446" height="249" alt="Screenshot 2026-10-29 140625" src="https://github.com/user-attachments/assets/36779a9c-1197-4506-9d8a-f125ed1cc733" />


[Back to top](#lending-guard-credit-portfolio-quality--loss-intelligence)

## Recommendations

1. **Investigate Social Media acquisition** (volume, loan size, DTI, campaign quality, losses) before cutting spend.
2. **Strengthen affordability checks** using combinations of attributes, not employment status alone.
3. **Validate V1 vs. V2** on comparable borrowers and mature cohorts.
4. **Fix risk-band and score logic** before relying on them.
5. **Track credit losses and recoveries** alongside default rates.

[Back to top](#lending-guard-credit-portfolio-quality--loss-intelligence)

## Limitations

Synthetic data. Association is not causation. Recent cohorts are immature. Source tables contain unresolved inconsistencies. The dashboard has no dedicated collections/recovery page.

[Back to top](#lending-guard-credit-portfolio-quality--loss-intelligence)

## Repository Structure

```
lending-guard/
├── README.md
├── data/            # CSV files
├── notebooks/       # Python / Pandas cleaning
├── sql/             # SQL Server queries
├── dashboard/       # Power BI (.pbix)
├── images/          # Dashboard screenshots
└── docs/
    └── detailed_project_report.pdf
```

[Back to top](#lending-guard-credit-portfolio-quality--loss-intelligence)

## Getting Started

```bash
git clone https://github.com/<your-username>/lending-guard.git
```

1. Run the notebook(s) in `notebooks/` to clean the data.
2. Load the tables into SQL Server and run the scripts in `sql/`.
3. Open the `.pbix` file in Power BI Desktop and point it to your SQL Server instance.

Full methodology: [detailed project report](docs/detailed_project_report.pdf)

[Back to top](#lending-guard-credit-portfolio-quality--loss-intelligence)

## Author

**Apoorva Maheshwari**

[LinkedIn](https://www.linkedin.com/in/apoorva-maheshwari-05b1b2b8/) | [GitHub](https://github.com/ApoorvaM)

[Back to top](#lending-guard-credit-portfolio-quality--loss-intelligence)

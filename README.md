# RampFlow — End-to-End Baggage Operations Analytics Platform
## From Aircraft Arrival to Passenger Baggage Delivery

# Introduction
RampFlow is an aviation data engineering and analytics project built to transform simulated ramp operations data into actionable business insights. The project uses 1,770 operational records covering the period from 1 November 2025 to 26 February 2026, across flight handling, loading supervisor deployment, and baggage belt allocation activities.

The project uses Excel, Microsoft SQL Server, and Power BI. The operational CSV datasets are ingested into SQL Server and processed through a Bronze, Silver, and Gold data architecture to store, clean, transform, and enrich the data for analytical use. The Gold layer is then consumed by Power BI and AD-HOC SEARCH to track ramp operations performance and support data-driven decision-making by ramp operations supervisors.

The current pipeline uses full batch ingestion, with Python planned as a future enhancement to automate and schedule daily data ingestion.

# Objective
Develop a modern data warehouse using **SQL SERVER** to consolidate **baggage handling data** enabling analytical reporting and data driven decision making.

### Specifications
-**Data Sources**: Import data from 3 sources (Flight handling report, Baggage sort area log, loading supervisor deployment)-all provided as **CSV files**.<br>
-**Data Quality**: Clean and resolve data quality issues before analysis.<br>
-**Integration**: Combine the 3 sources into a single, user friendly SQL VIEW optimized for analytical queries.<br>
-**Serve**: **SQL based AD-HOC SEARCH** and **POWER BI Dashboard** to deliver detailed insights into: <br>
 -**Ramp baggage handling operations performance**: covering activities from aircraft chocks on to baggage delivery to passengers.
   These insights empower stakeholders with key business metrics, enabling strategic decision making.
-**Scope**: No historization (SCDs).<br>
-**Documentation**: Provide clear documentation of the sql view to support both business stakeholders and analytics teams.<br>

# Architecture
![image alt]()



## About Me
Hi there! I'm **Josphat Mulambu** <br>
**B.ENG. AERONAUTICAL ENGINEERING**

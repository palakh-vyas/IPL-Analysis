# IPL-Analysis
SQL analysis of 17 IPL seasons (2008-2024): win rates, toss impact, bat first vs chase. Built with SQLite
# IPL Data Analytics: Match Outcomes and Player Performance (SQL)

Analysis of 17 IPL seasons (2008-2024) using SQL to find what drives winning:
toss decisions, batting first vs chasing, venues, and player performance.

## Dataset
[IPL Complete Dataset (2008-2024)](https://www.kaggle.com/datasets) by Prateek Bhardwaj (Kaggle).
- `matches`: 1,095 matches
- `deliveries`: 260,920 ball-by-ball records

The raw CSV files are not included. Download them from Kaggle and import into SQLite.

## Tools
SQLite (DB Browser for SQLite). Power BI dashboard (in progress).

## Data Cleaning
- Converted text "NA" values to NULL
- Standardized renamed teams (Delhi Daredevils to Delhi Capitals, Kings XI Punjab to Punjab Kings, Royal Challengers Bangalore to Bengaluru)
- Merged 58 venue spellings into 36 stadiums
- Added helper columns: match phase, legal-ball flag, balls-faced flag, super-over flag
- Found 6 matches (rain-affected, D/L) whose result label disagreed with the actual batting order, so batting order was taken from ball-by-ball data

## Key Findings
- Chasing teams won **54.28%** of 1,076 decided matches (bat first: 45.72%)
- Excluding 21 rain-affected matches changes this by under 0.4 points
- Toss winners won **50.83%** of decided matches, close to a coin flip
- Chennai Super Kings: 58.23% win rate over 237 decided matches

## SQL Skills Used
Joins, CTEs, subqueries, CASE WHEN, window functions (RANK, LAG, moving average)

## Repository Structure
- `sql/`: cleaning and analysis scripts
- `results/`: exported query results
- `screenshots/`: result screenshots

## Status
Batch 1 (team, toss, bat first vs chase) complete. Venue, batting and bowling analysis and the Power BI dashboard are in progress.

## Author
Palakh Vyas

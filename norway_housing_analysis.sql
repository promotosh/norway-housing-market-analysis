-- ============================================================
-- Norwegian Housing Market Analysis
-- Data source: Statistics Norway (SSB) - Table 07221
-- Price index for existing dwellings, 2015K1 to 2026K1
-- Prepared as portfolio work for Business Intelligence Analyst role
-- ============================================================

-- TABLE STRUCTURE
-- housing_price_index (
--   region        TEXT,    -- 12 Norwegian regions
--   quarter       TEXT,    -- e.g. '2023K1' (year + quarter number)
--   year          INTEGER,
--   q             INTEGER, -- 1-4 (quarter of year)
--   dwelling_type TEXT,    -- Total / Detached houses / Row houses / Multi-dwelling
--   price_index   REAL     -- Index value (base: 2015 = 100)
-- )


-- ============================================================
-- QUERY 1: Which Norwegian regions have grown the fastest?
-- Business use: Helps Hjem.no prioritise where to focus
--               marketing and agent acquisition efforts.
-- ============================================================

SELECT
    region,
    ROUND(MAX(CASE WHEN quarter = '2015K1' THEN price_index END), 1) AS index_2015,
    ROUND(MAX(CASE WHEN quarter = '2026K1' THEN price_index END), 1) AS index_2026,
    ROUND(
        (MAX(CASE WHEN quarter = '2026K1' THEN price_index END) -
         MAX(CASE WHEN quarter = '2015K1' THEN price_index END))
        / MAX(CASE WHEN quarter = '2015K1' THEN price_index END) * 100
    , 1) AS growth_pct
FROM housing_price_index
WHERE dwelling_type = 'Total'
  AND region != 'The whole country'
GROUP BY region
ORDER BY growth_pct DESC;

-- KEY FINDING: Oslo leads at +79% growth. Bergen follows closely at +61%,
-- outpacing Trondheim (+46%) and Stavanger (+49%). This signals Bergen
-- is a high-priority market where Hjem.no has strong growth potential.


-- ============================================================
-- QUERY 2: How did COVID-19 affect the Norwegian housing market?
-- Business use: Understanding market shocks helps Hjem.no explain
--               anomalies in historical reporting to clients.
-- ============================================================

SELECT
    quarter,
    ROUND(MAX(CASE WHEN region = 'The whole country'   THEN price_index END), 1) AS norway_total,
    ROUND(MAX(CASE WHEN region = 'Oslo including Bærum' THEN price_index END), 1) AS oslo,
    ROUND(MAX(CASE WHEN region = 'Bergen'               THEN price_index END), 1) AS bergen,
    ROUND(MAX(CASE WHEN region = 'Stavanger'            THEN price_index END), 1) AS stavanger,
    ROUND(MAX(CASE WHEN region = 'Trondheim'            THEN price_index END), 1) AS trondheim
FROM housing_price_index
WHERE dwelling_type = 'Total'
  AND year BETWEEN 2019 AND 2022
GROUP BY quarter
ORDER BY quarter;

-- KEY FINDING: Contrary to initial expectations, COVID did NOT crash 
-- Norwegian housing prices. From 2020K1 to 2021K2, national prices 
-- surged +16%. Oslo jumped +16%, Bergen +11%. The market only cooled 
-- in late 2022 as interest rates rose sharply.


-- ============================================================
-- QUERY 3: Which property type is growing fastest in each city?
-- Business use: Informs which listing types Hjem.no should
--               prioritise in product development and agent outreach.
-- ============================================================

SELECT
    region,
    dwelling_type,
    ROUND(MAX(CASE WHEN quarter = '2015K1' THEN price_index END), 1) AS index_2015,
    ROUND(MAX(CASE WHEN quarter = '2026K1' THEN price_index END), 1) AS index_2026,
    ROUND(
        (MAX(CASE WHEN quarter = '2026K1' THEN price_index END) -
         MAX(CASE WHEN quarter = '2015K1' THEN price_index END))
        / MAX(CASE WHEN quarter = '2015K1' THEN price_index END) * 100
    , 1) AS growth_pct
FROM housing_price_index
WHERE dwelling_type != 'Total'
  AND region IN ('Oslo including Bærum', 'Bergen', 'Stavanger', 'Trondheim')
GROUP BY region, dwelling_type
ORDER BY region, growth_pct DESC;

-- KEY FINDING: Multi-dwelling (apartments) dominate in Oslo (+83%) and
-- Stavanger (+54%). In Bergen, Row houses lead (+62%), suggesting stronger
-- family home demand. In Trondheim, Detached houses outperform apartments —
-- a unique pattern worth monitoring for targeted listing campaigns.


-- ============================================================
-- QUERY 4: How does Bergen compare to Oslo and the national average?
-- Business use: Zrch is headquartered in Bergen. Understanding Bergen's
--               position relative to Oslo informs local strategy and
--               pitch materials for Bergen-area real estate clients.
-- ============================================================

SELECT
    year,
    ROUND(AVG(CASE WHEN region = 'Bergen'                THEN price_index END), 1) AS bergen_avg,
    ROUND(AVG(CASE WHEN region = 'Oslo including Bærum'  THEN price_index END), 1) AS oslo_avg,
    ROUND(AVG(CASE WHEN region = 'The whole country'     THEN price_index END), 1) AS norway_avg,
    ROUND(
        AVG(CASE WHEN region = 'Bergen' THEN price_index END) -
        AVG(CASE WHEN region = 'Oslo including Bærum' THEN price_index END)
    , 1) AS bergen_vs_oslo_gap
FROM housing_price_index
WHERE dwelling_type = 'Total'
GROUP BY year
ORDER BY year;

-- KEY FINDING: The Bergen-Oslo price gap peaked at -32 index points in 2022,
-- but has been closing rapidly. In 2026 the gap is only -16 points — the
-- narrowest since 2016. Bergen is catching up to Oslo, making it an
-- increasingly competitive and attractive market for Hjem.no.


-- ============================================================
-- QUERY 5: Are there consistent seasonal patterns in the market?
-- Business use: Seasonal insights help Hjem.no advise real estate
--               agents on optimal listing timing, and help the
--               analytics team normalise data in monthly reports.
-- ============================================================

SELECT
    q AS quarter_of_year,
    CASE q
        WHEN 1 THEN 'Q1 (Jan-Mar)'
        WHEN 2 THEN 'Q2 (Apr-Jun)'
        WHEN 3 THEN 'Q3 (Jul-Sep)'
        WHEN 4 THEN 'Q4 (Oct-Dec)'
    END AS season,
    ROUND(AVG(CASE WHEN region = 'The whole country'    THEN price_index END), 1) AS norway_avg_index,
    ROUND(AVG(CASE WHEN region = 'Bergen'               THEN price_index END), 1) AS bergen_avg_index,
    ROUND(AVG(CASE WHEN region = 'Oslo including Bærum' THEN price_index END), 1) AS oslo_avg_index
FROM housing_price_index
WHERE dwelling_type = 'Total'
  AND year BETWEEN 2016 AND 2025
GROUP BY q
ORDER BY q;

-- KEY FINDING: Q2 (spring) is consistently the strongest quarter across
-- all regions — prices peak in April-June every year. Q1 (winter) is
-- the weakest. This means real estate agents listing in Q2 can expect
-- higher prices, while Q1 listings may need adjusted pricing strategies.
-- Hjem.no could use this insight to build a seasonal listing advisor tool.

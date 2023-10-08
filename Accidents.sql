


-- Calculating Total deaths
SELECT
    "Country Name",
    "Age Group",
    "Number",
    "Year",
    "Death rate per 100 000 population",
    CASE
        WHEN "Death rate per 100 000 population" = 0 THEN 0  
        ELSE ROUND(("Number" / "Death rate per 100 000 population") * 100000)
    END AS "Total population"
FROM "Accidents".accidents
WHERE "Number" != 0 AND "Death rate per 100 000 population" != 0;


--Top 10 countries with Maximum death rate over 100,000 deaths
with a as (SELECT
    "Country Name",
    "Age Group",
    "Sex",	   
    "Number",
    "Year",
    "Death rate per 100 000 population" as "death rate", 
    CASE
        WHEN "Death rate per 100 000 population" = 0 THEN 0  
        ELSE ROUND(("Number" / "Death rate per 100 000 population") * 100000)
    END AS "Total population"
FROM "Accidents".accidents
WHERE "Number" != 0 AND "Death rate per 100 000 population" != 0),
b as (select "Country Name",(sum("Number") / sum("Total population") * 100000) as "Death Rate" from a
GROUP BY "Country Name")
SELECT
    "Country Name",
    Max("Death Rate") AS "Max Death Rate"
FROM b
GROUP BY "Country Name"
order by "Max Death Rate" Desc
limit 10;

--Top 10 countries with Maximum death rate over 100,000 deaths each year
with a as (SELECT
    "Country Name",
    "Age Group",
    "Sex",	   
    "Number",
    "Year",
    "Death rate per 100 000 population" as "death rate", 
    CASE
        WHEN "Death rate per 100 000 population" = 0 THEN 0  
        ELSE ROUND(("Number" / "Death rate per 100 000 population") * 100000)
    END AS "Total deaths"
FROM "Accidents".accidents
WHERE "Number" != 0 AND "Death rate per 100 000 population" != 0),
b as (select "Country Name","Year" ,(sum("Number") / sum("Total deaths") * 100000) as "Death Rate",
	  RANK() OVER (PARTITION BY "Year" ORDER BY (SUM("Number") / SUM("Total deaths") * 100000) DESC) AS "Rank" from a
GROUP BY "Country Name", "Year")
SELECT
    "Country Name",
    "Year",
    MAX("Death Rate") AS "Max Death Rate"
FROM b
where "Rank" <11
GROUP BY "Country Name", "Year"
order by "Year" desc,"Max Death Rate" desc;

--Top 10 countries with Minimum death rate over 100,000 deaths each year
with a as (SELECT
    "Country Name",
    "Age Group",
    "Sex",	   
    "Number",
    "Year",
    "Death rate per 100 000 population" as "death rate", 
    CASE
        WHEN "Death rate per 100 000 population" = 0 THEN 0  
        ELSE ROUND(("Number" / "Death rate per 100 000 population") * 100000)
    END AS "Total population"
FROM "Accidents".accidents
WHERE "Number" != 0 AND "Death rate per 100 000 population" != 0),
b as (select "Country Name","Year" ,(sum("Number") / sum("Total deaths") * 100000) as "Death Rate",
	  RANK() OVER (PARTITION BY "Year" ORDER BY (SUM("Number") / SUM("Total population") * 100000) ASC) AS "Rank" from a
GROUP BY "Country Name", "Year")
SELECT
    "Country Name",
    "Year",
    MIN("Death Rate") AS "Min Death Rate"
FROM b
where "Rank" <11
GROUP BY "Country Name", "Year"
order by "Year" desc,"Min Death Rate" Asc;








# Introduction
Road accidents represent a global public health challenge that affects millions of lives every year.While some causes of death, such as certain diseases, are beyond our control, it's crucial to recognize that fatalities resulting from accidents are, to a large extent, within our grasp to prevent. These accidents are often due to the carelessness of drivers and deficiencies in road management.

In this exploratory data analysis (EDA) project, we analyze road accident mortality rates. The goal is to gain valuable insights into the patterns, trends, and potential factors that influence the occurrence of deaths due to road accidents. By analyzing available data, we aim to identify high-risk areas, demographics, and circumstances associated with these tragic incidents.

## Data Source
Data is taken from Open Data Portal of  World Health Organization (WHO).

## Data Variables 
* Country Name 
* Year
* Sex
* Age Group (Age of person in this data are all above 15.)
* Number(Number of death due to Road Accident.)
* Percentage of Cause-specific death out of total deaths
* Death rate per 100,000 Population

## Data
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/e61689d6-a05b-4453-83e1-1ba9ec4c3f22) ![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/b92656d4-5223-4098-b4e8-d22d0ad525d8)

## Objectives
* To analyze the dispersion of mortality rates across countries, Age Group and sex.
* To analyze the percentage of cause-specific deaths out of total deaths across countries, Age Group and sex.
* To analyze which age group is most affected by death due to road accidents.
* To analyze which gender is most affected by death due to road accidents.
* To analyze trends in mortality rates over the years.

## Creating a View for Total Population

As our data doesn't have a 'Total Population' column but does have the 'Death rate per 100,000 Population,' which is essentially the Cause-specific mortality rate (CSMR) calculated using the formula 
###### CSMR = (Number of Deaths from a Specific Cause / Total Population) * 100,000
we can estimate the 'Total Population' using this formula. We will create a view with a 'Total Population' column as it is used further in our analysis.


            CREATE VIEW road_accidents AS SELECT
                                *,
                               ROUND(("Number" / "Death rate per 100 000 population") * 100000)
                               AS "Total population"
			       FROM "Accidents".accidents
	                        where "Death rate per 100 000 population" !=0 and "Number" != 0;

             Select * from road_accidents;

 #### Output
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/077e08b4-ed40-461f-8798-4532d171d505)![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/214f6d1f-32ed-4df2-a76f-ba528b4e0492)

## Cause-Specific Mortality Rate
### Top 10 countries with Maximum death rate over 100,000 deaths each year( Cause-Specific Mortality Rate).

            with a as(SELECT "Country Name","Year" ,(sum("Number") / sum("Total population") * 100000) as "Death Rate",
	                     RANK() OVER (PARTITION BY "Year" ORDER BY (SUM("Number") / SUM("Total population") * 100000) DESC)
		             AS "Rank" from road_accidents
                     GROUP BY "Country Name", "Year")
            SELECT  "Country Name",  "Year","Rank",
                    MAX("Death Rate") AS "Max Death Rate"
            FROM a
            where "Rank" <11
            GROUP BY "Country Name", "Year","Rank"
            order by "Year" desc,"Max Death Rate" desc;

#### Output

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/07d14b2c-76f6-4f61-9ec5-2722d3f5ef2e)


#### 10 countries with Minimum death rate over 100,000 deaths each year

           with a as(SELECT "Country Name","Year" ,(sum("Number") / sum("Total population") * 100000) as "Death Rate",
	                     RANK() OVER (PARTITION BY "Year" ORDER BY (SUM("Number") / SUM("Total population") * 100000) ASC)
		             AS "Rank" from road_accidents
                     GROUP BY "Country Name", "Year")
            SELECT  "Country Name",  "Year","Rank",
                    Min("Death Rate") AS "Min Death Rate"
            FROM a
            where "Rank" <11
            GROUP BY "Country Name", "Year","Rank"
            order by "Year" desc,"Max Death Rate" desc;
            order by "Year" desc,"Min Death Rate" Asc;

#### Output
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/b5f7c67d-89ab-45d7-8bb2-849ef2f47d12)

## Age-Specific Mortality Rate
The Age-Specific Mortality Rate (ASMR) is a measure used to calculate the mortality rate within specific age groups during a specified time period.
###### ASMR = (Number of Deaths in a Specific Age Group / Mid-year Population of that Age Group) * 1,000 (or 100,000)

### Age group that have Maximum death rate over 100,000 deaths each year (Age specific death rate)

with a as (SELECT "Country Name","Year" ,"Age Group",(sum("Number") / sum("Total population") * 100000) as "ASMR",
	                     RANK() OVER (PARTITION BY "Year" ORDER BY (SUM("Number") / SUM("Total population") * 100000) desC)
		             AS "Rank" from road_accidents
                     GROUP BY "Country Name", "Year","Age Group")
					 SELECT  "Country Name",  "Year","Age Group","Rank",
                    Max("ASMR") AS "Max ASMR"
            FROM a
            where "Rank" <4
            GROUP BY "Country Name", "Year","Rank", "Age Group"
            order by "Year" desc,"Max ASMR" desc;







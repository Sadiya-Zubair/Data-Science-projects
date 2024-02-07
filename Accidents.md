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

## Objective
To Conduct a comprehensive analysis for raising awareness about road safety, particularly in countries with alarmingly high rates of road accident fatalities. The goal is to provide data-driven insights and precautions for reducing road accident-related deaths in these countries.

## 1. Preparing Data for EDA

### Creating a View with Additional Data Fields

Before diving into our analysis, let's augment our dataset with two important columns: Total Population and Total Deaths. Although these columns are not directly available in our data, we do have the Death rate per 100,000 Population, which essentially represents the Cause-specific mortality rate (CSMR). This rate can be calculated using the following formula:

###### CSMR = (Number of Deaths from a Specific Cause / Total Population) * 100,000
By rearranging this formula, we can estimate the 'Total Population'. Additionally, we can calculate the percentage of cause-specific deaths out of the total deaths using the following formula:

###### Percentage of Cause-specific Deaths out of Total Deaths = (Number of Deaths from a Specific Cause / Total Deaths) * 100

                           CREATE VIEW accident_deaths AS SELECT
                                *,
                               ROUND(("Number" / "Death rate per 100 000 population") * 100000)
                               AS "Total population",
			      ROUND(("Number" / "Percentage of cause-specific deaths out of total deaths") * 100)
                               AS "Total Deaths"
			       FROM "Accidents".accidents
	                       where "Death rate per 100 000 population" !=0 and "Number" != 0
							and "Percentage of cause-specific deaths out of total deaths" !=0 ;

                                Select * from accident_deaths;
It's important to note that the values we will obtain are approximations rather than exact figures, as these are calculated estimates.

### Yearly Overall Data
                        SELECT
                           "Year",
                           SUM("Number") AS deaths_due_to_accidents,
                           SUM("Total Deaths") AS Total_Deaths,
                           SUM("Total population") AS Total_Population,
                           ROUND((SUM("Number") / SUM("Total Deaths") * 100), 2) AS "Percentage of cause-specific deaths out of total 
                           deaths",
                           ROUND((SUM("Number") / SUM("Total population") * 100000), 2) AS "Death rate per 100 000 population"
                        FROM accident_deaths
                        GROUP BY "Year"
                        ORDER BY "Year" DESC;

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/f0536c6e-b520-458a-9498-18104df5002e)

As expected, the number of deaths due to accidents, Percentage of cause-specific deaths out of total deaths, and the death rate per 100,000 population all went down starting in 2019.

Now, 2019 is a significant year because it's when the COVID-19 pandemic began, and many places imposed lockdowns to control it. It's reasonable to think that the decrease in road accident deaths is due to these lockdowns.

However, what's surprising is that the total number of deaths also decreased during this time. This is strange because the pandemic led to a high number of deaths.

### Number of Countries that gave data to WHO in the years 2019,2020 and 2021

                        SELECT "Year",Count(distinct "Country Name") as country_count
                         FROM accident_deaths
                         group by "Year"
                         order by "Year" Desc
                         limit 3;

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/9468026c-0918-43e0-ab11-281bd0f5d463)

We can observe a significant drop in the number of countries providing data to the WHO, which explains the decrease in Total Deaths and Total Population in our dataset during this time.
For the time being, we will exclude the years 2020 and 2021 from our analysis. We will revisit these years later and focus on the countries that consistently provided data to the WHO over the years.

### Outlier detection
                      with a as(Select "Country Name","Year", sum("Number") AS "Number",
                       sum("Total Deaths") AS "Total Deaths",
                       SUM("Total population") AS "Total Population",
                       ROUND((SUM("Number") / SUM("Total Deaths") * 100), 2) AS "per_death_outof_total_deaths",
                       ROUND((SUM("Number") / SUM("Total population") * 100000), 2) AS "Death Rate"
                    FROM accident_deaths
                    GROUP BY "Year","Country Name"),
                Quartiles AS (
                       SELECT
                        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY "Death Rate") AS Q1,
                        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY "Death Rate") AS Q3
                        FROM a
                         ),
        
                c as(SELECT
               a."Country Name",a."Year",a."Number",a."Total Deaths",
	       a."Total Population",a."per_death_outof_total_deaths",
               a."Death Rate",
            CASE
              WHEN a."Death Rate" < (q.Q1 - 1.5 * (q.Q3 - q.Q1)) OR a."Death Rate" > (q.Q3 + 1.5 * (q.Q3 - q.Q1)) THEN 1
           ELSE 0
           END AS is_outlier
           FROM a
          CROSS JOIN Quartiles q)
          select  "Country Name",Count("is_outlier") as outlier_count from c
          where "is_outlier" !=0
          group by "Country Name"
          order by outlier_count desc;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/4b0ee989-3f82-4a75-b2ee-910601ae3d74)

### Deleting Countries from our data with ouliers more than 2
                 DELETE FROM accident_deaths
                 WHERE "Country Name" in
		 ('Grenada','Saint Vincent and the Grenadines','Saint Lucia','Domnican Republic','Belize');

## 2. Income Category of a Country and Death Rates

I collected data related to Countries Income category from the World Bank.I used plsql to import both the data which were in Excel file to Database.

###  Count of Countries in Different Income Categories.
                       
			with a as(SELECT Distinct c."Country Name",c."Income Category" as income_category
                                 FROM Country_Income_Group AS c
                                 JOIN road_accidents AS r ON c."Country Name" = r."Country Name")
                         select income_category,count(income_category) as "count" from a
                         group by income_category
                         order by "count" desc;               

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/158b4f67-2170-4cf3-a15c-b01b36ad1a11)


Well, as we can see in our data set we only have very few lower-income countries.

### Average Death with respect to Income Category

		SELECT
                c."Income Category" as income_category, round(avg("Number"),2) as Number,
				round(avg("Total Deaths"),2) as "Total Deaths",
				round(avg("Total population"),2) as Total_Population,
                round(sum("Number")/sum("Total Deaths")*100, 2) || '%' as "death_per_outof_total",
				round(sum(r."Number")/sum(r."Total population")*100000, 2) as "Death Rate per 100,000 Population"
                FROM Country_Income_Group AS c
                JOIN accident_deaths AS r ON c."Country Name" = r."Country Name"
				where "Year" not in ('2020','2021')
                 GROUP BY c."Income Category"
                 order by "Death Rate per 100,000 Population" desc ;

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/d6d0c61f-000f-4a89-9e3b-5e553d51f289)

### Top Five Countries with the highest Average Death Rate
                              with z as ( Select "Country Name","Year", sum("Number") AS "Number",
                       sum("Total Deaths") AS "Total Deaths",
                       SUM("Total population") AS "Total Population",
                       ROUND((SUM("Number") / SUM("Total Deaths") * 100), 2) AS "per_death_outof_total_deaths",
                       ROUND((SUM("Number") / SUM("Total population") * 100000), 2) AS "Death Rate"
                    FROM accident_deaths
                    GROUP BY "Year","Country Name"),
			a as(SELECT
                "Country Name", round(avg("Number"),2) as Number,
				round(avg("Total Deaths"),2) as "Total Deaths",
				round(avg("Total Population"),2) as Total_Population,
				round(sum("Number")/sum("Total Population")*100000, 2) as "Death Rate per 100,000 Population"
				   from z
				  where "Year" not in ('2020','2021')
				  group by "Country Name")
				   select a."Country Name",c."Income Category",
				   a.Number,a."Total Deaths", a.Total_Population,a.death_per_outof_total,
				   a."Death Rate per 100,000 Population"
                FROM Country_Income_Group AS c
                JOIN a ON c."Country Name" = a."Country Name"
                 order by "Death Rate per 100,000 Population" desc
				 limit 5;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/95e1cd2b-24e4-47aa-8a5a-a4e1e2cd633c)

### Top Five Countries with the Least Average Death Rate
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/d86415e5-d3a5-4ccf-bad8-bd5312f216a5)

### Top Five Countries with the highest Average Death Percentage Out of Total Deaths

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/cb3f4e63-be42-4fb8-a31d-3d0754b16dd3)
### Top Five Countries with the Least Average Death Percentage Out of Total Deaths

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/32c80e34-c9ae-478c-b0af-7fce53f4b577)


## 3. Age and Gender Influence on Death Rates

###  Overall Death Rate with respect to Age
             SELECT "Age Group", round((sum("Number") / sum("Total population") * 100000),2) as "Death Rate"
                     from road_accidents
		     group by "Age Group"
                   Order by "Death Rate" Desc;

### Average Death Rate with respect to Age Category
                             with a as ( SELECT
                             *,
                         CASE
                           WHEN "Age Group" in ('15-19') THEN 'Teenager'
                           WHEN "Age Group" in ('20-24','25-29') THEN 'Young Adult'
                           WHEN "Age Group" in ('30-34','35-39') THEN 'Adult'
                           WHEN "Age Group" in ('40-44','45-49','50-54','55-59') THEN 'Middle Age'
                     ELSE 'Senior'
              END AS age_category
              FROM accident_deaths)
              SELECT "age_category",round(Avg("Number"),2) as avg_Number,Round(Avg("Total Deaths"),2)as Avg_Total_Deaths,
			  round(Avg("Total population"),2) as Avg_Total_Population, 
			  round((Sum("Number")/sum("Total Deaths")*100),2) || '%' as death_percent,
	                  round((sum("Number") / sum("Total population")* 100000),2) as "Death Rate"
                     from a
			 where "Year" not in ('2020','2021')
		     group by "age_category"
		     Order by "Death Rate" Desc;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/6bc32ab7-f941-42a0-b039-ed7beff1eeec)
### Average Death Rate with respect to Income Category and Age Category
                          with a as ( SELECT
                             *,
                         CASE
                           WHEN "Age Group" in ('15-19') THEN 'Teenager'
                           WHEN "Age Group" in ('20-24','25-29') THEN 'Young Adult'
                           WHEN "Age Group" in ('30-34','35-39') THEN 'Adult'
                           WHEN "Age Group" in ('40-44','45-49','50-54','55-59') THEN 'Middle Age'
                     ELSE 'Senior'
              END AS age_category
              FROM accident_deaths)
			  SELECT
              c."Income Category" as income_category, a."age_category", round(avg("Number"),2) as Number,
				round(avg("Total Deaths"),2) as "Total Deaths",
				round(avg("Total population"),2) as Total_Population,
                round(sum("Number")/sum("Total Deaths")*100, 2) || '%' as "death_per_outof_total",
				round(sum(a."Number")/sum(a."Total population")*100000, 2) as "Death Rate per 100,000 Population"
                FROM Country_Income_Group AS c
                JOIN a ON c."Country Name" = a."Country Name"
				where "Year" not in ('2020','2021')
                 GROUP BY c."Income Category",a."age_category"
				 order by c."Income Category", "Death Rate per 100,000 Population"desc;
     ![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/3f9742e5-23aa-4ada-93e8-9cf4a5b9ecc7)

 ### Death Rate with respect to Gender     
                        select "Sex",  round(sum("Number")/sum("Total Deaths")*100, 2) || '%' as "death_per_outof_total",
				round(sum("Number")/sum("Total population")*100000, 2) as "Death Rate per 100,000 Population"
				from accident_deaths
				group by "Sex";

    ![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/4501491d-4f18-4605-b4f5-d87d652aaac8)


### Average Death Rate with respect to gender and age category
                     with a as ( SELECT
                             *,
                         CASE
                           WHEN "Age Group" in ('15-19') THEN 'Teenager'
                           WHEN "Age Group" in ('20-24','25-29') THEN 'Young Adult'
                           WHEN "Age Group" in ('30-34','35-39') THEN 'Adult'
                           WHEN "Age Group" in ('40-44','45-49','50-54','55-59') THEN 'Middle Age'
                     ELSE 'Senior'
              END AS age_category
              FROM accident_deaths)
              SELECT "age_category","Sex",round(Avg("Number"),2) as avg_Number,Round(Avg("Total Deaths"),2)as Avg_Total_Deaths,
			  round(Avg("Total population"),2) as Avg_Total_Population, 
			  round((Sum("Number")/sum("Total Deaths")*100),2) || '%' as death_percent,
	                  round((sum("Number") / sum("Total population")* 100000),2) as "Death Rate"
                     from a
			 where "Year" not in ('2020','2021')
		     group by "age_category","Sex"
		     Order by "Death Rate" Desc;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/d5a322f4-d243-4a5f-a66b-81dd6b02320b)

### Average Death Rate with respect to gender and Income Category
              SELECT
              c."Income Category" as income_category,"Sex" , round(avg("Number"),2) as Number,
				round(avg("Total Deaths"),2) as "Total Deaths",
				round(avg("Total population"),2) as Total_Population,
                round(sum("Number")/sum("Total Deaths")*100, 2) || '%' as "death_per_outof_total",
				round(sum(a."Number")/sum(a."Total population")*100000, 2) as "Death Rate per 100,000 Population"
                FROM Country_Income_Group AS c
                JOIN accident_deaths as a ON c."Country Name" = a."Country Name"
				where "Year" not in ('2020','2021')
                 GROUP BY c."Income Category",a."Sex"
				 order by c."Income Category", "Death Rate per 100,000 Population"desc;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/194d6d94-b19e-451f-8040-130af8256953)

## 4. Impact of COVID-19 on Death Rates
The reason for excluding data from the years 2020 and 2021 for the above was due to insufficient data availability. Only approximately 23 countries provided complete data to the World Health Organization (WHO) during those years, and this was primarily due to the impact of "Covid-19."
### Year wise death rate of that 23 countries
                SELECT "Year",
                       SUM("Number") AS accident_deaths,
                       SUM("Total Deaths") AS Total_Deaths,
                       ROUND((SUM("Number") / SUM("Total Deaths")) * 100, 2) AS percentage,
		       round((sum("Number") / sum("Total population")* 100000),2) as "Death Rate"
              FROM accident_deaths
              WHERE "Country Name" IN ('Oman', 'Luxembourg', 'Saint Vincent and the Grenadines',
                         'Grenada', 'Latvia', 'Estonia', 'Kazakhstan', 'Iceland', 'Mongolia',
                         'Seychelles', 'Ecuador', 'Armenia', 'Qatar', 'Austria', 'Australia',
                         'Serbia', 'Mauritius', 'Lithuania', 'Spain', 'North Macedonia', 'Georgia',
                         'Lebanon', 'Czechia')
              GROUP BY "Year"
              ORDER BY "Year" DESC;

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/1ac0ef61-7cd2-4b1e-b61a-d9813f0a9216)

### Income Distribution of these countries
                     		
with a as (SELECT distinct (r."Country Name"),c."Income Category" as income_category
                                 FROM Country_Income_Group AS c
                                 JOIN road_accidents AS r ON c."Country Name" = r."Country Name"
						 		
			  where  r."Country Name" IN ('Oman', 'Luxembourg', 'Saint Vincent and the Grenadines',
                         'Grenada', 'Latvia', 'Estonia', 'Kazakhstan', 'Iceland', 'Mongolia',
                         'Seychelles', 'Ecuador', 'Armenia', 'Qatar', 'Austria', 'Australia',
                         'Serbia', 'Mauritius', 'Lithuania', 'Spain', 'North Macedonia', 'Georgia',
                         'Lebanon', 'Czechia')
                         group by income_category,r."Country Name")
		select income_category, count("income_category") as "count" from a
		group by income_category
		order by count desc;
                         
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/c08ab1b2-d5b5-4893-89b0-3512888cfd27)

### Year wise Death Rate with respect to Age Category
                         WITH a AS (
                         SELECT
                               *,
                               CASE
                                  WHEN "Age Group" IN ('15-19') THEN 'Teenager'
                                  WHEN "Age Group" IN ('20-24', '25-29') THEN 'Young Adult'
                                  WHEN "Age Group" IN ('30-34', '35-39') THEN 'Adult'
                                  WHEN "Age Group" IN ('40-44', '45-49', '50-54', '55-59') THEN 'Middle Age'
                          ELSE 'Senior'
                          END AS age_category
                          FROM accident_deaths
                          ),
                      b AS (
                    SELECT
                        "Year",
                        "age_category",
                        SUM("Number") AS "Number",
                        SUM("Total Deaths") AS Total_Deaths,
                        SUM("Total population") AS Total_Population,
                        ROUND((SUM("Number") / SUM("Total Deaths") * 100), 2) || '%' AS death_percent,
                        ROUND((SUM("Number") / SUM("Total population") * 100000), 2) AS "Death Rate"
                    FROM a
                    WHERE "Country Name" IN ('Oman', 'Luxembourg', 'Saint Vincent and the Grenadines',
                   'Grenada', 'Latvia', 'Estonia', 'Kazakhstan', 'Iceland', 'Mongolia',
                   'Seychelles', 'Ecuador', 'Armenia', 'Qatar', 'Austria', 'Australia',
                   'Serbia', 'Mauritius', 'Lithuania', 'Spain', 'North Macedonia', 'Georgia',
                   'Lebanon', 'Czechia')
                  GROUP BY "age_category", "Year"
                       )
                  SELECT
                     "Year",
                     ROUND(SUM(CASE WHEN "age_category" = 'Teenager' THEN "Death Rate" ELSE 0 END), 2) AS "Teenager Death Rate",
                     ROUND(SUM(CASE WHEN "age_category" = 'Young Adult' THEN "Death Rate" ELSE 0 END), 2) AS "Young Adult Death Rate",
                     ROUND(SUM(CASE WHEN "age_category" = 'Adult' THEN "Death Rate" ELSE 0 END), 2) AS "Adult Death Rate",
                     ROUND(SUM(CASE WHEN "age_category" = 'Middle Age' THEN "Death Rate" ELSE 0 END), 2) AS "Middle Age Death Rate",
                     ROUND(SUM(CASE WHEN "age_category" = 'Senior' THEN "Death Rate" ELSE 0 END), 2) AS "Senior Death Rate"
                  FROM b
                  GROUP BY "Year"
                  ORDER BY "Year" desc;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/beb67361-d49e-42d4-8241-535d3c0a4570)

### Year wise Death_Percentage Rate with respect to Age Category
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/9acb563c-391b-4004-a3a1-c22eec50102a)


## Conclusion
Based on our analysis, it's evident that death rates are significantly influenced by a country's income category. In most cases, countries with higher income levels tend to exhibit lower death rates due to Road Accidents. While there are exceptions, Like Qatar, I recently came across an article that mentioned more deaths in Qatar caused by road accidents than common diseases. Initially, I found it hard to believe, but upon conducting my analysis, I'm inclined to think there might be truth in that statement. The average percentage of deaths due to road accidents out of the total deaths is the highest, while China has the least. This data strongly suggests that countries like Qatar have a significant potential to reduce their death rates, as it lies within their control.

Furthermore, our findings highlight that gender plays a crucial role in road accidents, with males being more prone to such incidents. Young adults and adults are particularly vulnerable to road accidents. We also observed a notable drop in deaths due to accidents during the COVID-19 pandemic, as expected.

In conclusion, our findings underscore the complex interplay of income, gender, and age in shaping death rates, particularly in the context of road accidents. These insights can guide public health policies and interventions aimed at reducing mortality and enhancing the well-being of populations in different income categories. To address the challenge of road accidents, it's crucial for countries to implement effective road safety measures, enforcement, and awareness campaigns. The potential for reducing deaths from road accidents is well within their grasp, and concerted efforts can make a significant difference in saving lives and ensuring safer road environments."

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/5d44989b-9a78-47e6-a228-1a0ad8162424)










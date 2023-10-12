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
To Conduct a comprehensive analysis for raising awareness about road safety, particularly in countries with alarmingly high rates of road accident fatalities. The goal is to provide data-driven insights and precautions for reducing road accident-related deaths in these countries.

## Hypothesis
* ### Hypothesis 1: Income and Death Rates
    * Null Hypothesis (H0): There is no significant difference in death rates between low-income, middle-income, and high-income countries.
    * Alternative Hypothesis (H1): Low and middle-income countries exhibit higher death rates compared to high-income countries.

* ### Hypothesis 2: Age and Gender Influence on Death Rates
    * Null Hypothesis (H0): Age and gender do not significantly impact death rates.
    * Alternative Hypothesis (H1):Age and gend significantly impact death rates.

* ### Hypothesis 3: Cause-Specific Death Percentages by Age and Gender
    * Null Hypothesis (H0): There are no significant differences in cause-specific death percentages between age and gender groups.
    * Alternative Hypothesis (H1): Young adults and males exhibit the highest percentages of cause-specific deaths in certain categories.

* ### Hypothesis 4: The Impact of COVID-19 on Death Rates
    * Null Hypothesis (H0): There is no significant change in death rates after the year 2019.
    * Alternative Hypothesis (H1): A decrease in death rates observed after 2019 is attributed to the emergence of the COVID-19 pandemic.

##  Age and Gender Influence on Death Rates

### Creating a View for Total Population
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

###  Overall Death Rate with respect to Age
             SELECT "Age Group", round((sum("Number") / sum("Total population") * 100000),2) as "Death Rate"
                     from road_accidents
		     group by "Age Group"
                     Order by "Death Rate" Desc;

 <span style="font-weight: lighter;">Categorizing the Age Group into Teenager, Young Adult, Adult, Middle Age and Senior</span>

     with a as ( SELECT
                             *,
                         CASE
                           WHEN "Age Group" in ('15-19') THEN 'Teenager'
                           WHEN "Age Group" in ('20-24','25-29') THEN 'Young Adult'
                           WHEN "Age Group" in ('30-34','35-39') THEN 'Adult'
                           WHEN "Age Group" in ('40-44','45-49','50-54','55-59') THEN 'Middle Age'
                     ELSE 'Senior'
              END AS age_category
              FROM road_accidents)
              SELECT "age_category", round((sum("Number") / sum("Total population") * 100000),2) as "Death Rate"
                     from a
		     group by "age_category"
		     Order by "Death Rate" Desc;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/3beadabf-d5eb-44e1-9100-b3d9deed3bf7)

### Count of age_categories of each Country with Maximum Death Rate 
          with a as ( SELECT
                             *,
                         CASE
                           WHEN "Age Group" in ('15-19') THEN 'Teenager'
                           WHEN "Age Group" in ('20-24','25-29') THEN 'Young Adult'
                           WHEN "Age Group" in ('30-34','35-39') THEN 'Adult'
                           WHEN "Age Group" in ('40-44','45-49','50-54','55-59') THEN 'Middle Age'
                     ELSE 'Senior'
              END AS age_category
              FROM road_accidents),
			b as(  SELECT "Country Name","age_category", round((sum("Number") / sum("Total population") * 100000),2) as "Death 
                              Rate",
				RANK() OVER (PARTITION BY "Country Name" ORDER BY (SUM("Number") / SUM("Total population") * 100000) DESC)
	             AS "Rank" from a                                                                                ----ASC for minimum
		     group by "age_category","Country Name"),
			 c as (select "Country Name","age_category","Death Rate","Rank"
			     from b
				  where "Rank"<2
			     order by "Death Rate" desc)
			 SELECT
                "age_category",
                  COUNT("age_category") AS "Age Category Count"
              FROM c
              GROUP BY "age_category"
              ORDER BY "Age Category Count" DESC;

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/a29b1061-90e1-4344-adcd-30c673007e93)

### Count of age_categories of each Country with Minimum Death Rate 

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/4690b73b-a120-49bb-90c7-d1838b794e62)

### Count of age_categories of each Country with Maximum Death Rate with respect to gender
           with a as ( SELECT
                             *,
                         CASE
                           WHEN "Age Group" in ('15-19') THEN 'Teenager'
                           WHEN "Age Group" in ('20-24','25-29') THEN 'Young Adult'
                           WHEN "Age Group" in ('30-34','35-39') THEN 'Adult'
                           WHEN "Age Group" in ('40-44','45-49','50-54','55-59') THEN 'Middle Age'
                     ELSE 'Senior'
              END AS age_category
              FROM road_accidents),
			b as(  SELECT "Country Name","age_category","Sex", round((sum("Number") / sum("Total population") * 100000),2) as 
                              "Death Rate",
				RANK() OVER (PARTITION BY "Country Name" ORDER BY (SUM("Number") / SUM("Total population") * 100000) DESC)
	             AS "Rank" from                                                                                  -- ASC for min
		     group by "age_category","Country Name","Sex"),
			 c as (select "Country Name","age_category","Sex","Death Rate","Rank"
			     from b
				  where "Rank"<2
			     order by "Death Rate" desc)
			 SELECT
                "age_category","Sex",
                  COUNT("age_category") AS "Age Category Count"
              FROM c
              GROUP BY "age_category","Sex"
              ORDER BY "Age Category Count" DESC;

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/dc5b0119-d7c7-44fb-8e0e-f18bf5f99a56)

### Count of age_categories of each Country with Minimum Death Rate with respect to gender

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/89ae03d2-f31b-4a70-8f39-9c4f686ff8a8)


### Number of occurrences of the gender with the highest death rate in each country.
           			
	              with b as(  SELECT "Country Name","Sex", round((sum("Number") / sum("Total population") * 100000),2) as "Death Rate",
				RANK() OVER (PARTITION BY "Country Name" ORDER BY (SUM("Number") / SUM("Total population") * 100000) DESC)
                                                                                                                           --ASC for min
	             AS "Rank" from road_accidents
		     group by "Country Name","Sex"),
		         c as (select "Country Name","Sex","Death Rate"
			     from b
				  where "Rank"<2)
				  
				select "Sex", Count("Sex") as "Count"
				from c 
				group by "Sex"
				order by "Count" desc;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/0b68b891-e2d6-4150-9686-15bd02188d74)

### Number of occurrences of the gender with the highest death rate in each country.


![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/e1e7764a-f44f-443f-b7b9-12032d8b0ba5)


### Creating a View for Total Deaths
As our data doesn't have a 'Total Deaths' column but does have the 'Percentage of cause-specific deaths out of total deaths' 
###### Percentage of cause-specific deaths out of total deaths = (Number of Deaths from a Specific Cause / Total Deaths) * 100
we can estimate the 'Total Deaths' using this formula. We will create a view with a 'Total Deaths' column as it is used further in our analysis.
              
           CREATE VIEW road_accidents1 AS SELECT
                                *,
                               ROUND(("Number" / "Percentage of cause-specific deaths out of total deaths") * 100)
                               AS "Total Deaths"
			       FROM "Accidents".accidents
	                        where "Percentage of cause-specific deaths out of total deaths" !=0 and "Number" != 0;
              
### Overall percentage odf deaths due to accidents out of total deaths
            
	      SELECT round((sum("Number") / sum("Total Deaths") * 100),2) as "Death Rate"
                     from road_accidents1;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/f590345c-41d8-4c59-9068-0918e99680f6)

###  Percentage of Deaths Due to Accidents Out of Total Deaths for Different Age Groups

	             SELECT "Age Group",
               round((sum("Number") / sum("Total Deaths") * 100),2)
			   as "Percentage of death due to accident out of total deaths"
               from road_accidents1
			   group by "Age Group"
			   order by "Percentage of death due to accident out of total deaths" desc;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/abf63003-94e0-4f89-9288-92462ab31dc7)

### Count of Occurrences for Age Categories with the Highest Percentage of Death due to Accident out of total deaths in Each Country

	with a as ( SELECT
                         *,
                     CASE
                       WHEN "Age Group" in ('15-19') THEN 'Teenager'
                       WHEN "Age Group" in ('20-24','25-29') THEN 'Young Adult'
                       WHEN "Age Group" in ('30-34','35-39') THEN 'Adult'
                       WHEN "Age Group" in ('40-44','45-49','50-54','55-59') THEN 'Middle Age'
                 ELSE 'Senior'
          END AS age_category
          FROM road_accidents1),
		b as(  SELECT "Country Name","age_category", round((sum("Number") / sum("Total Deaths") * 100),2) as 
                          "percentage of death",
			RANK() OVER (PARTITION BY "Country Name" ORDER BY (SUM("Number") / SUM("Total Deaths") * 100) DESC)
             AS "Rank" from  a                                                                        -- ASC for min
	     group by "age_category","Country Name"),
		 c as (select "Country Name","age_category","percentage of death","Rank"
		     from b
			  where "Rank"<2
		     order by "percentage of death" desc)
		 SELECT
            "age_category",
              COUNT("age_category") AS "Count"
          FROM c
          GROUP BY "age_category"
          ORDER BY "Count" DESC;

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/c53b22fa-3eca-4c9b-b7a5-40436daa8d56)
### Count of Occurrences for Age Categories with the Lowest Percentage of Death due to Accident out of total deaths in Each Country

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/1fbe1381-92b7-43fc-834e-44450f4080ce)

### Count of Occurrences for Age Categories and Sex with the Highest Percentage of Deaths in Each Country
           
	   with a as ( SELECT
                             *,
                         CASE
                           WHEN "Age Group" in ('15-19') THEN 'Teenager'
                           WHEN "Age Group" in ('20-24','25-29') THEN 'Young Adult'
                           WHEN "Age Group" in ('30-34','35-39') THEN 'Adult'
                           WHEN "Age Group" in ('40-44','45-49','50-54','55-59') THEN 'Middle Age'
                     ELSE 'Senior'
              END AS age_category
              FROM road_accidents1),
			b as(  SELECT "Country Name","age_category","Sex", round((sum("Number") / sum("Total Deaths") * 100),2) as 
                              "percentage of deaths",
				RANK() OVER (PARTITION BY "Country Name" ORDER BY (SUM("Number") / SUM("Total Deaths") * 100) DESC)
	             AS "Rank" from  a                                                                                -- ASC for min
		     group by "age_category","Country Name","Sex"),
			 c as (select "Country Name","age_category","Sex","percentage of deaths","Rank"
			     from b
				  where "Rank"<2
			     order by "percentage of deaths" desc)
			 SELECT
                "age_category","Sex",
                  COUNT("age_category") AS "Age Category Count"
              FROM c
              GROUP BY "age_category","Sex"
              ORDER BY "Age Category Count" DESC;

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/a12fcb93-c120-4bd9-b9bb-ead7bc0663dd)
### Count of Occurrences for Age Categories and Sex with the Lowest Percentage of Deaths in Each Country
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/68ef8a0a-4c86-4ab3-932a-2c8b7f78d98f)

### Count of Number of occurrences for each gender with the highest percentage of deaths in each country

            WITH b AS (
                 SELECT "Country Name", "Sex", ROUND((SUM("Number") / SUM("Total Deaths") * 100), 2) AS "percentage of deaths",
                         RANK() OVER (PARTITION BY "Country Name" ORDER BY (SUM("Number") / SUM("Total Deaths") * 100) DESC) AS "Rank"
                         FROM road_accidents1
                         GROUP BY "Country Name", "Sex"
                        ),
                 c AS (
                 SELECT "Country Name", "Sex", "percentage of deaths", "Rank"
                        FROM b
                        WHERE "Rank" < 2
                        )
                SELECT
                     "Sex",
                      COUNT("Sex") AS "Count"
                      FROM c
                      GROUP BY "Sex"
                      ORDER BY "Count" DESC;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/5309111a-1319-4022-8ef2-87accae451d2)

###  Teenagers Year wise deaths due to accident
                     with a as ( SELECT
                                    *,
                                 CASE
                                    WHEN "Age Group" in ('15-19') THEN 'Teenager'
                                    WHEN "Age Group" in ('20-24','25-29') THEN 'Young Adult'
                                    WHEN "Age Group" in ('30-34','35-39') THEN 'Adult'
                                    WHEN "Age Group" in ('40-44','45-49','50-54','55-59') THEN 'Middle Age'
                                 ELSE 'Senior'
                                END AS age_category
                                FROM road_accidents1)
                     SELECT "Year",
		            SUM("Number")as accident_deaths,
                            SUM("Total Deaths") as Total_Deaths,
			    ROUND((SUM("Number") / SUM("Total Deaths")) * 100, 2) AS percentage
                     FROM a
                     WHERE "Year" != '2020' AND "Year" != '2021' and "age_category" = 'Teenager'
                     GROUP BY "Year"
                     ORDER BY "Year" DESC;
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/98b01e0f-1d3c-48f8-84d4-18c9b22576fd)

### Young Adults Year wise deaths due to accident
![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/1c4f3544-b159-45e7-a292-b1617954c46d)

## The Impact of COVID-19 on Death Rates
The reason for excluding data from the years 2020 and 2021 for the above was due to insufficient data availability. Only approximately 56 and 23 countries, respectively, provided complete data for the World Health Organization (WHO) during those years as we know the reason why "Covid-19".
### Year wise death rate of that 23 countries
                SELECT "Year",
                       SUM("Number") AS accident_deaths,
                       SUM("Total Deaths") AS Total_Deaths,
                       ROUND((SUM("Number") / SUM("Total Deaths")) * 100, 2) AS percentage
              FROM road_accidents1
              WHERE "Country Name" IN ('Oman', 'Luxembourg', 'Saint Vincent and the Grenadines',
                         'Grenada', 'Latvia', 'Estonia', 'Kazakhstan', 'Iceland', 'Mongolia',
                         'Seychelles', 'Ecuador', 'Armenia', 'Qatar', 'Austria', 'Australia',
                         'Serbia', 'Mauritius', 'Lithuania', 'Spain', 'North Macedonia', 'Georgia',
                         'Lebanon', 'Czechia')
              GROUP BY "Year"
              ORDER BY "Year" DESC;

![image](https://github.com/Sadiya-Zubair/Data-Science-projects/assets/36756199/a7caf1bb-f3b4-4a45-94ae-d06de47be071)

           
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

### Creating a View for Total Deaths

           CREATE VIEW road_accidents1 AS SELECT
                                *,
                               ROUND(("Number" / "Percentage of cause-specific deaths out of total deaths") * 100)
                               AS "Total Deaths"
			       FROM "Accidents".accidents
	                        where "Percentage of cause-specific deaths out of total deaths" !=0 and "Number" != 0;
		
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


           CREATE VIEW road_accidents1 AS SELECT
                                *,
                               ROUND(("Number" / "Percentage of cause-specific deaths out of total deaths") * 100)
                               AS "Total Deaths"
			       FROM "Accidents".accidents
	                        where "Percentage of cause-specific deaths out of total deaths" !=0 and "Number" != 0;
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







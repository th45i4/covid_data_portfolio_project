-- Run test to return all of the covid_death data filtering out entire continents listed in the location column

select *
from covid_deaths
where iso_code NOT LIKE '%OWID%';

-- Run test to pull all information from covid_vaccines

select *
from covid_vaccines;

-- Select Data that we frequently used

Select 
Location
,Date
,total_cases
,new_cases
,total_deaths
,population
from covid_deaths
where iso_code NOT LIKE '%OWID%'
order by 1,2

-- Looking at the total cases vs total deaths 
-- Shows the likelihood of dying if you contract COVID by country

Select 
Location
,Date
,total_cases
,total_deaths
,((total_deaths/total_cases)*100) as percentage_deaths_per_total_cases
from covid_deaths
where iso_code NOT LIKE '%OWID%'
order by 1,2;

-- Looking at what percentage of country's total population contracted COVID

select 
Location
,Date
,total_cases
,population
,((total_cases/population)*100) as percentage_population_contracted
from covid_deaths
where iso_code NOT LIKE '%OWID%'
order by 1,2;

-- Looking at countries with highest infection rate vs population
select 
Location
,population
,MAX(total_cases) as highest_infection_count
,MAX((total_cases/population))*100 as highest_percentage_population_contracted
from covid_deaths
where iso_code NOT LIKE '%OWID%'
group by location, population
order by highest_percentage_population_contracted desc;

-- Showing the countries with the highest death count per population
select 
Location
,MAX(total_deaths) as total_death_count
from covid_deaths
where iso_code NOT LIKE '%OWID%'
group by location
order by total_death_count desc;

-- Continents with the highest death counts
select 
location
,MAX(total_deaths) as total_death_count
from covid_deaths
where iso_code LIKE '%OWID%' AND location NOT IN('Upper middle income','High income','Lower middle income','Northern Cyprus','Kosovo','Low Income','International')
group by location
order by total_death_count desc;

-- Global numbers

Select 
SUM(new_cases) as total_cases
,SUM(new_deaths) as total_deaths
,SUM(new_deaths)/SUM(new_cases)*100 as global_death_percentage
from covid_deaths
where iso_code NOT LIKE '%OWID%'
order by 1,2;

-- Joining covid_deaths and covid_vaccines tables

select *
from covid_deaths d JOIN covid_vaccines v 
on d.location = v.location
AND d.date = v.date;

-- Finding the percentage of a country's population that is fully vaccinated using a rolling daily vaccination count and temp table

DROP TABLE IF EXISTS percentage_population_vaccinated;

CREATE TABLE percentage_population_vaccinated 

select
d.continent
,d.location
,d.date
,d.population
,v.people_fully_vaccinated
,SUM(v.people_fully_vaccinated) OVER (PARTITION by d.location ORDER BY d.location, d.date) as total_vaccinated_to_date
from covid_deaths d JOIN covid_vaccines v 
on d.location = v.location
AND d.date = v.date
where d.iso_code NOT LIKE '%OWID%'
order by 2,3;


select *
,(total_vaccinated_to_date/population)*100 as percentage_population_fully_vaccinated
from percentage_population_vaccinated;

-- Creating a view for visualizations

Create View percentage_population_fully_vaccinated_view as 
select
d.continent
,d.location
,d.date
,d.population
,v.people_fully_vaccinated
,SUM(v.people_fully_vaccinated) OVER (PARTITION by d.location ORDER BY d.location, d.date) as total_vaccinated_to_date
from covid_deaths d JOIN covid_vaccines v 
on d.location = v.location
AND d.date = v.date
where d.iso_code NOT LIKE '%OWID%';

select *
from percentage_population_fully_vaccinated_view;




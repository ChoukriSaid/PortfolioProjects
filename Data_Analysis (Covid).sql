Select *
FROM CovidDeaths

--Im gonna select the data i will work with 
Select Location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
order by 1,2






 --looking at total cases vs total deaths 
------First command don t work cause total_deaths and total_cases are nvarchar 
------Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
------FROM CovidDeaths
------order by 1,2

SELECT Location, date, total_cases, total_deaths,
       (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%morocco%' --death percentage in morocco
ORDER BY 1, 2

--Looking at total cases vs population (it shows what percentage of the population has gotten covid
SELECT Location, date,population, total_cases,
       (CAST(total_cases AS FLOAT) / population) * 100 AS InfectionPercentage
FROM CovidDeaths
--WHERE location like '%morocco%'
ORDER BY 1, 2

--EXEC sp_columns @table_name = 'CovidDeaths', @column_name = 'total_cases'; (result was nvarchar)
----i was searching for the max but the return value didn t match the max that i observe visually in the table, 
----so i realized the type of my column is nvarchar and because of that the max was returning the value of the highest
----in the alphabetic order, so the nxt query is to change the type to the float
--ALTER TABLE CovidDeaths
--ALTER COLUMN total_cases FLOAT;
--------------------------------------------------------

--Looking at the countries with highest infection rate compared to the population
Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by location,population
Order By PercentPopulationInfected DESC

--Shows the countries with the highest death count per population
Select Location, Population, Max(total_deaths) as HighestDeathCount
From CovidDeaths
Where continent is not null
Group by location,population
Order By HighestDeathCount DESC
----continent
Select continent, Max(total_deaths) as HighestDeathCount
From CovidDeaths
Where continent is not null
Group by continent
Order By HighestDeathCount DESC

--GLOBAL NUMBERS
----Gives the total cases and the total deaths for the world until today 16/02/2024
Select  sum(new_cases)as TotalNewCases,sum(new_deaths)as TotalNewDeaths,sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
FROM CovidDeaths
Where continent is not null
--Group by date 
order by 1,2
--gives the total new cases and the total new deaths for the world everyday since 2020
Select  date,sum(new_cases)as TotalNewCases,sum(new_deaths)as TotalNewDeaths,sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
FROM CovidDeaths
Where continent is not null
Group by date 
order by 1,2

--Looking at total population vs vaccinations
 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null 
--AND dea.location='morocco'
order by 2,3

--the nxt script is gone the same as the one before but we gonna add a percentage : RollingPeopleVaccinated/people
--to see what are the percentage of people getting vaccinated and its only gonna be increasing cause its a compound
--However the problem is in the query i can't add 'RollingPeopleVaccinated' in my SELECT query, so i have to 
--create a CTE or a temporary table to be able to. Follow with me :)

With PopulVsVAc(Continent, Location,date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null 

--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopulVsVAc
--WHERE location='morocco'
Order by 2,3

--Creating View to store data for later visualizations
Create view PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null 

Select *
from PercentPopulationVaccinated










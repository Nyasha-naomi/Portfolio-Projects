SELECT *
FROM [PortFolia Project new]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM [PortFolia Project new]..CovidVaccinations$
--ORDER BY 3,4

--Select data we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [PortFolia Project new]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you get Covid in South Africa

SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [PortFolia Project new]..CovidDeaths$
WHERE continent IS NOT NULL
,WHERE location LIKE '%South Africa%'
ORDER BY 1,2

--Looking at Total cases vs Population 
--Shows what percentage of population got covid

SELECT location,date,total_cases,new_cases,population,(total_cases/population)*100 as PercentPopulationInfected
FROM [PortFolia Project new]..CovidDeaths$
WHERE continent IS NOT NULL
,WHERE location LIKE '%South Africa%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location,population,MAX (total_cases) as HighInfectionCount,MAX ((total_cases/population))*100 as PercentPopulationInfected
FROM [PortFolia Project new]..CovidDeaths$
--WHERE location LIKE '%South Africa%'
WHERE continent IS NOT NULL
GROUP BY location,gdp_per_capita
ORDER BY PercentPopulationInfected DESC

--Showing Countries with the Highest Death Count Per Population

SELECT location,MAX (cast (total_deaths AS int)) as TotalDeathCount
FROM [PortFolia Project new]..CovidDeaths$
WHERE continent IS NOT NULL
--WHERE location LIKE '%South Africa%'
GROUP BY location
ORDER BY TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT
--Showing the continent with the highest
SELECT continent,MAX (cast (total_deaths AS int)) as TotalDeathCount
FROM [PortFolia Project new]..CovidDeaths$
WHERE continent IS NOT NULL
--WHERE location LIKE '%South Africa%'
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT date,SUM (new_cases), SUM(cast(new_deaths as int)),SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as DeathPercentage
FROM [PortFolia Project new]..CovidDeaths$
WHERE continent IS NOT NULL
--WHERE location LIKE '%South Africa%'
GROUP BY date
ORDER BY 1,2

SELECT SUM (new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [PortFolia Project new]..CovidDeaths$
WHERE continent IS NOT NULL
--WHERE location LIKE '%South Africa%'
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs Vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/gdp_per_capita)*100
From [PortFolia Project new]..CovidVaccinations$ vac
JOIN [PortFolia Project new]..CovidDeaths$ dea
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac(Continent, Location,date,population, RollingPeopleVaccinated,new_vaccinations)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/gdp_per_capita)*100
From [PortFolia Project new]..CovidVaccinations$ vac
JOIN [PortFolia Project new]..CovidDeaths$ dea
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar (225),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From [PortFolia Project new]..CovidVaccinations$ vac
JOIN [PortFolia Project new]..CovidDeaths$ dea
ON dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating Views to store data for later visualisation


Create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From [PortFolia Project new]..CovidVaccinations$ vac
JOIN [PortFolia Project new]..CovidDeaths$ dea
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
SELECT *
FROM ProjectPortafolio..CovidDeaths$
WHERE continent is not null
ORDER BY  3,4

--SELECT *
--FROM ProjectPortafolio..CovidVaccinations$
--ORDER BY  3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortafolio..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2



--looking at total cases vs total deaths
--shows likeihood of dying if you contract covid in Mexico
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectPortafolio..CovidDeaths$
WHERE location like '%Mexico%'
and continent is not null
ORDER BY 1, 2


--looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM ProjectPortafolio..CovidDeaths$
--WHERE location like '%Mexico%'
ORDER BY 1, 2


--looking at countries with highest infections rate compared with population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM ProjectPortafolio..CovidDeaths$
--WHERE location like '%Mexico%'
Group by population, location
ORDER BY PercentPopulationInfected desc

--Showing the countries with the Highest Deat Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortafolio..CovidDeaths$
--WHERE location like '%Mexico%'
WHERE continent is not null
Group by location
ORDER BY TotalDeathCount desc


--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortafolio..CovidDeaths$
--WHERE location like '%Mexico%'
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount desc


--Global numbers

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int )) as Total_Deaths, SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as DeathPercentage
FROM ProjectPortafolio..CovidDeaths$
--WHERE location like '%Mexico%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as PeopleVaccinated
,--(PeopleVaccinated/population)*100
FROM ProjectPortafolio..CovidDeaths$ dea
join ProjectPortafolio..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date 
	WHERE dea.continent is not null
	order by 2,3


--USE CTE

With PopvsVac (continent, Location, Date, Population, new_vaccinations, PeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as PeopleVaccinated

FROM ProjectPortafolio..CovidDeaths$ dea
join ProjectPortafolio..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null
	--order by 2,3
)
SELECT *,(PeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccionations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as PeopleVaccinated
FROM ProjectPortafolio..CovidDeaths$ dea
join ProjectPortafolio..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date 
--WHERE dea.continent is not null
	--order by 2,3

SELECT *,(PeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




--Creating View to sotre data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as PeopleVaccinated
FROM ProjectPortafolio..CovidDeaths$ dea
join ProjectPortafolio..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null
--order by 2,3

SELECT *
FROM #PercentPopulationVaccinated
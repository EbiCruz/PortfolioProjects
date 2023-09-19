
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Order By 1,2

-- Total Cases versus Total Deaths as a percentage
-- Ratio shows the likelihood of dying if contracted by the disease 
-- Code to see the percentage by country (creating new column alias to show results)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%state%' --Looking for the United States (can specify any country here)
Order By 1,2 --Ordering by the location and date


-- Looking at Total Cases versus the population of each country

Select location, date, population, total_cases, (total_cases/population)*100 as ContractPercentage
From PortfolioProject..CovidDeaths
Where location like '%state%' --Looking for the United States (can specify any country here [optional])
Order By 1,2 --Ordering by the location and date


-- Looking at countries with highest infection rate compared to population
 Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
 From PortfolioProject..CovidDeaths
 Group By Location, population
 Order by PercentPopulationInfected desc --Show from highest to lowest

 -- Showing the countries with highest death count
 Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount --Max((total_deaths/population))*100 as DeathRate
 From PortfolioProject..CovidDeaths
 Where continent is NOT NULL --To exclude data where the 'location' is showing the whole continent count
 Group By Location
 Order by TotalDeathCount desc --Showing the countries with highest count to lowest
 
 -- Breaking down by whole continent count
 Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 Where continent is null
 Group By location
 Order By TotalDeathCount desc

 -- Showing the continents with highest death count rates

 Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount, Max(population) as TotalPopulation, (Max(cast(total_deaths as bigint))/Max(population))*100 as DeathRate
 From PortfolioProject..CovidDeaths
 Where continent is null
 Group By location
 Order By DeathRate desc

 -- Global Numbers By daily cases, deaths, and that day death percentage

 Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 Where continent is NOT NULL
 Group By date
 Order By 1, 2

 -- Looking at Total Population vs Vaccinations

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths as dea
 JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths as dea
 JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Temp Table Version

DROP Table if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
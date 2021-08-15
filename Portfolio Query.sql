--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths
ORDER BY 1, 2


--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
WHERE location LIKE '%states%'
ORDER BY 1, 2


--Looking at the Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
WHERE location LIKE '%states%'
ORDER BY 1, 2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest Death Count

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Looking at Death Count by Continent

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing continents with the highest death count per population

SELECT location, MAX(cast(total_deaths AS int)/population) AS DeathPercentagePopulation
FROM PortfolioProject..covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY DeathPercentagePopulation DESC



--Global Numbers


--Death Percentage of Infected by Date Across World

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
GROUP BY date
ORDER BY 1, 2


--Total Death Percentage of Infected Across World

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
--GROUP BY date
ORDER BY 1, 2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations --(RollingVaccinations/population)*100
FROM PortfolioProject..covid_vaccinations vac
JOIN PortfolioProject..covid_deaths dea
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
ORDER BY 2, 3

--CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccinations) AS 

(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations --(RollingVaccinations/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations)

SELECT *, (RollingVaccinations/Population)*100
FROM PopVsVac


--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated

(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations --(RollingVaccinations/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

SELECT *, (RollingVaccinations/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations --(RollingVaccinations/population)*100
FROM PortfolioProject..covid_vaccinations vac
JOIN PortfolioProject..covid_deaths dea
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinated
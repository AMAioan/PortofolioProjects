SELECT *
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4


--SELECT * 
--FROM PortofolioProject..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, total_deaths, new_cases, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1, 2 



-- Total Cases vs. Total Deaths
-- The  likelyhood of dying from COVID-19 (USA)
SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2 



-- Percentage of population that got COVID-19 %

SELECT location, date, total_cases, total_cases, population, (total_cases/ population)*100 AS Infected
FROM PortofolioProject..CovidDeaths
ORDER BY 1, 2 


-- Looking at countries with Highest Infection Rate compared to Population %

SELECT location, Population, MAX(total_cases) AS MaxInfectionCount, MAX((total_cases/ population)*100) AS PopulationInfected
FROM PortofolioProject..CovidDeaths
GROUP BY location, Population
ORDER BY PopulationInfected DESC


-- Looking at Hieghest Death Count per Population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Looking at Highest Death Count per Continent

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE  continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


-- Total Population vs Vaccinations
SET ANSI_WARNINGS OFF
;WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea 
JOIN PortofolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac
WHERE location like  '%Romania%'



-- Creating View to store data for later visualizations 

CREATE VIEW PeopleVaccinatedpercent 
AS 
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortofolioProject..CovidDeaths dea 
	JOIN PortofolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null

SELECT * 
FROM PeopleVaccinatedpercent
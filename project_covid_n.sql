-- Data overview --
SELECT *
FROM ProjectCovidNow..CovidVaccinationsN
WHERE continent IS NOT null
ORDER BY 3,4; -- ordering by Location and Date --

SELECT *
FROM ProjectCovidNow..CovidDeathsN
ORDER BY 3,5;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectCovidNow..CovidDeathsN
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths (%) --
-- Shows likelihood of fying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS '%'
FROM ProjectCovidNow..CovidDeathsN
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Population (%) --
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 2) AS '%'
FROM ProjectCovidNow..CovidDeathsN
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population --

SELECT location, population, MAX(total_cases) AS HighInfecCount, MAX(ROUND((total_cases/population)*100, 2)) AS '%'
FROM ProjectCovidNow..CovidDeathsN
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

-- Showing countries with highest death count per population --

SELECT location, MAX(CAST(total_deaths AS INT)) AS DeathsCount
FROM ProjectCovidNow..CovidDeathsN
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- Total deaths by continent --

SELECT location, MAX(CAST(total_deaths AS INT)) AS DeathsCount
FROM ProjectCovidNow..CovidDeathsN
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC;

-- World deaths percentage --

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100, 2) AS '%'
FROM ProjectCovidNow..CovidDeathsN
WHERE continent IS NOT NULL
ORDER BY 3;

-- Total population vs Vaccinations --

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM ProjectCovidNow..CovidDeathsN dea
JOIN ProjectCovidNow..CovidVaccinationsN vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Total % population vaccinated --

WITH popvac (continent, location, date, population, new_vaccinations, rollpeoplevac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, CONVERT(date, dea.date)) AS rollpeoplevac
FROM ProjectCovidNow..CovidDeathsN dea
JOIN ProjectCovidNow..CovidVaccinationsN vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (rollpeoplevac/population)*100 AS '%_people_vacc'
FROM popvac
-- WHERE location = 'Brazil'

-- TEMP TABLE --

DROP TABLE IF EXISTS #PercPopVaccinated
CREATE TABLE #PercPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollpeoplevac numeric
)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, CONVERT(date, dea.date)) AS rollpeoplevac
FROM ProjectCovidNow..CovidDeathsN dea
JOIN ProjectCovidNow..CovidVaccinationsN vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rollpeoplevac/population)*100 AS '%_people_vacc'
FROM #PercPopVaccinated

-- Creating View to store data for DataViz --

CREATE VIEW PercPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollpeoplevac
FROM ProjectCovidNow..CovidDeathsN dea
JOIN ProjectCovidNow..CovidVaccinationsN vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercPopVaccinated

-- ALTER TABLE SIZE --
ALTER TABLE CovidVaccinationsN
ALTER COLUMN location nvarchar(150)

-- Total % population fully vaccinated --

SELECT location, date, people_fully_vaccinated, population, ROUND((people_fully_vaccinated/population)*100, 2) AS '%'
FROM ProjectCovidNow..CovidVaccinationsN
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Total % population with booster vac --

SELECT location, date, total_boosters, population, ROUND((total_boosters/population)*100, 2) AS '%'
FROM ProjectCovidNow..CovidVaccinationsN
WHERE continent IS NOT NULL
-- AND location = 'Brazil'
ORDER BY 1,2;
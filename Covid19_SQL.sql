SELECT * 
FROM covid.dbo.coviddeaths


SELECT * 
FROM covid.dbo.covidvac

--Selecting data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid.dbo.coviddeaths
ORDER BY location, date


-- Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM covid.dbo.coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date

--Shows the likelihood of dying if you contract covid in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM covid.dbo.coviddeaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY location, date

--Looking at total cases vs population
--Shows what % of population got covid
SELECT location, date, total_cases, total_deaths, population, (total_cases/population) * 100 AS PercentPopulationInfected
FROM covid.dbo.coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date

SELECT location, date, total_cases, total_deaths, population, (total_cases/population) * 100 AS PercentPopulationInfected
FROM covid.dbo.coviddeaths
WHERE location LIKE 'India'
AND continent IS NOT NULL
ORDER BY location, date

--Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM covid.dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Looking at countries with the highest death count per population

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM covid.dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LETS BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM covid.dbo.coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(New_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM covid.dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(New_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM covid.dbo.coviddeaths
WHERE continent IS NOT NULL



-- Looking at total population vs vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM covid.dbo.coviddeaths AS d
JOIN covid.dbo.covidvac AS v
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3


SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS people_vaccinated
FROM covid.dbo.coviddeaths AS d
JOIN covid.dbo.covidvac AS v
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3


--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, people_vaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS people_vaccinated
FROM covid.dbo.coviddeaths AS d
JOIN covid.dbo.covidvac AS v
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL
)

SELECT *, (people_vaccinated/population)*100 AS vaccination_percentage
FROM popvsvac


-- TEMP TABLE

CREATE TABLE popvsvac
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
new_vaccinations numeric,
people_vaccinated numeric,
)
 
INSERT INTO popvsvac
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS people_vaccinated
FROM covid.dbo.coviddeaths AS d
JOIN covid.dbo.covidvac AS v
ON d.location = v.location 
AND d.date = v.date
--WHERE d.continent IS NOT NULL



-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW popvsvac AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS people_vaccinated
FROM covid.dbo.coviddeaths AS d
JOIN covid.dbo.covidvac AS v
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *
FROM popvsvac







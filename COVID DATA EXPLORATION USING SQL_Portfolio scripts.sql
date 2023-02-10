SELECT * FROM Portfolioproject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

--Filtering the data we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

-- Total cases vs total deathes
--show the possibility of dying when contacted with covid (In africa)
SELECT location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 AS 'death percentage'
FROM Portfolioproject..CovidDeaths
--WHERE LOCATION LIKE '%africa%'
WHERE continent is not null
ORDER BY 1,2;

-- Total cases by population
-- And percentage of the population that got covid 
SELECT location, date,population,total_cases,(total_cases/population)*100 AS '% of population infected'
FROM Portfolioproject..CovidDeaths
--WHERE LOCATION LIKE '%africa%'
WHERE continent is not null
ORDER BY 1,2;

--Countries with highest infection rate compare to population
SELECT location, population, MAX(total_cases) AS 'maximum infection count',MAX(total_cases/population)*100 AS '% Maximum of population infected'
FROM Portfolioproject..CovidDeaths
--WHERE LOCATION LIKE '%africa%'
WHERE continent is not null
GROUP BY population, location
ORDER BY '% Maximum of population infected' DESC;

--Countries with highest death rate by population
SELECT location, MAX(cast(total_deaths as int)) AS 'maximum death count'
FROM Portfolioproject..CovidDeaths
--WHERE LOCATION LIKE '%africa%'
WHERE continent is not null
GROUP BY location
ORDER BY 'maximum death count' DESC;

--Continent with highest death rate by population
SELECT continent, MAX(cast(total_deaths as int)) AS 'maximum death count'
FROM Portfolioproject..CovidDeaths
--WHERE LOCATION LIKE '%africa%'
WHERE continent is not null
GROUP BY continent
ORDER BY 'maximum death count' DESC;

--Global Numbers
-- Cases grouped by date globally
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ sum(new_cases) * 100 as totaldeathpercentage
FROM Portfolioproject..CovidDeaths
--WHERE LOCATION LIKE '%africa%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

--
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ sum(new_cases) * 100 as totaldeathpercentage
FROM Portfolioproject..CovidDeaths
--WHERE LOCATION LIKE '%africa%'
WHERE continent is not null
ORDER BY 1,2;

--VACCINATION

--Total population vs vaccination
SELECT death.continent, death.location, death.date,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by death.location ORDER BY death.location, death.date) AS total_vaccinations
--,(total_vaccinations/population) * 100
FROM Portfolioproject..CovidDeaths death
JOIN
Portfolioproject..CovidVaccinations vac
ON death.location = vac.location AND death.date = vac.date
--WHERE vac.new_vaccinations IS NOT NULL
WHERE death.continent is not null
ORDER BY 2,3

--USE OF CTE
WITH POPvsVAC 
AS 
(SELECT death.continent, death.location, death.population, death.date,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by death.location ORDER BY death.location, death.date) AS total_vaccinations
--,(total_vaccinations/population) * 100
FROM Portfolioproject..CovidDeaths death
JOIN
Portfolioproject..CovidVaccinations vac
ON death.location = vac.location AND death.date = vac.date
--WHERE vac.new_vaccinations IS NOT NULL
WHERE death.continent is not null
)
SELECT *,(total_vaccinations/population) * 100 AS '%of_total_vaccinations_in_population'
FROM POPvsVAC 


--TEMP TABLE
DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)
INSERT INTO #percentpopulationvaccinated
SELECT death.continent, death.location, death.date, death.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by death.location ORDER BY death.location, death.date) AS total_vaccinations
--,(total_vaccinations/population) * 100
FROM Portfolioproject..CovidDeaths death
JOIN
Portfolioproject..CovidVaccinations vac
ON death.location = vac.location AND death.date = vac.date
--WHERE vac.new_vaccinations IS NOT NULL
WHERE death.continent is not null

SELECT *,(total_vaccinations/population) * 100 AS '%of_total_vaccinations_in_population'
FROM #percentpopulationvaccinated

--CREATING VIEW
CREATE VIEW percentpopulationvaccinated AS
SELECT death.continent, death.location, death.date, death.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by death.location ORDER BY death.location, death.date) AS total_vaccinations
--,(total_vaccinations/population) * 100
FROM Portfolioproject..CovidDeaths death
JOIN
Portfolioproject..CovidVaccinations vac
ON death.location = vac.location AND death.date = vac.date
--WHERE vac.new_vaccinations IS NOT NULL
WHERE death.continent is not null

SELECT * FROM percentpopulationvaccinated


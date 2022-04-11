SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE location like '%income%' AND continent is not  NULL
ORDER BY 3,4;

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

---CHOOSE DATA TO BE USED
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

---total cases v/s total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--- UPDATE COLUMN TO FLOAT INTEGER TYPE
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN new_cases FLOAT;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases FLOAT;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN population FLOAT;

SELECT Location, date, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE new_cases=NULL;

ALTER TABLE PortfolioProject..CovidVaccinations
ALTER COLUMN new_vaccinations FLOAT;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN date datetime;


--- UPDATE VALUES TO NULL WHERE VALUE=0 SO THAT IT DOES NOT GIVE DIVIDE BY ZERO ERROR
UPDATE PortfolioProject..CovidDeaths
SET new_deaths=NULL 
WHERE new_deaths=0;

UPDATE PortfolioProject..CovidDeaths
SET total_cases=NULL 
WHERE total_cases=0;

----UPDATE BLANK SPACES AS NULL
UPDATE PortfolioProject..CovidDeaths
SET continent=NULL 
WHERE continent=' ';

UPDATE PortfolioProject..CovidDeaths
SET population=NULL 
WHERE population=0;

UPDATE PortfolioProject..CovidVaccinations
SET new_vaccinations=NULL 
WHERE new_vaccinations=0;

---likelihood of death by covid in india(make sure data is in correct type , here float, to get expected result)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%INDIA%'
ORDER BY 1,2;

----total cases v/s population
-- Shows what percentage of population infected with Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS CovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%INDIA%'
ORDER BY 1,2;

---countries with highest infection rate compared to population

SELECT location, max(total_cases) as highestinfectioncountry, population, max((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
----WHERE Location LIKE '%INDIA%'
GROUP BY population,location
ORDER BY PercentagePopulationInfected desc;


---countries with highest death count per population

SELECT Location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;


---Comparing by continent

-- Showing contintents with the highest death count per population
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


---highest death count in continents

SELECT continent, max(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc;

---GLOBAL
SELECT location, max(total_cases) as highestinfectioncountry, population, max((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
----WHERE Location LIKE '%INDIA%'
GROUP BY population,location
ORDER BY PercentagePopulationInfected desc;

SELECT date, sum(new_cases) , SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
----WHERE Location LIKE '%INDIA%'
WHERE continent is null
GROUP BY date
ORDER BY 1,2;

SELECT  sum(new_cases) , SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
----WHERE Location LIKE '%INDIA%'
WHERE continent is null
----GROUP BY date
ORDER BY 1,2;


----------------------------------------------------------------------------
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT location, new_vaccinations
FROM PortfolioProject..CovidVaccinations;

SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
,SUM(new_vaccinations) OVER (Partition by dea.location,dea.date)
FROM PortfolioProject..CovidDeaths dea
	 JOIN PortfolioProject..CovidVaccinations vac
	 ON dea.location=vac.location
	 AND dea.date=vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3;



-- Using CTE to perform Calculation on Partition By in previous query
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
,SUM(new_vaccinations) OVER (Partition by dea.location,dea.date)
FROM PortfolioProject..CovidDeaths dea
	 JOIN PortfolioProject..CovidVaccinations vac
	 ON dea.location=vac.location
	 AND dea.date=vac.date
WHERE dea.continent is not NULL
-----ORDER BY 2,3;
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac;

---TEMP table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(225), 
Location nvarchar(225), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric , 
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
,SUM(new_vaccinations) OVER (Partition by dea.location,dea.date)
FROM PortfolioProject..CovidDeaths dea
	 JOIN PortfolioProject..CovidVaccinations vac
	 ON dea.location=vac.location
	 AND dea.date=vac.date
WHERE dea.continent is not NULL
---ORDER BY 2,3;

SELECT *
FROM #PercentPopulationVaccinated;

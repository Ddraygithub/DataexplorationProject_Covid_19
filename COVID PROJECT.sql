
--Visualizing the data COVIDDEATH in Nigeria
SELECT *
FROM dbo.COVIDDEATH
WHERE location = 'Nigeria';

--Extracting the needed data excluding null continent
SELECT date, location, population, new_cases, total_deaths, total_cases
FROM dbo.COVIDDEATH
WHERE continent IS NOT NULL;

--How possible is it to die after contracting the virus?
-- Let us look at totalcases vs totaldeath
SELECT date, location, total_cases, total_deaths
FROM dbo.COVIDDEATH
WHERE continent IS NOT NULL AND location = 'Nigeria'
ORDER BY 4 DESC;

--Visualising total_cases and total_death in percentage
SELECT date, location, population, total_cases, total_deaths, (CAST(total_deaths as float) / CAST(total_cases as float))*100 AS percentage_death
FROM dbo.COVIDDEATH
WHERE continent IS NOT NULL AND location = 'Nigeria'
ORDER BY 4 DESC;

--Showing the percentage of the population in Nigeria that contracted covid per date
SELECT date, location, population, total_cases, (total_cases/population)*100 AS casesper_population
FROM dbo.COVIDDEATH
WHERE continent IS NOT NULL AND location = 'Nigeria'
ORDER BY 4 DESC;

--Let us look at countries with highest cases and their population in the world
--World cases
SELECT location, population, MAX(total_cases) AS highest_case, MAX((total_deaths/population))*100 AS percentage_highest_death
FROM dbo.COVIDDEATH
GROUP BY location, population
ORDER BY percentage_highest_death DESC;

--Countries with the highest death count
SELECT location, MAX(total_deaths) highest_death
FROM dbo.COVIDDEATH
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death DESC;


--Globally

--Looking at the continent with higest death
SELECT continent, MAX(total_deaths) highest_death
FROM dbo.COVIDDEATH
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death DESC;

--Let us look at the numbers on a global scale

SELECT SUM(new_cases) AS total_global_cases, SUM(new_deaths) total_global_death, SUM(new_deaths)/(SUM(new_cases)*100) AS percentage_deaths
FROM dbo.COVIDDEATH
WHERE continent IS NOT NULL;

--Bringing in vaccination 

SELECT *
FROM dbo.COVIDVACCINATION;

--Joning the two tables
SELECT *
FROM dbo.COVIDDEATH codet
JOIN dbo.COVIDVACCINATION covac
	ON codet.location = covac.location
	AND codet.date = covac.date
ORDER BY codet.location;

--Looking at population vs vaccination
SELECT codet.date, codet.population, covac.new_vaccinations, codet.continent, codet.location 
FROM dbo.COVIDDEATH codet
JOIN dbo.COVIDVACCINATION covac
	ON codet.location = covac.location
	AND codet.date = covac.date
ORDER BY 2, 3 DESC;

--Percentage Population vs Vaccinated using CTE
WITH percentpop (date, population, new_vaccinations, continent, location, people_vacc)
AS
(
SELECT codet.date, codet.population, covac.new_vaccinations, codet.continent, codet.location, 
	SUM(CAST(covac.new_vaccinations AS float)) 
	OVER (PARTITION BY codet.location ORDER BY codet.location, codet.date) AS people_vacc
FROM dbo.COVIDDEATH codet
JOIN dbo.COVIDVACCINATION covac
	ON codet.location = covac.location
	AND codet.date = covac.date
WHERE codet.continent IS NOT NULL
)
SELECT *, (people_vacc/population)*100 percent_vaccinated
FROM percentpop;

--Calculating Percentage vaccinated vs population using tempt table  
DROP TABLE IF EXISTS #POPVSVACC
CREATE TABLE #POPVSVACC (
date datetime,
population numeric,
new_vaccinations numeric,
continent nvarchar(100),
location nvarchar(100),
people_vacc numeric
)
INSERT INTO #POPVSVACC
SELECT codet.date, codet.population, covac.new_vaccinations, codet.continent, codet.location, 
	SUM(CAST(covac.new_vaccinations AS float)) 
	OVER (PARTITION BY codet.location ORDER BY codet.location, codet.date) AS people_vacc
FROM dbo.COVIDDEATH codet
JOIN dbo.COVIDVACCINATION covac
	ON codet.location = covac.location
	AND codet.date = covac.date
WHERE codet.continent IS NOT NULL;

SELECT *, (people_vacc/population)*100 percent_vaccinated
FROM #POPVSVACC;

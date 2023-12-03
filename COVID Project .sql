-- Select Main Data
SELECT
  location
  , date
  , total_cases
  , new_cases
  , total_deaths
  , population
FROM covid_deaths
; 



-- Total Deaths Vs. Total Cases as %
SELECT
  location
  , date
  , total_cases
  , total_deaths
  , ROUND(((total_deaths/total_cases)*100),2) as Death_Percentage 
FROM covid_deaths
WHERE location ILIKE '%%states%' AND continent IS NOT NULL
ORDER BY date asc
;

-- Total Cases Vs. Total Population
SELECT
  location
  , date
  , total_cases
  , population
  , ROUND(((total_cases/population)*100),2) as Percent_Of_People_Infected
FROM covid_deaths
WHERE continent IS NOT NULL
;

-- Most Deaths In Countries
SELECT
  location
  , MAX(total_deaths) as Total_Deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Deaths desc
;

-- Total Deaths in Each Continent
SELECT
  location
  , MAX(total_deaths) as Total_Deaths
FROM covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_Deaths desc
;

-- Countries With HIghest Infection Rate
SELECT 
  location
  , population
  , MAX(total_cases) as Highest_Infections
  , MAX((total_cases/population))*100 as Percent_of_Population_Infected
FROM covid_deaths
GROUP BY location, Population
ORDER BY percent_of_Population_Infected desc
;

-- Cases Across the Globe
SELECT
  date
  , SUM(CAST(new_cases AS int)) as global_new_cases
  , SUM(CAST(new_deaths AS int)) as global_new_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY global_new_cases
;

-- CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, Rolling_Vaccinations)
AS
(
SELECT
  deaths.continent
  , deaths.location
  , deaths.date
  , deaths.population
  , vacs.new_vaccinations
  , SUM(CAST(vacs.new_vaccinations AS numeric)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as Rolling_Vaccinations
FROM covid_deaths AS deaths
JOIN covid_vaccinations AS vacs ON deaths.location = vacs.location 
       AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL
ORDER BY deaths.location, deaths.date
)
SELECT 
  *
  , (Rolling_Vaccinations/population)*100
FROM PopVsVac
;

-- TEMP Table
DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TEMP TABLE percent_population_vaccinated
(
continent varchar(255)
, location varchar(255)
, date timestamp
, population numeric
, new_vaccinations numeric
, rolling_vaccinations numeric
);
INSERT INTO
SELECT
  deaths.continent
  , deaths.location
  , deaths.date
  , deaths.population
  , vacs.new_vaccinations
  , SUM(CAST(vacs.new_vaccinations AS numeric)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as Rolling_Vaccinations
FROM covid_deaths AS deaths
JOIN covid_vaccinations AS vacs ON deaths.location = vacs.location 
       AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL
ORDER BY deaths.location, deaths.date
;
SELECT 
  *
  , (Rolling_Vaccinations/population)*100
FROM percent_population_vaccinated
;


-- Views
CREATE VIEW percent_population_vaccinated AS
SELECT
  deaths.continent
  , deaths.location
  , deaths.date
  , deaths.population
  , vacs.new_vaccinations
  , SUM(CAST(vacs.new_vaccinations AS numeric)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as Rolling_Vaccinations
FROM covid_deaths AS deaths
JOIN covid_vaccinations AS vacs ON deaths.location = vacs.location 
       AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL
ORDER BY deaths.location, deaths.date
;


CREATE VIEW total_deaths_by_continent AS
SELECT
  location
  , MAX(total_deaths) as Total_Deaths
FROM covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_Deaths desc
;
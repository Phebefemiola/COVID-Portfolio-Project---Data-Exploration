/* Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
 */

Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From [Portfolio Project]..CovidVaccinations
Order by 3,4

--Select Data to use

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
Order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%kingdom%'
Order by 1,2

-- Percentage of population with Covid


Select Location, date, population, total_cases, (total_cases/population)*100 As CovidPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Order by 1,2

--Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) As HighestinfectionCount, MAX((total_cases/population))*100 As PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

--Countries with the highest death count per population

Select Location, MAX(CAST(total_deaths as int)) As TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Continent with the Highest death count per population when continent 

Select continent, MAX(CAST(total_deaths as int)) As TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--When continent is null
Select location, MAX(CAST(total_deaths as int)) As TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

-- Global Impact

Select date, SUM(new_cases) As total_cases, SUM(CAST(new_deaths as int)) As total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) As total_cases, SUM(CAST(new_deaths as int)) As total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS PercentageDeath
From [Portfolio Project]..CovidDeaths
WHEre continent is not null


Select *
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	AND dea.iso_code = vac.iso_code

--Total Population Vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	AND dea.iso_code = vac.iso_code
Where dea.continent is not null
Order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) AS TotalPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	AND dea.iso_code = vac.iso_code
Where dea.continent is not null
Order by 2,3
	
-- Using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) AS TotalPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	AND dea.iso_code = vac.iso_code
Where dea.continent is not null
--Order by 2,3
)
Select *, (TotalPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) AS TotalPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	AND dea.iso_code = vac.iso_code
--Where dea.continent is not null
--Order by 2,3

Select *, (TotalPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Create View to store data for later visualization

Create view PercentPopulationVacccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) AS TotalPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	AND dea.iso_code = vac.iso_code
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVacccinated
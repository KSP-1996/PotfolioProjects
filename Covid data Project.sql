/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp tables, windows functions, Aggregate functions, creating views, Converting data types

*/

Select *
From CovidDeaths
Where continent is not null
Order by 3,4

-- Select the data that we will be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
order by 1, 2

-- Total cases vs Total deaths
-- Shows likelihood of dying if contracting covid in your country


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%South Africa%'
and continent is not null
order by 1, 2

-- Total cases vs Population
-- Shows percentage of population infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%South Africa%'
Order by 1,2

-- Countries with Highest infection rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%South Africa%'
Group by location, population
Order by PercentPopulationInfected Desc

-- Countries with highest Death count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%South Africa%'
Where continent is not null
Group by location
Order by TotalDeathCount Desc


-- Breaking things down by Continent

-- Showing continents with highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%South Africa%'
Where continent is null
Group by location
Order by TotalDeathCount Desc

-- Global Numbers

Select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%South Africa%'
Where continent is not null 
-- Group by date
Order by 1,2

-- Total Population vs Vaccinations
-- Shows percentage of population that has Received at least one Covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Using CTE to perform calculation on Partition by in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Using Temp Table to perform calculation on Partition by in previous query

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
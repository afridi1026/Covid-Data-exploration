Select * 
from [Portfolio project]..covidDeaths
where continent is not null
order by 3,4

--Select * 
--from [Portfolio project]..covidVaccinations
--order by 3,4


Select location,date, total_cases, new_cases, total_deaths, population
from [Portfolio project]..covidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of dying if yu contract covid in your country

Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio project]..covidDeaths
where location like '%india%'
and continent is not null
order by 1,2

-- Looking at total cases vs the popultaion

Select location,date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
from [Portfolio project]..covidDeaths
--where location like '%india%'
where continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, MAX(total_cases) as highestInfection, population, MAX((total_cases/population))*100 as HighestInfectionPerc
from [Portfolio project]..covidDeaths
--where location like '%india%'
where continent is not null
Group by location, population
order by HighestInfectionPerc desc


-- BREAKING THINGS BY CONTINENT


-- Showing continents with highest deathcounts

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..covidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc


  
  -- GLOBAR NUMBERS

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathperc --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio project]..covidDeaths
--where location like '%india%'
where continent is not null
Group by date
order by 1,2

-- TOTAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathperc --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio project]..covidDeaths
--where location like '%india%'
where continent is not null
order by 1,2


-- Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..covidDeaths dea
join [Portfolio project]..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..covidDeaths dea
join [Portfolio project]..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
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
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..covidDeaths dea
join [Portfolio project]..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- CREATING VIEWS

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project]..covidDeaths dea
join [Portfolio project]..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated
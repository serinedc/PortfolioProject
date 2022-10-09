Select *
From PortfolioProject..CovidDeaths$
Where continent is not NULL
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelyhood of dying if you contract covid in the US
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

--France
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%France%'
order by 1,2

-- Looking at Total cases VS Populations
-- Shows what percentage of the population got COVID19
Select Location, date, Population, total_cases, (total_cases/Population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to Population 

Select Location, Population, MAX(total_cases) as HighestinfectionCount, MAX((total_cases/Population))*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by InfectedPopulationPercentage desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
Where continent is not NULL
Group by Location, Population
order by TotalDeathsCount desc

-- breaking things down by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
Where continent is not NULL
Group by continent
order by TotalDeathsCount desc



-- Global numbers

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--- Where location like '%states%'
Where continent is not NULL
Group By date
order by 1,2

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population=*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population=*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
DROP Table If exists #PercentPopulationVaccinated
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
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population=*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population=*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
/*
Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From Portfolioproject..['covid deaths$']
Where continent is not null
order by 3,4

-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..['covid deaths$']
Where continent is not null
order by 1,2


--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your continent
Select location, date, total_cases, total_deaths, (cast(total_deaths as float))/(cast(total_cases as float))*100 as DeathPercentage
From Portfolioproject..['covid deaths$']
where location like '%Africa%'
and continent is not null
order by 1,2

--Total Cases vs Population
--Shows what percentage of population infected with Covid
Select location, date, total_cases, Population, (cast(total_cases as float))/(cast(population as float))*100 as CasesPercentage 
From Portfolioproject..['covid deaths$']
order by 1,2

--Countries with Highest Infection Rate compared to Population
Select location, Population, MAX(total_cases) as HighestInfectionCount, (cast(Max(total_cases) as float))/(cast(population as float))*100 as CasesPercentage
From Portfolioproject..['covid deaths$']
Group by location, population
order by CasesPercentage desc

--Cpountries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
From Portfolioproject..['covid deaths$']
Where continent is not null
Group by location
order by TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
From Portfolioproject..['covid deaths$']
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers
Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From Portfolioproject..['covid deaths$']
where continent is not null
order by 1,2



--Total Population vs Vaccinations
--Shows Percentage of Populationhas recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolioproject..['covid deaths$'] dea
Join Portfolioproject..['covid vaccinations$'] vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null  
order by 2,3

--Using CTE(Common Table Expression) to perform Calculation on Partition in previous query
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolioproject..['covid deaths$'] dea
Join Portfolioproject..['covid vaccinations$'] vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null  
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using  Temp Table to perform Calculation on Partition By in previous queryble
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolioproject..['covid deaths$'] dea
Join Portfolioproject..['covid vaccinations$'] vac
   On dea.location = vac.location
   and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolioproject..['covid deaths$'] dea
Join Portfolioproject..['covid vaccinations$'] vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null






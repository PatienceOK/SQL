
--- Covid 19 Data Exploration 
--- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

---Select Data that we are going to be starting with

select location, date, total_cases, 
new_cases, total_deaths, population
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
order by 1,2


--Total cases vs Total Deaths
-- Shows likelihood of dyin if you contract covid in the United States.

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from [Portfolio project].dbo.CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2

--Total cases vs Population
--Shows what percentage of population got infected with Covid

select location, date, total_cases, population, (total_cases/population)*100 PercentagePoplulation
from [Portfolio project].dbo.CovidDeaths$
order by 1,2

--Showing Countries with the highest infection rate compared to population

select location, population, Max(total_cases) HighestInfectionCount, 
max((total_cases/population))*100 PercentagePopulationInfected
from [Portfolio project].dbo.CovidDeaths$
group by location, population
order by PercentagePopulationInfected desc


--Showing Countries with the Highest Deathcount per population

select location, max(cast(total_deaths as int)) TotalDeathCount
from [Portfolio project].dbo.CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc

--Showing Continents with the highest deathcounts per population

select continent, max(cast(Total_deaths as int)) TotalDeathCount 
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers of Deaths 

select date, sum(new_cases) TotalCases, sum(cast(new_deaths as int)) TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2

select sum(new_cases) TotalCases, sum(cast(new_deaths as int)) TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
order by 1,2

--Global numbers of Vaccinations

select date, sum(convert(int,new_tests)) TotalTests, sum(convert(int,new_vaccinations)) TotalVaccinations, 
sum(convert(int,new_vaccinations))/sum(convert(int,new_tests))*100 VaccinationPercentage
from [Portfolio project].dbo.CovidVaccinations$
where continent is not null
group by date
order by 1,2


--Looking at Total population vs Vaccinations
--Shows percentage of population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from [Portfolio project].dbo.CovidDeaths$ dea
join [Portfolio project].dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE to perform Calculation on Partition By in previous query

with PopvsVac (Continent, location, date, population,New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from [Portfolio project].dbo.CovidDeaths$ dea
join [Portfolio project].dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Use Temp Table to perform calculation on partition by in previous query


drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project].dbo.CovidDeaths$ dea
join [Portfolio project].dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio project].dbo.CovidDeaths$ dea
join [Portfolio project].dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

create view DeathPercentage as
select date, sum(new_cases) TotalCases, sum(cast(new_deaths as int)) TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
group by date

create view TotalDeathCount as
select continent, max(cast(Total_deaths as int)) TotalDeathCount 
from [Portfolio project].dbo.CovidDeaths$
where continent is not null
group by continent
--order by TotalDeathCount desc


select * from PortfolioProject.dbo.coviddeaths
order by 3,4

select * from PortfolioProject.dbo.covidvaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1,2

--Total cases vs Total deaths in United states

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percent_of_deaths
from PortfolioProject..coviddeaths
where location like '%states%'
order by 1,2

--Total cases vs Population in India

select location, date, total_cases, population, (total_cases/population)*100 as percentage_affected
from PortfolioProject..coviddeaths
where location = 'india'
order by 1,2

--Most affected country on per capita basis

select location, MAX(total_cases/population) as infection_rate
from PortfolioProject..coviddeaths
group by location order by infection_rate DESC

--Total number of cases by each country within continent

select continent, location, sum(new_cases) as total_cases
from PortfolioProject..coviddeaths
where continent is not null
group by location, continent
order by continent, location

--Moving average(7days) of cases for each country

with MovingAvgCTE as
(
select a.continent,a.location,a.date, a.new_cases, AVG(b.new_cases) over (partition by a.location,a.date) as MovingAverage_7days from PortfolioProject..coviddeaths a join PortfolioProject..coviddeaths b
on a.location = b.location and b.date between dateadd(day,-6,a.date) and a.date
where a.continent is not null
--group by 1,2,3
--order by 2,3
)
select * from MovingAvgCTE
group by continent, location, date, new_cases, MovingAverage_7days order by location, date

--Total population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as rolling_vaccinations
from PortfolioProject..coviddeaths as dea join PortfolioProject..covidvaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2

--Using CTE to perform Calculation on Partition By in previous query

with CTE_table(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as rolling_vaccinations
from PortfolioProject..coviddeaths as dea join PortfolioProject..covidvaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentRollingVaccinations from CTE_table order by Location

--Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #temptable
create table #temptable(continent varchar(255), location varchar(255), date datetime, population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric)

Insert into #temptable
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as rolling_vaccinations
from PortfolioProject..coviddeaths as dea join PortfolioProject..covidvaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2

select *, (RollingPeopleVaccinated/population)*100 as percent_rolling_vaccinations
from #temptable

--Countries that are in danger zone
select continent, location, MAX(total_cases/population)*100 as percentage_of_cases,
CASE 
	when MAX(total_cases/population)*100 < 0.1 then 'highly safe'
	when MAX(total_cases/population)*100 between 0.1 and 0.5 then 'moderately safe'
	when MAX(total_cases/population)*100 between 0.5 and 1 then 'slightly dangerous'
	when MAX(total_cases/population)*100 > 1 then 'highly dangerous'
	else 'no data'
END as Safe_factor
from PortfolioProject..coviddeaths
where continent is not null
group by location, continent
order by continent, location

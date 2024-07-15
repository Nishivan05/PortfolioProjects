select *
from PortfolioProject..['covid deaths$']
where continent is not null


--select*
--from PortfolioProject..['covid vaccination$']
--order by 3,4


-- select data that we are going to be using

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..['covid deaths$']
order by 1,2

-- loooking at total_cases vs total_deaths
-- shows likelihood of dying if you contact covid in your country

select Location,date,total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as death_percentage
from PortfolioProject..['covid deaths$']
where location like '%india%'
order by 1,2

-- looking at the total_cases vs population
-- what percentage of people got covid

select Location,date,total_cases,population,(cast(total_cases as float)/cast(population as float))*100 as covid_percentage
from PortfolioProject..['covid deaths$']
where location like '%india%'
order by 1,2

-- looking at countries with highest infection rate
select Location,max(total_cases)as highest_infection_count,population,max((cast(total_cases as float)/cast(population as float)))*100 as max_covid_percentage
from PortfolioProject..['covid deaths$']
group by location,population
order by max_covid_percentage desc

--looking at countries with the maximum death count per population

select Location,max(cast(total_deaths as int)) as total_death_counts
from PortfolioProject..['covid deaths$']
where continent is not null
group by location
order by total_death_counts desc


-- lets see for continents with max deaths
select continent,max(cast(total_deaths as int)) as total_death_counts
from PortfolioProject..['covid deaths$']
where continent is not null
group by continent
order by total_death_counts desc 

--global numbers **error**
select date, sum(cast(new_cases as float)),sum(cast(new_deaths as float)),sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as death_percentage
from PortfolioProject..['covid deaths$']
where continent is not null
group by date
order by 1,2

---   total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date)
as rolling_people_vaccination,(/dea.population)*100 as percentage_vaccinated
from PortfolioProject..['covid vaccination$'] vac
join PortfolioProject..['covid deaths$'] dea
on vac.location =dea.location
and vac.date = dea.date
where dea.continent is not null 

-- USE CTE
with PopvsVac (continent,location,date,population,new_vaccination,rolling_people_vaccination)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date)
as rolling_people_vaccination
from PortfolioProject..['covid vaccination$'] vac
join PortfolioProject..['covid deaths$'] dea
on vac.location =dea.location
and vac.date = dea.date
where dea.continent is not null
--order by 2,3
)
select*,(rolling_people_vaccination/population)*100
from PopvsVac

--with temp 
drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(continent varchar(50),
location varchar(50),
date datetime,
population numeric ,
new_vaccination numeric,
rolling_people_vaccination numeric)


insert into #percentagepopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date)
as rolling_people_vaccination
from PortfolioProject..['covid vaccination$'] vac
join PortfolioProject..['covid deaths$'] dea
on vac.location =dea.location
and vac.date = dea.date
where dea.continent is not null
--order by 2,3
select*,(rolling_people_vaccination/population)*100
from #percentagepopulationvaccinated



--create view to store data for later visualisation

create view percentagepopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date)
as rolling_people_vaccination
from PortfolioProject..['covid vaccination$'] vac
join PortfolioProject..['covid deaths$'] dea
on vac.location =dea.location
and vac.date = dea.date
where dea.continent is not null
--order by 2,3










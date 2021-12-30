select * 
from portfolioproject..CovidDeaths$
where continent is not null
order by 3,4
--select * 
--from portfolioproject..CovidVaccinations$
--order by 3,4

--select data that we are going to be using 
select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..CovidDeaths$ order by 1,2

--loking at totalcases vs totaldeaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths$
where location like '%states%'
order by 1,2
-- loking at totalcases vs populalation 
--shows what percentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as deathpercentage
from portfolioproject..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate campared to population
select location,population,max(total_cases) as highestinfectionrate,max((total_cases/population)*100)
as percentagepopulationinfected from portfolioproject..CovidDeaths$
group by location,population
order by percentagepopulationinfected desc

select location,population,date,max(total_cases) as highestinfectioncount,max((total_cases/population)*100)
as percentagepopulationinfected from portfolioproject..CovidDeaths$
group by location,population,date
order by percentagepopulationinfected desc


--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount from portfolioproject..CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc

--lets break things down by continent 
select location, max(cast(total_deaths as int)) as totaldeathcount from portfolioproject..CovidDeaths$
where continent is  null
group by location
order by totaldeathcount desc
select continent, max(cast(total_deaths as int)) as totaldeathcount from portfolioproject..CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc

--showing continent with highestdeath count par population
select continent, max(cast(total_deaths as int)) as totaldeathcount from portfolioproject..CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc

--global number
select date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2

select date,sum(new_cases) as sumofnewcases--total_deaths(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as totalcases,sum(new_deaths_smoothed) as totaldeaths,
sum(cast(new_deaths_smoothed as int))/sum(new_cases)*100 as deathpercentage--total_deaths(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2
select * from portfolioproject..CovidVaccinations$  

--looking at total polulation vs total vaccination 

select * from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccinations$ vac
   on dea.location=vac.location
   and dea.date=vac.date
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccinations$ vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null
   order by 2,3

select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint ))  over(partition by dea.location order by dea.location,
dea.date)
as rollingpeoplevaccinated
from portfolioproject..CovidDeaths$ dea 
join portfolioproject..CovidVaccinations$ vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null
   order by 1,2,3

   --use cte
with popvsvac(continent,date,location,population,new_vaccinations,
rollingpeoplevaccinated)
as
(
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint ))  over(partition by dea.location)
as rollingpeoplevaccinated
from portfolioproject..CovidDeaths$ dea 
join portfolioproject..CovidVaccinations$ vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null
   --order by 1,2,3
   )
   select *, (rollingpeoplevaccinated/population)*100 from popvsvac

   --temp table
   drop table if exists #percentpopulationvaccinated
   create table #percentpopulationvaccinated(
   continent nvarchar(255),
   date datetime,
   location nvarchar(225),
   population numeric,
   new_vaccinations numeric,
   rollingpeoplevaccinated numeric)

   insert into #percentpopulationvaccinated
   select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint ))  over(partition by dea.location)
as rollingpeoplevaccinated
from portfolioproject..CovidDeaths$ dea 
join portfolioproject..CovidVaccinations$ vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null

  select *, (rollingpeoplevaccinated/population)*100 from #percentpopulationvaccinated

--create view to store data for later visualization
drop view  percentpopulationvaccinated
create view percentpopulationvaccinated
as
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint ))  over(partition by dea.location)
as rollingpeoplevaccinated
from portfolioproject..CovidDeaths$ dea 
join portfolioproject..CovidVaccinations$ vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null

   select * from percentpopulationvaccinated
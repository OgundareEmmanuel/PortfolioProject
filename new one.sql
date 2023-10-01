

select*
from portfolioproject..Coviddeaths
order by 3,4

select continent, location, count(continent)
from portfolioproject..Coviddeaths
group by continent, location
order by continent

select*
from portfolioproject..covidvaccination
order by 3,4

select location,date, total_cases, total_deaths,population
from portfolioproject..Coviddeaths
order by 1,2 

-- looking at the total  number of cases and the total deaths 
select sum(cast(total_cases as bigint)) as sumtotalcases, 
sum(cast(total_deaths as bigint)) as sumtotaldeaths
from portfolioproject..Coviddeaths

--Looking at the rate of total deaths to total cases general 
--shows likelihood of dying after contacting the virus
select location,date, total_cases, total_deaths,population, (cast(total_deaths as float))/
(cast(total_cases as float))* 100 as RatesofDeaths
from portfolioproject..Coviddeaths
group by location,date, total_cases, total_deaths,population

--Looking at the rate of total deaths to total cases in Africa
--shows likelihood of dying after contacting the virus in Africa
 select continent, location,date, total_cases, total_deaths,population, (cast(total_deaths as float))/
(cast(total_cases as float))* 100 as RatesofDeaths
from portfolioproject..Coviddeaths
where Continent ='Africa'
group by continent,location,date, total_cases, total_deaths,population

--total cases vs the population 
--shows likelihood of contacting the virus
 select continent, location,date, total_cases, population, (cast(total_cases as float))/(cast(population as float))*100 as Ratesofinfection
from portfolioproject..Coviddeaths
--where Continent ='Africa'
group by continent,location,date, total_cases,population

--total cases vs the population in angola
--shows likelihood of contacting the virus in Angola
 select continent, location,date, total_cases, population, (cast(total_cases as float))/(cast(population as float))*100 as Ratesofinfection
from portfolioproject..Coviddeaths
where location ='nigeria'
group by continent,location,date, total_cases,population

--looking at countries with the highest infection rate compared to population 
 select location, max(convert(int,total_cases)) Highestinfectioncount, population, (max(cast(total_cases as float))/(cast(population as float))*100) as Ratesofinfection
from portfolioproject..Coviddeaths
group by location,population
order by Ratesofinfection desc

--showing the countries with the highest death count per population 
 select location, max(convert(int,total_deaths)) Highestdeathcount, population, (max(cast(total_deaths as float))/(cast(population as float))*100) as Ratesofdeath
from portfolioproject..Coviddeaths
where continent is not null
group by location,population
order by Ratesofdeath desc

 --global numbers 
 --showing continents with the highest death count per population 
  select continent, max(convert(int,total_deaths)) Highestdeathcount
from portfolioproject..Coviddeaths
where continent is not null
group by continent
order by Highestdeathcount desc

--Looking at total population vs vaccinations

select*
from portfolioproject..Coviddeaths dea
join portfolioproject..Covidvaccination vac
on dea.location =vac.location 
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location  order by dea.date  ) rollingpeoplevaccination
from portfolioproject..Coviddeaths dea
join portfolioproject..Covidvaccination vac
on dea.location =vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using cte
with propvsvac (continent, location,date,population,new_vaccination, rollingpeoplevaccination)
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location  order by dea.date  ) rollingpeoplevaccination
from portfolioproject..Coviddeaths dea
join portfolioproject..Covidvaccination vac
on dea.location =vac.location 
and dea.date = vac.date
where dea.continent is not null
)
select continent, location,date,population,new_vaccination, rollingpeoplevaccination,
(rollingpeoplevaccination/population)*100 peoplevaccinated
from propvsvac

--using temptable
drop table if exists #propvsvac 
create table #propvsvac1
(continent  varchar(100), location varchar(100),date date ,population bigint,new_vaccination bigint, 
rollingpeoplevaccination bigint)

insert into #propvsvac1 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location  order by dea.date  ) rollingpeoplevaccination
from portfolioproject..Coviddeaths dea
join portfolioproject..Covidvaccination vac
on dea.location =vac.location 
and dea.date = vac.date 
where dea.continent is not null

select continent, location, date,population, new_vaccination,rollingpeoplevaccination,
(cast(rollingpeoplevaccination as numeric)/cast(population as numeric))*100
from #propvsvac1

--creating views
create view  Totalnumbercasevsdeath as 
select sum(cast(total_cases as bigint)) as sumtotalcases, 
sum(cast(total_deaths as bigint)) as sumtotaldeaths
from portfolioproject..Coviddeaths

create view likelihoodofdyingaftercontactingvirus as
select location,date, total_cases, total_deaths,population, (cast(total_deaths as float))/
(cast(total_cases as float))* 100 as RatesofDeaths
from portfolioproject..Coviddeaths
group by location,date, total_cases, total_deaths,population


create view countrywiththehighestvirus as 
 select location, max(convert(int,total_cases)) Highestinfectioncount, population, (max(cast(total_cases as float))/(cast(population as float))*100) as Ratesofinfection
from portfolioproject..Coviddeaths
group by location,population


create view countrywiththehighestdeathrate as
 select location, max(convert(int,total_deaths)) Highestdeathcount, population, (max(cast(total_deaths as float))/(cast(population as float))*100) as Ratesofdeath
from portfolioproject..Coviddeaths
where continent is not null
group by location,population


create view continentwithhighestdeathcount as 
  select continent, max(convert(int,total_deaths)) Highestdeathcount
from portfolioproject..Coviddeaths
where continent is not null
group by continent

create view dailyvaccinationcount as 
with propvsvac (continent, location,date,population,new_vaccination, rollingpeoplevaccination)
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location  order by dea.date  ) rollingpeoplevaccination
from portfolioproject..Coviddeaths dea
join portfolioproject..Covidvaccination vac
on dea.location =vac.location 
and dea.date = vac.date
where dea.continent is not null
)
select continent, location,date,population,new_vaccination, rollingpeoplevaccination,
(rollingpeoplevaccination/population)*100 peoplevaccinated
from propvsvac

 
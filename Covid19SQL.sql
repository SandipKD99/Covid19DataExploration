Select * From PortfolioProject.dbo.CovidDeaths  where continent is not null order by 3,4




--Selecting Reqd data

Select location,date,total_cases,new_cases,total_deaths,population 
From PortfolioProject.dbo.CovidDeaths  where continent is not null order by 1,2

--Total Cases vs Total Deaths and also the likelihood of death by Covid in 'India'

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRate 
From PortfolioProject.dbo.CovidDeaths where continent is not null
and location like 'India' order by 1,2 

--Total Cases VS Popuation(Shows Infection rate)

Select location,date,total_cases,population,(total_cases/population)*100 as InfectionRate 
From PortfolioProject.dbo.CovidDeaths  where continent is not null
and location like 'India' order by 1,2 

--Countries with Highest Infection rate per population

Select location,population,MAX(total_cases) as HighestInfectionCount ,MAX(total_cases/population)*100 as InfectionRate 
From PortfolioProject.dbo.CovidDeaths where continent is not null
group by location,population order by InfectionRate desc

--Countries with Highest Death count per population

Select location,population,MAX(cast(total_deaths as int)) as HighestDeathCount 
--MAX(total_deaths/population)*100 as DeathRate 
 From PortfolioProject.dbo.CovidDeaths 
 where continent is not null group by location,population order by HighestDeathCount  desc


 --Lets Break things down by continent

-- Select location,MAX(cast(total_deaths as int)) as HighestDeathCount 
----MAX(total_deaths/population)*100 as DeathRate 
-- From PortfolioProject.dbo.CovidDeaths 
-- where continent is null group by location order by HighestDeathCount  desc

 --Showing continents with the highest detah count per population
 Select continent,MAX(cast(total_deaths as int)) as HighestDeathCount 
--MAX(total_deaths/population)*100 as DeathRate 
 From PortfolioProject.dbo.CovidDeaths 
 where continent is not null group by continent order by HighestDeathCount  desc

 --Global Numbers
-- Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRate 
--From PortfolioProject.dbo.CovidDeaths where continent is not null
--order by 1,2

-- Select date,sum(new_cases) as NewCases,sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathRate
--From PortfolioProject.dbo.CovidDeaths where continent is not null group by date
--order by 1,2

---Overall global world deaths and death rate
 Select sum(new_cases) as NewCases,sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathRate
From PortfolioProject.dbo.CovidDeaths where continent is not null 
order by 1,2


Select * From PortfolioProject.dbo.CovidVaccinations where continent is not null order by 3,4

--joining CovidDeaths and CovidVaccinations table

--We are looking at Total popualtion vs Vaccinations and how  new vaccines being rolled out are added continuosly to total vaccination count

Select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
SUM(cast(vaccine.new_vaccinations as int)) OVER (Partition by death.location order by death.location,death.date) as RollingPeoplevaccinated 
From PortfolioProject.dbo.CovidDeaths 
as death Join PortfolioProject.dbo.CovidVaccinations vaccine
on death.location = vaccine.location and death.date = vaccine.date  where death.continent is not null order by 1,2,3


--USE CTE

With PeopleVaccine (Continent, Location, Date,Population,New_Vaccinations, RollingPeoplevaccinated)
as
(
Select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
 SUM(cast(vaccine.new_vaccinations as int)) OVER (Partition by death.location order by death.location,death.date) as RollingPeoplevaccinated 
 From PortfolioProject.dbo.CovidDeaths 
 as death Join PortfolioProject.dbo.CovidVaccinations vaccine
 on death.location = vaccine.location and death.date = vaccine.date  where death.continent is not null 
 --order by 2,3
)

Select *, (RollingPeoplevaccinated/Population) * 100 from Peoplevaccine


--Creating A TEMPORARY Table

Drop table if exists PercentPeopleVaccinated
Create Table PercentPeopleVaccinated
(
Continent  nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)

Insert into PercentPeopleVaccinated

Select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
 SUM(cast(vaccine.new_vaccinations as int)) OVER (Partition by death.location order by death.location,death.date) as RollingPeoplevaccinated 
 From PortfolioProject.dbo.CovidDeaths 
 as death Join PortfolioProject.dbo.CovidVaccinations vaccine
 on death.location = vaccine.location and death.date = vaccine.date  
 where death.continent is not null 
 --order by 2,3

Select *, (RollingPeoplevaccinated/Population) * 100 from PercentPeopleVaccinated


---Creating VIEW to store data for Visualization later on

Create VIEW PercentPeopleVaccinated1 as
Select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
 SUM(cast(vaccine.new_vaccinations as int)) OVER (Partition by death.location order by death.location,death.date) as RollingPeoplevaccinated 
 From PortfolioProject.dbo.CovidDeaths 
 as death Join PortfolioProject.dbo.CovidVaccinations vaccine
 on death.location = vaccine.location and death.date = vaccine.date  
 where death.continent is not null 
 --order by 2,3

 Select * from PercentPeopleVaccinated1


--Table Covid Deaths
Select *
From PortfolioProject..CovidDeaths$
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--Total kasus vs total kematian
-- Menunjukkan kemungkinan kematian jika tertular COVID di Indonesia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PersentaseKematian
From PortfolioProject..CovidDeaths$
Where location like '%Indonesia%'
order by 1,2

--Total kasus vs population
-- Menunjukkan berapa persentase populasi yang tertular COVID di Indonesia
Select location, date, population, total_cases, (total_cases/population)*100 as PersentasePopulasiKematian
From PortfolioProject..CovidDeaths$
Where location like '%Indonesia%'
order by 1,2


-- Negara dengan infeksi COVID terbesar dengan jumlah populasinya
Select location, population,MAX(total_cases) as JumlahInfeksiTertinggi, MAX((total_cases/population))*100 as PersentasePopulasiTerinfeksi
From PortfolioProject..CovidDeaths$
group by location, population
order by PersentasePopulasiTerinfeksi desc

-- Menunjukan negara dengan Populasi Kematian Terbesar
Select location, MAX(cast(Total_deaths as int)) as JumlahKematian
From PortfolioProject..CovidDeaths$
Where continent is not null
group by location
order by JumlahKematian desc

-- Menunjukkan Benua dengan populasi kematian terbesar
Select continent, MAX(cast(Total_deaths as int)) as JumlahKematian
From PortfolioProject..CovidDeaths$
Where continent is not null
group by continent
order by JumlahKematian desc

-- Global Number
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PersentaseKematian
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2


-- Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as OrangYangVaksin
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Penggunaan CTE
With PopvsVac (continent, location, date, population, new_vaccinations, OrangYangVaksin)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as OrangYangVaksin
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
)
Select *, (OrangYangVaksin/population)*100
From PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

 -- Membuat View
 Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT *
From PercentPopulationVaccinated

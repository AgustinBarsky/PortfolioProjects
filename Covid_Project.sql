--Seleccionamos la base a utilizar. En este caso, la base se llama "Agustin".

USE Agustin;

--------------------------------------------

--Seleccionamos * y lo ordenamos por 'location' y por 'date' (columnas 3 y 4)

SELECT * FROM CovidDeaths
ORDER BY 3,4;

--------------------------------------------

--Observamos todos los países que se encuentran en nuestro dataset

SELECT DISTINCT(location) FROM CovidDeaths
ORDER BY location;

--------------------------------------------

--Observamos la fecha del primer y del último registro

SELECT DISTINCT(date) FROM CovidDeaths
ORDER BY date;

SELECT MIN(DISTINCT(date)) Primer_Registro, MAX(DISTINCT(date)) Ultimo_Registro
FROM CovidDeaths;

--------------------------------------------

--Población por país

SELECT DISTINCT(location), population
FROM CovidDeaths;

-- Ordenamos por population DESC

SELECT DISTINCT(location), population
FROM CovidDeaths
ORDER BY population DESC;

--------------------------------------------

-- ratio de muertes (muertes/casos)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) rate_death, population
FROM dbo.CovidDeaths
ORDER BY location, date;

-- Modificamos rate_death para trabajarlo como porcentaje

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) percentaje_death, population
FROM dbo.CovidDeaths
ORDER BY location, date;

-- Veamos solamente Argentina

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) percentaje_death, population
FROM dbo.CovidDeaths
WHERE location = 'Argentina'
ORDER BY location, date;

-- Casos y muertes totales en Argentina

SELECT 'Argentina' País, MAX(total_deaths) total_deaths, MAX(total_cases) total_cases, 
((MAX(total_deaths)/MAX(total_cases))*100) percentaje_death
FROM dbo.CovidDeaths
WHERE location = 'Argentina';


--total_cases / population
--Impresionante! un 18% del país, contrajo Covid

SELECT 'Argentina' País, MAX(total_deaths) total_deaths, MAX(total_cases) total_cases, 
((MAX(total_deaths)/MAX(total_cases))*100) percentaje_death, (((MAX(total_cases))/MAX(population))*100) cases_population
FROM dbo.CovidDeaths
WHERE location = 'Argentina';

-- El 0,268% de la población argentina, falleció a causa del Covid

SELECT 'Argentina' País, MAX(total_deaths) total_deaths, MAX(total_cases) total_cases, 
((MAX(total_deaths)/MAX(total_cases))*100) percentaje_death, (((MAX(total_deaths))/MAX(population))*100) deaths_population
FROM dbo.CovidDeaths
WHERE location = 'Argentina';

--------------------------------------------

-- Veamos cual es el país que mas casos/población tuvo
-- Increíble. En Andorra, la mitad de su población contrajo Covid 19

SELECT location, population, MAX(total_deaths) total_deaths, MAX(total_cases) total_cases, 
((MAX(total_deaths)/MAX(total_cases))*100) percentaje_death, (((MAX(total_cases))/MAX(population))*100) cases_population
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY 6 DESC;

-- Siguiendo con el análisis, me pareción interesante agregar un Ranking.

SELECT RANK() OVER (ORDER BY (((MAX(total_cases))/MAX(population))*100) DESC) Ranking, location, population, 
MAX(total_deaths) total_deaths,  MAX(total_cases) total_cases, ((MAX(total_deaths)/MAX(total_cases))*100) percentaje_death, 
(((MAX(total_cases))/MAX(population))*100) cases_population
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY 1 ASC;


--------------------------------------------

-- Exploremos nuestra tabla CovidVaccinations

SELECT * FROM dbo.CovidVaccinations

-- Veamos en Argentina la cantidad de dosis suministradas, la cantidad de personas vacunadas,
-- y la cantidad de personas completamente vacunadas
-- Resultados:
-- 1) se suministraron un total de 89.915.714 vacunas
-- 2) se vacunó a 39.829.143 personas
-- 3) 35072.121 personas se encuentran totalmente vacunadas 

SELECT location, date, total_vaccinations, people_vaccinated, people_fully_vaccinated FROM dbo.CovidVaccinations
WHERE location = 'Argentina'
ORDER BY date DESC;

--------------------------------------------

-- Hagamos un Join de nuestras tablas, utilizando las columnas location y date

SELECT * FROM dbo.CovidDeaths CovDe
INNER JOIN dbo.CovidVaccinations CovVA
ON CovDe.location = CovVA.location
AND CovDe.date = CovVA.date;

SELECT CovDe.location, CovDe.date, CovDe.population, CovDe.total_cases, CovDe.total_deaths,
CovVa.total_vaccinations, CovVa.people_vaccinated, CovVa.people_fully_vaccinated 
FROM dbo.CovidDeaths CovDe
INNER JOIN dbo.CovidVaccinations CovVA
ON CovDe.location = CovVA.location
AND CovDe.date = CovVA.date
WHERE CovDe.continent IS NOT NULL
ORDER BY CovDe.location, CovDe.date;

-- Volvamos a ver analizar a Argentina

SELECT CovDe.location, CovDe.date, CovDe.population, CovDe.total_cases, CovDe.total_deaths,
CovVa.total_vaccinations, CovVa.people_vaccinated, CovVa.people_fully_vaccinated 
FROM dbo.CovidDeaths CovDe
INNER JOIN dbo.CovidVaccinations CovVA
ON CovDe.location = CovVA.location
AND CovDe.date = CovVA.date
WHERE CovDe.continent IS NOT NULL
AND CovDe.location = 'Argentina'
ORDER BY CovDe.date DESC;

-- Porcentaje de población vacunada, y totalmente vacunada
-- Resultados:
-- 1) el 87,3% de la población argentina se encuentra vacunada
-- 2) el 76,9% de la población argentina se encuentra totalmente vacunada

SELECT CovDe.location, CovDe.date, CovDe.population,
(((CAST(CovVa.people_vaccinated AS NUMERIC))/CovDe.population)*100) percentaje_people_vaccinated,
(((CAST(CovVa.people_fully_vaccinated AS NUMERIC))/CovDe.population)*100) percentaje_people_fully_vaccinated
FROM dbo.CovidDeaths CovDe
INNER JOIN dbo.CovidVaccinations CovVa
ON CovDe.location = CovVa.location
AND CovDe.date = CovVa.date
WHERE CovDe.continent IS NOT NULL
AND CovDe.location = 'Argentina'
ORDER BY date DESC;

--------------------------------------------

-- Continuando, vamos a proceder a crear una vista de la última consulta, para poder
-- visualizarla cuando lo necesitemos

CREATE VIEW PercentajesPeopleVaccinatedAndFullyVaccinated AS
SELECT CovDe.location, CovDe.date, CovDe.population,
(((CAST(CovVa.people_vaccinated AS NUMERIC))/CovDe.population)*100) percentaje_people_vaccinated,
(((CAST(CovVa.people_fully_vaccinated AS NUMERIC))/CovDe.population)*100) percentaje_people_fully_vaccinated
FROM dbo.CovidDeaths CovDe
INNER JOIN dbo.CovidVaccinations CovVa
ON CovDe.location = CovVa.location
AND CovDe.date = CovVa.date
WHERE CovDe.continent IS NOT NULL
AND CovDe.location = 'Argentina';

-- Utilizamos nuestra vista

SELECT * FROM dbo.PercentajesPeopleVaccinatedAndFullyVaccinated
ORDER BY date DESC

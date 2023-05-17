-- PROJETO DE ESTUDO: COVID 19
-- DADOS A SEREM EXTRAÍDOS:
-- % MORTES; CASOS X POPULAÇÃO; INFECÇÃO MÁXIMA VS PAÍSES; %TOTAL DE MORTES VS POPULAÇÃO DE PAÍSES; MORTES VS CONTINENTES; ANÁLISE GLOBAL; VACINAÇÃO ACUMULADA POR DATA E LOCALIDADE
--CRIAÇÃO DE VIEWS PARA SEREM USADAS POSTERIORMENTE NO POWER BI

--DADOS GERAIS
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases,
	total_deaths,
	population
FROM 
	covidDeaths
ORDER BY
	1,2

--% de mortes por por casos totais-----------------------------------------------------------------------------------
CREATE VIEW Mortes_Casos AS
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths,
	CONVERT(decimal(15,3), total_deaths) / CONVERT(decimal(15,3), total_cases) as 'Mortes/Casos' --função convert para transfroma em númerico os dados
FROM 
	covidDeaths
WHERE
	location = 'Asia'
ORDER BY
	2 desc

--TOTAL de casos vs population----------------------------------------------------------------------------------------
CREATE VIEW Casos_população AS
SELECT 
	location, 
	date, 
	population,
	total_cases, 
	CONVERT(decimal(15,3), total_cases) / CONVERT(decimal(15,3), population)*100 as 'Casos/População' --função convert para transfroma em númerico os dados
FROM 
	covidDeaths
WHERE
	location = 'Brazil'
ORDER BY
	1,2

--Paises com maior infecção---------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW Contaminação_maxima AS
SELECT 
	location, 
	population,
	MAX(CONVERT(decimal(15,3), total_cases)) as MaiorContagem, 
	MAX(CONVERT(decimal(15,3), total_cases) / CONVERT(decimal(15,3), population))*100 as 'Casos/População' --função convert para transfroma em númerico os dados
FROM 
	covidDeaths
GROUP BY
	location, 
	population
ORDER BY
	4 DESC

--Paises e seu máximo numero de mortes por população--------------------------------------------------------------------------------------------------------------------
CREATE VIEW Mortes_população AS 
SELECT 
	location, 
	population,
	MAX(CONVERT(decimal(15,3), total_deaths)) as MaiorContagemMortes, 
	MAX(CONVERT(decimal(15,3), total_deaths) / CONVERT(decimal(15,3), population))*100 as 'Mortes/População' --função convert para transfroma em númerico os dados
FROM 
	covidDeaths
GROUP BY
	location, 
	population
ORDER BY
	3 DESC

--NUMERO DE MORTES POR CONTINENTE--------------------------------------------------------------------------------------------------------------------
CREATE VIEW Mortes_continente AS
SELECT
	continent,
	SUM(CONVERT(decimal(15,1),new_cases)) as NovosCasos,
	SUM(CONVERT(decimal(15,1),new_deaths)) as NovasMortes
FROM 
	covidDeaths
WHERE
	continent <> location
GROUP BY 
	continent
Order by
	3
--Analise global = somatória
CREATE VIEW Casos_MortesGlobal AS
SELECT
	date,
	--location,
	SUM(CONVERT(decimal(15,3),new_cases)) as NovosCasos,
	SUM(CONVERT(decimal(15,3),new_deaths)) as NovasMortes,
	SUM(CONVERT(decimal(15,3), new_deaths) / NULLIF(CONVERT(decimal(15,3), new_cases),0))*100 as 'Mortes por novos casos %'
FROM 
	covidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	date
--	location
ORDER BY
	1 ASC


-- agora  analisar vacinações ao longo do tempo + acumulado + % da população vacinada
-- aqui [é necessario fazer uma tabela de consulta para conseguir fazer o valor acumulado e então, a partir dessa tabela de consulta, podemos fazer uma operação com total de vacinação x pop
-- ou poderiamos criar uma nova tabela que tenha apenas os dados da CTE e então a partir dessa nova tabela, fariamos uma coluna com operação.
WITH cte AS 
(
	SELECT 
		cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		SUM(CONVERT(decimal(18,2),cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS	TotalVacinações --irá fazer o acumúlado de vacinas (sum) porém será diferenciado pela location (partition by location) e organizada por data e lugar
	FROM
		covidDeaths cd
	LEFT JOIN
		covidvaccines cv
		ON
			cd.location = cv.location
		AND cd.date = cv.date
	WHERE 
		cd.continent IS NOT NULL
)
SELECT
		continent,
		location,
		date,
		population,
		new_vaccinations,
		TotalVacinações,
		(TotalVacinações / population) * 100 AS "% Vacinação"
FROM
	cte
ORDER BY
	1,2,3

-- como a consulta deu certo, agora é criar a VIEW

CREATE VIEW PorcentagemPopulaçãoVacinada AS
	SELECT 
		cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		SUM(CONVERT(decimal(18,2),cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS	TotalVacinações
	FROM
		covidDeaths cd
	LEFT JOIN
		covidvaccines cv
		ON
			cd.location = cv.location
		AND cd.date = cv.date
	WHERE 
		cd.continent IS NOT NULL
	--ORDER BY
	--	1,2,3

CREATE VIEW Paises AS
SELECT 
	DISTINCT(location)
FROM
	covidDeaths
-- PROJETO DE ESTUDO: COVID 19
-- DADOS A SEREM EXTRA�DOS:
-- % MORTES; CASOS X POPULA��O; INFEC��O M�XIMA VS PA�SES; %TOTAL DE MORTES VS POPULA��O DE PA�SES; MORTES VS CONTINENTES; AN�LISE GLOBAL; VACINA��O ACUMULADA POR DATA E LOCALIDADE
--CRIA��O DE VIEWS PARA SEREM USADAS POSTERIORMENTE NO POWER BI

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
	CONVERT(decimal(15,3), total_deaths) / CONVERT(decimal(15,3), total_cases) as 'Mortes/Casos' --fun��o convert para transfroma em n�merico os dados
FROM 
	covidDeaths
WHERE
	location = 'Asia'
ORDER BY
	2 desc

--TOTAL de casos vs population----------------------------------------------------------------------------------------
CREATE VIEW Casos_popula��o AS
SELECT 
	location, 
	date, 
	population,
	total_cases, 
	CONVERT(decimal(15,3), total_cases) / CONVERT(decimal(15,3), population)*100 as 'Casos/Popula��o' --fun��o convert para transfroma em n�merico os dados
FROM 
	covidDeaths
WHERE
	location = 'Brazil'
ORDER BY
	1,2

--Paises com maior infec��o---------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW Contamina��o_maxima AS
SELECT 
	location, 
	population,
	MAX(CONVERT(decimal(15,3), total_cases)) as MaiorContagem, 
	MAX(CONVERT(decimal(15,3), total_cases) / CONVERT(decimal(15,3), population))*100 as 'Casos/Popula��o' --fun��o convert para transfroma em n�merico os dados
FROM 
	covidDeaths
GROUP BY
	location, 
	population
ORDER BY
	4 DESC

--Paises e seu m�ximo numero de mortes por popula��o--------------------------------------------------------------------------------------------------------------------
CREATE VIEW Mortes_popula��o AS 
SELECT 
	location, 
	population,
	MAX(CONVERT(decimal(15,3), total_deaths)) as MaiorContagemMortes, 
	MAX(CONVERT(decimal(15,3), total_deaths) / CONVERT(decimal(15,3), population))*100 as 'Mortes/Popula��o' --fun��o convert para transfroma em n�merico os dados
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
--Analise global = somat�ria
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


-- agora  analisar vacina��es ao longo do tempo + acumulado + % da popula��o vacinada
-- aqui [� necessario fazer uma tabela de consulta para conseguir fazer o valor acumulado e ent�o, a partir dessa tabela de consulta, podemos fazer uma opera��o com total de vacina��o x pop
-- ou poderiamos criar uma nova tabela que tenha apenas os dados da CTE e ent�o a partir dessa nova tabela, fariamos uma coluna com opera��o.
WITH cte AS 
(
	SELECT 
		cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		SUM(CONVERT(decimal(18,2),cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS	TotalVacina��es --ir� fazer o acum�lado de vacinas (sum) por�m ser� diferenciado pela location (partition by location) e organizada por data e lugar
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
		TotalVacina��es,
		(TotalVacina��es / population) * 100 AS "% Vacina��o"
FROM
	cte
ORDER BY
	1,2,3

-- como a consulta deu certo, agora � criar a VIEW

CREATE VIEW PorcentagemPopula��oVacinada AS
	SELECT 
		cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		SUM(CONVERT(decimal(18,2),cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS	TotalVacina��es
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
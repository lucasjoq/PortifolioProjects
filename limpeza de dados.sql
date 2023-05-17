--------------Exercicios de limpeza e altera��o de data--------------

SELECT
	*
FROM
	limpeza

--------------Formatar formato de data e alterar na tabela original----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Primeiro vamos encontrar um formato "ok". Depois vamos jogar esse formato que queremos no update.

SELECT
	SaleDate,
	CONVERT(date,SaleDate) AS Date1 --formato que queremos"
	--convert(varchar, SaleDate ,11) AS Date2,   alguns exemplos de formata��es diferentes 
	--convert(varchar, SaleDate ,3) AS Date3
FROM
	limpeza

UPDATE
	limpeza
SET
	SaleDate = CONVERT(date,SaleDate) 


--por algum motivo o update na tabela n�o funcionou. vamos para outro jeito que �: criamos uma coluna nova em formato de data e fazemos a convers�o nela.

ALTER TABLE 
	limpeza
ADD DataModificada Date

UPDATE
	limpeza
SET
	DataModificada = CONVERT(date,SaleDate)


--------------Adicionar propriedade no Adress data----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--existem propertyadress que est�o nulos. Como iremos preenche-los de forma correta?
--Podemos identificar que: de toda tabela, ParcelID ela se repete quando h� propertyaddress repetido. Ent�o vamos usar ela com referencia para preencher

SELECT
	*
FROM
	limpeza
ORDER BY
	2

SELECT
	a.[UniqueID ],
	a.ParcelID,
	a.PropertyAddress,
	b.[UniqueID ],
	b.ParcelID,
	b.PropertyAddress
FROM
	limpeza a
JOIN
	limpeza b
	ON
		a.ParcelID = b.ParcelID
	AND a.[UniqueID ] < > b.[UniqueID ]
ORDER BY
	2
WHERE
	a.PropertyAddress is null

--esse codigo faz que: a tabela se consulte (2 tabelas iguais) em que: queremos que entre as linhas, o parcelID A seja igual B mas o uniqueID A seja diferente B. Assim excluimos dados que s� possuem 1 uniqueId e parcelId
--assim, por serem dados multiplicados que trazem null,essa fun��o ira agrupar o dado que n�o h� null com null, porque eles possuem uniqueID diferentes mas possuem parcelID iguais.
--Ent�o, para se completar, se filtrarmos por a.property = null, ela trar� apenas os nulos mas o seu correspondente de b possue endere�o 

SELECT
	a.[UniqueID ],
	a.ParcelID,
	a.PropertyAddress,
	b.[UniqueID ],
	b.ParcelID,
	b.PropertyAddress, 
	ISNULL(a.PropertyAddress,b.PropertyAddress) -- isnull = se o primeiro argumento � null, preencha com esse. Ent�o precisamos que essa coluna seja inserida nos nulos
FROM
	limpeza a
JOIN
	limpeza b
	ON
		a.ParcelID = b.ParcelID
	AND a.[UniqueID ] < > b.[UniqueID ]
WHERE
	a.PropertyAddress is null

UPDATE a -- precisa deixar "a". Ela ja faz ref�rencia do que seria o "a" e porque da problema se deixar apenas PropertyAddress
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM limpeza a
JOIN limpeza b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] < > b.[UniqueID ]
WHERE
	a.PropertyAddress is null -- agora a tabela foi preenchida corretamente

SELECT
	*
FROM
	limpeza
ORDER BY
	2


--------------Quebrar Adress em valores individuais----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- precisamos quebrar a coluna adress em 2 novas colunas: rua e cidade
-- o que separa a eles dois? uma virgula. Vamos focar nesse delimitador
-- substring(coluna, inicia onde, vai at� aonde) -- funciona como localizador de posi��o.
-- LEN quantidade total de letras que a palavra tem

SELECT
	PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Rua, -- come�a da primeira letra, vai at� encontrar a ',' menos 1 posi��o (assim fica sem virgula)
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Cidade -- come�a na virgula +1 posi��o, vai at� posi��o final da que contem
FROM
	limpeza

ALTER TABLE 
	limpeza
ADD Rua NVARCHAR(255)

UPDATE
	limpeza
SET
	Rua = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE 
	limpeza
ADD Cidade NVARCHAR(255)

UPDATE
	limpeza
SET
	Cidade = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))



--jeito diferente seria usando PARSENAME. PARSENAME � melhor para per�odos e existe limita��es. nesse caso ele nao identifica ',' , assim � necessario trocar ',' por . para ele identificar os periodos
SELECT
	owneraddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM limpeza

--------------trocar Y e N por Yes e No na coluna "sold as Vacant"---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- alguns valores da coluna "sold as vacant" est�o abreviados por y/n. Vamos repor eles
-- replace - nao vai dar certo pois : se usar replace no 'n' -> No, o que tiver 'No' vai virar 'Noo' = No + o

SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM limpeza
GROUP BY SoldAsVacanT

SELECT 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END
FROM limpeza

UPDATE limpeza
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant
						END


--------------Remover duplicadas---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- qual o parametro para encontrar valores duplicados?

SELECT DISTINCT(UNIQUEID), COUNT(UNIQUEID) -- nao deu certo porque: mesmo havendo alguma compra duplicada, foi gerado um uniqueid diferente. Ent�o precisamos se basear em mais variaveis
FROM limpeza
GROUP BY [UniqueID ]


WITH CTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY
				[ParcelID]
				,[PropertyAddress]
				,[SaleDate]
				,[SalePrice]
				,[LegalReference]
				ORDER BY 
				uniqueID ) row_num    --ROW_NUMBER ()OVER ( PARTITION BY): iremos contar a quantidade de vezes que a linha que contenha essas variav�is id�nticas se repetem.
SELECT *
FROM cte
where row_num >1   --- agora como deletamos as duplicada agora que encontramos j� os dados duplicados?


WITH CTE AS 
(
	SELECT *,
	ROW_NUMBER() OVER(
						PARTITION BY
									[ParcelID]
									,[PropertyAddress]
									,[SaleDate]
									,[SalePrice]
									,[LegalReference]
									ORDER BY 
									uniqueID ) row_num    
	from 
		limpeza
)
DELETE -- APLICAMOS DELETE
FROM 
	cte
where 
	row_num >1   


--------------Deletar colunas que n�o s�o necessarias---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Usamos a fun��o:

ALTER TABLE limpeza
DROP COLUMN coluna1,coluna2,coluna3
USE itau
GO

/*
SELECT * FROM [dbo].[Base_Ahorros]
SELECT * FROM [dbo].[Base_CDT]
SELECT * FROM [dbo].[Base_Cliente]
SELECT * FROM [dbo].[Base_Creditos]
*/

/*********************************************
1.a Número de Clientes que tienen Crédito y a la vez Cuenta de Ahorro 
*********************************************/

SELECT COUNT(*) AS Total
FROM [dbo].[Base_Ahorros] AS ah
INNER JOIN [dbo].[Base_Creditos] AS cr
	ON ah.Cliente = cr.Cliente

/*********************************************
1.b Número de Clientes que tienen Crédito y a la vez CDT
*********************************************/

SELECT COUNT(*) AS Total
FROM [dbo].[Base_CDT] AS cd
INNER JOIN [dbo].[Base_Creditos] AS cr
	ON cd.Cliente = cr.Cliente

/*********************************************
1.c Número de Clientes que Solo tienen Crédito (Que no tienen Cuenta de Ahorro ni CDT)
*********************************************/

SELECT COUNT(*) AS Total
FROM [dbo].[Base_Creditos] AS cr 
LEFT JOIN [dbo].[Base_Ahorros] AS ah
	ON cr.Cliente = ah.Cliente
LEFT JOIN [dbo].[Base_CDT] AS cd
	ON cr.Cliente = cd.Cliente
WHERE ah.Cliente IS NULL
	AND cd.Cliente IS NULL

/*********************************************
1.d Numero de Clientes que tienen los 3 productos (Crédito - Ahorro - CDT)
*********************************************/

SELECT COUNT(*) AS Total
FROM [dbo].[Base_Creditos] AS cr 
INNER JOIN [dbo].[Base_Ahorros] AS ah
	ON cr.Cliente = ah.Cliente
INNER JOIN [dbo].[Base_CDT] AS cd
	ON cr.Cliente = cd.Cliente

/*********************************************
2.a Campo nuevo de acuerdo a las siguientes rangos
*********************************************/

USE itau
GO

ALTER TABLE [dbo].[Base_Creditos]
ADD Rango_Dias_En_Mora TINYINT
GO

UPDATE [dbo].[Base_Creditos]
SET Rango_Dias_En_Mora = CASE
							WHEN Dias_En_Mora <= 30 THEN 1
							WHEN Dias_En_Mora <= 60 THEN 2
							WHEN Dias_En_Mora <= 90 THEN 3
							WHEN Dias_En_Mora <= 120 THEN 4
						ELSE 5
						END
GO


/*********************************************
2.b Datos agrupados por columna de rangos
*********************************************/

SELECT Rango_Dias_En_Mora
		,COUNT(Dias_En_Mora) AS Cantidad_Creditos
		,SUM(Saldo_Credito) AS Saldo_Creditos
FROM [dbo].[Base_Creditos] 
WHERE Fecha_Desembolso BETWEEN '2015-01-01' AND '2015-12-31'
GROUP BY Rango_Dias_En_Mora
ORDER BY Rango_Dias_En_Mora

/*********************************************
3.	Realice el cruce de las tablas
*********************************************/

SELECT cl.Cliente
		,cl.Estrato
		,cl.Estado_Civil
		,cl.Genero
		,CASE WHEN cr.Cliente		IS NOT NULL	THEN 1				  ELSE 0 END AS Credito
		,CASE WHEN cr.Saldo_Credito IS NOT NULL THEN cr.Saldo_Credito ELSE 0 END AS Saldo_Credito
		,CASE WHEN cr.Dias_En_Mora  IS NOT NULL THEN cr.Dias_En_Mora  ELSE 0 END AS Dias_En_Mora
		,CASE WHEN ah.Cliente	    IS NOT NULL THEN 1				  ELSE 0 END AS Ahorro
		,CASE WHEN ah.Saldo_Ahorro  IS NOT NULL THEN ah.Saldo_Ahorro  ELSE 0 END AS Saldo_Ahorro  
		,CASE WHEN cd.Cliente	    IS NOT NULL THEN 1				  ELSE 0 END AS CDT
		,CASE WHEN cd.Monto_CDT		IS NOT NULL THEN cd.Monto_CDT	  ELSE 0 END AS Monto_CDT
FROM [dbo].[Base_Cliente]		AS cl
LEFT JOIN [dbo].[Base_Ahorros]	AS ah
	ON cl.Cliente = ah.Cliente
LEFT JOIN [dbo].[Base_CDT]		AS cd
	ON cl.Cliente = cd.Cliente
LEFT JOIN [dbo].[Base_Creditos]	AS cr
	ON cl.Cliente = cr.Cliente

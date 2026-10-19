USE BATTAANALYTICS
GO

DROP TABLE IF EXISTS EnviosRoi;

CREATE TABLE EnviosRoi(
destino	VARCHAR(25)	,
fecha	DATE	,
fecbultos	DATE	,
movimiento	VARCHAR(12)	,
AgrupRubro	VARCHAR(25)	,
Transporte	VARCHAR(15)	,
Nom_Depto	VARCHAR(50)	,
num_cajas	INT	,
cant_env	INT	
)






--BULK INSERT EnviosRoi
--FROM	'C:\Users\JHERNANDEZP\Documents\GOMEZ\A2026\S39A2026\AnalisisAdicROI\envios_roi.csv'
--WITH(
--FORMAT	=	'csv',
--FIRSTROW	=	2,
--FIELDTERMINATOR	=	',',
--ROWTERMINATOR	=	'\n'

--)

SELECT * FROM EnviosRoi

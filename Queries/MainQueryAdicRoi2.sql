USE VISCOI

GO


WITH COSTOS_APLI AS (
	SELECT
	C.ARTICULO,
	CASE
	WHEN	C.moneda=	'DL'
	THEN	(C.costoactual*20*1.16*C.FACTOR)
	ELSE	(C.costoactual*1.16*C.FACTOR)
	END	COSTO_IVA
	FROM
	COSTOS(NOLOCK) C
	INNER	JOIN ARTICULOS(NOLOCK) A
		ON	C.articulo	=	A.articulo
	WHERE
	C.grupo=	'01'
	AND A.tipoart<>'PIVOTE'

)


,MOVTOS_ROI AS (

SELECT
mi.movimiento, mi.folio, mi.fecha, mi.fecbultos, mi.estatus, LTRIM(RTRIM(mi.id_sucursal1)) destino, LTRIM(RTRIM(S.PLAZA)) PLAZA_DEST,
MID.ARTICULO,
A.Marca, A.Estilo, A.Nombre,

LTRIM(RTRIM(CASE
WHEN	F.nom_rubro	=	'ISHU'	THEN	'CALZADO'
WHEN	F.nom_rubro	=	'ISHU ACC'	THEN	'ACCESORIOS'
WHEN	F.nom_rubro	LIKE('%ROPA%')	THEN	'ROPA'
ELSE	F.NOM_RUBRO
END)) AgrupRubro,
F.NOM_DEPTO,

MID.CANTIDAD,
CA.COSTO_IVA,
(MID.CANTIDAD*CA.COSTO_IVA) TotalCosto,

CASE
    WHEN MI.estatus = 'Bodega'
        THEN DATEDIFF(DAY, MI.fecha, CAST(GETDATE() AS date))
    WHEN MI.estatus = 'Actualizad'
         AND MI.fecbultos > '19000101'
        THEN DATEDIFF(DAY, MI.fecbultos, MI.fecha)
    ELSE NULL
END AS DiasEnBodega,

GEE.TRANSPORTE, 
CASE
WHEN GEE.TRANSPORTE	=	'INTER 9999' THEN GEE.CHOFER
ELSE	'TRANSPORTE INTER'
END TIPO_ENVIO

FROM
MOVTOSINVENT(NOLOCK) mi
left join movtosinventdet(nolock) mid
	on	mi.movimiento	=	mid.movimiento
LEFT JOIN SUCURSALES(NOLOCK)	S
	ON	LTRIM(RTRIM(mi.id_sucursal1))	=	LTRIM(RTRIM(S.id_sucursal))
	AND S.id_empresa	=	'BHERMANOS'
LEFT JOIN COSTOS_APLI	CA
	ON	MID.articulo	=	CA.articulo
LEFT JOIN ARTICULOS(NOLOCK) A
	ON	MID.articulo	=	A.ARTICULO
LEFT JOIN FAMILIAS_LEO(NOLOCK) F
	ON	A.familia	=	F.familia
LEFT JOIN guiaembarquedet	GED
	ON	MI.movimiento	=	GED.movimiento_tra
LEFT JOIN GUIAEMBARQUE	GEE
	ON	GED.movimiento	=	GEE.movimiento

WHERE
mi.id_sucursal=	'ADIC_ROI'
AND mi.tipo	=	'traenv'
AND MI.ESTATUS<>'CANCELADO'
AND MI.id_sucursal1 NOT IN(
'CEDIS LEON','CEDIS LEON2'

)
AND A.MARCA<>'JAVAS'
)
,
TOTAL_CANT_MOVTOS	AS(
	SELECT
	MOVIMIENTO,
	SUM(CANTIDAD) CANT_TOTAL_MOVTO
	FROM
	MOVTOSINVENTDET(NOLOCK)

	WHERE
	MOVIMIENTO IN(
	SELECT DISTINCT MOVIMIENTO FROM MOVTOS_ROI
	)
	GROUP BY
	MOVIMIENTO
)


SELECT 
ROI.movimiento, folio, fecha, fecbultos, estatus, destino, plaza_dest, AgrupRubro, Nom_Depto,
sum(cantidad) cantidad_env, sum(TotalCosto) costo_env,
DiasEnBodega,
ISNULL(TRANSPORTE, 'SIN TRANSPORTE') Transporte,
CASE WHEN
TRANSPORTE	IS NULL	THEN	'SIN ENVIO'
ELSE	TIPO_ENVIO
END	TipoEnvio,
CASE
WHEN	estatus	=	'actualizad'	and	fecbultos		=	0	THEN	0
ELSE	1
END Incluir_Antiguedad,

CASE
    WHEN estatus = 'Bodega' AND DiasEnBodega > 7 THEN 'VENCIDA'
	WHEN estatus = 'Bodega' AND DiasEnBodega BETWEEN 4 AND 7 THEN '4 A 7 DÍAS'
	WHEN estatus = 'Bodega' THEN '1 A 3 DÍAS'
    WHEN estatus = 'Actualizad' AND DiasEnBodega IS NULL THEN 'SIN FECHA DE BULTO'
    WHEN estatus = 'Actualizad' AND DiasEnBodega > 7 THEN 'SALIO DESPUES DE 7 DIAS'
    WHEN estatus = 'Actualizad' THEN 'SALIO EN 7 DIAS O MENOS'
    ELSE 'REVISAR ESTATUS'
END AS Clasificacion,

CASE
WHEN	TM.CANT_TOTAL_MOVTO	BETWEEN	0	AND	3	THEN	'1 A 3 ARTS'
WHEN	TM.CANT_TOTAL_MOVTO	BETWEEN	4	AND	6	THEN	'4 A 6 ARTS'
WHEN	TM.CANT_TOTAL_MOVTO	BETWEEN	7	AND	11	THEN	'7 A 11 ARTS'
ELSE	'12 O MÁS ARTS'
END ClasificacionCantidad
FROM
MOVTOS_ROI ROI
LEFT JOIN TOTAL_CANT_MOVTOS TM
	ON	ROI.movimiento	=	TM.MOVIMIENTO

GROUP BY
ROI.movimiento, folio, fecha, fecbultos, estatus, destino, plaza_dest, 
transporte, DiasEnBodega, TIPO_ENVIO, AgrupRubro, CANT_TOTAL_MOVTO, Nom_Depto

ORDER BY
MOVIMIENTO;
USE VISCOI;

DECLARE @Hasta date = '20261123'; -- Exclusivo: incluye todo el 22/nov.

WITH Solicitud AS (
    SELECT
        h.folio AS folio_pick,
		ltrim(rtrim(h.sucursal_destino)) AS destino,
        h.articulo,
        h.pack,
        h.rubro,
        h.fecha,
        h.estatus,
        h.cantidad,
        h.leido,
        h.fecha_fin
    FROM Distribuciones_Mcia_Picking AS h
    WHERE h.sucursal_origen = 'ADIC_ROI'
      AND h.fecha < @Hasta
      AND NOT EXISTS (
          SELECT 1
          FROM ARTICULOS AS a
          WHERE a.articulo = h.articulo AND a.marca = 'JAVAS'
      )
),
DetallePick AS (
    SELECT
        d.movimiento,
        LTRIM(RTRIM(D.destino)) AS destino,
        d.articulo,
        SUM(CASE WHEN h.estatus <> 'Cancelado'
                 THEN d.cantidad ELSE 0 END) AS picking_detalle,
        SUM(CASE WHEN h.estatus = 'Cancelado'
                 THEN d.cantidad ELSE 0 END) AS picking_cancelado,
        COUNT(DISTINCT d.folio_dist) AS folios_pick
    FROM Distribuciones_Mcia_PickingDet AS d
    INNER JOIN Solicitud AS h
        ON h.folio_pick = d.folio_dist
       AND h.destino = LTRIM(RTRIM(d.destino))
       AND h.articulo = d.articulo
       AND h.pack = d.pack
    WHERE d.origen = 'ADIC_ROI'
      AND d.fum < @Hasta
    GROUP BY d.movimiento, LTRIM(RTRIM(d.destino)), d.articulo
),
Transferencia AS (
    SELECT
        m.movimiento,
        LTRIM(RTRIM(m.id_sucursal1)) AS destino,
        md.articulo,
        m.fecha,
        m.fecbultos,
        m.estatus,
        SUM(md.cantidad) AS piezas_transferencia
    FROM MOVTOSINVENT AS m
    INNER JOIN MOVTOSINVENTDET AS md
        ON md.movimiento = m.movimiento
    WHERE m.id_sucursal = 'ADIC_ROI'
      AND m.tipo = 'TRAENV'
      AND LTRIM(RTRIM(m.id_sucursal1)) NOT IN ('CEDIS LEON', 'CEDIS LEON2')
      AND (
          m.fecha < @Hasta
          OR (m.fecbultos > '19000101' AND m.fecbultos < @Hasta)
      )
      AND NOT EXISTS (
          SELECT 1
          FROM ARTICULOS AS a
          WHERE a.articulo = md.articulo AND a.marca = 'JAVAS'
      )
    GROUP BY m.movimiento, LTRIM(RTRIM(m.id_sucursal1)), md.articulo,
             m.fecha, m.fecbultos, m.estatus
)
SELECT
    'SOLICITUD' AS tipo_fila,
    h.folio_pick,
    NULL AS movimiento,
    h.destino,
    h.articulo,
    h.pack,
    h.rubro,
    h.fecha AS fecha_solicitud,
    h.fecha_fin AS fecha_fin_picking,
    h.estatus AS estatus_picking_actual,
    h.cantidad AS solicitado,
    h.leido AS leido_actual,
    NULL AS folios_pick_en_movimiento_sku,
    NULL AS picking_detalle,
    NULL AS picking_cancelado,
    NULL AS fecha_movimiento,
    NULL AS fecha_bulto,
    NULL AS estatus_movimiento_actual,
    NULL AS piezas_transferencia,
    NULL AS salida_registrada_al_corte,
    NULL AS resultado_cruce
FROM Solicitud AS h

UNION ALL

SELECT
    'MOVIMIENTO_SKU',
    NULL,
    COALESCE(d.movimiento, t.movimiento),
    COALESCE(d.destino, t.destino),
    COALESCE(d.articulo, t.articulo),
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    d.folios_pick,
    d.picking_detalle,
    d.picking_cancelado,
    t.fecha,
    NULLIF(t.fecbultos, '19000101'),
    t.estatus,
    t.piezas_transferencia,
    CASE
        WHEN t.estatus = 'Actualizad' AND t.fecha < @Hasta
            THEN t.piezas_transferencia
        WHEN t.movimiento IS NOT NULL THEN 0
    END,
    CASE
        WHEN d.folios_pick IS NULL THEN 'TRANSFERENCIA SIN DETALLE PICKING'
        WHEN d.movimiento IS NULL THEN 'PICKING SIN MOVIMIENTO'
        WHEN t.movimiento IS NULL THEN 'SIN CRUCE POR MOVIMIENTO DESTINO SKU'
        WHEN d.picking_detalle + d.picking_cancelado <> t.piezas_transferencia
            THEN 'DIFERENCIA DE CANTIDAD'
        ELSE 'COINCIDE'
    END
FROM DetallePick AS d
FULL OUTER JOIN Transferencia AS t
    ON t.movimiento = d.movimiento
   AND t.destino = d.destino
   AND t.articulo = d.articulo;
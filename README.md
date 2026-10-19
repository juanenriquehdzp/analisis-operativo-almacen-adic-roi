# Análisis operativo del almacén ADIC_ROI

Diagnóstico del almacenamiento y del flujo de mercancía de un almacén de resurtido creado como parte de la implementación de un sistema de planeación de demanda en CEDIS León, Grupo Batta.

El proyecto combina consultas en SQL Server, análisis en Excel, entrevistas operativas y revisión física para identificar oportunidades de mejora y presentar los hallazgos a Operaciones CEDIS y Compras.

## Contexto del negocio

La compañía adquirió un sistema de planeación de demanda con el objetivo de reducir pedidos no atendidos y sobreinventario en sucursales. Para implementar el sistema por etapas, creó el almacén lógico **ADIC_ROI**, cuya existencia sirve como base para generar pedidos sugeridos de resurtido a tiendas.

Su operación contempla dos solicitudes distintas:

1. **Transferencia de CEDIS León a ADIC_ROI:** incorpora mercancía al inventario disponible para resurtido.
2. **Picking de ADIC_ROI a sucursales:** solicita la preparación de mercancía por destino y genera las cajas de salida.

Durante la revisión inicial se observaron espacios de resguardo compartidos con otros almacenes y preparación de cajas por rubro. Esto motivó el análisis de la acumulación de mercancía, las cajas con pocas piezas y la permanencia de cajas pendientes de envío.

## Objetivo

Evaluar la operación inicial de ADIC_ROI e identificar oportunidades para mejorar el resguardo, la preparación y el despacho de mercancía, con evidencia que permita acordar acciones entre Operaciones y Compras.

Las principales preguntas fueron:

- ¿Cómo evolucionan las entradas, las salidas y las existencias?
- ¿Qué rubros y estilos concentran el inventario pendiente de envío?
- ¿Las tallas extremas presentan menor porcentaje de salida que las intermedias?
- ¿Qué proporción de cajas contiene de uno a tres artículos?
- ¿Existen cajas que salen al mismo destino, en el mismo camión y fecha, con oportunidad de consolidación?
- ¿Qué cajas superan los siete días pendientes de envío y cuáles permanecen entre cortes?

## Alcance y fuentes

El análisis comprende la operación iniciada en julio de 2026, con actualizaciones hasta octubre. Los cortes varían según la fuente: existencias al **11 de octubre** y antigüedad de cajas al **12 de octubre de 2026**.

| Fuente | Uso en el análisis |
| --- | --- |
| `MOVTOSINVENT` y `MOVTOSINVENTDET` | Identificación de cajas, cantidades, destinos, estatus y fechas de operación. |
| `EXISTENCIASDET` | Reconstrucción de entradas, salidas y saldos semanales. |
| Catálogos de artículos, familias y sucursales | Clasificación por rubro, marca, estilo, talla y destino. |
| Registros de transporte y embarque | Agrupación de cajas enviadas juntas. |
| Auditoría física y bitácoras de sucursales | Contraste del contenido de cajas y seguimiento de incidencias. |

Las bases operativas completas quedan fuera del alcance público del repositorio.

## Herramientas

- **SQL Server / T-SQL:** extracción, clasificación, agregaciones y acumulación de movimientos mediante CTE y funciones de ventana.
- **Excel:** exploración, tablas dinámicas y comparación de resultados.
- **PowerPoint:** comunicación del diagnóstico y de las propuestas operativas.
- **Git y GitHub:** control de versiones y documentación del proyecto.

## Metodología

1. **Levantamiento operativo.** Entrevistas y recorridos para comprender las solicitudes de transferencia, picking, resguardo y despacho.
2. **Preparación de datos.** Integración de movimientos con sus detalles y catálogos. Exclusión de JAVAS por tratarse de material de embalaje y conservación de artículos depurados para mantener su historia.
3. **Evolución de inventario.** Reconstrucción del saldo inicial y de los movimientos semanales, mostrando entradas y salidas por separado para evitar que el neteo oculte actividad.
4. **Análisis por estilo y talla.** Comparación de cantidades recibidas, enviadas y pendientes. El porcentaje de salida se calcula como salidas de transferencia divididas entre la suma del saldo inicial y las entradas.
5. **Análisis de cajas.** Identificación de cada caja por movimiento, clasificación por cantidad de artículos y revisión de su permanencia según estatus.
6. **Consolidación y seguimiento.** Agrupación por destino, camión INTER y fecha de salida. Exclusión de paquetería y cajas con bocinas, climas o pantallas. Comparación de cajas vencidas entre cortes utilizando el identificador de movimiento.

## Principales resultados

### Inventario y resurtido

La existencia aumentó durante el periodo, con diferencias entre rubros y estilos en su porcentaje de salida. Este crecimiento debe interpretarse considerando que parte de la mercancía se reserva en ADIC_ROI para resurtir el sembrado inicial realizado en tiendas.

Por ello, la permanencia de mercancía requiere parámetros acordados con Compras, considerando ventas, cobertura y ciclo de resurtido. Un saldo elevado o una entrada reciente no bastan para clasificar un estilo como inmóvil.

### Comportamiento por talla

La comparación de entradas y salidas **no mostró una retención generalizada de tallas extremas**. La acumulación varía por estilo y talla, por lo que el seguimiento debe realizarse con ese nivel de detalle.

En ropa se distinguieron las tallas numéricas de partes bajas (pantalones y shorts) de las tallas CH, M, G y EG de partes altas.

### Cajas con pocas piezas y consolidación

De acuerdo con la clasificación del archivo de análisis, **69.42% de las cajas creadas contenía de uno a tres artículos**. El universo incluye cajas enviadas y pendientes en Bodega.

Se identificaron grupos de cajas que salieron al mismo destino, en el mismo camión y fecha, con oportunidad de consolidación. La viabilidad depende de la capacidad de la caja y de la compatibilidad de los productos. No se cuantificaron ahorros de embalaje, manejo o transporte.

### Cajas pendientes de envío

Se detectaron cajas armadas con más de siete días pendientes de salida y se compararon sus movimientos entre cortes para distinguir las enviadas, las que continúan en Bodega y las que requieren aclaración.

El objetivo operativo de **siete días aplica a cajas armadas pendientes de despacho**. Es distinto del plazo de permanencia de mercancía disponible para resurtido.

### Revisión física e incidencias

En la muestra ampliada informada por Auditoría se reportaron **dos cajas con diferencias de talla entre 508 revisadas**. Este resultado describe la muestra y no se extrapola a toda la operación.

También se reportaron **39 incidencias de sobrantes y faltantes en sucursales**, pendientes de validación documental. Estos reportes no permiten atribuir causas o responsabilidades sin investigación adicional.

## Propuestas y avances

| Tema | Propuesta o avance |
| --- | --- |
| Calendario de transferencias | Acordar un corte común para incorporar inventario al cálculo y registrar las excepciones. |
| Preparación de pedidos | Consolidar el picking por tienda y reunir los rubros antes del cierre de caja. |
| Resguardo | Operaciones realizó la ubicación de Ropa y Calzado. Continuar la validación de identificación, separación y capacidad, así como el seguimiento de los demás rubros. |
| Cajas con antigüedad mayor a siete días | Localizar y conciliar los movimientos pendientes con los registros de armado, aduana y embarque. |
| Permanencia de mercancía | Definir con Compras los parámetros de antigüedad y revisión según el ciclo de resurtido. |
| Inventario sin resurtido | Acordar destino, responsable y fecha de acción para los estilos que no generan la demanda esperada. |

## Limitaciones

- Las salidas desde ADIC_ROI representan despachos, no ventas al consumidor final.
- El porcentaje de salida no equivale a una medida formal de rotación de inventario.
- La primera entrada de un estilo no representa necesariamente la edad de todas las unidades restantes si hubo ingresos posteriores.
- Los movimientos agregados permiten analizar permanencia, pero no demostrar el cumplimiento físico de PEPS por lote.
- Las posibles causas de cajas pendientes y las incidencias reportadas por tiendas requieren validación.
- El saldo por talla requiere mantener esa granularidad en las agrupaciones y acumulaciones, evitando mezclar tallas distintas.

## Contenido del repositorio

| Ruta | Contenido |
| --- | --- |
| `Queries/` | Consultas SQL utilizadas en el análisis. |
| `Informes/` | Informe ejecutivo seleccionado para publicación. |
| `README.md` | Contexto, metodología, resultados y alcance del proyecto. |
| `.gitignore` | Exclusión de bases operativas, borradores y archivos temporales. |

[Consultar el informe ejecutivo](Informes/Diagnostico_ADIC_ROI_Compras_V3.pdf)

## Uso de las consultas

Las consultas requieren acceso a una base de SQL Server con las tablas y catálogos indicados. No se incluye una base de demostración, por lo que el repositorio documenta el análisis y su lógica, pero no puede ejecutarse de forma independiente.

Antes de ejecutarlas en un entorno autorizado, revisar las fechas de inicio y corte, los identificadores de almacén, los filtros y los nombres de los objetos de base de datos. Mantener documentados los parámetros utilizados para poder comparar los resultados entre cortes.

## Autor

**Juan Enrique Hernández**  
Auditoría e Inventarios. Proyecto de análisis aplicado a operaciones de distribución y resurtido.

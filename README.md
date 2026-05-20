
# Diagnóstico de calidad (versión simple)

Este README explica rápido qué encontramos en `data.csv` y qué proponemos hacer para dejar los datos listos para análisis.

"El grano de nuestro análisis es la línea de detalle de cada producto vendido por factura"

## Qué vimos (problemas principales)
- El archivo es un CSV plano que mezcla clientes, productos y ventas en la misma tabla.
- Hay líneas de venta y líneas de ajuste (descuentos, envíos, notas de crédito) mezcladas.
- `CustomerID` viene muchas veces vacío, así que no sirve como clave limpia.
- Las fechas vienen como texto con formato día/mes (p. ej. `12/1/2010 8:26`) y hay que convertirlas.

## Campos con problemas concretos
- `CustomerID`: muchos valores nulos/ausentes.
- `Quantity`: aparecen negativos (devoluciones) y algunos valores raros (`-1` en ajustes).
- `UnitPrice`: ceros o valores inesperados en líneas de ajuste o envío.
- `InvoiceDate`: texto; hay que parsearlo con `dayfirst=True` y convertir a `TIMESTAMP`.
- `Description`: algunas descripciones vacías o genéricas (`Discount`, `POST`).
- `InvoiceNo`: los que empiezan con `C` son notas de crédito (devoluciones).
- `StockCode`: tiene valores no estándar (por ejemplo `POST`, `D`, `Discount`).

## Por qué nos importa (impacto)
- Si usamos `CustomerID` sin limpiar, los joins con la dimensión cliente fallarán.
- Las cantidades negativas y precios cero distorsionan ingresos y unidades vendidas.
- Sin fechas normalizadas no podemos agrupar por día/mes correctamente.
- Las líneas de ajuste pueden cambiar los totales si no las gestionamos bien.

## Qué recomendamos (rápido)
- Declarar el grano: cada fila = un producto en una factura.
- Mantener devoluciones (Quantity < 0) pero etiquetarlas y acordar la política con negocio.
- Mapear `CustomerID` nulo a `-1` y crear un cliente `Cliente No Registrado` en `dim_clientes`.
- Parsear `InvoiceDate` con `dayfirst=True` y guardarlo como `TIMESTAMP` en `dim_fecha`.
- Limpiar `Description` con `TRIM()` y `UPPER()`; clasificar `StockCode` especial (`POST`, `Discount`).
- Crear claves subrogadas: `cliente_sk`, `producto_sk`, `fecha_sk` (usar `SERIAL`/`BIGSERIAL`).
- En `fact_ventas` calcular `monto_total_calculado = Quantity * UnitPrice`.

## Siguientes pasos prácticos
1. Hacer un script (Python + pandas) que: cargue el CSV, parsee fechas (`dayfirst=True`), etiquete devoluciones, calcule montos y exporte `clean.csv`.
2. Diseñar el modelo en estrella y exportar `design/diagrama_estrella.png`.
3. Crear la matriz de mapeo en `design/matriz_mapeo.xlsx`.
4. Escribir el DDL para Postgres en `sql/01_create_dw_schema.sql`.

## Referencia
- Archivo origen: `Extracci-n_de_Conocimiento_de_Base_de_Datos/archive/data.csv`

---

Versión corta y más directa del diagnóstico.

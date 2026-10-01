-- ============================================================
-- PROYECTO CAPSTONE: ANALISIS EXPLORATORIO DE DATOS EN POSTGRESQL
-- Archivo: analisis.sql
-- Base de datos: capstone_project
-- ============================================================

-- ============================================================
-- 0. CONTROL DE CALIDAD Y LIMPIEZA
-- ============================================================

-- Revisamos nulos en columnas importantes antes de analizar.
SELECT
    SUM(CASE WHEN ciudad IS NULL THEN 1 ELSE 0 END) AS ciudades_nulas
FROM clientes;

SELECT
    SUM(CASE WHEN descuento IS NULL THEN 1 ELSE 0 END) AS descuentos_nulos,
    SUM(CASE WHEN precio_unitario IS NULL THEN 1 ELSE 0 END) AS precios_nulos,
    SUM(CASE WHEN fecha_pedido IS NULL THEN 1 ELSE 0 END) AS fechas_nulas
FROM pedidos;

-- La ciudad faltante se presenta como "Sin informar" para no perder
-- el registro del cliente en futuras consultas.
SELECT
    cliente_id,
    nombre,
    COALESCE(ciudad, 'Sin informar') AS ciudad_limpia
FROM clientes
ORDER BY cliente_id;

-- Un descuento NULL significa que no hubo descuento.
-- COALESCE evita que los calculos monetarios devuelvan NULL.
SELECT
    pedido_id,
    descuento,
    COALESCE(descuento, 0) AS descuento_limpio
FROM pedidos
ORDER BY pedido_id;

-- Se controla que no existan clientes duplicados por email.
SELECT
    email,
    COUNT(*) AS cantidad
FROM clientes
GROUP BY email
HAVING COUNT(*) > 1;

-- ============================================================
-- ANALISIS 1: TOP 5 CLIENTES POR GASTO TOTAL
-- Pregunta: ¿Cuales son los clientes que mas dinero generaron?
-- ============================================================

SELECT
    c.cliente_id,
    c.nombre AS cliente,
    ROUND(
        SUM(
            p.cantidad * p.precio_unitario *
            (1 - COALESCE(p.descuento, 0) / 100)
        ),
        2
    ) AS gasto_total
FROM pedidos p
JOIN clientes c
    ON p.cliente_id = c.cliente_id
WHERE p.estado = 'Entregado'
GROUP BY
    c.cliente_id,
    c.nombre
ORDER BY gasto_total DESC
LIMIT 5;

-- ============================================================
-- ANALISIS 2: VENTAS TOTALES POR MES
-- Pregunta: ¿Como evolucionaron las ventas durante 2026?
-- ============================================================

SELECT
    DATE_TRUNC('month', p.fecha_pedido)::DATE AS mes,
    COUNT(*) AS cantidad_pedidos,
    SUM(p.cantidad) AS unidades_vendidas,
    ROUND(
        SUM(
            p.cantidad * p.precio_unitario *
            (1 - COALESCE(p.descuento, 0) / 100)
        ),
        2
    ) AS ventas_totales
FROM pedidos p
WHERE p.estado = 'Entregado'
GROUP BY DATE_TRUNC('month', p.fecha_pedido)
ORDER BY mes;

-- ============================================================
-- ANALISIS 3: 3 PRODUCTOS MENOS VENDIDOS
-- Pregunta: ¿Que productos presentan menor rotacion?
-- ============================================================
-- Se agrega producto_id como criterio de desempate para que el
-- resultado sea reproducible cuando hay productos con igual venta.

SELECT
    pr.producto_id,
    pr.nombre AS producto,
    pr.categoria,
    COALESCE(SUM(p.cantidad), 0) AS unidades_vendidas
FROM productos pr
LEFT JOIN pedidos p
    ON pr.producto_id = p.producto_id
    AND p.estado = 'Entregado'
GROUP BY
    pr.producto_id,
    pr.nombre,
    pr.categoria
ORDER BY
    unidades_vendidas ASC,
    pr.producto_id ASC
LIMIT 3;

-- ============================================================
-- ANALISIS 4: RANKING DE PEDIDOS POR CATEGORIA
-- Pregunta: ¿Cuales son los pedidos de mayor valor dentro de
-- cada categoria de producto?
-- ============================================================
-- RANK() permite comparar cada pedido contra otros de su misma
-- categoria sin perder el detalle de cada operacion.

WITH detalle_pedidos AS (
    SELECT
        p.pedido_id,
        c.nombre AS cliente,
        pr.nombre AS producto,
        pr.categoria,
        p.fecha_pedido,
        ROUND(
            p.cantidad * p.precio_unitario *
            (1 - COALESCE(p.descuento, 0) / 100),
            2
        ) AS total_pedido
    FROM pedidos p
    JOIN clientes c
        ON p.cliente_id = c.cliente_id
    JOIN productos pr
        ON p.producto_id = pr.producto_id
    WHERE p.estado = 'Entregado'
)

SELECT
    pedido_id,
    cliente,
    producto,
    categoria,
    fecha_pedido,
    total_pedido,
    RANK() OVER (
        PARTITION BY categoria
        ORDER BY total_pedido DESC
    ) AS ranking_categoria
FROM detalle_pedidos
ORDER BY
    categoria,
    ranking_categoria,
    pedido_id;

-- ============================================================
-- ANALISIS 5: SEGMENTACION DE CLIENTES POR GASTO
-- Pregunta: ¿Como se puede segmentar la cartera de clientes
-- de acuerdo con su valor economico?
-- ============================================================
-- CASE transforma una medida numerica en segmentos faciles de
-- interpretar para una decision comercial.

SELECT
    c.cliente_id,
    c.nombre AS cliente,
    ROUND(
        SUM(
            p.cantidad * p.precio_unitario *
            (1 - COALESCE(p.descuento, 0) / 100)
        ),
        2
    ) AS gasto_total,
    CASE
        WHEN SUM(
            p.cantidad * p.precio_unitario *
            (1 - COALESCE(p.descuento, 0) / 100)
        ) >= 700000 THEN 'Cliente de alto valor'
        WHEN SUM(
            p.cantidad * p.precio_unitario *
            (1 - COALESCE(p.descuento, 0) / 100)
        ) >= 300000 THEN 'Cliente de valor medio'
        ELSE 'Cliente de bajo valor'
    END AS segmento
FROM clientes c
JOIN pedidos p
    ON c.cliente_id = p.cliente_id
WHERE p.estado = 'Entregado'
GROUP BY
    c.cliente_id,
    c.nombre
ORDER BY gasto_total DESC;

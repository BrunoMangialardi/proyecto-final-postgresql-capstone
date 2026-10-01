# Proyecto Capstone: Análisis Exploratorio de Datos en PostgreSQL

## Descripción

Este proyecto simula el flujo de trabajo de un analista de datos sobre un pequeño e-commerce.  
El objetivo es construir una base de datos relacional en PostgreSQL, revisar la calidad de los datos y responder preguntas de negocio mediante consultas SQL.

El conjunto de datos fue creado específicamente para este proyecto y contiene tres tablas relacionadas:

- `clientes`
- `productos`
- `pedidos`

La base de datos utilizada se llama `capstone_project`.

## Problema de negocio

El e-commerce necesita entender mejor el comportamiento de sus ventas y clientes. El análisis busca responder preguntas como:

1. ¿Cuáles son los 5 clientes con mayor gasto total?
2. ¿Cómo evolucionaron las ventas por mes?
3. ¿Cuáles son los 3 productos menos vendidos?
4. ¿Qué pedidos tienen mayor valor dentro de cada categoría?
5. ¿Cómo pueden segmentarse los clientes según su gasto?

## Estructura de la base de datos

### Tabla `clientes`

Contiene información básica de cada cliente:

- `cliente_id`
- `nombre`
- `email`
- `ciudad`
- `fecha_registro`

### Tabla `productos`

Contiene el catálogo de productos:

- `producto_id`
- `nombre`
- `categoria`
- `precio`
- `stock`

### Tabla `pedidos`

Registra las operaciones de venta:

- `pedido_id`
- `cliente_id`
- `producto_id`
- `fecha_pedido`
- `cantidad`
- `precio_unitario`
- `descuento`
- `estado`

`cliente_id` y `producto_id` funcionan como claves foráneas y permiten conectar los pedidos con clientes y productos.

## Limpieza y control de calidad

Antes del análisis se revisaron valores nulos y duplicados.

Se detectó:

- 1 cliente con ciudad sin informar.
- 17 pedidos con descuento `NULL`.
- 0 valores nulos en `precio_unitario`.
- 0 valores nulos en `fecha_pedido`.
- No se detectaron emails duplicados.

Los descuentos nulos representan operaciones sin descuento, por lo que se utiliza:

```sql
COALESCE(descuento, 0)
```

De esta forma los cálculos de ventas no quedan afectados por valores `NULL`.

En el caso de la ciudad faltante, se utiliza `COALESCE(ciudad, 'Sin informar')` para conservar el registro sin inventar una ubicación.

## Análisis realizados

### 1. Top 5 clientes por gasto total

La consulta utiliza `JOIN`, `GROUP BY`, `SUM`, `COALESCE`, `ORDER BY` y `LIMIT`.

Resultados principales:

| Cliente | Gasto total |
| --- | ---: |
| Ana Gómez | $1.041.250 |
| Camila Sánchez | $866.750 |
| Sofía Martínez | $455.000 |
| Mateo Rodríguez | $422.500 |
| Lucas Fernández | $373.000 |

**Interpretación:** Ana Gómez y Camila Sánchez concentran los mayores niveles de gasto del conjunto analizado. Esto permite identificar clientes de alto valor para acciones de fidelización o beneficios específicos.

### 2. Ventas totales por mes

Se utiliza `DATE_TRUNC()` para agrupar las operaciones por mes.

| Mes | Pedidos | Unidades | Ventas |
| --- | ---: | ---: | ---: |
| Enero | 3 | 4 | $966.250 |
| Febrero | 4 | 5 | $493.000 |
| Marzo | 4 | 6 | $424.500 |
| Abril | 4 | 5 | $981.750 |
| Mayo | 4 | 6 | $463.000 |
| Junio | 4 | 5 | $602.500 |
| Julio | 4 | 7 | $339.750 |
| Agosto | 3 | 4 | $220.000 |

**Interpretación:** abril presenta la mayor facturación del período, con $981.750, seguido de enero con $966.250. Agosto registra el menor valor, aunque el tamaño reducido y simulado del dataset no permite afirmar que exista una tendencia estacional.

### 3. Productos menos vendidos

Se utiliza `LEFT JOIN` para conservar también productos que eventualmente pudieran no registrar ventas.

El producto con menor rotación es `Escritorio Oficina`, con 1 unidad. Varios productos empatan luego con 2 unidades; por ese motivo la consulta utiliza `producto_id` como criterio de desempate para devolver exactamente tres registros.

**Interpretación:** los productos con baja rotación podrían revisarse desde el punto de vista de precio, promoción o nivel de stock antes de tomar decisiones comerciales.

### 4. Ranking de pedidos por categoría

Se utiliza `RANK()` como función de ventana y `PARTITION BY categoria` para comparar cada pedido únicamente con otros de la misma categoría.

Los pedidos de mayor valor dentro de cada categoría son:

- Accesorios: pedido 19, Mochila Urbana, $99.000.
- Audio: pedido 25, Auriculares Bluetooth, $135.000.
- Hogar: pedido 27, Lámpara LED, $99.750.
- Muebles: pedido 4, Silla Ergonómica, $250.000.
- Tecnología: pedido 1, Notebook Lenovo, $850.000.

**Interpretación:** el ranking permite detectar qué operaciones aportaron mayor valor dentro de cada línea de producto sin mezclar categorías con escalas de precio diferentes.

### 5. Segmentación de clientes por gasto

Se utiliza `CASE` para clasificar clientes en tres grupos:

- Alto valor: gasto igual o superior a $700.000.
- Valor medio: gasto entre $300.000 y $699.999.
- Bajo valor: gasto inferior a $300.000.

**Interpretación:** esta segmentación convierte el gasto acumulado en grupos de negocio fáciles de utilizar para campañas diferenciadas, fidelización o seguimiento comercial.

## Hallazgos generales

En las 30 operaciones registradas se vendieron 42 unidades por una facturación total de **$4.490.750** después de descuentos.

Los principales hallazgos son:

- Dos clientes superan los $700.000 de gasto acumulado.
- Abril es el mes con mayor facturación del conjunto analizado.
- Existen productos con baja rotación que podrían requerir revisión comercial.
- Las funciones de ventana permiten comparar operaciones dentro de categorías sin perder el detalle individual.
- La gestión de valores nulos mediante `COALESCE` evita errores en los cálculos monetarios.

## Conclusión

El proyecto muestra cómo una base de datos relacional puede transformar registros de clientes, productos y pedidos en información útil para la toma de decisiones.

A través de PostgreSQL se aplicaron relaciones entre tablas, agregaciones, funciones de fecha, tratamiento de valores nulos, expresiones condicionales y funciones de ventana. Los resultados permiten identificar clientes relevantes, observar la evolución de las ventas, detectar productos con menor rotación y comparar operaciones dentro de cada categoría.

Debido a que se trata de un conjunto de datos pequeño y simulado, los hallazgos deben interpretarse como una demostración del proceso analítico y no como conclusiones generalizables a un negocio real.

## Cómo ejecutar el proyecto

1. Abrir PostgreSQL mediante pgAdmin.
2. Crear una base de datos llamada `capstone_project`.
3. Abrir el **Query Tool** conectado a `capstone_project`.
4. Ejecutar primero `estructura.sql`.
5. Ejecutar después `analisis.sql`.
6. Revisar los resultados de las consultas en el panel de resultados.

## Archivos del repositorio

```text
estructura.sql
analisis.sql
README.md
```

- `estructura.sql`: crea las tablas y carga los datos.
- `analisis.sql`: realiza limpieza, validaciones y consultas de negocio.
- `README.md`: documenta el problema, los hallazgos y la forma de ejecutar el proyecto.

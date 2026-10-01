-- ============================================================
-- PROYECTO CAPSTONE: ANALISIS EXPLORATORIO DE DATOS EN POSTGRESQL
-- Archivo: estructura.sql
-- Base de datos: capstone_project
-- ============================================================
-- IMPORTANTE:
-- Ejecutar este script dentro de la base de datos capstone_project.
-- El script elimina las tablas si ya existen para poder ejecutarse
-- nuevamente sin duplicar registros.
-- ============================================================

DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

-- ============================================================
-- 1. CREACION DE TABLAS
-- ============================================================

CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    ciudad VARCHAR(80),
    fecha_registro DATE NOT NULL
);

CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(80) NOT NULL,
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    stock INTEGER NOT NULL CHECK (stock >= 0)
);

CREATE TABLE pedidos (
    pedido_id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    producto_id INTEGER NOT NULL,
    fecha_pedido DATE NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),
    descuento NUMERIC(5,2) CHECK (descuento BETWEEN 0 AND 100),
    estado VARCHAR(30) NOT NULL,

    CONSTRAINT fk_pedidos_clientes
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(cliente_id),

    CONSTRAINT fk_pedidos_productos
        FOREIGN KEY (producto_id)
        REFERENCES productos(producto_id)
);

-- ============================================================
-- 2. CARGA DE DATOS: CLIENTES
-- ============================================================
-- Se deja una ciudad en NULL de forma intencional para demostrar
-- luego la deteccion y gestion de valores faltantes.

INSERT INTO clientes (nombre, email, ciudad, fecha_registro)
VALUES
('Ana Gómez', 'ana.gomez@email.com', 'Rosario', '2026-01-10'),
('Lucas Fernández', 'lucas.fernandez@email.com', 'Buenos Aires', '2026-01-15'),
('Sofía Martínez', 'sofia.martinez@email.com', 'Córdoba', '2026-02-03'),
('Mateo Rodríguez', 'mateo.rodriguez@email.com', 'Santa Fe', '2026-02-20'),
('Valentina López', 'valentina.lopez@email.com', 'Mendoza', '2026-03-02'),
('Tomás García', 'tomas.garcia@email.com', 'Rosario', '2026-03-18'),
('Camila Sánchez', 'camila.sanchez@email.com', 'Buenos Aires', '2026-04-05'),
('Joaquín Pérez', 'joaquin.perez@email.com', 'Córdoba', '2026-04-22'),
('Martina Romero', 'martina.romero@email.com', 'Santa Fe', '2026-05-11'),
('Benjamín Díaz', 'benjamin.diaz@email.com', NULL, '2026-05-29');

-- ============================================================
-- 3. CARGA DE DATOS: PRODUCTOS
-- ============================================================

INSERT INTO productos (nombre, categoria, precio, stock)
VALUES
('Notebook Lenovo', 'Tecnología', 850000.00, 15),
('Mouse Logitech', 'Tecnología', 25000.00, 50),
('Teclado Mecánico', 'Tecnología', 65000.00, 30),
('Monitor Samsung 24', 'Tecnología', 220000.00, 20),
('Auriculares Bluetooth', 'Audio', 75000.00, 35),
('Parlante JBL', 'Audio', 120000.00, 25),
('Escritorio Oficina', 'Muebles', 180000.00, 10),
('Silla Ergonómica', 'Muebles', 250000.00, 12),
('Lámpara LED', 'Hogar', 35000.00, 40),
('Cafetera Eléctrica', 'Hogar', 95000.00, 18),
('Mochila Urbana', 'Accesorios', 55000.00, 45),
('Soporte Notebook', 'Accesorios', 40000.00, 30);

-- ============================================================
-- 4. CARGA DE DATOS: PEDIDOS
-- ============================================================
-- Los descuentos NULL representan pedidos en los que no se
-- aplico descuento. Luego se gestionan con COALESCE.

INSERT INTO pedidos
(cliente_id, producto_id, fecha_pedido, cantidad, precio_unitario, descuento, estado)
VALUES
-- ENERO
(1, 1, '2026-01-20', 1, 850000.00, NULL, 'Entregado'),
(2, 2, '2026-01-25', 2, 25000.00, 10.00, 'Entregado'),
(1, 5, '2026-01-28', 1, 75000.00, 5.00, 'Entregado'),

-- FEBRERO
(3, 8, '2026-02-08', 1, 250000.00, NULL, 'Entregado'),
(4, 3, '2026-02-14', 1, 65000.00, NULL, 'Entregado'),
(2, 6, '2026-02-22', 1, 120000.00, 10.00, 'Entregado'),
(3, 9, '2026-02-27', 2, 35000.00, NULL, 'Entregado'),

-- MARZO
(5, 4, '2026-03-06', 1, 220000.00, 5.00, 'Entregado'),
(6, 2, '2026-03-20', 3, 25000.00, NULL, 'Entregado'),
(1, 11, '2026-03-24', 1, 55000.00, NULL, 'Entregado'),
(5, 10, '2026-03-30', 1, 95000.00, 10.00, 'Entregado'),

-- ABRIL
(7, 1, '2026-04-09', 1, 850000.00, 10.00, 'Entregado'),
(8, 12, '2026-04-15', 2, 40000.00, NULL, 'Entregado'),
(6, 5, '2026-04-21', 1, 75000.00, NULL, 'Entregado'),
(7, 3, '2026-04-28', 1, 65000.00, 5.00, 'Entregado'),

-- MAYO
(9, 7, '2026-05-14', 1, 180000.00, NULL, 'Entregado'),
(10, 9, '2026-05-31', 2, 35000.00, NULL, 'Entregado'),
(8, 6, '2026-05-19', 1, 120000.00, 5.00, 'Entregado'),
(9, 11, '2026-05-25', 2, 55000.00, 10.00, 'Entregado'),

-- JUNIO
(2, 4, '2026-06-03', 1, 220000.00, NULL, 'Entregado'),
(4, 8, '2026-06-10', 1, 250000.00, 5.00, 'Entregado'),
(5, 2, '2026-06-16', 2, 25000.00, NULL, 'Entregado'),
(10, 10, '2026-06-24', 1, 95000.00, NULL, 'Entregado'),

-- JULIO
(1, 3, '2026-07-04', 1, 65000.00, NULL, 'Entregado'),
(3, 5, '2026-07-11', 2, 75000.00, 10.00, 'Entregado'),
(7, 12, '2026-07-18', 1, 40000.00, NULL, 'Entregado'),
(6, 9, '2026-07-26', 3, 35000.00, 5.00, 'Entregado'),

-- AGOSTO
(4, 6, '2026-08-05', 1, 120000.00, NULL, 'Entregado'),
(8, 11, '2026-08-13', 1, 55000.00, NULL, 'Entregado'),
(9, 2, '2026-08-22', 2, 25000.00, 10.00, 'Entregado');

-- ============================================================
-- 5. VERIFICACION BASICA DE CARGA
-- ============================================================

SELECT COUNT(*) AS total_clientes FROM clientes;
SELECT COUNT(*) AS total_productos FROM productos;
SELECT COUNT(*) AS total_pedidos FROM pedidos;

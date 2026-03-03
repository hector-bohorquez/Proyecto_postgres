-- PostgreSQL Database Migration Script
-- Migrated from MySQL to PostgreSQL
-- Database: bd_app
-- Migration Date: 2026-02-10

-- Drop existing tables if they exist (in correct order to handle foreign keys)
DROP TABLE IF EXISTS detalle_orden CASCADE;
DROP TABLE IF EXISTS detalle_carrito CASCADE;
DROP TABLE IF EXISTS registro_login CASCADE;
DROP TABLE IF EXISTS usuario_rol CASCADE;
DROP TABLE IF EXISTS ordenes CASCADE;
DROP TABLE IF EXISTS carrito CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS metodo_pago CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

-- =============================================
-- Table: roles
-- =============================================
CREATE TABLE roles (
    idRol SERIAL PRIMARY KEY,
    nombreRol VARCHAR(50) NOT NULL
);

-- =============================================
-- Table: usuarios
-- =============================================
CREATE TABLE usuarios (
    idUsuario SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    reset_token VARCHAR(255),
    token_expiry TIMESTAMP
);

-- =============================================
-- Table: usuario_rol
-- =============================================
CREATE TABLE usuario_rol (
    idUsuario INTEGER NOT NULL,
    idRol INTEGER NOT NULL,
    PRIMARY KEY (idUsuario, idRol),
    CONSTRAINT usuario_rol_fk_usuario FOREIGN KEY (idUsuario) 
        REFERENCES usuarios(idUsuario) ON DELETE CASCADE,
    CONSTRAINT usuario_rol_fk_rol FOREIGN KEY (idRol) 
        REFERENCES roles(idRol) ON DELETE CASCADE
);

-- =============================================
-- Table: categorias
-- =============================================
CREATE TABLE categorias (
    idCategoria SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- =============================================
-- Table: productos
-- =============================================
CREATE TABLE productos (
    idProducto SERIAL PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio INTEGER NOT NULL,
    cantidad INTEGER DEFAULT 0,
    imagen VARCHAR(255),
    idCategoria INTEGER,
    CONSTRAINT productos_fk_categoria FOREIGN KEY (idCategoria) 
        REFERENCES categorias(idCategoria)
);

-- =============================================
-- Table: carrito
-- =============================================
CREATE TABLE carrito (
    idCarrito SERIAL PRIMARY KEY,
    idUsuario INTEGER NOT NULL,
    fechaCreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT carrito_fk_usuario FOREIGN KEY (idUsuario) 
        REFERENCES usuarios(idUsuario)
);

-- =============================================
-- Table: detalle_carrito
-- =============================================
CREATE TABLE detalle_carrito (
    idDetalle SERIAL PRIMARY KEY,
    idCarrito INTEGER NOT NULL,
    idProducto INTEGER NOT NULL,
    cantidad INTEGER DEFAULT 1,
    CONSTRAINT detalle_carrito_fk_carrito FOREIGN KEY (idCarrito) 
        REFERENCES carrito(idCarrito),
    CONSTRAINT detalle_carrito_fk_producto FOREIGN KEY (idProducto) 
        REFERENCES productos(idProducto)
);

-- =============================================
-- Table: metodo_pago
-- =============================================
CREATE TABLE metodo_pago (
    idMetodo SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

-- =============================================
-- Table: ordenes
-- =============================================
CREATE TABLE ordenes (
    idOrden SERIAL PRIMARY KEY,
    idUsuario INTEGER NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50) DEFAULT 'Pendiente',
    total NUMERIC(10,2) NOT NULL,
    metodo_pago VARCHAR(100),
    referencia_pago VARCHAR(100),
    fecha_pago TIMESTAMP,
    idMetodo INTEGER,
    CONSTRAINT ordenes_fk_usuario FOREIGN KEY (idUsuario) 
        REFERENCES usuarios(idUsuario),
    CONSTRAINT ordenes_fk_metodo FOREIGN KEY (idMetodo) 
        REFERENCES metodo_pago(idMetodo)
);

-- =============================================
-- Table: detalle_orden
-- =============================================
CREATE TABLE detalle_orden (
    idDetalle SERIAL PRIMARY KEY,
    idOrden INTEGER NOT NULL,
    idProducto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(10,2),
    CONSTRAINT detalle_orden_fk_orden FOREIGN KEY (idOrden) 
        REFERENCES ordenes(idOrden),
    CONSTRAINT detalle_orden_fk_producto FOREIGN KEY (idProducto) 
        REFERENCES productos(idProducto)
);

-- =============================================
-- Table: registro_login
-- =============================================
CREATE TABLE registro_login (
    id SERIAL PRIMARY KEY,
    idUsuario INTEGER NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT registro_login_fk_usuario FOREIGN KEY (idUsuario) 
        REFERENCES usuarios(idUsuario) ON DELETE CASCADE
);

-- =============================================
-- Create Indexes for better performance
-- =============================================
CREATE INDEX idx_carrito_usuario ON carrito(idUsuario);
CREATE INDEX idx_detalle_carrito_carrito ON detalle_carrito(idCarrito);
CREATE INDEX idx_detalle_carrito_producto ON detalle_carrito(idProducto);
CREATE INDEX idx_productos_categoria ON productos(idCategoria);
CREATE INDEX idx_ordenes_usuario ON ordenes(idUsuario);
CREATE INDEX idx_ordenes_metodo ON ordenes(idMetodo);
CREATE INDEX idx_detalle_orden_orden ON detalle_orden(idOrden);
CREATE INDEX idx_detalle_orden_producto ON detalle_orden(idProducto);
CREATE INDEX idx_registro_login_usuario ON registro_login(idUsuario);
CREATE INDEX idx_usuario_rol_rol ON usuario_rol(idRol);

-- =============================================
-- Insert Data: roles
-- =============================================
INSERT INTO roles (idRol, nombreRol) VALUES 
(1, 'Admin'),
(2, 'Usuario');

-- Update sequence for roles
SELECT setval('roles_idrol_seq', (SELECT MAX(idRol) FROM roles));

-- =============================================
-- Insert Data: usuarios
-- =============================================
INSERT INTO usuarios (idUsuario, nombre, apellido, username, password, reset_token, token_expiry) VALUES
(3, 'Matilda', 'Polo', 'matilda@polo.com', 
 'scrypt:32768:8:1$GD7TVUdIU4fEfIs3$28d6c4a606626d350209df1ca5b9c7a0a6096b3e511555cd006c46a2a6705f54145ecd1832477f2606a5b8fd1676e97222b6137e8d00f245501ef5250a7bdde1', 
 NULL, NULL),
(5, 'Maria', 'Cortez', 'maria@cortez.com', 
 'scrypt:32768:8:1$NmCTzHDOQL16CUic$34cee1c916c2ee74ab967392e17fc42c9a5758eef0a22bcc2d337eb789fca7953e69243991699df03e06db3d7c7cd7afc5ac5dd3cce518a9b515bea8cbb04d13', 
 NULL, NULL),
(7, 'Victoria', 'Marquez', 'victoria@gmail.com', 
 'scrypt:32768:8:1$UjBXAT1nFZKRHj68$74a853f5a7de9d37208bd0e0db06266877ca89890417d7ef558f3ef5d5bced54e7c4801c0725da2b387f3e056e8d0a990bda76edaf957f3e19d813394f91f841', 
 NULL, NULL),
(10, 'Nicol', 'Suarez', 'nicol@outlook.com', 
 'scrypt:32768:8:1$OiueZHrIBPCOGDWw$5175cd3e78c19ba30e273b2f00aeef833c4ba0fac09ee1b6fbb2ae6dfe16b981ba988abafd0c853da680fb38df0e69af1d5edbdf0125efb28cf776c6cca23b09', 
 NULL, NULL),
(14, 'Mariana', 'Pajon', 'mariana@pajon.co', 
 'scrypt:32768:8:1$gqNVHWI6WelnfnB6$bac7e144f769cec9a7492f6a469464cdb2fb9a85375f31a6463a32b674736deb233bc799cbe5d921a6167f15d334a4b26b16a1e456024321f56b166362454506', 
 NULL, NULL);

-- Update sequence for usuarios
SELECT setval('usuarios_idusuario_seq', (SELECT MAX(idUsuario) FROM usuarios));

-- =============================================
-- Insert Data: usuario_rol
-- =============================================
INSERT INTO usuario_rol (idUsuario, idRol) VALUES
(3, 1),
(10, 1),
(5, 2),
(7, 2),
(14, 2);

-- =============================================
-- Insert Data: productos
-- =============================================
INSERT INTO productos (idProducto, nombre_producto, descripcion, precio, cantidad, imagen, idCategoria) VALUES
(4, 'McDonald''s', 'Mccombo Mediano Big Mac 2 Hamburguesas de carne de res con gaseosa, papas fritas y salsa especial de McDonald''s', 
 30000, 95, 'mac_combo.jpg', NULL),
(5, 'KFC', 'Combo 4 Presas Disfruta de un delicioso combo con: 4 Presas de pollo + 2 papas pequeñas + coca cola + salsa especial', 
 35000, 98, 'kfc_4_presas.jpg', NULL),
(6, 'Qbano', E'Combo Sándwich Personal Pollo Bbq\n1 Sándwich personal 21cm pollo bbq\n+ 1 papas pequeñas + coca cola', 
 23000, 200, 'qbano_sandwich.jpg', NULL),
(7, 'Frisby', 'Pollo Frisby Francesa 8 Presas apanadas y 4 porciones de papas a la francesa + coca cola + salsa especial', 
 70000, 50, 'frisby_8_presas.jpg', NULL),
(9, 'Salchipapa', E'Salchipapa\nSalchipapa Especial', 
 70000, 200, 'salchipapa.jpg', NULL),
(13, 'Batido de frutas', E'Batido de frutas\nBatido de frutas', 
 20000, 100, 'batido.jpg', NULL),
(14, 'Juan Valdez', 'Cappuccino Tradicional. Café espresso con leche vaporizada.', 
 20000, 100, 'capuchino.jpg', NULL),
(16, 'Hamburgueza', E'Hamburgueza\nBig Hamburguer', 
 30000, 70, 'hamburguer.jpg', NULL),
(17, 'Pizza', 'Pizza familiar', 
 70000, 97, 'pizza.jpg', NULL),
(18, 'Pollo Broaster', 'Pollo Broaster Familiar', 
 70000, 100, 'pollo-broaster1.jpg', NULL),
(19, 'Hot Dog', 'Hot Dog Especial', 
 30000, 700, 'hotdog.jpg', NULL),
(20, 'Carne Asada', 'Carne Asada Especial', 
 100000, 70, 'carne1.jpg', NULL);

-- Update sequence for productos
SELECT setval('productos_idproducto_seq', (SELECT MAX(idProducto) FROM productos));

-- =============================================
-- Migration completed successfully!
-- =============================================

-- Verify data
/*
SELECT 'Roles:' as tabla, COUNT(*) as registros FROM roles
UNION ALL
SELECT 'Usuarios:', COUNT(*) FROM usuarios
UNION ALL
SELECT 'Usuario_Rol:', COUNT(*) FROM usuario_rol
UNION ALL
SELECT 'Productos:', COUNT(*) FROM productos;
*/

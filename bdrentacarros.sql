-- =============================================================
--  BASE DE DATOS: RENTA DE CARROS
--  Generado por: Sistema de gestión de renta vehicular
--  Motor:        MySQL 8.0+
--  Codificación: UTF-8
-- =============================================================

CREATE DATABASE IF NOT EXISTS bdrentacarros
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bdrentacarros;

-- =============================================================
-- 1. SUCURSAL
-- =============================================================
CREATE TABLE sucursal (
    id_sucursal       INT            NOT NULL AUTO_INCREMENT,
    nombre            VARCHAR(80)    NOT NULL,
    ciudad            VARCHAR(60)    NOT NULL,
    direccion         VARCHAR(150)   NOT NULL,
    telefono          VARCHAR(20)        NULL,
    email             VARCHAR(120)       NULL,
    activa            BOOLEAN        NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_sucursal PRIMARY KEY (id_sucursal)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
-- 2. EMPLEADO
-- =============================================================
CREATE TABLE empleado (
    id_empleado         INT           NOT NULL AUTO_INCREMENT,
    id_sucursal         INT           NOT NULL,
    nombre              VARCHAR(80)   NOT NULL,
    apellido            VARCHAR(80)   NOT NULL,
    cargo               VARCHAR(60)   NOT NULL,
    email               VARCHAR(120)      NULL,
    telefono            VARCHAR(20)       NULL,
    fecha_contratacion  DATE              NULL,
    activo              BOOLEAN       NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_empleado PRIMARY KEY (id_empleado),
    CONSTRAINT fk_empleado_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursal (id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
-- 3. CATEGORIA
-- =============================================================
CREATE TABLE categoria (
    id_categoria          INT              NOT NULL AUTO_INCREMENT,
    nombre                VARCHAR(60)      NOT NULL,
    descripcion           TEXT                 NULL,
    tarifa_diaria         DECIMAL(10,2)    NOT NULL,
    capacidad_pasajeros   TINYINT UNSIGNED     NULL,
    tipo_transmision      ENUM('manual','automatico') NOT NULL DEFAULT 'automatico',
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT chk_tarifa_diaria CHECK (tarifa_diaria > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
-- 4. VEHICULO
-- =============================================================
CREATE TABLE vehiculo (
    id_vehiculo   INT           NOT NULL AUTO_INCREMENT,
    id_categoria  INT           NOT NULL,
    id_sucursal   INT           NOT NULL,
    placa         VARCHAR(15)   NOT NULL,
    marca         VARCHAR(50)   NOT NULL,
    modelo        VARCHAR(50)   NOT NULL,
    anio          SMALLINT      NOT NULL,
    color         VARCHAR(30)       NULL,
    kilometraje   INT           NOT NULL DEFAULT 0,
    estado        ENUM('disponible','rentado','mantenimiento','inactivo')
                                NOT NULL DEFAULT 'disponible',
    CONSTRAINT pk_vehiculo    PRIMARY KEY (id_vehiculo),
    CONSTRAINT uq_placa       UNIQUE (placa),
    CONSTRAINT fk_veh_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_veh_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursal (id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_anio       CHECK (anio >= 1990),
    CONSTRAINT chk_kilometraje CHECK (kilometraje >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
-- 5. CLIENTE
-- =============================================================
CREATE TABLE cliente (
    id_cliente        INT           NOT NULL AUTO_INCREMENT,
    nombre            VARCHAR(80)   NOT NULL,
    apellido          VARCHAR(80)   NOT NULL,
    email             VARCHAR(120)      NULL,
    telefono          VARCHAR(20)       NULL,
    licencia_conducir VARCHAR(30)   NOT NULL,
    dui_pasaporte     VARCHAR(30)   NOT NULL,
    fecha_nacimiento  DATE              NULL,
    fecha_registro    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_cliente       PRIMARY KEY (id_cliente),
    CONSTRAINT uq_licencia      UNIQUE (licencia_conducir),
    CONSTRAINT uq_dui_pasaporte UNIQUE (dui_pasaporte)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
-- 6. RESERVA
-- =============================================================
CREATE TABLE reserva (
    id_reserva              INT              NOT NULL AUTO_INCREMENT,
    id_cliente              INT              NOT NULL,
    id_vehiculo             INT              NOT NULL,
    id_sucursal_recogida    INT              NOT NULL,
    id_sucursal_entrega     INT              NOT NULL,
    fecha_inicio            DATETIME         NOT NULL,
    fecha_fin               DATETIME         NOT NULL,
    monto_estimado          DECIMAL(10,2)        NULL,
    estado                  ENUM('pendiente','confirmada','cancelada','completada')
                                             NOT NULL DEFAULT 'pendiente',
    fecha_creacion          TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_reserva PRIMARY KEY (id_reserva),
    CONSTRAINT fk_res_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_res_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES vehiculo (id_vehiculo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_res_suc_recogida
        FOREIGN KEY (id_sucursal_recogida)
        REFERENCES sucursal (id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_res_suc_entrega
        FOREIGN KEY (id_sucursal_entrega)
        REFERENCES sucursal (id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_fechas_reserva CHECK (fecha_fin > fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
-- 7. CONTRATO
-- =============================================================
CREATE TABLE contrato (
    id_contrato                  INT              NOT NULL AUTO_INCREMENT,
    id_reserva                   INT              NOT NULL,
    id_empleado                  INT              NOT NULL,
    fecha_entrega                DATETIME         NOT NULL,
    fecha_devolucion             DATETIME             NULL,
    km_salida                    INT              NOT NULL DEFAULT 0,
    km_entrada                   INT                  NULL,
    nivel_combustible_salida     TINYINT UNSIGNED NOT NULL DEFAULT 100,
    nivel_combustible_entrada    TINYINT UNSIGNED     NULL,
    monto_total                  DECIMAL(10,2)        NULL,
    estado                       ENUM('activo','cerrado','cancelado')
                                                  NOT NULL DEFAULT 'activo',
    observaciones                TEXT                 NULL,
    CONSTRAINT pk_contrato         PRIMARY KEY (id_contrato),
    CONSTRAINT uq_contrato_reserva UNIQUE (id_reserva),
    CONSTRAINT fk_con_reserva
        FOREIGN KEY (id_reserva)
        REFERENCES reserva (id_reserva)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_con_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_combustible_salida   CHECK (nivel_combustible_salida  BETWEEN 0 AND 100),
    CONSTRAINT chk_combustible_entrada  CHECK (nivel_combustible_entrada BETWEEN 0 AND 100),
    CONSTRAINT chk_km_entrada           CHECK (km_entrada IS NULL OR km_entrada >= km_salida)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
-- 8. PAGO
-- =============================================================
CREATE TABLE pago (
    id_pago       INT              NOT NULL AUTO_INCREMENT,
    id_contrato   INT              NOT NULL,
    fecha_pago    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    monto         DECIMAL(10,2)    NOT NULL,
    metodo_pago   ENUM('efectivo','tarjeta_credito','tarjeta_debito','transferencia')
                                   NOT NULL,
    referencia    VARCHAR(80)          NULL,
    tipo          ENUM('anticipo','saldo','reembolso','cargo_extra')
                                   NOT NULL DEFAULT 'saldo',
    CONSTRAINT pk_pago PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_contrato
        FOREIGN KEY (id_contrato)
        REFERENCES contrato (id_contrato)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_monto_pago CHECK (monto <> 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
-- 9. MULTA
-- =============================================================
CREATE TABLE multa (
    id_multa        INT              NOT NULL AUTO_INCREMENT,
    id_contrato     INT              NOT NULL,
    tipo            ENUM('danio','tardanza','combustible','limpieza','otro')
                                     NOT NULL,
    descripcion     TEXT                 NULL,
    monto           DECIMAL(10,2)    NOT NULL,
    estado          ENUM('pendiente','pagada','exonerada')
                                     NOT NULL DEFAULT 'pendiente',
    fecha_registro  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_multa PRIMARY KEY (id_multa),
    CONSTRAINT fk_multa_contrato
        FOREIGN KEY (id_contrato)
        REFERENCES contrato (id_contrato)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_monto_multa CHECK (monto > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
-- 10. MANTENIMIENTO
-- =============================================================
CREATE TABLE mantenimiento (
    id_mantenimiento   INT              NOT NULL AUTO_INCREMENT,
    id_vehiculo        INT              NOT NULL,
    tipo               ENUM('preventivo','correctivo') NOT NULL,
    descripcion        TEXT                 NULL,
    fecha_inicio       DATE             NOT NULL,
    fecha_fin          DATE                 NULL,
    costo              DECIMAL(10,2)        NULL,
    km_al_servicio     INT                  NULL,
    taller             VARCHAR(100)         NULL,
    CONSTRAINT pk_mantenimiento PRIMARY KEY (id_mantenimiento),
    CONSTRAINT fk_mant_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES vehiculo (id_vehiculo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_fechas_mant  CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT chk_costo_mant   CHECK (costo IS NULL OR costo >= 0),
    CONSTRAINT chk_km_mant      CHECK (km_al_servicio IS NULL OR km_al_servicio >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
-- ÍNDICES ADICIONALES (rendimiento en consultas frecuentes)
-- =============================================================

CREATE INDEX idx_vehiculo_estado    ON vehiculo    (estado);
CREATE INDEX idx_vehiculo_sucursal  ON vehiculo    (id_sucursal);
CREATE INDEX idx_reserva_cliente    ON reserva     (id_cliente);
CREATE INDEX idx_reserva_fechas     ON reserva     (fecha_inicio, fecha_fin);
CREATE INDEX idx_reserva_estado     ON reserva     (estado);
CREATE INDEX idx_contrato_estado    ON contrato    (estado);
CREATE INDEX idx_pago_contrato      ON pago        (id_contrato);
CREATE INDEX idx_multa_estado       ON multa       (estado);
CREATE INDEX idx_mant_vehiculo      ON mantenimiento (id_vehiculo);
CREATE INDEX idx_mant_fecha         ON mantenimiento (fecha_inicio);


-- =============================================================
-- DATOS DE EJEMPLO (catálogos base)
-- =============================================================

INSERT INTO sucursal (nombre, ciudad, direccion, telefono, email) VALUES
  ('Sucursal Central',   'Ciudad de México', 'Av. Insurgentes Sur 1234', '55-1000-0001', 'central@rentacarros.mx'),
  ('Sucursal Norte',     'Monterrey',        'Av. Constitución 500',     '81-1000-0002', 'norte@rentacarros.mx'),
  ('Sucursal Occidente', 'Guadalajara',      'Calz. Independencia 890',  '33-1000-0003', 'occidente@rentacarros.mx');

INSERT INTO categoria (nombre, descripcion, tarifa_diaria, capacidad_pasajeros, tipo_transmision) VALUES
  ('Económico',  'Vehículos compactos de bajo consumo',        350.00, 5, 'manual'),
  ('Estándar',   'Sedanes medianos con mayor comodidad',        550.00, 5, 'automatico'),
  ('SUV',        'Camionetas con espacio para familia',          850.00, 7, 'automatico'),
  ('Lujo',       'Vehículos premium de alta gama',             1500.00, 5, 'automatico'),
  ('Camioneta',  'Pick-up para carga o terrenos difíciles',     700.00, 5, 'manual');

-- =============================================================
-- FIN DEL SCRIPT  |  bdrentacarros.sql
-- =============================================================

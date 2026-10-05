


-- 1_USUARIOS
-- Guarda a los operarios y a los administradores de la app.

CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(111) NOT NULL,
    email VARCHAR(111) NOT NULL UNIQUE,
    password VARCHAR(222) NOT NULL,        -- **** Modificar, queda expuesta
    rol VARCHAR(55) NOT NULL DEFAULT 'operario',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_alta TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_usuarios_rol CHECK (rol IN ('operario', 'administrador'))
);


-- 2_CATEGORIAS
-- Para agrupar el material
CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(111) NOT NULL UNIQUE
);

-- 3_ARTICULOS (catalogo maestro)
-- Material, sea consumible o maquinaria.
-- "activo" = FALSE significa que el admin lo ha bloqueado / dado de baja.

CREATE TABLE articulos (
    id_articulo SERIAL PRIMARY KEY,
    nombre VARCHAR(222) NOT NULL,
    descripcion	TEXT,
    id_categoria INT REFERENCES categorias(id_categoria),
    tipo VARCHAR(22) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 4_CONSUMIBLES (material a granel)
-- Relación 1 a 1 con articulos (misma clave primaria).
-- Cada consumible tiene un QR para toda la referencia (no uno por unidad).
-- El stock lo dejo en INT aunque el cable se mida en metros y podría haber decimales (2,5 m). De momento metros enteros.

CREATE TABLE consumibles (
    id_articulo INT PRIMARY KEY REFERENCES articulos(id_articulo) ON DELETE CASCADE,
    codigo_qr VARCHAR(55) NOT NULL UNIQUE,
    unidad_medida VARCHAR(11) NOT NULL DEFAULT 'uds',   -- uds, m, kg...
    stock_actual INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 0,  -- por debajo de esto salta la alerta
    stock_reservado  INT NOT NULL DEFAULT 0,  -- bloqueo por el admin para una obra futura
    CONSTRAINT chk_stock_actual CHECK (stock_actual >= 0),
    CONSTRAINT chk_stock_minimo CHECK (stock_minimo >= 0),
    CONSTRAINT chk_stock_reservado CHECK (stock_reservado >= 0)
);
-- El operario solo puede restar de (stock_actual - stock_reservado)"
-- ** NO está aquí, hay que comprobarla en la API antes de hacer el UPDATE.


-- 5_MAQUINAS (activos únicos)
--Resymen de Caracteristicas:
-- Cada fila es UNA unidad física con su propio QR (dos taladros iguales = dos filas con el mismo id_articulo).
-- Estados posibles:
-- disponible = se puede coger,
-- en_uso = la tiene un operario (ver tabla prestamos),
-- en_mantenimiento = bloqueada por una incidencia hasta que el admin la revise,
-- reservada = reservada por gerencia para una obra futura,

CREATE TABLE maquinas (
    id_maquina SERIAL PRIMARY KEY,
    id_articulo INT NOT NULL REFERENCES articulos(id_articulo),
    numero_serie VARCHAR(55) UNIQUE,
    codigo_qr VARCHAR(55) NOT NULL UNIQUE,
    estado VARCHAR(55  ) NOT NULL DEFAULT 'disponible'
);
-- * RECORDATORIO: el cambio de estado (disponible, en_uso, etc.) lo hace la API cuando se registra un préstamo, una devolución o una incidencia.


-- 6_FUNCIONES

-- 6_1 PRESTAMOS: quién se lleva qué máquina y cuándo la devuelve.
-- * RECORDATORIO:Si fecha_devolucion es NULL, el préstamo sigue abierto (la máquina está en uso).

CREATE TABLE prestamos (
    id_prestamo SERIAL PRIMARY KEY,
    id_maquina INT NOT NULL REFERENCES maquinas(id_maquina),
    id_usuario INT NOT NULL REFERENCES usuarios(id_usuario),
    fecha_salida TIMESTAMP NOT NULL DEFAULT NOW(),
    fecha_devolucion TIMESTAMP,
   -- A FUTURO (estado fotográfico): de momento van siempre a NULL, no se programa
    foto_salida VARCHAR(333),
    foto_devolucion VARCHAR(333)
);


-- 6_2 INCIDENCIAS: daños reportados por el operario al devolver la máquina.
CREATE TABLE incidencias (
    id_incidencia SERIAL PRIMARY KEY,
    descripcion TEXT NOT NULL,
    fecha_reporte TIMESTAMP NOT NULL DEFAULT NOW(),
    resuelta BOOLEAN NOT NULL DEFAULT FALSE
);

-- Al resolver una incidencia hay que poner la máquina en 'disponible' (desde la API).

-- 6_3 MOVIMIENTOS_CONSUMIBLE: histórico de cada +1 / -1 (o más) que se hace al stock.
-- cantidad es positiva si se añade stock y negativa si se gasta.
CREATE TABLE movimientos_consumible (
    id_movimiento SERIAL PRIMARY KEY,
    id_articulo INT NOT NULL REFERENCES consumibles(id_articulo),
    id_usuario INT NOT NULL REFERENCES usuarios(id_usuario),
    cantidad INT NOT NULL
);


-- 6_4 RESERVAS (FASE 2): el admin bloquea una máquina o una cantidad de consumible para una obra futura. 
-- O es de una máquina o es de un consumible, nunca de las dos cosas a la vez (el CHECK de abajo lo controla).
CREATE TABLE reservas (
    id_reserva      SERIAL PRIMARY KEY,
    id_admin        INT NOT NULL REFERENCES usuarios(id_usuario),
    id_maquina      INT REFERENCES maquinas(id_maquina),
    id_articulo     INT REFERENCES consumibles(id_articulo),
    cantidad        INT,
    motivo          VARCHAR(222) NOT NULL,        -- por ejemplo: nombre de la obra
    fecha_creacion  TIMESTAMP NOT NULL DEFAULT NOW(),
    activa          BOOLEAN NOT NULL DEFAULT TRUE
   
);
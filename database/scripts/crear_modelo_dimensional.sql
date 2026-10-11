/* ==========================================================================
   Modelo dimensional BikeZ_DW – Certamen 2 Inteligencia de Negocios
   Esquema estrella: FactVentas + DimFecha, DimCliente, DimProducto,
   DimEmpleado y DimTerritorio.
   ADVERTENCIA: al reejecutarlo se eliminan y recrean las tablas, por lo que
   se pierden los datos cargados y hay que volver a ejecutar el ETL.
   ========================================================================== */

USE master;
GO

IF DB_ID('BikeZ_DW') IS NULL
    CREATE DATABASE BikeZ_DW;
GO

USE BikeZ_DW;
GO

/* 1. Eliminar tablas existentes (primero la de hechos, por las claves foráneas) */
DROP TABLE IF EXISTS dbo.FactVentas;
DROP TABLE IF EXISTS dbo.DimFecha;
DROP TABLE IF EXISTS dbo.DimCliente;
DROP TABLE IF EXISTS dbo.DimProducto;
DROP TABLE IF EXISTS dbo.DimEmpleado;
DROP TABLE IF EXISTS dbo.DimTerritorio;
DROP TABLE IF EXISTS dbo.ETL_Rechazos;
GO

/* 2. Dimensiones */
CREATE TABLE dbo.DimFecha (
    FechaKey        INT           NOT NULL,   -- formato AAAAMMDD
    Fecha           DATE          NOT NULL,
    Anio            SMALLINT      NOT NULL,
    Trimestre       TINYINT       NOT NULL,
    Mes             TINYINT       NOT NULL,
    NombreMes       NVARCHAR(20)  NOT NULL,
    Dia             TINYINT       NOT NULL,
    DiaSemana       TINYINT       NOT NULL,
    NombreDiaSemana NVARCHAR(20)  NOT NULL,
    CONSTRAINT PK_DimFecha PRIMARY KEY (FechaKey)
);

CREATE TABLE dbo.DimCliente (
    ClienteKey      INT IDENTITY(1,1) NOT NULL,
    ClienteID       INT           NOT NULL,   -- clave de negocio (origen)
    Nombre          NVARCHAR(100) NOT NULL,
    Apellido        NVARCHAR(100) NOT NULL,
    NombreCompleto  NVARCHAR(250) NOT NULL,
    TipoCliente     NVARCHAR(30)  NOT NULL,
    CONSTRAINT PK_DimCliente PRIMARY KEY (ClienteKey),
    CONSTRAINT UQ_DimCliente_ClienteID UNIQUE (ClienteID)
);

CREATE TABLE dbo.DimProducto (
    ProductoKey     INT IDENTITY(1,1) NOT NULL,
    ProductoID      INT           NOT NULL,
    Producto        NVARCHAR(150) NOT NULL,
    Color           NVARCHAR(50)  NOT NULL,
    Categoria       NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_DimProducto PRIMARY KEY (ProductoKey),
    CONSTRAINT UQ_DimProducto_ProductoID UNIQUE (ProductoID)
);

CREATE TABLE dbo.DimEmpleado (
    EmpleadoKey       INT IDENTITY(1,1) NOT NULL,
    EmpleadoID        INT           NOT NULL,
    Cargo             NVARCHAR(100) NOT NULL,
    FechaNacimiento   DATE          NULL,
    EstadoCivil       NVARCHAR(20)  NOT NULL,
    Genero            NVARCHAR(20)  NOT NULL,
    FechaContratacion DATE          NULL,
    HorasVacaciones   INT           NULL,
    CONSTRAINT PK_DimEmpleado PRIMARY KEY (EmpleadoKey),
    CONSTRAINT UQ_DimEmpleado_EmpleadoID UNIQUE (EmpleadoID)
);

CREATE TABLE dbo.DimTerritorio (
    TerritorioKey   INT IDENTITY(1,1) NOT NULL,
    TerritorioID    INT           NOT NULL,
    Territorio      NVARCHAR(100) NOT NULL,
    Pais            NVARCHAR(100) NOT NULL,
    Grupo           NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_DimTerritorio PRIMARY KEY (TerritorioKey),
    CONSTRAINT UQ_DimTerritorio_TerritorioID UNIQUE (TerritorioID)
);

/* 3. Tabla de hechos (una fila por línea de detalle de venta) */
CREATE TABLE dbo.FactVentas (
    FechaVentaKey   INT           NOT NULL,
    FechaEnvioKey   INT           NOT NULL,
    ClienteKey      INT           NOT NULL,
    ProductoKey     INT           NOT NULL,
    EmpleadoKey     INT           NOT NULL,
    TerritorioKey   INT           NOT NULL,
    VentaID         INT           NOT NULL,   -- dimensión degenerada
    DetalleVentaID  INT           NOT NULL,   -- dimensión degenerada
    Cantidad        INT           NOT NULL,
    PrecioUnitario  DECIMAL(19,4) NOT NULL,
    VentaTotal      DECIMAL(19,4) NOT NULL,   -- Cantidad * PrecioUnitario
    DiasEnvio       INT           NOT NULL,   -- FechaEnvio - Fecha, en días
    CONSTRAINT PK_FactVentas PRIMARY KEY (VentaID, DetalleVentaID),
    CONSTRAINT FK_FactVentas_FechaVenta FOREIGN KEY (FechaVentaKey) REFERENCES dbo.DimFecha (FechaKey),
    CONSTRAINT FK_FactVentas_FechaEnvio FOREIGN KEY (FechaEnvioKey) REFERENCES dbo.DimFecha (FechaKey),
    CONSTRAINT FK_FactVentas_Cliente    FOREIGN KEY (ClienteKey)    REFERENCES dbo.DimCliente (ClienteKey),
    CONSTRAINT FK_FactVentas_Producto   FOREIGN KEY (ProductoKey)   REFERENCES dbo.DimProducto (ProductoKey),
    CONSTRAINT FK_FactVentas_Empleado   FOREIGN KEY (EmpleadoKey)   REFERENCES dbo.DimEmpleado (EmpleadoKey),
    CONSTRAINT FK_FactVentas_Territorio FOREIGN KEY (TerritorioKey) REFERENCES dbo.DimTerritorio (TerritorioKey)
);

/* 4. Tabla auxiliar para registros rechazados por el ETL */
CREATE TABLE dbo.ETL_Rechazos (
    RechazoID       INT IDENTITY(1,1) NOT NULL,
    Paquete         NVARCHAR(100) NOT NULL,
    Motivo          NVARCHAR(250) NOT NULL,
    VentaID         INT           NULL,
    DetalleVentaID  INT           NULL,
    FechaRegistro   DATETIME2(0)  NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_ETL_Rechazos PRIMARY KEY (RechazoID)
);
GO

/* 5. Poblar DimFecha (2015-01-01 a 2018-12-31) */
SET LANGUAGE Spanish;   -- nombres de mes y día en español; lunes = 1
DECLARE @Inicio DATE = '2015-01-01', @Fin DATE = '2018-12-31';

WITH Fechas AS (
    SELECT @Inicio AS Fecha
    UNION ALL
    SELECT DATEADD(DAY, 1, Fecha) FROM Fechas WHERE Fecha < @Fin
)
INSERT INTO dbo.DimFecha (FechaKey, Fecha, Anio, Trimestre, Mes, NombreMes, Dia, DiaSemana, NombreDiaSemana)
SELECT CONVERT(INT, CONVERT(CHAR(8), Fecha, 112)),
       Fecha,
       YEAR(Fecha),
       DATEPART(QUARTER, Fecha),
       MONTH(Fecha),
       DATENAME(MONTH, Fecha),
       DAY(Fecha),
       DATEPART(WEEKDAY, Fecha),
       DATENAME(WEEKDAY, Fecha)
FROM Fechas
OPTION (MAXRECURSION 0);

SET LANGUAGE us_english;
GO

/* 6. Registros "Desconocido" (clave -1) */
INSERT INTO dbo.DimFecha (FechaKey, Fecha, Anio, Trimestre, Mes, NombreMes, Dia, DiaSemana, NombreDiaSemana)
VALUES (-1, '1900-01-01', 1900, 1, 1, N'Desconocido', 1, 1, N'Desconocido');

SET IDENTITY_INSERT dbo.DimCliente ON;
INSERT INTO dbo.DimCliente (ClienteKey, ClienteID, Nombre, Apellido, NombreCompleto, TipoCliente)
VALUES (-1, -1, N'Desconocido', N'Desconocido', N'Cliente desconocido', N'Desconocido');
SET IDENTITY_INSERT dbo.DimCliente OFF;

SET IDENTITY_INSERT dbo.DimProducto ON;
INSERT INTO dbo.DimProducto (ProductoKey, ProductoID, Producto, Color, Categoria)
VALUES (-1, -1, N'Producto desconocido', N'Sin color', N'Sin categoría');
SET IDENTITY_INSERT dbo.DimProducto OFF;

SET IDENTITY_INSERT dbo.DimEmpleado ON;
INSERT INTO dbo.DimEmpleado (EmpleadoKey, EmpleadoID, Cargo, FechaNacimiento, EstadoCivil, Genero, FechaContratacion, HorasVacaciones)
VALUES (-1, -1, N'Sin vendedor', NULL, N'Sin información', N'Sin información', NULL, NULL);
SET IDENTITY_INSERT dbo.DimEmpleado OFF;

SET IDENTITY_INSERT dbo.DimTerritorio ON;
INSERT INTO dbo.DimTerritorio (TerritorioKey, TerritorioID, Territorio, Pais, Grupo)
VALUES (-1, -1, N'Territorio desconocido', N'Sin información', N'Sin información');
SET IDENTITY_INSERT dbo.DimTerritorio OFF;
GO

/* 7. Verificación */
SELECT 'DimFecha' AS Tabla, COUNT(*) AS Filas FROM dbo.DimFecha
UNION ALL SELECT 'DimCliente', COUNT(*) FROM dbo.DimCliente
UNION ALL SELECT 'DimProducto', COUNT(*) FROM dbo.DimProducto
UNION ALL SELECT 'DimEmpleado', COUNT(*) FROM dbo.DimEmpleado
UNION ALL SELECT 'DimTerritorio', COUNT(*) FROM dbo.DimTerritorio
UNION ALL SELECT 'FactVentas', COUNT(*) FROM dbo.FactVentas;
GO
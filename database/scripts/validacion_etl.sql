USE BikeZ_DW;
GO

-- Validacion de DimProducto
SELECT 'DimProducto' AS Dimension,
  (SELECT COUNT(*) FROM BikeZ.dbo.Productos) AS FilasOrigen,
  (SELECT COUNT(*) FROM BikeZ_DW.dbo.DimProducto WHERE ProductoKey <> -1) AS FilasDestino,
  (SELECT COUNT(*) FROM BikeZ_DW.dbo.DimProducto WHERE ProductoKey <> -1 AND Color = N'Sin color') AS SinColor,
  (SELECT COUNT(*) FROM BikeZ_DW.dbo.DimProducto WHERE ProductoKey <> -1 AND Categoria = N'Sin categoría') AS SinCategoria;

-- Validacion de DimTerritorio
SELECT 'DimTerritorio' AS Dimension,
  (SELECT COUNT(*) FROM BikeZ.dbo.Territorios) AS FilasOrigen,
  (SELECT COUNT(*) FROM BikeZ_DW.dbo.DimTerritorio WHERE TerritorioKey <> -1) AS FilasDestino,
  (SELECT COUNT(*) FROM BikeZ_DW.dbo.DimTerritorio WHERE TerritorioKey <> -1 AND Pais = N'Sin información') AS SinPais;

-- Validacion de DimEmpleado
SELECT 'DimEmpleado' AS Dimension,
  (SELECT COUNT(*) FROM BikeZ.dbo.Empleados) AS FilasOrigen,
  (SELECT COUNT(*) FROM BikeZ_DW.dbo.DimEmpleado WHERE EmpleadoKey <> -1) AS FilasDestino;

-- Validacion de DimCliente
SELECT 'DimCliente' AS Dimension,
  (SELECT COUNT(*) FROM BikeZ.dbo.Clientes) AS FilasOrigen,
  (SELECT COUNT(*) FROM BikeZ_DW.dbo.DimCliente WHERE ClienteKey <> -1) AS FilasDestino,
  (SELECT COUNT(*) FROM BikeZ_DW.dbo.DimCliente WHERE ClienteKey <> -1 AND TipoCliente = N'Sin nombre registrado') AS SinNombre;
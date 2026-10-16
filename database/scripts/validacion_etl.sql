USE BikeZ_DW;
GO

-- 1. Filas e ingreso: origen frente a la tabla de hechos
SELECT
  (SELECT COUNT(*) FROM BikeZ.dbo.DetalleVentas) AS FilasOrigen,
  (SELECT COUNT(*) FROM BikeZ_DW.dbo.FactVentas) AS FilasDestino,
  (SELECT SUM(Cantidad * PrecioUnitario) FROM BikeZ.dbo.DetalleVentas) AS IngresoOrigen,
  (SELECT SUM(VentaTotal) FROM BikeZ_DW.dbo.FactVentas) AS IngresoDestino;

-- 2. Ventas distintas y unidades vendidas
SELECT
  (SELECT COUNT(*) FROM BikeZ.dbo.Ventas) AS VentasOrigen,
  (SELECT COUNT(DISTINCT VentaID) FROM BikeZ_DW.dbo.FactVentas) AS VentasDestino,
  (SELECT SUM(CAST(Cantidad AS BIGINT)) FROM BikeZ.dbo.DetalleVentas) AS UnidadesOrigen,
  (SELECT SUM(CAST(Cantidad AS BIGINT)) FROM BikeZ_DW.dbo.FactVentas) AS UnidadesDestino;

-- 3. Claves "Desconocido" (-1) en la tabla de hechos
SELECT
  SUM(CASE WHEN ClienteKey = -1 THEN 1 ELSE 0 END) AS ClienteDesconocido,
  SUM(CASE WHEN ProductoKey = -1 THEN 1 ELSE 0 END) AS ProductoDesconocido,
  SUM(CASE WHEN EmpleadoKey = -1 THEN 1 ELSE 0 END) AS SinVendedor,
  SUM(CASE WHEN TerritorioKey = -1 THEN 1 ELSE 0 END) AS TerritorioDesconocido,
  SUM(CASE WHEN FechaVentaKey = -1 THEN 1 ELSE 0 END) AS FechaVentaDesconocida,
  SUM(CASE WHEN FechaEnvioKey = -1 THEN 1 ELSE 0 END) AS FechaEnvioDesconocida,
  (SELECT COUNT(*)
     FROM BikeZ.dbo.DetalleVentas d
     JOIN BikeZ.dbo.Ventas v ON v.VentaID = d.VentaID
    WHERE v.VendedorID IS NULL) AS LineasSinVendedorEnOrigen
FROM BikeZ_DW.dbo.FactVentas;

-- 4. Demostración de KPI: ventas, unidades y ticket promedio por año
SELECT
  fe.Anio,
  COUNT(DISTINCT f.VentaID) AS Ventas,
  SUM(f.Cantidad) AS Unidades,
  SUM(f.VentaTotal) AS Ingreso,
  SUM(f.VentaTotal) / COUNT(DISTINCT f.VentaID) AS TicketPromedio
FROM dbo.FactVentas f
JOIN dbo.DimFecha fe ON fe.FechaKey = f.FechaVentaKey
GROUP BY fe.Anio
ORDER BY fe.Anio;

-- 5. Demostración de KPI: ingreso y participación por territorio
SELECT
  t.Territorio,
  t.Pais,
  SUM(f.VentaTotal) AS Ingreso,
  CAST(100.0 * SUM(f.VentaTotal) / SUM(SUM(f.VentaTotal)) OVER () AS DECIMAL(5,2)) AS PorcentajeDelTotal
FROM dbo.FactVentas f
JOIN dbo.DimTerritorio t ON t.TerritorioKey = f.TerritorioKey
GROUP BY t.Territorio, t.Pais
ORDER BY Ingreso DESC;
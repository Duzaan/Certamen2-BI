USE BikeZ_DW;
GO

-- Productos cuyo ingreso difiere entre origen y destino (esperado: 0)
SELECT COUNT(*) AS ProductosConDiferencia
FROM (SELECT ProductoID, SUM(Cantidad * PrecioUnitario) AS Ing
      FROM BikeZ.dbo.DetalleVentas GROUP BY ProductoID) o
FULL JOIN (SELECT p.ProductoID, SUM(f.VentaTotal) AS Ing
           FROM dbo.FactVentas f
           JOIN dbo.DimProducto p ON p.ProductoKey = f.ProductoKey
           GROUP BY p.ProductoID) x ON x.ProductoID = o.ProductoID
WHERE ISNULL(o.Ing, 0) <> ISNULL(x.Ing, 0);

-- Territorios cuyo ingreso difiere entre origen y destino (esperado: 0)
SELECT COUNT(*) AS TerritoriosConDiferencia
FROM (SELECT v.TerritorioID, SUM(d.Cantidad * d.PrecioUnitario) AS Ing
      FROM BikeZ.dbo.DetalleVentas d
      JOIN BikeZ.dbo.Ventas v ON v.VentaID = d.VentaID GROUP BY v.TerritorioID) o
FULL JOIN (SELECT t.TerritorioID, SUM(f.VentaTotal) AS Ing
           FROM dbo.FactVentas f
           JOIN dbo.DimTerritorio t ON t.TerritorioKey = f.TerritorioKey
           GROUP BY t.TerritorioID) x ON x.TerritorioID = o.TerritorioID
WHERE ISNULL(o.Ing, 0) <> ISNULL(x.Ing, 0);
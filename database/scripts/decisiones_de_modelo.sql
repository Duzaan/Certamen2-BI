USE BikeZ;
GO

-- Consulta A: naturaleza de los faltantes (nulos frente a referencias inexistentes)
SELECT
  (SELECT COUNT(*) FROM Productos WHERE CategoriaID IS NULL) AS ProductosCategoriaNula,
  (SELECT COUNT(*) FROM Productos p
     WHERE p.CategoriaID IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Categorias c WHERE c.CategoriaID = p.CategoriaID)) AS ProductosCategoriaInexistente,
  (SELECT COUNT(*) FROM Ventas WHERE VendedorID IS NULL) AS VentasVendedorNulo,
  (SELECT COUNT(*) FROM Ventas v
     WHERE v.VendedorID IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Empleados e WHERE e.EmpleadoID = v.VendedorID)) AS VentasVendedorInexistente,
  (SELECT COUNT(*) FROM Clientes WHERE Nombre IS NULL) AS ClientesNombreNulo,
  (SELECT COUNT(*) FROM Clientes WHERE Apellido IS NULL) AS ClientesApellidoNulo,
  (SELECT COUNT(*) FROM Clientes WHERE Nombre IS NULL AND Apellido IS NULL) AS ClientesAmbosNulos;

-- Consulta B: peso de las ventas con y sin vendedor
SELECT
  CASE WHEN v.VendedorID IS NULL THEN 'Sin vendedor' ELSE 'Con vendedor' END AS Grupo,
  COUNT(DISTINCT v.VentaID) AS Ventas,
  SUM(d.Cantidad * d.PrecioUnitario) AS Ingreso
FROM Ventas v
JOIN DetalleVentas d ON d.VentaID = v.VentaID
GROUP BY CASE WHEN v.VendedorID IS NULL THEN 'Sin vendedor' ELSE 'Con vendedor' END;

-- Consulta C: peso de los productos con y sin categoría
SELECT
  CASE WHEN c.CategoriaID IS NULL THEN 'Sin categoria' ELSE 'Con categoria' END AS Grupo,
  COUNT(DISTINCT p.ProductoID) AS Productos,
  COUNT(*) AS LineasVenta,
  SUM(d.Cantidad * d.PrecioUnitario) AS Ingreso
FROM DetalleVentas d
JOIN Productos p ON p.ProductoID = d.ProductoID
LEFT JOIN Categorias c ON c.CategoriaID = p.CategoriaID
GROUP BY CASE WHEN c.CategoriaID IS NULL THEN 'Sin categoria' ELSE 'Con categoria' END;

-- Consulta D: peso de las ventas de clientes con y sin nombre
SELECT
  CASE WHEN cl.Nombre IS NULL THEN 'Cliente sin nombre' ELSE 'Cliente con nombre' END AS Grupo,
  COUNT(DISTINCT v.VentaID) AS Ventas,
  SUM(d.Cantidad * d.PrecioUnitario) AS Ingreso
FROM Ventas v
JOIN Clientes cl ON cl.ClienteID = v.ClienteID
JOIN DetalleVentas d ON d.VentaID = v.VentaID
GROUP BY CASE WHEN cl.Nombre IS NULL THEN 'Cliente sin nombre' ELSE 'Cliente con nombre' END;
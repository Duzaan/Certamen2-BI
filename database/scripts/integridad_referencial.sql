USE BikeZ;
GO

SELECT 'Detalle sin venta' AS Control, COUNT(*) AS Casos
FROM DetalleVentas d LEFT JOIN Ventas v ON v.VentaID = d.VentaID
WHERE v.VentaID IS NULL
UNION ALL
SELECT 'Detalle sin producto', COUNT(*)
FROM DetalleVentas d LEFT JOIN Productos p ON p.ProductoID = d.ProductoID
WHERE p.ProductoID IS NULL
UNION ALL
SELECT 'Venta sin cliente', COUNT(*)
FROM Ventas v LEFT JOIN Clientes c ON c.ClienteID = v.ClienteID
WHERE c.ClienteID IS NULL
UNION ALL
SELECT 'Venta sin vendedor', COUNT(*)
FROM Ventas v LEFT JOIN Empleados e ON e.EmpleadoID = v.VendedorID
WHERE e.EmpleadoID IS NULL
UNION ALL
SELECT 'Venta sin territorio', COUNT(*)
FROM Ventas v LEFT JOIN Territorios t ON t.TerritorioID = v.TerritorioID
WHERE t.TerritorioID IS NULL
UNION ALL
SELECT 'Producto sin categoria', COUNT(*)
FROM Productos p LEFT JOIN Categorias c ON c.CategoriaID = p.CategoriaID
WHERE c.CategoriaID IS NULL
UNION ALL
SELECT 'Territorio sin pais', COUNT(*)
FROM Territorios t LEFT JOIN Paises x ON x.PaisID = t.PaisID
WHERE x.PaisID IS NULL;
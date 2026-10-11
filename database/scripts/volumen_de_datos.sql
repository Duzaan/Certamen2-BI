USE BikeZ;
SELECT 'Ventas' AS Tabla, COUNT(*) AS Filas FROM Ventas
UNION ALL SELECT 'DetalleVentas', COUNT(*) FROM DetalleVentas
UNION ALL SELECT 'Clientes', COUNT(*) FROM Clientes
UNION ALL SELECT 'Productos', COUNT(*) FROM Productos
UNION ALL SELECT 'Categorias', COUNT(*) FROM Categorias
UNION ALL SELECT 'Empleados', COUNT(*) FROM Empleados
UNION ALL SELECT 'Territorios', COUNT(*) FROM Territorios
UNION ALL SELECT 'Paises', COUNT(*) FROM Paises
UNION ALL SELECT 'Almacenes', COUNT(*) FROM Almacenes;
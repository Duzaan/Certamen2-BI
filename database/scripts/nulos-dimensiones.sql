USE BikeZ;
GO

SELECT 'Productos: Color nulo' AS Control, COUNT(*) AS Casos FROM Productos WHERE Color IS NULL
UNION ALL SELECT 'Empleados: Cargo nulo', COUNT(*) FROM Empleados WHERE Cargo IS NULL
UNION ALL SELECT 'Empleados: Genero nulo', COUNT(*) FROM Empleados WHERE Genero IS NULL
UNION ALL SELECT 'Empleados: EstadoCivil nulo', COUNT(*) FROM Empleados WHERE EstadoCivil IS NULL
UNION ALL SELECT 'Clientes: Nombre nulo', COUNT(*) FROM Clientes WHERE Nombre IS NULL OR Apellido IS NULL;
USE BikeZ_DW;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FactVentas_FechaVentaKey' AND object_id = OBJECT_ID('dbo.FactVentas'))
    CREATE NONCLUSTERED INDEX IX_FactVentas_FechaVentaKey ON dbo.FactVentas (FechaVentaKey);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FactVentas_FechaEnvioKey' AND object_id = OBJECT_ID('dbo.FactVentas'))
    CREATE NONCLUSTERED INDEX IX_FactVentas_FechaEnvioKey ON dbo.FactVentas (FechaEnvioKey);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FactVentas_ClienteKey' AND object_id = OBJECT_ID('dbo.FactVentas'))
    CREATE NONCLUSTERED INDEX IX_FactVentas_ClienteKey ON dbo.FactVentas (ClienteKey);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FactVentas_ProductoKey' AND object_id = OBJECT_ID('dbo.FactVentas'))
    CREATE NONCLUSTERED INDEX IX_FactVentas_ProductoKey ON dbo.FactVentas (ProductoKey);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FactVentas_EmpleadoKey' AND object_id = OBJECT_ID('dbo.FactVentas'))
    CREATE NONCLUSTERED INDEX IX_FactVentas_EmpleadoKey ON dbo.FactVentas (EmpleadoKey);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FactVentas_TerritorioKey' AND object_id = OBJECT_ID('dbo.FactVentas'))
    CREATE NONCLUSTERED INDEX IX_FactVentas_TerritorioKey ON dbo.FactVentas (TerritorioKey);
GO
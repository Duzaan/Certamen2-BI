SELECT
  MIN(Fecha) AS FechaMin,
  MAX(Fecha) AS FechaMax,
  SUM(CASE WHEN FechaEnvio IS NULL THEN 1 ELSE 0 END) AS EnvioNulo,
  SUM(CASE WHEN FechaEnvio < Fecha THEN 1 ELSE 0 END) AS EnvioAntesDeVenta,
  SUM(CASE WHEN ClienteID IS NULL THEN 1 ELSE 0 END) AS SinCliente,
  SUM(CASE WHEN VendedorID IS NULL THEN 1 ELSE 0 END) AS SinVendedor,
  SUM(CASE WHEN TerritorioID IS NULL THEN 1 ELSE 0 END) AS SinTerritorio
FROM Ventas;

SELECT
  MIN(Cantidad) AS CantMin, MAX(Cantidad) AS CantMax,
  MIN(PrecioUnitario) AS PrecioMin, MAX(PrecioUnitario) AS PrecioMax,
  SUM(CASE WHEN Cantidad <= 0 THEN 1 ELSE 0 END) AS CantidadNoPositiva,
  SUM(CASE WHEN PrecioUnitario <= 0 THEN 1 ELSE 0 END) AS PrecioNoPositivo
FROM DetalleVentas;
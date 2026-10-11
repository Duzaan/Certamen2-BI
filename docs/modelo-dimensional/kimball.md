# Modelo dimensional – Metodología de Kimball

## Paso 1: Proceso de negocio

Ventas de artículos de motocross de Bike Z. Es el proceso que genera los ingresos de la empresa y el que sustenta los KPI definidos (ver `kpi.md`).

## Paso 2: Granularidad

Una fila de la tabla de hechos por **cada línea de detalle de venta**, identificada por `VentaID` + `DetalleVentaID`. Es el nivel más detallado disponible en la base transaccional, lo que permite agregar la información por cualquier dimensión sin pérdida de detalle.

## Paso 3: Dimensiones

| Dimensión | Origen | Atributos principales |
|---|---|---|
| `DimFecha` | Generada por script (2015-01-01 a 2018-12-31) | Fecha, año, trimestre, mes, nombre del mes, día, día de la semana |
| `DimCliente` | `Clientes` | ClienteID, Nombre, Apellido |
| `DimProducto` | `Productos` + `Categorias` | ProductoID, Producto, Color, Categoría |
| `DimEmpleado` | `Empleados` (vendedor) | EmpleadoID, Cargo, FechaNacimiento, EstadoCivil, Género, FechaContratación, HorasVacaciones |
| `DimTerritorio` | `Territorios` + `Paises` | TerritorioID, Territorio, País, Grupo |

Decisiones de diseño:
- **Esquema estrella:** las dimensiones se aplanan (categoría dentro de `DimProducto`, país dentro de `DimTerritorio`) para reducir uniones y simplificar el análisis.
- **Claves sustitutas:** cada dimensión tiene una clave artificial (`...Key`) y conserva la clave original del sistema transaccional.
- **`DimFecha` con doble rol:** se usa para la fecha de venta y para la fecha de envío.
- **`Almacenes` queda fuera del modelo:** solo se relaciona con `Territorios` y no con las ventas, por lo que no aporta a la granularidad elegida.
- **Valores desconocidos:** cada dimensión incluye un registro "Desconocido" (clave −1) para las ventas sin vendedor, productos sin categoría o color, y clientes sin nombre, de modo que ninguna venta se pierda en la carga.

## Paso 4: Medidas y tabla de hechos

Tabla de hechos: `FactVentas`.

| Columna | Tipo | Descripción |
|---|---|---|
| `FechaVentaKey` | Clave foránea | Fecha de la venta (`DimFecha`) |
| `FechaEnvioKey` | Clave foránea | Fecha de envío (`DimFecha`) |
| `ClienteKey` | Clave foránea | Cliente (`DimCliente`) |
| `ProductoKey` | Clave foránea | Producto (`DimProducto`) |
| `EmpleadoKey` | Clave foránea | Vendedor (`DimEmpleado`) |
| `TerritorioKey` | Clave foránea | Territorio (`DimTerritorio`) |
| `VentaID`, `DetalleVentaID` | Dimensión degenerada | Identifican la línea de venta de origen |
| `Cantidad` | Medida aditiva | Unidades vendidas |
| `PrecioUnitario` | Medida no aditiva | Precio por unidad (no se suma; se promedia o pondera) |
| `VentaTotal` | Medida aditiva (derivada) | Cantidad × PrecioUnitario |
| `DiasEnvio` | Medida no aditiva (derivada) | Días entre FechaEnvio y Fecha (se promedia) |
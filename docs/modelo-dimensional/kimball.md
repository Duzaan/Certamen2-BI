# Modelo dimensional – Metodología de Kimball

## Paso 1: Proceso de negocio

Ventas de artículos de motocross de Bike Z. Es el proceso que genera los ingresos de la empresa y el que sustenta los KPI definidos (ver `kpi.md`).

## Paso 2: Granularidad

Una fila de la tabla de hechos por **cada línea de detalle de venta**, identificada por `VentaID` + `DetalleVentaID`. Es el nivel más detallado disponible en la base transaccional, lo que permite agregar la información por cualquier dimensión sin pérdida de detalle.

Cardinalidad esperada: 121.317 filas, equivalentes a las líneas de la tabla `DetalleVentas` de origen.

## Paso 3: Dimensiones

| Dimensión | Origen | Atributos principales |
|---|---|---|
| `DimFecha` | Generada por script (2015-01-01 a 2018-12-31) | Fecha, año, trimestre, mes, nombre del mes, día, día de la semana, nombre del día |
| `DimCliente` | `Clientes` | ClienteID, Nombre, Apellido, NombreCompleto, TipoCliente |
| `DimProducto` | `Productos` + `Categorias` | ProductoID, Producto, Color, Categoría |
| `DimEmpleado` | `Empleados` (vendedor) | EmpleadoID, Cargo, FechaNacimiento, EstadoCivil, Género, FechaContratación, HorasVacaciones |
| `DimTerritorio` | `Territorios` + `Paises` | TerritorioID, Territorio, País, Grupo |

Decisiones de diseño:
- **Esquema estrella:** las dimensiones se aplanan (categoría dentro de `DimProducto`, país dentro de `DimTerritorio`) para reducir uniones y simplificar el análisis.
- **Claves sustitutas:** cada dimensión tiene una clave artificial (`...Key`) y conserva la clave original del sistema transaccional (`...ID`), con restricción de unicidad.
- **`DimFecha` con doble rol:** se usa para la fecha de venta y para la fecha de envío. Cubre años completos, más allá del período real de ventas.
- **`Almacenes` queda fuera del modelo:** solo se relaciona con `Territorios` y no con las ventas, por lo que no aporta a la granularidad elegida.
- **Registro "Desconocido" (clave −1):** cada dimensión lo incluye como medida de seguridad ante referencias que no puedan resolverse. Las ventas sin vendedor se asocian al registro −1 de `DimEmpleado` (cargo "Sin vendedor").
- **Valores por defecto en el ETL:** los productos sin color o sin categoría se cargan como "Sin color" y "Sin categoría". Los clientes sin nombre se cargan con el nombre "Cliente sin nombre (ID n)" y `TipoCliente` = "Sin nombre registrado" (los demás: "Nombre registrado"). De este modo no se pierde ninguna venta.
- **Tipos de datos:** las medidas monetarias se definen como `DECIMAL(19,4)`, porque los precios de origen tienen hasta 4 decimales; las fechas se almacenan como `DATE`.

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
| `VentaID`, `DetalleVentaID` | Dimensión degenerada | Identifican la línea de venta de origen; forman la clave primaria |
| `Cantidad` | Medida aditiva (INT) | Unidades vendidas |
| `PrecioUnitario` | Medida no aditiva (DECIMAL(19,4)) | Precio por unidad (no se suma; se promedia o pondera) |
| `VentaTotal` | Medida aditiva, derivada (DECIMAL(19,4)) | Cantidad × PrecioUnitario |
| `DiasEnvio` | Medida no aditiva, derivada (INT) | Días entre FechaEnvio y Fecha (se promedia) |

## Hallazgos del perfilamiento y decisiones asociadas

| Hallazgo | Dato | Decisión |
|---|---|---|
| Período de ventas | 2015-07-01 a 2018-07-31 | `DimFecha` cubre 2015-01-01 a 2018-12-31. |
| Ventas sin vendedor | 27.658 de 31.465 (87,9 % de las ventas; 26,6 % del ingreso). Son valores nulos, no referencias inexistentes. | Registro "Sin vendedor" (clave -1) en `DimEmpleado`. |
| Clientes sin nombre | 9.546 de 19.820 (48,2 % de los clientes), con el 82,2 % del ingreso. | Se cargan todos. Se genera un nombre "Cliente sin nombre (ID n)" y el atributo `TipoCliente`. |
| Productos sin categoría | 209 de 504, sin ventas registradas. | Se cargan como "Sin categoría". |
| Productos sin color | 248 de 504. | Se cargan como "Sin color". |
| Fechas de envío, cantidades y precios | Sin nulos ni valores inconsistentes. | `DiasEnvio` se calcula directamente. `PrecioUnitario` como DECIMAL(19,4). |
| `Almacenes` | 701 filas, relacionadas solo con `Territorios`. | Fuera del modelo. |

## Cifras de control para validar el ETL

| Control | Valor en el origen (`BikeZ`) |
|---|---|
| Líneas de detalle de venta (`DetalleVentas`) | 121.317 |
| Ventas (`Ventas`) | 31.465 |
| Ingreso total (Cantidad × PrecioUnitario) | 110.373.889,3134 |
| Clientes | 19.820 |
| Productos | 504 |
| Empleados | 290 |
| Territorios | 10 |

Tras la carga, `FactVentas` debe tener 121.317 filas, y la suma de `VentaTotal` debe coincidir con el ingreso total del origen. Las dimensiones deben tener las filas del origen más el registro "Desconocido" (−1).
# Diseño del cubo OLAP (SSAS multidimensional)

Origen: base `BikeZ_DW`. Proyecto: `olap/proyecto-ssas`. Base de datos de Analysis Services: `BikeZ_Cubo`. Cubo: `BikeZ Cubo`.

## Dimensiones y jerarquías

| Dimensión | Jerarquía | Notas |
|---|---|---|
| Fecha (rol doble: Fecha de Venta y Fecha de Envío) | Calendario: Año > Trimestre > Mes > Fecha | Consulta con nombre que excluye el registro "Desconocido"; claves de texto únicas (AAAA-TN, AAAA-MM) |
| Producto | Categoría > Producto | Incluye "Sin categoría" |
| Cliente | Tipo de cliente > Cliente | Separa "Nombre registrado" de "Sin nombre registrado" |
| Empleado (vendedor) | Cargo > Empleado | Incluye "Sin empleado" |
| Territorio | Grupo > País > Territorio | |

## Medidas

| Medida | Agregación | Grupo |
|---|---|---|
| Cantidad, Venta Total, Días de envío | Suma | Ventas |
| Líneas de venta | Recuento | Ventas |
| Cantidad de ventas | Recuento de distintos (VentaID) | Ventas distintas |

## Decisiones

- `PrecioUnitario` no es medida: no es aditiva; el precio promedio se calcula como Venta Total ÷ Cantidad.
- El recuento de distintos va en un grupo de medidas aparte, como exige SSAS.
- Miembros calculados y KPI: se documentan en la siguiente etapa.
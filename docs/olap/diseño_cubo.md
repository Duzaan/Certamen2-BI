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

## Miembros calculados y KPI

| Miembro | Uso | KPI del proyecto |
|---|---|---|
| Ticket Promedio | Venta Total ÷ Cantidad de ventas | KPI 3 |
| Precio Promedio | Venta Total ÷ Cantidad | Apoyo al KPI 2 |
| Dias de envio promedio | Días de envío ÷ Líneas de venta (por línea) | KPI 8 |
| Crecimiento Anual % y Mensual % | ParallelPeriod y PrevMember; devuelven vacío si no hay venta | KPI 4 |
| Participacion % | Venta Total ÷ total de territorios (Root) | KPI 7 |

KPI de SSAS: "Crecimiento anual de ventas" (meta 0, semáforo).

Notas: los datos van de julio de 2015 a junio de 2018 (julio de 2018 es parcial), por lo que el crecimiento anual de 2015 y 2018 no es comparable; se compara por semestres. Los miembros calculados requieren la jerarquía Calendario.
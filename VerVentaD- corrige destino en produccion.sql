

ALTER VIEW [dbo].[VerVentaD]
AS 
SELECT
Venta.ID,
VentaD.Renglon,
VentaD.RenglonSub,
Venta.Empresa,
Venta.Mov,
Venta.MovID,
Venta.Moneda,
Venta.FechaEmision,
"FechaRequerida" = ISNULL(VentaD.FechaRequerida, Venta.FechaRequerida),
"FechaSalida" = DATEADD(day, VentaD.Cantidad-ISNULL(VentaD.CantidadCancelada, 0.0), ISNULL(VentaD.FechaRequerida, Venta.FechaRequerida)),
HoraRequerida = VentaD.HoraRequerida,
Venta.Prioridad,
Venta.Referencia,
Venta.Proyecto,
Venta.Concepto,
Venta.Estatus,
Venta.Cliente,
VentaD.EnviarA,
Venta.DescuentoGlobal,
Venta.SobrePrecio,
Venta.ServicioArticulo,
Venta.ServicioSerie,
Venta.ServicioFecha,
Venta.ServicioNumeroEconomico,
Venta.Sucursal,
Venta.SucursalOrigen,
VentaD.Agente,
VentaD.Almacen,
VentaD.Articulo,
VentaD.SubCuenta,
VentaD.Espacio,
"Cantidad" = VentaD.Cantidad-ISNULL(VentaD.CantidadCancelada, 0.0), 
VentaD.CantidadReservada, 
VentaD.CantidadOrdenada, 
VentaD.CantidadPendiente, 
VentaD.Unidad,
VentaD.Factor,
"CantidadFactor"  = (VentaD.Cantidad-ISNULL(VentaD.CantidadCancelada, 0.0))/VentaD.Factor, 
"ReservadaFactor" = VentaD.CantidadReservada*VentaD.Factor,
"OrdenadaFactor"  = VentaD.CantidadOrdenada*VentaD.Factor,
"PendienteFactor" = VentaD.CantidadPendiente*VentaD.Factor,
VentaD.CantidadInventario,
VentaD.Precio, 
VentaD.DescuentoTipo,
VentaD.DescuentoLinea,
VentaD.Impuesto1,
VentaD.Impuesto2,
VentaD.Impuesto3,
VentaD.DescripcionExtra,
VentaD.Instruccion,
VentaD.PoliticaPrecios,
VentaD.PrecioMoneda,
VentaD.PrecioTipoCambio,
VentaD.Paquete,
VentaD.UEN,
Cte.Nombre CteNombre,
Art.Descripcion1 ArtDescripcion,
Art.SeProduce ArtSeProduce,
Art.SeCompra ArtSeCompra,
Art.Espacios,
Art.EspaciosNivel,
"MovTipo" = mt.Clave,
"Semana" = DATEDIFF(week, GETDATE(), ISNULL(VentaD.FechaRequerida, Venta.FechaRequerida)),
VentaD.Bobina,
INTERCantidadM2,
INTERPrecioM2
FROM
Venta, VentaD, Cte, Art, MovTipo mt
WHERE 
Venta.ID = VentaD.ID AND 
Cte.Cliente = Venta.Cliente AND Art.Articulo = VentaD.Articulo AND mt.Modulo = 'VTAS' AND mt.Mov = Venta.Mov


GO



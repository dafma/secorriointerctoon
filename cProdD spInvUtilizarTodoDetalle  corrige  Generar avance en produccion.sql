
CREATE VIEW [dbo].[cProdD]
AS
SELECT
  ID,
  Renglon,
  RenglonSub,

  RenglonID,
  RenglonTipo,

  AutoGenerado, 
  Almacen,
  Codigo,
  Articulo,
  SubCuenta,
  Cantidad,
  Costo,
  ProdSerieLote,

  CantidadPendiente,
  CantidadReservada,
  CantidadCancelada,
  CantidadOrdenada,
  CantidadA,
  Paquete,

  DestinoTipo,
  Destino,
  DestinoID,
  Aplica,
  AplicaID,

  Cliente,
  Centro,
  CentroDestino,
  Orden,
  OrdenDestino,
  Estacion,
  EstacionDestino,

  Unidad,
  Factor,
  CantidadInventario,

  Ruta,
  Volumen,

  SustitutoArticulo,
  SustitutoSubCuenta,

  FechaRequerida,
  FechaEntrega,
  DescripcionExtra,

  Merma,
  Desperdicio,
  Tipo,
  Comision,
  ManoObra,
  Indirectos,
  Maquila,
  Personal,
  Turno,
  TiempoMuerto,
  Causa,
  Posicion,

  UltimoReservadoCantidad,
  UltimoReservadoFecha,
  Sucursal,
  SucursalOrigen,

  Logico1,
  Logico2,
  Logico3,
  Instruccion,
  Tarima,
  INTERCantidadM2

FROM 
  ProdD


/************************************ VISTAS ********************************/

GO



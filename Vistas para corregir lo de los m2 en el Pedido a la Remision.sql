SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO

if exists (select * from sysobjects where id = object_id('dbo.cVentaD') and sysstat & 0xf = 2) drop view dbo.cVentaD
GO
CREATE VIEW cVentaD
--//WITH ENCRYPTION
AS
	SELECT
		ID,
		Renglon,
		RenglonSub,

		RenglonID,
		RenglonTipo,

		Cantidad,
		Almacen,
		EnviarA,
		Codigo,
		Articulo,
		SubCuenta,
		--nSubCuenta,
		Precio,
		PrecioSugerido,
		DescuentoTipo,
		DescuentoLinea,
		DescuentoImporte,
		Impuesto1,
		Impuesto2,
		Impuesto3,
		DescripcionExtra,
		Costo,
		CostoActividad,
		Paquete,
		ContUso,
		ContUso2,
		ContUso3,

		--  Comision,

		Aplica,
		AplicaID,

		CantidadPendiente,
		CantidadReservada,
		CantidadCancelada,
		CantidadOrdenada,
		CantidadObsequio,

		CantidadA,

		Unidad,
		Factor,
		CantidadInventario,

		SustitutoArticulo,
		SustitutoSubCuenta,
		FechaRequerida,
		HoraRequerida,

		Instruccion,

		UltimoReservadoCantidad,
		UltimoReservadoFecha,
  
		Agente,
		Departamento,
		Sucursal,
		SucursalOrigen,
		AutoLocalidad,
		UEN,
		Espacio,
		CantidadAlterna,
		PoliticaPrecios,
		PrecioMoneda,
		PrecioTipoCambio,
		AFArticulo,
		AFSerie,
		ExcluirPlaneacion,
		Anexo, 
		Estado,
		ExcluirISAN,
		Posicion,
		PresupuestoEsp,
		ProveedorRef,
		TransferirA,
		Tarima,
		ABC,
		TipoImpuesto1,
		TipoImpuesto2,
		TipoImpuesto3,
		OrdenCompra,
  
		TipoRetencion1,
		TipoRetencion2,
		TipoRetencion3,
		Retencion1,
		Retencion2,
		Retencion3,
		AnticipoFacturado,
		AnticipoMoneda,
		AnticipoTipoCambio,
		AnticipoRetencion,
  
		RecargaTelefono,			-- REQ12336 REQ13848
		RecargaConfirmarTelefono,	-- REQ12336 REQ13848
		AplicaRenglon,
		MesLanzamiento,
		Puntos,						-- Monedero
    INTERCantidadM2, 
    INTERPrecioM2, 
    Bobina
	FROM
		VentaD
GO


/***************** cVentaDWMS *******************/
if exists (select * from sysobjects where id = object_id('dbo.cVentaDWMS') and sysstat & 0xf = 2) drop view dbo.cVentaDWMS
GO
CREATE VIEW cVentaDWMS
--//WITH ENCRYPTION
AS
SELECT
  ID,
  Renglon,
  RenglonSub,

  RenglonID,
  RenglonTipo,

  Cantidad,
  Almacen,
  EnviarA,
  Codigo,
  Articulo,
  SubCuenta,
  --nSubCuenta,
  Precio,
  PrecioSugerido,
  DescuentoTipo,
  DescuentoLinea,
  DescuentoImporte,
  Impuesto1,
  Impuesto2,
  Impuesto3,
  DescripcionExtra,
  Costo,
  CostoActividad,
  Paquete,
  ContUso,
  ContUso2,
  ContUso3,

--  Comision,

  Aplica,
  AplicaID,

  CantidadPendiente,
  CantidadReservada,
  CantidadCancelada,
  CantidadOrdenada,
  CantidadObsequio,

  CantidadA,

  Unidad,
  Factor,
  CantidadInventario,

  SustitutoArticulo,
  SustitutoSubCuenta,
  FechaRequerida,
  HoraRequerida,

  Instruccion,

  UltimoReservadoCantidad,
  UltimoReservadoFecha,
  
  Agente,
  Departamento,
  Sucursal,
  SucursalOrigen,
  AutoLocalidad,
  UEN,
  Espacio,
  CantidadAlterna,
  PoliticaPrecios,
  PrecioMoneda,
  PrecioTipoCambio,
  AFArticulo,
  AFSerie,
  ExcluirPlaneacion,
  Anexo, 
  Estado,
  ExcluirISAN,
  Posicion,
  PresupuestoEsp,
  ProveedorRef,
  TransferirA,
  Tarima,
  ABC,
  TipoImpuesto1,
  TipoImpuesto2,
  TipoImpuesto3,
  OrdenCompra,  
  AnticipoFacturado,
  AnticipoMoneda,
  AnticipoTipoCambio,
  AnticipoRetencion,
      INTERCantidadM2, 
    INTERPrecioM2, 
    Bobina
FROM
  VentaD
GO

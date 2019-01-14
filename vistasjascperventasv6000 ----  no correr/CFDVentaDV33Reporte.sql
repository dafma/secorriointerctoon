USE [INTER]
GO

/****** Object:  View [dbo].[CFDVentaDV33Reporte]    Script Date: 28/12/2018 06:13:15 p. m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[CFDVentaDV33Reporte]
AS
SELECT REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,VD.ID))))) + RTRIM(LTRIM(CONVERT(varchar,VD.ID))) +
REPLICATE('0',12-LEN(RTRIM(LTRIM(CONVERT(varchar,VD.Renglon))))) + RTRIM(LTRIM(CONVERT(varchar,VD.Renglon))) +
REPLICATE('0',7-LEN(RTRIM(LTRIM(CONVERT(varchar,VD.RenglonSub))))) + RTRIM(LTRIM(CONVERT(varchar,VD.RenglonSub))) +
REPLICATE(' ',50)
OrdenExportacion,
VD.ID,
VD.Renglon,
VD.RenglonSub,
CPS.Clave																					ClaveProdServV33,
CU.ClaveUnidad																				ClaveUnidadV33,
dbo.fnXMLValor(Art.Unidad)																	VentaDUnidad,
dbo.fnXMLValor(VD.Articulo)																	VentaDArticulo,
CASE WHEN VD.Cantidad-ISNULL(VD.CantidadObsequio,0) = 0
THEN VD.Cantidad
ELSE VD.Cantidad-ISNULL(VD.CantidadObsequio,0)
END VentaDCantidad,
CASE WHEN EmpresaCfg.VentaPreciosImpuestoIncluido = 1
THEN ((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))+
(((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))-
((((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*((ISNULL(VD.DescuentoLinea,0)/100)))+	
((((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
(((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*((ISNULL(VD.DescuentoLinea,0)/100))))*	
(ISNULL(Venta.DescuentoGlobal,0)/100))))*(Isnull(Venta.SobrePrecio/100,0.0))))
*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
ELSE ((VD.Precio)+(((VD.Precio)-
(((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*(ISNULL(VD.DescuentoLinea,0)/100))+				
(((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*(ISNULL(VD.DescuentoLinea,0)/100)))*				
(ISNULL(Venta.DescuentoGlobal,0)/100))))*(Isnull(Venta.SobrePrecio/100,0.0))))
*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
END																							VentaDPrecio,
CASE WHEN VD.Cantidad-ISNULL(VD.CantidadObsequio,0) = 0
THEN CASE WHEN EmpresaCfg.VentaPreciosImpuestoIncluido = 1
THEN (((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*VD.Cantidad)+
((((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*VD.Cantidad)-
((((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*((ISNULL(VD.DescuentoLinea,0)/100)))+	
((((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
(((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*((ISNULL(VD.DescuentoLinea,0)/100))))*	
(ISNULL(Venta.DescuentoGlobal,0)/100))))*(Isnull(Venta.SobrePrecio/100,0.0))))
*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
ELSE ((ISNULL(VD.Precio,0)*VD.Cantidad)+
(((ISNULL(VD.Precio,0)*VD.Cantidad)-
(((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*(ISNULL(VD.DescuentoLinea,0)/100))+				
(((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*(ISNULL(VD.DescuentoLinea,0)/100)))*				
(ISNULL(Venta.DescuentoGlobal,0)/100))))*(Isnull(Venta.SobrePrecio/100,0.0))))
*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
END
ELSE CASE WHEN EmpresaCfg.VentaPreciosImpuestoIncluido = 1
THEN (((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))+
((((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
((((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*((ISNULL(VD.DescuentoLinea,0)/100)))+	
((((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
(((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*((ISNULL(VD.DescuentoLinea,0)/100))))*	
(ISNULL(Venta.DescuentoGlobal,0)/100))))*(Isnull(Venta.SobrePrecio/100,0.0))))
*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
ELSE ((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))+
(((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
(((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*(ISNULL(VD.DescuentoLinea,0)/100))+				
(((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*(ISNULL(VD.DescuentoLinea,0)/100)))*				
(ISNULL(Venta.DescuentoGlobal,0)/100))))*(Isnull(Venta.SobrePrecio/100,0.0))))
*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
END
END VentaDImporte,
CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0
THEN CASE WHEN EmpresaCfg.VentaPreciosImpuestoIncluido = 1
THEN ((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*VD.Cantidad)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
ELSE (ISNULL(VD.Precio,0)*VD.Cantidad)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
END
ELSE
CASE WHEN EmpresaCfg.VentaPreciosImpuestoIncluido = 1
THEN ((((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*((ISNULL(VD.DescuentoLinea,0)/100)))+	
(
(((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
(((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*((ISNULL(VD.DescuentoLinea,0)/100))))*	
(ISNULL(Venta.DescuentoGlobal,0)/100)
))*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
ELSE (((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*(ISNULL(VD.DescuentoLinea,0)/100))+				
(((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*(ISNULL(VD.DescuentoLinea,0)/100)))*				
(ISNULL(Venta.DescuentoGlobal,0)/100)))
*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
END
END																							VentaDDescuentoImporte,
CASE WHEN EmpresaCfg.VentaPreciosImpuestoIncluido = 1
THEN (((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
((((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*((ISNULL(VD.DescuentoLinea,0)/100)))+	
(
(((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
(((((VD.Precio)/((ISNULL(VD.Impuesto2,0.0)/100.0)+1))/((ISNULL(VD.Impuesto1,0.0)/100.0)+1))*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*((ISNULL(VD.DescuentoLinea,0)/100))))*	
(ISNULL(Venta.DescuentoGlobal,0)/100)
)))
*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
ELSE ((VD.Precio*VD.Cantidad)-
(((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*(ISNULL(VD.DescuentoLinea,0)/100))+				
(((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))-
((ISNULL(VD.Precio,0)*(VD.Cantidad-ISNULL(VD.CantidadObsequio,0)))*(ISNULL(VD.DescuentoLinea,0)/100)))*				
(ISNULL(Venta.DescuentoGlobal,0)/100)
)))
*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
END																							VentaDImpuestoBase,
dbo.fnXMLValor(Art.Descripcion1)																VentaDDescripcion,
dbo.fnXMLValor(Art.Descripcion2)																VentaDDescripcion2,
SAI.CuentaPredial																			CuentaPredialV33,
dbo.fnQueCodigo(EmpresaCFD.EAN13, VD.Articulo, VD.SubCuenta, VD.Codigo, Venta.Cliente)		EAN13,
dbo.fnQueCodigo(EmpresaCFD.SKU, VD.Articulo, VD.SubCuenta, VD.Codigo, Venta.Cliente)			SKUCliente,
U.Clave																						UnidadClave,
CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0
THEN (vtc.PrecioSinDL)
ELSE (vtc.Importe/vtc.Cantidad)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
END																							VentaDImporteUnitario,
CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0
THEN (vtc.PrecioSinDL)
ELSE (vtc.SubTotal/Vtc.Cantidad)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
END																							VentaDSubTotalUnitario,
CASE WHEN (VD.Cantidad-ISNULL(VD.CantidadObsequio,0)) = 0
THEN (vtc.PrecioSinDL*VD.Cantidad)
ELSE vtc.SubTotal*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))
END          VentaDSubTotal,
CASE WHEN  EmpresaCfg.VentaPrecioMoneda =1 then
CASE WHEN Vtc.PrecioTotal IS NULL THEN 0.0 ELSE (((Vtc.PrecioTotal*dbo.fneDocVentaFactorPrecio(VD.ID, VD.Renglon, VD.RenglonSub))*ISNULL(VD.PrecioTipoCambio,1.0))/Venta.TipoCambio)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)) END
ELSE
CASE WHEN Vtc.PrecioTotal IS NULL THEN 0.0 ELSE ((Vtc.PrecioTotal*dbo.fneDocVentaFactorPrecio(VD.ID, VD.Renglon, VD.RenglonSub)))*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)) END
END  VentaDPrecioTotal,
VD.Renglon VentaDRenglon,
VD.RenglonSub VentaDRenglonSub,
VD.RenglonID VentaDRenglonID,
VD.RenglonTipo VentaDRenglonTipo,
VD.Almacen VentaDAlmacen,
VD.EnviarA VentaDEnviarA,
VD.Codigo VentaDCodigo,
VD.SubCuenta VentaDSubCuenta,
VD.PrecioSugerido VentaDPrecioSugerido,
VD.DescuentoTipo VentaDDescuentoTipo,
VD.Impuesto3 VentaDImpuesto3,
VD.DescripcionExtra VentaDDescripcionExtra,
VD.Costo VentaDCosto,
VD.CostoActividad VentaDCostoActividad,
VD.Paquete VentaDPaquete,
VD.ContUso VentaDContUso,
VD.Comision VentaDComision,
VD.Aplica VentaDAplica,
VD.AplicaID VentaDAplicaID,
VD.CantidadPendiente VentaDCantidadPendiente,
VD.CantidadReservada VentaDCantidadReservada,
VD.CantidadCancelada VentaDCantidadCancelada,
VD.CantidadOrdenada VentaDCantidadOrdenada,
VD.CantidadEmbarcada VentaDCantidadEmbarcada,
VD.CantidadA VentaDCantidadA,
VD.Factor VentaDFactor,
VD.SustitutoArticulo VentaDSustitutoArticulo,
VD.SustitutoSubCuenta VentaDSustitutoSubCuenta,
VD.FechaRequerida VentaDFechaRequerida,
VD.HoraRequerida VentaDHoraRequerida,
VD.Instruccion VentaDInstruccion,
VD.Agente VentaDAgente,
VD.Departamento VentaDDepartamento,
VD.UltimoReservadoCantidad VentaDUltimoReservadoCantidad,
VD.UltimoReservadoFecha VentaDUltimoReservadoFecha,
VD.Sucursal VentaDSucursal,
VD.PoliticaPrecios VentaDPoliticaPrecios,
VD.SucursalOrigen VentaDSucursalOrigen,
VD.AutoLocalidad VentaDAutoLocalidad,
VD.UEN VentaDUEN,
VD.Espacio VentaDEspacio,
VD.CantidadAlterna VentaDCantidadAlterna,
VD.PrecioMoneda VentaDPrecioMoneda,
VD.PrecioTipoCambio VentaDPrecioTipoCambio,
VD.Estado VentaDEstado,
VD.ServicioNumero VentaDServicioNumero,
VD.AgentesAsignados VentaDAgentesAsignados,
VD.AFArticulo VentaDAFArticulo,
VD.ExcluirPlaneacion VentaDExcluirPlaneacion,
VD.Anexo VentaDAnexo,
VD.AjusteCosteo VentaDAjusteCosteo,
VD.CostoUEPS VentaDCostoUEPS,
VD.CostoPEPS VentaDCostoPEPS,
VD.UltimoCosto VentaDUltimoCosto,
VD.PrecioLista VentaDPrecioLista,
VD.DepartamentoDetallista VentaDDepartamentoDetallista,
VD.PresupuestoEsp VentaDPresupuestoEsp,
VD.Posicion VentaDPosicion,
VD.Puntos VentaDPuntos,
VD.CantidadObsequio VentaDCantidadObsequio,
VD.OfertaID VentaDOfertaID,
VD.ProveedorRef VentaDProveedorRef,
VD.TransferirA VentaDTransferirA,
VD.ArtEstatus VentaDArtEstatus,
VD.ArtSituacion VentaDArtSituacion,
VD.Tarima VentaDTarima,
VD.ExcluirISAN VentaDExcluirISAN,
VD.ContUso2 VentaDContUso2,
VD.ContUso3 VentaDContUso3,
VD.CostoEstandar VentaDCostoEstandar,
VD.ABC VentaDABC,
VD.OrdenCompra VentaDOrdenCompra,
VD.TipoImpuesto1 VentaDTipoImpuesto1,
VD.TipoImpuesto2 VentaDTipoImpuesto2,
VD.TipoImpuesto3 VentaDTipoImpuesto3,
VD.CostoPromedio VentaDCostoPromedio,
VD.CostoReposicion VentaDCostoReposicion,
VD.TipoComprobante VentaDTipoComprobante,
VD.SustentoComprobante VentaDSustentoComprobante,
VD.TipoIdentificacion VentaDTipoIdentificacion,
VD.DerechoDevolucion VentaDDerechoDevolucion,
VD.Establecimiento VentaDEstablecimiento,
VD.PuntoEmision VentaDPuntoEmision,
VD.SecuencialSRI VentaDSecuencialSRI,
VD.AutorizacionSRI VentaDAutorizacionSRI,
VD.VigenteA VentaDVigenteA,
VD.SecuenciaRetencion VentaDSecuenciaRetencion,
VD.Comprobante VentaDComprobante,
VD.FechaContableMov VentaDFechaContableMov,
VD.TipoRetencion1 VentaDTipoRetencion1,
VD.TipoRetencion2 VentaDTipoRetencion2,
VD.TipoRetencion3 VentaDTipoRetencion3,
VD.Retencion1 VentaDRetencion1,
VD.Retencion2 VentaDRetencion2,
VD.Retencion3 VentaDRetencion3,
NULL AS ArtRamaCalculo,                  
NULL AS Cliente75,                    
NULL AS ArtFamilia,                  
NULL AS VentaDInstruccionCalculo,                  
NULL AS VentaDIgualInstruccionCalculo,                  
NULL AS ArtFamiliaInstruccion,                  
NULL AS VentaDIgualCalculo,                    
NULL AS CteTipoGramaje,                  
NULL AS CteTipoGramajeInstruccion,                  
NULL AS SerieloteCteTipoGramajeInstruccion,                  
NULL AS VentaDHojasRenglon,                  
NULL AS HojasRenglon,                  
NULL AS CantidadRenglon,                  
NULL AS ArtRamaMetros,                  
NULL AS BobinasTarimas,              
NULL AS BobinaOP,                  
NULL AS fnProdVenta, --insertarlo como ProdVenta                  
NULL AS CalculoHojas,                  
NULL AS serielotehojasrenglon,                  
NULL AS RamaBOBINAMetrosLineales,                  
NULL AS SerieLoteSincroC,                  
NULL AS SerielotePropiedades,                  
NULL AS Rama,        
NULL AS fnFSC,        
NULL AS fnFSCPEFC,   
NULL AS fnFSCSFI,      
NULL AS fnFSCD,  
NULL AS fnFSCDPEFC,  
NULL AS fnFSCDSFI,      
NULL AS fnFSCD2              
FROM Venta
--JOIN Empresa ON Venta.Empresa = Empresa.Empresa 
--JOIN Cte ON Cte.Cliente = Venta.Cliente 
JOIN VentaD VD
ON Venta.ID = VD.ID
JOIN Art
ON VD.Articulo = Art.Articulo
JOIN SATArticuloInfo SAI
ON VD.Articulo = SAI.Articulo
JOIN Unidad U
ON Art.Unidad = U.Unidad
JOIN EmpresaCFD
ON Venta.Empresa = EmpresaCFD.Empresa
JOIN MovTipo mt
ON mt.Modulo = 'VTAS' AND mt.Mov = Venta.Mov
JOIN EmpresaCfg
ON Venta.Empresa = EmpresaCfg.Empresa
JOIN VentaTCalc vtc
ON vtc.ID = VD.ID AND vtc.Renglon = VD.Renglon AND vtc.RenglonSub = VD.RenglonSub
LEFT JOIN SATCatClaveProdServ CPS
ON SAI.ClaveSAT = CPS.Clave
LEFT JOIN SATCatClaveUnidad CU
ON U.ClaveSAT = CU.ClaveUnidad
--LEFT OUTER JOIN CFDFolio ON CFDFolio.Empresa = Venta.Empresa AND CFDFolio.Modulo = mt.ConsecutivoModulo AND CFDFolio.Mov = mt.ConsecutivoMov AND CFDFolio.FechaAprobacion <= Venta.FechaRegistro                 
--AND dbo.fnFolioConsecutivo(Venta.MovID) BETWEEN CFDFolio.FolioD AND CFDFolio.FolioA AND ISNULL(dbo.fnSerieConsecutivo(Venta.MovID),'') = ISNULL(CFDFolio.Serie,'') AND (CASE WHEN ISNULL(CFDFolio.Nivel,'') = 'Sucursal' THEN CFDFolio.Sucursal ELSE Venta.Sucursal END) = Venta.Sucursal AND CFDFolio.Estatus = 'ALTA'                
WHERE VD.RenglonTipo NOT IN ('C','E')


GO



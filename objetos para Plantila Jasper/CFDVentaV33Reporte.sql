Alter VIEW [dbo].[CFDVentaV33Reporte]
AS
SELECT REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,Vta.ID))))) + RTRIM(LTRIM(CONVERT(varchar,Vta.ID))) +
REPLICATE(' ',12) +
REPLICATE(' ',7) +
REPLICATE(' ',50)
OrdenExportacion,
Vta.ID																				ID,
dbo.fnSerieConsecutivo(Vta.MovID)													VentaSerie,
dbo.fnFolioConsecutivo(Vta.MovID)													VentaFolio,
CONVERT(datetime,Vta.FechaRegistro, 126)												VentaFechaRegistroV33,
CASE WHEN ISNULL(Condicion.TipoCondicion,'') = 'Credito' THEN '99'
WHEN ISNULL(Vta.FormaPagoTipo,'') <> '' THEN FP.ClaveSAT
WHEN ISNULL(VC.FormaCobro1,'') <> '' THEN FP1.ClaveSAT
WHEN ISNULL(CteEmpresaCFD.InfoFormaPago,'') <> '' THEN FP3.ClaveSAT
WHEN ISNULL(CteCFD.InfoFormaPago,'') <> '' THEN FP2.ClaveSAT
ELSE '99' END 																		FormaPagoV33,
dbo.fnXMLValor(REPLACE(REPLACE(Vta.Condicion,'(',''),')',''))						VentaCondicion,
dbo.fnValorCFDVentaV33 (Vta.ID, 1, null)												VentaSubTotal,
dbo.fnValorCFDVentaV33 (Vta.ID, 2, null)												VentaDescuentoImporte,
CASE WHEN ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN) = 1 THEN 'MXN' ELSE SATMon.Clave END	MonedaV33,
CASE WHEN ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN) = 1 THEN '1.0' ELSE Vta.TipoCambio END VentaTipoCambio,
dbo.fnValorCFDVentaV33 (Vta.ID, 3, null)												VentaTotal,
LOWER(mt.CFD_TipoDeComprobante)                                                      VentaTipoComprobante,
SATMetodoPago.IDClave+' '+   SATMetodoPago.Clave										MetodoPagoV33,
EmpresaCP.ClaveCP																	LugarExpedicionEmpresaV33,
SucCP.ClaveCP																		LugarExpedicionSucursalV33,
dbo.fnXMLValor(Empresa.Nombre)										EmpresaNombre,
dbo.fnXMLValor(Empresa.RFC)															EmpresaRFC,
Empresa.FiscalRegimen																EmpresaRegimenFiscalV33,
dbo.fnXMLValor(Sucursal.Nombre)										SucursalNombre,
dbo.fnXMLValor(Sucursal.RFC)																			SucursalRFC,
Sucursal.FiscalRegimen																SucursalRegimenFiscalV33,
CASE WHEN ISNULL(c.ClaveUsoCFDI,'') = '' THEN CteCFD.ClaveUsoCFDI ELSE c.ClaveUsoCFDI END				ClaveUsoCFDIV33,
CASE WHEN SATPais.ClavePais= 'MEX' THEN NULL ELSE SATPais.ClavePais END CteResidenciaFiscalV33,
CteCFD.NumRegIdTrib																	CteNumRegIdTribV33,
dbo.fnXMLValor(Cte.Nombre)											ClienteNombre,
dbo.fnXMLValor(Cte.RFC)																				ClienteRFC,
CASE WHEN Vta.Estatus IN ('CONCLUIDO','PENDIENTE') THEN 'ORIGINAL' ELSE 'DELETE' END VentaEstatusCancelacion,
CASE
WHEN mt.Clave IN ('VTAS.F','VTAS.FM','VTAS.FR') THEN 'INVOICE'
WHEN mt.Clave IN ('VTAS.B','VTAS.D','VTAS.DF')  THEN 'CREDIT_NOTE'
END																					VentaTipoDocumento,
dbo.fnNumeroEnEspanol(vtce.TotalNeto-ISNULL(Vta.Retencion,0.00), CASE WHEN ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN) = 1 THEN 'M.N.' ELSE Vta.Moneda END) VentaImporteLetra,
Vta.OrdenCompra																		VentaOrdenCompra,
Vta.FechaOrdenCompra																	VentaOrdenCompraFecha,
CFDFolio.noAprobacion																CFDnoAprobacion,
VentaEntrega.Recibo																	VentaEntregaRecibo,
VentaEntrega.ReciboFecha																VentaEntregaReciboFecha,
Cte.GLN																				ClienteGLN,
CteDepto.Clave																		CteDeptoClave,
Empresa.GLN																			EmpresaGLN,
ISNULL(CteDeptoEnviarA.ProveedorID, CteEmpresaCFD.ProveedorID)						ClienteProveedorID,
RTRIM(ISNULL(Cte.Direccion,'') + ' ' + ISNULL(Cte.DireccionNumero,'') + ' ' + ISNULL(Cte.DireccionNumeroInt,'')) + ', ' + ISNULL(Cte.Colonia,'') ClienteDireccion,
Cte.Poblacion																		ClienteLocalidad,
Cte.CodigoPostal																		ClienteCodigoPostal,
Mon.Clave																			VentaMoneda,
CASE
WHEN Condicion.TipoCondicion = 'Credito' THEN 'DATE_OF_INVOICE'
WHEN Condicion.TipoCondicion = 'Contado' THEN 'EFFECTIVE_DATE'
END																					VentaTipoPago,
ISNULL(Condicion.DiasVencimiento,0)													CondicionDiasVencimiento,
Descuento.Clave																		VentaDescuentoGlobalClave,
Descuento.Porcentaje																	VentaPorcentajeDescuentoGlobal,
Empresa.Direccion EmpresaCalle,
Empresa.DireccionNumero EmpresaNumeroExterior,
Empresa.DireccionNumeroInt EmpresaNumeroInterior,
Empresa.Colonia EmpresaColonia,
Empresa.Poblacion EmpresaLocalidad,
Empresa.Delegacion EmpresaMunicipio,
Empresa.Estado EmpresaEstado,
Empresa.Pais EmpresaPais,
Empresa.CodigoPostal EmpresaCodigoPostal,
CASE LEN(Empresa.RFC) WHEN 12 THEN NULL ELSE Empresa.RepresentanteCURP END EmpresaRepresentanteCURP,
Sucursal.Direccion SucursalCalle,
Sucursal.DireccionNumero SucursalNumeroExterior,
Sucursal.DireccionNumeroInt SucursalNumeroInterior,
Sucursal.Colonia SucursalColonia,
Sucursal.Delegacion + ', ' + Sucursal.Estado SucursalLocalidad,
Sucursal.Delegacion SucursalMunicipio,
Sucursal.Estado SucursalEstado,
Sucursal.Pais SucursalPais,
Sucursal.CodigoPostal SucursalCodigoPostal,
CteEnviarA.GLN CteEnviarAGLN,
CteEnviarA.Nombre CteEnviarANombre,
CteEnviarA.Direccion CteEnviarACalle,
CteEnviarA.DireccionNumero CteEnviarANumeroExterior,
CteEnviarA.DireccionNumeroInt CteEnviarANumeroInterior,
CteEnviarA.Colonia CteEnviarAColonia,
CteEnviarA.Poblacion CteEnviarALocalidad,
CteEnviarA.Delegacion CteEnviarAMunicipio,
CteEnviarA.Estado CteEnviarAEstado,
CteEnviarA.Pais CteEnviarAPais,
CteEnviarA.CodigoPostal CteEnviarACodigoPostal,
CteEnviarA.Clave CteEnviarAClave,
Cte.Direccion ClienteCalle,
Cte.DireccionNumero ClienteNumeroExterior,
Cte.DireccionNumeroInt ClienteNumeroInterior,
cte.Colonia ClienteColonia,
Cte.Delegacion ClienteMunicipio,
Cte.Estado ClienteEstado,
Cte.Pais ClientePais,
Cte.EntreCalles ClienteEntreCalles,
CFD.Modulo CFDModulo,
CFD.ModuloID CFDModuloID,
CFD.Fecha CFDFecha,
CFD.Ejercicio CFDEjercicio,
CFD.Periodo CFDPeriodo,
CFD.Empresa CFDEmpresa,
CFD.MovID CFDMovID,
CFD.Serie CFDSerie,
CFD.Folio CFDFolio,
CFD.RFC CFDRFC,
CFD.Aprobacion CFDAprobacion,
CFD.Importe CFDImporte,
CFD.Impuesto1 CFDImpuesto1,
CFD.Impuesto2 CFDImpuesto2,
CFD.FechaCancelacion CFDFechaCancelacion,
CFD.noCertificado CFDnoCertificado,
CFD.Sello CFDSello,
CFD.CadenaOriginal CFDCadenaOriginal,
CFD.CadenaOriginal1 CFDCadenaOriginal1,
CFD.CadenaOriginal2 CFDCadenaOriginal2,
CFD.CadenaOriginal3 CFDCadenaOriginal3,
CFD.CadenaOriginal4 CFDCadenaOriginal4,
CFD.CadenaOriginal5 CFDCadenaOriginal5,
CFD.GenerarPDF CFDGenerarPDF,
CFD.Retencion1 CFDRetencion1,
CFD.Retencion2 CFDRetencion2,
CFD.TipoCambio CFDTipoCambio,
CFD.Timbrado CFDTimbrado,
CFD.UUID CFDUUID,
CFD.FechaTimbrado CFDFechaTimbrado,
CFD.SelloSAT CFDSelloSAT,
CFD.TFDVersion CFDTFDVersion,
CFD.noCertificadoSAT CFDnoCertificadoSAT,
Condicion.CFD_MetodoDePago CondicionMetodoDePago,
YEAR(CFDFolio.fechaAprobacion) CFDanoAprobacion,
vta.Vencimiento VentaVencimiento,
vta.FechaRequerida VentaFechaRequerida,
vta.FechaOrdenCompra VentaFechaOrdenCompra,
vta.ReferenciaOrdenCompra VentaReferenciaOrdenCompra,
vta.Atencion VentaAtencion,
vta.Observaciones VentaObservaciones,
vta.AtencionTelefono VentaAtencionTelefono,
dbo.fnCFDVentaMovImpuestoExcento(Vta.ID,(vtce.Impuestos-ISNULL(AnticiposImpuestos,0.0))*dbo.fnCFDTipoCambioMN(Vta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))) VentaImpuestos,
dbo.fnCFDVentaMovRetencionExcento(Vta.ID,Vta.Retencion)*dbo.fnCFDTipoCambioMN(Vta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)) VentaRetencionTotal,
CONVERT(datetime,Vta.FechaRegistro, 126) VentaFechaRegistro,
isnull(SATCatTipoRelacion.ClaveTipoRelacion,'')+' '+isnull(SATCatTipoRelacion.Descripcion,'') AS TipoRelacion,
SFP.Descripcion AS FormaPago,
Vta.OrigenID VentaOrigenID,            
Vta.Referencia VentaReferencia,
convert(varchar, CFDFolio.fechaAprobacion, 103)+ ' '+convert(varchar, CFDFolio.fechaAprobacion, 108) FechaAprobacion,   
empresa.telefonos TelEmpresa, 
empresa.fax FaxEmpresa,          
cte.Telefonos TelCte                           
FROM Venta Vta
JOIN VentaTCalcExportacion Vtce ON Vta.ID = Vtce.ID
JOIN CFD CFD on vta.ID=cfd.ModuloID  AND CFD.Modulo='VTAS'
JOIN MovTipo mt ON mt.Mov = Vta.Mov AND mt.Modulo = 'VTAS'
JOIN Mon ON Vta.Moneda = Mon.Moneda
JOIN Empresa ON Vta.Empresa = Empresa.Empresa
JOIN Sucursal ON Vta.Sucursal = Sucursal.Sucursal
JOIN Cte ON Cte.Cliente = Vta.Cliente
JOIN EmpresaCFD ON Vta.Empresa = EmpresaCFD.Empresa
LEFT JOIN Causa c on Vta.Causa = c.Causa AND c.Modulo = 'VTAS'
LEFT JOIN SATMoneda SATMon ON Mon.Clave = SATMon.Clave
LEFT JOIN SATCatTipoComprobante SATTipComp ON LOWER(mt.CFD_TipoDeComprobante) = LOWER(SATTipComp.Descripcion)
LEFT JOIN SATCatCP EmpresaCP ON Empresa.CodigoPostal = EmpresaCP.ClaveCP
LEFT JOIN SATCatCP SucCP ON Sucursal.CodigoPostal = SucCP.ClaveCP
LEFT JOIN FormaPago FP ON Vta.FormaPagoTipo = FP.FormaPago
LEFT JOIN VentaCobro VC ON Vta.Id = VC.ID
LEFT JOIN FormaPago FP1 ON VC.FormaCobro1 = FP1.FormaPago
LEFT JOIN Condicion ON Condicion.Condicion = Vta.Condicion
LEFT JOIN SATFormaPago SFP ON isnull(condicion.CFD_formaDePago,FP.FormaPago)=ISNULL(SFP.Descripcion,SFP.Descripcion)
LEFT JOIN SATMetodoPago ON Condicion.CFD_metodoDePago = SATMetodoPago.Clave
LEFT JOIN SATPais ON SATPais.Descripcion = Cte.Pais
LEFT JOIN FiscalRegimen FiscalRegimenE ON Empresa.FiscalRegimen = FiscalRegimenE.FiscalRegimen
LEFT JOIN FiscalRegimen FiscalRegimenS ON Sucursal.FiscalRegimen = FiscalRegimenS.FiscalRegimen
LEFT JOIN CteEnviarA ON Vta.Cliente = CteEnviarA.Cliente AND Vta.EnviarA = CteEnviarA.ID
LEFT JOIN CteCFD ON CteCFD.Cliente = Vta.Cliente
left JOIN SATCatUsoCFDI sat on isnull(c.ClaveUsoCFDI,CteCFD.ClaveUsoCFDI)=sat.ClaveUsoCFDI
LEFT JOIN FormaPago FP2 ON CteCFD.InfoFormaPago = FP2.FormaPago
LEFT JOIN CFDFolio ON CFDFolio.Empresa = Vta.Empresa AND CFDFolio.Modulo = mt.ConsecutivoModulo AND CFDFolio.Mov = mt.ConsecutivoMov AND CFDFolio.FechaAprobacion <= Vta.FechaRegistro AND dbo.fnFolioConsecutivo(Vta.MovID) BETWEEN CFDFolio.FolioD AND CFDFolio.FolioA AND ISNULL(dbo.fnSerieConsecutivo(Vta.MovID),'') = ISNULL(CFDFolio.Serie,'') AND (CASE WHEN ISNULL(CFDFolio.Nivel,'') = 'Sucursal' THEN ISNULL(CFDFolio.Sucursal,0) ELSE Vta.Sucursal END) = Vta.Sucursal AND CFDFolio.Estatus = 'ALTA'
LEFT JOIN VentaEntrega ON Vta.ID = VentaEntrega.ID
LEFT JOIN CteDepto ON Vta.Cliente = CteDepto.Cliente AND Vta.Departamento = CteDepto.Departamento
LEFT JOIN CteEmpresaCFD ON Vta.Cliente = CteEmpresaCFD.Cliente AND Vta.Empresa = CteEmpresaCFD.Empresa
LEFT JOIN CteCFDFormaPago ON CteEmpresaCFD.Cliente = CteCFDFormaPago.Cliente
LEFT JOIN FormaPago FP3 ON CteCFDFormaPago.FormaPago = FP3.FormaPago
LEFT JOIN CteDeptoEnviarA ON CteDeptoEnviarA.Empresa = Vta.Empresa AND CteDeptoEnviarA.Departamento = Vta.Departamento AND CteDeptoEnviarA.Cliente = Vta.Cliente AND CteDeptoEnviarA.EnviarA = Vta.EnviarA
LEFT JOIN Descuento ON Descuento.Descuento = Vta.Descuento
LEFT JOIN CFDVentaRelacionadosR CFDRelacionado1 ON Vta.ID =CFDRelacionado1.ID
LEFT JOIN SATCatTipoRelacion ON SATCatTipoRelacion.ClaveTipoRelacion=CFDRelacionado1.TipoRelacion
GO



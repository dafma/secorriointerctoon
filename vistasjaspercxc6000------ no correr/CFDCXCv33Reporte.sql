USE [INTER]
GO

/****** Object:  View [dbo].[CFDCXCv33Reporte]    Script Date: 28/12/2018 06:18:49 p. m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[CFDCXCv33Reporte]
AS
SELECT 'OrdenExportacion'     = REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,c.ID))))) + RTRIM(LTRIM(CONVERT(varchar,c.ID))) +REPLICATE(' ',12) + REPLICATE(' ',7) + REPLICATE(' ',50),
'ID'                    = c.ID,
'Mov'                   = c.Mov,
'EmpresaCalle'			= e.Direccion,
'EmpresaNumeroExterior' = e.DireccionNumero,
'EmpresaNumeroInterior' = e.DireccionNumeroInt,
'EmpresaColonia'		= e.Colonia,
'EmpresaLocalidad'		= e.Poblacion,
'EmpresaMunicipio'		= e.Delegacion,
'EmpresaEstado'			= e.Estado,
'EmpresaPais'			= e.Pais,
'EmpresaCodigoPostal'	= e.CodigoPostal,
'SucursalGLN'            = s.GLN,
'SucursalNombre'         = s.Nombre,
'SucursalRFC'            = s.RFC,
'SucursalCalle'          = s.Direccion,
'SucursalNumeroExterior' = s.DireccionNumero,
'SucursalNumeroInterior' = s.DireccionNumeroInt,
'SucursalColonia'        = s.Colonia,
'SucursalLocalidad'      = s.Delegacion + ', ' + s.Estado,
'SucursalMunicipio'      = s.Delegacion,
'SucursalEstado'         = s.Estado,
'SucursalPais'           = s.Pais,
'SucursalCodigoPostal'   = s.CodigoPostal,
'CxcFechaRegistro'		= c.FechaRegistro,
'CxcSerie'				= dbo.fnSerieConsecutivo(C.MovID),
'CxcFolio'				= dbo.fnFolioConsecutivo(C.MovID),
'CxcCondicion'			= c.Condicion,
'CxcSubTotal'			= dbo.fnCFDCxcImporte(c.ID, (c.Importe+ISNULL(c.Impuestos,0.0)-(SELECT ISNULL(SUM(ISNULL(Importe,0.0)),0.0) FROM CFDCXCMovRetencion WHERE ID = c.ID)), 0)*dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN)),
'CxcTipoComprobante'	= mt.CFD_tipoDeComprobante,
'CxcTotal'				= (ISNULL(c.Importe,0.0)+ISNULL(c.Impuestos,0.0)-(SELECT ISNULL(SUM(ISNULL(Importe,0.0)),0.0) FROM CFDCXCMovRetencion WHERE ID = c.ID))*dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN)),
'ClienteRFC'			= Cte.RFC,
'ClienteNombre'			= Cte.Nombre,
'ClienteCalle'			= Cte.Direccion,
'ClienteNumeroExterior' = Cte.DireccionNumero,
'ClienteNumeroInterior' = Cte.DireccionNumeroInt,
'ClienteColonia'		= Cte.Colonia,
'ClienteLocalidad'		= Cte.Poblacion,
'ClienteMunicipio'		= Cte.Delegacion,
'ClienteEstado'			= Cte.Estado,
'ClientePais'			= Cte.Pais,
'ClienteCodigoPostal'	= Cte.CodigoPostal,
'CFDanoAprobacion'		= YEAR(CFDFolio.FechaAprobacion),
'CFDnoAprobacion'		= CFDFolio.noAprobacion,
'CxcDCantidad'			= '1',
'CxcDUnidad'			= C.Concepto,
'CxcDArticulo'			= C.Concepto,
'CxcDDescripcion'		= C.Concepto,
'CxcDPrecio'			= c.Importe*dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN)),
'CxcDPrecioTotal'		= C.Importe*dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN)),
'CxcImporteImpuesto1'	= dbo.fnCFDCxcMovImpuestoExcento(c.ID,((SELECT SUM(Importe1) FROM MovImpuesto WHERE Modulo = 'CXC' AND ModuloID=c.ID))*dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN))) ,
'CxcImporteImpuesto2'	= dbo.fnCFDCxcMovImpuestoExcento(c.ID,((SELECT SUM(Importe2) FROM MovImpuesto WHERE Modulo = 'CXC' AND ModuloID=c.ID))*dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN))) ,
'CxcImporte'			= c.Importe*dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN)) ,
'CxcRetencion'			= dbo.fnCFDCxcMovRetencionExcento(c.ID,(SELECT ISNULL(SUM(ISNULL(Importe,0.0)),0.0) FROM CFDCXCMovRetencion WHERE ID = c.ID)*dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN))),
'CXCVencimiento'		= c.Vencimiento,
'CXCMoneda'             = CASE WHEN ISNULL(mt.SAT_MN, f.SAT_MN) = 1 THEN 'M.X.' ELSE c.Moneda END,
'CXCTipoCambio'			= c.TipoCambio,
'NumCtaPago'			= NULLIF(RIGHT(c.Referencia, 4),'No Aplica'),
'CFDModulo'             = CFD.Modulo ,
'CFDModuloID'           = CFD.ModuloID,
'CFDFecha'              = CFD.Fecha ,
'CFDEjercicio'          = CFD.Ejercicio,
'CFDPeriodo'            = CFD.Periodo,
'CFDEmpresa'            = CFD.Empresa ,
'CFDMovID'              = CFD.MovID ,
'CFDSerie'              = CFD.Serie ,
'CFDFolio'              = CFD.Folio ,
'CFDRFC'                = CFD.RFC ,
'CFDAprobacion'         = CFD.Aprobacion,
'CFDImporte'            = CFD.Importe,
'CFDImpuesto1'          = CFD.Impuesto1 ,
'CFDImpuesto2'          = CFD.Impuesto2 ,
'CFDFechaCancelacion'   = CFD.FechaCancelacion ,
'CFDnoCertificado'      = CFD.noCertificado ,
'CFDSello'              = CFD.Sello ,
'CFDCadenaOriginal'     = CFD.CadenaOriginal ,
'CFDCadenaOriginal1'    = CFD.CadenaOriginal1 ,
'CFDCadenaOriginal2'    = CFD.CadenaOriginal2 ,
'CFDCadenaOriginal3'    = CFD.CadenaOriginal3 ,
'CFDCadenaOriginal4'    = CFD.CadenaOriginal4 ,
'CFDCadenaOriginal5'    = CFD.CadenaOriginal5 ,
'CFDGenerarPDF'         = CFD.GenerarPDF ,
'CFDRetencion1'         = CFD.Retencion1 ,
'CFDRetencion2'         = CFD.Retencion2 ,
'CFDTipoCambio'         = CFD.TipoCambio ,
'CFDTimbrado'           = CFD.Timbrado ,
'CFDUUID'               = CFD.UUID ,
'CFDFechaTimbrado'      = CFD.FechaTimbrado ,
'CFDSelloSAT'           = CFD.SelloSAT ,
'CFDTFDVersion'         = CFD.TFDVersion ,
'CFDnoCertificadoSAT'   = CFD.noCertificadoSAT ,
dbo.fnSerieConsecutivo(c.MovID)																																				'CxcSerieV33',
dbo.fnFolioConsecutivo(c.MovID)																																				'CxcFolioV33',
c.FechaRegistro																																								'CxcFechaRegistroV33',
CASE WHEN mt.Clave = 'CXC.NC' THEN '23'
ELSE CASE WHEN ISNULL(Condicion.TipoCondicion,'') = 'Credito' THEN '99'
ELSE fp.ClaveSAT+' '+sfp.Descripcion  END END																																'CxcFormaPagoV33',
c.Condicion																																									'CxcCondicionV33',
CASE WHEN (SELECT ISNULL(SUM(SubTotal),0) FROM MovImpuesto WHERE Modulo = 'CXC' AND ModuloID = c.ID AND OrigenModulo = 'VTAS') = 0
THEN
(SELECT SUM(SubTotal) FROM MovImpuesto WHERE Modulo = 'CXC' AND ModuloID = c.ID AND OrigenModulo = 'CXC') *
dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN))
ELSE
(SELECT SUM(SubTotal) FROM MovImpuesto WHERE Modulo = 'CXC' AND ModuloID = c.ID AND OrigenModulo = 'VTAS') *
dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN))
END																																											'CxcSubTotalV33',
SATMon.Clave																																								'CxcMonedaV33',
CASE WHEN SATMon.Clave = 'MXN' THEN CONVERT(INT,c.TipoCambio) ELSE c.TipoCambio END																							'CxcTipoCambioV33',
CASE WHEN (SELECT ISNULL(SUM(SubTotal),0) FROM MovImpuesto WHERE Modulo = 'CXC' AND ModuloID = c.ID AND OrigenModulo = 'VTAS') = 0
THEN
(SELECT SUM(SubTotal) FROM MovImpuesto WHERE Modulo = 'CXC' AND ModuloID = c.ID AND OrigenModulo = 'CXC') +
((SELECT SUM(Importe) FROM CFDCXCMovImpuesto WHERE ID = c.ID) - (SELECT ISNULL(SUM(ISNULL(Importe,0.0)),0.0) FROM CFDCXCMovRetencion WHERE ID = c.ID)) *
dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN))
ELSE
(SELECT SUM(SubTotal) FROM MovImpuesto WHERE Modulo = 'CXC' AND ModuloID = c.ID AND OrigenModulo = 'VTAS') +
((SELECT SUM(Importe) FROM CFDCXCMovImpuesto WHERE ID = c.ID) - (SELECT ISNULL(SUM(ISNULL(Importe,0.0)),0.0) FROM CFDCXCMovRetencion WHERE ID = c.ID)) *
dbo.fnCFDTipoCambioMN(C.TipoCambio, ISNULL(mt.SAT_MN, f.SAT_MN))
END																																											'CxcTotalV33',
CASE WHEN mt.Clave = 'CXC.NC' THEN 'PUE' ELSE SATMetodoPago.IDClave END																										'CxcMetodoPagoV33',
EmpresaCP.ClaveCP																																							'CxcLugarExpedicionEmpresaV33',
SATTipComp.TipoComprobante +' '+SATTipComp.Descripcion																														'CxcTipoComprobanteV33',
SucCP.ClaveCP																																								'CxcLugarExpedicionSucursalV33',
CFDCXCEmisorV33R.CxcEmpresaRFCV33																																			'CxcEmpresaRFCV33',
CFDCXCEmisorV33R.CxcEmpresaNombreV33																																			'CxcEmpresaNombreV33',
CFDCXCEmisorV33R.CxcEmpresaRegimenFiscalV33																																	'CxcEmpresaRegimenFiscalV33',
CFDCXCReceptorV33R.CxcClienteRFCV33																																			'CxcClienteRFCV33',
CFDCXCReceptorV33R.CxcClienteNombreV33																																		'CxcClienteNombreV33',
CFDCXCReceptorV33R.CxcCteResidenciaFiscalV33																																	'CxcCteResidenciaFiscalV33',
CFDCXCReceptorV33R.CxcCteNumRegIdTribV33																																		'CxcCteNumRegIdTribV33',
CFDCXCReceptorV33R.CxcClaveUsoCFDIV33,
SATFormaPago.Descripcion FormaPago,
c.origentipo,
c.origen,
c.origenid,
c.referencia,
c.observaciones,      
convert(varchar, CFDFolio.fechaAprobacion, 103)+ ' '+convert(varchar, CFDFolio.fechaAprobacion, 108) FechaAprobacion,      
e.telefonos TelEmpresa, 
e.fax FaxEmpresa,
cte.Telefonos TelCte,  
case when c.cliente='035' then 'N.A.' else isnull(nullif((select ctecfd.cta from ctecfd where c.cliente=ctecfd.cliente), ''),'No Aplica') end CuentaCte               
FROM Cxc c
JOIN MovTipo mt ON mt.Modulo = 'CXC' AND mt.Mov = c.Mov
JOIN Mon ON c.Moneda = Mon.Moneda
JOIN Empresa e ON c.Empresa = e.Empresa
LEFT JOIN EmpresaCFD f ON e.Empresa = f.Empresa
JOIN Sucursal s ON c.Sucursal = s.Sucursal
JOIN Cte Cte ON Cte.Cliente = c.Cliente
LEFT JOIN SATMoneda SATMon ON Mon.Clave = SATMon.Clave
LEFT JOIN SATCatTipoComprobante SATTipComp ON LOWER(mt.CFD_TipoDeComprobante) = LOWER(SATTipComp.Descripcion)
LEFT JOIN SATCatCP EmpresaCP ON e.CodigoPostal = EmpresaCP.ClaveCP
LEFT JOIN SATCatCP SucCP ON s.CodigoPostal = SucCP.ClaveCP
LEFT JOIN FormaPago fp ON c.Formacobro = FP.FormaPago
LEFT JOIN SATFormaPago sfp ON fp.ClaveSAT=sfp.Clave
LEFT JOIN Condicion ON Condicion.Condicion = c.Condicion
LEFT JOIN SATFormaPago ON Condicion.CFD_formaDePago=SATFormaPago.Descripcion
LEFT JOIN SATMetodoPago ON Condicion.CFD_metodoDePago COLLATE Latin1_general_CI_AI = SATMetodoPago.Clave
LEFT JOIN CFDCXCEmisorV33R ON c.ID = CFDCXCEmisorV33R.CxcIDV33
LEFT JOIN CFDCXCReceptorV33R ON c.ID = CFDCXCReceptorV33R.CxcIDV33
LEFT OUTER JOIN CFDFolio ON CFDFolio.Mov = mt.ConsecutivoMov AND CFDFolio.Modulo = mt.Modulo AND CFDFolio.Empresa = e.Empresa
AND dbo.fnFolioConsecutivo(c.MovID) BETWEEN CFDFolio.FolioD AND CFDFolio.FolioA
AND ISNULL(dbo.fnSerieConsecutivo(c.MovID),'') = ISNULL(CFDFolio.Serie,'')
LEFT OUTER JOIN CFD ON CFD.ModuloID = c.ID AND CFD.Modulo = 'CXC'

GO



USE [INTER]
GO

/****** Object:  View [dbo].[CFDVentaMovRetencion]    Script Date: 28/12/2018 06:14:12 p. m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[CFDVentaMovRetencion] AS
SELECT
'OrdenExportacion'	= REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))))) + RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))) +
REPLICATE(' ',12) +
REPLICATE(' ',7) +
REPLICATE(' ',50),
'ID'					= MovImpuesto.ModuloID,
'Impuesto'			= CONVERT(varchar(50),'IVA'),
'ImpuestoClave'		= CONVERT(varchar(50),'VAT'),
'Tasa'				= ISNULL(MovImpuesto.Impuesto1,0.00),
'Importe'				= SUM(ISNULL(MovImpuesto.Importe1,0.00)*ISNULL(dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)),0.00)),
'CategoriaImpuesto'	= 'RETENIDO',
'ImporteV33'			= 0
FROM MovImpuesto
JOIN Venta ON MovImpuesto.Modulo = 'VTAS' AND MovImpuesto.ModuloId = Venta.ID
JOIN EmpresaCFD ON Venta.Empresa = EmpresaCFD.Empresa
JOIN MovTipo mt ON mt.Modulo = 'VTAS' AND mt.Mov = Venta.Mov
JOIN cte ON Cte.cliente = Venta.Cliente
JOIN EmpresaGral ON Venta.Empresa = EmpresaGral.Empresa
WHERE MovImpuesto.Modulo = 'VTAS'
AND NULLIF(MovImpuesto.Importe1,0.0) IS NOT NULL
AND NULLIF(Venta.Retencion,0.0) IS NOT NULL 
AND ISNULL(MovImpuesto.Excento1,0) <> 1
AND EmpresaGral.TipoImpuesto = 0
GROUP BY MovImpuesto.ModuloID, MovImpuesto.Impuesto1
UNION ALL
SELECT
'OrdenExportacion' =	REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,VentaTCalc.ID))))) + RTRIM(LTRIM(CONVERT(varchar,VentaTCalc.ID))) +
REPLICATE(' ',12) +
REPLICATE(' ',7) +
REPLICATE(' ',50),
'ID'					= VentaTCalc.ID,
'Impuesto'			= CONVERT(varchar(50),'IVA'),
'ImpuestoClave'		= CONVERT(varchar(50),'VAT') ,
'Tasa'				= 4 ,
'Importe'				= (ISNULL(Importe,0.00)*.04)*ISNULL(dbo.fnCFDTipoCambioMN(VentaTCalc.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)),0.00),
'CategoriaImpuesto'	= 'RETENIDO',
'ImporteV33'			= 0
FROM VentaTCalc
JOIN MovTipo ON MovTipo.Modulo = 'VTAS' AND MovTipo.Mov = VentaTcalc.Mov
JOIN EmpresaCFD ON VentaTCalc.Empresa = EmpresaCFD.Empresa
JOIN MovTipo mt ON mt.Modulo = 'VTAS' AND mt.Mov = VentaTCalc.Mov
JOIN EmpresaGral ON VentaTCalc.Empresa = EmpresaGral.Empresa
WHERE Articulo = 'FLETE' AND MovTipo.Clave IN ('VTAS.F', 'VTAS.D', 'VTAS.DF', 'VTAS.B')
AND EmpresaGral.TipoImpuesto = 0
UNION ALL
SELECT
'OrdenExportacion'	= REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))))) + RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))) +
REPLICATE(' ',12) +
REPLICATE(' ',7) +
REPLICATE(' ',50),
'ID'					= MovImpuesto.ModuloID,
'Impuesto'			= CONVERT(varchar(50),'ISR'),
'ImpuestoClave'		= CONVERT(varchar(50),'GST'),
'Tasa'				= ISNULL(MovImpuesto.Retencion1,0.00),
'Importe'				= SUM((ISNULL(MovImpuesto.Retencion1,0.00)/100* ISNULL(MovImpuesto.SubTotal,0.00))*ISNULL(dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)),0.00)),
'CategoriaImpuesto'	= 'RETENIDO',
'ImporteV33'			= SUM((ISNULL(MovImpuesto.SubTotal,0))*(ISNULL(MovImpuesto.Retencion1,0)/100))
FROM MovImpuesto
JOIN Venta ON MovImpuesto.Modulo = 'VTAS' AND MovImpuesto.ModuloId = Venta.ID
JOIN EmpresaCFD ON Venta.Empresa = EmpresaCFD.Empresa
JOIN cte ON Cte.cliente = Venta.Cliente
JOIN MovTipo mt ON mt.Modulo = 'VTAS' AND mt.Mov = Venta.Mov
JOIN EmpresaGral ON Venta.Empresa = EmpresaGral.Empresa
WHERE MovImpuesto.Modulo = 'VTAS'
AND NULLIF(MovImpuesto.Retencion1,0.0) IS NOT NULL
AND NULLIF(Venta.Retencion,0.0) IS NOT NULL
AND ISNULL(MovImpuesto.Excento1,0) <> 1
AND EmpresaGral.TipoImpuesto = 1
GROUP BY MovImpuesto.ModuloID, MovImpuesto.Retencion1
UNION ALL
SELECT
'OrdenExportacion'	= REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))))) + RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))) +
REPLICATE(' ',12) +
REPLICATE(' ',7) +
REPLICATE(' ',50),
'ID'					= MovImpuesto.ModuloID,
'Impuesto'			= CONVERT(varchar(50),'IVA'),
'ImpuestoClave'		= CONVERT(varchar(50),'VAT'),
'Tasa'				= ISNULL(MovImpuesto.Retencion2,0.00),
'Importe'				= SUM((CASE WHEN ISNULL(v.Retencion2BaseImpuesto1,0) = 0 THEN ISNULL(MovImpuesto.SubTotal*(MovImpuesto.Retencion2/100.0), 0.0) ELSE ISNULL(MovImpuesto.Importe1*(MovImpuesto.Retencion2/100.0),0.0) END)*dbo.fnCFDTipoCambioMN(Venta.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))),
'CategoriaImpuesto'	= 'RETENIDO',
'ImporteV33'			= SUM((ISNULL(MovImpuesto.SubTotal,0))*(ISNULL(MovImpuesto.Retencion2,0)/100))
FROM MovImpuesto
JOIN Venta ON MovImpuesto.Modulo = 'VTAS' AND MovImpuesto.ModuloId = Venta.ID
JOIN EmpresaCFD ON Venta.Empresa = EmpresaCFD.Empresa
JOIN cte ON Cte.cliente = Venta.Cliente
JOIN MovTipo mt ON mt.Modulo = 'VTAS' AND mt.Mov = Venta.Mov
JOIN version v ON 1 = 1
JOIN EmpresaGral ON Venta.Empresa = EmpresaGral.Empresa
WHERE MovImpuesto.Modulo = 'VTAS'
AND NULLIF(MovImpuesto.Retencion2,0.0) IS NOT NULL
AND NULLIF(Venta.Retencion,0.0) IS NOT NULL
AND ISNULL(MovImpuesto.Excento2,0) <> 1
AND EmpresaGral.TipoImpuesto = 1
GROUP BY MovImpuesto.ModuloID, MovImpuesto.Retencion2
GO



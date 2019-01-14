USE [INTER]
GO

/****** Object:  View [dbo].[CFDCXCMovRetencion]    Script Date: 28/12/2018 06:20:46 p. m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[CFDCXCMovRetencion] AS
SELECT
REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))))) + RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))) +
REPLICATE(' ',12) +
REPLICATE(' ',7) +
REPLICATE(' ',50)
OrdenExportacion,
MovImpuesto.ModuloID ID,
CONVERT(varchar(50),'ISR') Impuesto,
CONVERT(varchar(50),'VAT') ImpuestoClave,
MovImpuesto.Retencion1 Tasa,
SUM(ISNULL(MovImpuesto.SubTotal*(MovImpuesto.Retencion1/100.0), 0.0)*dbo.fnCFDTipoCambioMN(Cxc.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))) Importe,
'RETENIDO' CategoriaImpuesto
FROM MovImpuesto
JOIN CXC ON MovImpuesto.Modulo = 'Cxc' AND MovImpuesto.ModuloId = Cxc.ID
JOIN EmpresaCFD ON Cxc.Empresa = EmpresaCFD.Empresa
JOIN cte ON Cte.cliente = Cxc.Cliente
JOIN version v ON 1 = 1
JOIN MovTipo mt ON mt.Modulo = 'CXC' AND mt.Mov = Cxc.Mov
WHERE MovImpuesto.Modulo = 'CXC'
AND NULLIF(MovImpuesto.Retencion1,0.0) IS NOT NULL
AND ISNULL(MovImpuesto.Excento1,0) <> 1
GROUP BY
REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))))) + RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))) +
REPLICATE('0',12) +
REPLICATE('0',7) +
REPLICATE(' ',50),
MovImpuesto.ModuloID,
MovImpuesto.Retencion1
UNION ALL
SELECT
REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))))) + RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))) +
REPLICATE(' ',12) +
REPLICATE(' ',7) +
REPLICATE(' ',50)
OrdenExportacion,
MovImpuesto.ModuloID ID,
CONVERT(varchar(50),'IVA') Impuesto,
CONVERT(varchar(50),'VAT') ImpuestoClave,
MovImpuesto.Retencion2 Tasa,
SUM((CASE WHEN ISNULL(v.Retencion2BaseImpuesto1,0) = 0 THEN ISNULL(MovImpuesto.SubTotal*(MovImpuesto.Retencion2/100.0), 0.0) ELSE ISNULL(MovImpuesto.Importe1*(MovImpuesto.Retencion2/100.0),0.0) END)*dbo.fnCFDTipoCambioMN(Cxc.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))) Importe,
'RETENIDO' CategoriaImpuesto
FROM MovImpuesto
JOIN CXC ON MovImpuesto.Modulo = 'Cxc' AND MovImpuesto.ModuloId = Cxc.ID
JOIN EmpresaCFD ON Cxc.Empresa = EmpresaCFD.Empresa
JOIN cte ON Cte.cliente = Cxc.Cliente
JOIN version v ON 1 = 1
JOIN MovTipo mt ON mt.Modulo = 'CXC' AND mt.Mov = Cxc.Mov
WHERE MovImpuesto.Modulo = 'CXC'
AND NULLIF(MovImpuesto.Retencion2,0.0) IS NOT NULL
AND ISNULL(MovImpuesto.Excento2,0) <> 1
GROUP BY
REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))))) + RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))) +
REPLICATE('0',12) +
REPLICATE('0',7) +
REPLICATE(' ',50),
MovImpuesto.ModuloID,
MovImpuesto.Retencion2
GO



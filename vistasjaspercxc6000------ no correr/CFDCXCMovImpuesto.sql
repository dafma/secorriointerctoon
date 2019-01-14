USE [INTER]
GO

/****** Object:  View [dbo].[CFDCXCMovImpuesto]    Script Date: 28/12/2018 06:21:25 p. m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[CFDCXCMovImpuesto] AS
SELECT
REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))))) + RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))) +
REPLICATE(' ',12) +
REPLICATE(' ',7) +
REPLICATE(' ',50)
OrdenExportacion,
MovImpuesto.ModuloID ID,
CONVERT(varchar(50),'IVA') Impuesto,
CONVERT(varchar(50),'VAT') ImpuestoClave,
ISNULL(MovImpuesto.Impuesto1,0) Tasa,
SUM(MovImpuesto.Importe1*dbo.fnCFDTipoCambioMN(Cxc.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)))  Importe,
'TRANSFERIDO' CategoriaImpuesto
FROM MovImpuesto
JOIN CXC ON MovImpuesto.Modulo = 'Cxc' AND MovImpuesto.ModuloId = Cxc.ID
JOIN EmpresaCFD ON Cxc.Empresa = EmpresaCFD.Empresa
JOIN MovTipo mt ON mt.Modulo = 'CXC' AND mt.Mov = Cxc.Mov
WHERE MovImpuesto.Modulo = 'CXC'
AND MovImpuesto.Importe1 IS NOT NULL
AND ISNULL(MovImpuesto.Excento1,0) <> 1
GROUP BY
REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))))) + RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))) +
REPLICATE('0',12) +
REPLICATE('0',7) +
REPLICATE(' ',50),
MovImpuesto.ModuloID,
MovImpuesto.Impuesto1
UNION ALL
SELECT
REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))))) + RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))) +
REPLICATE(' ',12) +
REPLICATE(' ',7) +
REPLICATE(' ',50)
OrdenExportacion,
MovImpuesto.ModuloID ID,
CONVERT(varchar(50),'IEPS') Impuesto,
CONVERT(varchar(50),'GST') ImpuestoClave,
ISNULL(MovImpuesto.Impuesto2,0) Tasa,
SUM(MovImpuesto.Importe2*dbo.fnCFDTipoCambioMN(Cxc.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN))) Importe,
'TRANSFERIDO' CategoriaImpuesto
FROM MovImpuesto
JOIN CXC ON MovImpuesto.Modulo = 'Cxc' AND MovImpuesto.ModuloId = Cxc.ID
JOIN EmpresaCFD ON Cxc.Empresa = EmpresaCFD.Empresa
JOIN MovTipo mt ON mt.Modulo = 'CXC' AND mt.Mov = Cxc.Mov
WHERE MovImpuesto.Modulo = 'CXC'
AND MovImpuesto.Importe2 IS NOT NULL
AND ISNULL(MovImpuesto.Excento2,0) <> 1
GROUP BY
REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))))) + RTRIM(LTRIM(CONVERT(varchar,MovImpuesto.ModuloID))) +
REPLICATE('0',12) +
REPLICATE('0',7) +
REPLICATE(' ',50),
MovImpuesto.ModuloID,
MovImpuesto.Impuesto2
/*
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
MovImpuesto.Impuesto1 Tasa,
MovImpuesto.Importe1*dbo.fnCFDTipoCambioMN(Cxc.TipoCambio, ISNULL(mt.SAT_MN, EmpresaCFD.SAT_MN)) Importe,
'RETENIDO' CategoriaImpuesto
FROM MovImpuesto
JOIN CXC ON MovImpuesto.Modulo = 'Cxc' AND MovImpuesto.ModuloId = Cxc.ID
JOIN EmpresaCFD ON Cxc.Empresa = EmpresaCFD.Empresa
JOIN cte ON Cte.cliente = Cxc.Cliente
WHERE MovImpuesto.Modulo = 'CXC'
AND NULLIF(MovImpuesto.Importe1,0.0) IS NOT NULL
AND NULLIF(Cxc.Retencion,0.0) IS NOT NULL AND NULLIF(Cte.Pitex,'') IS NOT NULL
*/
GO



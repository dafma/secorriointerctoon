USE [INTER]
GO

/****** Object:  View [dbo].[CFDCxcFiscalRegimen]    Script Date: 28/12/2018 06:19:51 p. m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[CFDCxcFiscalRegimen] AS
SELECT  REPLICATE('0', 20 - LEN(RTRIM(LTRIM(CONVERT(varchar, Cxc.ID))))) + RTRIM(LTRIM(CONVERT(varchar, Cxc.ID)))
+ REPLICATE('0',12 - LEN(RTRIM(LTRIM(CONVERT(varchar, 20048))))) + RTRIM(LTRIM(CONVERT(varchar, 2048))) + REPLICATE('0', 7 - LEN(RTRIM(LTRIM(CONVERT(varchar, 0)))))
+ RTRIM(LTRIM(CONVERT(varchar, 0))) + REPLICATE(' ', 50 - LEN(RTRIM(LTRIM(CONVERT(varchar, dbo.fnCFDFlexRegimenFiscal(Cxc.Empresa, 'CXC', Cxc.Concepto))))))
+ RTRIM(LTRIM(CONVERT(varchar, dbo.fnCFDFlexRegimenFiscal(Cxc.Empresa, 'CXC', Cxc.Concepto))))
OrdenExportacion,
Cxc.ID,
dbo.fnCFDFlexRegimenFiscal(Cxc.Empresa, 'CXC', Cxc.Concepto) EmisorRegimenFiscal
FROM  Cxc
GO



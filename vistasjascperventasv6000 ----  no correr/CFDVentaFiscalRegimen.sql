USE [INTER]
GO

/****** Object:  View [dbo].[CFDVentaFiscalRegimen]    Script Date: 28/12/2018 06:11:03 p. m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[CFDVentaFiscalRegimen] AS
SELECT  REPLICATE('0', 20 - LEN(RTRIM(LTRIM(CONVERT(varchar, Venta.ID))))) + RTRIM(LTRIM(CONVERT(varchar, Venta.ID)))
+ REPLICATE('0', 12 - LEN(RTRIM(LTRIM(CONVERT(varchar, 20048))))) + RTRIM(LTRIM(CONVERT(varchar, 2048))) + REPLICATE('0', 7 - LEN(RTRIM(LTRIM(CONVERT(varchar, 0)))))
+ RTRIM(LTRIM(CONVERT(varchar, 0))) + REPLICATE(' ', 50 - LEN(RTRIM(LTRIM(CONVERT(varchar, dbo.fnCFDFlexRegimenFiscal(Venta.Empresa, 'VTAS', Venta.Concepto))))))
+ RTRIM(LTRIM(CONVERT(varchar, dbo.fnCFDFlexRegimenFiscal(Venta.Empresa, 'VTAS', Venta.Concepto))))
OrdenExportacion,
Venta.ID,
dbo.fnCFDFlexRegimenFiscal(Venta.Empresa, 'VTAS', Venta.Concepto) EmisorRegimenFiscal
FROM  Venta
GO



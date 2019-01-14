USE [INTER]
GO

/****** Object:  View [dbo].[CFDVentaPedimento]    Script Date: 28/12/2018 06:13:42 p. m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[CFDVentaPedimento] AS
SELECT
REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,VentaD.ID))))) + RTRIM(LTRIM(CONVERT(varchar,VentaD.ID))) +
REPLICATE('0',12-LEN(RTRIM(LTRIM(CONVERT(varchar,VentaD.Renglon))))) + RTRIM(LTRIM(CONVERT(varchar,VentaD.Renglon))) +
REPLICATE('0',7-LEN(RTRIM(LTRIM(CONVERT(varchar,VentaD.RenglonSub))))) + RTRIM(LTRIM(CONVERT(varchar,VentaD.RenglonSub))) +
RTRIM(SerieLoteMov.SerieLote) + REPLICATE (' ', 50 - LEN(RTRIM(SerieLoteMov.SerieLote)))
OrdenExportacion,
SerieLoteMov.ID ID,
VentaD.Renglon,
VentaD.RenglonSub,
SerieLoteMov.SerieLote,
SerieLoteMov.Cantidad,
SerieLoteMov.Propiedades,
SerieLoteMov.Ubicacion,
SerieLoteMov.Localizacion,
SerieLoteMov.ArtCostoInv,
SerieLoteprop.Fecha1,
SerieLoteprop.Fecha2,
SerieLoteprop.Fecha3,
SerieLoteprop.PedimentoClave,
SerieLoteprop.PedimentoRegimen,
SerieLoteprop.AgenteAduanal,
SerieLoteprop.Aduana,
SerieLoteprop.PedimentoTipo,
Aduana.GLN AduanaGLN
FROM SerieLoteMov JOIN VentaD
ON SerieLoteMov.ID = VentaD.ID AND SerieLoteMov.RenglonID = VentaD.RenglonID AND SerieLoteMov.Articulo = VentaD.Articulo
JOIN SerieLoteProp ON SerieLoteMov.Propiedades = SerieLoteProp.Propiedades
LEFT OUTER JOIN Aduana ON SerieLoteProp.Aduana = Aduana.Aduana
WHERE SerieLoteMov.Modulo = 'VTAS'
GO



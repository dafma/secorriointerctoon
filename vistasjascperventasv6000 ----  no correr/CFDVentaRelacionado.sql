USE [INTER]
GO

/****** Object:  View [dbo].[CFDVentaRelacionado]    Script Date: 28/12/2018 06:15:51 p. m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[CFDVentaRelacionado]
AS
SELECT DISTINCT
REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,vd.ID))))) + RTRIM(LTRIM(CONVERT(varchar,vd.ID))) +
REPLICATE(' ',12) +
REPLICATE(' ',7) +
REPLICATE(' ',50)								OrdenExportacion,
vd.ID											ID,
vd.Modulo										Modulo,
vd.ModuloOrigen									ModuloOrigen,
vd.IdOrigen										IdOrigen,
CONVERT(VARCHAR(255),CF.UUID)					UUID
FROM VentaOrigenDevolucion vd
JOIN CFD CF
ON vd.ModuloOrigen = CF.Modulo
AND vd.IdOrigen =  CF.ModuloID
WHERE vd.Modulo = 'VTAS'
AND ISNULL(CONVERT(VARCHAR(255),CF.UUID),'') <> ''
UNION
SELECT DISTINCT
REPLICATE('0',20-LEN(RTRIM(LTRIM(CONVERT(varchar,vd.ID))))) + RTRIM(LTRIM(CONVERT(varchar,vd.ID))) +
REPLICATE(' ',12) +
REPLICATE(' ',7) +
REPLICATE(' ',50)								OrdenExportacion,
vd.ID											ID,
vd.Modulo										Modulo,
vd.ModuloOrigen									ModuloOrigen,
vd.IdOrigen										IdOrigen,
CONVERT(VARCHAR(255),CF.UUID)					UUID
FROM VentaOrigenDevolucion vd
JOIN CFDSaldoInicial CF
ON vd.ModuloOrigen = CF.Modulo
AND vd.IdOrigen =  CF.ModuloID
WHERE vd.Modulo = 'VTAS'
AND ISNULL(CONVERT(VARCHAR(255),CF.UUID),'') <> ''
GO



USE [INTER]
GO

/****** Object:  View [dbo].[CFDVentaCadenaOriginal]    Script Date: 28/12/2018 06:15:11 p. m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[CFDVentaCadenaOriginal] AS
SELECT * FROM dbo.fnCFDVentaCadenaOriginal()
GO



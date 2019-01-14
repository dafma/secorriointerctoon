USE [INTER]
GO

/****** Object:  View [dbo].[CFDCxcCadenaOriginal]    Script Date: 28/12/2018 06:21:53 p. m. ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[CFDCxcCadenaOriginal] AS
SELECT * FROM dbo.fnCFDCxcCadenaOriginal()
GO



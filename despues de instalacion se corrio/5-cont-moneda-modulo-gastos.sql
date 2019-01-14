/*** ContMoneda ***/
if exists (select * from sysobjects where id = object_id('dbo.ContMoneda') and type = 'V') drop view dbo.ContMoneda
GO
CREATE VIEW ContMoneda
--//WITH ENCRYPTION
AS 
SELECT 
  ec.Empresa,
  ec.ContMoneda,
  m.TipoCambio,
  m.TipoCambio TipoCambioInv
  FROM EmpresaCfg ec JOIN Mon m
    ON m.Moneda = ec.ContMoneda
GO

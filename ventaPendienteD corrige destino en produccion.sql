alter VIEW [dbo].[VentaPendienteD]
AS 
SELECT * 
FROM VerVentaD
WHERE UPPER(Estatus) IN ('PENDIENTE', 'CONFIRMAR') AND (CantidadReservada > 0.0 OR CantidadOrdenada > 0.0 OR CantidadPendiente > 0.0)
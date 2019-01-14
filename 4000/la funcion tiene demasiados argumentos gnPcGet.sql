CREATE FUNCTION fnOfertaArtCostoBase (@ID int, @Articulo varchar(20))
RETURNS money
WITH ENCRYPTION
AS BEGIN
DECLARE
@Base	varchar(50),
@Empresa	varchar(5),
@Moneda	varchar(10),
@TipoCambio	float
SELECT @Empresa = o.Empresa, @Moneda = o.Moneda, @TipoCambio = o.TipoCambio, @Base = gral.CostoBase
FROM Oferta o
JOIN EmpresaGral gral ON gral.Empresa = o.Empresa
WHERE o.ID = @ID
RETURN(SELECT dbo.fnPCGet(@Empresa, 0, @Moneda, @TipoCambio, @Articulo, NULL, @Base))
END
CREATE PROCEDURE spOfertaProcesar
@Empresa		varchar(5),
@Sucursal		int,
@Moneda			varchar(10),
@TipoCambio		float,
@ListaPrecios	varchar(50),
@ID				int	= NULL
WITH ENCRYPTION
AS BEGIN
DECLARE
@CfgCostoBase			varchar(50),
@CfgOfertaNivelopcion	bit,
@Articulo				varchar(20),
@SubCuenta				varchar(50),
@ArtCantidadTotal		float,
@ArtPrecioSugerido		float,
@ArtCostoBase			float,
@ArtPrecio				float,
@ArtDescuento			float,
@ArtDescuentoImporte	money,
@ArtPuntos				float,
@ArtPuntosPorcentaje	float,
@ArtComision			float,
@ArtComisionPorcentaje	float,
@ArtOfertaID			int,
@RID					int,
@Renglon				float,
@RenglonSub				int,
@Aplica					bit
SELECT @CfgCostoBase = CostoBase
FROM EmpresaGral
WHERE Empresa = @Empresa
SELECT @CfgOfertaNivelopcion = ISNULL(OfertaNivelopcion, 0)
FROM EmpresaCfg2
WHERE Empresa = @Empresa
EXEC spOfertaObsequiosMultiples @Empresa, @Sucursal, @Moneda, @TipoCambio
EXEC spOfertaArmada @Empresa, @Sucursal, @Moneda, @TipoCambio
IF @CfgOfertaNivelopcion = 1
DECLARE crVentaD CURSOR LOCAL FOR
SELECT Articulo, ISNULL(RTRIM(SubCuenta), ''), MIN(PrecioSugerido), SUM(Cantidad)
FROM #VentaD
WHERE NULLIF(OfertaID, 0) IS NULL
GROUP BY Articulo, ISNULL(RTRIM(SubCuenta), '')
ELSE
DECLARE crVentaD CURSOR LOCAL FOR
SELECT Articulo, CONVERT(char(50), ''), MIN(PrecioSugerido), SUM(Cantidad)
FROM #VentaD
WHERE NULLIF(OfertaID, 0) IS NULL
GROUP BY Articulo
OPEN crVentaD
FETCH NEXT FROM crVentaD INTO @Articulo, @SubCuenta, @ArtPrecioSugerido, @ArtCantidadTotal
WHILE @@FETCH_STATUS <> -1
BEGIN
SELECT @Aplica = 1
EXEC xpOfertaAplicarDetalle @ID, @Articulo, @Aplica OUTPUT
IF @@FETCH_STATUS <> -2 AND @Aplica = 1
BEGIN
SELECT @ArtCostoBase = dbo.fnPCGet(@Empresa, 0, @Moneda, @TipoCambio, @Articulo, @SubCuenta,  @CfgCostoBase)
SELECT @ArtPrecio = NULL, @ArtDescuento = NULL, @ArtDescuentoImporte = NULL, @ArtPuntos = NULL, @ArtPuntosPorcentaje = NULL,
@ArtComision = NULL, @ArtComisionPorcentaje = NULL, @ArtOfertaID = NULL
EXEC spOfertaNormal @Empresa, @Sucursal, @Moneda, @TipoCambio, @Articulo, @SubCuenta, @ArtCantidadTotal, @ArtCostoBase, @ArtPrecioSugerido,
@ArtPrecio OUTPUT, @ArtDescuento OUTPUT, @ArtDescuentoImporte OUTPUT, @ArtPuntos OUTPUT, @ArtPuntosPorcentaje OUTPUT,
@ArtComision OUTPUT, @ArtComisionPorcentaje OUTPUT, @ArtOfertaID OUTPUT, @CfgOfertaNivelopcion
IF @CfgOfertaNivelopcion = 1
UPDATE #VentaD
SET Precio = ISNULL(@ArtPrecio, PrecioSugerido),
Descuento = @ArtDescuento,
DescuentoImporte = @ArtDescuentoImporte,
Puntos = @ArtPuntos,
PuntosPorcentaje = @ArtPuntosPorcentaje,
Comision = @ArtComision,
ComisionPorcentaje = @ArtComisionPorcentaje,
OfertaID = @ArtOfertaID
WHERE Articulo = @Articulo AND ISNULL(SubCuenta, '') = @SubCuenta
ELSE
UPDATE #VentaD
SET Precio = ISNULL(@ArtPrecio, PrecioSugerido),
Descuento = @ArtDescuento,
DescuentoImporte = @ArtDescuentoImporte,
Puntos = @ArtPuntos,
PuntosPorcentaje = @ArtPuntosPorcentaje,
Comision = @ArtComision,
ComisionPorcentaje = @ArtComisionPorcentaje,
OfertaID = @ArtOfertaID
WHERE Articulo = @Articulo
END
FETCH NEXT FROM crVentaD INTO @Articulo, @SubCuenta, @ArtPrecioSugerido, @ArtCantidadTotal
END  
CLOSE crVentaD
DEALLOCATE crVentaD
EXEC spOfertaGrupal @Empresa, @Sucursal, @Moneda, @TipoCambio
DECLARE crArtObsequio CURSOR LOCAL FOR
SELECT Articulo
FROM #ArtObsequio
ORDER BY Articulo
OPEN crArtObsequio
FETCH NEXT FROM crArtObsequio INTO @Articulo
WHILE @@FETCH_STATUS <> -1
BEGIN
IF @@FETCH_STATUS <> -2
BEGIN
SELECT @RID = MIN(RID)
FROM #VentaD
WHERE Articulo = @Articulo AND ISNULL(ABS(Cantidad), 0.0) - ISNULL(CantidadObsequio, 0.0) > 0.0 
UPDATE #VentaD
SET CantidadObsequio = ISNULL(CantidadObsequio, 0.0) + 1.0
WHERE RID = @RID
END
FETCH NEXT FROM crArtObsequio INTO @Articulo
END  
CLOSE crArtObsequio
DEALLOCATE crArtObsequio
RETURN
END
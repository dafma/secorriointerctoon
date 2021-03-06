ALTER PROCEDURE [dbo].[xpUnidadFactorProd]
@CfgMultiUnidades	bit,
@CfgMultiUnidadesNivel	char(20),
@Articulo		char(20),
@SubCuenta		varchar(50),
@Unidad			varchar(50),
@Factor			float		OUTPUT,
@Decimales		int		OUTPUT,
@Ok			int		OUTPUT,
@OkRef			varchar(255)	OUTPUT
AS BEGIN
SELECT @Factor = 1.0
SELECT @Unidad = NULLIF(RTRIM(@Unidad), '')
IF @CfgMultiUnidades = 1
BEGIN
IF @Unidad IS NULL SELECT @Ok = 20150 ELSE
IF @CfgMultiUnidadesNivel = 'ARTICULO'
EXEC xpArtUnidadFactor @Articulo, @SubCuenta, @Unidad, @Factor OUTPUT, @Decimales OUTPUT, @OK OUTPUT
ELSE BEGIN
IF @Ok IS NULL
EXEC xpUnidadFactor @Articulo, @SubCuenta, @Unidad, @Factor OUTPUT, @Decimales OUTPUT
END
END
IF @Ok IS NOT NULL SELECT @OkRef = @Articulo
RETURN
END
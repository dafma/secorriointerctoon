ALTER PROCEDURE [dbo].[xpArtUnidadFactor]
@Articulo	char(20),
@SubCuenta	varchar(50),
@MovUnidad	varchar(50),
@Factor	 	float	OUTPUT,
@Decimales	int	OUTPUT,
@Ok		int	OUTPUT
AS BEGIN
SELECT @Factor = Factor
FROM ArtUnidad
WHERE Articulo = @Articulo AND Unidad = @MovUnidad
SELECT @Decimales = 0
SELECT @Decimales = ISNULL(Decimales, 0.0)
FROM Unidad
WHERE Unidad = @MovUnidad
RETURN
END

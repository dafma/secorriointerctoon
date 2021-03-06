ALTER PROCEDURE [dbo].[xpUnidadFactor]
@Articulo	char(20),
@SubCuenta	varchar(50),
@MovUnidad	varchar(50),
@Factor	 	float	OUTPUT,
@Decimales	int	OUTPUT
AS BEGIN
SELECT @Factor = 1.0
SELECT @Factor = ISNULL(NULLIF(Factor, 0.0), 1.0), @Decimales = ISNULL(Decimales, 0.0)
FROM Unidad
WHERE Unidad = @MovUnidad
RETURN
END

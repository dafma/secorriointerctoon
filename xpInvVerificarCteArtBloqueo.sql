ALTER PROCEDURE [dbo].[xpInvVerificarCteArtBloqueo]
@Empresa		char(5),
@ID			int,
@Usuario		char(10),
@Cliente		char(10),
@Articulo		char(20),
@Ok			int		OUTPUT,
@OkRef			varchar(255)	OUTPUT
AS BEGIN
DECLARE
@Categoria	varchar(50),
@Grupo	varchar(50),
@Familia	varchar(50),
@Fabricante	varchar(50)
IF EXISTS(SELECT * FROM CteArtBloqueo WHERE Cliente = @Cliente)
BEGIN
SELECT @Categoria  = Categoria,
@Grupo      = Grupo,
@Familia    = Familia,
@Fabricante = Fabricante
FROM Art
WHERE Articulo = @Articulo
IF EXISTS(
SELECT *
FROM CteArtBloqueo
WHERE Cliente = @Cliente
AND ((UPPER(Agrupador) = 'CATEGORIA'  AND Nombre = @Categoria)
OR (UPPER(Agrupador)  = 'GRUPO'      AND Nombre = @Grupo)
OR (UPPER(Agrupador)  = 'FAMILIA'    AND Nombre = @Familia)
OR (UPPER(Agrupador)  = 'FABRICANTE' AND Nombre = @Fabricante)))
SELECT @Ok = 65050, @OkRef = @Articulo
END
RETURN
END

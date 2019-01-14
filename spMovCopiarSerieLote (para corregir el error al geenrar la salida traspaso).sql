

ALTER PROCEDURE [dbo].[spMovCopiarSerieLote]
		   @Sucursal	int,
		   @Modulo	char(5),
    		   @OID         int,
                   @DID		int,
		   @CopiarArtCostoInv	bit = 0
		   --@Base			char(20)
--//WITH ENCRYPTION
AS BEGIN
DECLARE
		@AlmWMS		bit
		
	IF @Modulo = 'VTAS'
		BEGIN
			SELECT @AlmWMS = A.WMS FROM Venta V JOIN Alm A ON V.Almacen = A.Almacen WHERE V.ID = @DID
		END
	IF @Modulo = 'INV'
		BEGIN
			SELECT @AlmWMS = A.WMS FROM Inv V JOIN Alm A ON V.Almacen = A.Almacen WHERE V.ID = @DID
		END

	IF @Modulo = 'TMA'
		BEGIN
			SELECT @AlmWMS = A.WMS FROM Tma V JOIN Alm A ON V.Almacen = A.Almacen WHERE V.ID = @DID
		END
		
	IF @Modulo = 'COMS'
		BEGIN
			SELECT @AlmWMS = A.WMS FROM Compra V JOIN Alm A ON V.Almacen = A.Almacen WHERE V.ID = @DID
		END		
	
	IF @AlmWMS = 1
		INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad, CantidadAlterna, Propiedades, Ubicacion, Cliente, Localizacion, ArtCostoInv, Tarima)
		SELECT @Sucursal, m.Empresa, m.Modulo, @DID, m.RenglonID, m.Articulo, m.SubCuenta, m.SerieLote, m.Cantidad, m.CantidadAlterna, m.Propiedades, m.Ubicacion, m.Cliente, m.Localizacion, CASE WHEN @CopiarArtCostoInv = 1 THEN m.ArtCostoInv ELSE NULL END, Tarima
		  FROM SerieLoteMov m
		 WHERE m.Modulo = @Modulo AND m.ID = @OID
	ELSE
		INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad, CantidadAlterna, Propiedades, Ubicacion, Cliente, Localizacion, ArtCostoInv, Tarima)
		SELECT @Sucursal, m.Empresa, m.Modulo, @DID, m.RenglonID, m.Articulo, m.SubCuenta, m.SerieLote, SUM(m.Cantidad), NULLIF(SUM(ISNULL(m.CantidadAlterna,0)),0), m.Propiedades, m.Ubicacion, m.Cliente, m.Localizacion, CASE WHEN @CopiarArtCostoInv = 1 THEN m.ArtCostoInv ELSE NULL END, ''
		  FROM SerieLoteMov m
		 WHERE m.Modulo = @Modulo AND m.ID = @OID
      GROUP BY Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Propiedades, Ubicacion, Cliente, Localizacion, ArtCostoInv
END

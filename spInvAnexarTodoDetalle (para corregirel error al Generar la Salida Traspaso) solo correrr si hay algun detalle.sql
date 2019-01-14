/**************** spInvAnexarTodoDetalle ****************/
if exists (select * from sysobjects where id = object_id('dbo.spInvAnexarTodoDetalle') and type = 'P') drop procedure dbo.spInvAnexarTodoDetalle
GO        

     
CREATE PROCEDURE spInvAnexarTodoDetalle
		   @Empresa		char(5),
		   @Modulo		char(5),
    		   @ID                	int,
                   @AnexoID		int,
		   @CfgImpInc		bit,
  		   @CfgMultiUnidades	bit,
		   @Ok			int	OUTPUT,
		   @CfgPrecioMoneda	bit = 0
--//WITH ENCRYPTION
AS BEGIN
  DECLARE
    @Renglon 		float,
    @DescuentoGlobal	float,
    @SobrePrecio	float,
    @RenglonID int

  -- SET nocount ON
  IF @Modulo = 'VTAS'
  BEGIN
    SELECT @DescuentoGlobal = DescuentoGlobal, @SobrePrecio = SobrePrecio FROM Venta WHERE ID = @AnexoID
    SELECT @Renglon = MAX(Renglon), @RenglonID = MAX(RenglonID) FROM VentaD WHERE ID = @AnexoID
    
    IF ISNULL(@CfgMultiUnidades, 0) = 0
      UPDATE d
         SET d.Unidad = a.Unidad
        FROM VentaD d
        JOIN Art a ON d.Articulo = a.Articulo
       WHERE d.ID = @ID
    
    SELECT * INTO #VentaDetalle FROM cVentaD WHERE ID = @ID
    IF @@ERROR <> 0 SELECT @Ok = 1

    UPDATE #VentaDetalle SET ID = @AnexoID, Renglon = Renglon + @Renglon, RenglonID = RenglonID + @RenglonID, CantidadPendiente = Cantidad, AplicaRenglon = @Renglon
    IF @@ERROR <> 0 SELECT @Ok = 1

    -- Actualizar Descuento Importe
    UPDATE #VentaDetalle SET DescuentoImporte = (Cantidad*Precio)*(DescuentoLinea/100.0), CantidadA = Cantidad
    IF @@ERROR <> 0 SELECT @Ok = 1


    IF EXISTS ( SELECT s.SerieLote FROM SerieLoteMov s JOIN Art a ON s.Articulo = a.Articulo 
                                  WHERE s.Modulo = @Modulo AND s.ID IN (@AnexoID, @ID) AND a.tipo = 'SERIE'
                                  GROUP BY s.Empresa, s.Modulo, s.Articulo, s.SubCuenta, s.SerieLote
                                 HAVING COUNT(SerieLote) > 1 )

       SELECT @Ok = 20080 

    IF @Ok IS NULL
      INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad, CantidadAlterna, Propiedades, Ubicacion, Cliente, Localizacion, ArtCostoInv)
      SELECT m.Sucursal, m.Empresa, m.Modulo, @AnexoID, m.RenglonID+@RenglonID, m.Articulo, m.SubCuenta, m.SerieLote, m.Cantidad, m.CantidadAlterna, m.Propiedades, m.Ubicacion, m.Cliente, m.Localizacion, m.ArtCostoInv
        FROM SerieLoteMov m
       WHERE m.Modulo = @Modulo AND m.ID = @ID
           IF @@ERROR <> 0 SELECT @Ok = 1

    IF @Ok IS NULL  
      INSERT INTO cVentaD SELECT * FROM #VentaDetalle --WHERE ID = @ID
      IF @@ERROR <> 0 SELECT @Ok = 1

    DROP TABLE #VentaDetalle
    IF @@ERROR <> 0 SELECT @Ok = 1

    EXEC spInvReCalcEncabezado @AnexoID, @Modulo, @CfgImpInc, @CfgMultiUnidades, @DescuentoGlobal, @SobrePrecio, @CfgPrecioMoneda = @CfgPrecioMoneda
  END

  RETURN
END
GO
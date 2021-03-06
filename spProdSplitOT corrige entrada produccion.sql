
ALTER PROCEDURE [dbo].[spProdSplitOT]
		   @Sucursal		int,
    		   @OPID           	int,
		   @Renglon		float,
	           @RenglonSub		int,
	           @CantidadOriginal	float,
	           @CantidadNueva	float,
		   @OrdenDestino	int,
		   @OrdenSiguiente	int,
                   @CentroDestino	char(10),
		   @CentroSiguiente	char(10),
                   @EstacionDestino	char(10),
		   @EstacionSiguiente	char(10),
           @Instruccion  varchar(50) = null
----WITH ENCRYPTION
AS BEGIN
  DECLARE
    @Dif 		float,
    @RenglonSubN	int

  SELECT @Dif = @CantidadOriginal - @CantidadNueva 
  IF @Dif > 0.0
  BEGIN
    SELECT * INTO #ProdDetalle 
      FROM cProdD 
     WHERE ID = @OPID AND Renglon = @Renglon AND RenglonSub = @RenglonSub 

---select @OPID,@Renglon ,@RenglonSub, @Instruccion
----select * from #ProdDetalle


    SELECT @RenglonSubN = ISNULL(MAX(RenglonSub), 0) + 1 
      FROM ProdD 
     WHERE ID = @OPID AND Renglon = @Renglon

    UPDATE #ProdDetalle 
       SET Sucursal = @Sucursal, RenglonSub = @RenglonSubN, Cantidad = @Dif, CantidadPendiente = @Dif

    UPDATE #ProdDetalle 
       SET CantidadInventario = Cantidad*Factor

    INSERT INTO cProdD SELECT * FROM #ProdDetalle

    UPDATE ProdD 
       SET Orden = @OrdenDestino,
           OrdenDestino = @OrdenSiguiente,
           Centro = @CentroDestino, 
           CentroDestino = @CentroSiguiente,
           Estacion = @EstacionDestino, 
           EstacionDestino = @EstacionSiguiente,
           Cantidad = ISNULL(Cantidad, 0.0) - @Dif, CantidadPendiente = ISNULL(CantidadPendiente, 0.0) - @Dif, 
           CantidadCancelada = NULL 
     WHERE ID = @OPID AND Renglon = @Renglon AND RenglonSub = @RenglonSub 

    UPDATE ProdD 
       SET CantidadInventario = Cantidad*Factor
     WHERE ID = @OPID AND Renglon = @Renglon AND RenglonSub = @RenglonSub 

  END
  RETURN
END

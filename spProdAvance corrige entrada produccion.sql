
ALTER PROCEDURE [dbo].[spProdAvance]
	@Sucursal		int,
	@Accion		char(20),
	@Empresa		char(5),
	@FechaEmision	datetime,
	@FechaRegistro	datetime,
	@Usuario		char(10),
	@AvanceID		int,
	@AvanceMov		char(20),
	@AvanceMovID		varchar(20),
	@MovTipo		char(20),

	@Ok                	int          OUTPUT,
	@OkRef             	varchar(255) OUTPUT
--//WITH ENCRYPTION
AS BEGIN  
  DECLARE
    @Ruta			char(20),
    @Orden			int,
    @OrdenDestino	int,
    @Centro			char(10),
    @CentroDestino     	char(10),
    @ProdSerieLote      varchar(50),
    @Articulo		char(20),
    @SubCuenta		varchar(50),
    @RenglonTipo	char(1),
    @Cantidad		float,
    @Unidad			varchar(50),
    @Factor			float,
    @MermaDesp		float,
    @GeneroCosto 	bit,
	@Instruccion    varchar(50)

--  IF @MovTipo = 'PROD.E' AND @Accion = 'CANCELAR' RETURN

  SELECT @GeneroCosto = 0

  DECLARE crProdAP CURSOR FOR
  SELECT Ruta, Orden, OrdenDestino, Centro, CentroDestino, ProdSerieLote, Articulo, SubCuenta, Unidad, RenglonTipo, AVG(Factor), SUM(Cantidad), SUM(ISNULL(Merma, 0)+ISNULL(Desperdicio, 0)),Instruccion
    FROM ProdD d
   WHERE ID = @AvanceID AND ISNULL(UPPER(d.Tipo), '') <> 'EXCEDENTE'
   GROUP BY Ruta, Orden, OrdenDestino, Centro, CentroDestino, ProdSerieLote, Articulo, SubCuenta, Unidad, RenglonTipo, Instruccion
   ORDER BY Ruta, Orden, OrdenDestino, Centro, CentroDestino, ProdSerieLote, Articulo, SubCuenta, Unidad, RenglonTipo, Instruccion

  OPEN crProdAP
  FETCH NEXT FROM crProdAP INTO @Ruta, @Orden, @OrdenDestino, @Centro, @CentroDestino, @ProdSerieLote, @Articulo, @SubCuenta, @Unidad, @RenglonTipo, @Factor, @Cantidad, @MermaDesp, @Instruccion
  WHILE @@FETCH_STATUS <> -1 AND @Cantidad+@MermaDesp>0.0 AND @Ok IS NULL
  BEGIN
    IF @@FETCH_STATUS <> -2 
    BEGIN
      IF @MovTipo = 'PROD.E' SELECT @Cantidad = @Cantidad + @MermaDesp

      EXEC spProdAvanceMatar @Sucursal, @Accion, @Empresa, @FechaEmision, @FechaRegistro, @Usuario, @AvanceID, @AvanceMov, @AvanceMovID, @MovTipo, @Orden, @OrdenDestino, @Centro, @CentroDestino, @ProdSerieLote, 
	  		     @Articulo, @SubCuenta, @Cantidad, @Unidad, @RenglonTipo, @Factor, 
		             @Ruta, @GeneroCosto OUTPUT, @Ok OUTPUT, @OkRef OUTPUT, @instruccion
    END

    FETCH NEXT FROM crProdAP INTO @Ruta, @Orden, @OrdenDestino, @Centro, @CentroDestino, @ProdSerieLote, @Articulo, @SubCuenta, @Unidad, @RenglonTipo, @Factor, @Cantidad, @MermaDesp, @Instruccion
  END
  CLOSE crProdAP 
  DEALLOCATE crProdAP 


----SELECT @Ok = 20180

  RETURN
END

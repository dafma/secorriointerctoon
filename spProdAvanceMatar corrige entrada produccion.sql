
ALTER PROCEDURE [dbo].[spProdAvanceMatar]
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
	@OrdenD		int,
	@OrdenA		int,
	@CentroD      	char(10),
	@CentroA	      	char(10),
	@ProdSerieLote      	varchar(50),
	@Articulo		char(20),
	@SubCuenta		varchar(50),
	@Cantidad		float,
	@Unidad		varchar(50),
	@RenglonTipo		char(1),
	@Factor		float,
	@Ruta		char(20),

	@GeneroCosto		bit	     OUTPUT,
	@Ok                	int          OUTPUT,
	@OkRef             	varchar(255) OUTPUT,
    @instruccion	varchar(50) = null
--//WITH ENCRYPTION
AS BEGIN
  DECLARE
    @OPID		int,
    @OPMov		char(20),
    @OPMovID		varchar(20),
    @Renglon		float,
    @RenglonSub		int,
    @OrdenOrigen	int,
    @OrdenDestino	int,
    @OrdenSiguiente	int,
    @CentroOrigen	char(10),
    @CentroDestino	char(10),
    @CentroSiguiente	char(10),
    @EstacionDestino	char(10),
    @EstacionSiguiente	char(10),
    @CentroCosto	char(10),
    @Saldo		float,
    @CantidadPendiente	float


  SELECT @OPID = MIN(ID), @OPMov = MIN(Mov), @OPMovID = MIN(MovID)
    FROM ProdSerieLotePendiente 
   WHERE Empresa = @Empresa AND ProdSerieLote = @ProdSerieLote AND Articulo = @Articulo AND SubCuenta = @SubCuenta

  EXEC spMovFlujo @Sucursal, @Accion, @Empresa, 'PROD', @OPID, @OPMov, @OPMovID, 'PROD', @AvanceID, @AvanceMov, @AvanceMovID, @Ok OUTPUT 

  IF @MovTipo = 'PROD.E' SELECT @CentroA = @CentroD, @OrdenA = @OrdenD

  IF @MovTipo IN ('PROD.A', 'PROD.E') 
    EXEC spProdAutoAfectarConsumos @Sucursal, @Empresa, @Accion, @FechaEmision, @FechaRegistro, @Usuario, @AvanceID, @AvanceMov, @AvanceMovID, @OPID, @OPMov, @OPMovID, @CentroD, @ProdSerieLote, @Articulo, @SubCuenta, @Cantidad, @Unidad, @Ok OUTPUT, @OkRef OUTPUT

  IF @MovTipo = 'PROD.E' AND @Accion = 'CANCELAR' RETURN

  IF @Accion <> 'CANCELAR'
    SELECT @CentroOrigen = @CentroD, @CentroDestino = @CentroA,
           @OrdenOrigen  = @OrdenD,  @OrdenDestino  = @OrdenA
  ELSE
    SELECT @CentroOrigen = @CentroA, @CentroDestino = @CentroD,
           @OrdenOrigen  = @OrdenA,  @OrdenDestino  = @OrdenD

  EXEC spProdAvanceAlCentro @Empresa, @MovTipo, @Articulo, @SubCuenta, @ProdSerieLote, @Ruta, @OrdenDestino, @OrdenSiguiente OUTPUT, @CentroDestino, @CentroSiguiente OUTPUT, @EstacionDestino OUTPUT, @EstacionSiguiente OUTPUT

  IF (SELECT Estatus FROM Prod WHERE ID = @OPID) <> 'PENDIENTE' SELECT @Ok = 20180

  SELECT @Saldo = @Cantidad
  DECLARE crProdOT CURSOR FOR
  SELECT d.ID, d.Renglon, d.RenglonSub, ROUND(ISNULL(d.CantidadPendiente, 0.0), 4)
    FROM Prod e, ProdD d
   WHERE e.ID = d.ID AND e.ID = @OPID
     AND e.Empresa = @Empresa AND d.ProdSerieLote = @ProdSerieLote AND d.Articulo = @Articulo AND d.SubCuenta = @SubCuenta AND d.Unidad = @Unidad 
     AND ISNULL(d.Orden, 0) = ISNULL(@OrdenOrigen, 0)
     AND ISNULL(d.Centro, '') = ISNULL(@CentroOrigen, '')
     AND ISNULL(d.CantidadPendiente, 0.0) > 0.0
     AND ISNULL(d.Instruccion, '') = ISNULL(@Instruccion,'') 
   ORDER BY d.CantidadPendiente

  OPEN crProdOT
  FETCH NEXT FROM crProdOT INTO @OPID, @Renglon, @RenglonSub, @CantidadPendiente
  WHILE @@FETCH_STATUS <> -1 AND @Saldo > 0.0 AND @Ok IS NULL
  BEGIN
    IF @@FETCH_STATUS <> -2 AND @Saldo > 0.0 AND @Ok IS NULL
    BEGIN

      IF @Saldo >= @CantidadPendiente 
      BEGIN
        UPDATE ProdD 
           SET Centro   = @CentroDestino,   CentroDestino   = @CentroSiguiente,
               Orden    = @OrdenDestino,    OrdenDestino    = @OrdenSiguiente,
               Estacion = @EstacionDestino, EstacionDestino = @EstacionSiguiente
         WHERE CURRENT OF crProdOT
        SELECT @Saldo = @Saldo - @CantidadPendiente
		
		---EXEC spProdExcedente @Sucursal, @OPID, @Renglon, @RenglonSub, @CantidadPendiente, @Saldo, @OrdenDestino, @OrdenSiguiente, @CentroDestino, @CentroSiguiente, @EstacionDestino, @EstacionSiguiente, @Instruccion
        ---SELECT @Saldo = 0.0
      END ELSE
      BEGIN
		EXEC spProdSplitOT @Sucursal, @OPID, @Renglon, @RenglonSub, @CantidadPendiente, @Saldo, @OrdenDestino, @OrdenSiguiente, @CentroDestino, @CentroSiguiente, @EstacionDestino, @EstacionSiguiente
        SELECT @Saldo = 0.0
      END 
    END
    FETCH NEXT FROM crProdOT INTO @OPID, @Renglon, @RenglonSub, @CantidadPendiente
  END
  CLOSE crProdOT
  DEALLOCATE crProdOT
  
 ---- IF @Saldo > 0.0 AND @Ok IS NULL SELECT @Ok = 20180
/*  IF @Saldo > 0.0 AND @Ok IS NULL
  BEGIN
    SELECT @Renglon = MAX(Renglon) + 2048.0 FROM ProdD WHERE ID = @OPID 
    INSERT ProdD (ID,    Renglon,  RenglonSub, RenglonTipo,  Articulo,  SubCuenta,  ProdSerieLote,  Orden,         Centro,         Cantidad, CantidadPendiente, Unidad,  Factor)
          VALUES (@OPID, @Renglon, 0,          @RenglonTipo, @Articulo, @SubCuenta, @ProdSerieLote, @OrdenDestino, @CentroDestino, @Saldo,   @Saldo,            @Unidad, @Factor)
  END
*/

  IF @Accion <> 'CANCELAR'
  BEGIN
    IF @MovTipo = 'PROD.R' SELECT @CentroCosto = @CentroDestino ELSE SELECT @CentroCosto = @CentroOrigen
    IF @@ROWCOUNT > 0 SELECT @GeneroCosto = 1
  END
  RETURN
END

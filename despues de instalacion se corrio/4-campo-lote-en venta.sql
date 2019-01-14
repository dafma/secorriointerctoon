
ALTER PROCEDURE [dbo].[spVerArtAlmExistencia]
		            @Sucursal		int,
                    @Empresa		char(5),
	                @Articulo		char(20),
		            @ArtTipo		char(20),
                    @Almacen		char(10),
                    @Descripcion	varchar(255) = NULL
--//WITH ENCRYPTION
AS BEGIN
  -- SET nocount ON
  DECLARE
    @AlmacenTipo	varchar(20),
    @Tipo		varchar(20),
    @TipoOpcion		varchar(20),
    @Localizacion	varchar(50),
    @Pasillo		varchar(50),
    @Anaquel		varchar(50),
    @Estante		varchar(50),
    @Disponible	 	float,
    @Reservado   	float,
    @PorProcesar 	float,
    @Remisionado	float,
    @ExistenciaAlterna	float,
    @SeVende		bit,
    @SeCompra		bit,
    @SeProduce		bit,
    @TieneSustitutos	bit,
    @Espacios		bit,
    @lotes numeric
  

  SELECT @PorProcesar = NULL, @ExistenciaAlterna = NULL, @Localizacion = NULL, @Disponible = NULL, @Reservado = NULL, @Remisionado = NULL
  SELECT @Tipo = Tipo, @TipoOpcion = TipoOpcion, @TieneSustitutos = Sustitutos, @SeVende = SeVende, @SeCompra = SeCompra, @SeProduce = SeProduce, @Espacios = Espacios FROM Art WHERE Articulo = @Articulo
  SELECT @Localizacion = MIN(Localizacion)
    FROM ArtAlm WHERE Empresa = @Empresa AND Articulo = @Articulo AND Almacen = @Almacen
  SELECT @AlmacenTipo = UPPER(Tipo) FROM Alm WHERE Almacen = @Almacen
 
  SELECT @Pasillo = Pasillo, @Anaquel = Anaquel, @Estante = Estante
    FROM ArtAlm WHERE Empresa = @Empresa AND Articulo = @Articulo AND Almacen = @Almacen AND Localizacion = @Localizacion

  IF @AlmacenTipo = 'ACTIVOS FIJOS'
    SELECT @Disponible 	= SUM(SaldoU) FROM SaldoU WHERE Rama = 'AF' AND Empresa = @Empresa AND Cuenta = @Articulo AND Grupo = @Almacen
  ELSE BEGIN
    SELECT @Disponible 	= Convert(float, Disponible)   FROM ArtDisponible    WHERE Empresa = @Empresa AND Articulo = @Articulo AND Almacen = @Almacen
    SELECT @Reservado  	= Convert(float, Reservado)    FROM ArtReservado     WHERE Empresa = @Empresa AND Articulo = @Articulo AND Almacen = @Almacen
    SELECT @Remisionado = SUM(Remisionado)             FROM ArtRemisionado   WHERE Empresa = @Empresa AND Articulo = @Articulo AND Almacen = @Almacen
  END

/*  IF EXISTS(SELECT * FROM ArtVtasMostrador WHERE Empresa = @Empresa AND Articulo = @Articulo AND Almacen = @Almacen)
    SELECT @PorProcesar = SUM(-Cantidad) 
      FROM Venta f, VentaD d
     WHERE f.ID = d.ID
       AND f.Empresa = @Empresa 
       AND d.Almacen = @Almacen
       AND f.Estatus = 'PROCESAR'
       AND d.Articulo = @Articulo 
       AND d.Cantidad < 0
*/
  IF UPPER(@ArtTipo) = 'PARTIDA'
  BEGIN
    SELECT @ExistenciaAlterna = SUM(ExistenciaAlterna)
      FROM SerieLote 
     WHERE Empresa = @Empresa
       AND Articulo = @Articulo
       AND Almacen = @Almacen
       AND Sucursal = @Sucursal
  END
  
  
/* agregamos un nuevo campo calculado que divida las existencias entre el numero de series por articulo*/
  
  SELECT @lotes=COUNT(*) FROM SerieLote sl          
 WHERE sl.Empresa = @Empresa 
   AND sl.Articulo = @Articulo
   AND sl.Almacen = @Almacen


  SELECT "Empresa" = @Empresa, "Articulo" = @Articulo, "Almacen" = @Almacen, "Disponible" = @Disponible, "Reservado" = @Reservado, "Remisionado" = @Remisionado, "PorProcesar" = @PorProcesar, "ExistenciaAlterna" = @ExistenciaAlterna, "Descripcion" = @Descripcion, "Localizacion" = @Localizacion, "SeVende" = @SeVende, "SeCompra" = @SeCompra, "SeProduce" = @SeProduce, "TieneSustitutos" = @TieneSustitutos, "Tipo" = @Tipo, "TipoOpcion" = @TipoOpcion, "Espacios" = @Espacios, "Pasillo" = @Pasillo, "Anaquel" = @Anaquel, "Estante" = @Estante, "lotes"=@lotes
END

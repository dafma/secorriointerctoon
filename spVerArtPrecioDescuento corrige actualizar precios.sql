
ALTER PROCEDURE [dbo].[spVerArtPrecioDescuento]
 @Articulo	 char(20),
 @SubCuenta	 varchar(50),
 @Lista	     char(20),
 @Moneda	 char(5),
 @TipoCambio float,
 @EnSilencio bit = 0,
 @Precio 	 money = NULL OUTPUT,
 @Descuento	 float = NULL OUTPUT,
 @TC         float = NULL OUTPUT
--WITH ENCRYPTION
 AS BEGIN
 DECLARE
  @ArtMoneda	char(10)
 SELECT @Precio     = NULL,
        @Articulo   = NULLIF(RTRIM(@Articulo), ''),
        @SubCuenta  = NULLIF(RTRIM(@SubCuenta), ''),
        @Lista      = NULLIF(RTRIM(@Lista), ''), 
        @Moneda     = NULLIF(RTRIM(@Moneda), ''),
        @TipoCambio = NULLIF(@TipoCambio, 0)
 
IF @Lista IS NOT NULL AND  @Lista <> ''
 BEGIN
  IF @SubCuenta IS NOT NULL
   BEGIN
    SELECT @Precio = NULLIF(Precio, 0) 
      FROM ListaPreciosSub 
     WHERE Articulo  = @Articulo 
       AND SubCuenta = @SubCuenta 
       AND Lista     = @Lista 
       AND Moneda    = @Moneda
       
        IF @Precio IS NOT NULL
         SELECT @Precio = MIN(lp.Precio)/@TipoCambio 
           FROM ListaPreciosSub lp, Mon m 
          WHERE lp.Articulo = @Articulo 
            AND SubCuenta = @SubCuenta 
            AND lp.Lista = @Lista 
            AND lp.Moneda = m.Moneda 
            AND m.TipoCambio = 1
    END

   IF @Precio IS NULL
    BEGIN
      SELECT @Precio = NULLIF(Precio, 0) 
        FROM ListaPreciosD 
       WHERE Articulo = @Articulo 
         AND Lista    = @Lista 
         AND Moneda   = @Moneda
      
       IF @Precio IS NOT NULL
        SELECT @Precio = MIN(lp.Precio)/@TipoCambio 
          FROM ListaPreciosD lp, Mon m 
         WHERE lp.Articulo = @Articulo AND lp.Lista = @Lista AND lp.Moneda = m.Moneda AND m.TipoCambio = 1
    END
  END

  IF @Precio IS NULL
   BEGIN
     
     SELECT @Precio = (lp.Precio*mon.TipoCambio), @ArtMoneda = ISNULL(MonedaPrecio, @Moneda),@TipoCambio= mon.TipoCambio
       FROM Art JOIN ListaPreciosD lp on art.Articulo=lp.Articulo and lp.Articulo = @Articulo AND lp.Lista = @Lista
                JOIN Mon on lp.Moneda=mon.Moneda 
      WHERE art.Articulo = @Articulo

    IF ISNULL(@ArtMoneda,'') <> @Moneda
      SELECT @Precio = MIN(lp.Precio)/@TipoCambio 
        FROM ListaPreciosD lp, Mon m 
       WHERE lp.Articulo = @Articulo 
         AND lp.Lista = @Lista 
         AND lp.Moneda = m.Moneda 
         AND m.TipoCambio = 1
   END

   SET @TC=@TipoCambio
  
 IF @EnSilencio = 0
   SELECT "Precio" = @Precio, "Descuento" = NULL 
   RETURN
END


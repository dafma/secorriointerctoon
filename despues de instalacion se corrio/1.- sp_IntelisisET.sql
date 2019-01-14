
ALTER PROCEDURE [dbo].[sp_IntelisisET] 
			@Accion			varchar(20),
			@Estacion		int,
			@EstacionFirma	varchar(32),
			@Desde			int		= NULL,
			@Hasta			int		= NULL,
			@AccesoID		int		= NULL,
			@Empresa		varchar(5)	= NULL,
			@Sucursal		int		= NULL,
			@Usuario		varchar(10)	= NULL,
			@Licenciamiento	varchar(50)	= NULL

AS BEGIN
  DECLARE
    @TimeOut			int,
    @Ahora			datetime,
    @Vencido			datetime,
    @UltimaActualizacion	datetime,
    @ultEstacion		int,
    @crEstacion			int,
    @Ok				int,
    @OkRef			varchar(255),
	@EliminarUsuarioDuplicado bit

  SELECT @TimeOut = ISNULL(ETTimeOut, 15), @EliminarUsuarioDuplicado = EliminarUsuarioDuplicado FROM IntelisisMK
  SELECT @Ahora = GETDATE()
  SELECT @Vencido = DATEADD(minute, -@TimeOut, @Ahora)

  SELECT @Ok = NULL, @OkRef = NULL
  IF @Accion = 'INSERT'
  BEGIN
    IF @EliminarUsuarioDuplicado = 1
      IF EXISTS (SELECT * FROM IntelisisET WHERE Usuario = @Usuario AND Estacion BETWEEN @Desde AND @Hasta)
		DELETE IntelisisET WHERE Usuario = @Usuario AND Estacion BETWEEN @Desde AND @Hasta

    SELECT @Estacion = NULL
    SELECT @Estacion = (SELECT MAX(Estacion) FROM IntelisisET WHERE Estacion BETWEEN @Desde AND @Hasta)
    IF @Estacion IS NULL 
      SELECT @Estacion = @Desde
    ELSE
    IF @Estacion = @Hasta
    BEGIN
      SELECT @Estacion = NULL, @crEstacion = NULL, @ultEstacion = @Desde - 1
      DECLARE crIntelisisET CURSOR LOCAL FOR 
       SELECT Estacion, UltimaActualizacion
         FROM IntelisisET
        WHERE Estacion BETWEEN @Desde AND @Hasta
        ORDER BY Estacion
      OPEN crIntelisisET
      FETCH NEXT FROM crIntelisisET INTO @crEstacion, @UltimaActualizacion
      WHILE @@FETCH_STATUS <> -1 AND @Estacion IS NULL
      BEGIN
        IF @@FETCH_STATUS <> -2 
        BEGIN
          IF @crEstacion > @ultEstacion + 1
            SELECT @Estacion = @ultEstacion + 1
          ELSE 
          IF @TimeOut > 0 AND @UltimaActualizacion < @Vencido
          BEGIN
            DELETE IntelisisET WHERE Estacion = @crEstacion
            SELECT @Estacion = @crEstacion
          END
          SELECT @ultEstacion = @crEstacion
        END
        FETCH NEXT FROM crIntelisisET INTO @crEstacion, @UltimaActualizacion
      END
      CLOSE crIntelisisET
      DEALLOCATE crIntelisisET  
    END ELSE
    IF @Estacion < @Hasta
      SELECT @Estacion = @Estacion + 1

    IF @Estacion IS NOT NULL
    BEGIN
      IF NOT EXISTS(SELECT * FROM IntelisisET WHERE EstacionFirma = @EstacionFirma)
	  BEGIN
        INSERT IntelisisET (
                Estacion,  EstacionFirma,  Empresa,  Sucursal,  Usuario,  UltimaActualizacion, Licenciamiento) 
        VALUES (@Estacion, @EstacionFirma, @Empresa, @Sucursal, @Usuario, @Ahora, @Licenciamiento)  
      END
      ELSE 
        SELECT @Estacion = NULL, @Ok = 151
    END ELSE
      SELECT @Ok = 152
  END ELSE
  BEGIN
    SELECT @EstacionFirma = EstacionFirma FROM IntelisisET WHERE Estacion = @Estacion 
    IF @Accion = 'UPDATE'
    BEGIN
      UPDATE IntelisisET WITH (ROWLOCK) SET UltimaActualizacion = @Ahora WHERE Estacion = @Estacion 
      IF @@ROWCOUNT = 0 SELECT @Ok = 153
    END ELSE
    IF @Accion = 'DELETE'
    BEGIN
      DELETE IntelisisET WHERE Estacion = @Estacion AND EstacionFirma = @EstacionFirma 
      IF @@ROWCOUNT = 0 SELECT @Ok = 154
    END
  END
  SELECT 'Estacion' = @Estacion, 'EstacionFirma' = @EstacionFirma, 'Ok' = @Ok, 'OkRef' = @OkRef
END
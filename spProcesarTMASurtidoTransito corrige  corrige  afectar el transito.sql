alter  PROCEDURE spProcesarTMASurtidoTransito
@Estacion		int,
@Empresa		char(5),
@FechaEmision	datetime,
@Usuario		char(10),
@CteCNO			char(10) 	= NULL,
@EnSilencio		bit	 	= 0,
@Ok				int	 	= NULL	OUTPUT,
@OkRef			varchar(255)	= NULL	OUTPUT
--WITH ENCRYPTION
AS BEGIN
DECLARE
@NotaID				int,
@Mov				varchar(20),
@Estatus			varchar(20),
@Agente				varchar(10),
@TarimaSurtido		varchar(20),
@Sucursal			int,
@SurtidoID			int,
@Renglon			float,
@Almacen			char(10),
@Posicion			char(10),
@PosicionDestino	char(10),
@Cantidad			float,
@Aplica				varchar(20),
@AplicaID			varchar(20),
@AplicaRenglon		float,
@Zona				varchar(50),
@Tarima				varchar(20),
@CuantasNotas		int,
@Cuantas			int,
@IDAplica			int,
@MovDestino			varchar(20),
@MovDestinoID		varchar(20),
@Origen				varchar(20),
@OrigenID			varchar(20),
@IDOrigen			int,
@Montacarga			varchar(10),
@IdO                int,
@IdMovO             int,
@OrigenO            varchar(20),
@OrigenIDO          varchar(20),
@OrigenMov          varchar(20),
@OrigenIDMov        varchar(20),
@Modulo             varchar(5),
@Articulo        varchar(20),
@SubCuenta       varchar(50),
@Transaccion     varchar(10),
@ArtCambioClave  varchar(50),
@Base			char(20)
SELECT @CuantasNotas = 0
SET @Transaccion = CONVERT(VARCHAR,@@SPID)
IF NOT EXISTS(SELECT * FROM ListaID WHERE Estacion = @Estacion)
BEGIN
SELECT @OkRef = 'No se seleccinó ningún Movimiento'
SELECT @OkRef
RETURN
END
ELSE
SELECT @Cuantas = COUNT(*) FROM ListaID WHERE Estacion = @Estacion
BEGIN TRANSACTION @Transaccion
DECLARE crLista CURSOR
FOR SELECT ID FROM ListaID WHERE Estacion = @Estacion
OPEN crLista
FETCH NEXT FROM crLista INTO @NotaID
CLOSE crLista
DEALLOCATE crLista
IF @NotaID IS NULL
BEGIN
SELECT @Ok = 10160
IF @EnSilencio = 1 RETURN
END
SELECT TOP 1
@Mov = Mov,
@Estatus = 'SINAFECTAR'
FROM MovTipo
WHERE Clave = 'TMA.SUR'
AND Modulo = 'TMA'
CREATE TABLE #Surtido (ID int NULL, FechaEmision datetime NULL)
DECLARE crEncabezado CURSOR LOCAL FOR
SELECT DISTINCT Agente, TarimaSurtido, Sucursal, Almacen, Mov, MovID, Montacarga, Origen, OrigenID, t.ID, t.OrigenTipo
FROM TMA t, ListaID l
WHERE l.Estacion = @Estacion AND t.ID = l.ID
OPEN crEncabezado
FETCH NEXT FROM crEncabezado INTO @Agente, @TarimaSurtido, @Sucursal, @Almacen, @Origen, @OrigenID, @Montacarga, @OrigenO, @OrigenIDO, @IDO, @Modulo
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
INSERT TMA (Empresa,   Usuario,  Mov,	 FechaEmision,	Estatus,  Sucursal,  Almacen,  Agente, Origen, OrigenID, Prioridad, TarimaSurtido, Montacarga)
VALUES     (@Empresa, @Usuario, @Mov, @FechaEmision, @Estatus, @Sucursal, @Almacen, @Agente, @Origen, @OrigenID, 'Normal', @TarimaSurtido, @Montacarga)
SELECT @SurtidoID = @@IDENTITY
SELECT @Renglon = 0
-- asi estaba EXEC spMovCopiarSerielote @Sucursal, @Modulo, @IDO, @SurtidoID,1 ,@Base
EXEC spMovCopiarSerielote @Sucursal, @Modulo, @IDO, @SurtidoID,1 
DECLARE crDetalle CURSOR LOCAL FOR
SELECT d.Almacen, d.Posicion, d.PosicionDestino, d.CantidadPicking, t.Mov, t.MovID, d.Renglon, d.Zona, d.Tarima, o.ID, d.Articulo, d.SubCuenta, d.ArtCambioClave 
FROM TMA t
JOIN TMAD d
ON t.ID = d.ID
JOIN TMA o ON o.Mov = t.Origen
AND o.MovID = t.OrigenID
AND o.Empresa = t.Empresa
JOIN ListaID l
ON l.ID = t.ID AND Estacion = @Estacion
WHERE t.Agente = @Agente
AND t.TarimaSurtido = @TarimaSurtido
AND t.Sucursal = @Sucursal
AND t.Almacen = @Almacen
AND t.Mov = @Origen
AND t.MovID = @OrigenID
OPEN crDetalle
FETCH NEXT FROM crDetalle INTO @Almacen, @Posicion, @PosicionDestino, @Cantidad, @Aplica, @AplicaID, @AplicaRenglon, @Zona, @Tarima, @IDOrigen, @Articulo, @SubCuenta, @ArtCambioClave 
WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
BEGIN
IF @@FETCH_STATUS <> -2
BEGIN
SELECT @Renglon = @Renglon + 2048
INSERT TMAD (ID,          Sucursal,  Renglon, Tarima,          Almacen,  Posicion,   PosicionDestino, CantidadPicking,  Aplica,  AplicaID,  AplicaRenglon,  Zona, TarimaPCK, Prioridad, EstaPendiente, Articulo, SubCuenta, ArtCambioClave) 
SELECT       @SurtidoID, @Sucursal, @Renglon, @TarimaSurtido, @Almacen, @Posicion,  @PosicionDestino, @Cantidad,       @Aplica, @AplicaID, @AplicaRenglon, @Zona, @Tarima, 'Normal', 1, @Articulo, @SubCuenta, @ArtCambioClave 
UPDATE TMAD SET CantidadA  = 0 WHERE ID = @IDOrigen AND Tarima = CASE WHEN CHARINDEX('-', @Tarima, 1) >0 THEN SUBSTRING(@Tarima, 1, CHARINDEX('-', @Tarima, 1)-1) ELSE @Tarima END
/* Se actualiza el RenglonID por que el movimiento anterior tiene otro RenglonID y por ende este no se visualiza en el surtido TMA */
IF EXISTS (SELECT * FROM SerieloteMov WHERE Modulo = 'TMA' AND ID = @SurtidoID)
UPDATE SerieLoteMov SET RenglonID = @Renglon WHERE Modulo = 'TMA' AND ID = @SurtidoID
END
FETCH NEXT FROM crDetalle INTO @Almacen, @Posicion, @PosicionDestino, @Cantidad, @Aplica, @AplicaID, @AplicaRenglon, @Zona, @Tarima, @IDOrigen, @Articulo, @SubCuenta, @ArtCambioClave 
END 
CLOSE crDetalle
DEALLOCATE crDetalle
INSERT VentaOrigen (ID, OrigenID, Sucursal, SucursalOrigen)
SELECT @SurtidoID, v.ID, @Sucursal, @Sucursal
FROM Venta v, ListaID l
WHERE l.Estacion = @Estacion AND v.ID = l.ID
INSERT #Surtido (ID) VALUES (@SurtidoID)
SELECT @CuantasNotas = @CuantasNotas + 1
FETCH NEXT FROM crEncabezado INTO @Agente, @TarimaSurtido, @Sucursal, @Almacen, @Origen, @OrigenID, @Montacarga, @OrigenO, @OrigenIDO, @IdO, @Modulo
END 
CLOSE crEncabezado
DEALLOCATE crEncabezado
DECLARE crSurtido CURSOR LOCAL FOR
SELECT ID
FROM #Surtido
OPEN crSurtido
FETCH NEXT FROM crSurtido INTO @SurtidoID
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
EXEC spAfectar 'TMA', @SurtidoID, 'Afectar', @EnSilencio = 1, @Conexion = 1, @Ok = @Ok OUTPUT, @OkRef = @OkRef OUTPUT
IF @Ok IN (80030, 80060) SELECT @Ok = NULL, @OkRef = NULL
DECLARE crAplica CURSOR LOCAL FOR
SELECT DISTINCT d.Aplica, d.AplicaID, t.ID
FROM TMAD d
JOIN TMA t ON d.Aplica = t.Mov AND d.AplicaID = t.MovID AND t.Empresa = @Empresa
WHERE d.ID = @SurtidoID
OPEN crAplica
FETCH NEXT FROM crAplica INTO @Aplica, @AplicaID, @IDAplica
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
UPDATE TMA SET Estatus = 'CONCLUIDO' WHERE Mov = @Aplica AND MovID = @AplicaID AND Empresa = @Empresa AND Estatus = 'PROCESAR'
SELECT @MovDestino = Mov, @MovDestinoID = MovID FROM TMA WHERE ID = @SurtidoID
EXEC spMovFlujo @Sucursal, Afectar, @Empresa, 'TMA', @IDAplica, @Aplica, @AplicaID, 'TMA', @SurtidoID, @MovDestino, @MovDestinoID, @Ok OUTPUT
FETCH NEXT FROM crAplica INTO @Aplica, @AplicaID, @IDAplica
END
CLOSE crAplica
DEALLOCATE crAplica
FETCH NEXT FROM crSurtido INTO @SurtidoID
END
CLOSE crSurtido
DEALLOCATE crSurtido
IF @Ok IS NULL
BEGIN
IF @EnSilencio = 0
BEGIN
SELECT @OkRef = RTRIM(Convert(char, @Cuantas))+' Surtidos(s) Transito procesados.'
IF @SurtidoID IS NOT NULL
BEGIN
IF @CuantasNotas = 1
SELECT @OkRef = RTRIM(ISNULL(@OkRef,'')) + '<BR>Se Procesaron: '+RTRIM(@Mov)
ELSE
SELECT @OkRef = RTRIM(ISNULL(@OkRef,'')) + '<BR>Se Procesaron: '+CONVERT(varchar, @CuantasNotas)+' '+RTRIM(@Mov)+'(s)'
END
SELECT @OkRef
END
COMMIT TRANSACTION @Transaccion
END ELSE
BEGIN
IF @EnSilencio = 0
SELECT  'Error: - ' + CONVERT(varchar, Mensaje) + '<BR><BR>' + Descripcion + '<BR><BR>' + RTRIM(ISNULL(@OkRef,''))
FROM MensajeLista
WHERE Mensaje = @Ok
ROLLBACK TRANSACTION @Transaccion
END
RETURN
END
GO

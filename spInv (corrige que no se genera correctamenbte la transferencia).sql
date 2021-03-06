ALTER  PROCEDURE [dbo].[spInv]
@ID                  	int,
@Modulo	      		char(5),
@Accion			char(20),
@Base			char(20),
@FechaRegistro		datetime,
@GenerarMov			char(20),
@Usuario			char(10),
@Conexion			bit,
@SincroFinal			bit,
@AccionEspecial		varchar(20),
@Mov	      			char(20)	OUTPUT,
@MovID            		varchar(20)	OUTPUT,
@IDGenerar			int		OUTPUT,
@ContID			int		OUTPUT,
@Ok				int		OUTPUT,
@OkRef			varchar(255)	OUTPUT,
@VolverAfectar		int = 0		OUTPUT,
@EsCancelacionFactura	bit = 0,
@FacturacionRapidaAgrupada	bit = 0,
@Estacion			int = 0 
--WITH ENCRYPTION
AS BEGIN
DECLARE
@Sucursal			int,
@SucursalDestino		int,
@SucursalOrigen		int,
@SucursalPrincipal		int,
@SucursalEnLinea		int,
@EnLinea			bit,
@PuedeEditar		bit,
@Empresa	      		char(5),
@MovUsuario			char(10),
@MovTipo   			char(20),
@MovMoneda	      		char(10),
@MovTipoCambio	     	float,
@MovSeguimiento		char(20),
@SeguimientoMatriz		bit,
@FechaAfectacion   		datetime,
@FechaEmision      		datetime,
@FechaConclusion		datetime,
@Concepto	      		varchar(50),
@Proyecto	      		varchar(50),
@Autorizacion     		char(10),
@Mensaje			int,
@Referencia	      		varchar(50),
@DocFuente	      		int,
@Observaciones    		varchar(255),
@Estatus          		char(15),
@AccionOriginal		char(20),
@Almacen          		char(10),
@AlmacenTipo		char(15),
@AlmacenDestino   		char(10),
@AlmacenDestinoTipo		char(15),
@AlmacenTransito		char(10),
@AlmacenEspecifico		char(10),
@AlmacenSucursal		int,
@VoltearAlmacen		bit,
@Largo			bit,
@ServicioGarantia		bit,
@ServicioArticulo		char(20),
@ServicioSerie		char(20),
@Condicion			varchar(50),
@Vencimiento		datetime,
@FormaEnvio			varchar(50),
@UEN			int,
@ZonaImpuesto		varchar(50),
@ClienteProv		char(10),
@ClienteProvTipo		char(20),
@EnviarA			int,
@Credito			varchar(50),
@CreditoEspecial		bit,
@ConCredito			bit,
@ConLimiteCredito		bit,
@LimiteCredito		money,
@ConLimitePedidos		bit,
@LimitePedidos		money,
@MonedaCredito		char(10),
@Dias			int,
@DiasCredito		int,
@CondicionesValidas		varchar(255),
@TipoCambioCredito		float,
@PedidosParciales		bit,
@VtasConsignacion		bit,
@AfectarConsignacion	bit,
@AfectarVtasMostrador	bit,
@FacturarVtasMostrador	bit,
@AlmacenVtasConsignacion	char(10),
@DescuentoGlobal		float,
@SobrePrecio		float,
@Agente			char(10),
@Departamento		int,
@ExcluirPlaneacion		bit,
@AFArticulo			varchar(20),
@AFSerie			varchar(50),	
@CobroIntegrado		bit,
@CobroIntegradoCxc		bit,
@CobroIntegradoParcial      bit,
@CobrarPedido		bit,
@AnticiposFacturados	money,
@CancelacionID		int,
@ServicioPlacas		varchar(20),
@ServicioKms		int,
@AutoCorrida		varchar(20),
@Espacio			varchar(10),
@AutoKmsActuales		int,
@Periodicidad		varchar(20),
@EndosarA			varchar(10),
@Directo			bit,
@FechaRequerida		datetime,
@HoraRequerida		char(5),
@OrigenTipo			varchar(10),
@Origen			varchar(20),
@OrigenID			varchar(20),
@OrigenMovTipo		varchar(20),
@Ejercicio	      		int,
@Periodo	      		int,
@AlmacenTmp			char(10),
@GenerarOP			bit,
@CfgAlmacenTransito		char(20),
@CfgFormaCosteo   		char(20),
@CfgTipoCosteo    		char(20),
@CfgCosteoActividades	varchar(20),
@CfgCosteoNivelSubCuenta	bit,
@CfgCosteoMultipleSimultaneo bit,
@CfgPosiciones		bit,
@CfgExistenciaAlterna	bit,
@CfgExistenciaAlternaSerieLote bit,
@CfgValidarPrecios		char(20),
@CfgPrecioMinimoSucursal	bit,
@CfgValidarMargenMinimo	char(20),
@CfgSeriesLotesMayoreo	bit,
@CfgSeriesLotesAutoCampo	char(20),
@CfgSeriesLotesAutoOrden	char(20),
@CfgCosteoSeries		bit,
@CfgCosteoLotes		bit,
@CfgValidarLotesCostoDif	bit,
@CfgPedidosReservar		bit,
@CfgPedidosReservarEsp	bit,
@CfgVentaSurtirDemas	bit,
@CfgCompraRecibirDemas	bit,
@CfgCompraRecibirDemasTolerancia float,
@CfgTransferirDemas		bit,
@CfgBackOrders		bit,
@CfgContX			bit,
@CfgContXGenerar		char(20),
@CfgContXFacturasPendientes bit,
@CfgEmbarcar		bit,
@CfgImpInc			bit,
@CfgPrecioMoneda		bit,
@CfgVentaRedondeoDecimales	int,
@CfgCompraCostosImpuestoIncluido bit,
@CfgMultiUnidades		bit,
@CfgMultiUnidadesNivel	char(20),
@CfgInvPrestamosGarantias	bit,
@CfgServiciosRequiereTareas bit,
@CfgServiciosValidarID	bit,
@CfgInvEntradasSinCosto	bit,
@CfgVentaConfirmarServicios	bit,
@CfgVentaConfirmarContratos	bit,
@CfgInvConfirmarSolicitudes	bit,
@CfgVentaContratosArticulo	char(20),
@CfgVentaContratosImpuesto	float,
@CfgVentaChecarCredito	char(20),
@CfgVentaPedidosDisminuyenCredito bit,
@CfgVentaBloquearMorosos	char(20),
@CfgVentaLiquidaIntegral	bit,
@CfgVentaLiquidaIntegralCxc	bit,
@CfgFacturaCobroIntegrado	bit,
@CfgFacturaCobroIntegradoParcial bit,
@CfgVentaComisionesCobradas bit,
@CfgCompraConsignacion	char(20),
@CfgAutorizarRequisiciones	bit,
@CfgBackOrdersNivel		char(20),
@CfgCancelarFacturaReservarPedido bit,
@CfgFacturasPendientes	bit,
@CfgFacturasPendientesSerieLote bit,
@CfgLimiteRenFacturas	int,
@CfgNotasBorrador		bit,
@CfgInvFisicoConteo		int,
@CfgAnticiposFacturados	bit,
@CfgCompraFactorDinamico 	bit,
@CfgInvFactorDinamico   	bit,
@CfgProdFactorDinamico  	bit,
@CfgVentaFactorDinamico 	bit,
@CfgCompraAutoCargos	bit,
@CfgVentaAutoBonif		bit,
@CfgVINAccesorioArt 	bit,
@CfgVINCostoSumaAccesorios	bit,
@CfgDecimalesCantidades	int,
@CfgToleranciaCosto		float,
@CfgToleranciaCostoInferior	float,
@CfgToleranciaTipoCosto	char(20),
@CfgAutoAsignarBackOrders	bit,
@CfgInvMultiAlmacen		bit,
@CfgCompraMultiAlmacen	bit,
@CfgVentaMultiAlmacen	bit,
@CfgVentaUENDetalle		bit,
@CfgVentaMultiAgente	bit,
@CfgVentaMultiDepartamento	bit,
@CfgVentaAFDetalle		bit,
@CfgVentaEnviarADetalle	bit,
@CfgVentaExcluirPlaneacionDetalle bit,
@CfgVentaDFechaRequerida	bit,
@CfgVentaDHoraRequerida	bit,
@CfgFormaPagoRequerida	bit,
@CfgBloquearNotasNegativas	bit,
@CfgBloquearFacturacionDirecta	bit,
@CfgBloquearInvSalidaDirecta	bit,
@CfgVentaArtAlmacenEspecifico  bit,
@CfgProdAutoLote		char(20),
@CfgProdAutoCB		char(20),
@CfgTipoMerma		char(1),
@CfgComisionBase		char(20),
@CfgCompraValidarArtProv	bit,
@CfgPresupuestosPendientes  bit,
@CfgAutoAsignarMovSucursalAlmacen bit,
@CfgPermitirMovSucursalDiferente  bit,
@CfgValidarCC		bit,
@CfgVentaRestringida	bit,
@CfgLimiteCreditoNivelGrupo bit,
@CfgLimiteCreditoNivelUEN   bit,
@CfgRestringirArtBloqueados bit,
@CfgAutotransportes		bit,
@CfgCancelarFactura		varchar(20),
@CfgAnexosAlFacturar	bit,
@CfgVentaEndoso		bit,
@CfgValidarFechaRequerida	bit,
@CfgRecibirDemasSinLimites	bit,
@CfgVIN			bit,
@AfectarDetalle             bit,
@AfectarMatando		bit,
@AfectarMatandoOpcional	bit,
@AfectarAlmacenRenglon	bit,
@AfectarConsecutivo		bit,
@EstatusNuevo		char(15),
@EsTransferencia		bit,
@CteChecarCredito		varchar(20),
@ChecarCredito		varchar(20),
@CteBloquearMorosos		varchar(20),
@BloquearMorosos		varchar(20),
@IDTransito			int,
@TransitoSucursal		int,
@TransitoMov 		char(20),
@TransitoMovID 		varchar(20),
@TransitoEstatus 		char(15),
@Utilizar			bit,
@UtilizarID			int,
@UtilizarMov		char(20),
@UtilizarSerie		char(20),
@UtilizarMovTipo		char(20),
@UtilizarMovID		varchar(20),
@Generar                    bit,
@GenerarMovID		varchar(20),
@GenerarSerie		char(20),
@GenerarAfectado		bit,
@GenerarCopia		bit,
@GenerarPoliza		bit,
@Autorizar			bit,
@GenerarGasto		bit,
@InvConteo			int,
@AnexoID			int,
@AnexarTodoDetalle		bit,
@Verificar			bit,
@CfgCentroCostos2VentaD	bit,
@CfgCentroCostos3VentaD	bit,
@CfgCentroCostos2CompraD	bit,
@CfgCentroCostos3CompraD	bit,
@ContUso2			varchar(20),
@ContUso3			varchar(20),
@InvVerificarEnConexion bit,
@cPosicionActual                  varchar(10),
@cId							  int,
@cArticulo						  varchar(20),
@cAlmacen						  varchar(10),
@cRenglon						  float,
@cTarima						  varchar(20),
@Renglon						  float,
@RenglonSub						  int,
@RenglonID						  int,
@RenglonTipo					  varchar(1),
@Almacenc						  varchar(10),
@Articulo						  varchar(20),
@Costo							  money,
@Unidad							  varchar(50),
@Factor							  float,
@CantidadInventario				  float,
@Sucursalc						  int,
@SucursalOrigenc				  int,
@Tarima							  varchar(20),
@PosicionActual					  varchar(10),
@PosicionReal					  varchar(10),
@Articuloc						  varchar(20),
@Cantidadc						  float,
@Almacenct                        varchar(10),
@cTarimaAlta                      varchar(20),
/* Bugs 4592,4602,4656,4818 */
@Renglonc                         float,
@PosicionActualc	              varchar(10),
@PosicionRealc	                  varchar(10),
@TipoA	                          varchar(20),
@TipoR	                          varchar(20),
@WMS                              bit, 
@CrossDocking                     bit,
@Escrossdocking                   varchar(2),
@PosicionWMS                      varchar(10),
@DID                              int,
@posicioncrossdocking             varchar(10),
@FechaCaducidad                   datetime, 
@ArticuloFC                       varchar(20),
@AlmacencFC                       varchar(10),
@CrArtículo						  varchar(20),
@CrAlmacen						  varchar(20),
@CrCantidadDisponible			  float,
@CrCantidadAfectar				  float,
@CrMov							  varchar(20),
@IDGenerarSATMA					  INT,
@IDGenerarOATMA					  INT,
@IDGenerarATMA					  INT,
@OrigenWMS						  VARCHAR(20),
@OrigenIDWMS					  VARCHAR(20),
@OrigenSubMovTipo                 varchar(20),
@MovMES							  bit
SELECT @AfectarDetalle	  = 1,
@AfectarMatando          = 0,
@AfectarMatandoOpcional  = 1,
@AfectarAlmacenRenglon	  = 1,
@AfectarConsecutivo	  = 0,
@EsTransferencia	  = 0,
@CobroIntegrado	  = 0,
@CobroIntegradoCxc	  = 0,
@CobroIntegradoParcial   = 0,
@CobrarPedido		  = 0,
@VoltearAlmacen	  = 0,
@AlmacenEspecifico	  = NULL,
@CancelacionID	  	  = NULL,
@SeguimientoMatriz	  = 0,
@SucursalPrincipal	  = NULL,
@Periodicidad		  = NULL,
@EndosarA		  = NULL,
@Utilizar		  = 0,
@UtilizarSerie		  = NULL,
@Generar		  = 0,
@GenerarSerie		  = NULL,
@GenerarAfectado	  = 0,
@GenerarCopia		  = 1,
@AnticiposFacturados	  = 0.0,
@AutoCorrida		  = NULL,
@Espacio		  = NULL,
@Autorizar		  = 0,
@Mensaje		  = NULL,
@ClienteProvTipo 	  = NULL,
@AlmacenDestino	  = NULL,
@AlmacenTransito	  = NULL,
@Largo			  = 0,
@EnviarA		  = NULL,
@Condicion	 	  = NULL,
@FormaEnvio		  = NULL,
@ClienteProv		  = NULL,
@ConCredito		  = 0,
@ConLimiteCredito	  = 0,
@LimiteCredito		  = 0.0,
@LimitePedidos		  = 0.0,
@DiasCredito		  = NULL,
@CondicionesValidas	  = NULL,
@TipoCambioCredito	  = 1.0,
@PedidosParciales	  = 0,
@VtasConsignacion	  = 0,
@AfectarConsignacion	  = 0,
@AfectarVtasMostrador    = 0,
@FacturarVtasMostrador	  = 0,
@ServicioGarantia	  = 0,
@ServicioArticulo	  = NULL,
@ServicioSerie		  = NULL,
@ServicioPlacas	  = NULL,
@ServicioKms		  = NULL,
@AlmacenVtasConsignacion = NULL,
@DescuentoGlobal	  = 0.0,
@SobrePrecio		  = 0.0,
@Agente		  = NULL,
@Departamento		  = NULL,
@ExcluirPlaneacion	  = 0,
@AFArticulo		  = NULL,
@AFSerie		  = NULL,
@Autorizacion		  = NULL,
@Mensaje		  = NULL,
@GenerarOP		  = 0,
@IDTransito		  = NULL,
@SobrePrecio		  = NULL,
@CfgContX		    = 0,
@CfgContXGenerar	    = 'NO',
@CfgContXFacturasPendientes= 0,
@CfgEmbarcar		    = 0,
@CfgMultiUnidades	    = 0,
@CfgMultiUnidadesNivel     = 'UNIDAD',
@CfgAutorizarRequisiciones = 0,
@FechaRequerida	  = NULL,
@HoraRequerida		  = NULL,
@OrigenTipo		  = NULL,
@Origen		  = NULL,
@OrigenID		  = NULL,
@OrigenMovTipo		  = NULL,
@GenerarGasto		  = 0,
@AnexoID		  = NULL,
@AnexarTodoDetalle	  = 0,
@Verificar		  = 1
EXEC spMovInfo @ID,@Modulo,@Empresa=@Empresa OUTPUT,@Mov=@Mov OUTPUT,@Movtipo=@Movtipo OUTPUT, @Estatus=@Estatus OUTPUT
IF @Modulo = 'VTAS' AND @Ok IS NULL
EXEC spVentaDEmbarqueVerificar @ID
IF @Modulo = 'INV' AND @MovTipo = 'INV.SOL' AND @Ok IS NULL
BEGIN
DECLARE CrVerificaTarima CURSOR FOR
SELECT D.Articulo,
D.Almacen,
CASE @BASE WHEN 'Pendiente'
THEN SUM(CASE WHEN ISNULL(D.CantidadPendiente,0) <> 0
THEN D.CantidadPendiente
ELSE
CASE WHEN ISNULL(D.CantidadInventario,0) = 0
THEN D.Cantidad
ELSE D.CantidadInventario
END
END)
WHEN 'Seleccion'
THEN SUM(D.CantidadA)
WHEN 'Reservado'
THEN SUM(D.CantidadReservada)
END,
E.MOV
FROM InvD D
JOIN Inv E ON D.Id = E.Id
WHERE E.ID = @ID
GROUP BY D.Articulo, D.Almacen, E.Mov
OPEN CrVerificaTarima
FETCH NEXT FROM CrVerificaTarima INTO @CrArtículo, @CrAlmacen, @CrCantidadAfectar, @CrMov
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
SELECT @CrCantidadDisponible = SUM(Disponible)
FROM ArtDisponibleTarima
WHERE Articulo = @CrArtículo
AND Almacen = @CrAlmacen
AND Empresa = @Empresa
AND ISNULL(Tarima,'') = ''
IF EXISTS (SELECT * FROM ALMSUGERIRSURTIDOTARIMA WHERE Modulo = 'INV' AND MOV = @CrMov AND Almacen = @CrAlmacen)
BEGIN
IF @CrCantidadDisponible < @CrCantidadAfectar
SELECT @Ok = 10340, @OkRef = 'La Cantidad a Entarimar es Mayor a la Disponible'
END
FETCH NEXT FROM CrVerificaTarima INTO @CrArtículo, @CrAlmacen, @CrCantidadAfectar, @CrMov
END
CLOSE CrVerificaTarima
DEALLOCATE CrVerificaTarima
END
SELECT @WMS = NULLIF(WMS,'') FROM EmpresaGral WHERE Empresa = @Empresa
IF @Modulo ='INV' AND @WMS = 1 AND @Accion = 'AFECTAR' AND @MovTipo = 'INV.IF'
BEGIN
DECLARE crInvWMS CURSOR FOR
SELECT Id.PosicionActual, Id.Id, Id.Articulo, I.Almacen, Id.Renglon
FROM INVD AS ID
JOIN INV AS I ON I.ID = ID.Id
WHERE I.ID = @ID
OPEN crInvWMS
FETCH NEXT FROM crInvWMS INTO @cPosicionActual, @cId, @cArticulo, @cAlmacen, @cRenglon
WHILE @@FETCH_STATUS = 0
BEGIN
DECLARE crInvTarWMS CURSOR FOR
SELECT
Tarima.Tarima
FROM Tarima
LEFT OUTER JOIN AlmPos ON Tarima.Almacen = AlmPos.Almacen AND Tarima.Posicion = AlmPos.Posicion
LEFT JOIN ArtDisponibleTarima ON Tarima.Tarima = ArtDisponibleTarima.Tarima
WHERE Tarima.Estatus = 'ALTA' AND Tarima.Almacen = @cAlmacen AND ArtDisponibleTarima.Articulo = (SELECT ISNULL(NULLIF(CONVERT(varchar(20),@cArticulo),''),ArtDisponibleTarima.Articulo))
AND ArtDisponibleTarima.Disponible > 0
AND Tarima.Posicion = @cPosicionActual
OPEN crInvTarWMS
FETCH NEXT FROM crInvTarWMS INTO @cTarima
WHILE @@FETCH_STATUS = 0
BEGIN
IF NOT EXISTS (SELECT * FROM INVD WHERE ID = @cId AND Tarima = @cTarima)
BEGIN
SELECT @RenglonSub         = RenglonSub,
@RenglonTipo        = RenglonTipo,
@Almacenc           = Almacen,
@Articulo           = Articulo,
@Costo              = Costo,
@Unidad             = Unidad,
@Factor             = Factor,
@CantidadInventario = CantidadInventario,
@Sucursalc          = Sucursal,
@SucursalOrigenc    = SucursalOrigen,
@Tarima             = Tarima,
@PosicionActual     = PosicionActual
FROM InvD
WHERE Id = @cId
AND Renglon = @cRenglon
SELECT @Renglon   = MAX(Renglon),
@RenglonID = MAX(RenglonID)
FROM INVD
WHERE ID = @cId
SET @Renglon = @Renglon + 2048
SET @RenglonID = @RenglonID + 1
SELECT @PosicionReal = Posicion
FROM tarima
WHERE tarima = @cTarima
INSERT INTO InvD
(ID, Renglon, RenglonSub, RenglonID, RenglonTipo, Almacen, Codigo, Articulo, SubCuenta, ArticuloDestino, SubCuentaDestino, Cantidad, Paquete, Costo, CantidadA, Aplica, AplicaID, ContUso, Unidad, Factor, CantidadInventario, FechaRequerida, ProdSerieLote, Merma, Desperdicio, Producto, SubProducto, Tipo, Sucursal, SucursalOrigen, Precio, CostoInv, Espacio, DestinoTipo, Destino, DestinoID, Cliente, SegundoConteo, DescripcionExtra, Posicion, Tarima, FechaCaducidad, PosicionDestino, PosicionActual, PosicionReal)
VALUES
(@cId, @Renglon, @RenglonSub, @RenglonID, @RenglonTipo, @Almacenc, NULL, @Articulo, NULL, NULL, NULL, 0.0,  NULL, @Costo, NULL, NULL, NULL, NULL, @Unidad, @Factor, @CantidadInventario, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @Sucursalc, @SucursalOrigenc, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @cTarima, NULL, NULL, @PosicionActual, @PosicionReal)
END
FETCH NEXT FROM crInvTarWMS INTO @cTarima
END
CLOSE crInvTarWMS
DEALLOCATE crInvTarWMS
FETCH NEXT FROM crInvWMS INTO @cPosicionActual, @cId, @cArticulo, @cAlmacen, @cRenglon
END
CLOSE crInvWMS
DEALLOCATE crInvWMS
DECLARE crInvFisTar CURSOR FOR
SELECT ID.Tarima, ID.Articulo, ID.Cantidad, I.Almacen, ID.Renglon, ID.PosicionActual, ID.PosicionReal
FROM INVD ID
JOIN INV I ON ID.Id = I.Id
WHERE ID.ID = @ID
OPEN crInvFisTar
FETCH NEXT FROM crInvFisTar INTO @cTarimaAlta, @Articuloc, @Cantidadc, @Almacenct, @Renglonc, @PosicionActualc, @PosicionRealc
WHILE @@FETCH_STATUS = 0
BEGIN
/* Bugs 4592,4602,4656,4818 */
SELECT @TipoA = Tipo
FROM AlmPos
WHERE Posicion = @PosicionActualc
SELECT @TipoR = Tipo
FROM AlmPos
WHERE Posicion = @PosicionRealc
IF @TipoA = 'Ubicacion' AND @TipoR = 'Domicilio'
BEGIN
SELECT @Ok = 13137, @OkRef = ' ' + @cTarimaAlta
END
IF @TipoR = 'Surtido'
BEGIN
SELECT @Ok = 13136, @OkRef = ' Posición: ' + @PosicionRealc
END
ELSE
BEGIN
IF EXISTS (SELECT Tarima
FROM Tarima
WHERE Tarima  = @cTarimaAlta
) AND @TipoA <> 'Ubicacion' AND @TipoR <> 'Domicilio'
BEGIN
UPDATE Tarima
SET Posicion = @PosicionRealc
WHERE Tarima   = @cTarimaAlta
END
END
/* Bugs 4592,4602,4656,4818 */
IF EXISTS (SELECT Tarima
FROM Tarima
WHERE Tarima  = @cTarimaAlta
AND Estatus = 'BAJA')	AND @Accion <> 'CANCELAR'
BEGIN
/* Valida si puede Autoriza la alta de la tarima*/
IF EXISTS (SELECT AutorizaAltaTarima FROM Usuario WHERE Usuario = @Usuario AND AutorizaAltaTarima = 1)
BEGIN
INSERT TarimasBajaWMS (Tarima,      SaldoU,     Articulo,    Almacen)
SELECT  @cTarimaAlta, @Cantidadc, @Articuloc, @Almacenct
UPDATE Tarima
SET Estatus = 'ALTA',
Alta = GETDATE()
WHERE Tarima = @cTarimaAlta
END
ELSE
BEGIN
SELECT @Ok = 13135, @OkRef = ''
END
END
IF EXISTS(SELECT * FROM TarimasBajaWMS WHERE Tarima = @cTarimaAlta AND Articulo = @Articuloc AND Almacen = @Almacenct) AND @Accion = 'CANCELAR'
BEGIN
IF EXISTS (SELECT Tarima
FROM Tarima
WHERE Tarima  = @cTarimaAlta
AND Estatus = 'ALTA') AND @Accion = 'CANCELAR'
BEGIN
UPDATE Tarima
SET Estatus = 'BAJA',
Baja    = GETDATE()
WHERE Tarima = @cTarimaAlta
IF EXISTS ( SELECT * FROM SaldoUWMS WHERE SubGrupo = @cTarimaAlta )
UPDATE SaldoUWMS
SET SaldoU = 0
WHERE SubGrupo = @cTarimaAlta
IF EXISTS ( SELECT * FROM SaldoU WHERE SubGrupo = @cTarimaAlta )
UPDATE SaldoU
SET SaldoU = 0
WHERE SubGrupo = @cTarimaAlta
END
END
FETCH NEXT FROM crInvFisTar INTO @cTarimaAlta, @Articuloc, @Cantidadc, @Almacenct, @Renglonc, @PosicionActualc, @PosicionRealc
END
CLOSE crInvFisTar
DEALLOCATE crInvFisTar
END
SELECT @SucursalPrincipal = Sucursal, @InvVerificarEnConexion = InvVerificarEnConexion FROM Version
SELECT @AccionOriginal = @Accion
IF @Accion = 'CANCELAR' AND @Base = 'TODO' SELECT @EstatusNuevo = 'CANCELADO' ELSE SELECT @EstatusNuevo = 'CONCLUIDO'
IF @Modulo = 'VTAS'
BEGIN
SELECT @Sucursal = Sucursal, @SucursalDestino = SucursalDestino, @SucursalOrigen = SucursalOrigen, @Empresa = Empresa, @MovID = MovID, @Mov = Mov, @FechaEmision = FechaEmision, @Concepto = Concepto, @Proyecto = Proyecto, @MovMoneda = Moneda, @MovTipoCambio = TipoCambio,
@MovUsuario = Usuario, @Autorizacion = NULLIF(RTRIM(Autorizacion), ''), @Mensaje = Mensaje, @Referencia = Referencia, @DocFuente = DocFuente, @Observaciones = Observaciones, @Estatus = UPPER(Estatus),
@Almacen = NULLIF(RTRIM(Almacen), ''), @AlmacenDestino = NULLIF(RTRIM(AlmacenDestino), ''), @Condicion = Condicion, @Vencimiento = Vencimiento, @FormaEnvio = FormaEnvio, @ClienteProv = Cliente, @EnviarA = EnviarA,
@DescuentoGlobal = DescuentoGlobal, @SobrePrecio = SobrePrecio, @Agente = Agente, @AnticiposFacturados = ISNULL(AnticiposFacturados, 0.0),
@ServicioGarantia = ServicioGarantia, @ServicioArticulo = NULLIF(RTRIM(ServicioArticulo), ''), @ServicioSerie = NULLIF(RTRIM(ServicioSerie), ''),
@OrigenTipo = OrigenTipo, @Origen = Origen, @OrigenID = OrigenID, @GenerarPoliza = GenerarPoliza, @FechaConclusion = FechaConclusion, @FechaRequerida = FechaRequerida, @HoraRequerida = HoraRequerida,
@CancelacionID = CancelacionID, @Departamento = Departamento, @GenerarOP = GenerarOP, @Periodicidad = NULLIF(RTRIM(Periodicidad), ''), @EndosarA = NULLIF(RTRIM(EndosarA), ''),
@AutoCorrida = NULLIF(RTRIM(AutoCorrida), ''), @Espacio = NULLIF(RTRIM(Espacio), ''), @AutoKmsActuales = ISNULL(AutoKmsActuales, 0), @UEN = UEN, @ServicioPlacas = NULLIF(RTRIM(ServicioPlacas), ''), @ServicioKms = NULLIF(ServicioKms, 0),
@AFArticulo = NULLIF(RTRIM(AFArticulo), ''), @AFSerie = NULLIF(RTRIM(AFSerie), ''),
@ExcluirPlaneacion = ISNULL(ExcluirPlaneacion, 0), @ZonaImpuesto = NULLIF(RTRIM(ZonaImpuesto), ''),
@AnexoID = NULLIF(AnexoID, 0), @Directo = ISNULL(Directo, 0), @ContUso2 = ContUso2, @ContUso3 = ContUso3
FROM Venta
WHERE ID = @ID
IF @@ERROR <> 0 SELECT @Ok = 1
SELECT @ClienteProvTipo	    = UPPER(Tipo),
@Credito 		    = Credito,
@CreditoEspecial	    = CreditoEspecial,
@PedidosParciales	    = PedidosParciales,
@VtasConsignacion 	    = VtasConsignacion,
@AlmacenVtasConsignacion = NULLIF(RTRIM(AlmacenVtasConsignacion), ''),
@CteChecarCredito   	    = UPPER(ISNULL(RTRIM(ChecarCredito), '(EMPRESA)')),
@CteBloquearMorosos      = UPPER(ISNULL(RTRIM(BloquearMorosos), '(EMPRESA)'))
FROM Cte
WHERE Cliente = @ClienteProv
IF @@ERROR <> 0 SELECT @Ok = 1
IF @CreditoEspecial = 1
BEGIN
SELECT @ConCredito = 1
SELECT @ConLimiteCredito   = ISNULL(CreditoConLimite, 0),
@LimiteCredito      = ISNULL(CreditoLimite, 0.0),
@ConLimitePedidos   = ISNULL(CreditoConLimitePedidos, 0),
@LimitePedidos      = ISNULL(CreditoLimitePedidos, 0.0),
@MonedaCredito      = CreditoMoneda,
@DiasCredito	 = CASE WHEN CreditoConDias = 1 THEN CreditoDias END,
@CondicionesValidas = CASE WHEN CreditoConCondiciones = 1 THEN NULLIF(UPPER(RTRIM(CreditoCondiciones)), '') END
FROM Cte
WHERE Cliente = @ClienteProv
END ELSE
SELECT @ConCredito         = ConCredito,
@ConLimiteCredito   = ISNULL(ConLimiteCredito, 0),
@LimiteCredito      = ISNULL(LimiteCredito, 0.0),
@ConLimitePedidos   = ISNULL(ConLimitePedidos, 0),
@LimitePedidos      = ISNULL(LimitePedidos, 0.0),
@MonedaCredito      = MonedaCredito,
@DiasCredito	 = CASE WHEN ConDias = 1 THEN Dias END,
@CondicionesValidas = CASE WHEN ConCondiciones = 1 THEN NULLIF(UPPER(RTRIM(Condiciones)), '') END
FROM CteCredito
WHERE Empresa = @Empresa AND Credito = @Credito
IF @ConCredito = 1 AND @ConLimiteCredito = 1 AND @MonedaCredito IS NOT NULL
SELECT @TipoCambioCredito = TipoCambio FROM Mon WHERE Moneda = @MonedaCredito
END ELSE
IF @Modulo = 'COMS'
BEGIN
SELECT @Sucursal = Sucursal, @SucursalDestino = SucursalDestino, @SucursalOrigen = SucursalOrigen, @Empresa = Empresa, @MovID = MovID, @Mov = Mov, @FechaEmision = FechaEmision, @Concepto = Concepto, @Proyecto = Proyecto, @MovMoneda = Moneda, @MovTipoCambio = TipoCambio,
@MovUsuario = Usuario, @Autorizacion = NULLIF(RTRIM(Autorizacion), ''), @Mensaje = Mensaje, @Referencia = Referencia, @DocFuente = DocFuente, @Observaciones = Observaciones, @Estatus = UPPER(Estatus),
@Almacen = NULLIF(RTRIM(Almacen), ''), @Condicion = Condicion, @Vencimiento = Vencimiento, @FormaEnvio = FormaEnvio, @ClienteProv = Proveedor, @DescuentoGlobal = DescuentoGlobal,
@FechaRequerida = FechaRequerida, @OrigenTipo = OrigenTipo, @Origen = Origen, @OrigenID = OrigenID,
@GenerarPoliza = GenerarPoliza, @FechaConclusion = FechaConclusion, @UEN = UEN, @ZonaImpuesto = NULLIF(RTRIM(ZonaImpuesto), ''), @Directo = ISNULL(Directo, 0), @ContUso2 = ContUso2, @ContUso3 = ContUso3
FROM Compra
WHERE ID = @ID
SELECT @ClienteProvTipo = UPPER(Tipo)
FROM Prov
WHERE Proveedor = @ClienteProv
END ELSE
IF @Modulo = 'INV'
BEGIN
SELECT @Sucursal = Sucursal, @SucursalDestino = SucursalDestino, @SucursalOrigen = SucursalOrigen, @Empresa = Empresa, @MovID = MovID, @Mov = Mov, @FechaEmision = FechaEmision, @Concepto = Concepto, @Proyecto = Proyecto, @MovMoneda = Moneda, @MovTipoCambio = TipoCambio,
@MovUsuario = Usuario, @Autorizacion = NULLIF(RTRIM(Autorizacion), ''), @Referencia = Referencia, @DocFuente = DocFuente, @Observaciones = Observaciones, @Estatus = UPPER(Estatus),
@Almacen = NULLIF(RTRIM(Almacen), ''), @AlmacenDestino = NULLIF(RTRIM(AlmacenDestino), ''), @AlmacenTransito = NULLIF(RTRIM(AlmacenTransito), ''), @Condicion = Condicion, @Vencimiento = Vencimiento, @FormaEnvio = FormaEnvio, @Largo = Largo,
@GenerarPoliza = GenerarPoliza, @FechaConclusion = FechaConclusion, @Agente = NULLIF(RTRIM(Agente), ''),
@OrigenTipo = OrigenTipo, @Origen = Origen, @OrigenID = OrigenID, @UEN = UEN, @InvConteo = ISNULL(Conteo,1), @Directo = ISNULL(Directo, 0) 
FROM Inv
WHERE ID = @ID
IF EXISTS (SELECT * FROM MovTipo WHERE Modulo = 'INV' AND Clave = 'INV.E' AND SubClave = 'INV.EA' AND Mov = @Mov)
BEGIN
SELECT @OrigenTipo = 'I:MES', @MovMES = 1
UPDATE Inv
SET OrigenTipo = @OrigenTipo,
MovMES	  = @MovMES
WHERE ID = @ID
END
END ELSE
IF @Modulo = 'PROD'
BEGIN
SELECT @Sucursal = Sucursal, @SucursalDestino = SucursalDestino, @SucursalOrigen = SucursalOrigen, @Empresa = Empresa, @MovID = MovID, @Mov = Mov, @FechaEmision = FechaEmision, @Concepto = Concepto, @Proyecto = Proyecto, @MovMoneda = Moneda, @MovTipoCambio = TipoCambio,
@MovUsuario = Usuario, @Autorizacion = NULLIF(RTRIM(Autorizacion), ''), @Referencia = Referencia, @DocFuente = DocFuente, @Observaciones = Observaciones, @Estatus = UPPER(Estatus),
@Almacen = NULLIF(RTRIM(Almacen), ''), @OrigenTipo = OrigenTipo, @Origen = Origen, @OrigenID = OrigenID,
@GenerarPoliza = GenerarPoliza, @FechaConclusion = FechaConclusion, @UEN = UEN, @Directo = ISNULL(Directo, 0)
FROM Prod
WHERE ID = @ID
END
IF @@ERROR <> 0 SELECT @Ok = 1
IF @Accion = 'AUTORIZAR'
SELECT @Autorizacion = @Usuario, @Accion = 'AFECTAR'
IF @ClienteProvTipo = 'ESTRUCTURA' SELECT @Ok = 20680, @OkRef = @ClienteProv
IF NULLIF(RTRIM(@Usuario), '') IS NULL SELECT @Usuario = @MovUsuario
EXEC spFechaAfectacion @Empresa, @Modulo, @ID, @Accion, @FechaEmision OUTPUT, @FechaRegistro, @FechaAfectacion OUTPUT
EXEC spExtraerFecha @FechaAfectacion OUTPUT
EXEC spMovTipo @Modulo, @Mov, @FechaAfectacion, @Empresa, @Estatus, @Concepto OUTPUT, @MovTipo OUTPUT, @Periodo OUTPUT, @Ejercicio OUTPUT, @Ok OUTPUT, @GenerarGasto = @GenerarGasto OUTPUT
EXEC spMovOk @SincroFinal, @ID, @Estatus, @Sucursal, @Accion, @Empresa, @Usuario, @Modulo, @Mov, @FechaAfectacion, @FechaRegistro, @Ejercicio, @Periodo, @Proyecto, @Ok OUTPUT, @OkRef OUTPUT
IF @Origen IS NOT NULL
SELECT @OrigenMovTipo = Clave, @OrigenSubMovTipo = SubClave FROM MovTipo WHERE Modulo = @OrigenTipo AND Mov = @Origen
IF @MovTipo = 'INV.TI' AND @Accion <> 'GENERAR' AND NOT (@AccionEspecial = 'TRANSITO' OR @SincroFinal = 1)
SELECT @Ok = 25410
IF @OrigenTipo = 'INV/EP' AND @Accion = 'CANCELAR' AND @Conexion = 0 SELECT @Ok = 60072
IF @Ok IS NOT NULL RETURN
IF @MovTipo IN ('VTAS.VC', 'VTAS.DC') AND @EnviarA IS NOT NULL
SELECT @AlmacenVtasConsignacion = ISNULL(NULLIF(RTRIM(AlmacenVtasConsignacion), ''), @AlmacenVtasConsignacion)
FROM CteEnviarA
WHERE Cliente = @ClienteProv AND ID = @EnviarA
SELECT @CfgFormaCosteo             = ISNULL(UPPER(RTRIM(FormaCosteo)), 'EMPRESA'),
@CfgTipoCosteo              = ISNULL(UPPER(RTRIM(TipoCosteo)), 'PROMEDIO'),
@CfgCosteoActividades       = UPPER(CosteoActividades),
@CfgCosteoNivelSubCuenta    = CosteoNivelSubCuenta,
@CfgCosteoMultipleSimultaneo= ISNULL(CosteoMultipleSimultaneo, 0),
@CfgToleranciaCosto	     = ISNULL(ToleranciaCosto, 0.0),
@CfgToleranciaCostoInferior = ISNULL(ToleranciaCostoInferior, 0.0),
@CfgToleranciaTipoCosto     = ISNULL(UPPER(RTRIM(ToleranciaTipoCosto)), 'PROMEDIO'),
@CfgValidarPrecios	     = ISNULL(UPPER(RTRIM(ValidarPrecios)), 'NO'),
@CfgPrecioMinimoSucursal    = ISNULL(PrecioMinimoNivelSucursal, 0),
@CfgValidarMargenMinimo     = ISNULL(UPPER(RTRIM(ValidarMargenMinimo)), 'ULTIMO COSTO'),
@CfgSeriesLotesMayoreo      = SeriesLotesMayoreo,
@CfgSeriesLotesAutoCampo    = ISNULL(UPPER(RTRIM(SeriesLotesAutoCampo)),'NUMERO'),
@CfgSeriesLotesAutoOrden    = ISNULL(UPPER(RTRIM(SeriesLotesAutoOrden)), 'NO'),
@CfgCosteoSeries	     = CosteoSeries,
@CfgCosteoLotes             = CosteoLotes,
@CfgPedidosReservar         = ISNULL(PedidosReservar, 0),
@CfgPedidosReservarEsp	     = ISNULL(PedidosReservarEsp, 0),
@CfgVentaSurtirDemas        = VentaSurtirDemas,
@CfgTransferirDemas	     = TransferirDemas,
@CfgVentaConfirmarServicios = VentaConfirmarServicios,
@CfgVentaConfirmarContratos = VentaConfirmarContratos,
@CfgInvConfirmarSolicitudes = InvConfirmarSolicitudes,
@CfgServiciosRequiereTareas = VentaServiciosRequiereTareas,
@CfgServiciosValidarID	     = ISNULL(VentaServiciosValidarID, 0),
@CfgVentaContratosArticulo  = NULLIF(RTRIM(VentaContratosArticulo), ''),
@CfgVentaContratosImpuesto  = ISNULL(VentaContratosImpuesto, 0.0),
@CfgInvPrestamosGarantias   = InvPrestamosGarantias,
@CfgInvEntradasSinCosto     = InvEntradasSinCosto,
@CfgInvFisicoConteo	     = ISNULL(InvFisicoConteo, 1),
@CfgVentaChecarCredito      = UPPER(ISNULL(RTRIM(VentaChecarCredito), 'PEDIDO')),
@CfgVentaPedidosDisminuyenCredito = ISNULL(VentaPedidosDisminuyenCredito, 0),
@CfgVentaBloquearMorosos    = UPPER(ISNULL(RTRIM(VentaBloquearMorosos), 'NO')),
@CfgVentaLiquidaIntegral    = VentaLiquidaIntegral,
@CfgVentaLiquidaIntegralCxc = VentaLiquidaIntegralCxc,
@CfgVentaComisionesCobradas = VentaComisionesCobradas,
@CfgImpInc		     = VentaPreciosImpuestoIncluido,
@CfgPrecioMoneda	     = VentaPrecioMoneda,
@CfgVentaRedondeoDecimales  = ISNULL(VentaCobroRedondeoDecimales, 2),
@CfgCompraConsignacion      = ISNULL(UPPER(RTRIM(CompraConsignacion)), 'NO'),
@CfgAutorizarRequisiciones  = AutorizarRequisiciones,
@CfgBackOrders	             = BackOrders,
@CfgBackOrdersNivel	     = UPPER(BackOrdersNivel),
@CfgFacturasPendientes      = FacturasPendientes,
@CfgLimiteRenFacturas       = ISNULL(VentaLimiteRenFacturas, 0),
@CfgNotasBorrador	     = NotasBorrador,
@CfgFormaPagoRequerida      = FormaPagoRequerida,
@CfgCancelarFacturaReservarPedido = CancelarFacturaReservarPedido,
@CfgComisionBase	     = UPPER(ComisionBase),
@CfgCompraValidarArtProv    = ISNULL(CompraValidarArtProv, 0),
@CfgValidarCC	 	     = ISNULL(CentroCostosValidar, 0),
@CfgCancelarFactura         = ISNULL(UPPER(CancelarFactura), 'NO'),
@CfgRestringirArtBloqueados = CASE @Modulo WHEN 'VTAS' THEN VentaRestringirArtBloqueados WHEN 'COMS' THEN CompraRestringirArtBloquedos ELSE 0 END,
@CfgLimiteCreditoNivelGrupo = ISNULL(VentaLimiteCreditoNivelGrupo, 0),
@CfgLimiteCreditoNivelUEN   = ISNULL(VentaLimiteCreditoNivelUEN, 0),
@CfgAnexosAlFacturar        = ISNULL(VentaAnexosAlFacturar, 0),
@CfgVentaEndoso	     = ISNULL(VentaEndoso, 0),
@CfgPosiciones		     = ISNULL(Posiciones, 0),
@CfgExistenciaAlterna	     = ISNULL(ExistenciaAlterna, 0),
@CfgExistenciaAlternaSerieLote = ISNULL(ExistenciaAlternaSerieLote, 0),
@CfgCentroCostos2VentaD = ISNULL(CentroCostos2VentaD,0),
@CfgCentroCostos3VentaD = ISNULL(CentroCostos3VentaD,0),
@CfgCentroCostos2VentaD = ISNULL(CentroCostos2CompraD,0),
@CfgCentroCostos3VentaD = ISNULL(CentroCostos3CompraD,0)
FROM EmpresaCfg
WHERE Empresa = @Empresa
IF @@ERROR <> 0 SELECT @Ok = 1
IF @Modulo = 'VTAS'
SELECT @CfgLimiteRenFacturas = ISNULL(NULLIF(VentaLimiteRenFacturas, 0), @CfgLimiteRenFacturas) FROM UEN WHERE UEN = @UEN
SELECT @CfgFacturaCobroIntegrado 	  = FacturaCobroIntegrado,
@CfgFacturaCobroIntegradoParcial = FacturaCobroIntegradoParcial,
@CfgAnticiposFacturados 	= CxcAnticiposFacturados,
@CfgCompraRecibirDemas  	= CompraRecibirDemas,
@CfgCompraRecibirDemasTolerancia = NULLIF(CompraRecibirDemasTolerancia, 0),
@CfgMultiUnidades       	= MultiUnidades,
@CfgMultiUnidadesNivel  	= ISNULL(UPPER(NivelFactorMultiUnidad), 'UNIDAD'),
@CfgCompraFactorDinamico	= CompraFactorDinamico,
@CfgInvFactorDinamico   	= InvFactorDinamico,
@CfgProdFactorDinamico  	= ProdFactorDinamico,
@CfgVentaFactorDinamico 	= VentaFactorDinamico,
@CfgFacturasPendientesSerieLote= FacturasPendientesSerieLote,
@CfgAutoAsignarBackOrders 	= AutoAsignarBackOrders,
@CfgInvMultiAlmacen	   	= InvMultiAlmacen,
@CfgCompraMultiAlmacen	        = CompraMultiAlmacen,
@CfgVentaMultiAlmacen   	= VentaMultiAlmacen,
@CfgVentaUENDetalle		= VentaUENDetalle,
@CfgVentaMultiAgente	   	= VentaMultiAgente,
@CfgVentaMultiDepartamento 	= VentaMultiDepartamento,
@CfgVentaAFDetalle		= VentaAFDetalle,
@CfgVentaEnviarADetalle	= VentaEnviarADetalle,
@CfgVentaExcluirPlaneacionDetalle = VentaExcluirPlaneacionDetalle,
@CfgVentaDFechaRequerida	= VentaDFechaRequerida,
@CfgVentaDHoraRequerida	= VentaDHoraRequerida,
@CfgValidarLotesCostoDif	= ValidarLotesCostoDif,
@CfgCompraAutoCargos           = CompraAutoCargos,
@CfgVentaAutoBonif		= VentaBonificacionAuto,
@CfgVentaArtAlmacenEspecifico  = VentaArtAlmacenEspecifico,
@CfgCompraCostosImpuestoIncluido= ISNULL(CompraCostosImpuestoIncluido, 0),
@CfgProdAutoLote	 	= ISNULL(UPPER(ProdAutoLote), 'NO'),
@CfgProdAutoCB		        = ISNULL(UPPER(ProdAutoCB), 'NO'),
@CfgTipoMerma		        = ISNULL(NULLIF(RTRIM(ProdTipoMerma), ''), '%'),
@CfgVentaRestringida           = ISNULL(VentaRestringida, 0),
@CfgPresupuestosPendientes     = CASE @Modulo WHEN 'VTAS' THEN VentaPresupuestosPendientes WHEN 'COMS' THEN CompraPresupuestosPendientes ELSE 0 END,
@CfgValidarFechaRequerida      = CASE @Modulo WHEN 'VTAS' THEN VentaValidarFechaRequerida  WHEN 'COMS' THEN CompraValidarFechaRequerida  ELSE 0 END,
@CfgVIN                        = ISNULL(VIN, 0),
@CfgVINAccesorioArt 		= VINAccesorioArt,
@CfgVINCostoSumaAccesorios	= VINCostoSumaAccesorios
FROM EmpresaCfg2
WHERE Empresa = @Empresa
IF @@ERROR <> 0 SELECT @Ok = 1
SELECT @CfgAlmacenTransito         = NULLIF(RTRIM(AlmacenTransito), ''),
@CfgDecimalesCantidades     = ISNULL(DecimalesCantidades, 0),
@CfgContX	             = ContX,
@CfgContXFacturasPendientes = ISNULL(ContXFacturasPendientes, 0),
@CfgAutotransportes	     = ISNULL(Autotransportes, 0),
@CfgAutoAsignarMovSucursalAlmacen = ISNULL(AutoAsignarMovSucursalAlmacen, 0),
@CfgPermitirMovSucursalDiferente  = ISNULL(PermitirMovSucursalDiferente, 0)
FROM EmpresaGral
WHERE Empresa = @Empresa
IF @@ERROR <> 0 SELECT @Ok = 1
IF @CfgAutoAsignarMovSucursalAlmacen = 1 SELECT @CfgPermitirMovSucursalDiferente = 0
IF @CfgContX = 1
SELECT @CfgContXGenerar = ISNULL(UPPER(RTRIM(ContXGenerar)), 'NO')
FROM EmpresaCfgModulo
WHERE Empresa = @Empresa
AND Modulo  = @Modulo
IF @@ERROR <> 0 SELECT @Ok = 1
SELECT @CfgBloquearNotasNegativas     = ISNULL(BloquearNotasNegativas, 0),
@CfgBloquearFacturacionDirecta = ISNULL(BloquearFacturacionDirecta, 0),
@CfgBloquearInvSalidaDirecta   = ISNULL(BloquearInvSalidaDirecta, 0)
FROM Usuario
WHERE Usuario = @Usuario
SELECT @CfgRecibirDemasSinLimites = ISNULL(RecibirDemasSinLimites, 0)
FROM UsuarioCfg2
WHERE Usuario = @Usuario
IF @CfgRecibirDemasSinLimites = 1 SELECT @CfgCompraRecibirDemasTolerancia = NULL
/***Inventarios Ubicacion*/
EXEC spMovInfo @ID,@Modulo,@Empresa=@Empresa OUTPUT,@Mov=@Mov OUTPUT,@Movtipo=@Movtipo OUTPUT, @Estatus=@Estatus OUTPUT
IF @MovTipo  IN ('INV.CPOS') AND @Estatus IN ('SINAFECTAR', 'CONFIRMAR') AND @Accion = 'AFECTAR'
EXEC spAntesAfectarCambioPosicion @Empresa,@ID,@Mov,@Movtipo,@Accion,@Estatus,@Ok OUTPUT, @OkRef OUTPUT  
/******************/
IF @MovTipo = 'INV.IF' AND @OrigenTipo = 'CR'
SELECT @CfgInvFisicoConteo = 1
IF @Accion = 'AFECTAR' AND @CfgAnexosAlFacturar = 1 AND @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX', 'VTAS.FB', 'VTAS.N', 'VTAS.FM') AND @OrigenTipo <> 'VMOS' AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR')
EXEC spAnexosAlFacturar @ID, @CfgMultiUnidades, @CfgMultiUnidadesNivel, @Ok OUTPUT, @OkRef OUTPUT
/*  IF @Accion IN ('AFECTAR', 'VERIFICAR') AND @CfgVIN = 1 AND @Modulo = 'VTAS' AND @MovTipo NOT IN ('VTAS.D', 'VTAS.DF', 'VTAS.B')
EXEC spVentaCalcISAN @ID
*/
IF @EndosarA IS NOT NULL
BEGIN
IF @Modulo = 'VTAS' AND (@MovTipo NOT IN ('VTAS.F','VTAS.FAR', 'VTAS.FB', 'VTAS.D', 'VTAS.DF', 'VTAS.B') OR @CfgVentaEndoso = 0 OR @ClienteProv = @EndosarA) SELECT @EndosarA = NULL
END
IF @Accion = 'CANCELAR' AND @Estatus = 'CONCLUIDO' AND @MovTipo IN ('VTAS.F','VTAS.FAR') AND @CfgCancelarFactura <> 'NO' AND @AnticiposFacturados = 0.0
BEGIN
IF @CancelacionID IS NULL
BEGIN
IF DATEPART(month, @FechaRegistro) > DATEPART(month, @FechaEmision)
OR DATEPART(year,  @FechaRegistro) > DATEPART(year,  @FechaEmision)
OR (@CfgCancelarFactura = 'Cambio Dia' AND DATEPART(day,  @FechaRegistro) > DATEPART(day,  @FechaEmision))
BEGIN
EXEC spCancelarFacturaOtroMes @Sucursal, @Modulo, @ID, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @Empresa, @Usuario, @FechaRegistro,
@GenerarMov OUTPUT, @GenerarMovID OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NULL
SELECT @Generar = 1, @Ok = 80030
ELSE RETURN
END
END ELSE SELECT @Ok = 60280
END
IF @Estatus = 'SINCRO' AND @Accion = 'CANCELAR'
BEGIN
EXEC spPuedeEditarMovMatrizSucursal @Sucursal, @SucursalOrigen, @ID, @Modulo, @Empresa, @Usuario, @Mov, @Estatus, 1, @PuedeEditar OUTPUT
IF @PuedeEditar = 0
SELECT @Ok = 60300
ELSE BEGIN
SELECT @Estatus = 'SINAFECTAR'/*, @Verificar = 0*/
EXEC spAsignarSucursalEstatus @ID, @Modulo, @Sucursal, @Estatus
END
END
IF @MovTipo = 'INV.IF' AND @Accion = 'AFECTAR' AND @Estatus = 'SINAFECTAR' AND @InvConteo=1 AND @CfgInvFisicoConteo = 1
BEGIN
UPDATE InvD SET CantidadA=Cantidad WHERE ID = @ID
UPDATE Inv SET Conteo = 1 WHERE ID = @ID
END
IF @MovTipo = 'INV.IF' AND @Accion = 'AFECTAR' AND @Estatus = 'PENDIENTE' AND @CfgInvFisicoConteo = 3
BEGIN
IF ISNULL(@InvConteo, 0) = 2
BEGIN
UPDATE InvD SET SegundoConteo = CantidadA, CantidadA = NULL WHERE ID = @ID
UPDATE Inv SET Conteo = 3 WHERE ID = @ID
RETURN
END ELSE
IF ISNULL(@InvConteo, 0) = 3 UPDATE InvD SET CantidadA = SegundoConteo WHERE ID = @ID AND SegundoConteo = Cantidad
END
IF @Ok IS NULL AND
((@Accion <> 'CANCELAR' AND @Estatus IN ('SINAFECTAR', 'BORRADOR', 'AUTORIZARE', 'CONFIRMAR', 'PENDIENTE', 'PROCESAR', 'RECURRENTE')) OR
(@Accion =  'CANCELAR' AND @Estatus IN ('CONCLUIDO',  'AUTORIZARE', 'PENDIENTE', 'PROCESAR', 'RECURRENTE'))) OR
(@Accion = 'GENERAR')
BEGIN
EXEC spSucursalMovSeguimiento @Sucursal, @Modulo, @Mov, @MovSeguimiento OUTPUT
IF @Accion = 'CANCELAR'
BEGIN
IF @MovTipo IN (/*'VTAS.C', */'VTAS.CS', 'VTAS.P', 'VTAS.S', 'VTAS.VC','VTAS.VCR', 'INV.IF', 'INV.P', 'INV.SOL','INV.OT','INV.OI','INV.TI','INV.SM') AND @Estatus = 'CONCLUIDO' SELECT @Ok = 60050
IF @MovTipo IN ('VTAS.C') AND @Estatus = 'CONCLUIDO' AND ISNULL(@OrigenTipo, '') <> 'OPORT' SELECT @Ok = 60050
END ELSE
BEGIN
IF @Modulo = 'VTAS'
BEGIN
IF @MovTipo IN (/*'VTAS.C', */'VTAS.CS','VTAS.OP') AND @Estatus = 'CONFIRMAR' AND @Accion <> 'VERIFICAR' SELECT @Utilizar = 1
IF @MovTipo IN ('VTAS.C') AND @Estatus = 'CONFIRMAR' AND @Accion <> 'VERIFICAR' AND ISNULL(@OrigenTipo, '') <> 'OPORT' SELECT @Utilizar = 1
IF @MovTipo IN ('VTAS.C') AND @Estatus = 'CONFIRMAR' AND @Accion = 'GENERAR' AND ISNULL(@OrigenTipo, '') = 'OPORT' SELECT @Utilizar = 1
IF @MovTipo IN ('VTAS.PR', 'VTAS.CTO', 'VTAS.S', 'VTAS.FR', 'VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM') AND @Accion = 'GENERAR' SELECT @Utilizar = 1
IF ((@MovTipo IN ('VTAS.P','VTAS.R','VTAS.S','VTAS.VC','VTAS.VCR', 'VTAS.SD') AND @Estatus = 'PENDIENTE') OR (@MovTipo = 'VTAS.CO' AND @Estatus = 'CONFIRMAR')) AND @Accion IN ('AFECTAR','GENERAR') SELECT @Utilizar = 1
END ELSE
IF @Modulo = 'COMS'
BEGIN
IF @MovTipo = 'COMS.C' AND @Estatus = 'CONFIRMAR' SELECT @Utilizar = 1
IF @MovTipo IN ('COMS.PR','COMS.R','COMS.O','COMS.OP','COMS.OG','COMS.OD','COMS.OI','COMS.IG','COMS.CC') AND @Estatus = 'PENDIENTE' AND @Accion IN ('AFECTAR','GENERAR') SELECT @Utilizar = 1
END ELSE
IF @Modulo = 'INV'
BEGIN
IF ((@MovTipo='INV.S' AND @Estatus = 'CONCLUIDO') OR (@MovTipo IN ('INV.P', 'INV.SOL', 'INV.OT','INV.OI','INV.TI','INV.SM') AND @Estatus = 'PENDIENTE')) AND @Accion IN ('AFECTAR','GENERAR') SELECT @Utilizar = 1
END ELSE
IF @Modulo = 'PROD'
BEGIN
IF @MovTipo = 'PROD.O' AND @Estatus = 'PENDIENTE' AND @Accion IN ('AFECTAR','GENERAR') SELECT @Utilizar = 1
END
IF (@Generar = 1 OR @Utilizar = 1) AND @GenerarMov IS NULL AND @Ok IS NULL
SELECT @Ok = 60040
IF @Ok = 60040 AND @MovTipo IN ('VTAS.C') AND @Estatus = 'CONFIRMAR' AND @Accion <> 'VERIFICAR' AND ISNULL(@OrigenTipo, '') = 'OPORT'
SELECT @Ok = NULL
END
IF @Ok IS NOT NULL RETURN
IF @Utilizar = 1
BEGIN
SELECT @Estatus =  'SINAFECTAR'
SELECT @UtilizarID = @ID, @UtilizarMov = @Mov, @UtilizarMovID = @MovID, @UtilizarMovTipo = @MovTipo,
@Mov = @GenerarMov, @GenerarMov = NULL, @MovID = NULL
EXEC spMovTipo @Modulo, @Mov, @FechaAfectacion, @Empresa, NULL, NULL, @MovTipo OUTPUT, @Periodo OUTPUT, @Ejercicio OUTPUT, @Ok OUTPUT
END
IF @FormaEnvio IS NOT NULL AND EXISTS(SELECT * FROM EmpresaCfgMovEsp WHERE Empresa = @Empresa AND Asunto = 'EMB' AND Modulo = @Modulo AND Mov = @Mov)
BEGIN
SELECT @CfgEmbarcar = Embarcar FROM FormaEnvio WHERE FormaEnvio = @FormaEnvio
END
IF @Modulo = 'COMS' AND @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR', 'SINCRO')
BEGIN
IF @CfgCompraMultiAlmacen = 0 UPDATE CompraD SET Almacen = @Almacen WHERE ID = @ID AND Almacen <> @Almacen
IF @CfgCentroCostos2VentaD = 0 UPDATE VentaD SET ContUso2 = @ContUso2 WHERE ID = @ID AND ContUso2 <> @ContUso2
IF @CfgCentroCostos3VentaD = 0 UPDATE VentaD SET ContUso3 = @ContUso3 WHERE ID = @ID AND ContUso3 <> @ContUso3
END
IF @Modulo = 'VTAS'
BEGIN
IF @CteChecarCredito   = '(EMPRESA)' SELECT @ChecarCredito   = @CfgVentaChecarCredito   ELSE SELECT @ChecarCredito   = @CteChecarCredito
IF @CteBloquearMorosos = '(EMPRESA)' SELECT @BloquearMorosos = @CfgVentaBloquearMorosos ELSE SELECT @BloquearMorosos = @CteBloquearMorosos
IF @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR', 'SINCRO')
BEGIN
IF @CfgVentaUENDetalle        = 0 UPDATE VentaD SET UEN          = @UEN          WHERE ID = @ID AND UEN          <> @UEN
IF @CfgVentaMultiAlmacen      = 0 UPDATE VentaD SET Almacen      = @Almacen      WHERE ID = @ID AND Almacen      <> @Almacen
IF @CfgVentaMultiAgente       = 0 UPDATE VentaD SET Agente       = @Agente       WHERE ID = @ID AND Agente       <> @Agente
IF @CfgVentaMultiDepartamento = 0 UPDATE VentaD SET Departamento = @Departamento WHERE ID = @ID AND Departamento <> @Departamento
IF @CfgVentaEnviarADetalle    = 0 UPDATE VentaD SET EnviarA      = @EnviarA      WHERE ID = @ID AND EnviarA      <> @EnviarA
IF @CfgVentaAFDetalle         = 0 UPDATE VentaD SET AFArticulo   = @AFArticulo, AFSerie = @AFSerie WHERE ID = @ID AND (AFArticulo <> @AFArticulo OR AFSerie <> @AFSerie)
IF @CfgVentaExcluirPlaneacionDetalle = 0 UPDATE VentaD SET ExcluirPlaneacion = @ExcluirPlaneacion WHERE ID = @ID AND ExcluirPlaneacion <> @ExcluirPlaneacion
IF @CfgCentroCostos2VentaD = 0 UPDATE VentaD SET ContUso2 = @ContUso2 WHERE ID = @ID AND ContUso2 <> @ContUso2
IF @CfgCentroCostos3VentaD = 0 UPDATE VentaD SET ContUso3 = @ContUso3 WHERE ID = @ID AND ContUso3 <> @ContUso3
END
END
/** 28.07.2006 **/
IF @Modulo = 'INV' AND @Accion IN (/*'GENERAR', */'VERIFICAR', 'AFECTAR') AND (@CfgInvMultiAlmacen = 0 OR @MovTipo IN ('INV.IF', 'INV.EI', 'INV.TIF', 'INV.TIS', 'INV.P', 'INV.R')) AND @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR')
BEGIN
/** 22.11.2006 **/
IF @MovTipo IN ('INV.EI', /*'INV.TIF', */'INV.TIS')
UPDATE InvD SET Almacen = @AlmacenDestino WHERE ID = @ID AND Almacen <> @AlmacenDestino
ELSE
UPDATE InvD SET Almacen = @Almacen WHERE ID = @ID AND Almacen <> @Almacen
END
IF @Ok IS NULL
BEGIN
/** 22.11.2006 **/
IF @MovTipo IN ('INV.EI', /*'INV.TIF', */'INV.TIS', 'INV.DTI') SELECT @AlmacenTmp = @AlmacenDestino ELSE SELECT @AlmacenTmp = @Almacen
SELECT @AlmacenSucursal = Sucursal FROM Alm WHERE Almacen = @AlmacenTmp
IF @MovSeguimiento = 'MATRIZ'
BEGIN
SELECT @SeguimientoMatriz = 1
IF @AlmacenSucursal <> 0 SELECT @Ok = 60350
IF @Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'AUTORIZARE', 'CONFIRMAR')
BEGIN
IF @SucursalPrincipal = 0
SELECT @Sucursal = 0
ELSE
IF @Accion <> 'CANCELAR' SELECT @Ok = 60300
END
END
IF @SeguimientoMatriz = 0 AND ISNULL(@SucursalDestino, @Sucursal) <> @AlmacenSucursal AND @MovTipo <> 'INV.TI' AND @Accion <> 'CANCELAR'
BEGIN
IF @CfgAutoAsignarMovSucursalAlmacen = 1
SELECT @SucursalDestino = @AlmacenSucursal
EXEC xpInvSucursalDestino @Accion, @Empresa, @ID, @MovTipo, @Almacen, @AlmacenDestino, @SucursalDestino OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
/*EXEC spSucursalEnLinea @AlmacenSucursal, @EnLinea OUTPUT
IF @EnLinea = 0
BEGIN*/
IF @Modulo = 'VTAS' UPDATE Venta  SET SucursalDestino = @SucursalDestino WHERE ID = @ID AND SucursalDestino <> @SucursalDestino ELSE
IF @Modulo = 'COMS' UPDATE Compra SET SucursalDestino = @SucursalDestino WHERE ID = @ID AND SucursalDestino <> @SucursalDestino ELSE
IF @Modulo = 'PROD' UPDATE Prod   SET SucursalDestino = @SucursalDestino WHERE ID = @ID AND SucursalDestino <> @SucursalDestino ELSE
IF @Modulo = 'INV'  UPDATE Inv    SET SucursalDestino = @SucursalDestino WHERE ID = @ID AND SucursalDestino <> @SucursalDestino
IF @@ERROR <> 0 SELECT @Ok = 1
/*END*/
END
IF ((@SucursalDestino IS NOT NULL AND @SucursalDestino <> @Sucursal) OR ISNULL(@SucursalDestino, @Sucursal) <> @AlmacenSucursal) AND @Accion = 'AFECTAR'
BEGIN
IF @SucursalDestino IS NULL SELECT @SucursalDestino = @Sucursal
EXEC spInvVerificarSincro @SucursalDestino, @Modulo, @ID, @MovTipo, @Almacen, @AlmacenDestino, @Ok OUTPUT, @OkRef OUTPUT
EXEC spSucursalEnLinea @SucursalDestino, @EnLinea OUTPUT
IF @EnLinea = 1
BEGIN
IF @Ok = 20780 AND @CfgPermitirMovSucursalDiferente = 1 SELECT @Ok = NULL, @OkRef = NULL
EXEC spMovConsecutivo @Sucursal, @SucursalOrigen, @SucursalDestino, @Empresa, @Usuario, @Modulo, @Ejercicio, @Periodo, @ID, @Mov, NULL, @Estatus, @Concepto, @Accion, @Conexion, @SincroFinal, @MovID OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
EXEC spAsignarSucursalEstatus @ID, @Modulo, @SucursalDestino, NULL
SELECT @Sucursal = @SucursalDestino
END ELSE
SELECT @Accion = 'SINCRO'
END
END
IF @AlmacenTransito IS NULL SELECT @AlmacenTransito = @CfgAlmacenTransito
IF @MovTipo IN ('VTAS.PR', 'COMS.PR') AND @CfgPresupuestosPendientes = 1
BEGIN
IF @Accion = 'CANCELAR'
SELECT @EstatusNuevo = 'CANCELADO'
ELSE
SELECT @EstatusNuevo = 'PENDIENTE'
END
IF @Modulo = 'VTAS'
BEGIN
IF @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR') AND @Accion = 'AFECTAR'
BEGIN
IF @CfgVentaDFechaRequerida = 0 UPDATE VentaD SET FechaRequerida = @FechaRequerida WHERE ID = @ID AND FechaRequerida <> @FechaRequerida
IF @CfgVentaDHoraRequerida  = 0 UPDATE VentaD SET HoraRequerida  = @HoraRequerida  WHERE ID = @ID AND HoraRequerida  <> @HoraRequerida
END
IF @MovTipo IN ('VTAS.VC','VTAS.VCR','VTAS.DC','VTAS.DCR','VTAS.EG') SELECT @EsTransferencia = 1
IF @MovTipo IN ('VTAS.OP', 'VTAS.C', 'VTAS.CS', 'VTAS.FR') SELECT @AfectarDetalle = 0
IF (@Accion <> 'CANCELAR' AND ((@MovTipo = 'VTAS.FM' AND @Estatus = 'PROCESAR')) OR (@MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FB','VTAS.D') AND @OrigenTipo = 'VMOS')) SELECT @FacturarVtasMostrador = 1
IF @MovTipo IN ('VTAS.P','VTAS.VP','VTAS.S','VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX','VTAS.FB','VTAS.R','VTAS.DR','VTAS.SG','VTAS.D','VTAS.DF','VTAS.EG','VTAS.VC','VTAS.VCR','VTAS.DC','VTAS.DCR','VTAS.N','VTAS.NO', 'VTAS.NR','VTAS.FM')
BEGIN
SELECT @AfectarMatando = 1
IF @VolverAfectar = 5 AND @Accion IN ('RESERVAR', 'RESERVARPARCIAL') AND @MovTipo = 'VTAS.P' SELECT @AfectarMatando = 0
IF @Utilizar = 1 AND @UtilizarMovTipo IN ('VTAS.C', 'VTAS.CS', 'VTAS.FR') SELECT @AfectarMatando = 0 
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX') AND @Accion <> 'CANCELAR' AND @Estatus = 'PENDIENTE' SELECT @AfectarMatando = 0 
END
IF @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR')
BEGIN
IF @Estatus IN ('SINAFECTAR', 'BORRADOR') AND
(@MovTipo IN ('VTAS.C', 'VTAS.CS') OR
(@MovTipo = 'VTAS.S'  AND @CfgVentaConfirmarServicios = 1) OR
(@MovTipo = 'VTAS.CO' AND @CfgVentaConfirmarContratos = 1)) OR
(@MovTipo IN ('VTAS.N', 'VTAS.FM') AND @Accion = 'AFECTAR' AND @Estatus = 'SINAFECTAR' AND @MovID IS NULL AND @CfgVentaLiquidaIntegral = 0)
SELECT @EstatusNuevo = 'CONFIRMAR'
ELSE
IF @MovTipo IN ('VTAS.P', 'VTAS.S', 'VTAS.R', 'VTAS.SD')
BEGIN
IF @AnexoID IS NOT NULL
BEGIN
IF NOT EXISTS(SELECT * FROM Venta WHERE ID = @AnexoID AND Empresa = @Empresa AND Estatus IN ('PENDIENTE', 'CANCELADO'))
SELECT @Ok = 10350
ELSE
SELECT @EstatusNuevo = 'CONCLUIDO', @AnexarTodoDetalle = 1
END ELSE BEGIN
SELECT @EstatusNuevo = 'PENDIENTE'
IF @Accion = 'AFECTAR' AND @MovTipo IN ('VTAS.P', 'VTAS.S') AND @CfgPedidosReservar = 1 AND @SeguimientoMatriz = 0
IF @CfgPedidosReservarEsp = 0 OR EXISTS(SELECT * FROM EmpresaPedidosReservarEsp WHERE Empresa = @Empresa AND Modulo = @Modulo AND Mov = @Mov)
IF ABS(DATEDIFF(day, GETDATE(), @FechaEmision)) < 2
IF @Directo = 1
SELECT @Accion = 'RESERVARPARCIAL'
ELSE
SELECT @VolverAfectar = 5
END
END
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX','VTAS.FB')
BEGIN
IF @CfgFacturasPendientes = 1 AND @Accion = 'AFECTAR' AND @MovTipo = 'VTAS.F'
BEGIN
IF @OrigenTipo <> 'VMOS'
BEGIN
IF NOT EXISTS(SELECT * FROM VentaD d, MovTipo mt WHERE d.ID = @ID AND mt.Mov = d.Aplica AND mt.Modulo = 'VTAS' AND mt.Clave = 'VTAS.R') AND
NOT EXISTS(SELECT * FROM VentaD d WHERE d.ID = @ID AND @CfgFacturasPendientesSerieLote = 0 AND d.RenglonTipo IN ('S', 'L', 'V', 'A'))
BEGIN
IF (SELECT FacturasPendientes FROM Alm WHERE Almacen = @Almacen ) = 1
BEGIN
IF @CfgPosiciones = 1 AND EXISTS (SELECT ID FROM VentaD WHERE ID = @ID AND NULLIF(Posicion,'') IS NULL)
SELECT @Ok= 13050, @OkRef = 'Articulo: '+(SELECT TOP 1 Articulo FROM VentaD WHERE ID = @ID AND NULLIF(Posicion,'') IS NULL)
ELSE
BEGIN
SELECT @EstatusNuevo = 'PENDIENTE'
/*IF @CfgPedidosReservar = 1 */SELECT @Accion = 'RESERVARPARCIAL'
END
END
END
END
END ELSE
IF @Utilizar = 1 AND @UtilizarMovTipo IN ('VTAS.VC','VTAS.VCR') SELECT @VoltearAlmacen = 1 
END
IF @MovTipo IN ('VTAS.VC', 'VTAS.DC') SELECT @AlmacenDestino = @AlmacenVtasConsignacion
IF @MovTipo IN ('VTAS.VCR', 'VTAS.DCR')
BEGIN
SELECT @AlmacenDestino = NULLIF(RTRIM(Almacen), '') FROM MovTipo WHERE Modulo = @Modulo AND Mov = @Mov
IF @AlmacenDestino IS NULL SELECT @Ok = 20770
END
IF @MovTipo IN ('VTAS.VC', 'VTAS.VCR') SELECT @EstatusNuevo = 'PENDIENTE'
IF @MovTipo IN ('VTAS.DC', 'VTAS.DCR') SELECT @VoltearAlmacen = 1 
IF @MovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR', 'VTAS.FM') AND @EstatusNuevo <> 'CONFIRMAR' SELECT @EstatusNuevo = 'PROCESAR', @AfectarVtasMostrador = 1
IF @MovTipo = 'VTAS.FR' SELECT @EstatusNuevo = 'RECURRENTE'
IF @MovTipo = 'VTAS.OP' SELECT @EstatusNuevo = 'CONFIRMAR'
END
ELSE
IF @Estatus = 'PENDIENTE'
BEGIN
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX','VTAS.P','VTAS.S','VTAS.VC','VTAS.VCR') AND @EstatusNuevo <> 'CANCELADO' SELECT @EstatusNuevo = 'PENDIENTE'
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FC', 'VTAS.FG', 'VTAS.FX')
IF @Accion = 'AFECTAR'
BEGIN
IF EXISTS (SELECT * FROM VentaD d, Art a WHERE d.Articulo = a.Articulo AND d.ID = @ID AND a.Tipo NOT IN ('JUEGO', 'SERVICIO') AND (ISNULL(d.CantidadPendiente, 0.0) <> 0.0 OR ISNULL(d.CantidadOrdenada, 0.0) <> 0.0))
SELECT @Ok = 20520
ELSE SELECT @EstatusNuevo = 'CONCLUIDO', @AfectarMatando = 0
END ELSE
IF @Accion = 'CANCELAR'
IF EXISTS (SELECT * FROM VentaD WHERE ID = @ID AND ISNULL(CantidadOrdenada, 0.0) <> 0.0)
SELECT @Ok = 20530
END ELSE
IF @Estatus = 'PROCESAR'
BEGIN
IF @MovTipo IN ('VTAS.N', 'VTAS.NO', 'VTAS.NR','VTAS.FM') AND @Accion = 'CANCELAR'
SELECT @AfectarVtasMostrador = 1
END
END ELSE
IF @Modulo = 'COMS'
BEGIN
IF @Estatus IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR')
BEGIN
IF @MovTipo = 'COMS.R'
BEGIN
IF @CfgAutorizarRequisiciones = 0 SELECT @EstatusNuevo = 'PENDIENTE'
ELSE SELECT @EstatusNuevo = 'AUTORIZARE'
END ELSE
IF @MovTipo = 'COMS.C' SELECT @EstatusNuevo = 'CONFIRMAR'  ELSE
IF @MovTipo IN ('COMS.O',/*'COMS.OP',*/'COMS.OG','COMS.OD','COMS.OI','COMS.IG','COMS.CC') SELECT @EstatusNuevo = 'PENDIENTE'
IF @MovTipo IN ('COMS.EG', 'COMS.EI') AND @Accion <> 'GENERAR' AND @OrigenSubMovTipo <> 'COMS.EIMPO' EXEC spCompraCostoInv @ID
END ELSE
IF @Estatus = 'AUTORIZARE'
BEGIN
IF @MovTipo = 'COMS.R' AND @EstatusNuevo <> 'CANCELADO' SELECT @EstatusNuevo = 'PENDIENTE'
END ELSE
IF @Estatus = 'PENDIENTE'
BEGIN
IF @MovTipo IN ('COMS.R','COMS.O','COMS.OP','COMS.OG','COMS.OD','COMS.OI','COMS.CC') AND @EstatusNuevo <> 'CANCELADO' SELECT @EstatusNuevo = 'PENDIENTE'
END
/*      IF @MovTipo IN ('COMS.O','COMS.OP','COMS.OG','COMS.OI','COMS.F','COMS.FL','COMS.EG', 'COMS.EI','COMS.IG','COMS.D','COMS.DG','COMS.CC','COMS.DC') SELECT @AfectarAlmacenRenglon = 1*/
IF @MovTipo = 'COMS.C' OR (@MovTipo = 'COMS.R' AND @Estatus = 'SINAFECTAR' AND @EstatusNuevo = 'AUTORIZARE') SELECT @AfectarDetalle = 0
IF @MovTipo IN ('COMS.R', 'COMS.O','COMS.OP','COMS.CP','COMS.OG','COMS.OD','COMS.D','COMS.OI','COMS.F','COMS.FL','COMS.EG', 'COMS.EI','COMS.IG','COMS.CC','COMS.DC','COMS.DG')
BEGIN
SELECT @AfectarMatando = 1
IF @Utilizar = 1 AND @UtilizarMovTipo = 'COMS.C' SELECT @AfectarMatando = 0 
END
IF @MovTipo = 'COMS.DC' SELECT @DescuentoGlobal = 0.0
END ELSE
IF @Modulo = 'INV'
BEGIN
IF @MovTipo = 'INV.SOC' SELECT @AfectarMatando = 1
IF @MovTipo = 'INV.EP' AND @Estatus = 'SINAFECTAR' AND @Accion = 'AFECTAR'
BEGIN
SELECT @EstatusNuevo = 'BORRADOR'
UPDATE InvD SET Costo = NULL, CostoInv = NULL WHERE ID = @ID
END
IF @MovTipo = 'INV.IF' AND @Accion <> 'CANCELAR'
BEGIN
IF @CfgInvFisicoConteo=1 OR @Estatus = 'PENDIENTE'
SELECT @Generar = 1, @GenerarCopia = 0
ELSE SELECT @EstatusNuevo = 'PENDIENTE'
END
IF @MovTipo IN ('INV.T','INV.TC','INV.TG','INV.R','INV.P') SELECT @EsTransferencia = 1
IF @MovTipo = 'INV.R' AND @Estatus <> 'PENDIENTE' SELECT @AfectarMatando = 1, @AfectarMatandoOpcional = 0
IF @MovTipo IN ('INV.S', 'INV.CM', 'INV.SI', 'INV.E', 'INV.EI', 'INV.T', 'INV.TIF', 'INV.TC', 'INV.TG', 'INV.P', 'INV.SOL', 'INV.OT', 'INV.OI', 'INV.DTI', 'INV.TMA') SELECT @AfectarMatando = 1
IF @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR')
BEGIN
IF @CfgInvConfirmarSolicitudes = 1 AND @MovTipo = 'INV.SOL' AND @Estatus = 'SINAFECTAR'
SELECT @EstatusNuevo = 'CONFIRMAR'
ELSE
IF @MovTipo IN ('INV.P', 'INV.SOL', 'INV.OT', 'INV.OI', 'INV.TI','INV.SM') SELECT @EstatusNuevo = 'PENDIENTE'
IF @MovTipo IN ('INV.OT', 'INV.T','INV.TG')
BEGIN
IF EXISTS(SELECT * FROM Alm o, Alm d WHERE o.Almacen = @Almacen AND d.Almacen = @AlmacenDestino AND o.Sucursal <> d.Sucursal) SELECT @Ok = 60360 ELSE
IF EXISTS(SELECT * FROM InvD i, Alm o, Alm d WHERE i.ID = @ID AND i.Almacen = o.Almacen AND d.Almacen = @AlmacenDestino AND o.Sucursal <> d.Sucursal) SELECT @Ok = 60360
END
IF @MovTipo IN ('INV.T','INV.TG')
BEGIN
IF @Largo = 1
BEGIN
IF @AlmacenTransito IS NULL OR @AlmacenDestino IS NULL SELECT @Ok = 20120
SELECT @EstatusNuevo = 'PENDIENTE', @AlmacenDestino = @AlmacenTransito
END
END
IF @Accion = 'AFECTAR' AND @EstatusNuevo <> 'CONFIRMAR' AND
@MovTipo IN ('INV.SOL', 'INV.OT', 'INV.OI') AND @CfgPedidosReservar = 1 AND @SeguimientoMatriz = 0
IF @CfgPedidosReservarEsp = 0 OR EXISTS(SELECT * FROM EmpresaPedidosReservarEsp WHERE Empresa = @Empresa AND Modulo = @Modulo AND Mov = @Mov)
IF ABS(DATEDIFF(day, GETDATE(), @FechaEmision)) < 2
IF @Directo = 1
SELECT @Accion = 'RESERVARPARCIAL'
ELSE
SELECT @VolverAfectar = 5
IF @MovTipo = 'INV.EI' AND @Accion <> 'GENERAR' EXEC spInvCostoInv @ID
END
ELSE
IF @Estatus = 'PENDIENTE'
BEGIN
IF @MovTipo IN ('INV.T','INV.TG') BEGIN IF @Accion = 'CANCELAR' SELECT @AlmacenDestino = @AlmacenTransito ELSE SELECT @AlmacenEspecifico = @AlmacenTransito /*@Almacen = @AlmacenTransito*/ END ELSE
IF @MovTipo = 'INV.P' AND @Accion <> 'CANCELAR' SELECT @VoltearAlmacen = 1 
IF @MovTipo IN ('INV.SOL', 'INV.OT', 'INV.OI', 'INV.TI','INV.SM') AND @EstatusNuevo <> 'CANCELADO' SELECT @EstatusNuevo = 'PENDIENTE'
END
END ELSE
IF @Modulo = 'PROD'
BEGIN
SELECT @AfectarAlmacenRenglon = 1
IF @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR')
BEGIN
IF @MovTipo = 'PROD.O'
BEGIN
SELECT @EstatusNuevo = 'PENDIENTE'
EXEC spProdAutoSerieLote @CfgProdAutoLote, @Sucursal, @ID
END
END ELSE
IF @Estatus = 'PENDIENTE'
BEGIN
IF @MovTipo = 'PROD.O' AND @EstatusNuevo <> 'CANCELADO' SELECT @EstatusNuevo = 'PENDIENTE'
IF @MovTipo IN ('PROD.A', 'PROD.R', 'PROD.E') AND @Accion <> 'CANCELAR' SELECT @EstatusNuevo = 'CONCLUIDO'
END
IF @MovTipo IN (/*'PROD.O', */'PROD.E', 'PROD.CO') SELECT @AfectarMatando = 1
END
IF @Accion = 'GENERAR' OR (@Accion IN ('RESERVAR', 'DESRESERVAR', 'ASIGNAR', 'DESASIGNAR') AND @Base = 'TODO') SELECT @Verificar = 0
/* Si no se verifica en algunar cancelaciones como la entrada de compra, no checa que exista disponible para cancelar */
IF @Accion = 'RESERVAR' AND @Base = 'PENDIENTE' SELECT @Accion = 'RESERVARPARCIAL'
IF @MovTipo IN ('COMS.CC', 'COMS.DC', 'INV.TG') SELECT @AfectarConsignacion = 1
EXEC xpInvAccion @Empresa, @Sucursal, @Usuario, @Modulo, @ID, @MovTipo, @Base, @Estatus, @EstatusNuevo, @Directo, @Accion OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @Accion = 'CANCELAR' AND @EsTransferencia = 1 AND @MovTipo NOT IN ('VTAS.DC', 'VTAS.DCR')
SELECT @VoltearAlmacen = ~@VoltearAlmacen 
IF @Almacen        IS NOT NULL SELECT @AlmacenTipo        = UPPER(Tipo) FROM Alm WHERE Almacen = @Almacen
IF @AlmacenDestino IS NOT NULL SELECT @AlmacenDestinoTipo = UPPER(Tipo) FROM Alm WHERE Almacen = @AlmacenDestino
IF @Estatus IN ('SINAFECTAR','AUTORIZARE','CONFIRMAR','BORRADOR') AND @Accion <> 'CANCELAR'
BEGIN
IF @MovTipo = 'VTAS.FR'
EXEC spCalcularPeriodicidad @FechaEmision, @Periodicidad, @Vencimiento OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
ELSE
EXEC spCalcularVencimiento @Modulo, @Empresa, @ClienteProv, @Condicion, @FechaEmision, @Vencimiento OUTPUT, @Dias OUTPUT, @Ok OUTPUT
EXEC spExtraerFecha @Vencimiento OUTPUT
END
IF @Accion = 'DESAFECTAR'
EXEC spInvDesafectar @Modulo, @ID, @Usuario, @MovTipo, @Estatus, @Ok OUTPUT, @OkRef OUTPUT
IF ((@Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR', 'PENDIENTE') AND @Accion <> 'GENERAR') OR @Accion = 'CANCELAR')
BEGIN
IF @Modulo = 'VTAS' AND @Condicion IS NOT NULL AND EXISTS(SELECT * FROM Condicion WHERE Condicion = @Condicion AND ControlAnticipos = 'COBRAR PEDIDO')
SELECT @CobrarPedido = 1
IF @MovTipo IN ('VTAS.P', 'VTAS.S', 'VTAS.SD', 'VTAS.VP', 'VTAS.B') AND @CobrarPedido = 1
SELECT @CobroIntegrado = 1
IF @MovTipo IN ('VTAS.N','VTAS.FM') AND @CobrarPedido = 0
SELECT @CobroIntegrado = 1
IF @MovTipo IN ('VTAS.F','VTAS.FAR', 'VTAS.FB', 'VTAS.D', 'VTAS.DF') AND @CfgFacturaCobroIntegrado = 1 AND @Vencimiento<=@FechaEmision AND @CobrarPedido = 0
BEGIN
SELECT @CobroIntegrado = 1
IF @CfgFacturaCobroIntegradoParcial = 1 AND (SELECT FacturaCobroIntegradoParcial FROM Condicion WHERE Condicion = @Condicion) = 1
SELECT @CobroIntegradoParcial = 1
END
IF @Modulo = 'VTAS' AND (@OrigenTipo='CR' OR @EsCancelacionFactura = 1 OR @OrigenTipo='VMOS')
SELECT @CobroIntegrado = 0
IF @CobroIntegrado = 1 AND @CfgVentaLiquidaIntegral = 1 AND @CfgVentaLiquidaIntegralCxc = 1
SELECT @CobroIntegradoCxc = 1
END
IF @CfgSeriesLotesMayoreo = 1 AND @Accion IN ('AFECTAR', 'VERIFICAR') AND @Estatus IN ('SINAFECTAR','CONFIRMAR','BORRADOR')
EXEC spInvQuitarBasura @Empresa, @Modulo, @ID, @Conexion, @SincroFinal, @Sucursal
IF @MovTipo IN ('INV.SI', 'INV.DTI') AND @Accion = 'CANCELAR' AND @Ok IS NULL
BEGIN
SELECT @IDTransito = MIN(DID) FROM MovFlujo WHERE Cancelado = 0 AND Sucursal = @Sucursal AND Empresa = @Empresa AND OModulo = @Modulo AND OID = @ID AND DModulo = @Modulo
IF @IDTransito IS NULL
BEGIN
IF (SELECT fixCancelarTraspasoSinTransito FROM EmpresaGral WHERE Empresa = @Empresa) = 0
SELECT @Ok = 25420
END
IF @Ok IS NULL AND @IDTransito IS NOT NULL
BEGIN
SELECT @TransitoSucursal = Sucursal, @TransitoMov = Mov, @TransitoMovID = MovID, @TransitoEstatus = Estatus FROM Inv WHERE ID = @IDTransito
EXEC spPuedeEditarMovMatrizSucursal @TransitoSucursal, /*@TransitoSucursal*/@Sucursal, @IDTransito, @Modulo, @Empresa, @Usuario, @TransitoMov, @TransitoEstatus, 1, @PuedeEditar OUTPUT
IF @PuedeEditar = 0 SELECT @Ok = 25430 ELSE
IF @TransitoEstatus = 'CONCLUIDO' SELECT @Ok = 60050 ELSE
IF EXISTS(SELECT * FROM InvD WHERE CantidadPendiente<>Cantidad AND ID = @IDTransito) SELECT @Ok = 60080
IF @Ok IS NULL
BEGIN
EXEC spEmbarqueMov @Accion, @Empresa, @Modulo, @IDTransito, @TransitoMov, @TransitoMovID, @TransitoEstatus, @EstatusNuevo, @CfgEmbarcar, @Ok OUTPUT
IF @Ok IS NOT NULL SELECT @OkRef = RTRIM(@TransitoMov)+' '+RTRIM(@TransitoMovID)
END
END
END
IF @Accion = 'CANCELAR' AND @Base IN ('SELECCION', 'PENDIENTE') AND @MovTipo <> 'COMS.O' SELECT @AfectarMatando = 0
IF @Accion = 'CANCELAR' AND @MovTipo = 'PROD.CO' SELECT @Ok = 10100
IF @CfgAutotransportes = 1 AND @Espacio IS NOT NULL AND @Modulo = 'VTAS' AND @Accion <> 'CANCELAR' AND @Estatus = 'SINAFECTAR' AND @AccionEspecial <> 'AUTO_MANT' AND @MovTipo = 'VTAS.P' AND @AutoCorrida IS NOT NULL AND @Ok IS NULL
EXEC xpGenerarAutoCorrida @ID, @Empresa, @Sucursal, @Mov, @AutoCorrida, @Almacen, @FechaRequerida, @Espacio, @MovMoneda, @MovTipoCambio, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo = 'COMS.OP' AND @Accion = 'AFECTAR'
EXEC spCompraProrrateoPreparar @Empresa, @ID, @Ok OUTPUT, @OkRef OUTPUT
/* Esto antes estaba en spInvVerificar */
IF @Accion = 'CANCELAR' AND (@Base IN ('TODO','PENDIENTE') OR (@MovTipo NOT IN ('INV.SM', 'INV.OT', /** JH 22.08.2006 **/ 'INV.OI')))	
BEGIN
IF @Conexion = 0
IF EXISTS (SELECT * FROM MovFlujo WHERE Cancelado = 0 AND Empresa = @Empresa AND DModulo = @Modulo AND DID = @ID AND OModulo <> DModulo) AND @MovTipo <> 'INV.CM'
BEGIN
SELECT @Ok = 60071
IF @MovTipo IN ('INV.OT', 'INV.OI') AND @OrigenMovTipo IN ('VTAS.P', 'VTAS.S') SELECT @Ok = NULL
IF @OrigenTipo = 'PACTO' SELECT @Ok = NULL
IF @Ok = 60071
EXEC xpOk_60071 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
END
END
IF ((@Conexion = 0 OR @InvVerificarEnConexion = 1 OR @Accion ='VERIFICAR' OR @OrigenTipo = 'I:MES') OR @AccionEspecial = 'TRANSITO') AND @Accion NOT IN ('CONSECUTIVO'/*, 'SINCRO'*/) AND @Ok IS NULL AND @Verificar = 1
BEGIN
EXEC spInvVerificar @ID, @Accion, @Base, @Empresa, @Usuario, @Autorizacion OUTPUT, @Mensaje, @Modulo, @Mov, @MovID, @MovTipo, @MovMoneda, @MovTipoCambio, @FechaEmision, @Ejercicio, @Periodo,
@Almacen, @AlmacenTipo, @AlmacenDestino, @AlmacenDestinoTipo, @VoltearAlmacen, @AlmacenEspecifico, @Condicion, @Vencimiento,
@ClienteProv, @EnviarA, @DescuentoGlobal, @SobrePrecio, @ConCredito, @ConLimiteCredito, @LimiteCredito, @ConLimitePedidos, @LimitePedidos, @MonedaCredito, @TipoCambioCredito, @DiasCredito, @CondicionesValidas,
@PedidosParciales, @VtasConsignacion, @AlmacenVtasConsignacion, @AnticiposFacturados,
@Estatus, @EstatusNuevo, @AfectarMatando, @AfectarMatandoOpcional, @AfectarConsignacion, @AfectarAlmacenRenglon,
@OrigenTipo, @Origen, @OrigenID, @OrigenMovTipo,
@FacturarVtasMostrador, @EsTransferencia, @ServicioGarantia, @ServicioArticulo, @ServicioSerie, @FechaRequerida, @AutoCorrida,
@CfgCosteoNivelSubCuenta, @CfgDecimalesCantidades, @CfgSeriesLotesMayoreo, @CfgSeriesLotesAutoOrden, @CfgValidarPrecios, @CfgPrecioMinimoSucursal, @CfgValidarMargenMinimo, @CfgVentaSurtirDemas, @CfgCompraRecibirDemas, @CfgCompraRecibirDemasTolerancia, @CfgTransferirDemas, @ChecarCredito, @CfgVentaPedidosDisminuyenCredito, @BloquearMorosos, @CfgVentaLiquidaIntegral, @CfgFacturaCobroIntegrado, @CfgInvPrestamosGarantias,
@CfgInvEntradasSinCosto, @CfgServiciosRequiereTareas, @CfgServiciosValidarID, @CfgImpInc, @CfgLimiteRenFacturas, @CfgNotasBorrador, @CfgAnticiposFacturados, @CfgMultiUnidades, @CfgMultiUnidadesNivel, @CfgCompraFactorDinamico, @CfgInvFactorDinamico, @CfgProdFactorDinamico, @CfgVentaFactorDinamico, @CfgToleranciaCosto, @CfgToleranciaCostoInferior, @CfgToleranciaTipoCosto, @CfgFormaPagoRequerida, @CfgBloquearNotasNegativas, @CfgBloquearFacturacionDirecta, @CfgBloquearInvSalidaDirecta, @SeguimientoMatriz, @CobroIntegrado, @CobroIntegradoCxc, @CobroIntegradoParcial, @CobrarPedido, @CfgCompraValidarArtProv,
@CfgValidarCC, @CfgVentaRestringida, @CfgLimiteCreditoNivelGrupo, @CfgLimiteCreditoNivelUEN, @CfgRestringirArtBloqueados, @CfgValidarFechaRequerida, @FacturacionRapidaAgrupada,
@Utilizar, @UtilizarID, @UtilizarMovTipo,
@Generar, @GenerarMov, @GenerarAfectado, @Conexion, @SincroFinal, @Sucursal, @SucursalDestino, @AccionEspecial, @AnexoID,
@Autorizar OUTPUT, @AfectarConsecutivo OUTPUT, @Ok OUTPUT, @OkRef OUTPUT,
@CfgPrecioMoneda = @CfgPrecioMoneda
IF @Autorizar = 1 AND @Modulo IN ('VTAS', 'COMS')
BEGIN
IF @Modulo = 'VTAS' UPDATE Venta  SET Mensaje = @Ok WHERE ID = @ID ELSE
IF @Modulo = 'COMS' UPDATE Compra SET Mensaje = @Ok WHERE ID = @ID
IF @@ERROR <> 0 SELECT @Ok = 1
END
IF @Ok BETWEEN 80000 AND 89999 AND @Accion IN ('AFECTAR','GENERAR','CANCELAR') SELECT @Ok = NULL ELSE
IF @Accion = 'VERIFICAR' AND @Ok IS NULL
BEGIN
SELECT @Ok = 80000
EXEC xpOk_80000 @Empresa, @Usuario, @Accion, @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
END
END
IF @CfgAutotransportes = 1 AND @Espacio IS NOT NULL AND @Modulo = 'VTAS' AND @Accion NOT IN ('CANCELAR', 'GENERAR') AND @Estatus = 'SINAFECTAR' AND @AccionEspecial <> 'AUTO_MANT' AND @Ok IS NULL
EXEC xpAutoMant @ID, @Mov, @Almacen, @Usuario, @Empresa, @FechaEmision, @FechaRegistro, @Espacio, @AutoKmsActuales, @Ok OUTPUT, @OkRef OUTPUT
IF @MovTipo = 'VTAS.S' AND @Accion <> 'CANCELAR' AND @ServicioSerie IS NOT NULL AND @Ok IS NULL
UPDATE VIN SET Empresa = @Empresa, Cliente = @ClienteProv, Placas = @ServicioPlacas, Km = @ServicioKms WHERE VIN = @ServicioSerie
IF @MovTipo = 'VTAS.F' AND @OrigenMovTipo = 'VTAS.S' AND @Accion <> 'CANCELAR' AND @ServicioSerie IS NOT NULL AND @Ok IS NULL
BEGIN
UPDATE VIN SET FechaUltimoServicio = @FechaEmision WHERE VIN = @ServicioSerie
UPDATE Venta SET FechaOriginal = @FechaEmision WHERE Empresa = @Empresa AND Mov = @Origen AND MovID = @OrigenID AND Estatus IN ('PENDIENTE', 'CONCLUIDO')
END
IF @Accion <> 'VERIFICAR' AND @Ok IS NULL AND @EstatusNuevo <> 'BORRADOR'
BEGIN
IF @AnexarTodoDetalle = 1 AND @Ok IS NULL
BEGIN
EXEC spInvAnexarTodoDetalle @Empresa, @Modulo, @ID, @AnexoID, @CfgImpInc, @CfgMultiUnidades, @Ok OUTPUT,
@CfgPrecioMoneda = @CfgPrecioMoneda
IF @OK IS NULL AND @Modulo = 'VTAS' AND @AnexoID IS NOT NULL AND @MovTipo IN ('VTAS.P', 'VTAS.S')
IF @CfgPedidosReservar = 1 AND @SeguimientoMatriz = 0
IF @CfgPedidosReservarEsp = 0 OR EXISTS(SELECT * FROM EmpresaPedidosReservarEsp WHERE Empresa = @Empresa AND Modulo = @Modulo AND Mov = @Mov)
EXEC spAfectar 'VTAS', @AnexoID, 'RESERVARPARCIAL', 'SELECCION', @Usuario = @Usuario, @ok = @ok Output, @OkRef = @OkRef Output
END
EXEC spInvAfectar @ID, @Accion, @Base, @Empresa, @Modulo, @Mov, @MovID OUTPUT, @MovTipo, @MovMoneda, @MovTipoCambio, @FechaEmision, @FechaAfectacion, @FechaConclusion,
@Concepto, @Proyecto, @Usuario, @Autorizacion, @Referencia, @DocFuente, @Observaciones,
@Estatus, @EstatusNuevo, @FechaRegistro, @Ejercicio, @Periodo,
@Almacen, @AlmacenTipo, @AlmacenDestino, @AlmacenDestinoTipo, @VoltearAlmacen, @AlmacenEspecifico, @Largo, @Condicion, @Vencimiento, @Periodicidad, @EndosarA,
@ClienteProv, @EnviarA, @DescuentoGlobal, @SobrePrecio, @Agente, @AnticiposFacturados, @ServicioArticulo, @ServicioSerie, @FechaRequerida, @ZonaImpuesto,
@OrigenTipo, @Origen, @OrigenID, @OrigenMovTipo,
/*@CfgAutoConsig, */@CfgFormaCosteo, @CfgTipoCosteo, @CfgCosteoActividades, @CfgCosteoNivelSubCuenta, @CfgCosteoMultipleSimultaneo, @CfgPosiciones, @CfgExistenciaAlterna, @CfgExistenciaAlternaSerieLote, @CfgSeriesLotesMayoreo, @CfgSeriesLotesAutoCampo, @CfgSeriesLotesAutoOrden, @CfgCosteoSeries, @CfgCosteoLotes, @CfgValidarLotesCostoDif,
@CfgVentaSurtirDemas, @CfgCompraRecibirDemas, @CfgTransferirDemas, @CfgBackOrders, @CfgContX, @CfgContXGenerar, @CfgContXFacturasPendientes, @CfgEmbarcar, @CfgImpInc, @CfgVentaContratosArticulo, @CfgVentaContratosImpuesto,
@CfgVentaComisionesCobradas, @CfgAnticiposFacturados, @CfgMultiUnidades, @CfgMultiUnidadesNivel, @CfgCompraFactorDinamico, @CfgInvFactorDinamico, @CfgProdFactorDinamico, @CfgVentaFactorDinamico, @CfgCompraAutoCargos, @CfgVentaAutoBonif, @CfgVINAccesorioArt, @CfgVINCostoSumaAccesorios, @SeguimientoMatriz, @CobroIntegrado, @CobroIntegradoCxc, @CobroIntegradoParcial,  @CobrarPedido,
@AfectarDetalle, @AfectarMatando, @AfectarVtasMostrador, @FacturarVtasMostrador, @AfectarConsignacion, @AfectarAlmacenRenglon, @CfgVentaMultiAgente, @CfgVentaMultiAlmacen, @CfgVentaArtAlmacenEspecifico, @CfgTipoMerma, @CfgComisionBase, @CfgLimiteRenFacturas, @CfgVentaRedondeoDecimales, @CfgCompraCostosImpuestoIncluido,
@AfectarConsecutivo, @EsTransferencia, @Conexion, @SincroFinal, @Sucursal, @SucursalDestino, @SucursalOrigen,
@Utilizar, @UtilizarID, @UtilizarMov, @UtilizarSerie, @UtilizarMovTipo, @UtilizarMovID,
@Generar, @GenerarMov, @GenerarSerie, @GenerarAfectado, @GenerarCopia, @GenerarPoliza, @GenerarOP, @GenerarGasto, @FacturacionRapidaAgrupada,
@IDTransito OUTPUT, @IDGenerar OUTPUT, @GenerarMovID OUTPUT, @ContID OUTPUT,
@Ok OUTPUT, @OkRef OUTPUT,
@CfgPrecioMoneda = @CfgPrecioMoneda, @EstacionTrabajo = @Estacion 
IF @MovTipo = 'PROD.O' AND @Accion = 'AFECTAR' AND @CfgProdAutoCB <> 'NO' AND @Ok IS NULL
EXEC spProdAutoCB @CfgProdAutoCB, @Sucursal, @ID
IF @MovTipo IN ('VTAS.D', 'VTAS.DF')  AND @Accion = 'CANCELAR' AND @Ok IS NULL AND @CancelacionID IS NOT NULL
UPDATE Venta SET CancelacionID = NULL WHERE CancelacionID = @CancelacionID
IF @MovTipo IN ('VTAS.D')  AND @Accion = 'CANCELAR' AND @Ok IS NULL
DELETE FROM VentaDevolucion WHERE ID =  @ID
IF (@Utilizar = 0 OR @Generar = 0 AND @MovTipo IN( 'INV.OT', 'INV.OI', 'INV.SI', 'INV.TI', 'INV.EI'))
BEGIN
DECLARE C_FechaCaducidad CURSOR FOR
SELECT Articulo
FROM INVD
WHERE ID = @ID
GROUP BY Articulo
OPEN C_FechaCaducidad
FETCH NEXT FROM C_FechaCaducidad
INTO @ArticuloFC
WHILE @@FETCH_STATUS = 0
BEGIN
SELECT @FechaCaducidad = FechaCaducidad
FROM Tarima
WHERE Articulo = @ArticuloFC
AND Estatus = 'ALTA'
IF @FechaCaducidad IS NOT NULL
UPDATE INVD
SET FechaCaducidad = @FechaCaducidad
WHERE ID = @ID
AND Articulo = @ArticuloFC
FETCH NEXT FROM C_FechaCaducidad
INTO @ArticuloFC
END
CLOSE C_FechaCaducidad;
DEALLOCATE C_FechaCaducidad;
END
IF (@Utilizar = 1 OR @Generar = 1) AND @Ok IS NULL
BEGIN
SELECT @CrossDocking  = CrossDocking,
@Almacen       = Almacen,
@PosicionWMS   = PosicionWMS
FROM INV
WHERE ID = @ID
SELECT @EsCrossDocking       = EsCrossDocking,
@posicioncrossdocking = ISNULL(defposicioncrossdocking,'')
FROM ALM
WHERE Almacen = @Almacen
IF @Ok IS NULL AND @Accion <> 'CANCELAR' AND @CrossDocking <> 1 OR RTRIM(LTRIM(@EsCrossDocking)) = 'No'
SELECT @Ok = 80030, @OkRef = NULL
IF @CrossDocking = 1 AND RTRIM(LTRIM(@EsCrossDocking)) = 'No' AND @Modulo = 'INV' AND RTRIM(LTRIM(@MovTipo)) = 'INV.TMA'
BEGIN
DECLARE C_ActualizaTarimaPCD CURSOR FOR
SELECT Tarima
FROM INVD
WHERE ID = @IDGenerar
GROUP BY Articulo, Tarima
OPEN C_ActualizaTarimaPCD
FETCH NEXT FROM C_ActualizaTarimaPCD
INTO @Tarima
WHILE @@FETCH_STATUS = 0
BEGIN
IF @Tarima IS NOT NULL
UPDATE Tarima
SET Posicion = @posicioncrossdocking
WHERE Tarima = @Tarima
FETCH NEXT FROM C_ActualizaTarimaPCD
INTO @Tarima
END
CLOSE C_ActualizaTarimaPCD;
DEALLOCATE C_ActualizaTarimaPCD;
END
IF @CrossDocking = 1 AND RTRIM(LTRIM(@EsCrossDocking)) = 'Si' AND @Modulo = 'INV' AND RTRIM(LTRIM(@MovTipo)) = 'INV.TMA'
BEGIN
/* Concluye el Entarimado y genera la Solicitud de Acomodo en TMA */
EXEC spAfectar 'INV', @IDGenerar, 'AFECTAR', 'Todo', NULL, @Usuario, @EnSilencio = 1, @Estacion = @Estacion
/* Se obtiene el Mov y MovID para encontrar el Mov la Solicitud de Acomodo en TMA */
SELECT @OrigenWMS   = Mov,
@OrigenIDWMS = MovID
FROM INV
WHERE ID = @IDGenerar
/* Se obtiene el ID de la Solicitud de Acomodo */
SELECT @IDGenerarSATMA = ID FROM TMA WHERE ORIGEN = @OrigenWMS AND ORIGENID = @OrigenIDWMS
EXEC spMovPos  @Estacion, 'INV', @IDGenerar
SELECT @DID = MovPos.DID
FROM MovPos
LEFT OUTER JOIN MovPos MovPosLista ON MovPos.Estacion=MovPosLista.Estacion AND MovPos.Modulo=MovPosLista.Modulo AND MovPos.Tipo=MovPosLista.Tipo AND MovPos.Rama=MovPosLista.Clave
WHERE MovPos.Estacion = @Estacion AND MovPos.Modulo = 'INV' AND MovPos.Tipo = 'DESTINO' and MovPos.dmov = 'Solicitud Acomodo' AND MovPos.OESTATUS = 'CONCLUIDO'
UPDATE TMAD
SET PosicionDestino = @posicioncrossdocking
WHERE ID = @DID
/* Se comenta esta seccion de codigo ya que no se tiene definido montacargas y acomodador para cross docking
/* Afecta Solicitud de Acomodo por todo el pendiente */
EXEC @IDGenerarOATMA = spAfectar 'TMA', @IDGenerarSATMA, 'GENERAR', 'Pendiente', 'Orden Acomodo', @Usuario, @EnSilencio = 1, @Estacion = @Estacion
/* Se actualiza Montacargas y Acomodador */
UPDATE TMA SET Agente = 'C.DOCKING', Montacarga = 'C.DOCKING' WHERE ID = @IDGenerarOATMA
/* Afecta Orden de Acomodo */
EXEC spAfectar 'TMA', @IDGenerarOATMA, 'AFECTAR', 'Todo', NULL, @Usuario, @EnSilencio = 1, @Estacion = @Estacion
/* Afecta Orden de Acomodo por todo el pendiente y Genero Acomodo */
EXEC @IDGenerarATMA = spAfectar 'TMA', @IDGenerarOATMA, 'GENERAR', 'Pendiente', 'Acomodo', @Usuario, @EnSilencio = 1, @Estacion = @Estacion
/* Afecta y concluyo el Acomodo */
EXEC spAfectar 'TMA', @IDGenerarATMA, 'AFECTAR', 'Todo', NULL, @Usuario, @EnSilencio = 1, @Estacion = @Estacion
*/
END
END
END ELSE
IF @EstatusNuevo IN ('CONFIRMAR', 'BORRADOR') EXEC spMovCancelarSinAfectar @Modulo, @ID, @Ok OUTPUT, @EstatusNuevo = @EstatusNuevo
END ELSE
BEGIN
IF @Ok <> 80030
BEGIN
IF @Estatus IN ('SINAFECTAR','SINCRO','BORRADOR','CONFIRMAR') AND @Accion = 'CANCELAR' EXEC spMovCancelarSinAfectar @Modulo, @ID, @Ok OUTPUT ELSE
IF @Estatus = 'AFECTANDO' SELECT @Ok = 80020 ELSE
IF @Estatus = 'CONCLUIDO' SELECT @Ok = 80010
ELSE SELECT @Ok = ISNULL(@Ok, 60040)
END
END
IF @MovTipo = 'INV.EP' AND @EstatusNuevo = 'BORRADOR' AND @Ok IS NULL AND @Accion <> 'CANCELAR'
EXEC spInvEntradaProductoGenerarConsumoMaterial @Accion, @Empresa, @ID, @IDGenerar OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
IF @OrigenTipo = 'PLAN' AND @Estatus IN ('SINAFECTAR', 'CONFIRMAR', 'BORRADOR') AND @Ok IN (80030, NULL)
BEGIN
IF @AccionOriginal = 'CANCELAR'
UPDATE PlanArtOP
SET LiberacionModulo = NULL, LiberacionID = NULL, LiberacionMov = NULL, LiberacionMovID = NULL, Estado = 'Plan'
WHERE LiberacionModulo = @Modulo AND LiberacionID = @ID /*AND LiberacionMov = @Mov AND LiberacionMovID = @MovID*/
ELSE
IF @AccionOriginal = 'AFECTAR'
BEGIN
DELETE PlanArtOP
WHERE LiberacionModulo = @Modulo AND LiberacionID = @ID /*AND LiberacionMov = @Mov AND LiberacionMovID = @MovID*/
END
END
IF @MovTipo IN ('VTAS.C', 'VTAS.CS') AND @Accion = 'CANCELAR'
EXEC spEmbarqueMov @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @Estatus, @EstatusNuevo, @CfgEmbarcar, @Ok OUTPUT
IF @Accion = 'CANCELAR' AND @MovTipo IN ('VTAS.F','VTAS.FAR','VTAS.P') AND @CfgCancelarFacturaReservarPedido = 1 AND @Ok IS NULL
SELECT @VolverAfectar = 4
IF @Accion <> 'CANCELAR' AND @MovTipo = 'VTAS.F' AND @CfgFacturasPendientes = 1 AND @EstatusNuevo = 'PENDIENTE' AND @Ok IS NULL
IF NOT EXISTS (SELECT * FROM VentaD d, Art a WHERE d.Articulo = a.Articulo AND d.ID = @ID AND a.Tipo NOT IN ('JUEGO', 'SERVICIO') AND (ISNULL(ROUND(d.CantidadPendiente, 4), 0.0) <> 0.0 OR ISNULL(ROUND(d.CantidadOrdenada, 4), 0.0) <> 0.0))
SELECT @VolverAfectar = 1
IF @Estatus = 'SINAFECTAR' AND @Accion <> 'CANCELAR' AND @MovTipo IN ('VTAS.P', 'VTAS.S', 'INV.SOL','INV.OT', 'INV.OI','INV.SM') AND @CfgBackOrders = 1 AND @CfgBackOrdersNivel = 'MOVIMIENTO' AND @CfgAutoAsignarBackOrders = 1 AND @EstatusNuevo = 'PENDIENTE' AND @Ok IS NULL AND @OrigenMovTipo IS NULL
IF EXISTS (SELECT * FROM VentaD d, Art a WHERE d.Articulo = a.Articulo AND d.ID = @ID AND a.Tipo NOT IN ('JUEGO', 'SERVICIO') AND ISNULL(ROUND(d.CantidadPendiente, 4), 0.0) <> 0.0)
SELECT @VolverAfectar = 2
IF @Accion = 'SINCRO' AND @Ok = 80060
BEGIN
SELECT @Ok = NULL, @OkRef = NULL
EXEC spSucursalEnLinea @SucursalDestino, @EnLinea OUTPUT
IF @EnLinea = 1 EXEC spSincroFinalModulo @Modulo, @ID, @Ok OUTPUT, @OkRef OUTPUT
END
/* Aqui estaba antes la generacion del transito */
IF @MovTipo = 'INV.IF' AND @Accion = 'AFECTAR' AND @Ok IS NULL
UPDATE Inv SET Conteo = 2 WHERE ID = @ID AND Conteo IS NULL
IF @AccionEspecial = 'TRANSITO' AND @Ok IS NULL
SELECT @Ok = 80030, @OkRef = 'Movimiento: '+RTRIM(@Mov)+ ' ' +LTRIM(Convert(varchar, @MovID))
IF @Ok IS NOT NULL AND @OkRef IS NULL
BEGIN
IF @Ok = 80030
BEGIN
IF @Utilizar = 1 SELECT @OkRef = 'Movimiento: '+RTRIM(@Mov)        + ' ' +LTRIM(Convert(varchar, @MovID))
IF @Generar  = 1 SELECT @OkRef = 'Movimiento: '+RTRIM(@GenerarMov) + ' ' +LTRIM(Convert(varchar, @GenerarMovID))
END
ELSE
SELECT @OkRef = 'Movimiento: '+RTRIM(@Mov)+' '+LTRIM(Convert(varchar, @MovID)), @IDGenerar = NULL
END
RETURN
END

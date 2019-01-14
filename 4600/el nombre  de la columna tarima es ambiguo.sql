CREATE PROCEDURE spInvInventarioFisico
@Sucursal			int,
@ID				int,
@Empresa			char(5),
@Almacen			char(10),
@IDGenerar			int,
@Base			char(20),
@CfgSeriesLotesMayoreo	bit,
@Estatus			char(15),
@Ok 				int 		OUTPUT,
@OkRef 			varchar(255)	OUTPUT,
@Modulo			varchar(5) = 'INV',
@Proveedor			varchar(10) = NULL
WITH ENCRYPTION
AS BEGIN
DECLARE
@ZonaImpuesto		varchar(30),
@Impuesto1			float,
@Impuesto2			float,
@Impuesto3			money,
@SucursalAlmacen		int,
@RegistrarPrecios		bit,
@MovAlmacen			char(10),
@Tarima			varchar(20),
@Moneda			char(10),
@TipoCambio			float,
@Articulo 			char(20),
@ArtTipo			char(20),
@Renglon			float,
@RenglonID			int,
@RenglonTipo		char(1),
@SubCuenta			varchar(50),
@Unidad			varchar(50),
@Cantidad			float,
@CantidadABS		float,
@CantidadA			float,
@Existencia			float,
@Factor			float,
@FormaCosteo		varchar(20),
@TipoCosteo			varchar(20),
@Costo			float,
@Precio			float,
@Decimales			int,
@CfgMultiUnidades		bit,
@CfgMultiUnidadesNivel	char(20),
@SeriesLotesAutoOrden	varchar(20),
@LotesFijos			bit,
@Lote				varchar(50),
@Contacto			varchar(10),
@EnviarA			int,
@FechaEmision		datetime,
@Mov				varchar(20),
@ContUso				varchar(20), 
@WMSSugerirEntarimado	bit, 
@PosicionActual varchar(10),
@PosicionReal   varchar(10),
@WMS                   BIT,
@Departamento          VARCHAR(50),
@Familia               VARCHAR(50),
@SubFamilia            VARCHAR(50),
@UEN                   INT,
@UENTipo               VARCHAR(50),
@InvFisico             INT,
@ArticuloBlanco        VARCHAR(20),
@TarimaBlanco          VARCHAR(20),
@MonedaBlanco          VARCHAR(10),
@Movx                  varchar(20)
SELECT @ArticuloBlanco = Articulo, @TarimaBlanco = Tarima FROM WMSInventarioFisicoArtBlanco
SELECT @MonedaBlanco = MonedaCosto FROM Art WHERE Articulo = @ArticuloBlanco
SELECT @WMS = ISNULL(WMS, 0) FROM Alm WHERE Almacen = @Almacen
SELECT @Renglon = 0, @RenglonID = 0, @Precio = NULL, @Contacto = NULL, @EnviarA = NULL, @FechaEmision = NULL
SELECT @SeriesLotesAutoOrden    = UPPER(SeriesLotesAutoOrden),
@FormaCosteo		  = UPPER(FormaCosteo),
@TipoCosteo		  = ISNULL(NULLIF(RTRIM(UPPER(TipoCosteo)), ''), 'PROMEDIO'),
@WMSSugerirEntarimado = WMSSugerirEntarimado
FROM EmpresaCfg
WHERE Empresa = @Empresa
SELECT @CfgMultiUnidades = MultiUnidades,
@CfgMultiUnidadesNivel = ISNULL(UPPER(NivelFactorMultiUnidad), 'UNIDAD'),
@RegistrarPrecios = InvRegistrarPrecios
FROM EmpresaCfg2
WHERE Empresa = @Empresa
SELECT @Moneda = Moneda, @TipoCambio = TipoCambio FROM Inv WHERE ID = @IDGenerar
SELECT @SucursalAlmacen = Sucursal FROM Alm WHERE Almacen = @Almacen
IF @WMS = 1
BEGIN
SELECT @Base = 'TODO'
IF NOT EXISTS(SELECT * FROM SaldoU WHERE Sucursal = @Sucursal AND Empresa = @Empresa AND Rama = 'INV' AND Grupo = @Almacen AND Cuenta = @ArticuloBlanco AND SubCuenta = '' AND SubGrupo = @TarimaBlanco)
INSERT INTO SaldoU(
Sucursal,  Empresa, Rama,   Moneda,        Grupo,    SubGrupo,      Cuenta,         SubCuenta, Saldo, SaldoU, PorConciliar, PorConciliarU, UltimoCambio)
SELECT @Sucursal, @Empresa, 'INV', @MonedaBlanco, @Almacen, @TarimaBlanco, @ArticuloBlanco, '',        0,     0,      0,            0,             GETDATE()
END
IF @WMS = 1
EXEC spWMSInvInventarioFisicoSerieLote @ID, @Base, @Modulo, @Almacen, @IDGenerar, @Ok OUTPUT, @OkRef OUTPUT
IF @Ok IS NOT NULL RETURN
IF @Modulo = 'COMS'
SELECT @Mov = Mov, @ZonaImpuesto = ZonaImpuesto, @Contacto = Proveedor, @FechaEmision = FechaEmision
FROM Compra
WHERE ID = @IDGenerar
ELSE BEGIN
SELECT @Mov = Mov
FROM Inv
WHERE ID = @IDGenerar
CREATE TABLE #ExistenciaFisica (Articulo varchar(20) COLLATE Database_Default NOT NULL,  SubCuenta varchar(50) COLLATE Database_Default NULL,  Cantidad float NULL,  CantidadA float NULL, Costo float NULL, ArtTipo 	varchar(20)  COLLATE Database_Default NULL, Unidad varchar(50)  COLLATE Database_Default NULL, Almacen varchar(10) COLLATE Database_Default  NULL, Tarima varchar(20)  COLLATE Database_Default NULL, ContUso varchar(20) COLLATE Database_Default NULL, PosicionActual varchar(10) COLLATE Database_Default NULL,PosicionReal varchar(10) COLLATE Database_Default NULL) 
INSERT #ExistenciaFisica (
Articulo,   SubCuenta,   Almacen,   /*Unidad, */   Cantidad,                                           CantidadA,                                           ArtTipo,                   Costo,                         ContUso,             PosicionActual,               PosicionReal,             Tarima) 
SELECT d.Articulo, d.SubCuenta, d.Almacen, /*d.Unidad, */ SUM(ISNULL(d.Cantidad, 0.0)*ISNULL(d.Factor, 1.0)), SUM(ISNULL(d.CantidadA, 0.0)*ISNULL(d.Factor, 1.0)), NULLIF(RTRIM(a.Tipo), ''), ac.CostoPromedio/*, d.Factor*/,NULLIF(d.ContUso,''),ISNULL(d.PosicionActual,''), ISNULL(d.PosicionReal,''), d.Tarima
FROM InvD d, Art a, ArtCostoSucursal ac
WHERE d.ID = @ID
AND d.Articulo = a.Articulo
AND UPPER(a.Tipo) NOT IN ('JUEGO', 'SERVICIO')
AND ac.Articulo = a.Articulo AND ac.Empresa = @Empresa AND ac.Sucursal = @Sucursal
GROUP BY d.Articulo, d.SubCuenta, a.Tipo, /*d.Unidad, */d.Almacen, ac.CostoPromedio/*, d.Factor*/,NULLIF(d.ContUso,''),ISNULL(d.PosicionActual,''), ISNULL(d.PosicionReal,''), d.Tarima 
ORDER BY d.Articulo, d.SubCuenta, a.Tipo, /*d.Unidad, */d.Almacen, ac.CostoPromedio/*, d.Factor*/
INSERT #ExistenciaFisica (
Articulo,   SubCuenta,   Almacen,   Cantidad,                                           CantidadA,                                           ArtTipo,                   Costo,   ContUso,             PosicionActual,               PosicionReal,             Tarima) 
SELECT d.Articulo, d.SubCuenta, d.Almacen, SUM(ISNULL(d.Cantidad, 0.0)*ISNULL(d.Factor, 1.0)), SUM(ISNULL(d.CantidadA, 0.0)*ISNULL(d.Factor, 1.0)), NULLIF(RTRIM(a.Tipo), ''), NULL,    NULLIF(d.ContUso,''),ISNULL(d.PosicionActual,''), ISNULL(d.PosicionReal,''), Tarima
FROM InvD d, Art a
WHERE d.ID = @ID
AND d.Articulo = a.Articulo
AND UPPER(a.Tipo) NOT IN ('JUEGO', 'SERVICIO')
AND a.Articulo NOT IN(SELECT Articulo FROM #ExistenciaFisica)
GROUP BY d.Articulo, d.SubCuenta, a.Tipo, d.Almacen, NULLIF(d.ContUso,''),ISNULL(d.PosicionActual,''), ISNULL(d.PosicionReal,''), Tarima 
ORDER BY d.Articulo, d.SubCuenta, a.Tipo, d.Almacen
END
CREATE INDEX idx_ArtExistenciaFisica on #ExistenciaFisica(Articulo,Subcuenta,Almacen)  
IF @Modulo = 'COMS'
DECLARE crExistencia CURSOR FOR
SELECT e.Articulo, NULLIF(RTRIM(e.SubCuenta), ''), ISNULL(e.Disponible, 0.0), NULLIF(RTRIM(Art.Tipo), ''), Art.Unidad, e.Almacen, NULLIF(RTRIM(e.Tarima), ''), Art.ContUso 
FROM ArtSubDisponibleTarima e
JOIN Art ON Art.Articulo = e.Articulo
WHERE e.Empresa  = @Empresa
AND e.Almacen  = ISNULL(@Almacen, e.Almacen)
AND e.Disponible > 0
AND Art.Proveedor = @Proveedor OR EXISTS(SELECT * FROM ArtProv ap WHERE ap.Articulo = e.Articulo AND ap.SubCuenta = ISNULL(RTRIM(e.SubCuenta), '') AND ap.Proveedor = @Proveedor)
ELSE
IF @Base = 'DISPONIBLE'
DECLARE crExistencia CURSOR FOR
SELECT e.Articulo, NULLIF(RTRIM(e.SubCuenta), ''), ISNULL(e.Disponible, 0.0), NULLIF(RTRIM(Art.Tipo), ''), Art.Unidad, e.Almacen, NULLIF(RTRIM(e.Tarima), ''), Art.ContUso 
FROM ArtSubDisponibleTarima e, Art
WHERE e.Articulo = Art.Articulo
AND e.Empresa  = @Empresa
AND e.Almacen  = ISNULL(@Almacen, e.Almacen)
AND e.Disponible > 0
ELSE
IF @Base = 'TODO'
DECLARE crExistencia CURSOR FOR
SELECT e.Articulo, NULLIF(RTRIM(e.SubCuenta), ''), ISNULL(e.Existencia, 0.0), NULLIF(RTRIM(Art.Tipo), ''), Art.Unidad, e.Almacen, NULLIF(RTRIM(e.Tarima), ''), Art.ContUso 
FROM ArtSubExistenciaConsigAFTarima e, Art
WHERE e.Articulo = Art.Articulo
AND e.Empresa  = @Empresa
AND e.Almacen  = ISNULL(@Almacen, e.Almacen)
AND e.Existencia > 0
AND UPPER(Art.Tipo) NOT IN ('JUEGO', 'SERVICIO')
ELSE
DECLARE crExistencia CURSOR FOR
SELECT e.Articulo, NULLIF(RTRIM(e.SubCuenta), ''), ISNULL(e.Existencia, 0.0), NULLIF(RTRIM(Art.Tipo), ''), Art.Unidad, e.Almacen, NULLIF(RTRIM(e.Tarima), ''), Art.ContUso 
FROM ArtSubExistenciaConsigAFTarima e, Art, InvD d
WHERE e.Articulo = Art.Articulo
AND e.Empresa  = @Empresa
AND e.Almacen  = ISNULL(@Almacen, e.Almacen)
AND e.Existencia > 0
AND d.ID = @ID AND d.Articulo = e.Articulo AND ISNULL(d.SubCuenta, '') = ISNULL(e.SubCuenta, '')
AND UPPER(Art.Tipo) NOT IN ('JUEGO', 'SERVICIO')
OPEN crExistencia
FETCH NEXT FROM crExistencia INTO @Articulo, @SubCuenta, @Existencia, @ArtTipo, @Unidad, @MovAlmacen, @Tarima, @ContUso
IF @@ERROR <> 0 SELECT @Ok = 1
WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
BEGIN
IF @@FETCH_STATUS <> -2
BEGIN
SELECT @PosicionActual = NULL, @PosicionReal = NULL
SELECT @PosicionActual = Posicion, @PosicionReal = Posicion FROM Tarima WHERE Tarima = @Tarima
UPDATE #ExistenciaFisica
SET Cantidad  = Cantidad  - @Existencia,
CantidadA = CantidadA - @Existencia
WHERE Articulo  = @Articulo
AND SubCuenta = @SubCuenta
AND Almacen   = @Almacen
AND CASE WHEN @WMSSugerirEntarimado = 1 THEN Tarima ELSE NULLIF(RTRIM(Tarima), '') END = @Tarima
AND ContUso = @ContUso
IF @@ROWCOUNT = 0
INSERT #ExistenciaFisica (Articulo,  SubCuenta,  Cantidad,     CantidadA,    Costo, ArtTipo, /*Unidad, */Almacen,       Tarima,  ContUso)
VALUES (@Articulo, @SubCuenta, -@Existencia, -@Existencia, NULL,  @ArtTipo, /*@Unidad, */@MovAlmacen, @Tarima, @ContUso)
IF @@ERROR <> 0 SELECT @Ok = 1
END 
FETCH NEXT FROM crExistencia INTO @Articulo, @SubCuenta, @Existencia, @ArtTipo, @Unidad, @MovAlmacen, @Tarima, @ContUso
IF @@ERROR <> 0 SELECT @Ok = 1
END 
CLOSE crExistencia
DEALLOCATE crExistencia
IF @Base <> 'DISPONIBLE' AND @Modulo = 'INV'
INSERT #ExistenciaFisica
(Articulo,  SubCuenta,   Cantidad,   CantidadA,  Costo, ArtTipo, /*Unidad, */Almacen,  Tarima,   ContUso,PosicionActual,PosicionReal)
SELECT d.Articulo, d.SubCuenta, d.Cantidad, d.Cantidad, NULL,  a.Tipo,              @Almacen, d.Tarima, a.ContUso,d.PosicionActual,d.PosicionReal
FROM InvD d, Art a
WHERE d.ID = @ID AND d.Articulo = a.Articulo AND d.Articulo NOT IN (SELECT Articulo FROM #ExistenciaFisica)
EXEC spWMSInvInventarioFisico @ID, @Base, @Modulo, @Almacen, @IDGenerar
DECLARE crAjuste CURSOR FOR
SELECT Articulo, SubCuenta, ISNULL(Cantidad, 0.0), ISNULL(CantidadA, 0.0), ISNULL(Costo, 0.0), /*Unidad, */Almacen, Tarima, ArtTipo/*, ISNULL(Factor, 1.0)*/, ContUso, PosicionActual, PosicionReal
FROM #ExistenciaFisica
OPEN crAjuste
FETCH NEXT FROM crAjuste INTO @Articulo, @SubCuenta, @Cantidad, @CantidadA, @Costo, /*@Unidad, */@MovAlmacen, @Tarima, @ArtTipo/*, @Factor*/,@ContUso, @PosicionActual, @PosicionReal
IF @@ERROR <> 0 SELECT @Ok = 1
WHILE @@FETCH_STATUS <> -1 AND @Ok IS NULL
BEGIN
SELECT @Unidad = Unidad, @LotesFijos = ISNULL(LotesFijos, 0) FROM Art WHERE Articulo = @Articulo
IF @CfgMultiUnidadesNivel = 'ARTICULO'
EXEC xpArtUnidadFactor @Articulo, @SubCuenta, @Unidad, @Factor OUTPUT, @Decimales OUTPUT, @Ok OUTPUT
ELSE
EXEC xpUnidadFactor @Articulo, @SubCuenta, @Unidad, @Factor OUTPUT, @Decimales OUTPUT
SELECT @Factor = ISNULL(NULLIF(@Factor, 0), 1)
IF @FormaCosteo = 'ARTICULO' SELECT @TipoCosteo = TipoCosteo FROM Art WHERE Articulo = @Articulo
EXEC spVerCosto @Sucursal, @Empresa, NULL, @Articulo, @SubCuenta, @Unidad, @TipoCosteo, @Moneda, @TipoCambio, @Costo OUTPUT, 0
IF @Estatus = 'PENDIENTE' SELECT @Cantidad = @CantidadA
SELECT @CantidadABS = ISNULL(@Cantidad, 0.0)
IF @Base = 'DISPONIBLE' SELECT @CantidadABS = -@CantidadABS
IF @@FETCH_STATUS <> -2 AND ISNULL(@CantidadABS, 0.0) <> 0.0
BEGIN
SELECT @Renglon   = @Renglon + 2048,
@RenglonID = @RenglonID + 1,
@Lote      = NULL
IF @CantidadABS < 0.0 SELECT @Costo = NULL
EXEC spRenglonTipo @ArtTipo, @SubCuenta, @RenglonTipo OUTPUT
IF @RegistrarPrecios = 1
EXEC spPrecioEsp '(Precio Lista)', @Moneda, @Articulo, @SubCuenta, @Precio OUTPUT
IF @LotesFijos = 1
BEGIN
IF @SeriesLotesAutoOrden = 'ASCENDENTE'
SELECT @Lote = (SELECT TOP 1 Lote FROM ArtLoteFijo WHERE Articulo = @Articulo ORDER BY Lote DESC)
ELSE
SELECT @Lote = (SELECT TOP 1 Lote FROM ArtLoteFijo WHERE Articulo = @Articulo ORDER BY Lote)
SELECT @Lote = NULLIF(RTRIM(@Lote), '')
IF @Lote IS NOT NULL
SELECT @Costo = MIN(CostoPromedio)*@Factor FROM SerieLote WHERE Empresa = @Empresa AND Articulo = @Articulo AND SubCuenta = ISNULL(@SubCuenta, '') AND SerieLote = @Lote AND Almacen = @MovAlmacen AND Tarima = @Tarima
END
IF @Modulo = 'COMS'
BEGIN
SELECT @Impuesto1 = Impuesto1, @Impuesto2 = Impuesto2, @Impuesto3 = Impuesto3
FROM Art
WHERE Articulo = @Articulo
EXEC spZonaImp @ZonaImpuesto, @Impuesto1 OUTPUT
EXEC spZonaImp @ZonaImpuesto, @Impuesto2 OUTPUT
EXEC spZonaImp @ZonaImpuesto, @Impuesto3 OUTPUT
EXEC spTipoImpuesto @Modulo, @IDGenerar, @Mov, @FechaEmision, @Empresa, @Sucursal, @Contacto, @EnviarA, @Articulo = @Articulo, @EnSilencio = 1, @Impuesto1 = @Impuesto1 OUTPUT, @Impuesto2 = @Impuesto2 OUTPUT, @Impuesto3 = @Impuesto3 OUTPUT
INSERT INTO CompraD (Sucursal,  ID,         Renglon,  RenglonSub, RenglonID,  RenglonTipo,  Articulo,  SubCuenta,  Cantidad,             CantidadInventario, Unidad,  Costo,  Almacen,     Tarima,  Impuesto1,  Impuesto2,  Impuesto3)
VALUES (@Sucursal, @IDGenerar, @Renglon, 0,          @RenglonID, @RenglonTipo, @Articulo, @SubCuenta, @CantidadABS/@Factor, @CantidadABS,       @Unidad, @Costo, @MovAlmacen, @Tarima, @Impuesto1, @Impuesto2, @Impuesto3)
END ELSE
INSERT INTO InvD (Sucursal,  ID,         Renglon,  RenglonSub, RenglonID,  RenglonTipo,  Articulo,  SubCuenta,  Cantidad,             CantidadInventario, Unidad,  Costo,  Precio,  Almacen,     Tarima,  ContUso, PosicionActual, PosicionReal)
VALUES (@Sucursal, @IDGenerar, @Renglon, 0,          @RenglonID, @RenglonTipo, @Articulo, @SubCuenta, @CantidadABS/@Factor, @CantidadABS,       @Unidad, @Costo, @Precio, @MovAlmacen, @Tarima, @ContUso, @PosicionActual, @PosicionReal)
IF @@ERROR <> 0 SELECT @Ok = 1
IF @LotesFijos = 1 AND @Lote IS NOT NULL AND @CantidadABS > 0
INSERT SerieLoteMov (Empresa,  Sucursal,  Modulo,  ID,         RenglonID,  Articulo,  SubCuenta,              SerieLote, Cantidad)
VALUES (@Empresa, @Sucursal, @Modulo, @IDGenerar, @RenglonID, @Articulo, ISNULL(@SubCuenta, ''), @Lote,     @CantidadABS)
ELSE
IF UPPER(@ArtTipo) IN ('SERIE', 'LOTE', 'VIN', 'PARTIDA') AND @Cantidad < 0
BEGIN
/*
IF EXISTS(SELECT * FROM SerieLoteMov WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID AND Articulo = @Articulo AND SubCuenta = ISNULL(@SubCuenta, '') AND RenglonID = @RenglonID)
BEGIN
/*IF @Cantidad > 0
INSERT INTO SerieLoteMov (Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad)
SELECT @Empresa, 'INV', @IDGenerar, @RenglonID, @Articulo, ISNULL(@SubCuenta, ''), SerieLote, Cantidad
FROM SerieLoteMov
WHERE Empresa = @Empresa AND Modulo = 'INV' AND ID = @ID AND Articulo = @Articulo AND SubCuenta = ISNULL(@SubCuenta, '') AND RenglonID = @RenglonID
AND SerieLote NOT IN (SELECT SerieLote FROM SerieLote WHERE Empresa = @Empresa AND Modulo = 'INV' AND Articulo = @Articulo AND SubCuenta = ISNULL(@SubCuenta, '') AND Almacen = @Almacen AND (ISNULL(Existencia, 0) > 0 OR ISNULL(ExistenciaActivoFijo, 0) > 0))
ELSE
INSERT INTO SerieLoteMov (Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad)
SELECT @Empresa, 'INV', @IDGenerar, @RenglonID, @Articulo, ISNULL(@SubCuenta, ''), SerieLote, Existencia
FROM SerieLote
WHERE Sucursal = @Sucursal
AND Empresa = @Empresa
AND Articulo = @Articulo
AND SubCuenta = ISNULL(@SubCuenta, '')
AND Almacen = @Almacen
AND Existencia > 0
AND SerieLote NOT IN (SELECT SerieLote FROM SerieLoteMov WHERE Empresa = @Empresa AND Modulo = 'INV' AND ID = @ID AND Articulo = @Articulo AND SubCuenta = ISNULL(@SubCuenta, ''))
*/
INSERT INTO SerieLoteMov (Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad)
SELECT @Empresa, @Modulo, @IDGenerar, @RenglonID, @Articulo, ISNULL(@SubCuenta, ''), sl.SerieLote, ABS(ISNULL(sl.Existencia, 0.0)-ISNULL(slm.Cantidad, 0.0))
FROM SerieLote sl
LEFT OUTER JOIN SerieLoteMov slm ON slm.Empresa = @Empresa AND slm.Modulo = @Modulo AND slm.ID = @ID AND slm.Articulo = @Articulo AND slm.SubCuenta = ISNULL(@SubCuenta, '') AND slm.SerieLote = sl.SerieLote
WHERE sl.Sucursal = @Sucursal
AND sl.Empresa = @Empresa
AND sl.Articulo = @Articulo
AND sl.SubCuenta = ISNULL(@SubCuenta, '')
AND sl.Almacen = @Almacen
AND sl.Tarima = @Tarima
AND ISNULL(sl.Existencia, 0.0) <> ISNULL(slm.Cantidad, 0.0)
END
*/
INSERT INTO SerieLoteMov (Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad, Tarima) 
SELECT @Empresa, @Modulo, @IDGenerar, @RenglonID, @Articulo, ISNULL(@SubCuenta, ''), sl.SerieLote, CASE WHEN UPPER(@ArtTipo) = 'LOTE' THEN ABS(ISNULL(sl.Existencia, 0.0)-ISNULL(slm.Cantidad, 0.0)) ELSE ISNULL(@Existencia, 0.0) END, @Tarima 
FROM SerieLote sl
LEFT OUTER JOIN SerieLoteMov slm ON slm.Empresa = @Empresa AND slm.Modulo = @Modulo AND slm.ID = @ID AND slm.Articulo = @Articulo AND slm.SubCuenta = ISNULL(@SubCuenta, '') AND slm.SerieLote = sl.SerieLote
WHERE sl.Sucursal = @Sucursal
AND sl.Empresa = @Empresa
AND sl.Articulo = @Articulo
AND sl.SubCuenta = ISNULL(@SubCuenta, '')
AND sl.Almacen = @Almacen
AND sl.Tarima = @Tarima
AND ISNULL(sl.Existencia, 0.0) <> ISNULL(slm.Cantidad, 0.0)
END
END
FETCH NEXT FROM crAjuste INTO @Articulo, @SubCuenta, @Cantidad, @CantidadA, @Costo, /*@Unidad, */@MovAlmacen, @Tarima, @ArtTipo/*, @Factor*/,@ContUso, @PosicionActual, @PosicionReal
IF @@ERROR <> 0 SELECT @Ok = 1
END
CLOSE crAjuste
DEALLOCATE crAjuste
IF @WMS = 1
EXEC spWMSInventarioFisicoCambioArticulo @Sucursal, @ID, @Empresa, @Almacen, @IDGenerar, @Base, @CfgSeriesLotesMayoreo, @Estatus, @Ok OUTPUT, @OkRef OUTPUT
IF @Modulo = 'COMS'
BEGIN
UPDATE Compra SET RenglonID = @RenglonID + 1 WHERE ID = @IDGenerar
DELETE CompraD WHERE ID = @IDGenerar AND NULLIF(ROUND(Cantidad, 10), 0) IS NULL
END ELSE
BEGIN
UPDATE Inv SET RenglonID = @RenglonID + 1 WHERE ID = @IDGenerar
DELETE InvD WHERE ID = @IDGenerar AND NULLIF(ROUND(Cantidad, 10), 0) IS NULL
END
IF @@ERROR <> 0 SELECT @Ok = 1
IF NOT EXISTS(SELECT * FROM InvD WHERE ID = @IDGenerar)
BEGIN
IF @Modulo = 'COMS'
DELETE Compra WHERE ID = @IDGenerar
ELSE
DELETE Inv WHERE ID = @IDGenerar
SELECT @Ok = 80070
END
EXEC xpInvInventarioFisico @Sucursal, @ID, @Empresa, @Almacen, @IDGenerar, @Base, @CfgSeriesLotesMayoreo, @Estatus, @Ok OUTPUT, @OkRef OUTPUT, @Modulo, @Proveedor
RETURN
END
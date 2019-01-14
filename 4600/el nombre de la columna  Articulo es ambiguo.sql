CREATE PROCEDURE spPreparaSurtido
@Estacion	int,
@Empresa	char(5),
@EnSilencio		bit = 0
AS
BEGIN
SET NOCOUNT ON
DECLARE @Modulo				varchar(5),
@ID					int,
@Articulo			varchar(20),
@Almacen			varchar(10),
@Cantidad		    float,
@Tarima				varchar(20),
@Disponible			float,
@Posicion			varchar(10),
@Zona				varchar(50),
@CantidadPedida		float,
@CantidadDisponible float,
@Ok					int,
@OkRef				varchar(255),
@Desde				int,
@Hasta				int,
@COUNT				int,
@ControlArticulo	varchar(20),
@Referencia			varchar(50),
@Unidad				varchar(50), 
@CantidadUnidad		float, 
@Factor				float, 
@SucursalDestino	int,
@IDAux				int,
@IDAuxAnt			int,
@ModuloAux			varchar(5),
@ModuloAuxAnt		varchar(5),
@ArticuloAux		varchar(20),
@ArticuloAuxAnt	    varchar(20),
@AlmacenAux		    varchar(20),
@AlmacenAuxAnt		varchar(20),
@CantidadFaltante	float,
@CantidadA			float,
@UnidadAux			varchar(50),
@UnidadAuxAnt		varchar(50),
@Disponibles		float,
@Utilizadas		    float,
@PosicionDestino	varchar(20)
CREATE TABLE #CualesID (ID int NULL)
CREATE TABLE #Anden (Anden int NULL)
CREATE TABLE #TarimaAux
(
Tarima			varchar(20) COLLATE Database_Default NOT NULL,
Cantidad		float  NOT NULL,
CantidadA		float  NULL,
)
CREATE INDEX tarima
ON #tarimaaux(tarima)
CREATE TABLE #Explocion
(
modulo             VARCHAR(5) COLLATE database_default NOT NULL,
moduloid           INT NOT NULL,
referencia         VARCHAR(50) COLLATE database_default NULL,
sucursalfiltro     INT NULL,
Cantidad			float	NULL,
Pocicion			varchar(10) COLLATE Database_Default NULL,
Articulo			varchar(20) COLLATE Database_Default NULL,
Almacen			varchar(10) COLLATE Database_Default NULL,
Tarima				varchar(20) COLLATE Database_Default NULL,
Zona				varchar(30) COLLATE Database_Default NULL,
Tipo				int		NULL,
Unidad				varchar(50) COLLATE Database_Default NULL,  
CantidadUnidad		float	NULL,  
Factor				float	NULL  
)
SELECT @Ok = NULL
DELETE WMSLista WHERE Estacion = @Estacion
DELETE WMSSurtidoPendiente WHERE Estacion = @Estacion
SELECT  TOP 1 @Desde = ID FROM WMSModuloTarima ORDER BY ID DESC
DECLARE crInicial CURSOR LOCAL STATIC FOR
SELECT Modulo, ID FROM ListaModuloID WHERE Estacion = @Estacion ORDER BY Modulo, ID
OPEN crInicial
FETCH NEXT FROM crInicial INTO @Modulo, @ID
WHILE @@FETCH_STATUS = 0
BEGIN
DELETE WMSModuloTarima WHERE Modulo = @Modulo AND IDModulo = @ID 
IF @Modulo = 'VTAS'
INSERT WMSModuloTarima (IDModulo, Modulo,  Renglon,    RenglonSub,    Cantidad,             PosicionDestino, Articulo, Almacen, Utilizar, AlmacenDestino, Unidad, CantidadUnidad)
SELECT                  v.ID,     @Modulo, vd.Renglon, vd.RenglonSub,  CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN CASE WHEN (ISNULL( u.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) <0  THEN (ISNULL( u.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) WHEN (ISNULL( u.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) = 0 THEN ISNULL(vd.Cantidad,0) ELSE (ISNULL( u.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) END ELSE CASE WHEN (ISNULL( au.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) < 0  THEN (ISNULL( au.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) WHEN (ISNULL( au.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) = 0 THEN (ISNULL( au.Factor, 1) * ISNULL(vd.Cantidad,0)) ELSE (ISNULL( au.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) END END, ISNULL(v.PosicionWMS, a.DefPosicionSurtido), vd.Articulo, vd.Almacen, 1, vd.Almacen, vd.Unidad, vd.Cantidad 
FROM Venta v
JOIN VentaD vd ON v.ID = vd.ID
JOIN Cte c ON v.Cliente = c.Cliente
LEFT JOIN CteEnviarA ca ON c.Cliente = ca.Cliente AND vd.EnviarA = ca.ID
JOIN Alm a ON vd.Almacen = a.Almacen
LEFT OUTER JOIN WMSModuloTarima w ON w.IDModulo = v.ID AND w.Modulo = @Modulo AND w.IDTMA IS NOT NULL AND Utilizar = 1
LEFT OUTER JOIN TMA t ON t.ID = w.IDTMA AND t.Estatus <> 'CANCELADO'
LEFT OUTER JOIN EmpresaCfg2 g ON v.Empresa = g.Empresa
LEFT OUTER JOIN Unidad u ON vd.Unidad = u.Unidad
LEFT OUTER JOIN ArtUnidad au ON vd.Articulo = au.Articulo AND vd.Unidad = au.Unidad
WHERE v.ID = @ID
AND v.Mov IN(SELECT Movimiento FROM WMSModuloMovimiento WHERE Modulo = @Modulo)
AND v.Estatus = (SELECT Estatus FROM WMSModuloMovimiento WHERE Modulo = @Modulo AND Movimiento = v.Mov)
AND NULLIF(vd.Tarima,'') IS NULL
AND Isnull(vd.CantidadPendiente, '') > 0
GROUP BY v.ID, vd.Renglon, vd.RenglonSub, ISNULL(vd.CantidadPendiente,0) , ISNULL(v.PosicionWMS, a.DefPosicionSurtido), vd.Articulo, vd.Almacen, vd.Cantidad, g.NivelFactorMultiUnidad, ISNULL( u.Factor, 1), ISNULL( au.Factor, 1), vd.Unidad 
IF @Modulo = 'COMS'
INSERT WMSModuloTarima (IDModulo, Modulo,  Renglon,    RenglonSub,    Cantidad,             PosicionDestino, Articulo, Almacen, Utilizar, AlmacenDestino, Unidad, CantidadUnidad)
SELECT                  v.ID,     @Modulo, vd.Renglon, vd.RenglonSub, CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN CASE WHEN (ISNULL( u.Factor, 1) * ISNULL(vd.Cantidad, 0)) - SUM(ISNULL(w.Cantidad,0)) < 0 THEN (ISNULL( u.Factor, 1) * ISNULL(vd.Cantidad, 0)) - SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) ELSE (ISNULL( u.Factor, 1) * ISNULL(vd.Cantidad, 0)) - SUM(ISNULL(w.Cantidad,0)) END ELSE CASE WHEN (ISNULL( au.Factor, 1) * ISNULL(vd.Cantidad, 0)) - SUM(ISNULL(w.Cantidad,0)) < 0 THEN (ISNULL( au.Factor, 1) * ISNULL(vd.Cantidad, 0)) - SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) ELSE (ISNULL( au.Factor, 1) * ISNULL(vd.Cantidad, 0)) - SUM(ISNULL(w.Cantidad,0)) END END, ISNULL(ISNULL(c.DefPosicionSurtido, v.PosicionWMS), a.DefPosicionSurtido), vd.Articulo, vd.Almacen, 1, vd.Almacen, vd.Unidad, vd.Cantidad 
FROM Compra v
JOIN CompraD vd ON v.ID = vd.ID
JOIN Prov c ON v.Proveedor = c.Proveedor
JOIN Alm a ON vd.Almacen = a.Almacen
LEFT OUTER JOIN WMSModuloTarima w ON w.IDModulo = v.ID AND w.Modulo = @Modulo AND w.IDTMA IS NOT NULL AND Utilizar = 1
LEFT OUTER JOIN TMA t ON t.ID = w.IDTMA AND t.Estatus <> 'CANCELADO'
LEFT OUTER JOIN EmpresaCfg2 g ON v.Empresa = g.Empresa
LEFT OUTER JOIN Unidad u ON vd.Unidad = u.Unidad
LEFT OUTER JOIN ArtUnidad au ON vd.Articulo = au.Articulo AND vd.Unidad = au.Unidad
WHERE v.ID = @ID
AND v.Mov IN(SELECT Movimiento FROM WMSModuloMovimiento WHERE Modulo = @Modulo)
AND v.Estatus = (SELECT Estatus FROM WMSModuloMovimiento WHERE Modulo = @Modulo AND Movimiento = v.Mov)
AND NULLIF(vd.Tarima,'') IS NULL
GROUP BY v.ID, vd.Renglon, vd.RenglonSub, ISNULL(vd.Cantidad, 0), ISNULL(ISNULL(c.DefPosicionSurtido, v.PosicionWMS), a.DefPosicionSurtido), vd.Articulo, vd.Almacen, g.NivelFactorMultiUnidad, ISNULL( u.Factor, 1), ISNULL( au.Factor, 1), vd.Cantidad, vd.Unidad 
IF @Modulo = 'INV'
INSERT WMSModuloTarima (IDModulo, Modulo,  Renglon,    RenglonSub,    Cantidad,             PosicionDestino, Articulo, Almacen, Utilizar, AlmacenDestino, Unidad, CantidadUnidad)
SELECT                  v.ID,     @Modulo, vd.Renglon, vd.RenglonSub,  CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN CASE WHEN (ISNULL( u.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) <0  THEN (ISNULL( u.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) WHEN (ISNULL( u.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) = 0 THEN ISNULL(vd.Cantidad,0) ELSE (ISNULL( u.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) END ELSE CASE WHEN (ISNULL( au.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) < 0  THEN (ISNULL( au.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) WHEN (ISNULL( au.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) = 0 THEN (ISNULL( au.Factor, 1) * ISNULL(vd.Cantidad,0)) ELSE (ISNULL( au.Factor, 1) * ISNULL(vd.CantidadPendiente,0)) - SUM(ISNULL(w.Cantidad,0)) END END, ISNULL(v.PosicionWMS, a.DefPosicionSurtido), vd.Articulo, vd.Almacen, 1, v.AlmacenDestino, vd.Unidad, vd.Cantidad 
FROM Inv v
JOIN InvD vd ON v.ID = vd.ID
JOIN Alm a ON vd.Almacen = a.Almacen
LEFT OUTER JOIN WMSModuloTarima w ON w.IDModulo = v.ID AND w.Modulo = @Modulo AND w.IDTMA IS NOT NULL AND Utilizar = 1
LEFT OUTER JOIN TMA t ON t.ID = w.IDTMA AND t.Estatus <> 'CANCELADO'
LEFT OUTER JOIN EmpresaCfg2 g ON v.Empresa = g.Empresa
LEFT OUTER JOIN Unidad u ON vd.Unidad = u.Unidad
LEFT OUTER JOIN ArtUnidad au ON vd.Articulo = au.Articulo AND vd.Unidad = au.Unidad
WHERE v.ID = @ID
AND v.Mov IN(SELECT Movimiento FROM WMSModuloMovimiento WHERE Modulo = @Modulo)
AND v.Estatus = (SELECT Estatus FROM WMSModuloMovimiento WHERE Modulo = @Modulo AND Movimiento = v.Mov)
AND NULLIF(vd.Tarima,'') IS NULL
AND Isnull(vd.CantidadPendiente, '') > 0
GROUP BY v.ID, vd.Renglon, vd.RenglonSub, ISNULL(vd.CantidadPendiente,0) , ISNULL(v.PosicionWMS, a.DefPosicionSurtido), vd.Articulo, vd.Almacen, vd.Cantidad, g.NivelFactorMultiUnidad, ISNULL( u.Factor, 1), ISNULL( au.Factor, 1), v.AlmacenDestino, vd.Unidad 
INSERT #CualesID VALUES (@@IDENTITY)
DELETE WMSModuloTarima
WHERE ID IN((SELECT s.ID FROM WMSModuloTarima w
JOIN WMSModuloTarima s ON w.IDModulo = s.IDModulo AND w.Modulo = s.Modulo
AND w.Articulo = s.Articulo AND w.Renglon = s.Renglon AND s.TarimaSurtido = NULL AND s.IDTMA = NULL AND w.RenglonSub = s.RenglonSub
WHERE w.ID IN (SELECT ID FROM #CualesID) AND s.ID NOT IN (SELECT ID FROM #CualesID)))
IF @Modulo = 'VTAS'
INSERT WMSLista  (Estacion, Modulo, IDModulo, Articulo, Cantidad, Unidad, CantidadUnidad) 
SELECT @Estacion, @Modulo, @ID, vd.Articulo, CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN ISNULL( u.Factor, 1) * vd.CantidadPendiente ELSE ISNULL( au.Factor, 1) * vd.CantidadPendiente END, vd.unidad, vd.Cantidad 
FROM VentaD  vd
JOIN Venta v ON vd.ID = v.ID
LEFT OUTER JOIN EmpresaCfg2 g ON v.Empresa = g.Empresa
LEFT OUTER JOIN Unidad u ON vd.Unidad = u.Unidad
LEFT OUTER JOIN ArtUnidad au ON vd.Articulo = au.Articulo AND vd.Unidad = au.Unidad
WHERE vd.ID = @ID
AND NULLIF(vd.Tarima,'') IS NULL
AND Isnull(vd.CantidadPendiente, '') > 0
IF @Modulo = 'COMS'
INSERT WMSLista  (Estacion, Modulo, IDModulo, Articulo, Cantidad, Unidad, CantidadUnidad) 
SELECT @Estacion, @Modulo, @ID, vd.Articulo, CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN ISNULL( u.Factor, 1) * ISNULL(vd.CantidadPendiente, vd.Cantidad) ELSE ISNULL( au.Factor, 1) * ISNULL(vd.CantidadPendiente, vd.Cantidad) END, vd.unidad, vd.Cantidad 
FROM CompraD vd
JOIN Compra v ON vd.ID = v.ID
LEFT OUTER JOIN EmpresaCfg2 g ON v.Empresa = g.Empresa
LEFT OUTER JOIN Unidad u ON vd.Unidad = u.Unidad
LEFT OUTER JOIN ArtUnidad au ON vd.Articulo = au.Articulo AND vd.Unidad = au.Unidad
WHERE vd.ID = @ID
AND NULLIF(vd.Tarima,'') IS NULL
IF @Modulo = 'INV'
INSERT WMSLista  (Estacion, Modulo, IDModulo, Articulo, Cantidad, Unidad, CantidadUnidad) 
SELECT @Estacion, @Modulo, @ID, vd.Articulo, CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN ISNULL( u.Factor, 1) * vd.CantidadPendiente ELSE ISNULL( au.Factor, 1) * vd.CantidadPendiente END, vd.unidad, vd.Cantidad 
FROM InvD  vd
JOIN INV v ON vd.ID = v.ID
LEFT OUTER JOIN EmpresaCfg2 g ON v.Empresa = g.Empresa
LEFT OUTER JOIN Unidad u ON vd.Unidad = u.Unidad
LEFT OUTER JOIN ArtUnidad au ON vd.Articulo = au.Articulo AND vd.Unidad = au.Unidad
WHERE vd.ID = @ID
AND NULLIF(vd.Tarima,'') IS NULL
AND Isnull(vd.CantidadPendiente, '') > 0
FETCH NEXT FROM crInicial INTO @Modulo, @ID
END
CLOSE crInicial
DEALLOCATE crInicial
SELECT TOP 1 @Hasta = ID FROM #CualesID ORDER BY ID DESC
TRUNCATE TABLE #CualesID
SELECT @Desde = @Desde + 1
WHILE @Desde <= @Hasta
BEGIN
INSERT #CualesID SELECT @Desde
SELECT @Desde = @Desde + 1
END
INSERT #Anden
SELECT COUNT(DISTINCT PosicionDestino) FROM WMSModuloTarima WHERE ID IN(SELECT ID FROM #CualesID) GROUP BY PosicionDestino
IF(SELECT COUNT(Anden) FROM #Anden) <> 1 
SELECT @Ok = 13034
IF @Modulo IS NULL
BEGIN
IF @EnSilencio = 0
SELECT 'Favor de Seleccionar un Artículo'
RETURN
END
IF @Modulo = 'VTAS'
BEGIN
SELECT @COUNT = 1
DECLARE crubicacion CURSOR local static FOR
SELECT Modulo, ID, SUM(Cantidad), Posicion, Articulo, Almacen, Unidad, CantidadUnidad, Factor, NULL 
FROM
(
SELECT 'VTAS' Modulo, v.ID, CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN CASE ISNULL( u.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) WHEN 0 THEN ISNULL( u.Factor, 1) * SUM(ISNULL(vd.Cantidad,0)) ELSE CASE WHEN (ISNULL( u.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT)- SUM(ISNULL(w.Cantidad,0)) < 0 THEN (ISNULL( u.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT) - SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) ELSE (ISNULL( u.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT)- SUM(ISNULL(w.Cantidad,0)) END END ELSE CASE ISNULL( au.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) WHEN 0 THEN ISNULL( au.Factor, 1) * SUM(ISNULL(vd.Cantidad,0)) ELSE CASE WHEN (ISNULL( au.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT)- SUM(ISNULL(w.Cantidad,0)) < 0 THEN (ISNULL( au.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT)- SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) ELSE (ISNULL( au.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT)- SUM(ISNULL(w.Cantidad,0)) END END END as Cantidad, CASE ISNULL(e.WMSAndenSurtidoContacto,0) WHEN 1 THEN c.DefPosicionSurtido ELSE ISNULL(v.PosicionWMS, a.DefPosicionSurtido) END as Posicion, vd.Articulo, vd.Almacen, vd.Unidad, vd.Cantidad CantidadUnidad, CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN ISNULL( u.Factor, 1) ELSE ISNULL( au.Factor, 1) END Factor 
FROM Venta v
JOIN VentaD vd ON v.ID = vd.ID
JOIN Cte c ON v.Cliente = c.Cliente
LEFT JOIN CteEnviarA ca ON c.Cliente = ca.Cliente AND vd.EnviarA = ca.ID
JOIN Alm a ON vd.Almacen = a.Almacen
JOIN EmpresaCfg e ON e.Empresa = @Empresa
LEFT OUTER JOIN WMSModuloTarima w ON w.IDModulo = v.ID AND w.Modulo = 'VTAS' AND w.IDTMA IS NOT NULL AND Utilizar = 1
LEFT OUTER JOIN TMA t ON t.ID = w.IDTMA AND t.Estatus <> 'CANCELADO'
LEFT OUTER JOIN EmpresaCfg2 g ON v.Empresa = g.Empresa
LEFT OUTER JOIN Unidad u ON vd.Unidad = u.Unidad
LEFT OUTER JOIN ArtUnidad au ON vd.Articulo = au.Articulo AND vd.Unidad = au.Unidad
WHERE v.ID IN (SELECT IDModulo FROM WMSLista WHERE Modulo = 'VTAS' AND Estacion = @Estacion)
AND v.Mov IN(SELECT Movimiento FROM WMSModuloMovimiento WHERE Modulo = 'VTAS')
AND v.Estatus = (SELECT Estatus FROM WMSModuloMovimiento WHERE Modulo = 'VTAS' AND Movimiento = v.Mov)
AND NULLIF(vd.Tarima,'') IS NULL
AND Isnull(vd.CantidadPendiente, '') > 0
GROUP BY v.ID, CASE ISNULL(e.WMSAndenSurtidoContacto,0) WHEN 1 THEN c.DefPosicionSurtido ELSE ISNULL(v.PosicionWMS, a.DefPosicionSurtido) END, vd.Articulo, vd.Almacen, g.NivelFactorMultiUnidad, ISNULL( u.Factor, 1), ISNULL( au.Factor, 1), vd.Unidad, vd.Cantidad, ISNULL( u.Factor, 1)
)AS x
GROUP BY Modulo, ID, Posicion, Articulo, Almacen, Unidad, CantidadUnidad, Factor 
ORDER BY Posicion, Articulo, Almacen, Unidad, CantidadUnidad, Factor
END ELSE
IF @Modulo = 'COMS'
BEGIN
SELECT @COUNT = 1
DECLARE crubicacion CURSOR local static FOR
SELECT Modulo, ID, SUM(Cantidad), Posicion, Articulo, Almacen, Unidad, CantidadUnidad, Factor, NULL 
FROM
(
SELECT 'COMS' Modulo, v.ID, CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN CASE WHEN (ISNULL( u.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente, vd.Cantidad))/@COUNT) - SUM(ISNULL(w.Cantidad,0)) < 0 THEN (ISNULL( u.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente, vd.Cantidad))/@COUNT) - SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) ELSE (ISNULL( u.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente, vd.Cantidad))/@COUNT) - SUM(ISNULL(w.Cantidad,0)) END ELSE CASE WHEN (ISNULL( au.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente, vd.Cantidad))/@COUNT) - SUM(ISNULL(w.Cantidad,0)) < 0 THEN (ISNULL( au.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente, vd.Cantidad))/@COUNT) - SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) ELSE (ISNULL( au.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente, vd.Cantidad))/@COUNT) - SUM(ISNULL(w.Cantidad,0)) END END Cantidad, CASE ISNULL(e.WMSAndenSurtidoContacto,0) WHEN 1 THEN c.DefPosicionSurtido ELSE ISNULL(v.PosicionWMS, a.DefPosicionSurtido) END as Posicion, vd.Articulo, vd.Almacen, vd.Unidad, vd.Cantidad CantidadUnidad, CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN ISNULL( u.Factor, 1) ELSE ISNULL( au.Factor, 1) END Factor 
FROM Compra v
JOIN CompraD vd ON v.ID = vd.ID
JOIN Prov c ON v.Proveedor = c.Proveedor
JOIN Alm a ON vd.Almacen = a.Almacen
JOIN EmpresaCfg e ON e.Empresa = @Empresa
LEFT OUTER JOIN WMSModuloTarima w ON w.IDModulo = v.ID AND w.Modulo = 'COMS' AND w.IDTMA IS NOT NULL AND Utilizar = 1
LEFT OUTER JOIN TMA t ON t.ID = w.IDTMA AND t.Estatus <> 'CANCELADO'
LEFT OUTER JOIN EmpresaCfg2 g ON v.Empresa = g.Empresa
LEFT OUTER JOIN Unidad u ON vd.Unidad = u.Unidad
LEFT OUTER JOIN ArtUnidad au ON vd.Articulo = au.Articulo AND vd.Unidad = au.Unidad
WHERE v.ID IN (SELECT IDModulo FROM WMSLista WHERE Modulo = 'COMS' AND Estacion = @Estacion)
AND v.Mov IN(SELECT Movimiento FROM WMSModuloMovimiento WHERE Modulo = 'COMS')
AND v.Estatus = (SELECT Estatus FROM WMSModuloMovimiento WHERE Modulo = 'COMS' AND Movimiento = v.Mov)
AND NULLIF(vd.Tarima,'') IS NULL
GROUP BY v.ID, ISNULL(v.PosicionWMS, a.DefPosicionSurtido), vd.Articulo, vd.Almacen, e.WMSAndenSurtidoContacto, c.DefPosicionSurtido, g.NivelFactorMultiUnidad, ISNULL( u.Factor, 1), ISNULL( au.Factor, 1), vd.Unidad, vd.Cantidad, ISNULL( u.Factor, 1)
)AS x
GROUP BY Modulo, ID, Posicion, Articulo, Almacen, Unidad, CantidadUnidad, Factor 
ORDER BY Posicion, Articulo, Almacen, Unidad, CantidadUnidad, Factor
END ELSE
IF @Modulo = 'INV'
BEGIN
SELECT @COUNT = 1
DECLARE crUbicacion CURSOR LOCAL STATIC FOR
SELECT Modulo, ID, SUM(Cantidad), Posicion, Articulo, Almacen, Unidad, CantidadUnidad, Factor, NULL 
FROM
(
SELECT 'INV' Modulo, v.ID, CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN CASE ISNULL( u.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) WHEN 0 THEN ISNULL( u.Factor, 1) * SUM(ISNULL(vd.Cantidad,0)) ELSE CASE WHEN (ISNULL( u.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT)- SUM(ISNULL(w.Cantidad,0)) < 0 THEN (ISNULL( u.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT) - SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) ELSE (ISNULL( u.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT)- SUM(ISNULL(w.Cantidad,0)) END END ELSE CASE ISNULL( au.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) WHEN 0 THEN ISNULL( au.Factor, 1) * SUM(ISNULL(vd.Cantidad,0)) ELSE CASE WHEN (ISNULL( au.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT)- SUM(ISNULL(w.Cantidad,0)) < 0 THEN (ISNULL( au.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT)- SUM(ISNULL(w.Cantidad,0)) + SUM(ISNULL(w.Cantidad,0)) ELSE (ISNULL( au.Factor, 1) * SUM(ISNULL(vd.CantidadPendiente,0)) /@COUNT)- SUM(ISNULL(w.Cantidad,0)) END END END as Cantidad, ISNULL(v.PosicionWMS, a.DefPosicionSurtido) as Posicion, vd.Articulo, vd.Almacen, vd.Unidad, vd.Cantidad CantidadUnidad, CASE g.NivelFactorMultiUnidad WHEN 'Unidad' THEN ISNULL( u.Factor, 1) ELSE ISNULL( au.Factor, 1) END Factor 
FROM Inv v
JOIN InvD vd ON v.ID = vd.ID
JOIN Alm a ON vd.Almacen = a.Almacen
JOIN EmpresaCfg e ON e.Empresa = @Empresa
LEFT OUTER JOIN WMSModuloTarima w ON w.IDModulo = v.ID AND w.Modulo = @Modulo AND w.IDTMA IS NOT NULL AND Utilizar = 1
LEFT OUTER JOIN TMA t ON t.ID = w.IDTMA AND t.Estatus <> 'CANCELADO'
LEFT OUTER JOIN EmpresaCfg2 g ON v.Empresa = g.Empresa
LEFT OUTER JOIN Unidad u ON vd.Unidad = u.Unidad
LEFT OUTER JOIN ArtUnidad au ON vd.Articulo = au.Articulo AND vd.Unidad = au.Unidad
WHERE v.ID IN (SELECT IDModulo FROM WMSLista WHERE Modulo = @Modulo AND Estacion = @Estacion)
AND v.Mov IN(SELECT Movimiento FROM WMSModuloMovimiento WHERE Modulo = @Modulo)
AND v.Estatus = (SELECT Estatus FROM WMSModuloMovimiento WHERE Modulo = @Modulo AND Movimiento = v.Mov)
AND NULLIF(vd.Tarima,'') IS NULL
AND ISNULL(vd.CantidadPendiente,'') > 0
GROUP BY v.ID, ISNULL(v.PosicionWMS, a.DefPosicionSurtido), vd.Articulo, vd.Almacen, g.NivelFactorMultiUnidad, ISNULL( u.Factor, 1), ISNULL( au.Factor, 1), vd.Unidad, vd.Cantidad, ISNULL( u.Factor, 1)
)AS x
GROUP BY Modulo, ID, Posicion, Articulo, Almacen, Unidad, CantidadUnidad, Factor 
ORDER BY Posicion, Articulo, Almacen, Unidad, CantidadUnidad, Factor
END
OPEN crUbicacion
FETCH NEXT FROM crUbicacion INTO @ModuloAux, @IDAux, @Cantidad, @Posicion, @Articulo, @Almacen, @Unidad, @CantidadUnidad, @Factor, @Disponible 
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
EXEC spTMAArtDomicilioInicializar @Empresa, @Almacen, @Articulo, NULL
/*
SELECT @Referencia = dbo.fnWMSReferenciaHerramienta(#CualesID.ID)
FROM #CualesID
JOIN WMSModuloTarima ON #CualesID.ID = WMSModuloTarima.ID
WHERE WMSModuloTarima.Modulo = @ModuloAux
AND WMSModuloTarima.IDModulo = @IDAux
*/
SELECT @SucursalDestino = Sucursal,
@Referencia = 'Sucursal Destino ' + CONVERT(varchar(max), Sucursal)
FROM Alm
JOIN WMSModuloTarima ON Alm.Almacen = WMSModuloTarima.AlmacenDestino
WHERE WMSModuloTarima.Modulo = @ModuloAux
AND WMSModuloTarima.IDModulo = @IDAux
SELECT @ControlArticulo = ControlArticulo FROM Art WHERE Articulo  = @Articulo
IF @ControlArticulo IS NULL OR @ControlArticulo = ''
SELECT @OK = 10036, @OkRef = @Articulo
SELECT TOP 1 @Zona = Zona FROM ArtZona WHERE Articulo = @Articulo ORDER BY Orden
IF @ControlArticulo = 'Caducidad'
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Ubicacion', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
ELSE
IF @ControlArticulo = 'Posición'
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Ubicacion', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
ELSE
IF @ControlArticulo = 'Fecha Entrada'
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Ubicacion', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
IF @Cantidad >= @Disponible AND @Disponible > 0 AND @Tarima IS NOT NULL
BEGIN
INSERT #TarimaAux
SELECT @Tarima, @Cantidad, @Disponible
INSERT #Explocion
SELECT @ModuloAux, @IDAux, @Referencia, @SucursalDestino, @Disponible, @Posicion, @Articulo, @Almacen, @Tarima, @Zona, 1, @Unidad, (CASE WHEN @Cantidad > @Disponible THEN @Disponible ELSE @Cantidad END / @Factor), @Factor 
SELECT @Cantidad = @Cantidad - @Disponible
END
WHILE @Cantidad >= @Disponible AND @Disponible > 0 AND @Tarima IS NOT NULL
BEGIN
IF @ControlArticulo = 'Caducidad'
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Ubicacion', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
ELSE
IF @ControlArticulo = 'Posición'
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Ubicacion', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
ELSE
IF @ControlArticulo = 'Fecha Entrada'
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Ubicacion', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
IF @Tarima IS NOT NULL
BEGIN
INSERT #TarimaAux
SELECT @Tarima, @Cantidad, @Disponible
INSERT #Explocion
SELECT @ModuloAux, @IDAux, @Referencia, @SucursalDestino, @Disponible, @Posicion, @Articulo, @Almacen, @Tarima, @Zona, 2, @Unidad, (CASE WHEN @Cantidad > @Disponible THEN @Disponible ELSE @Cantidad END / @Factor), @Factor 
SELECT @Cantidad = @Cantidad - @Disponible
END
END
IF @Cantidad >= ISNULL(@Disponible  ,0)
BEGIN
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Domicilio', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
IF @Cantidad >= @Disponible AND @Disponible > 0 AND @Tarima IS NOT NULL
BEGIN
INSERT #TarimaAux
SELECT @Tarima, @Cantidad, @Disponible
INSERT #Explocion
SELECT @ModuloAux, @IDAux, @Referencia, @SucursalDestino, @Disponible, @Posicion, @Articulo, @Almacen, @Tarima, @Zona, 3, @Unidad, (CASE WHEN @Cantidad > @Disponible THEN @Disponible ELSE @Cantidad END / @Factor), @Factor 
SELECT @Cantidad = @Cantidad - @Disponible
END
WHILE @Cantidad >= @Disponible AND @Disponible > 0 AND @Tarima IS NOT NULL
BEGIN
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Domicilio', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
IF @Tarima IS NOT NULL
BEGIN
INSERT #TarimaAux
SELECT @Tarima, @Cantidad, @Disponible
INSERT #Explocion
SELECT @ModuloAux, @IDAux, @Referencia, @SucursalDestino, @Disponible, @Posicion, @Articulo, @Almacen, @Tarima, @Zona, 4, @Unidad, (CASE WHEN @Cantidad > @Disponible THEN @Disponible ELSE @Cantidad END / @Factor), @Factor 
SELECT @Cantidad = @Cantidad - @Disponible
END
END
END
IF @Cantidad < @Disponible AND @Cantidad > 0
BEGIN
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Domicilio', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
IF  @Tarima IS NOT NULL
BEGIN
INSERT #TarimaAux
SELECT @Tarima, @Cantidad, @Disponible
IF @Disponible > 0
BEGIN
IF @Cantidad <= @Disponible
INSERT #Explocion
SELECT @ModuloAux, @IDAux, @Referencia, @SucursalDestino, @Cantidad, @Posicion, @Articulo, @Almacen, @Tarima, @Zona, 5, @Unidad, (CASE WHEN @Cantidad > @Disponible THEN @Disponible ELSE @Cantidad END / @Factor), @Factor 
ELSE
INSERT #Explocion
SELECT @ModuloAux, @IDAux, @Referencia, @SucursalDestino, @Disponible, @Posicion, @Articulo, @Almacen, @Tarima, @Zona, 5, @Unidad, (CASE WHEN @Cantidad > @Disponible THEN @Disponible ELSE @Cantidad END / @Factor), @Factor 
END
SELECT @Cantidad = @Cantidad - @Disponible
END
END
IF NOT EXISTS (SELECT * FROM #Explocion)  AND @Disponible IS NULL AND @Cantidad > 0
BEGIN
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Domicilio', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
IF  @Tarima IS NOT NULL
BEGIN
INSERT #TarimaAux
SELECT @Tarima, @Cantidad, @Disponible
IF @Disponible >= @Cantidad
INSERT #Explocion
SELECT @ModuloAux, @IDAux, @Referencia, @SucursalDestino, @Cantidad, @Posicion, @Articulo, @Almacen, @Tarima, @Zona, 6, @Unidad, (CASE WHEN @Cantidad > @Disponible THEN @Disponible ELSE @Cantidad END / @Factor), @Factor 
SELECT @Cantidad = @Cantidad - @Disponible
END
WHILE @Cantidad >= @Disponible AND @Disponible > 0 AND @Tarima IS NOT NULL
BEGIN
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Domicilio', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
IF @Tarima IS NOT NULL
BEGIN
INSERT #TarimaAux
SELECT @Tarima, @Cantidad, @Disponible
INSERT #Explocion
SELECT @ModuloAux, @IDAux, @Referencia, @SucursalDestino, @Disponible, @Posicion, @Articulo, @Almacen, @Tarima, @Zona, 7, @Unidad, (CASE WHEN @Cantidad > @Disponible THEN @Disponible ELSE @Cantidad END / @Factor), @Factor 
SELECT @Cantidad = @Cantidad - @Disponible
END
END
END
/*
SELECT @CantidadPedida = 0, @CantidadDisponible = 0
SELECT @CantidadPedida = SUM(Cantidad)
FROM WMSModuloTarima
WHERE ID IN(SELECT ID FROM #CualesID)
AND Articulo = @Articulo
GROUP BY Articulo, Unidad 
SELECT @CantidadDisponible = SUM(Cantidad)
FROM #Explocion
WHERE Articulo = @Articulo
GROUP BY Articulo, Unidad 
IF @CantidadPedida - @CantidadDisponible > 0
BEGIN
SELECT @Cantidad = @CantidadPedida - @CantidadDisponible, @Tarima = NULL
IF @ControlArticulo = 'Caducidad'
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Ubicacion', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
ELSE
IF @ControlArticulo = 'Posición'
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Ubicacion', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
ELSE
IF @ControlArticulo = 'Fecha Entrada'
EXEC spTMAExplocionTarima @Almacen, @Articulo, @Cantidad, @ControlArticulo, 'Ubicacion', NULL, @Tarima OUTPUT, @Disponible OUTPUT, NULL
IF @Cantidad > 0 AND @Tarima IS NOT NULL
BEGIN
INSERT #TarimaAux
SELECT @Tarima, @Cantidad, @Cantidad
INSERT #Explocion
SELECT @Disponible, @Posicion, @Articulo, @Almacen, @Tarima, @Zona, 8, @Unidad, (CASE WHEN @Cantidad > @Disponible THEN @Disponible ELSE @Cantidad END / @Factor), @Factor 
SELECT @CantidadDisponible = @CantidadDisponible + @Cantidad
END
IF @CantidadPedida - @CantidadDisponible > 0
IF NOT EXISTS(SELECT * FROM WMSSurtidoPendiente WHERE Estacion = @Estacion AND Articulo = @Articulo AND Almacen = Almacen) 
INSERT WMSSurtidoPendiente (Estacion, Articulo,  Almacen,  Cantidad)
SELECT  				     @Estacion, @Articulo, @Almacen, @CantidadPedida - @CantidadDisponible
END
*/
FETCH NEXT FROM crUbicacion INTO  @ModuloAux, @IDAux, @Cantidad, @Posicion, @Articulo, @Almacen, @Unidad, @CantidadUnidad, @Factor, @Disponible 
END
CLOSE crUbicacion
DEALLOCATE crUbicacion
UPDATE #Explocion
SET CantidadUnidad = FLOOR(Cantidad/Factor),
Cantidad = FLOOR(Cantidad/Factor) * Factor
FROM #Explocion
WHERE FLOOR(Cantidad/Factor)- CantidadUnidad <> 0
DELETE #Explocion WHERE ISNULL(Cantidad, 0) = 0
SELECT @ModuloAuxAnt = ''
WHILE(1=1)
BEGIN
SELECT @ModuloAux = MIN(Modulo)
FROM ListaModuloID
WHERE Estacion = @Estacion
AND Modulo > @ModuloAuxAnt
IF @ModuloAux IS NULL BREAK
SELECT @ModuloAuxAnt = @ModuloAux
SELECT @IDAuxAnt = 0
WHILE(1=1)
BEGIN
SELECT @IDAux = MIN(ID)
FROM ListaModuloID
WHERE Estacion = @Estacion
AND Modulo = @ModuloAux
AND ID > @IDAuxAnt
IF @IDAux IS NULL BREAK
SELECT @IDAuxAnt = @IDAux
/*
SELECT @Referencia = dbo.fnWMSReferenciaHerramienta(#CualesID.ID)
FROM #CualesID
JOIN WMSModuloTarima ON #CualesID.ID = WMSModuloTarima.ID
WHERE WMSModuloTarima.Modulo = @ModuloAux
AND WMSModuloTarima.IDModulo = @IDAux
*/
SELECT @SucursalDestino = NULL, @Referencia = NULL, @Posicion = NULL
SELECT @SucursalDestino = Sucursal,
@Referencia = 'Sucursal Destino ' + CONVERT(varchar(max), Sucursal),
@PosicionDestino = ISNULL(WMSModuloTarima.PosicionDestino, Alm.DefPosicionSurtido)
FROM Alm
JOIN WMSModuloTarima ON Alm.Almacen = WMSModuloTarima.AlmacenDestino
WHERE WMSModuloTarima.Modulo = @ModuloAux
AND WMSModuloTarima.IDModulo = @IDAux
SELECT @AlmacenAuxAnt = ''
WHILE(1=1)
BEGIN
SELECT @AlmacenAux = MIN(Almacen)
FROM WMSModuloTarima
WHERE Modulo = @ModuloAux
AND IDModulo = @IDAux
AND Almacen > @AlmacenAuxAnt
IF @AlmacenAux IS NULL BREAK
SELECT @AlmacenAuxAnt = @AlmacenAux
SELECT @ArticuloAuxAnt = ''
WHILE(1=1)
BEGIN
SELECT @ArticuloAux = MIN(Articulo)
FROM WMSModuloTarima
WHERE Modulo = @ModuloAux
AND IDModulo = @IDAux
AND Almacen = @AlmacenAux
AND Articulo > @ArticuloAuxAnt
IF @ArticuloAux IS NULL BREAK
SELECT @ArticuloAuxAnt = @ArticuloAux
SELECT @Zona = NULL
SELECT TOP 1 @Zona = Zona FROM ArtZona WHERE Articulo = @ArticuloAux ORDER BY Orden
SELECT @UnidadAuxAnt = ''
WHILE(1=1)
BEGIN
SELECT @UnidadAux = MIN(Unidad)
FROM WMSModuloTarima
WHERE Modulo = @ModuloAux
AND IDModulo = @IDAux
AND Almacen = @AlmacenAux
AND Articulo = @ArticuloAux
AND Unidad >@UnidadAuxAnt
IF @UnidadAux IS NULL BREAK
SELECT @UnidadAuxAnt = @UnidadAux
SELECT @CantidadPedida = 0
SELECT @CantidadPedida = ISNULL(SUM(Cantidad), 0)
FROM WMSModuloTarima
WHERE Modulo = @ModuloAux
AND IDModulo = @IDAux
AND Almacen = @AlmacenAux
AND Articulo = @ArticuloAux
AND Unidad = @UnidadAux
SELECT @CantidadDisponible = 0
SELECT @CantidadDisponible = ISNULL(SUM(Cantidad), 0)
FROM #Explocion
WHERE Modulo = @ModuloAux
AND ModuloID = @IDAux
AND Almacen = @AlmacenAux
AND Articulo = @ArticuloAux
AND Unidad = @UnidadAux
SELECT @CantidadFaltante = 0
SELECT @CantidadFaltante = @CantidadPedida - @CantidadDisponible
IF @CantidadFaltante > 0
BEGIN
SELECT @Disponibles = 0
SELECT @Disponibles = SUM(Disponible)
FROM ArtDisponibleTarima
JOIN Tarima ON ArtDisponibleTarima.tarima = tarima.tarima
JOIN AlmPos ON tarima.posicion = almpos.posicion
WHERE AlmPos.Almacen = @AlmacenAux
AND Tarima.Articulo = @ArticuloAux
AND Tarima.Tarima <> ''
AND Tipo IN('Ubicacion')
AND Tarima.Tarima NOT IN (SELECT ISNULL(Tarima,'') FROM #TarimaAux)
AND Tarima.Tarima NOT IN(SELECT d.Tarima FROM TMAD d JOIN TMA a ON a.ID = d.ID JOIN MovTipo m ON m.Mov = a.Mov AND m.Modulo = 'TMA' WHERE a.Estatus IN ('PENDIENTE', 'SINAFECTAR') AND m.Clave IN ('TMA.OSUR', 'TMA.TSUR')
UNION
SELECT d.Tarima FROM TMAD d JOIN TMA a ON a.ID = d.ID JOIN MovTipo m ON m.Mov = a.Mov AND m.Modulo = 'TMA' WHERE a.Estatus IN ('PENDIENTE', 'SINAFECTAR') AND m.Clave IN ('TMA.SRADO', 'TMA.SADO', 'TMA.ORADO', 'TMA.OADO')AND d.Procesado = 0)
SELECT @Disponibles = ISNULL(@Disponibles, 0) + SUM(ISNULL(Disponible, 0))
FROM ArtDisponibleTarima
JOIN Tarima ON ArtDisponibleTarima.tarima = tarima.tarima
JOIN AlmPos ON tarima.posicion = almpos.posicion
WHERE AlmPos.Almacen = @AlmacenAux
AND Tarima.Articulo = @ArticuloAux
AND Tarima.Tarima <> ''
AND Tipo IN('Domicilio')
SELECT @Disponibles = ISNULL(@Disponibles, 0) - ISNULL(SUM(TMAD.CantidadPendiente), 0)
FROM TMA
JOIN TMAD ON TMA.ID = TMAD.ID
JOIN Tarima ON TMAD.Tarima = Tarima.Tarima
JOIN AlmPos ON Tarima.Posicion = Almpos.Posicion
WHERE AlmPos.Almacen = @AlmacenAux
AND ArticuloEsp = @ArticuloAux
AND Tipo IN('Domicilio')
AND TMA.Estatus = 'PENDIENTE'
SELECT @Utilizadas  = 0
/*SELECT @Utilizadas = SUM(ISNULL(d.CantidadPendiente,0))
FROM TMAD d
JOIN TMA a ON a.ID = d.ID
JOIN MovTipo m ON m.Mov = a.Mov AND m.Modulo = 'TMA'
JOIN ArtDisponibleTarima ON d.Tarima = ArtDisponibleTarima.Tarima
JOIN Tarima ON ArtDisponibleTarima.Tarima = Tarima.Tarima
JOIN AlmPos ON Tarima.Posicion = AlmPos.Posicion
WHERE a.Estatus IN ('PENDIENTE', 'PROCESAR')
AND m.Clave IN ('TMA.OSUR', 'TMA.TSUR', 'TMA.SRADO', 'TMA.SADO')
AND d.Procesado = CASE m.Clave
WHEN 'TMA.OSUR'  THEN d.Procesado
WHEN 'TMA.TSUR'  THEN d.Procesado
WHEN 'TMA.SRADO' THEN 0
WHEN 'TMA.SADO'  THEN 0
END
AND ArtDisponibleTarima.Almacen = @AlmacenAux
AND Articulo = @ArticuloAux
AND ArtDisponibleTarima.Tarima <> ''
AND AlmPos.Tipo IN('Ubicacion')*/
SELECT @Tarima = NULL, @Posicion = NULL
SELECT @Tarima = a.Tarima,
@Posicion = p.Posicion
FROM ArtDisponibleTarima a
JOIN Tarima t ON t.Tarima = a.Tarima
JOIN AlmPos p ON p.Posicion = t.Posicion  AND p.Almacen = @AlmacenAux
WHERE a.Articulo = @ArticuloAux
AND p.ArticuloEsp = @ArticuloAux
AND p.Tipo = 'Domicilio'
AND a.Disponible > 0
AND t.Estatus = 'ALTA' AND t.Tarima NOT LIKE '%-%'
IF @Tarima IS NULL
SELECT @Tarima = a.Tarima,
@Posicion = p.Posicion
FROM ArtDisponibleTarima a
JOIN Tarima t ON t.Tarima = a.Tarima
JOIN AlmPos p ON p.Posicion = t.Posicion  AND p.Almacen = @AlmacenAux
WHERE a.Articulo = @ArticuloAux
AND p.ArticuloEsp = @ArticuloAux
AND p.Tipo = 'Domicilio'
AND t.Estatus = 'ALTA' AND t.Tarima NOT LIKE '%-%'
IF @Tarima IS NULL
SELECT @Tarima = a.Tarima,
@Posicion = p.Posicion
FROM ArtDisponibleTarima a
JOIN Tarima t ON t.Tarima = a.Tarima
JOIN AlmPos p ON p.Posicion = t.Posicion  AND p.Almacen = @AlmacenAux
WHERE a.Articulo = @ArticuloAux
AND p.ArticuloEsp = @ArticuloAux
AND p.Tipo = 'Domicilio'
AND t.Estatus = 'BAJA' AND t.Tarima NOT LIKE '%-%'
IF @Tarima IS NULL
BEGIN
SELECT @Posicion = NULL
SELECT @Posicion = p.Posicion
FROM AlmPos p
WHERE p.ArticuloEsp = @ArticuloAux
AND p.Tipo = 'Domicilio'
AND p.Almacen = @AlmacenAux
IF @Posicion IS NOT NULL
SELECT @Tarima = Tarima
FROM Tarima
WHERE Posicion = @Posicion
AND Almacen = @AlmacenAux
ELSE
SELECT @Tarima = NULL
END
IF @Tarima IS NOT NULL
BEGIN
SELECT @Disponibles = ISNULL(@Disponibles, 0) - ISNULL(SUM(Cantidad), 0)
FROM #Explocion
WHERE /*Modulo = @ModuloAux
AND ModuloID = @IDAux
AND */Almacen = @AlmacenAux
AND Articulo = @ArticuloAux
AND Unidad = @UnidadAux
AND Tarima = @Tarima
END
IF @Tarima IS NOT NULL AND ISNULL(@Disponibles, 0) - ISNULL(@Utilizadas, 0) > 0
BEGIN
IF ISNULL(@Disponibles, 0) - ISNULL(@Utilizadas, 0) < @CantidadFaltante
SELECT @CantidadFaltante = ISNULL(@Disponibles, 0) - ISNULL(@Utilizadas, 0)
INSERT #TarimaAux
SELECT @Tarima, @CantidadFaltante, @CantidadFaltante
INSERT #Explocion
SELECT TOP 1 @ModuloAux, @IDAux, @Referencia, @SucursalDestino, @CantidadFaltante, @PosicionDestino, @ArticuloAux, @AlmacenAux, @Tarima, @Zona, 8, @UnidadAux, @CantidadFaltante / dbo.fnArtUnidadFactor(@Empresa, @ArticuloAux, @UnidadAux), dbo.fnArtUnidadFactor(@Empresa, @ArticuloAux, @UnidadAux)
END
END
END
END
UPDATE #Explocion
SET CantidadUnidad = FLOOR(Cantidad/Factor),
Cantidad = FLOOR(Cantidad/Factor) * Factor
FROM #Explocion
WHERE FLOOR(Cantidad/Factor)- CantidadUnidad <> 0
DELETE #Explocion WHERE ISNULL(Cantidad, 0) = 0
SELECT @CantidadPedida = ISNULL(SUM(Cantidad), 0)
FROM WMSModuloTarima
WHERE Modulo = @ModuloAux
AND IDModulo = @IDAux
AND Almacen = @AlmacenAux
AND Articulo = @ArticuloAux
SELECT @CantidadDisponible = ISNULL(SUM(Cantidad), 0)
FROM #Explocion
WHERE Modulo = @ModuloAux
AND ModuloID = @IDAux
AND Almacen = @AlmacenAux
AND Articulo = @ArticuloAux
SELECT @CantidadFaltante = @CantidadPedida - @CantidadDisponible
IF @CantidadFaltante > 0
IF NOT EXISTS(SELECT * FROM WMSSurtidoPendiente WHERE Estacion = @Estacion AND Articulo = @ArticuloAux AND Almacen = @AlmacenAux)
INSERT WMSSurtidoPendiente (Estacion, Articulo,  Almacen,  Cantidad)
SELECT           @Estacion, @ArticuloAux, @AlmacenAux, @CantidadFaltante
END
END
END
DELETE WMSSurtidoProcesarD WHERE Estacion = @Estacion AND Procesado = 0
IF @ControlArticulo = 'Fecha Entrada'
INSERT WMSSurtidoProcesarD (Estacion, Modulo, ModuloID, Procesado, Articulo, Tarima, PosicionDestino, CantidadTarima, PosicionOrigen, Tipo, Zona, Almacen, Referencia, Unidad, CantidadUnidad, SucursalFiltro) 
SELECT @Estacion, e.Modulo, e.ModuloID, 0, e.Articulo, e.Tarima, e.Pocicion, Sum(e.cantidad), t.Posicion, ap.Tipo, ap.zona, e.Almacen, Referencia, e.Unidad, Sum(CASE WHEN e.factor = 1 THEN e.cantidad ELSE e.cantidadunidad END), SucursalFiltro 
FROM #Explocion e
LEFT JOIN Tarima t ON e.Tarima = t.Tarima
LEFT JOIN AlmPos ap ON e.Almacen = ap.Almacen AND t.Posicion = ap.Posicion
GROUP BY e.Modulo, e.ModuloID, e.Articulo, e.Tarima, e.Pocicion, t.Posicion, ap.Tipo, ap.Zona, e.Almacen, e.Unidad, t.Alta, Referencia, SucursalFiltro
ORDER BY t.Alta
IF @ControlArticulo = 'Posición'
INSERT WMSSurtidoProcesarD (Estacion, Modulo, ModuloID, Procesado, Articulo, Tarima, PosicionDestino, CantidadTarima, PosicionOrigen, Tipo, Zona, Almacen, Referencia, Unidad, CantidadUnidad, SucursalFiltro) 
SELECT @Estacion, e.Modulo, e.ModuloID, 0, e.Articulo, e.Tarima, e.Pocicion, Sum(e.cantidad), t.Posicion, ap.Tipo, ap.zona, e.Almacen, Referencia, e.Unidad, Sum(CASE WHEN e.factor = 1 THEN e.cantidad ELSE e.cantidadunidad END), SucursalFiltro 
FROM #Explocion e
LEFT JOIN Tarima t ON e.Tarima = t.Tarima
LEFT JOIN AlmPos ap ON e.Almacen = ap.Almacen AND t.Posicion = ap.Posicion
GROUP BY e.Modulo, e.ModuloID, e.Articulo, e.Tarima, e.Pocicion, t.Posicion, ap.Tipo, ap.Zona, e.Almacen, e.Unidad, ap.Tipo, Referencia, SucursalFiltro
ORDER BY ap.Tipo
IF @ControlArticulo = 'Caducidad'
INSERT WMSSurtidoProcesarD (Estacion,  Modulo, ModuloID, Procesado, Articulo, Tarima, PosicionDestino, CantidadTarima, PosicionOrigen, Tipo, Zona, Almacen, Referencia, Unidad, CantidadUnidad, SucursalFiltro) 
SELECT @Estacion, e.Modulo, e.ModuloID, 0, e.Articulo, e.Tarima, e.Pocicion, Sum(e.cantidad), t.Posicion, ap.Tipo, ap.zona, e.Almacen, Referencia, e.Unidad, Sum(CASE WHEN e.factor = 1 THEN e.cantidad ELSE e.cantidadunidad END), SucursalFiltro 
FROM #Explocion e
LEFT JOIN Tarima t ON e.Tarima = t.Tarima
LEFT JOIN AlmPos ap ON e.Almacen = ap.Almacen AND t.Posicion = ap.Posicion
GROUP BY e.Modulo, e.ModuloID, e.Articulo, e.Tarima, e.Pocicion, t.Posicion, ap.Tipo, ap.Zona, e.Almacen, e.Unidad, t.FechaCaducidad, Referencia, SucursalFiltro
ORDER BY t.FechaCaducidad
IF (SELECT ISNULL(WMSAndenSurtidoContacto, 0) FROM EmpresaCfg WHERE Empresa = @Empresa) = 0
UPDATE WMSSurtidoProcesarD SET PosicionDestino = NULL
UPDATE WMSModuloTarima SET Utilizar = 0 WHERE ID IN(SELECT ID FROM #CualesID)
IF @Ok IS NULL OR @Ok BETWEEN 80030 AND 81000 OR @Ok = 80010
BEGIN
IF (SELECT COUNT(DISTINCT ARTICULO) FROM WMSModuloTarima WHERE ID IN(SELECT ID FROM #CualesID)) <>
(SELECT COUNT(*)
FROM
(
SELECT Articulo, SUM(Cantidad) as Cantidad
FROM WMSModuloTarima
WHERE ID IN(SELECT ID FROM #CualesID)
AND Articulo IN(SELECT Articulo FROM #Explocion GROUP BY Articulo)
GROUP BY Articulo
) as x)
BEGIN
IF @EnSilencio = 0
SELECT 'Los movimientos seleccionados no podrán ser surtidos en su Totalidad.'
END
ELSE
BEGIN
IF @EnSilencio = 0
SELECT 'Procesadas Con Exito'
END
END
ELSE
BEGIN
IF @OK = 10036
IF @EnSilencio = 0
SELECT Descripcion + ' ' + ISNULL(@OkRef,'')  FROM MensajeLista WHERE Mensaje = @Ok
ELSE
IF @EnSilencio = 0
SELECT Descripcion + ' Articulo ' + ISNULL(@OkRef,'')  FROM MensajeLista WHERE Mensaje = @Ok
DELETE WMSSurtidoProcesarD WHERE Estacion = @Estacion AND Procesado = 0
END
END
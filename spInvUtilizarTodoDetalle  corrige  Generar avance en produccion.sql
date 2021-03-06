
ALTER PROCEDURE [dbo].[spInvUtilizarTodoDetalle]  
     @Sucursal  int,  
     @Modulo  char(5),  
     @Base  char(20),   -- IDENTICO  
         @OID            int,  
                   @OrigenMov  char(20),  
                   @OrigenMovID  varchar(20),  
                   @OrigenMovTipo char(20),  
                   @DID   int,  
     @GenerarDirecto bit,  
  
     @Ok   int OUTPUT,  
     @Empresa  char(5) = NULL,  
     @MovTipo  varchar(20) = NULL  
--//WITH ENCRYPTION  
AS BEGIN  
   
  IF @Modulo = 'VTAS'  
  BEGIN  
    IF @GenerarDirecto = 1 SELECT @OrigenMov = NULL, @OrigenMovID = NULL  
    SELECT * INTO #VentaDetalle FROM cVentaD   WHERE ID = @OID  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    IF @Base IN ('TODO', 'IDENTICO') UPDATE #VentaDetalle SET ID = @DID, CantidadPendiente = NULL, CantidadCancelada = NULL, CantidadReservada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL ELSE  
    IF @Base = 'SELECCION' UPDATE #VentaDetalle SET ID = @DID, Cantidad = CantidadA, CantidadInventario = CantidadA * CantidadInventario / Cantidad, CantidadPendiente = NULL, CantidadCancelada = NULL, CantidadReservada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL ELSE  
    IF @Base = 'PENDIENTE' UPDATE #VentaDetalle SET ID = @DID, Cantidad = NULLIF(ISNULL(CantidadPendiente,0.0) + ISNULL(CantidadReservada, 0.0), 0.0), CantidadInventario = (NULLIF(ISNULL(CantidadPendiente,0.0) + ISNULL(CantidadReservada, 0.0), 0.0)) * CantidadInventario / Cantidad, CantidadPendiente = NULL, CantidadReservada = NULL, CantidadCancelada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL 
ELSE  
    IF @Base = 'RESERVADO' UPDATE #VentaDetalle SET ID = @DID, Cantidad = CantidadReservada, CantidadInventario = CantidadReservada * CantidadInventario / Cantidad, CantidadPendiente = NULL, CantidadCancelada = NULL, CantidadReservada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL   
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    IF @Base = 'IDENTICO'  
      UPDATE #VentaDetalle SET Aplica = o.Aplica, AplicaID = o.AplicaID FROM #VentaDetalle n, VentaD o WHERE o.ID = @OID AND n.Renglon = o.Renglon AND n.RenglonSub = o.RenglonSub  
    ELSE  
      UPDATE #VentaDetalle SET Sucursal = @Sucursal, SucursalOrigen = @Sucursal, SustitutoArticulo = NULL, SustitutoSubCuenta = NULL  
  
/*  
    IF @Base = 'SELECCION'  
      UPDATE #VentaDetalle SET Precio = Precio * Factor WHERE Factor <> 1.0  
    ELSE  
      UPDATE #VentaDetalle SET Cantidad = Cantidad / Factor, Precio = Precio * Factor WHERE Factor <> 1.0  
*/  
    DELETE #VentaDetalle WHERE Cantidad IS NULL OR Cantidad = 0.0  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    -- Actualizar Descuento Importe  
    UPDATE #VentaDetalle SET DescuentoImporte = (Cantidad*Precio)*(DescuentoLinea/100.0)  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    INSERT INTO cVentaD SELECT * FROM #VentaDetalle  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    DROP TABLE #VentaDetalle  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  END ELSE  
  
  IF @Modulo = 'PROD'  
  BEGIN  

    IF @GenerarDirecto = 1 SELECT @OrigenMov = NULL, @OrigenMovID = NULL  
    SELECT * INTO #ProdDetalle FROM cProdD WHERE ID = @OID  
  
    IF @@ERROR <> 0 SELECT @Ok = 1  
    IF @Base = 'TODO' DELETE #ProdDetalle WHERE AutoGenerado = 1  
    IF @@ERROR <> 0 SELECT @Ok = 1  
 
    IF @Base = 'TODO'      UPDATE #ProdDetalle SET ID = @DID, AutoGenerado = 0, ProdSerieLote = NULL, CantidadPendiente = NULL, CantidadCancelada = NULL, CantidadReservada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL ELSE  
    IF @Base = 'SELECCION' UPDATE #ProdDetalle SET ID = @DID, AutoGenerado = 0, Cantidad = CantidadA, CantidadInventario = CantidadA * CantidadInventario / Cantidad, CantidadPendiente = NULL, CantidadCancelada = NULL, CantidadReservada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL ELSE  
    IF @Base = 'PENDIENTE' UPDATE #ProdDetalle SET ID = @DID, AutoGenerado = 0, Cantidad = NULLIF(ISNULL(CantidadPendiente,0.0) + ISNULL(CantidadReservada, 0.0), 0.0), CantidadInventario = (NULLIF(ISNULL(CantidadPendiente,0.0) + ISNULL(CantidadReservada, 0.0), 0.0)) * CantidadInventario / Cantidad, CantidadPendiente = NULL, CantidadReservada = NULL, CantidadCancelada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL ELSE  
    IF @Base = 'RESERVADO' UPDATE #ProdDetalle SET ID = @DID, AutoGenerado = 0, Cantidad = CantidadReservada, CantidadInventario = CantidadReservada * CantidadInventario / Cantidad, CantidadPendiente = NULL, CantidadCancelada = NULL, CantidadReservada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL   
  
    UPDATE #ProdDetalle SET Sucursal = @Sucursal, SucursalOrigen = @Sucursal, DestinoTipo = NULL, Destino = NULL, DestinoID = NULL  

    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    UPDATE #ProdDetalle SET SustitutoArticulo = NULL, SustitutoSubCuenta = NULL  
  
    DELETE #ProdDetalle WHERE Cantidad IS NULL OR Cantidad = 0.0  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    CREATE TABLE #ProdAplica(  
      Aplica    char(20) COLLATE Database_Default NULL,   
      AplicaID    varchar(20) COLLATE Database_Default NULL,   
      ProdSerieLote   varchar(50) COLLATE Database_Default NULL,  
      Articulo    char(20) COLLATE Database_Default NULL,   
      SubCuenta    varchar(50) COLLATE Database_Default NULL,  
      Unidad    varchar(50) COLLATE Database_Default NULL,  
      Almacen    char(10) COLLATE Database_Default NULL,  
      Centro    char(10) COLLATE Database_Default NULL,  
      Instruccion   varchar(50) COLLATE Database_Default NULL,  
      Renglon    float  NULL,  
      RenglonSub   int  NULL,  
      Cantidad    float  NULL,  
      CantidadInventario  float  NULL)  
  
    INSERT   
      INTO #ProdAplica  
    SELECT Aplica, AplicaID, ProdSerieLote, Articulo, SubCuenta, Unidad, Almacen, Centro, Instruccion, Min(Renglon), Min(RenglonSub), SUM(Cantidad), SUM(CantidadInventario)  
      FROM #ProdDetalle   
     GROUP BY Aplica, AplicaID, ProdSerieLote, Articulo, SubCuenta, Unidad, Almacen, Centro, Instruccion  
     ORDER BY Aplica, AplicaID, ProdSerieLote, Articulo, SubCuenta, Unidad, Almacen, Centro, Instruccion  
    IF @@ERROR <> 0 SELECT @Ok = 1   

    INSERT INTO cProdD   
    SELECT d.*   
      FROM #ProdDetalle d, #ProdAplica a   
     WHERE ISNULL(d.ProdSerieLote, '') = ISNULL(a.ProdSerieLote, '')  
       AND ISNULL(d.Aplica,'') = ISNULL(a.Aplica, '')   
       AND ISNULL(d.AplicaID, '') = ISNULL(a.AplicaID, '')  
       AND d.Articulo = a.Articulo  
       AND ISNULL(d.SubCuenta,'') = ISNULL(a.SubCuenta, '')  
       AND d.Almacen = a.Almacen  
       AND ISNULL(d.Centro, '') = ISNULL(a.Centro, '')  
       AND d.Renglon = a.Renglon  
       AND d.RenglonSub = a.RenglonSub  
    AND ISNULL(d.Instruccion,'') = ISNULL(a.Instruccion,'') 
 
      IF @@ERROR <> 0 SELECT @Ok = 1  
  
    UPDATE ProdD   
       SET ProdD.Cantidad = a.Cantidad,  
           ProdD.CantidadInventario = a.CantidadInventario  
      FROM ProdD d, #ProdAplica a   
     WHERE d.ID = @DID   
       AND ISNULL(d.ProdSerieLote, '') = ISNULL(a.ProdSerieLote, '')  
       AND ISNULL(d.Aplica,'') = ISNULL(a.Aplica, '')   
       AND ISNULL(d.AplicaID, '') = ISNULL(a.AplicaID, '')  
       AND d.Articulo = a.Articulo   
       AND ISNULL(d.SubCuenta,'') = ISNULL(a.SubCuenta, '')  
       AND d.Almacen = a.Almacen  
       AND ISNULL(d.Centro, '') = ISNULL(a.Centro, '')  
       AND d.Renglon = a.Renglon  
       AND d.RenglonSub = a.RenglonSub  
      IF @@ERROR <> 0 SELECT @Ok = 1  
  
    DROP TABLE #ProdDetalle  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  END ELSE  
  
  IF @Modulo = 'COMS'  
  BEGIN  
    SELECT * INTO #CompraDetalle FROM cCompraD  WHERE ID = @OID  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    IF @Base IN ('TODO', 'IDENTICO') UPDATE #CompraDetalle SET ID = @DID, CantidadCancelada = NULL, CantidadPendiente = NULL, CantidadA = NULL, Aplica = CASE WHEN @OrigenMovTipo <> 'COMS.C' THEN @OrigenMov ELSE Aplica END, AplicaID = CASE WHEN @OrigenMovTipo <> 'COMS.C' THEN @OrigenMovID ELSE AplicaID END ELSE  
    IF @Base = 'SELECCION' UPDATE #CompraDetalle SET ID = @DID, DestinoTipo = CASE WHEN @MovTipo = 'COMS.CP' THEN DestinoTipo ELSE NULL END, Destino = CASE WHEN @MovTipo = 'COMS.CP' THEN Destino ELSE NULL END, DestinoID = CASE WHEN @MovTipo = 'COMS.CP' THEN DestinoID ELSE NULL END, Cantidad = CantidadA, CantidadInventario = CantidadA * CantidadInventario / Cantidad, CantidadCancelada = NULL, CantidadPendiente = NULL, CantidadA = NULL, Aplica = CASE WHEN @OrigenMovTipo <> 'COMS.C' THEN @OrigenMov ELSE Aplica END, AplicaID = CASE WHEN @OrigenMovTipo <> 'COMS.C' THEN @OrigenMovID ELSE AplicaID END ELSE  
    IF @Base = 'PENDIENTE' UPDATE #CompraDetalle SET ID = @DID, DestinoTipo = CASE WHEN @MovTipo = 'COMS.CP' THEN DestinoTipo ELSE NULL END, Destino = CASE WHEN @MovTipo = 'COMS.CP' THEN Destino ELSE NULL END, DestinoID = CASE WHEN @MovTipo = 'COMS.CP' THEN DestinoID ELSE NULL END, Cantidad = CantidadPendiente, CantidadInventario = CantidadPendiente * CantidadInventario / Cantidad, CantidadCancelada = NULL, CantidadPendiente = NULL, CantidadA = NULL, Aplica = CASE WHEN @OrigenMovTipo <> 'COMS.C' THEN @OrigenMov ELSE Aplica END, AplicaID = CASE WHEN @OrigenMovTipo <> 'COMS.C' THEN @OrigenMovID ELSE AplicaID END   
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    IF @Base <> 'IDENTICO'  
      UPDATE #CompraDetalle SET Sucursal = @Sucursal, SucursalOrigen = @Sucursal   
  
    DELETE #CompraDetalle WHERE Cantidad IS NULL OR Cantidad = 0.0  
    IF @@ERROR <> 0 SELECT @Ok = 1  
      
    IF @OrigenMovTipo IN ('COMS.R','COMS.O','COMS.OP','COMS.OG','COMS.OD','COMS.OI')  
    BEGIN  
      CREATE TABLE #CompraAplica(  
        Almacen   char(10) COLLATE Database_Default NULL,  
        Aplica   char(20) COLLATE Database_Default NULL,   
        AplicaID  varchar(20) COLLATE Database_Default NULL,   
        Articulo  char(20) COLLATE Database_Default NULL,   
        SubCuenta  varchar(50) COLLATE Database_Default NULL,  
 Unidad   varchar(50) COLLATE Database_Default NULL,  
 Cliente   char(10) COLLATE Database_Default NULL,  
 ContUso   char(20) COLLATE Database_Default NULL,  
 FechaRequerida  datetime NULL,  
        Renglon   float  NULL,  
        RenglonSub  int  NULL,  
        Cantidad  float  NULL,  
        CantidadInventario   float  NULL,  
 Costo   money  NULL)  
  
      IF (SELECT CompraConcentrarEntrada FROM EmpresaCfg WHERE Empresa = @Empresa) = 1  
        INSERT   
          INTO #CompraAplica  
        SELECT Almacen, Aplica, AplicaID, Articulo, SubCuenta, Unidad, Cliente, ContUso, FechaRequerida, Min(Renglon), Min(RenglonSub), SUM(Cantidad), SUM(CantidadInventario), SUM(Costo*Cantidad)/SUM(Cantidad)  
          FROM #CompraDetalle   
         GROUP BY Almacen, Aplica, AplicaID, Articulo, SubCuenta, Unidad, Cliente, ContUso, FechaRequerida  
         ORDER BY Almacen, Aplica, AplicaID, Articulo, SubCuenta, Unidad, Cliente, ContUso, FechaRequerida  
      ELSE  
        INSERT   
          INTO #CompraAplica  
        SELECT Almacen, Aplica, AplicaID, Articulo, SubCuenta, Unidad, Cliente, ContUso, FechaRequerida, Renglon, RenglonSub, Cantidad, CantidadInventario, Costo  
          FROM #CompraDetalle   
         --GROUP BY Almacen, Aplica, AplicaID, Articulo, SubCuenta, Unidad, Cliente, ContUso, FechaRequerida  
         --ORDER BY Almacen, Aplica, AplicaID, Articulo, SubCuenta, Unidad, Cliente, ContUso, FechaRequerida  
      IF @@ERROR <> 0 SELECT @Ok = 1  
  
      -- Actualizar Descuento Importe  
      UPDATE #CompraDetalle SET DescuentoImporte = (Cantidad*Costo)*(DescuentoLinea/100.0)  
      IF @@ERROR <> 0 SELECT @Ok = 1  
  
      INSERT INTO cCompraD   
      SELECT d.*   
        FROM #CompraDetalle d, #CompraAplica a   
       WHERE d.Almacen = a.Almacen  
         AND d.Aplica = a.Aplica   
         AND d.AplicaID = a.AplicaID   
         AND d.Articulo = a.Articulo   
         AND ISNULL(d.SubCuenta,'') = ISNULL(a.SubCuenta, '')  
         AND ISNULL(d.Cliente,'') = ISNULL(a.Cliente, '')  
         AND d.Renglon = a.Renglon  
         AND d.RenglonSub = a.RenglonSub  
      IF @@ERROR <> 0 SELECT @Ok = 1  
  
  
      UPDATE CompraD   
         SET DestinoTipo    = CASE WHEN @MovTipo = 'COMS.CP' THEN DestinoTipo ELSE NULL END,  
             Destino        = CASE WHEN @MovTipo = 'COMS.CP' THEN Destino     ELSE NULL END,   
             DestinoID      = CASE WHEN @MovTipo = 'COMS.CP' THEN DestinoID   ELSE NULL END,   
             CompraD.Cantidad = a.Cantidad,  
             CompraD.CantidadInventario = a.CantidadInventario,  
             CompraD.Costo  = a.Costo  
        FROM CompraD d, #CompraAplica a   
       WHERE d.ID = @DID   
         AND d.Almacen = a.Almacen  
         AND d.Aplica = a.Aplica   
         AND d.AplicaID = a.AplicaID   
         AND d.Articulo = a.Articulo   
         AND ISNULL(d.SubCuenta,'') = ISNULL(a.SubCuenta, '')  
         AND ISNULL(d.Cliente,'') = ISNULL(a.Cliente, '')  
         AND d.Renglon = a.Renglon  
         AND d.RenglonSub = a.RenglonSub  
      IF @@ERROR <> 0 SELECT @Ok = 1  
    END ELSE  
    BEGIN  
      -- Actualizar Descuento Importe  
      UPDATE #CompraDetalle SET DescuentoImporte = (Cantidad*Costo)*(DescuentoLinea/100.0)  
      IF @@ERROR <> 0 SELECT @Ok = 1  
  
      INSERT INTO cCompraD SELECT * FROM #CompraDetalle  
      IF @@ERROR <> 0 SELECT @Ok = 1  
    END  
  
    DROP TABLE #CompraDetalle  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  END ELSE  
  
  IF @Modulo = 'INV'  
  BEGIN  
    IF @GenerarDirecto = 1 SELECT @OrigenMov = NULL, @OrigenMovID = NULL  
    SELECT * INTO #InvDetalle FROM cInvD   WHERE ID = @OID  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    IF @Base IN ('TODO', 'IDENTICO') UPDATE #InvDetalle SET ID = @DID, CantidadPendiente = NULL, CantidadCancelada = NULL, CantidadReservada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL ELSE  
    IF @Base = 'SELECCION' UPDATE #InvDetalle SET ID = @DID, Cantidad = CantidadA, CantidadInventario = CantidadA * CantidadInventario / Cantidad, CantidadPendiente = NULL, CantidadCancelada = NULL, CantidadReservada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL ELSE  
    IF @Base = 'PENDIENTE' UPDATE #InvDetalle SET ID = @DID, Cantidad = NULLIF(ISNULL(CantidadPendiente,0.0) + ISNULL(CantidadReservada, 0.0), 0.0), CantidadInventario = (NULLIF(ISNULL(CantidadPendiente,0.0) + ISNULL(CantidadReservada, 0.0), 0.0)) * CantidadInventario / Cantidad, CantidadPendiente = NULL, CantidadReservada = NULL, CantidadCancelada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL ELSE  
    IF @Base = 'RESERVADO' UPDATE #InvDetalle SET ID = @DID, Cantidad = CantidadReservada, CantidadInventario = CantidadReservada * CantidadInventario / Cantidad, CantidadPendiente = NULL, CantidadCancelada = NULL, CantidadReservada = NULL, CantidadOrdenada = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID, UltimoReservadoCantidad = NULL, UltimoReservadoFecha = NULL  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    UPDATE #InvDetalle SET Sucursal = @Sucursal, SucursalOrigen = @Sucursal   
  
    DELETE #InvDetalle WHERE Cantidad IS NULL OR Cantidad = 0.0  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    IF @OrigenMovTipo IN ('INV.SOL', 'INV.SM')  
    BEGIN  
      CREATE TABLE #InvAplica(  
 ProdSerieLote  varchar(50) COLLATE Database_Default NULL,  
 Producto  char(20) COLLATE Database_Default NULL,  
 SubProducto  varchar(50) COLLATE Database_Default NULL,  
        Almacen   char(10) COLLATE Database_Default NULL,  
        Aplica   char(20) COLLATE Database_Default NULL,   
        AplicaID  varchar(20) COLLATE Database_Default NULL,   
        Articulo  char(20) COLLATE Database_Default NULL,   
        SubCuenta  varchar(50) COLLATE Database_Default NULL,  
 Unidad   varchar(50) COLLATE Database_Default NULL,  
 ContUso   char(20) COLLATE Database_Default NULL,  
        Renglon   float  NULL,  
        RenglonSub  int  NULL,  
        Cantidad  float  NULL,  
        CantidadInventario   float  NULL,  
 Merma   float  NULL,  
        Desperdicio  float  NULL)  
  
      INSERT   
        INTO #InvAplica  
      SELECT ProdSerieLote, Producto, SubProducto, Almacen, Aplica, AplicaID, Articulo, SubCuenta, Unidad, ContUso, Min(Renglon), Min(RenglonSub), SUM(Cantidad), SUM(CantidadInventario), SUM(Merma), SUM(Desperdicio)  
        FROM #InvDetalle   
       GROUP BY ProdSerieLote, Producto, SubProducto, Almacen, Aplica, AplicaID, Articulo, SubCuenta, Unidad, ContUso  
       ORDER BY ProdSerieLote, Producto, SubProducto, Almacen, Aplica, AplicaID, Articulo, SubCuenta, Unidad, ContUso  
      IF @@ERROR <> 0 SELECT @Ok = 1  
  
      INSERT INTO cInvD   
      SELECT d.*   
        FROM #InvDetalle d, #InvAplica a   
       WHERE ISNULL(d.ProdSerieLote, '') = ISNULL(a.ProdSerieLote, '')  
         AND ISNULL(d.Producto, '') = ISNULL(a.Producto, '')  
         AND ISNULL(d.SubProducto, '') = ISNULL(a.SubProducto, '')  
         AND d.Almacen = a.Almacen  
         AND d.Aplica = a.Aplica   
         AND d.AplicaID = a.AplicaID   
         AND d.Articulo = a.Articulo   
         AND ISNULL(d.SubCuenta,'') = ISNULL(a.SubCuenta, '')  
         AND d.Renglon = a.Renglon  
         AND d.RenglonSub = a.RenglonSub  
      IF @@ERROR <> 0 SELECT @Ok = 1  
  
      UPDATE InvD   
         SET InvD.Cantidad = a.Cantidad,  
             InvD.CantidadInventario = a.CantidadInventario,  
             InvD.Merma = a.Merma,  
             InvD.Desperdicio = a.Desperdicio  
        FROM InvD d, #InvAplica a   
       WHERE d.ID = @DID   
         AND ISNULL(d.ProdSerieLote, '') = ISNULL(a.ProdSerieLote, '')  
         AND ISNULL(d.Producto, '') = ISNULL(a.Producto, '')  
         AND ISNULL(d.SubProducto, '') = ISNULL(a.SubProducto, '')  
         AND d.Almacen = a.Almacen  
         AND d.Aplica = a.Aplica   
         AND d.AplicaID = a.AplicaID   
         AND d.Articulo = a.Articulo   
         AND ISNULL(d.SubCuenta,'') = ISNULL(a.SubCuenta, '')  
         AND d.Renglon = a.Renglon  
         AND d.RenglonSub = a.RenglonSub  
      IF @@ERROR <> 0 SELECT @Ok = 1  
    END ELSE  
    BEGIN  
      INSERT INTO cInvD SELECT * FROM #InvDetalle  
      IF @@ERROR <> 0 SELECT @Ok = 1  
    END  
    DROP TABLE #InvDetalle  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  END   
  
/*  IF @Modulo = 'WMS'  
  BEGIN  
    IF @GenerarDirecto = 1 SELECT @OrigenMov = NULL, @OrigenMovID = NULL  
    SELECT * INTO #WMSDetalle FROM cWMSD WHERE ID = @OID  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    IF @Base = 'TODO'      UPDATE #InvDetalle SET ID = @DID, CantidadPendiente = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID  ELSE  
    IF @Base = 'SELECCION' UPDATE #InvDetalle SET ID = @DID, Cantidad = CantidadA, CantidadPendiente = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID  ELSE  
    IF @Base = 'PENDIENTE' UPDATE #InvDetalle SET ID = @DID, Cantidad = CantidadPendiente, CantidadPendiente = NULL, CantidadA = NULL, Aplica = @OrigenMov, AplicaID = @OrigenMovID   
    IF @@ERROR <> 0 SELECT @Ok = 1  
  
    UPDATE #WMSDetalle SET Sucursal = @Sucursal, SucursalOrigen = @Sucursal   
  
    DELETE #WMSDetalle WHERE Cantidad IS NULL OR Cantidad = 0.0  
    IF @@ERROR <> 0 SELECT @Ok = 1  
  END */  
  
  EXEC xpInvUtilizarTodoDetalle @Sucursal, @Modulo, @Base, @OID, @OrigenMov, @OrigenMovID, @OrigenMovTipo, @DID, @GenerarDirecto, @Ok OUTPUT  
  
  RETURN  
END  

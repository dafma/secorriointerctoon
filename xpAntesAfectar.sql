
ALTER PROCEDURE [dbo].[xpAntesAfectar]                                      
@Modulo        char(5),                                      
@ID            int,                                      
@Accion        char(20),                                      
@Base          char(20),                                      
@GenerarMov    char(20),                                      
@Usuario       char(10),                                      
@SincroFinal   bit,                                      
@EnSilencio    bit,                                      
@Ok            int   OUTPUT,                                      
@OkRef         varchar(255)  OUTPUT,                                      
@FechaRegistro datetime                                      
AS BEGIN                                      
DECLARE     
  @Condicion   varchar(50),    
  @Lote        varchar(50),    
  @Instruccion varchar(50),    
  @TC          varchar(25),     
  @Estatus     varchar(20),                                   
  @OrigenID    varchar(20),     
  @Clave       varchar(20),       
  @Origen      varchar(20),      
  @Mov         varchar(20),     
  @Articulo    varchar(20),                               
  @OrigenTipo  varchar(10),       
  @Cte         varchar(10),                                                                
  @IDOrigen    int,                                                               
  @Abono       money,                                
  @cargo       money,      
  @Maximo      float,                                   
  @Cantidad    float,                                    
  @CantidadPendiente float,    
  @Bandera int                        

                                 
  IF @Modulo = 'PROD' AND @Accion = 'CANCELAR'                               

   BEGIN                              

    IF (SELECT Mov from prod WHERE id = @id) = 'Orden Produccion'                              

     BEGIN                              

     SELECT a.Empresa,a.ProdSerieLote,a.Articulo,a.SubCuenta,a.Sucursal,a.moneda,                              
           'Cargo' = SUM(ISNULL(cargo,0)),                              
           'Abono' = SUM(ISNULL(abono,0))                              
       INTO #Temp                              
       FROM ProdSerieLoteCosto A                               
      WHERE ProdSerielote in (select ProdSerieLote FROM PRODD WHERE PRODD.id = @id)                              
      GROUP BY a.Empresa,a.ProdSerieLote,a.Articulo,a.SubCuenta,a.Sucursal,a.moneda                              

     INSERT ProdSerieLoteCosto (Empresa,ProdSerieLote,Articulo,SubCuenta,Sucursal,ModuloID,Modulo,Cargo,Abono,moneda, Concepto)                              
     SELECT Empresa,ProdSerieLote,Articulo,SubCuenta,Sucursal,@id,'PROD',Cargo*-1,Abono*-1,moneda, 'Ajuste'                              
       FROM #Temp                              

       
     --Borra el origen par aque se pueda cancelar                            

     DELETE FROM MOVFLUJO WHERE DModulo = 'PROD' and DID = @ID                            

    END                                

  END                               

                                          

     --Para eliminar el excedente y no queden pendientes                                    

  IF @Modulo = 'PROD' AND @Accion = 'AFECTAR'                                    

   BEGIN                                    

        

    SELECT @Clave=Clave,@OrigenTipo=OrigenTipo,@Origen=Origen,@OrigenID=OrigenID,@Mov=a.Mov                                

      FROM Prod a INNER JOIN Movtipo ON Movtipo.Mov = a.Mov AND Movtipo.Modulo = 'PROD'           

     WHERE ID=@ID                                    

                                    

    SELECT @IDOrigen = ID                                    

      FROM Prod                                    

     WHERE Mov=@Origen AND MovID=@OrigenID          

                                    

    IF @Mov = 'Cancelacion Orden'                                

     BEGIN                                

 SELECT @lote = min(ProdSerieLote) FROM prodD where id = @ID                                

                                

      SELECT @Cargo = SUM(Cargo)                                

        FROM prodSerieLoteCosto                                

       WHERE ProdSerieLote = @lote                                

                                

      UPDATE prodSerieLoteCosto                                

         SET Abono = @Cargo                                

       WHERE ProdSerieLote = @lote AND Cargo is null and abono is null                                

                                

     RETURN                                

    END                                

                                

IF @Clave = 'PROD.E'                                    

 BEGIN                                    

                               

   DECLARE crProdAP CURSOR FOR                                    

  SELECT AD.ARTICULO, AD.INSTRUCCION, AD.CANTIDAD, SUM(BD.CANTIDADPENDIENTE)                                    

  FROM PROD A                                    

   INNER JOIN PRODD AD ON A.ID = AD.ID                               

   INNER JOIN PROD B ON A.ORIGEN = B.MOV AND A.ORIGENID = B.MOVID AND A.ORIGENTIPO='PROD'                                    

   INNER JOIN PRODD BD ON B.ID = BD.ID AND AD.ARTICULO = BD.ARTICULO AND ISNULL(AD.INSTRUCCION,'') = ISNULL(BD.INSTRUCCION,'') AND  BD.CANTIDADPENDIENTE > 0                                   

  WHERE                                     

   A.ID = @ID                                    

  GROUP BY AD.ARTICULO, AD.INSTRUCCION, AD.CANTIDAD                                   

      

     

                                      

    OPEN crProdAP                                    

    FETCH NEXT FROM crProdAP INTO @Articulo, @Instruccion, @Cantidad, @CantidadPendiente                          

    WHILE @@FETCH_STATUS <> -1                                     

    BEGIN                                    

   IF @@FETCH_STATUS <> -2                                     

   BEGIN                                    

                                    

    SELECT @Maximo = MAX(Renglon)+2058 FROM PRODD WHERE ID= @IDOrigen                                    

                                    

                                  

    IF @Cantidad > @CantidadPendiente                                    

     begin                                  

----select @Cantidad - @CantidadPendiente                                    

     INSERT prodd (ID,Renglon,RenglonSub,RenglonID,RenglonTipo,AutoGenerado,Almacen,Codigo,Articulo,SubCuenta,Cantidad,Costo,ProdSerieLote,                                    

     CantidadPendiente,CantidadReservada,CantidadCancelada,CantidadOrdenada,CantidadA,Paquete,DestinoTipo,Destino,DestinoID,                                    

     Aplica,AplicaID,Cliente,Centro,CentroDestino,Orden,OrdenDestino,Unidad,Factor,CantidadInventario,Ruta,Volumen,SustitutoArticulo,                                    

     SustitutoSubCuenta,FechaRequerida,FechaEntrega,DescripcionExtra,UltimoReservadoCantidad,UltimoReservadoFecha,Merma,                                 

     Desperdicio,Tipo,Comision,ManoObra,Indirectos,Maquila,Personal,Estacion,EstacionDestino,Tiempo,TiempoUnidad,Sucursal,Turno,                                    

     TiempoEstandarFijo,TiempoEstandarVariable,TiempoMuerto,Causa,Logico1,Logico2,Logico3,AjusteCosteo,CostoUEPS,CostoPEPS,                                    

     UltimoCosto,PrecioLista,DepartamentoDetallista,Posicion,SucursalOrigen,Tarima,Bobina,Instruccion,Hoja,Kilo)                                    

                                   

     SELECT  top 1 ID,@Maximo,RenglonSub,RenglonID,RenglonTipo,AutoGenerado,Almacen,Codigo,Articulo,SubCuenta,@Cantidad - @CantidadPendiente,Costo,ProdSerieLote,                                    

     @Cantidad - @CantidadPendiente,CantidadReservada,CantidadCancelada,CantidadOrdenada,CantidadA,1,DestinoTipo,Destino,DestinoID,                                    

     Aplica,AplicaID,Cliente,Centro,CentroDestino,Orden,OrdenDestino,Unidad,Factor,CantidadInventario,Ruta,Volumen,SustitutoArticulo,                                    

     SustitutoSubCuenta,FechaRequerida,FechaEntrega,@ID,UltimoReservadoCantidad,UltimoReservadoFecha,Merma,                                    

     Desperdicio,Tipo,Comision,ManoObra,Indirectos,Maquila,Personal,Estacion,EstacionDestino,Tiempo,TiempoUnidad,Sucursal,Turno,                                    

     TiempoEstandarFijo,TiempoEstandarVariable,TiempoMuerto,Causa,Logico1,Logico2,Logico3,AjusteCosteo,CostoUEPS,CostoPEPS,                                    

     UltimoCosto,PrecioLista,DepartamentoDetallista,Posicion,SucursalOrigen,0,0,Instruccion,Hoja,Kilo                                    

     FROM prodd                                    

     WHERE  id= @IdOrigen AND Articulo = @articulo AND Instruccion = @Instruccion and cantidadpendiente > 0                                   

  end                                  

   END                                    

                                    

   FETCH NEXT FROM crProdAP INTO @Articulo, @Instruccion, @Cantidad, @CantidadPendiente                                    

    END                                    

    CLOSE crProdAP                                     

    DEALLOCATE crProdAP                                     

                                    

 END                                    

                                    

END                                    

                              

                        

DECLARE @MovVTAS  char(20),                            

  @MovIDVTAS  varchar(20)                            

                            

---- VERIFICAR QUE EL PEDIDO NO TENGA ORDENES DE PRODUCCION PENDIENTES                            

IF @Modulo = 'VTAS' AND @Accion = 'CANCELAR'                               

BEGIN                              

 SELECT @MovVTAS = Mov, @MovIDVTAS = Movid                            

 FROM venta                            

 WHERE Id = @id                            

                            

 IF  @MovVTAS = 'PEDIDO'                            

 BEGIN                            

  IF EXISTS (SELECT * FROM PROD                             

       INNER JOIN PRODD ON PROD.ID = PRODD.ID                            

      WHERE PROD.ID = PRODD.ID                             

      AND DestinoTipo='VTAS'                            

      AND Destino =  @MovVTAS                            

      AND DestinoId = @MovIDVTAS                            

      AND Estatus in ('PENDIENTE','CONCLUIDO'))                            

                            

   SELECT @OK = 30151                            

                 

 END                            

                             

                            

                            

END                            

                            

                          

DECLARE @AlmacenVTAS varchar(10)  , @contador int, @clientex bit                          

                                    

---- genera el reservado de bobinas                            

IF @Modulo = 'VTAS' AND @Accion in ('AFECTAR','VERIFICAR')                               

BEGIN                            

  IF EXISTS(SELECT * FROM ARTMATERIAL WHERE ARTICULO IN (SELECT ARTICULO FROM VENTAD WHERE ID=@ID))      

  BEGIN                     

    SELECT @AlmacenVTAS = Almacen, @MovVTAS = mov, @clienteX = validarReservado                          

      FROM venta INNER JOIN cte on venta.cliente = cte.cliente                           

     WHERE Id = @id        

    

               

                             

    IF @AlmacenVTAS IN ('ALM-PT','ALM-PT-M2') AND @MovVTAS = 'PEDIDO'                            

    BEGIN                            

                           

      IF ISNULL(@clienteX,1) <> 0                          

       BEGIN                      

              

        SELECT a.articulo, a.renglonid, 'Cantidad' = SUM(ISNULL(b.cantidad,0))              

          INTO #reservado     

          FROM ventad a LEFT OUTER JOIN ReservaBobina b ON a.id = b.moduloid AND SUBSTRING(a.articulo,2,10) = SUBSTRING(b.bobina,LEN(REPLACE(b.bobina,SUBSTRING(a.articulo,2,10),''))+1,10) AND a.renglonid = b.renglonid              

     WHERE a.id =  @id              

         GROUP BY a.articulo, a.renglonid                  

              

        SELECT @contador =COUNT(*)                          

          FROM #reservado a                          

         WHERE ISNULL(CANTIDAD,0) = 0       

                 

        IF @contador > 0                          

          SELECT @OK = 20400, @OKREF = 'No Ingresaron el Almacen para Reservar'      

    

    

        SELECT bobina, almacen, 'cantidad' = SUM(Cantidad)                          

          INTO #bobina                          

          FROM ReservaBobina a                          

         WHERE  moduloid= @id and modulo='VTAS'                          

           AND ISNULL(CANTIDAD,0) > 0                          

         GROUP BY BOBINA, almacen                          

                           

        SELECT cuenta,grupo,'Disponible'=SUM(CASE WHEN RAMA='INV' THEN saldou ELSE -SALDOU END)                  

          INTO #DISPONIBLE                  

          FROM #bobina a                          

          LEFT OUTER JOIN saldou b ON a.bobina = b.cuenta and a.almacen = b.grupo                  

         GROUP BY cuenta,grupo                  

                  

        SELECT @OK = 20400, @OKREF = 'No hay suficiente cantidad ' + a.bobina + ' en ' + a.almacen                          

          FROM #bobina a                          

          LEFT OUTER JOIN #DISPONIBLE b ON a.bobina = b.cuenta and a.almacen = b.grupo                   

         WHERE a.cantidad > b.Disponible                          

               

        SELECT  material, 'Cantidad' = sum(a.Cantidad)                          

          INTO #material                          

          FROM ventad a                          

         inner join artmaterial  b on a.articulo = b.articulo                          

         WHERE a.id = @id                          

         GROUP BY b.material                          

                           

        SELECT bobina, 'cantidad' = sum(cantidad)                          

          INTO #bobina2                          

          FROM #bobina                          

         GROUP BY bobina                          

                           

        SELECT @OK = 20400, @OKREF = 'Diferente con el detalle ' + a.bobina                           

         FROM #bobina2 a                          

         LEFT OUTER JOIN #material b ON a.bobina = b.material                          

        WHERE a.cantidad <> b.cantidad                          

      END                           

    END      

          

    IF @AlmacenVTAS = 'ALM-REB' AND @MovVTAS = 'PEDIDO'                            

    BEGIN                            

                           

      IF ISNULL(@clienteX,1) <> 0                          

      BEGIN                      

              

        SELECT a.articulo, a.renglonid, 'Cantidad' = sum(isnull(b.cantidad,0))              

          INTO #reservadorebobinado              

          FROM ventad a LEFT OUTER JOIN ReservaRebobinado b on a.id = b.moduloid AND a.renglonid = b.renglonid   

         WHERE a.id =  @id              

         GROUP BY a.articulo, a.renglonid                  

              

        SELECT @contador =count(*)                          

          FROM #reservadorebobinado a                          

         WHERE ISNULL(CANTIDAD,0) = 0                          

                             

        IF @contador > 0                          

          SELECT @OK = 20400, @OKREF = 'No ingresaron el almacen para reservar'                          

                           

     SELECT  bobina, almacen, 'cantidad' = sum(Cantidad)                          

          Into #bobinaRebobinado                          

          FROM ReservaRebobinado a                          

         WHERE  moduloid= @id and modulo='VTAS'                          

           AND ISNULL(CANTIDAD,0) > 0                          

         GROUP BY BOBINA, almacen                          

                           

        SELECT cuenta,grupo,'Disponible'=SUM(CASE WHEN RAMA='INV' THEN saldou ELSE -SALDOU END)                  

   INTO #DISPONIBLERebobinado                  

          FROM #bobinaRebobinado a                          

          LEFT OUTER JOIN saldou b ON a.bobina = b.cuenta and a.almacen = b.grupo                  

         GROUP BY cuenta,grupo                  

                  

        SELECT @OK = 20400, @OKREF = 'No hay suficiente cantidad ' + a.bobina + ' en ' + a.almacen                          

          FROM #bobinaRebobinado a                          

          LEFT OUTER JOIN #DISPONIBLERebobinado b ON a.bobina = b.cuenta and a.almacen = b.grupo                   

         WHERE a.cantidad > b.Disponible                          

               

        SELECT  material, 'Cantidad' = sum(a.Cantidad)                          

          INTO #materialRebobinado                          

          FROM ventad a                          

         inner join artmaterial  b on a.articulo = b.articulo                          

         WHERE a.id = @id                          

         GROUP BY b.material                          

                           

        SELECT bobina, 'cantidad' = sum(cantidad)                          

          INTO #bobinaRebobinado2                          

          FROM #bobinaRebobinado                          

         GROUP BY bobina                          

                                 

      END                           

    END      

          

                              

  END                                            

END            

    

    

    

 /* Valida campo Interes CO GMO */       

 IF @Modulo='VTAS'      

  BEGIN     

    

   SELECT @Mov=Mov ,@Estatus=Estatus,@Condicion=Condicion    

     FROM Venta     

    WHERE ID=@ID     

       

  IF @Mov='Remision' AND @Estatus='SINAFECTAR'    

   BEGIN     

   

    EXEC spValidaSLRemision @ID,@Modulo,@Bandera=@Bandera OUTPUT   

  

    IF @Bandera= 0   

       SELECT @Ok=73040, @OkRef='LAS CERTIFICACIONES DE SERIE/LOTE NO PUEDEN SER DIFERENTES'        

   END    

      

  IF @Mov='Pedido' AND @Estatus='SINAFECTAR'    

   BEGIN    

      IF(@Condicion IS NULL OR @Condicion='')        

         SELECT @Ok=10010, @OkRef='Condiciones'       

   END      

         

  END     
  




 IF @Modulo='INV'
  BEGIN 

  SELECT @Mov=Mov,@Estatus=Estatus
    FROM Inv
   WHERE ID=@ID 

 IF @Mov='Entrada Desperdicio' AND @Estatus='SINAFECTAR' 
   BEGIN -- RDOMENZAIN -- DDSIS
    --
    UPDATE Inv 
	   SET Almacen='ALM-DESP'
     WHERE ID=@ID;
	--
    UPDATE InvD 
	   SET Almacen='ALM-DESP'
     WHERE ID=@ID;
    --
  END
 
 END
                            

RETURN                                      

END       


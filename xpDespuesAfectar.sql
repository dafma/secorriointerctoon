

ALTER   PROCEDURE [dbo].[xpDespuesAfectar]                                              
@Modulo  char(5),                                              
@ID                  int,                                              
@Accion  char(20),                                              
@Base  char(20),                                              
@GenerarMov  char(20),                                              
@Usuario  char(10),                                              
@SincroFinal  bit,                                              
@EnSilencio         bit,                                              
@Ok                int   OUTPUT,                                              
@OkRef             varchar(255)  OUTPUT,                                              
@FechaRegistro datetime                                              
AS BEGIN                                              
DECLARE                                              
  @Empresa  char(5),                                              
  @Origen  varchar(20),                                              
  @OrigenID  varchar(20),                                              
  @Instruccion varchar(50),                                              
  @Tarima  float,                                              
  @Bobina  float,                                              
  @Renglon  float,                                               
  @iContI  int,                                               
  @iContF  int,                                               
  @IDV   int,                                              
  @NumTarima int,                                              
  @Articulo  varchar(20),                                              
  @Sucursal  int   ,                                            
  @IDOrigen  INT  ,            
  @OCFSC varchar(20),
  @Referencia varchar(50),   
  @Posicion   int,
  @IDCancelacion int,
  @Vencimiento datetime,
  @MovID varchar(20),
  @Mov varchar(20)
                                  
IF @Modulo = 'PROD' AND UPPER(@Accion)='GENERAR'                                              
  BEGIN                                              
 create table #Produccion (                                              
  ID    int   IDENTITY(1,1) NOT NULL ,                                              
  IDProd   int   NULL ,                                               
  Empresa   varchar(5) COLLATE Modern_Spanish_CI_AS NULL ,                                              
  Origen   varchar(50) COLLATE Modern_Spanish_CI_AS NULL ,                                              
  OrigenId  varchar(20) COLLATE Modern_Spanish_CI_AS NULL ,                                                         
  Renglon   float  NULL ,                                              
  RenglonID  int   NULL ,                                               
  RenglonSub  int   NULL ,                                              
  Instruccion  varchar(50) COLLATE Modern_Spanish_CI_AS NULL ,                                              
  Tarima   float  NULL ,                                              
  Bobina   float  NULL ,                                              
  Articulo  varchar(20) COLLATE Modern_Spanish_CI_AS NULL                                               
 )                                              
  insert into #Produccion                                               
  SELECT b.Id, a.Empresa, a.Mov, a.MovID, b.Renglon, b.RenglonId, b.RenglonSub, b.Instruccion, b.Tarima,  b.Bobina, b.Articulo                                              
  FROM Prod a                                              
  JOIN ProdD b ON a.ID = b.ID                                              
  WHERE a.ID = @ID                                              
SELECT @IDV = NULL,@iContI = 1, @iContF = COUNT(ID) FROM ProdD WHERE ID = @ID                     
 WHILE @iContI <= @iContF                                              
 BEGIN                                      
  SELECT @Articulo =Articulo, @Renglon = Renglon, @Tarima=Tarima  from #Produccion where idProd = @ID and id= @iContI                                              
  
  SELECT @IDV=p.ID  
    FROM Prod p join #Produccion c on p.Origen = c.Origen AND p.OrigenID = c.OrigenID and p.mov=@GenerarMov --'Entrada Produccion'                                                     
   WHERE c.IDProd = @ID and c.ID = @iContI  and p.movid is null                                             
  
  
  UPDATE ProdD                                          
  SET Instruccion = c.Instruccion,                                               
   Bobina = c.Bobina,                                             
   Tarima = c.Tarima                                              
  from prodD vd join #Produccion c on vd.Renglon = c.Renglon and vd.RenglonSub = c.RenglonSub                                              
  where vd.Id = @IDV 
  

                                               
  IF UPPER(@GenerarMov) in ('Entrada Produccion','Entrada Tarimas')                                              
   Begin      
                    
   select @NumTarima = 1                                                
     WHILE @NumTarima <= cast(@Tarima as int)                                              
   begin                                             
    exec spPrevioContarTarima 'INTER', 'INTER1', @IDV, @Renglon, @NumTarima, @Articulo, @FechaRegistro  --'20081001'                                               
    select @NumTarima = @NumTarima + 1                                             
   end                                              
   End                                               
  select @iContI = @iContI + 1                                              
 END                                              
END                                              
 IF @Modulo = 'PROD' AND UPPER(@Accion)='AFECTAR'                                             
  begin                           
  IF EXISTS(SELECT * FROM PROD WHERE ID= @ID AND MOV = 'Entrada Produccion')                          
  BEGIN                                             
  ----------generar articulo para la merma                                          
   select @Origen=Origen, @OrigenID= OrigenID, @Sucursal=sucursal, @Empresa=Empresa from prod where ID=@ID                                               
   select @IDV = id from prod where mov = @Origen and MovId = @OrigenId                                              
   exec spBobinaIntercarton  @IDV, @Empresa, @Sucursal                                          
   -----insert roger select  @IDV                                  
   insert into MermaIntercarton (Empresa, Sucursal, Usuario, IdProd, Serielote, Articulo, KgOriginal, KgTarima, KgReal, Estatus, FechaEmision, UltimoCambio  )                                              
   Select @Empresa, @Sucursal, @Usuario, @IDV, Serielote, Articulo,  Cantidad, 0, Cantidad, 'SINAFECTAR', @FechaRegistro, @FechaRegistro                                              
   from BobinaIntercarton where mov = @Origen and MovId = @OrigenId                                              
  END                          
 end                                              
IF @Modulo = 'PROD' AND UPPER(@Accion)='CANCELAR'                                
  BEGIN                                           
 if (select mov from prod where ID=@ID) = 'Entrada Produccion'                   
 begin                                              
  select @Origen=Origen, @OrigenID= OrigenID from prod where ID=@ID                                             
  update contarTarima set Estatus= 'CANCELADO', FechaCancelacion= getdate()                                               
  where idProd = @ID        
  update MermaIntercarton set Estatus= 'CANCELADO', FechaCancelacion= getdate()                                               
  where idProd = @ID                      
 SELECT @IDOrigen = ID                             
 FROM PROD                                            
 WHERE MOV = @Origen AND MovID = @OrigenID                                            
 DELETE FROM PRODD                                             
     WHERE ID = @IDOrigen                                             
  AND DESCRIPCIONEXTRA = @ID                                            
 end                                                 
  END   
  
  ---------- PROCEDIMIENTO DE CANCELACION DE CXP  PARA EL MOVIMIENTO Emb Transito
  

  IF @Modulo = 'COMS' AND UPPER(@Accion)='AFECTAR'                                
  BEGIN                                           
     if (select mov from Compra where ID=@ID) ='Entrada Importacion'                   
     begin                                              
      select @Referencia=Referencia from compra where ID=@ID 
	  select @Posicion=charindex('/',@referencia)   
      select @Referencia=SUBSTRING(@Referencia,1,@Posicion-1)
	  select @IDCancelacion=ID from CXP where Referencia=@Referencia  and Mov='Emb Transito'  
	  IF @IDCancelacion is not NULL
		begin
			exec spAfectar 'CXP', @IDCancelacion, 'CANCELAR', 'Todo', NULL,@Usuario 
		end
	                              
     end                                           
  END   
  
  --123457/
  ---------- HASTA AQUI ES EL PROCEDIMIENO DE CANCELACION DE CXP.

  ------------REPORTE DE CXP PARA QUE JALE EL VENCIMIENTO.

   IF @Modulo = 'COMS' AND UPPER(@Accion)='AFECTAR'                                
  BEGIN                                           
     
      select @Vencimiento=Vencimiento, @Mov=Mov,@MovID=MovID from compra where ID=@ID 
	  update Cxp set Vencimiento=@Vencimiento where OrigenTipo='COMS' and Origen=@Mov and OrigenID=@MovID

	                                      
  END   
  ---------FIN DE VENCIMIENTO
  
                       
declare @TipoFSC   varchar(50),                
  @CategoriaFSC  varchar(50),                
  @ObservacionesFSC varchar(500),                
  @SerieloTeBobina1 varchar(50),           
  @CategoriaPEFC  varchar(50),                     
  @CategoriaSFI  varchar(50),                
  @ArticuloBobina  varchar(20)                
IF @Modulo = 'PROD' AND UPPER(@Accion)='AFECTAR'                                               
BEGIN                                     
 if (select mov from prod where ID=@ID) = 'Entrada Produccion'                                              
 begin                                              
  select @Origen=Origen, @OrigenID= OrigenID, @Sucursal=sucursal, @Empresa=Empresa from prod where ID=@ID                                               
  update contarTarima set Estatus= 'CONCLUIDO'                                               
  where idProd = @ID                  
  select top 1 @SerieloTeBobina1 = bobinaserie1, @articulobobina = bobina1                
  from contartarima                     
  where idProd = @ID                      
  select top 1 @CategoriaPEFC=CategoriaPEFC,@CategoriaSFI=CategoriaSFI,@TipoFSC=TipoFSC,@CategoriaFSC=CategoriaFSC,@ObservacionesFSC=ObservacionesFSC, @OCFSC = OrdenCompra                
  from serielote                 
  where articulo=@articulobobina                
  and serielote = @SerieloTeBobina1                
  update serielotemov set CategoriaPEFC=@CategoriaPEFC,CategoriaSFI=@CategoriaSFI,TipoFSC=@TipoFSC,CategoriaFSC=@CategoriaFSC,ObservacionesFSC=@ObservacionesFSC, OrdenCompra = @OCFSC                 
  where id=@id                                    
  update serielote set instruccion =sm.instruccion, TipoFSC = sm.TipoFSC, CategoriaPEFC=sm.CategoriaPEFC, CategoriaSFI=sm.CategoriaSFI, CategoriaFSC = sm.CategoriaFSC, ObservacionesFSC=sm.ObservacionesFSC, OrdenCOmpra = @OCFSC, TotalINTERM2=sm.TotalINTERM2        
  from serielote s                                               
  join serielotemov sm on s.empresa = sm.empresa and s.articulo=sm.articulo                    
  and s.subcuenta=sm.subcuenta and s.serielote=sm.serielote                                              
  where sm.Modulo = 'PROD' and sm.id= @ID                                              
  update MermaIntercarton set Estatus= 'CONCLUIDO'                                        
  where idProd = @ID                    
  exec spMermaInv @Empresa, @Sucursal, @ID, @FechaRegistro, @Usuario, @OrigenID                                              
  ------actulaizar ProdSerieLoteCosto                             
  update ProdSerieLoteCosto                                          
   set abono = null                                          
  where modulo ='PROD' and Moduloid = @id                                          
 end           
  END                                              
    ---- PARA CANCELAR LAS BOBINAS DE UNA CANCELACION DE CONSUMO                                            
IF @Modulo = 'INV' AND @Accion = 'CANCELAR'                                            
BEGIN                      
 IF EXISTS(SELECT * FROM INV WHERE ID=@ID AND ESTATUS='CANCELADO')                                            
 BEGIN                                            
  INSERT INTO BobinaIntercartonRespaldo                                            
  SELECT ID,IDINV,Empresa,Sucursal,Mov,MovId,Serielote,Articulo,Subcuenta,Cantidad,Disponible,Propiedades,Producto                                             
  FROM BobinaIntercarton                                            
  WHERE IDINV = @ID                                            
  DELETE FROM BobinaIntercarton WHERE IDINV = @ID                                            
 END                                            
END                                         
---- PARA actualizar la serie lote en caso de no existir                                        
IF @Modulo = 'COMS' AND @Accion = 'AFECTAR'                                            
BEGIN                                            
  if (select mov from compra where ID=@ID) in  ('Entrada Importacion','Entrada Con Gastos', 'Entrada Compra')                                              
   UPDATE SerieLote                                        
   set Instruccion = isnull(SerieLote.Instruccion , a.instruccion),                                        
    Ubicacion2 = isnull(SerieLote.Ubicacion2, a.Ubicacion2),                                        
    Apartados = isnull(SerieLote.Apartados, a.Apartados),  
	FechaApartado =     isnull(SerieLote.FechaApartado, a.FechaApartado),                                   
    Observaciones = isnull(SerieLote.Observaciones, a.Observaciones),                                        
    Furgon = isnull(SerieLote.Furgon, a.Furgon),                                        
    MetrosLineales = isnull(SerieLote.MetrosLineales, a.MetrosLineales),                                        
    AnchoUtil = isnull(SerieLote.AnchoUtil, a.AnchoUtil),                                        
    Hojas = isnull(SerieLote.Hojas, a.Hojas),                                        
    Largo = isnull(SerieLote.Largo, a.Largo),                                        
    Propiedades = isnull(SerieLote.Propiedades, a.Propiedades) ,                
    TipoFSC = isnull(serielote.TipoFSC, a.TipoFSC),                
 CategoriaFSC = isnull(serielote.CategoriaFSC, a.CategoriaFSC),                
 ObservacionesFSC = isnull(serielote.ObservacionesFSC, a.ObservacionesFSC),          
 CategoriaPEFC = isnull(serielote.CategoriaPEFC,a.CategoriaPEFC),            
 CategoriaSFI = isnull(serielote.CategoriaSFI,a.CategoriaSFI),            
 OrdenCompra = isnull(serielote.OrdenCompra, a.OrdenCompra)            
   FROM serieLoteMov a                                        
   WHERE  Serielote.Serielote = a.Serielote                                        
  AND a.Modulo = 'COMS'                                        
   AND a.id = @id                                        
END                                         
declare @idGenerar int,                                        
  @MovOrigInv varchar(20),                                        
  @MovIDOrigInv varchar(20)                                        
----- modulo de ventas                                        
IF @Modulo = 'VTAS' AND @Accion = 'GENERAR'                                            
BEGIN                                            
     select @MovOrigInv = Mov , @MovIDOrigInv = Movid FROM Venta WHERE ID=@ID                                        
  IF @MovOrigInv IN ('Remision')                                        
  BEGIN                                        
     select @idGenerar = MAX(id) from VENTA where origen = @MovOrigInv and  origenid = @MovIDOrigInv and origentipo='VTAS' and estatus='SINAFECTAR'                                        
   SELECT id,modulo,SerieLote,Instruccion,Ubicacion2,Apartados,Observaciones,Furgon,MetrosLineales,AnchoUtil,Hojas,Largo,Propiedades, TipoFSC, CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra, TotalINTERM2,FechaApartado               
   INTO #TEMP1                                        
   FROM serieLoteMov                                        
   WHERE  Modulo = 'VTAS'                                        
   AND id = @ID                                        
   
   
   UPDATE SerieLoteMOV                            
   set Instruccion = isnull(SerieLoteMOV.Instruccion , a.instruccion),                         
    Ubicacion2 = isnull(SerieLoteMOV.Ubicacion2, a.Ubicacion2),                                        
    Apartados = isnull(SerieLoteMOV.Apartados, a.Apartados),  
	 FechaApartado = isnull(SerieLoteMOV.FechaApartado, a.FechaApartado),                                         
    Observaciones = isnull(SerieLoteMOV.Observaciones, a.Observaciones),                                        
    Furgon = isnull(SerieLoteMOV.Furgon, a.Furgon),                                        
    MetrosLineales = isnull(SerieLoteMOV.MetrosLineales, a.MetrosLineales),                                        
    AnchoUtil = isnull(SerieLoteMOV.AnchoUtil, a.AnchoUtil),                                        
    Hojas = isnull(SerieLoteMOV.Hojas, a.Hojas),                                        
    Largo = isnull(SerieLoteMOV.Largo, a.Largo),                                        
    Propiedades = isnull(SerieLoteMOV.Propiedades, a.Propiedades),                
 TipoFSC = isnull(serielotemov.TipoFSC, a.TipoFSC),                
 CategoriaFSC = isnull(serielotemov.CategoriaFSC, a.CategoriaFSC),                
 ObservacionesFSC = isnull(serielotemov.ObservacionesFSC, a.ObservacionesFSC),          
 CategoriaPEFC = isnull(serielotemov.CategoriaPEFC, a.CategoriaPEFC),            
 CategoriaSFI = isnull(serielotemov.CategoriaSFI, a.CategoriaSFI),            
 OrdenCompra = isnull(serielotemov.OrdenCompra, a.OrdenCompra),        
 TotalINTERM2 = ISNULL(serielotemov.TotalINTERM2, a.TotalINTERM2)                                                 
   FROM #TEMP1 a                                        
   WHERE  SerieLoteMOV.Serielote = a.Serielote                                        
  and SerieLoteMOV.id = @idGenerar             
   and SerieLoteMOV.modulo = 'VTAS'                                        
 END                                       
END                                         
IF @Modulo = 'PROD' AND @Accion in ( 'AFECTAR')                                            
BEGIN                                            
  if (select mov from PROD where ID=@ID) in  ('Entrada Produccion','Ent X Rebobinacion')             
   UPDATE SerieLote                                        
   set Instruccion = isnull(SerieLote.Instruccion , a.instruccion),                                        
    Ubicacion2 = isnull(SerieLote.Ubicacion2, a.Ubicacion2),                                        
    Apartados = isnull(SerieLote.Apartados, a.Apartados),    
	  FechaApartado = isnull(SerieLote.FechaApartado, a.FechaApartado),                            
    Observaciones = isnull(SerieLote.Observaciones, a.Observaciones),     
    Furgon = isnull(SerieLote.Furgon, a.Furgon),                                        
    MetrosLineales = isnull(SerieLote.MetrosLineales, a.MetrosLineales),                                        
    AnchoUtil = isnull(SerieLote.AnchoUtil, a.AnchoUtil),                                        
    Hojas = isnull(SerieLote.Hojas, a.Hojas),                                        
    Largo = isnull(SerieLote.Largo,  a.instruccion),         
    Propiedades = isnull(SerieLote.Propiedades, a.Propiedades),                
  TipoFSC = isnull(serielote.TipoFSC, a.TipoFSC),                
  CategoriaFSC = isnull(serielote.CategoriaFSC, a.CategoriaFSC),                
  ObservacionesFSC = isnull(serielote.ObservacionesFSC, a.ObservacionesFSC),          
  CategoriaPEFC = isnull(serielote.CategoriaPEFC, a.CategoriaPEFC),            
  CategoriaSFi = isnull(serielote.CategoriaSFI, a.CategoriaSFI),              
  OrdenCompra = isnull(serielote.OrdenCompra, a.OrdenCompra),        
  TotalINTERM2=ISNULL(SerieLote.TotalINTERM2, a.TotalINTERM2)                                           
   FROM serieLoteMov a                                        
   WHERE  Serielote.Serielote = a.Serielote                                        
   AND a.Modulo = 'PROD'                                        
   AND a.id = @id                                        
END                                        
IF @Modulo = 'INV' AND @Accion in ( 'AFECTAR','GENERAR')                                            
BEGIN       
  if (select mov from inv where ID=@ID) in  ('TRANSFERENCIA','Reservado', 'Trans Almacen Segund', 'Trans Bobinas Dañadas','Recibo Traspaso', 'Cambio Presentacion')                                              
 BEGIN    
   UPDATE SerieLote                                        
      set Instruccion = isnull(SerieLote.Instruccion , a.instruccion),                                        
    Ubicacion2 = isnull(SerieLote.Ubicacion2, a.Ubicacion2),                                        
    Apartados = isnull(SerieLote.Apartados, a.Apartados),  
	FechaApartado =   isnull(SerieLote.FechaApartado, a.FechaApartado),                                    
    Observaciones = isnull(SerieLote.Observaciones, a.Observaciones),                                        
    Furgon = isnull(SerieLote.Furgon, a.Furgon),                                        
    MetrosLineales = isnull(SerieLote.MetrosLineales, a.MetrosLineales),                  
    AnchoUtil = isnull(SerieLote.AnchoUtil, a.AnchoUtil),                                        
    Hojas = isnull(SerieLote.Hojas, a.Hojas),                                        
    Largo = isnull(SerieLote.Largo, a.Largo),                                        
    Propiedades = isnull(SerieLote.Propiedades, a.Propiedades),                
    TipoFSC = isnull(serielote.TipoFSC, a.TipoFSC),                
    CategoriaFSC = isnull(serielote.CategoriaFSC, a.CategoriaFSC),                
    ObservacionesFSC = isnull(serielote.ObservacionesFSC, a.ObservacionesFSC) ,          
    CategoriaPEFC = isnull(serielote.CategoriaPEFC, a.CategoriaPEFC),            
    CategoriaSFI = isnull(serielote.CategoriaSFI, a.CategoriaSFI),              
    OrdenCompra = isnull(serielote.OrdenCompra, a.OrdenCOmpra)       
   FROM serieLoteMov a                                        
   WHERE  Serielote.Serielote = a.Serielote                                        
   AND a.Modulo = 'INV'                                        
   AND a.id = @id       
 END    
 ELSE                                        
 BEGIN        
  select @MovOrigInv = Mov , @MovIDOrigInv = Movid FROM INV WHERE ID=@ID        
  IF @MovOrigInv IN ('Salida Traspaso','Transito')                                        
  BEGIN                                        
     SELECT @idGenerar = MAX(id) FROM inv WHERE origen = @MovOrigInv AND  origenid = @MovIDOrigInv and origentipo='INV'  --and estatus='SINAFECTAR'                                         
   SELECT id,modulo,SerieLote,Instruccion,Ubicacion2,Apartados,Observaciones,Furgon,MetrosLineales,AnchoUtil,Hojas,Largo,Propiedades, TipoFSC, CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado                                       




     INTO #TEMP2                                        
     FROM serieLoteMov                                        
    WHERE  Modulo = 'INV'                                        
      AND id = @ID     
	  
	                                     
   UPDATE SerieLoteMOV                                        
   set Instruccion = isnull(SerieLoteMOV.Instruccion , a.instruccion),                                        
    Ubicacion2 = isnull(SerieLoteMOV.Ubicacion2, a.Ubicacion2),                                        
    Apartados = isnull(SerieLoteMOV.Apartados, a.Apartados),  
	 FechaApartado = isnull(SerieLoteMOV.FechaApartado, a.FechaApartado),                                          
    Observaciones = isnull(SerieLoteMOV.Observaciones, a.Observaciones),                                        
    Furgon = isnull(SerieLoteMOV.Furgon, a.Furgon),                                        
    MetrosLineales = isnull(SerieLoteMOV.MetrosLineales, a.MetrosLineales),                                        
    AnchoUtil = isnull(SerieLoteMOV.AnchoUtil, a.AnchoUtil),                                        
 Hojas = isnull(SerieLoteMOV.Hojas, a.Hojas),          
    Largo = isnull(SerieLoteMOV.Largo, a.Largo),                                        
    Propiedades = isnull(SerieLoteMOV.Propiedades, a.Propiedades),                
 TipoFSC = isnull(serielotemov.TipoFSC, a.TipoFSC),                
 CategoriaFSC = isnull(serielotemov.CategoriaFSC, a.CategoriaFSC),                
 ObservacionesFSC = isnull(serielotemov.ObservacionesFSC, a.ObservacionesFSC),          
 CategoriaPEFC = isnull(serielotemov.CategoriaPEFC, a.CategoriaPEFC),            
 CategoriaSFI = isnull(serielotemov.CategoriaSFI, a.CategoriaSFI),              
  OrdenCOmpra = isnull(serielotemov.OrdenCompra, a.OrdenCompra)                                                         
   FROM #TEMP2 a                                        
   WHERE  SerieLoteMOV.Serielote = a.Serielote                                        
   and SerieLoteMOV.id = @idGenerar                                        
   and SerieLoteMOV.modulo = 'INV'                                        
   UPDATE SerieLote                                        
   set Instruccion = isnull(SerieLote.Instruccion , a.instruccion),                                        
    Ubicacion2 = isnull(SerieLote.Ubicacion2, a.Ubicacion2),                                        
    Apartados = isnull(SerieLote.Apartados, a.Apartados),                                        
    Observaciones = isnull(SerieLote.Observaciones, a.Observaciones),                                        
    Furgon = isnull(SerieLote.Furgon, a.Furgon),                 
    MetrosLineales = isnull(SerieLote.MetrosLineales, a.MetrosLineales),                                        
    AnchoUtil = isnull(SerieLote.AnchoUtil, a.AnchoUtil),                                        
    Hojas = isnull(SerieLote.Hojas, a.Hojas),                                        
    Largo = isnull(SerieLote.Largo, a.Largo),                                        
    Propiedades = isnull(SerieLote.Propiedades, a.Propiedades) ,                
 TipoFSC = isnull(serielote.TipoFSC, a.TipoFSC),                
 CategoriaFSC = isnull(serielote.CategoriaFSC, a.CategoriaFSC),                
 ObservacionesFSC = isnull(serielote.ObservacionesFSC, a.ObservacionesFSC),           
 CategoriaPEFC = isnull(serielote.CategoriaPEFC, a.CategoriaPEFC),          
 CategoriaSFI = isnull(serielote.CategoriaSFI, a.CategoriaSFI),            
 OrdenCOmpra = isnull(serielote.OrdenCompra, a.OrdenCompra)                                                      
   FROM serieLoteMov a                                        
   WHERE  Serielote.Serielote = a.Serielote                                        
   AND a.Modulo = 'INV'                                        
   AND a.id = @idGenerar                                        
  END                                        
 END                                        
END                                         
IF @Modulo = 'PROD'                                        
BEGIN                                        
 UPDATE SerieLoteMov                                        
 SET largo = case when largo is null then instruccion else largo end                                        
 WHERE Modulo = 'PROD'                                        
   AND id = @id                                        
END                                        
------- actualizar el pedido de ventas para ver su origen                                    
DECLARE @Movprod  char(20),                                    
  @MovIDprod  varchar(20),                                    
  @DestinoIDc  int,                                    
        @EstatusProd char(15),                                    
  @DestinoTipo varchar(10),                                    
 @Destino  varchar(20),                                    
  @DestinoID  varchar(20)                                    
IF @Modulo = 'PROD'                    
BEGIN                                    
 SELECT @Movprod = Mov, @MovIdProd = Movid,  @EstatusProd = Estatus, @Empresa = Empresa, @Sucursal = prod.Sucursal,                                    
   @Destino = Destino, @DestinoID = DestinoID, @DestinoTipo = DestinoTipo                                    
 FROM Prod                                    
  INNER JOIN prodD On prod.Id = ProdD.id                         
 WHERE prod.id = @id                                    
 SELECT @DestinoIDc = id FROM Venta WHERE Mov = @Destino AND Movid = @DestinoID                               
 IF @Movprod = 'Orden Produccion' AND @EstatusProd ='PENDIENTE'                                     
 BEGIN                                    
  if not exists(select * from movflujo where Omodulo=@DestinoTipo and  OId=@DestinoIDc and DModulo='PROD' and DID=@id)                                   
  INSERT MovFLujo (Sucursal, Empresa,   Omodulo,     OId,         OMov,     OMovID,       DModulo, DID, Dmov,    DMovID, Cancelado)                                    
           SELECT @Sucursal, @Empresa, @DestinoTipo, @DestinoIDc, @Destino, @DestinoID, 'PROD', @id, @Movprod, @MovIdProd,0                                    
 END      
END                                        
----------------                 
 DECLARE @MovX  varchar(20),                                    
  @MovIDX  varchar(20)  ,                                  
 @estacionX int,                                  
 @clientex int,            
 @AlmacenX varchar(10)                                  
IF @Modulo = 'VTAS' AND @Accion in ('AFECTAR','AUTORIZAR')                                    
BEGIN                                    
    SELECT @MovX = Mov, @clientex = ISNULL(validarReservado,1), @AlmacenX = Venta.Almacen                   
    FROM venta inner join cte on venta.cliente = cte.cliente                                    
    WHERE ID = @ID                                  
    IF @MovX IN ('Pedido')  and ISNULL(@clientex,1) <> 0 AND @AlmacenX NOT IN ('ALM-REB')                                
    BEGIN                                     
      ---SELECT 'PASO'             
      SELECT @ESTACIONX = EstacionTrabajo FROM ReservaBobina WHERE Modulo='VTAS' AND ModuloID=@ID              
      EXEC spReservaBobinaHerramienta @ESTACIONX, 'VTAS', @ID, @USUARIO              
    END               
    IF @MovX IN ('Pedido')  and ISNULL(@clientex,1) <> 0 AND @AlmacenX IN ('ALM-REB')                                
    BEGIN                                     
      ---SELECT 'PASO'                  
      SELECT @ESTACIONX = EstacionTrabajo FROM ReservaRebobinado WHERE Modulo='VTAS' AND ModuloID=@ID             
      EXEC spReservaRebobinadoHerramienta @ESTACIONX, 'VTAS', @ID, @USUARIO               
    END                                   
END                                    
--- actualiza el id por si no ha sido grabado                    
IF @Modulo = 'VTAS'                    
BEGIN                    
 IF EXISTS(SELECT * FROM ReservaBobinaAuxiliar WHERE Movid is null)                    
  UPDATE ReservaBobinaAuxiliar                    
  SET movid = venta.movid                    
  FROM venta                    
  WHERE venta.id = ReservaBobinaAuxiliar.moduloid                    
  AND ReservaBobinaAuxiliar.Movid is null             
 IF EXISTS(SELECT * FROM ReservaRebobinadoAuxiliar WHERE Movid is null)                    
  UPDATE ReservaRebobinadoAuxiliar                    
  SET movid = venta.movid                    
  FROM venta                    
  WHERE venta.id = ReservaRebobinadoAuxiliar.moduloid                    
  AND ReservaRebobinadoAuxiliar.Movid is null                    
END                    
IF @Modulo = 'VTAS' AND @Accion in ('CANCELAR')                                    
BEGIN                                    
 SELECT @MOVX = MOV,@clientex = validarReservado, @AlmacenX = Venta.Almacen       from VENTA inner join cte on venta.cliente = cte.cliente                                   
    WHERE id = @id                                  
 IF @MovX IN ('Pedido')AND @AlmacenX NOT IN ('ALM-REB')                                  
 BEGIN                  
   SELECT @ESTACIONX = EstacionTrabajo  FROM ReservaBobina WHERE Modulo='VTAS' AND ModuloID=@ID                              
  EXEC spReservaBobinaHerramienta @ESTACIONX, 'VTAS', @ID, @USUARIO, 0, 1                                  
 eND                  
  IF @MovX IN ('Pedido')AND @AlmacenX IN ('ALM-REB')                                  
 BEGIN                                     
   SELECT @ESTACIONX = EstacionTrabajo  FROM ReservaRebobinado WHERE Modulo='VTAS' AND ModuloID=@ID            
  EXEC spReservaRebobinadoHerramienta @ESTACIONX, 'VTAS', @ID, @USUARIO, 0, 1                                  
 eND             
--- PARA BORRAR EN EL CASO DE QUE HAY SIDO ESCANEADA                  
DECLARE @RefScanner Varchar(100)                  
IF @Accion in ('CANCELAR')                                    
BEGIN                    
 IF @Modulo = 'VTAS'                  
  SELECT @RefScanner = REFERENCIA FROM Venta WHERE id = @id                    
 IF @Modulo = 'INV'                  
  SELECT @RefScanner = REFERENCIA FROM INV WHERE id = @id           
 DELETE FROM scannerCopia WHERE Referencia = @RefScanner                 
 DELETE FROM scanner WHERE Referencia = @RefScanner                  
END                  
END                                    
/*                                    
IF @Modulo = 'INV' AND @Accion in ('AFECTAR')                                    
BEGIN                               
    SELECT @MovX = Mov , @MovIDX = Movid FROM INV WHERE ID=@ID                                        
    IF @MovX IN ('Transferencia')                                    
 BEGIN                          
  UPDATE AuxiliarU set MovId = @MovIDX WHERE Modulo = @modulo and ModuloID = @id                                    
  UPDATE ReservaBobinaAuxiliar set MovId = @MovIDX WHERE Modulo = @modulo and ModuloID = @id                                    
 END                                    
END                                    
IF @Modulo = 'INV' AND @Accion in ('CANCELAR')                                    
BEGIN                                    
    SELECT @MovX = Mov , @MovIDX = Movid FROM INV WHERE ID=@ID                                        
    IF @MovX IN ('Transferencia')                                    
   EXEC spReservaBobinaHerramienta null, 'INV', @ID, @USUARIO, 0, 1                                  
END                                    
IF @Modulo = 'INV' AND @Accion in ('CANCELAR') AND @BASE IN ('Pendiente')                                    
BEGIN                                    
    SELECT @MovX = Mov , @MovIDX = Movid FROM INV WHERE ID=@ID                                        
    IF @MovX IN ('Orden Transferencia')                                    
 BEGIN                                     
  EXEC spReservaBobinaHerramienta null, 'INV', @ID, @USUARIO, 0, 0, 1                                  
 END                         
END                                    
  */                                  
  IF (SELECT Mov FROM Prod WHERE ID=@ID)=  'Ent X Rebobinacion'  
   BEGIN   
    EXEC spSLMovIntercartonRe @ID  
  END  
   DECLARE 
	--@Empresa	varchar(10),
--	@Mov		varchar(20),
	@DModulo	varchar(20), 
	@DMov		varchar(20),
	@DID		varchar(20),
	--@Sucursal	int,
	@Estatus    varchar(20),
	@Timbrado	bit
/*CFDI Cancelacion*/
	SELECT @Timbrado=Timbrado  FROM CFD WHERE Modulo = @Modulo AND ModuloID = @ID
	IF @Accion = 'CANCELAR' AND @Timbrado=1
	BEGIN	
	  EXEC spMovInfo @ID, @Modulo, @Estatus=@Estatus OUTPUT, @Sucursal=@Sucursal OUTPUT, @Empresa = @Empresa OUTPUT
	  IF @Estatus = 'CANCELADO' 
	  IF EXISTS(SELECT ModuloID FROM CFD WHERE Modulo = @Modulo AND ModuloID = @ID AND (UUID IS NOT NULL OR SelloSAT IS NOT NULL))
         AND (SELECT TimbrarCFDIServidor FROM EmpresaCFD WHERE Empresa = @Empresa) IN (SELECT * FROM dbo.fnIntelisisCFDIListaPAC(@Empresa))
	       EXEC spCFDICancelacion @Modulo, @ID, @Estatus, @Empresa, @Sucursal, @Ok OUTPUT, @okref OUTPUT

	END
 /*CFDI Cancelacion*/	
    EXEC spMovInfo    @ID, @Modulo , @Empresa = @Empresa OUTPUT, @Mov=@Mov OUTPUT                                
RETURN                                              
END 


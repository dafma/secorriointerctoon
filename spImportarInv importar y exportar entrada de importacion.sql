
ALTER  PROCEDURE [dbo].[spImportarInv]--PRUEBA       
   @Estacion  int,        
   @Empresa char(5),        
   @Modulo  char(5),        
   @ID  int,        
            @Sucursal int        
        
AS BEGIN        
        
  DECLARE        
    @a   float,        
    @Mov  char(20),        
    @Cliente  char(10),        
    @Proveedor  char(10),        
    @Clave  char(255),        
    @PrimerAplica char(20),        
    @PrimerAplicaID varchar(20),        
    @Aplica  char(20),        
    @AplicaID  varchar(20),        
    @ArtTipo  char(20),        
    @Articulo  char(20),        
    @Cantidad  float,        
    @SerieLote  varchar(50),        
    @CantidadSerieLote float,        
    @Renglon  float,        
    @RenglonID  int,        
    @Almacen  char(10),        
    @FechaRequerida datetime,        
    @FechaEntrega datetime,        
    @Costo         money,        
    @Precio  float,        
    @Impuesto1  float,        
    @Impuesto2  float,        
    @Impuesto3  money,        
    @ZonaImpuesto varchar(50),         
    @DescuentoTipo char(1),        
    @DescuentoLinea money,        
    @DescripcionExtra varchar(100),        
    @FechaEmision datetime,        
    @Usuario  char(10),        
        
    @Concepto  varchar(50),        
    @Proyecto  varchar(50),        
    @Moneda    char(10),        
    @TipoCambio  float,        
    @Referencia  varchar(50),        
    @Observaciones  varchar(100),        
    @FormaEnvio  varchar(50),        
    @Condicion   varchar(50),        
    @Vencimiento datetime,        
    @Descuento  varchar(30),        
    @DescuentoGlobal  float,        
    @SobrePrecio float,        
    @CfgCompraCostoSugerido char(20),        
    @CfgTipoCosteo varchar(20),        
    @Ok   int,        
    @OkRef  varchar(255)        
--------------        
    ,@Texto  varchar(255),        
    @MiArticulo  char(20),        
    @MiSubcuenta    char(20),        
    @MiTipoOpcion   char(20),        
    @Mipedimento    char(20),        
    @MiCantidad     float,        
    @Separador     char(1),        
    @Ubicacion2     char(5),        
    @Apartados     char(50),        
    @Observaciones2 char(200),        
    @Furgon         char(50),        
 @MetrosLineales float,        
 @AnchoUtil     float,        
 @Hojas         float,        
 @Largo         float,        
 @MiRenglonID int,        
    @MiRenglonIDaux int,        
    @MiCantidadxSyL int,        
    @MiAlmacenI varchar(10),        
    @AlmacenImp varchar(10),        
    @MiProveedor char(10),        
    @MiInstruccion char(50),        
    @MovTipo       char(20) ,       
 @TipoFSC   varchar(50),      
 @CategoriaFSC  varchar(50),      
 @ObservacionesFSC varchar(500),  
 @CategoriaPEFC  varchar(50),        
 @CategoriaSFI  varchar(50),     
 @OrdenCompraFSC varchar(20) ,
 @FechaApartado  datetime   
    
    SET NOCOUNT ON;    

    SELECT @Separador = char(9) -- Tabulador        
---------------        
        
    SELECT @CfgCompraCostoSugerido = CompraCostoSugerido, @CfgTipoCosteo = TipoCosteo FROM EmpresaCfg WHERE Empresa = @Empresa        
        
    SELECT @Ok = NULL, @OkRef = NULL,@MiSubcuenta ='',@MiCantidad=0,         
           @Aplica = NULL, @AplicaID = NULL, @PrimerAplica = NULL, @PrimerAplicaID = NULL,         
           @ArtTipo = NULL, @Articulo = NULL, @Cantidad = NULL, @SerieLote = NULL, @CantidadSerieLote = NULL,        
           @Almacen = NULL, @FechaRequerida = NULL, @FechaEntrega = NULL,         
           @Renglon = 2048, @RenglonID = 1,        
           @Concepto = NULL, @Proyecto = NULL, @Moneda = NULL, @TipoCambio = NULL, @Referencia = NULL, @Observaciones = NULL,         
           @FormaEnvio = NULL, @Condicion = NULL, @Vencimiento = NULL, @Descuento = NULL, @DescuentoGlobal = NULL, @SobrePrecio = NULL,        
           @Cliente = NULL, @Proveedor = NULL, @FechaEmision = GETDATE(), @ZonaImpuesto = NULL,      
           @TipoFSC = null,@CategoriaFSC = null, @ObservacionesFSC=null, @CategoriaPEFC = null, @CategoriaSFI = null, @OrdenCompraFSC = null     
        

        
    EXEC spExtraerFecha @FechaEmision OUTPUT                
    IF @Modulo = 'COMS' DELETE CompraD WHERE ID = @ID ELSE        
    IF @Modulo = 'INV'  DELETE InvD    WHERE ID = @ID        


        
    DELETE SerieLoteMov         
    WHERE Empresa = @Empresa AND Modulo = @Modulo AND ID = @ID        
        
    IF @Modulo = 'COMS'         
    BEGIN        
    SELECT @Mov = Mov, @Moneda = Moneda, @TipoCambio = TipoCambio, @Usuario = Usuario, @Almacen = Almacen, @ZonaImpuesto = ZonaImpuesto, @Proveedor = Proveedor, @FechaRequerida = FechaRequerida, @FechaEntrega = FechaEntrega FROM Compra WHERE ID = @ID    
 

  
    
    SELECT @MovTipo=clave FROM MovTipo WHERE Mov=@Mov --NEW        
    END        
    ELSE        
    IF @Modulo = 'INV'  SELECT @Mov = Mov, @Moneda = Moneda, @TipoCambio = TipoCambio, @Usuario = Usuario, @Almacen = Almacen FROM Inv    WHERE ID = @ID         
            
     --------        
     DECLARE crImportarIC CURSOR FOR        
      SELECT RTRIM(LTRIM(Clave))        
        FROM ICImportarInv        
       WHERE Estacion = @Estacion        
     
	 OPEN crImportarIC        
      FETCH NEXT FROM crImportarIC INTO @Texto        
        WHILE @@FETCH_STATUS = 0        
         BEGIN        
        
            IF @Modulo = 'COMS'         
            BEGIN                 
				EXEC spExtraerDato @Texto OUTPUT, @MiArticulo OUTPUT, @Separador        
				--        
				EXEC spExtraerDato @Texto OUTPUT, @AlmacenImp OUTPUT, @Separador        
				EXEC spExtraerDato @Texto OUTPUT, @MiInstruccion OUTPUT, @Separador        
				EXEC spExtraerDato @Texto OUTPUT, @MiProveedor OUTPUT, @Separador        
				--        
				EXEC spExtraerDato @Texto OUTPUT, @SerieLote OUTPUT, @Separador        
				EXEC spExtraerDato @Texto OUTPUT, @Cantidad OUTPUT, @Separador        
				EXEC spExtraerDato @Texto OUTPUT, @MiPedimento OUTPUT, @Separador        
				EXEC spExtraerDato @Texto OUTPUT, @MetrosLineales OUTPUT, @Separador        
				EXEC spExtraerDato @Texto OUTPUT, @Furgon OUTPUT, @Separador   
				EXEC spExtraerDato @Texto OUTPUT, @Ubicacion2 OUTPUT, @Separador      
				EXEC spExtraerDato @Texto OUTPUT, @Apartados OUTPUT, @Separador        
                EXEC spExtraerDato @Texto OUTPUT, @FechaApartado OUTPUT, @Separador 
   				EXEC spExtraerDato @Texto OUTPUT, @AnchoUtil OUTPUT, @Separador        
				EXEC spExtraerDato @Texto OUTPUT, @Hojas OUTPUT, @Separador        
			   -- EXEC spExtraerDato @Texto OUTPUT, @Largo OUTPUT, @Separador        
			    EXEC spExtraerDato @Texto OUTPUT, @Observaciones OUTPUT, @Separador        
    ---EXEC spExtraerDato @Texto OUTPUT, @MiSubcuenta OUTPUT, @Separador        
    ---- cambio con la norma FSC      
				EXEC spExtraerDato @Texto OUTPUT, @TipoFSC OUTPUT, @Separador        
				EXEC spExtraerDato @Texto OUTPUT, @CategoriaFSC OUTPUT, @Separador        
				EXEC spExtraerDato @Texto OUTPUT, @ObservacionesFSC OUTPUT, @Separador        
				EXEC spExtraerDato @Texto OUTPUT, @CategoriaPEFC OUTPUT, @Separador         
				EXEC spExtraerDato @Texto OUTPUT, @CategoriaSFI OUTPUT, @Separador   
				EXEC spExtraerDato @Texto OUTPUT, @OrdenCompraFSC OUTPUT, @Separador     
        
   
        
            END        
            ELSE IF @Modulo = 'INV'        
            BEGIN         
                EXEC spExtraerDato @Texto OUTPUT, @MiArticulo OUTPUT, @Separador        
--        
                EXEC spExtraerDato @Texto OUTPUT, @AlmacenImp OUTPUT, @Separador        
--        
                EXEC spExtraerDato @Texto OUTPUT, @SerieLote OUTPUT, @Separador        
                EXEC spExtraerDato @Texto OUTPUT, @MiSubcuenta OUTPUT, @Separador      
            END        
        
		--NEW        
		IF @Modulo = 'COMS' AND NOT EXISTS(SELECT * FROM Prov WHERE  Proveedor =@MiProveedor )--Verificar Existencia de Prov        
		BEGIN        
            SELECT         
            @Ok = 1,         
            @OkRef = 'No Existe el Provedor Importado: '+RTRIM(@MiProveedor)        
            SET @MiProveedor=' '        
            RAISERROR(@OkRef,16,-1)           
        END        
        
		IF @Modulo = 'INV' AND NOT EXISTS(SELECT * FROM SerieLoteMov WHERE  SerieLote =@SerieLote )--Verificar Existencia de @SerieLote        
		BEGIN        

            SELECT         
            @Ok = 1,         
            @OkRef = 'No Existe la serie/Lote Importada: '+RTRIM(@SerieLote)        
            SET @SerieLote=' '        
            RAISERROR(@OkRef,16,-1)           
        END        
--NEW        
        
		IF NOT EXISTS(SELECT * FROM Alm WHERE  Almacen =@AlmacenImp )--Verificar Existencia de Almacén        
		BEGIN        
            SELECT         
            @Ok = 1,         
            @OkRef = 'No Existe el Almacén Importado: '+RTRIM(@AlmacenImp)        
            RAISERROR(@OkRef,16,-1)           
        END        
		ELSE        
		BEGIN----ALMACEN        
        
   
		   SELECT @ArtTipo = NULL, @Articulo = NULL  
		   SET @Articulo = @MiArticulo        
           SELECT @ArtTipo = Tipo FROM Art WHERE Articulo =UPPER(@Articulo)    

    
--SELECT @Articulo,@MiArticulo,@SerieLote
    
        
   IF @Articulo IS NOT NULL  -- Cantidad        
   BEGIN-------0        
        
            SELECT @MiTipoOpcion=TipoOpcion FROM Art WHERE Articulo = @Articulo        
            IF(@MiTipoOpcion='Si' AND ISNULL(@MiSubcuenta,'')='')        
            BEGIN        
                  SELECT         
                  @Ok = 1,         
                  @OkRef = 'Es necesario especificar en el archivo de texto la Opción del Articulo: '+RTRIM(@MiArticulo)        
                  RAISERROR(@OkRef,16,-1)           
            END        
                
            IF @@FETCH_STATUS = 0 --IF ISNUMERIC(@MiArticulo) = 1 SELECT @Cantidad = CONVERT(float, @MiArticulo) ELSE SELECT @Cantidad = NULL        
             IF @@Error <> 0 SELECT @Ok = 1        
              IF @ArtTipo IN ('SERIE', 'LOTE', 'VIN')        
              BEGIN        
               IF(@Modulo = 'INV')        
                 BEGIN        
                 IF EXISTS(SELECT * FROM SerieLote WHERE SerieLote = @SerieLote)        
                    BEGIN        

    
---------        
     DECLARE        
   @MUbicacion2 Varchar(5),        
   @MApartados     Varchar(50),   
   @MFechaApartado  DateTime,  
   @MObservaciones Varchar(200),        
   @MFurgon     Varchar(50),        
   @MMetrosLineales float,        
   @MAnchoUtil float,        
   @MHojas float,        
   @MLargo float,        
   @Mpedimento  char(20),        
   @MInstruccion char(50)        
   ---------        


      
     IF(@MiTipoOpcion='Si')        
          BEGIN        
        
    SELECT @MUbicacion2=Ubicacion2,@MApartados=Apartados,@MFechaApartado=FechaApartado,       
           @MObservaciones=Observaciones,@MFurgon=Furgon,        
		   @MMetrosLineales=MetrosLineales,        
		   @MAnchoUtil=AnchoUtil,@MHojas=Hojas,@MLargo=@Largo,        
		   @Mpedimento=Propiedades,           
		   @MInstruccion=Instruccion,      
		   @TipoFSC = TipoFSC,
		   @CategoriaFSC = CategoriaFSC, 
		   @ObservacionesFSC=ObservacionesFSC,
		   @CategoriaPEFC = CategoriaPEFC,
		   @CategoriaSFI = CategoriaSFI, 
		   @OrdenCompraFSC = OrdenCompra        
      FROM SerieLoteMov 
	 WHERE Empresa =@Empresa 
	   AND Articulo =@Articulo        
       AND SubCuenta=@MiSubCuenta 
	   AND SerieLote =@SerieLote       

	   
    SELECT @MiCantidad=ISNULL(SUM(Existencia), 0.0)        
      FROM SerieLote 
	 WHERE Empresa =@Empresa 
	   AND Articulo =@Articulo        
       AND SubCuenta=@MiSubCuenta 
	   AND SerieLote =@SerieLote 
	   AND Almacen =@AlmacenImp    

                                 
        
--INI AGRUPACION INV        
            IF ( @ArtTipo = 'SERIE')        
               BEGIN        


--NEW S    
    IF NOT EXISTS(SELECT * FROM InvD WHERE  ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp)        
    --NEW S                               
      INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,Ubicacion2,Apartados,Observaciones,Furgon,MetrosLineales,AnchoUtil,Hojas,Largo,Propiedades,Instruccion, TipoFSC,CategoriaFSC,ObservacionesFSC,CategoriaPEFC,CategoriaSFI, OrdenCompra,FechaApartado)       
      VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,@MiSubCuenta, @SerieLote,@MiCantidad,@MUbicacion2,@MApartados,@MObservaciones,@MFurgon,@MMetrosLineales,@MAnchoUtil,@MHojas,@MLargo,@MPedimento,@MInstruccion, @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@MFechaApartado)                     
                                               
             --@MiCantidad,@MUbicacion2,@MApartados,@MObservaciones,@MFurgon,@MMetrosLineales,@MAnchoUtil,@MHojas,@MLargo,@MPedimento,@MInstruccion                     
--NEW S        
    ELSE        
    BEGIN        
     SELECT @MiRenglonID=RenglonID FROM InvD WHERE  ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp        
     SELECT @MiAlmacenI=Almacen FROM InvD WHERE ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND RenglonID=@MiRenglonID        
     --insert into val values(@MiRenglonIDaux,@Articulo,@AlmacenImp)        
     --insert into val values(100,@MiAlmacenI,@AlmacenImp)        
    IF(@MiAlmacenI=@AlmacenImp)        
BEGIN        
         SELECT @MiRenglonID=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
         
		 INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,
		                      MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion ,       
                              TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado  )        
         VALUES (@Sucursal, @Empresa, @Modulo, @ID,@MiRenglonID, @Articulo,@MiSubCuenta,@SerieLote,        
                 @MiCantidad,@MMetrosLineales,@MFurgon,@MApartados,@MUbicacion2,@MAnchoUtil,@MHojas,@MLargo,@MObservaciones,@MPedimento,@MInstruccion,        
                 @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@MFechaApartado)        
      END        
     ELSE        
     BEGIN        
              INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
                                   MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,       
                                   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado)        
              VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,@MiSubCuenta, @SerieLote,        
                      @MiCantidad,@MMetrosLineales,@MFurgon,@MApartados,@MUbicacion2,@MAnchoUtil,@MHojas,@MLargo,@MObservaciones,@MPedimento,@MInstruccion ,      
                      @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@MFechaApartado)        
     END        
   END        
--NEW S        
           END        
           ELSE IF (@ArtTipo = 'LOTE')        
           BEGIN        
--NEW        
    IF NOT EXISTS(SELECT * FROM InvD WHERE  ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp)        
--NEW        
     INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
                          MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion,       
                          TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado)        
       VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,@MiSubCuenta, @SerieLote,        
               @MiCantidad,@MMetrosLineales,@MFurgon,@MApartados,@MUbicacion2,@MAnchoUtil,@MHojas,@MLargo,@MObservaciones,@MPedimento,@MInstruccion ,      
               @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@MFechaApartado)        
--NEW        
   ELSE        
  BEGIN        
  SELECT @MiRenglonID=RenglonID FROM InvD WHERE  ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp        
  SELECT @MiAlmacenI=Almacen FROM InvD WHERE ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND RenglonID=@MiRenglonID        
  IF(@MiAlmacenI=@AlmacenImp)        
    BEGIN        
      
        
    SELECT @MiRenglonID=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
    
	INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
                         MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion,       
                         TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado)        
    VALUES (@Sucursal, @Empresa, @Modulo, @ID,@MiRenglonID, @Articulo,@MiSubCuenta,@SerieLote,         
            @MiCantidad,@MMetrosLineales,@MFurgon,@MApartados,@MUbicacion2,@MAnchoUtil,@MHojas,@MLargo,@MObservaciones,@MPedimento,@MInstruccion,      
            @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@MFechaApartado)       
                                           
  END        
  ELSE        
  BEGIN        
           INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
                                MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
                                TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado)        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,@MiSubCuenta, @SerieLote,        
                   @MiCantidad,@MMetrosLineales,@MFurgon,@MApartados,@MUbicacion2,@MAnchoUtil,@MHojas,@MLargo,@MObservaciones,@MPedimento,@MInstruccion ,      
                   @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@MFechaApartado)        
  END        
END        
--NEW        
                                 END        
                                --INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,Ubicacion2,Apartados,Observaciones,Furgon,MetrosLineales,AnchoUtil,Hojas,Largo,Instruccion)        
                                --VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,@MiSubcuenta, @SerieLote, @MiCantidad,@MUbicacion2,@MApartados,@MObservaciones,@MFurgon,@MMetrosLineales,@MAnchoUtil,@MHojas,@MLargo,@MInstruccion)        




 
--FIN AGRUPACION INV                          
                              END        
                         ELSE         ----------NO TIENE OPCIONES.........................        
                              BEGIN        
      
      
  -----GMO    
        
        SELECT @MUbicacion2=Ubicacion2,@MApartados=Apartados,@MFechaApartado=FechaApartado,        
        @MObservaciones=Observaciones,@MFurgon=Furgon,        
        @MMetrosLineales=MetrosLineales,        
        @MAnchoUtil=AnchoUtil,@MHojas=Hojas,@MLargo=@Largo,@MInstruccion=Instruccion  ,      
        @TipoFSC=TipoFSC,@CategoriaFSC=CategoriaFSC, @ObservacionesFSC=ObservacionesFSC, @CategoriaPEFC=CategoriaPEFC, @CategoriaSFI=CategoriaSFI, @OrdenCompraFSC=OrdenCompra      
        FROM SerieLoteMov WHERE Empresa =@Empresa AND Articulo =@Articulo        
        AND SerieLote =@SerieLote        
      
        SELECT @MiCantidad=ISNULL(SUM(Existencia), 0.0)        
        FROM SerieLote WHERE Empresa =@Empresa AND Articulo =@Articulo        
        AND SerieLote =@SerieLote AND Almacen =@AlmacenImp        
        
                               --INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,Ubicacion2,Apartados,Observaciones,Furgon,MetrosLineales,AnchoUtil,Hojas,Largo,Instruccion)        
                               --VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo, '', @SerieLote,@MiCantidad,@MUbicacion2,@MApartados,@MObservaciones,@MFurgon,@MMetrosLineales,@MAnchoUtil,@MHojas,@MLargo,@MInstruccion)         
        
--------INI AGRUPA INV        
IF ( @ArtTipo = 'SERIE')        
                                   BEGIN         
--NEW S        
IF NOT EXISTS(SELECT * FROM InvD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp )        
--NEW S        
begin      
                                   INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado       
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID,         
                                   @Articulo,'', @SerieLote, @MiCantidad,@MMetrosLineales,@MFurgon,@MApartados,@MUbicacion2,@MAnchoUtil,@MHojas,@MLargo,@Observaciones,@MPedimento,@MInstruccion,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@MFechaApartado         
                                  --@Articulo, '', @SerieLote,@MiCantidad,@MUbicacion2,@MApartados,@MObservaciones,@MFurgon,@MMetrosLineales,@MAnchoUtil,@MHojas,@MLargo,@MInstruccion        
             )        
      
      
end      
      
---NEW S                     
ELSE        
BEGIN        
      
      
      
  SELECT @MiRenglonIDaux=RenglonID FROM InvD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
  SELECT @MiAlmacenI=Almacen FROM InvD WHERE ID = @ID AND Articulo=@Articulo AND  RenglonID=@MiRenglonIDaux        
  IF(@MiAlmacenI=@AlmacenImp)        
    BEGIN        
                                   



SELECT @MiRenglonID=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
           
		   INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,        
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
           TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado       
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID,@MiRenglonID,         
                                   @Articulo, '', @SerieLote,@MiCantidad,        
                                   @MMetrosLineales,@MFurgon,@MApartados,@MUbicacion2,@MAnchoUtil,@MHojas,@MLargo,@MObservaciones,@MPedimento,@MInstruccion  ,      
        @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@MFechaApartado      
                                   )        
    END        
    ELSE-------? INSERCION NUEVA        
    BEGIN        
                                   INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,       
   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado       
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID,        
                                   @Articulo, '', @SerieLote,@MiCantidad,        
                                   @MMetrosLineales,@MFurgon,@MApartados,@MUbicacion2,@MAnchoUtil,@MHojas,@MLargo,@MObservaciones,@MPedimento,@MInstruccion  ,      
     @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@MFechaApartado       
                                   )        
    END        
END        
--NEW S        
        
                                   END        
                                   ELSE IF (@ArtTipo = 'LOTE')        
                                   BEGIN        
                                           
--NEW        
IF NOT EXISTS(SELECT * FROM InvD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp )        
--NEW        
begin        
                                   INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado      
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID,        
                                   @Articulo, '', @SerieLote,@MiCantidad,        
                                   @MMetrosLineales,@MFurgon,@MApartados,@MUbicacion2,@MAnchoUtil,@MHojas,@MLargo,@MObservaciones,@MPedimento,@MInstruccion  ,      
         @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC ,@MFechaApartado      
         
                                )        
      
--select @SerieLote      
end        
---NEW        
                     
ELSE        
BEGIN        
    


  SELECT @MiRenglonIDaux=RenglonID FROM InvD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
  SELECT @MiAlmacenI=Almacen FROM InvD WHERE ID = @ID AND Articulo=@Articulo AND  RenglonID=@MiRenglonIDaux        
  IF(@MiAlmacenI=@AlmacenImp)        
    BEGIN        
         
                                   SELECT @MiRenglonID=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp  
								   
           INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado       
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID,@MiRenglonIDAux,        
                                   @Articulo, '', @SerieLote,@MiCantidad,        
                                   @MMetrosLineales,@MFurgon,@MApartados,@MUbicacion2,@MAnchoUtil,@MHojas,@MLargo,@MObservaciones,@MPedimento,@MInstruccion  ,      
         @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@MFechaApartado       
                                   )        
    END        
    ELSE-------? INSERCION NUEVA        
    BEGIN        
                                   INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado      
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID,        
                                   @Articulo, '', @SerieLote,@MiCantidad,        
                                   @MMetrosLineales,@MFurgon,@MApartados,@MUbicacion2,@MAnchoUtil,@MHojas,@MLargo,@MObservaciones,@MPedimento,@MInstruccion  ,      
         @TipoFSC,@CategoriaFSC, @ObservacionesFSC , @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@MFechaApartado      
                                   )        
    END        
END        
--NEW                                          
                                  END        
--------FIN AGRUPA INV        
         END        
                    END        
                 ELSE        
                     BEGIN        
                      IF(@MiTipoOpcion='Si')        
                          BEGIN        
                               INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad, TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra )        
                               VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,@MiSubcuenta, @SerieLote,0, @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC )--PQ NO EXISTE          
                          END        
                      ELSE        
                BEGIN        
                               INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad, TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra )        
                               VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo, '', @SerieLote,0, @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC )--PQ         
                          END           
                     END        
                 END         
               ELSE        
               IF(@Modulo = 'COMS')        
               BEGIN         
               SELECT @a = 0        
               WHILE @a < @Cantidad AND @Ok IS NULL        
                BEGIN        
                     IF @@Error <> 0 SELECT @Ok = 1          
                         -- Cantidad         
                         SELECT @CantidadSerieLote = @Cantidad        
                             
                       IF @Ok IS NULL        
      BEGIN         
        IF(@MiTipoOpcion='Si')        
              BEGIN         
                                   IF ( @ArtTipo = 'SERIE')        
                                   BEGIN        
        
--NEW S        
IF NOT EXISTS(SELECT * FROM CompraD WHERE  ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp)        
--NEW S         
           INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado       
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,@MiSubCuenta, @SerieLote, @CantidadSerieLote,        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC ,@FechaApartado      
             )        
--NEW S        
ELSE        
BEGIN        
SELECT @MiRenglonID=RenglonID FROM CompraD WHERE  ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp        
SELECT @MiAlmacenI=Almacen FROM CompraD WHERE ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND RenglonID=@MiRenglonID        
--insert into val values(@MiRenglonIDaux,@Articulo,@AlmacenImp)        
--insert into val values(100,@MiAlmacenI,@AlmacenImp)        
IF(@MiAlmacenI=@AlmacenImp)        
  BEGIN        
                                   SELECT @MiRenglonID=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
           INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,       
   TipoFSC,CategoriaFSC, ObservacionesFSC , CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado      
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID,@MiRenglonID, @Articulo,@MiSubCuenta,@SerieLote, @CantidadSerieLote,--CAMBIO        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC , @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@FechaApartado      
                                   )        
  END        
  ELSE        
  BEGIN        
                                   INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion ,       
   TipoFSC,CategoriaFSC, ObservacionesFSC , CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado       
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,@MiSubCuenta, @SerieLote, @CantidadSerieLote,--        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC , @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@FechaApartado    
             )        
  END        
END        
--NEW S        
        
                                   END        
                                   ELSE IF (@ArtTipo = 'LOTE')        
                                   BEGIN        
        IF EXISTS(SELECT * FROM SERIELOTEPROP WHERE Propiedades = @MiPedimento)        
                                   BEGIN        
        
--NEW        
IF NOT EXISTS(SELECT * FROM CompraD WHERE  ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp)        
--NEW        
                                   INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado       
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,@MiSubCuenta, @SerieLote, @CantidadSerieLote,        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@FechaApartado       
             )        
--NEW        
ELSE        
BEGIN        
SELECT @MiRenglonID=RenglonID FROM CompraD WHERE  ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp        
SELECT @MiAlmacenI=Almacen FROM CompraD WHERE ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND RenglonID=@MiRenglonID        
IF(@MiAlmacenI=@AlmacenImp)        
  BEGIN        
                                   SELECT @MiRenglonID=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
           INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
   TipoFSC,CategoriaFSC, ObservacionesFSC , CategoriaPEFC, CategoriaSFI, OrdenCompra ,FechaApartado     
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID,@MiRenglonID, @Articulo,@MiSubCuenta,@SerieLote, @CantidadSerieLote,--CAMBIO        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@FechaApartado      
                                   )        
  END        
  ELSE        
  BEGIN        
                INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado       
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,@MiSubCuenta, @SerieLote, @CantidadSerieLote,--        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@FechaApartado       
             )        
  END        
END        
--NEW        
                                   END        
                                   ELSE        
    BEGIN        
                                   SELECT @Ok = 1,         
           @OkRef = 'No Existe el Pedimento: '+RTRIM(@MiPedimento)        
           RAISERROR(@OkRef,16,-1)        
                                   END        
                                   END        
                                END        
        ELSE------------NO TIENE OPCIONES        
        BEGIN        
                                   IF ( @ArtTipo = 'SERIE')        
                                   BEGIN         
--NEW S        
IF NOT EXISTS(SELECT * FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp )        
--NEW S        
                                   INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion,      
   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado         
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,'', @SerieLote, @CantidadSerieLote,        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@FechaApartado       
             )        
---NEW S                     
ELSE        
BEGIN        
  SELECT @MiRenglonIDaux=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
  SELECT @MiAlmacenI=Almacen FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND  RenglonID=@MiRenglonIDaux        
  IF(@MiAlmacenI=@AlmacenImp)        
    BEGIN        
                                   SELECT @MiRenglonID=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
           INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado       
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID,@MiRenglonID, @Articulo,'',@SerieLote, @CantidadSerieLote,--CAMBIO        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@FechaApartado       
                                   )        
    END        
    ELSE-------? INSERCION NUEVA        
    BEGIN        
                                   INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
 TipoFSC,CategoriaFSC, ObservacionesFSC , CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado      
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,'',@SerieLote, @CantidadSerieLote,        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@FechaApartado       
                                   )        
    END        
END        
--NEW S        
        
        
                                   END        
                                   ELSE IF (@ArtTipo = 'LOTE')        
                                   BEGIN        
                                   IF EXISTS(SELECT * FROM SERIELOTEPROP WHERE Propiedades = @MiPedimento)        
                                   BEGIN        
--NEW        
IF NOT EXISTS(SELECT * FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp )        
--NEW        
                                   INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,       
   TipoFSC,CategoriaFSC, ObservacionesFSC, CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado       
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,'',@SerieLote, @CantidadSerieLote,        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC , @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@FechaApartado      
                                   )        
---NEW                     
ELSE        
BEGIN        
  SELECT @MiRenglonIDaux=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
  SELECT @MiAlmacenI=Almacen FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND  RenglonID=@MiRenglonIDaux        
  IF(@MiAlmacenI=@AlmacenImp)        
    BEGIN        
      SELECT @MiRenglonID=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
           INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,      
   TipoFSC,CategoriaFSC, ObservacionesFSC , CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado      
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID,@MiRenglonID, @Articulo,'',@SerieLote, @CantidadSerieLote,--CAMBIO        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
  @TipoFSC,@CategoriaFSC, @ObservacionesFSC, @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@FechaApartado       
                                   )        
    END        
    ELSE-------? INSERCION NUEVA        
    BEGIN        
                                   INSERT SerieLoteMov (Sucursal, Empresa, Modulo, ID, RenglonID, Articulo, SubCuenta, SerieLote, Cantidad,          
           MetrosLineales,Furgon,Apartados,Ubicacion2,AnchoUtil,Hojas,Largo,Observaciones,Propiedades,Instruccion  ,       
   TipoFSC,CategoriaFSC, ObservacionesFSC , CategoriaPEFC, CategoriaSFI, OrdenCompra,FechaApartado      
              )        
           VALUES (@Sucursal, @Empresa, @Modulo, @ID, @RenglonID, @Articulo,'',@SerieLote, @CantidadSerieLote,        
           @MetrosLineales,@Furgon,@Apartados,@Ubicacion2,@AnchoUtil,@Hojas,@Largo,@Observaciones,@MiPedimento,@MiInstruccion  ,      
   @TipoFSC,@CategoriaFSC, @ObservacionesFSC , @CategoriaPEFC, @CategoriaSFI, @OrdenCompraFSC,@FechaApartado      
                                   )        
    END        
END        
--NEW        
                                 END        
                                   ELSE        
                                   BEGIN        
                                   SELECT @Ok = 1,         
           @OkRef = 'No Existe el Pedimento: '+RTRIM(@MiPedimento)        
           RAISERROR(@OkRef,16,-1)        
                                   END        
                                   END        
        END           
                        END                                  
                       SELECT @a = @a + @CantidadSerieLote        
        
             END--WHILE        
               END--IF MOD        
           END--        
        
                
            IF @Ok IS NULL  -- Insertar el Detalle        
              BEGIN---1        
              SELECT @Costo = NULL, @Precio = NULL, @Impuesto1 = NULL, @Impuesto2 = NULL, @Impuesto3 = NULL, @DescuentoTipo = NULL, @DescuentoLinea = NULL, @DescripcionExtra = NULL        
               IF @Aplica IS NOT NULL AND @AplicaID IS NOT NULL        
               BEGIN        
        
                  IF @Modulo = 'COMS'         
                     SELECT @Almacen = d.Almacen, @FechaRequerida = d.FechaRequerida, @FechaEntrega = d.FechaEntrega, @Costo = d.Costo,        
                          @Impuesto1 = d.Impuesto1, @Impuesto2 = d.Impuesto2, @Impuesto3 = d.Impuesto3, @DescuentoTipo = d.DescuentoTipo, @DescuentoLinea = d.DescuentoLinea, @DescripcionExtra = d.DescripcionExtra        
                     FROM Compra e, CompraD d       
                     WHERE e.ID = d.ID AND e.Empresa = @Empresa AND e.Mov = @Aplica AND e.MovID = @AplicaID AND e.Estatus NOT IN ('SINAFECTAR', 'CANCELADO') AND d.Articulo = @Articulo         
        
                   ELSE        
                   IF @Modulo = 'INV'         
                     SELECT @Almacen = d.Almacen, @Costo = d.Costo        
                     FROM Inv e, InvD d        
                     WHERE e.ID = d.ID AND e.Empresa = @Empresa AND e.Mov = @Aplica AND e.MovID = @AplicaID AND e.Estatus NOT IN ('SINAFECTAR', 'CANCELADO') AND d.Articulo = @Articulo         
               END         
               ELSE         
               BEGIN        
                SELECT @Aplica = NULL, @AplicaID = NULL        
        
                IF @Modulo = 'COMS'        
          EXEC spVerCosto @Sucursal, @Empresa, @Proveedor, @Articulo, NULL, NULL, @CfgCompraCostoSugerido, @Moneda, @TipoCambio, @Costo OUTPUT, 0        
                ELSE         
          EXEC spVerCosto @Sucursal, @Empresa, @Proveedor, @Articulo, NULL, NULL, @CfgTipoCosteo, @Moneda, @TipoCambio, @Costo OUTPUT, 0        
                SELECT @Impuesto1 = Impuesto1, @Impuesto2 = Impuesto2, @Impuesto3 = Impuesto3 FROM Art WHERE Articulo = @Articulo        
        
               END        
        
                 EXEC spZonaImp @ZonaImpuesto, @Impuesto1 OUTPUT        
                 EXEC spZonaImp @ZonaImpuesto, @Impuesto2 OUTPUT        
                 EXEC spZonaImp @ZonaImpuesto, @Impuesto3 OUTPUT        
        
        
                  IF @Modulo = 'COMS'         
                         
                       IF(@MiTipoOpcion='Si')        
                       BEGIN        
--NEW        
IF NOT EXISTS(SELECT * FROM CompraD WHERE ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp)        
--NEW        
      BEGIN        
           IF(@MovTipo='COMS.EI')        
                          INSERT CompraD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo,SubCuenta, Cantidad, DescripcionExtra, Almacen, FechaRequerida, FechaEntrega, Costo, Impuesto1, Impuesto2, Impuesto3, DescuentoTipo, DescuentoLinea,ImportacionProveedor)        
                          VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo,@MiSubCuenta, @Cantidad, @DescripcionExtra,@AlmacenImp, @FechaRequerida, @FechaEntrega, @Costo, @Impuesto1, @Impuesto2, @Impuesto3, @DescuentoTipo, @DescuentoLinea,@MiProveedor)        
           ELSE        
                          INSERT CompraD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo,SubCuenta, Cantidad, DescripcionExtra, Almacen, FechaRequerida, FechaEntrega, Costo, Impuesto1, Impuesto2, Impuesto3, DescuentoTipo, DescuentoLinea,ImportacionProveedor)        
                          VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo,@MiSubCuenta, @Cantidad, @DescripcionExtra,@AlmacenImp, @FechaRequerida, @FechaEntrega, @Costo, @Impuesto1, @Impuesto2, @Impuesto3, @DescuentoTipo, @DescuentoLinea,NULL)        
      END        
--NEWUP        
ELSE        
BEGIN--1                  --TIENE OPCIONES     --Si  es el mismo almacen que solo actualice la cantidad, si no que inserte una new partida        
        
SELECT @MiRenglonIDaux=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
SELECT @MiAlmacenI=Almacen FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND SubCuenta=@MiSubCuenta AND  RenglonID=@MiRenglonIDaux        
IF(@MiAlmacenI=@AlmacenImp)        
BEGIN--2        
SELECT @MiCantidadxSyL=Cantidad FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp        
SELECT @MiCantidadxSyL=@MiCantidadxSyL+@Cantidad        
UPDATE CompraD SET Cantidad=@MiCantidadxSyL  WHERE ID = @ID AND Articulo=@Articulo AND SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp        
END--2        
ELSE        
BEGIN--3 INSERCION NUEVA        
IF(@MovTipo='COMS.EI')        
 INSERT CompraD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo,SubCuenta, Cantidad, DescripcionExtra, Almacen, FechaRequerida, FechaEntrega, Costo, Impuesto1, Impuesto2, Impuesto3, DescuentoTipo, DescuentoLinea,ImportacionProveedor)        
 VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo,@MiSubCuenta, @Cantidad, @DescripcionExtra, @AlmacenImp, @FechaRequerida, @FechaEntrega, @Costo, @Impuesto1, @Impuesto2, @Impuesto3, @DescuentoTipo, @DescuentoLinea,@MiProveedor)        
ELSE        
 INSERT CompraD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo,SubCuenta, Cantidad, DescripcionExtra, Almacen, FechaRequerida, FechaEntrega, Costo, Impuesto1, Impuesto2, Impuesto3, DescuentoTipo, DescuentoLinea,ImportacionProveedor)        
 VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo,@MiSubCuenta, @Cantidad, @DescripcionExtra, @AlmacenImp, @FechaRequerida, @FechaEntrega, @Costo, @Impuesto1, @Impuesto2, @Impuesto3, @DescuentoTipo, @DescuentoLinea,NULL)     


  
   
END--3        
END--1        
--NEWUP        
                       END        
                       ELSE        
                       BEGIN        
--NEW        
IF NOT EXISTS(SELECT * FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp)        
--NEW        
BEGIN        
  IF(@MovTipo='COMS.EI')        
                          INSERT CompraD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo, Cantidad, DescripcionExtra, Almacen, FechaRequerida, FechaEntrega, Costo, Impuesto1, Impuesto2, Impuesto3, DescuentoTipo, DescuentoLinea,ImportacionProveedor)        
                          VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo, @Cantidad, @DescripcionExtra,/*@Almacen*/@AlmacenImp, @FechaRequerida, @FechaEntrega, @Costo, @Impuesto1, @Impuesto2, @Impuesto3, @DescuentoTipo, @DescuentoLinea,@MiProveedor)        
        ELSE        
                          INSERT CompraD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo, Cantidad, DescripcionExtra, Almacen, FechaRequerida, FechaEntrega, Costo, Impuesto1, Impuesto2, Impuesto3, DescuentoTipo, DescuentoLinea,ImportacionProveedor)        
                          VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo, @Cantidad, @DescripcionExtra,/*@Almacen*/@AlmacenImp, @FechaRequerida, @FechaEntrega, @Costo, @Impuesto1, @Impuesto2, @Impuesto3, @DescuentoTipo, @DescuentoLinea,NULL)        
END        
--NEWUP        
ELSE      -------NO OPCION        
BEGIN--1        
        
SELECT @MiRenglonIDaux=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
SELECT @MiAlmacenI=Almacen FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND  RenglonID=@MiRenglonIDaux        
        
IF(@MiAlmacenI=@AlmacenImp)        
BEGIN--2        
SELECT @MiCantidadxSyL=Cantidad FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
SELECT @MiCantidadxSyL=@MiCantidadxSyL+@Cantidad        
UPDATE CompraD SET Cantidad=@MiCantidadxSyL  WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
END--2        
ELSE        
BEGIN--3 INSERCION NUEVA        
IF(@MovTipo='COMS.EI')        
  INSERT CompraD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo, Cantidad, DescripcionExtra, Almacen, FechaRequerida, FechaEntrega, Costo, Impuesto1, Impuesto2, Impuesto3, DescuentoTipo, DescuentoLinea,ImportacionProveedor)     


  
   
  VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo, @Cantidad, @DescripcionExtra,@AlmacenImp, @FechaRequerida, @FechaEntrega, @Costo, @Impuesto1, @Impuesto2, @Impuesto3, @DescuentoTipo, @DescuentoLinea,@MiProveedor)        
ELSE        
  INSERT CompraD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo, Cantidad, DescripcionExtra, Almacen, FechaRequerida, FechaEntrega, Costo, Impuesto1, Impuesto2, Impuesto3, DescuentoTipo, DescuentoLinea,ImportacionProveedor)     


  
   
  VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo, @Cantidad, @DescripcionExtra,@AlmacenImp, @FechaRequerida, @FechaEntrega, @Costo, @Impuesto1, @Impuesto2, @Impuesto3, @DescuentoTipo, @DescuentoLinea,NULL)        
END--3        
END--1        
--NEWUP        
                       END        
                  ELSE        
                    IF @Modulo = 'INV'         
------------        
                       IF(@MiTipoOpcion='Si')        
                       BEGIN        
        
---INI AG INV        
--NEW        
IF NOT EXISTS(SELECT * FROM InvD WHERE ID = @ID AND Articulo=@Articulo and SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp)        
--NEW        
      BEGIN        
                    INSERT InvD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo,SubCuenta, Cantidad, Costo, Almacen)        
                    VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo,@MiSubCuenta, @MiCantidad, @Costo,@AlmacenImp)        
      END        
--NEWUP        
ELSE        
BEGIN--1                  --TIENE OPCIONES     --Si  es el mismo almacen que solo actualice la cantidad, si no que inserte una new partida        
        
SELECT @MiRenglonIDaux=RenglonID FROM InvD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
SELECT @MiAlmacenI=Almacen FROM InvD WHERE ID = @ID AND Articulo=@Articulo AND SubCuenta=@MiSubCuenta AND  RenglonID=@MiRenglonIDaux        
IF(@MiAlmacenI=@AlmacenImp)        
BEGIN--2        
SELECT @MiCantidadxSyL=Cantidad FROM InvD WHERE ID = @ID AND Articulo=@Articulo AND SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp        
SELECT @MiCantidadxSyL=@MiCantidadxSyL+@MiCantidad        
UPDATE InvD SET Cantidad=@MiCantidadxSyL  WHERE ID = @ID AND Articulo=@Articulo AND SubCuenta=@MiSubCuenta AND Almacen=@AlmacenImp        
END--2        
ELSE        
BEGIN--3 INSERCION NUEVA        
                       INSERT InvD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo,SubCuenta, Cantidad, Costo, Almacen)        
                       VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo,@MiSubCuenta, @MiCantidad, @Costo,@AlmacenImp)        
END--3        
END--1        
--NEWUP        
---FIN AG INV        
                       --INSERT InvD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo,SubCuenta, Cantidad, Costo, Almacen)        
                       --VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo,@MiSubCuenta, @MiCantidad, @Costo,@AlmacenImp)        
        
        
                       END        
                       ELSE        
                       BEGIN        
        
--IMP INV AG        
--NEW        
IF NOT EXISTS(SELECT * FROM InvD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp)        
--NEW        
BEGIN        
                     INSERT InvD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo, Cantidad, Costo, Almacen)        
                     VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo, @MiCantidad, @Costo,@AlmacenImp)          
END        
--NEWUP        
ELSE      -------NO OPCION        
BEGIN--1        
        
SELECT @MiRenglonIDaux=RenglonID FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
SELECT @MiAlmacenI=Almacen FROM CompraD WHERE ID = @ID AND Articulo=@Articulo AND  RenglonID=@MiRenglonIDaux        
        
IF(@MiAlmacenI=@AlmacenImp)        
BEGIN--2        
        
SELECT @MiCantidadxSyL=Cantidad FROM InvD WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
SELECT @MiCantidadxSyL=@MiCantidadxSyL+@MiCantidad        
        
--insert into val values(@RenglonID,@Articulo,@AlmacenImp)        
--insert into val values(@MiRenglonIDaux,'1',@AlmacenImp)        
--insert into val values(@MiCantidadxSyL,'2',@AlmacenImp)        
        
UPDATE InvD SET Cantidad=@MiCantidadxSyL  WHERE ID = @ID AND Articulo=@Articulo AND Almacen=@AlmacenImp        
END--2        
ELSE        
BEGIN--3 INSERCION NUEVA        
                     INSERT InvD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo, Cantidad, Costo, Almacen)        
                     VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo, @MiCantidad, @Costo,@AlmacenImp)          
END--3        
END--1        
--NEWUP        
--IMP INV AG        
                       --INSERT InvD (Sucursal, ID, Renglon, RenglonSub, RenglonID, Aplica, AplicaID, Articulo, Cantidad, Costo, Almacen)        
                       --VALUES (@Sucursal, @ID, @Renglon, 0, @RenglonID, @Aplica, @AplicaID, @Articulo, @MiCantidad, @Costo,@AlmacenImp)        
                       END        
        
                   SELECT @Renglon = @Renglon + 2048, @RenglonID = @RenglonID + 1        
              END----1        
        
            END-----0        
            ELSE         
               BEGIN        
                  SELECT         
                  @Ok = 1,         
                  @OkRef = 'No Existe el Articulo: '+RTRIM(@Articulo)        
                  RAISERROR(@OkRef,16,-1)           
               END        
        
      -- Actualizar Encabezado        
            
      IF @Aplica IS NOT NULL AND @AplicaID IS NOT NULL        
      BEGIN        
        IF @Modulo = 'COMS'        
          UPDATE Compra         
             SET RenglonID = @RenglonID , Concepto = @Concepto, Proyecto = @Proyecto, Referencia = @Referencia, Observaciones = @Observaciones,        
                 FormaEnvio = @FormaEnvio, Condicion = @Condicion, Vencimiento = @Vencimiento, Descuento = @Descuento, DescuentoGlobal = @DescuentoGlobal,        
                 Almacen = @Almacen, Proveedor = @Proveedor, FechaRequerida = @FechaRequerida, FechaEntrega = @FechaEntrega, Directo = 0        
       WHERE ID = @ID         
        ELSE        
        IF @Modulo = 'INV'         
          UPDATE Inv        
             SET RenglonID = @RenglonID , Concepto = @Concepto, Proyecto = @Proyecto, Referencia = @Referencia, Observaciones = @Observaciones,        
                 FormaEnvio = @FormaEnvio, Condicion = @Condicion, Vencimiento = @Vencimiento,        
                 Almacen = @Almacen, Directo = 0        
           WHERE ID = @ID         
      END ELSE        
      BEGIN        
        IF @Modulo = 'COMS' UPDATE Compra SET RenglonID = @RenglonID WHERE ID = @ID ELSE        
        IF @Modulo = 'INV'  UPDATE Inv    SET RenglonID = @RenglonID WHERE ID = @ID         
 END        
        
END ---ALMACEN            
        
    FETCH NEXT FROM crImportarIC INTO @Texto        
    END        
        
  CLOSE crImportarIC        
  DEALLOCATE crImportarIC       


  UPDATE SerieLoteMov  
   SET SerieLoteMov.CategoriaFSC=SerieLote.CategoriaFSC,
       SerieLoteMov.ObservacionesFSC=SerieLote.ObservacionesFSC,
       SerieLoteMov.CategoriaPEFC=SerieLote.CategoriaPEFC,
       SerieLoteMov.CategoriaSFI=SerieLote.CategoriaSFI ,
       SerieLoteMov.TipoFSC=SerieLote.TipoFSC,
       SerieLoteMov.OrdenCompra=SerieLote.OrdenCompra,
       SerieLoteMov.Apartados=SerieLote.Apartados,
       SerieLoteMov.Instruccion=SerieLote.Instruccion,
       SerieLoteMov.Ubicacion2=SerieLote.Ubicacion2,
       SerieLoteMov.AnchoUtil=SerieLote.AnchoUtil,
       SerieLoteMov.Observaciones=SerieLote.Observaciones,
       SerieLoteMov.Furgon=SerieLote.Furgon,
       SerieLoteMov.MetrosLineales=SerieLote.MetrosLineales,
       SerieLoteMov.Hojas=SerieLote.Hojas,
       SerieLoteMov.Largo=SerieLote.Largo,
	   SerieLoteMov.FechaApartado=SerieLote.FechaApartado
  FROM SerieLoteMov JOIN SerieLote ON SerieLote.SerieLote=SerieLoteMov.SerieLote
 WHERE SerieLoteMov.ID=@ID 
   AND SerieLoteMov.Modulo=@Modulo
        
  RETURN        
END 



ALTER  PROC [dbo].[INTERm2SerieLote]  
@Empresa CHAR(5),  
@Almacen VARCHAR(10),  
@SerieLote VARCHAR(50),  
@Articulo VARCHAR(20),  
@Largo VARCHAR(50),  
@DExtraNoHojas VARCHAR(100),  
@ID INT,  
@Modulo CHAR(5)  
AS  
BEGIN  
   
DECLARE  
@LetraArt CHAR(1),  
@Calidad VARCHAR(50),  
@Ancho VARCHAR(50),  
@Cantidad FLOAT,  
@Hojas FLOAT,  
@PrecioM2 MONEY,  
@TipoGramaje VARCHAR(10),  
@Gramaje FLOAT,  
@Cliente VARCHAR(10),  
@INTERControlCalidad BIT  
  
IF @Modulo='VTAS'  
BEGIN  
 SELECT TOP 1 @Cliente=Cliente FROM Venta WHERE ID=@ID  
 SELECT @INTERControlCalidad=INTERControlCalidad   
 FROM Cte WHERE Cliente=@Cliente  
END  
  
SELECT @Hojas=dbo.fnINTERSeparaINT(@DExtraNoHojas)  
  
SELECT @LetraArt=SUBSTRING(@Articulo, 1, 1)  
  
SELECT @Calidad=Categoria, @Ancho=Convert(varchar,Ancho) FROM Art WHERE Articulo=@Articulo  
  
IF @Largo IS NULL OR @Largo=''  
SELECT @Largo=0  
  
IF @Modulo='VTAS'  
BEGIN  
 IF EXISTS(SELECT * FROM INTERCteCalidad WHERE Cliente=@Cliente AND Calidad=@Calidad) AND @INTERControlCalidad=1 AND ISNUMERIC(CONVERT(FLOAT,@Ancho))=1 AND ISNUMERIC(@Largo)=1 /*AND ISNUMERIC(@Hojas)=1*/ AND CONVERT(FLOAT,@Ancho)>0 --AND @Largo>0  
 BEGIN  
   IF @LetraArt='T'  
   SELECT @Cantidad = (SELECT TotalINTERM2 FROM SerieLote WHERE Empresa=@Empresa AND Almacen=@Almacen AND SerieLote=@SerieLote AND Articulo=@Articulo)  
   ELSE   
    IF @LetraArt='B'  
    BEGIN  
     IF EXISTS(SELECT a.Articulo  
     FROM ArtProv a  
     JOIN Art b ON a.Articulo=b.Articulo  
     JOIN INTERProvCalidad c ON a.Proveedor=c.Proveedor AND b.Categoria=c.Calidad  
     WHERE a.Articulo=@Articulo)  
     SELECT @Cantidad=@Hojas  
     ELSE  
     SELECT @Cantidad = (CONVERT(DECIMAL, CONVERT(FLOAT,@Ancho))/100)*(@Hojas)  
    END  
 END   
END   
ELSE  
 BEGIN  
  IF ISNUMERIC(CONVERT(FLOAT,@Ancho))=1 AND ISNUMERIC(@Largo)=1 AND CONVERT(FLOAT,@Ancho)>0  
  BEGIN  
   IF @LetraArt='T'  
   SELECT @Cantidad = (SELECT TotalINTERM2 FROM SerieLote WHERE Empresa=@Empresa AND Almacen=@Almacen AND SerieLote=@SerieLote AND Articulo=@Articulo)  
   ELSE   
   IF @LetraArt='B'  
   BEGIN  
    IF EXISTS(SELECT a.Articulo  
    FROM ArtProv a  
    JOIN Art b ON a.Articulo=b.Articulo  
    JOIN INTERProvCalidad c ON a.Proveedor=c.Proveedor AND b.Categoria=c.Calidad  
    WHERE a.Articulo=@Articulo)  
    SELECT @Cantidad=@Hojas  
    ELSE  
    SELECT @Cantidad = (CONVERT(DECIMAL, @Ancho)/100)*(@Hojas)  
   END  
     
  END  
    
 END  

--SELECT Apartados,FechaApartado 
--  FROM SerieLote 
-- WHERE SerieLote='1209600227'
--   AND Apartados IS NOT NULL 

--SELECT * FROM Serielotemov   WHERE SerieLote='1209600227'
  
--UPDATE Serielotemov SET FechaApartado='20180102' WHERE SerieLote='1209600227'

SELECT ROUND(@Cantidad,4)  
  
END  



ALTER PROCEDURE [dbo].[xpMovFinal]  

@Empresa  char(5),      
@Sucursal  int,      
@Modulo  char(5),      
@ID   int,      
@Estatus  char(15),      
@EstatusNuevo char(15),      
@Usuario  char(10),      
@FechaEmision datetime,      
@FechaRegistro datetime,      
@Mov   char(20),      
@MovID  varchar(20),      
@MovTipo  char(20),      
@IDGenerar  int,      
@Ok   int  OUTPUT,      
@OkRef  varchar(255) OUTPUT      

AS BEGIN      

 DECLARE 

 @MovTipoCFDFlex BIT, 
@CFDFlex BIT, 
 @eDoc BIT, 
 @XML VARCHAR(max), 
 @eDocOk INT, 
 @eDocOkRef VARCHAR(255),
 @p    char(1),
@RFC 	varchar(20),
@cliente varchar(20)
   
  IF @Modulo = 'VTAS'	
	BEGIN
			IF @Mov = 'Factura Desperdicio'
				BEGIN   

SELECT @Cliente = Cliente FROM Venta WHERE ID = @ID
SELECT @RFC = NULLIF(LTRIM(RTRIM(RFC)), '') FROM Cte WHERE Cliente = @Cliente
IF @RFC IS NOT NULL AND LEN(@RFC) >= 9
BEGIN

SELECT @p = SUBSTRING(@RFC, 4, 1)
IF UPPER(@p) NOT IN ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z')
BEGIN
				UPDATE VentaD SET Retencion1 = a.Retencion1, Retencion2 = a.Retencion2
				  FROM VentaD JOIN Art a ON VentaD.Articulo = a.Articulo  
				 WHERE ID = @ID 
			DELETE FROM MovImpuesto WHERE Modulo = 'VTAS' AND ModuloID = @ID
			INSERT INTO MovImpuesto (Modulo, ModuloID, Impuesto1, Impuesto2, Impuesto3, Importe1,Importe2, Importe3, SubTotal,Retencion1, Retencion2, Excento1, Excento2, Excento3, OrigenModulo, OrigenModuloID, OrigenDeducible, OrigenFecha, ImporteBruto)
                SELECT 'VTAS', VentaD.ID,        VentaD.Impuesto1, 0,         0,    (((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))-((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))*(ISNULL(VentaD.DescuentoLinea,0)/100)))-((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))-((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))*(ISNULL(VentaD.DescuentoLinea,0)/100)))*(ISNULL(Venta.DescuentoGlobal,0)/100))*(ISNULL(VentaD.Impuesto1,0)/100) , 0,        0,        ((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))-((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))*(ISNULL(VentaD.DescuentoLinea,0)/100)))-((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))-((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))*(ISNULL(VentaD.DescuentoLinea,0)/100)))*(ISNULL(Venta.DescuentoGlobal,0)/100), VentaD.Retencion1, VentaD.Retencion2, 0,0,0, 'VTAS', VentaD.ID, 100, GETDATE(), ((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))-((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))*(ISNULL(VentaD.DescuentoLinea,0)/100)))-((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))-((ISNULL(VentaD.Cantidad,0)*ISNULL(VentaD.Precio,0))*(ISNULL(VentaD.DescuentoLinea,0)/100)))*(ISNULL(Venta.DescuentoGlobal,0)/100)                    
				FROM VentaD JOIN Venta ON VentaD.ID = Venta.ID
                   WHERE VentaD.ID =  @ID 


END
END
 	END		
				END 

  SELECT @CFDFlex = ISNULL(CFDFlex, 0), @eDoc = ISNULL(eDoc, 0)      
  FROM EmpresaGral      
  WHERE Empresa = @Empresa      

  SELECT @MovTipoCFDFlex = ISNULL(CFDFlex, 0)      

  FROM MovTipo      
  WHERE Mov = @Mov AND Modulo = @Modulo      

  IF (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000) AND @eDoc = 1 AND @MovTipoCFDFlex = 0 --MEJORA2104              
  BEGIN      

    SELECT @eDocOk = NULL, @eDocOkRef = NULL      

    EXEC speDocXML @@SPID, @Empresa, @Modulo, @Mov, @ID, NULL, @EstatusNuevo, 1, 0, @XML OUTPUT, @eDocOk OUTPUT, @eDocOkRef OUTPUT      
    IF @eDocOk IS NOT NULL      
      SELECT @Ok = @eDocOk, @OkRef = @eDocOkRef      
  END      
  IF (@MovTipoCFDFlex = 1) AND (@CFDFlex = 1) AND (@eDoc = 1) AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000) --MEJORA2104              

  BEGIN      
    SELECT @eDocOk = NULL, @eDocOkRef = NULL      
    EXEC spCFDFlex @@SPID, @Empresa, @Modulo, @ID, @EstatusNuevo, @eDocOk OUTPUT, @eDocOkRef OUTPUT      
    IF @eDocOk IS NOT NULL      
    SELECT @Ok = @eDocOk, @OkRef = @eDocOkRef      
  END      
  IF (@MovTipoCFDFlex = 1) AND (@CFDFlex = 1) AND (@eDoc = 1) AND (@Ok IS NULL OR @Ok BETWEEN 80030 AND 81000) --MEJORA2104              
BEGIN      
    SELECT @eDocOk = NULL, @eDocOkRef = NULL      
    EXEC spCFDFlexCancelar @@SPID, @Empresa, @Modulo, @ID, @EstatusNuevo, @eDocOk OUTPUT, @eDocOkRef OUTPUT      
    IF @eDocOk IS NOT NULL      
      SELECT @Ok = @eDocOk, @OkRef = @eDocOkRef      
  END      
RETURN      
END

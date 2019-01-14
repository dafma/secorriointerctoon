
ALTER PROC [dbo].[spMermaInventario]  
 @IDProd  int,  
 @Accion  char(20),  
 @Usuario char(10),  
 @Estacion int  
  
AS BEGIN  
 DECLARE  
 @IdInv int  

select @IdInv= IdInv from mermaIntercarton where idProd = @IDProd  
  
if (select estatus from prod where id = @IDProd)='CONCLUIDO' AND @IdInv IS NOT NULL AND @Accion= 'AFECTAR'  
  begin  
 EXEC  spAfectar 'INV', @IdInv, 'AFECTAR', 'Todo', NULL, @Usuario, @Estacion=@Estacion  
  end  
  
if (select estatus from prod where id = @IDProd)='CANCELADO' AND @IdInv IS NOT NULL AND  @Accion= 'CANCELAR'  
  begin  
 EXEC  spAfectar 'INV', @IdInv, 'CANCELAR', 'Todo', NULL, @Usuario, @Estacion=@Estacion  
  end


  
END  
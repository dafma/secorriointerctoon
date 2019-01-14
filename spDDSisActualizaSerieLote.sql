ALTER PROCEDURE [dbo].[spDDSisActualizaSerieLote]
  @ID int,
  @Modulo varchar(10)

AS BEGIN 

   UPDATE SerieLote 
      SET FechaApartado=SerieLoteMov.FechaApartado,Apartados=SerieLoteMov.Apartados
	 FROM SerieLoteMov JOIN  SerieLote ON SerieLoteMov.SerieLote=SerieLote.SerieLote AND SerieLote.Articulo=SerieLoteMov.Articulo
    WHERE SerieLoteMov.ID=@ID AND SerieLoteMov.Modulo=@Modulo

 RETURN 
END 

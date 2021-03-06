
ALTER  PROCEDURE [dbo].[spRepVtasCtosDDSis] (@Empresa VARCHAR(5),
									        @Ejercicio INT,
									        @Periodo INT) AS
  BEGIN
	-- Crea la tabla
	CREATE TABLE #Resultado (	ID int null,
	                            Mov varchar(20) null,
								MovID varchar(20) null,
								FechaEmision varchar(20) null,
								Origen varchar(20) null,
								Consecutivo varchar(20) null,
								ClaveCliente varchar(10) null,
								NombreCliente varchar(100) null,
								Agente varchar(10) null,
								NombreAgente varchar(100) null,
								Articulo varchar(20) null,
								Cantidad float null,
								Precio money null,
								Subtotal money null,
								CostoUnitario money null,
								TipoCambio float null,
								OrdenCompra varchar(50) null,
								Estatus varchar(15) null,
								AlmacenDestino varchar(10) null,
								Observaciones varchar(100) null,
								CostoTotal money null,
								CostoTotalRemision money null,
								CostoTotalFacturado money null,
								Venta money null
							);
	-- Inserta la informacion
	INSERT INTO #Resultado
	SELECT Venta.ID, 
		   Venta.Mov, 
		   Venta.MovID, 
		   LEFT(CONVERT(VARCHAR, Venta.FechaEmision, 120), 10) as FechaEmision , 
		   Venta.Origen, 
		   Venta.OrigenID, 
		   Cte.Cliente, 
		   Cte.Nombre, 
		   Cte.Agente, 
		   Agente.Nombre NombreAgente,
		   VentaD.Articulo, 
		   VentaD.Cantidad * CASE WHEN Venta.Mov IN ('Devolucion Venta','Bonificacion Venta') THEN -1 ELSE 1 END , 
		   VentaD.Precio * CASE WHEN Venta.Mov IN ('Devolucion Venta','Bonificacion Venta') THEN -1 ELSE 1 END , 
		   (ISNULL(VentaD.Cantidad, 0) * ISNULL(VentaD.Precio, 0)) * CASE WHEN Venta.Mov IN ('Devolucion Venta','Bonificacion Venta') THEN -1 ELSE 1 END  AS SubTotal, 
		   VentaD.Costo * CASE WHEN Venta.Mov IN ('Devolucion Venta','Bonificacion Venta') THEN -1 ELSE 1 END  AS CostoUnitario, 
		   Venta.TipoCambio, 
		   Venta.OrdenCompra, 
		   Venta.Estatus, 
		   Venta.AlmacenDestino, 
		   Venta.Observaciones,
		   --
		   (ISNULL(VentaD.Cantidad, 0) * ISNULL(VentaD.Costo, 0) * ISNULL(Venta.TipoCambio, 0)) * CASE WHEN Venta.Mov IN ('Devolucion Venta','Bonificacion Venta') THEN -1 ELSE 1 END  AS CostoTotal,
		   --
		   (SELECT ROUND((ISNULL(VentaDRem.Cantidad, 0) * ISNULL(VentaDRem.Costo, 0) * ISNULL(VentaRem.TipoCambio, 0)), 2) AS CostoTotalRemision
			  FROM Venta VentaRem JOIN VentaD VentaDRem ON VentaDRem.ID = VentaRem.ID AND VentaDRem.Renglon = VentaD.Renglon AND VentaDRem.RenglonID = VentaD.RenglonID 
			 WHERE VentaRem.Mov = Venta.Origen 
			   AND VentaRem.MovID = Venta.OrigenID
			   AND VentaRem.Estatus = 'CONCLUIDO') * CASE WHEN Venta.Mov IN ('Devolucion Venta','Bonificacion Venta') THEN -1 ELSE 1 END AS CostoTotalRemision,
		   --
		   (SELECT ROUND((ISNULL(VentaD.Cantidad, 0) * ISNULL(VentaDRem.Costo, 0) * ISNULL(VentaRem.TipoCambio, 0)), 2) AS CostoTotalRemision
			  FROM Venta VentaRem JOIN VentaD VentaDRem ON VentaDRem.ID = VentaRem.ID AND VentaDRem.Renglon = VentaD.Renglon AND VentaDRem.RenglonID = VentaD.RenglonID
			 WHERE VentaRem.Mov = Venta.Origen 
			   AND VentaRem.MovID = Venta.OrigenID
			   AND VentaRem.Estatus = 'CONCLUIDO') * CASE WHEN Venta.Mov IN ('Devolucion Venta','Bonificacion Venta') THEN -1 ELSE 1 END  as CostoTotalFacturado,
		   --
		   (SELECT (VentaTCalc.PrecioTotal * VentaTCalc.TipoCambio) AS Venta 
              FROM VentaTCalc 
             WHERE VentaTCalc.ID =  VentaD.ID
               AND VentaTCalc.Mov = Venta.Mov 
			   AND VentaTCalc.MovID = Venta.MovID 
               AND VentaTCalc.Estatus = 'CONCLUIDO'
	           AND VentaTCalc.Renglon = VentaD.Renglon 
 	           AND VentaTCalc.RenglonID = VentaD.RenglonID ) * CASE WHEN Venta.Mov IN ('Devolucion Venta','Bonificacion Venta') THEN -1 ELSE 1 END  AS Venta
	  FROM Venta
	  JOIN Cte ON Venta.Cliente = Cte.Cliente
	  JOIN VentaD ON Venta.ID = VentaD.ID
	  JOIN Art ON VentaD.Articulo = Art.Articulo
	  LEFT OUTER JOIN Agente ON Agente.Agente = Cte.Agente
	 WHERE (Venta.Origen = 'Remision' 
	    OR (Venta.Mov IN ('Devolucion Venta','Bonificacion Venta'))
	    OR (Venta.ID IN (SELECT DISTINCT Venta.ID 
						   FROM Venta JOIN VentaD  ON Venta.ID =VentaD.ID 
						  WHERE Venta.Estatus='CONCLUIDO' 
						    AND Venta.Ejercicio = @Ejercicio
	                        AND Venta.Periodo = @Periodo
						    AND Venta.Origen IS NULL 
						    AND VentaD.Articulo IN ('Carton','Seguro')))
	       ) -- RDOMENZAIN 05/07/2018
	   AND Venta.Estatus = 'CONCLUIDO'
	   AND Venta.Ejercicio = @Ejercicio
	   AND Venta.Periodo = @Periodo;
    
	UPDATE #Resultado 
	   SET CostoTotalFacturado=ISNULL(CostoTotalFacturado,CostoTotal),CostoTotalRemision=ISNULL(CostoTotalRemision,CostoTotal)
     WHERE Mov='Devolucion Venta'

	SELECT *
	  FROM #Resultado 
	  ORDER BY Mov, MovID;;
	--
	RETURN;
    --
END;




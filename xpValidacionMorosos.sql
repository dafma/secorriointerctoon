ALTER PROCEDURE [dbo].[xpValidacionMorosos]
@Empresa                char(5),
@Accion		        char(20),
@Modulo                 char(5),
@ID                     int,
@MovTipo                varchar(20),
@ServicioGarantia       bit,
@Ok                     int        OUTPUT
AS BEGIN
/* Esta rutina se ejecuta cuando falla por morosidad y siver para condicionar el error */
IF @MovTipo IN ('VTAS.C', 'VTAS.CS', 'VTAS.SG', 'VTAS.EG') OR (@MovTipo = 'VTAS.S' AND @ServicioGarantia = 1)
SELECT @Ok = NULL
RETURN
END

CREATE VIEW Retardo
WITH ENCRYPTION
AS
SELECT Personal.Personal,
HoraRegistro     = MIN(AsisteD.HoraRegistro),
HoraSalida    = MAX(AsisteD.HoraRegistro),
'Fecha'     = AsisteD.FechaD,
Retardo,
Usuario        = (SELECT  top 1 MovEstatusLog.Usuario FROM  MovEstatusLog WHERE MovEstatusLog.Modulo='ASIS'   AND MovEstatusLog.ModuloID=asiste.id AND ESTATUS='CONCLUIDO' )
FROM Personal, AsisteD ,Asiste
WHERE   Personal.Personal     = AsisteD.Personal
AND Asiste.ID         = AsisteD.ID
GROUP BY Personal.Personal,AsisteD.FechaD,Retardo,Asiste.Id
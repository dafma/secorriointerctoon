select RecepcionPagosParcialidad,* from movtipo where modulo='VTAS'

update movtipo
set RecepcionPagosParcialidad=1
where mov='Factura Electronica'

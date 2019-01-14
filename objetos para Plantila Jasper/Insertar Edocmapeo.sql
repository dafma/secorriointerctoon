select * from eDocD
where edoc='JASPER_CFDI_3.3' and modulo='VTAS'
select * from eDocDMapeoCampo 
where edoc='JASPER_CFDI_3.3' and modulo='VTAS' and idseccion=1860

Insert eDocDMapeoCampo(Modulo,eDoc,IDSeccion,CampoXML,CampoVista,FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero)
select 'VTAS','JASPER_CFDI_3.3',1860,'[VentaOrigenId]','VentaOrigenId',null,0,0,null,null,null,1,0,1,0
Insert eDocDMapeoCampo(Modulo,eDoc,IDSeccion,CampoXML,CampoVista,FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero)
select 'VTAS','JASPER_CFDI_3.3',1860,'[VentaReferencia]','VentaReferencia',null,0,0,null,null,null,1,0,1,0
Insert eDocDMapeoCampo(Modulo,eDoc,IDSeccion,CampoXML,CampoVista,FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero)
select 'VTAS','JASPER_CFDI_3.3',1860,'[VentaPedido]','(SELECT dbo.fnPedido(CFDModuloID))',null,0,0,null,null,null,1,0,1,0
Insert eDocDMapeoCampo(Modulo,eDoc,IDSeccion,CampoXML,CampoVista,FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero)
select 'VTAS','JASPER_CFDI_3.3',1860,'[FechaAprobacion]','FechaAprobacion',null,0,0,null,null,null,1,0,1,0
Insert eDocDMapeoCampo(Modulo,eDoc,IDSeccion,CampoXML,CampoVista,FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero)
select 'VTAS','JASPER_CFDI_3.3',1860,'[Telempresa]','Telempresa',null,0,0,null,null,null,1,0,1,0
Insert eDocDMapeoCampo(Modulo,eDoc,IDSeccion,CampoXML,CampoVista,FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero)
select 'VTAS','JASPER_CFDI_3.3',1860,'[FaxEmpresa]','FaxEmpresa',null,0,0,null,null,null,1,0,1,0
Insert eDocDMapeoCampo(Modulo,eDoc,IDSeccion,CampoXML,CampoVista,FormatoOpcional,Traducir,Opcional,BorrarSiOpcional,TablaSt,Decimales,CaracterExtendidoAASCII,ConvertirPaginaCodigo437,ConvertirComillaDobleAASCII,NumericoNuloACero)
select 'VTAS','JASPER_CFDI_3.3',1860,'[TelCte]','TelCte',null,0,0,null,null,null,1,0,1,0

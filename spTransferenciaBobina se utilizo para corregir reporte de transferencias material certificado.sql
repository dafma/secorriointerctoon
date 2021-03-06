

 --    exec  spTransferenciaBobina '01/12/2017' ,'31/12/2018'

ALTER procedure [dbo].[spTransferenciaBobina]            

 @FechaD datetime,            

 @FechaA datetime            

AS            

    --spTransferenciaBobina '2018/01/06' ,'2018/30/06'       
	
	
	--spTransferenciaBobina '01/06/2018' ,'30/06/2018' 

BEGIN            

          

create table #TransferenciasBobina            

( id int identity,            

Mov varchar(20) null,            

MovID varchar (20) null,            

FechaEmision datetime null,            

Referencia varchar (50) null,            

Almacen varchar (10) null,            

AlmacenDestino varchar (10) null,            

Articulo varchar (20) null,            

SerieLote varchar (50) null,            

Cantidad float null,            

TipoFSC varchar (50) null,            

CategoriaFSC varchar (50) null,      

CategoriaPEFC varchar (50) null,    

CategoriaSFI varchar (50) null,
Consumido  float null,
UltimoCambio DateTime null)           

            

       

      

--select INV.mov, inv.movid, inv.fechaemision, inv.referencia, inv.almacen, inv.almacendestino ,            

--serielotemov.Articulo, serielotemov.serielote, serielotemov.cantidad, serielotemov.tipoFSC, serielotemov.categoriaFSC            

--from inv            

-- inner join serielotemov on inv.id = serielotemov.id and serielotemov.modulo='INV'            

--where mov='TRANSFERENCIA'            

--and estatus='CONCLUIDO'            

--and inv.fechaemision between @fechaD and @fechaA            

--and almacendestino = 'ALM-PROD'            

--order by serielotemov.categoriaFSC            

           

insert #TransferenciasBobina(Mov,MovID,FechaEmision,Referencia,Almacen,AlmacenDestino,Articulo,SerieLote,Cantidad,TipoFSC,CategoriaFSC,CategoriaPEFC,CategoriaSFI,Consumido,UltimoCambio)            

select INV.mov, inv.movid, inv.fechaemision, inv.referencia, inv.almacen, inv.almacendestino ,            

serielotemov.Articulo, serielotemov.serielote, serielotemov.cantidad, serielotemov.tipoFSC, serielotemov.categoriaFSC,serielotemov.CategoriaPEFC,serielotemov.CategoriaSFI,
  ISNULL(dbo.fnSerieLoteConsumido(inv.referencia,serielotemov.serielote),0) Consumido ,UltimoCambio          

from inv            

 inner join serielotemov on inv.id = serielotemov.id and serielotemov.modulo='INV'            

where mov='TRANSFERENCIA'            

and estatus='CONCLUIDO'            

and inv.fechaemision between @fechaD and @fechaA            

and almacendestino = 'ALM-PROD'             

order by serielotemov.categoriaFSC,serielotemov.CategoriaPEFC,serielotemov.CategoriaSFI     


create table #TarimaCantidad            

( id int identity,            

 Serielote varchar(50) null,            

 Bobina  varchar(20) null,            

 Kilos  float null)            

            

create table #TarimaBobina            

( id int identity,            

 Serielote varchar(50) null,            

 Articulo  varchar(20) null,            

 Cantidad  float null)            

            

            

insert #TarimaBobina(serielote, articulo,cantidad)            

select serielote, articulo, 'Cantidad'=sum(cantidad)            

from #TransferenciasBobina            

group by serielote, articulo            

            

truncate table #TarimaCantidad            

            

insert #TarimaCantidad(Serielote,Bobina,Kilos)            

select  b.serielote, b.articulo, Kilo1              

from contartarima a            

 inner join #TarimaBobina b on a.bobinaserie1 = b.serielote and a.bobina1 = b.articulo            

where a.bobinaserie1 is not null            

            

insert #TarimaCantidad(Serielote,Bobina,Kilos)            

select   b.serielote, b.articulo, Kilo2              

from contartarima a            

 inner join #TarimaBobina b on a.bobinaserie2 = b.serielote and a.bobina2 = b.articulo            

where a.bobinaserie2 is not null            

            

insert #TarimaCantidad(Serielote,Bobina,Kilos)            

select   b.serielote, b.articulo, Kilo3              

from contartarima a            

 inner join #TarimaBobina b on a.bobinaserie3 = b.serielote and a.bobina3 = b.articulo            

where a.bobinaserie3 is not null            



insert #TarimaCantidad(Serielote,Bobina,Kilos)            

select b.serielote, b.articulo, Kilo4              

from contartarima a            

 inner join #TarimaBobina b on a.bobinaserie4 = b.serielote and a.bobina4 = b.articulo            

where a.bobinaserie4 is not null            

            

create table #Transferencias            

( id int identity,            

 Serielote varchar(50) null,            

 Articulo  varchar(20) null,            

 Referencia varchar(50) null,            

Cantidad  float null)            

            

create table #Produccion            

( id int identity,            

 Serielote varchar(50) null,       

 Articulo  varchar(20) null,            

 Kilos  float null)            

            

            

insert #Transferencias(serielote, articulo, referencia, cantidad)            

select serielote, articulo, max(referencia), 'Cantidad'=sum(cantidad)            

from #TransferenciasBobina            

group by serielote, articulo            

            

insert #Produccion(serielote, articulo, kilos)            

select a.Serielote, 'articulo' = bobina, 'Kilos' = sum(kilos)            

from #TarimaCantidad a            

group by a.Serielote,a.bobina            

            
/*
select a.serielote, a.articulo, cantidad, kilos,referencia,             

'CategoriaFSC' = (select top 1 categoriafsc from #TransferenciasBobina where serielote = a.serielote),        

'CategoriaPEFC' = (select top 1 categoriapefc from #TransferenciasBobina where serielote = a.serielote),    

'CategoriaSFI' = (select top 1 categoriaSFI from #TransferenciasBobina where serielote = a.serielote),          

'Fecha' = (select top 1 fechaemision from #TransferenciasBobina where serielote = a.serielote order by fechaemision desc),            

d.Descripcion2,d.Grupo,d.Familia           
 
from #Transferencias a          left outer join #Produccion b on a.serielote = b.serielote and a.articulo = b.articulo, art d            

where a.Serielote in (select serielote from #TransferenciasBobina 

WHERE ((isnull(nullif(categoriaFSC,'0'),'') <> '') OR (isnull(nullif(categoriaPEFC,'0'),'') <> '')) ) 

and d.articulo=a.articulo 

--and            

order by CategoriaFSC desc,CategoriaPEFC desc ,CategoriaSFI ,Fecha       

*/

 UPDATE #TransferenciasBobina  SET CategoriaFSC=NULL WHERE CategoriaFSC='0'
 UPDATE #TransferenciasBobina  SET CategoriaPEFC=NULL WHERE CategoriaPEFC='0'
 UPDATE #TransferenciasBobina  SET CategoriaSFI=NULL WHERE CategoriaSFI='0'
  UPDATE #TransferenciasBobina  SET CategoriaFSC='(MADERA CONTROLADA FSC)' WHERE CategoriaFSC='''(MADERA CONTROLADA FSC)'


--CAMBIO GMO
--SELECT ROW_NUMBER() OVER(PARTITION BY A.Serielote,a.Articulo,Referencia ORDER BY A.Serielote,a.Articulo,Referencia,A.UltimoCambio DESC) Orden ,A.UltimoCambio, 
SELECT convert(varchar(20), ROW_NUMBER() OVER(PARTITION BY A.Serielote,a.Articulo,Referencia ORDER BY A.Serielote,a.Articulo,Referencia,A.UltimoCambio DESC) ) as Orden  ,A.UltimoCambio, 
       a.SerieLote,a.Articulo,a.Cantidad,Consumido, Kilos,a.Referencia,a.CategoriaFSC,a.CategoriaPEFC,a.CategoriaSFI,a.FechaEmision Fecha ,b.Descripcion2,b.Grupo,B.Familia
  FROM #TransferenciasBobina A JOIN Art B ON A.Articulo=b.Articulo
                               JOIN #Produccion ON #Produccion.Serielote=A.SerieLote and #Produccion.Articulo=a.Articulo
Where a.CategoriaFSC is not null or a.CategoriaPEFC is not null or a.CategoriaSFI is not null 						   
order by CategoriaFSC desc,CategoriaPEFC desc ,CategoriaSFI ,Fecha  

 

end 


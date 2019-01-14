
ALTER PROCEDURE speDocXML
(
@Estacion			int,
@Empresa			varchar(5),
@Modulo			varchar(5),
@Mov				varchar(20),
@ID				int,
@eDoc				varchar(50) = NULL,
@Estatus			varchar(15),
@Registrar		bit = 1,
@CFDFlex			bit = 0,
@XMLOut			varchar(max) OUTPUT,
@Ok				int OUTPUT,
@OkRef			varchar(255) OUTPUT,
@LlamadaExterna	bit = 0,
@Contacto			varchar(10) = NULL
)
WITH ENCRYPTION
AS
BEGIN
DECLARE	@Documento				varchar(MAX),
@Orden					int,
@Seccion				varchar(50),
@SubSeccionDe			varchar(50),
@Vista					varchar(100),
@DocumentoSeccion		varchar(MAX),
@LargoExpresionFinal	int,
@PosicionFinal			int,
@Select					varchar(MAX),
@NSelect				nvarchar(MAX),
@OrdenSeccion			int,
@Cierre					bit,
@DocumentoTexto			varchar(MAX),
@ApuntadorTexto			binary(16),
@ApuntadorPrologo		binary(16),
@IDSeccion				int,
@Prologo				varchar(200),
@Codificacion			varchar(20),
@ApuntadorValido		int,
@XML					varchar(max),
@XMLIN					xml,
@MovTipoeDoc			varchar(50),
@MovTipoEstatus			varchar(15),
@LimpiarAutoXML			xml,
@TipoXML				bit,
@TagSostener			varchar(max),
@Tag					varchar(255),
@SeccionVerificar		varchar(50),
@TipoCFD				bit,
@Compilar				bit,
@RutaErrorMapeo			varchar(max),
@Referencia				varchar(max),
@CompXMLCpto			varchar(max),
@CompXMLCFD				varchar(max),
@AddendaXMLCFD			varchar(max),
@VersionCDFI			bit,
@Sucursal				int,
@MovID					varchar(20),
@ComplementoConcepto	bit,
@CuadrarImportes		bit
SET @Compilar = dbo.fneDocCompilar(@Modulo, @eDoc)
SELECT @MovTipoEstatus = NULL, @MovTipoeDoc = NULL
SELECT @CuadrarImportes = CuadrarImportes FROM EmpresaCFD WHERE Empresa = @Empresa
DELETE CFDFlexSesion WHERE Estacion = @@SPID
INSERT CFDFlexSesion(Estacion, Modulo, ID)
VALUES (@@SPID, @Modulo, @ID)
IF @LlamadaExterna = 0
BEGIN
IF @Modulo = 'VTAS' SELECT @Contacto = Cliente     FROM Venta    WHERE ID = @ID ELSE
IF @Modulo = 'CXC'  SELECT @Contacto = Cliente     FROM Cxc      WHERE ID = @ID ELSE
IF @Modulo = 'COMS' SELECT @Contacto = Proveedor   FROM Compra   WHERE ID = @ID ELSE
IF @Modulo = 'CXP'  SELECT @Contacto = Proveedor   FROM Cxp      WHERE ID = @ID ELSE
IF @Modulo = 'GAS'  SELECT @Contacto = Acreedor    FROM Gasto    WHERE ID = @ID
END ELSE
BEGIN
IF @Mov IS NULL AND @Ok IS NULL SELECT @Ok = 10160 ELSE
IF @Mov IS NOT NULL AND NOT EXISTS(SELECT * FROM MovTipo WHERE Modulo = @Modulo AND Mov = @Mov) AND @Ok IS NULL SELECT @Ok = 14055 ELSE
IF @Contacto IS NOT NULL AND NOT EXISTS(SELECT * FROM MovTipoeDoc WHERE Modulo = @Modulo AND Mov = @Mov AND Contacto = @Contacto) AND @Ok IS NULL SELECT @Ok = 28020, @OkRef = @Contacto
END
IF @CFDFlex = 0
BEGIN
SELECT @MovTipoeDoc = ISNULL(eDoc,''), @MovTipoEstatus = Estatus FROM MovTipoeDoc WHERE Contacto = @Contacto AND Mov = @Mov AND Modulo = @Modulo
IF NULLIF(@MovTipoeDoc,'') IS NULL AND NULLIF(@MovTipoEstatus,'') IS NULL
SELECT @MovTipoeDoc = ISNULL(eDoc,''), @MovTipoEstatus = eDocEstatus FROM MovTipo WHERE Mov = @Mov AND Modulo = @Modulo
IF @Estatus <> @MovTipoEstatus RETURN
IF NULLIF(@eDoc,'') IS NULL SELECT @eDoc = NULLIF(@MovTipoeDoc,'')
END
IF @eDoc IS NULL RETURN
SET @OrdenSeccion = 0
DELETE eDocSeccionTemporal WHERE Estacion = @Estacion
SELECT @Documento = Documento, @TipoXML = TipoXML, @TipoCFD = TipoCFD, @ComplementoConcepto = ComplementoConcepto FROM eDoc WHERE Modulo = @Modulo AND eDoc = @eDoc
SELECT @Codificacion = 'Windows-1252'
IF @TipoCFD = 1
SET @Prologo = '<?xml version="1.0" encoding="'+ RTRIM(@Codificacion) +'"?>' 
ELSE
SET @Prologo = '' 
SELECT @SeccionVerificar = NULL
SELECT
@SeccionVerificar = edd.Seccion
FROM dbo.fneDocDocumentoASecciones(@Modulo,@eDoc) s RIGHT JOIN eDocD edd
ON s.Nombre = edd.Seccion
WHERE edd.Modulo = @Modulo
AND edd.eDoc = @eDoc
AND s.Nombre IS NULL
IF @SeccionVerificar IS NOT NULL SELECT @Ok = 71620, @OkRef = @SeccionVerificar
IF @Compilar = 0 
BEGIN
DECLARE @eDocCompilacion TABLE(CodigoSQL varchar(max) NULL)
INSERT @eDocCompilacion(CodigoSQL)
SELECT CodigoSQL
FROM eDocCompilacion
WHERE eDoc = @eDoc
AND Modulo = @Modulo
ORDER BY Orden
END
IF @Compilar = 1
BEGIN
DELETE FROM eDocCompilacion WHERE Modulo = @Modulo AND eDoc = @eDoc
DECLARE creDocD CURSOR FAST_FORWARD FOR
SELECT medd.Orden, medd.Seccion, NULLIF(medd.SubSeccionDe,''), medd.Vista, medd.Cierre, medd.RID, ds.Datos
FROM eDocD medd JOIN dbo.fneDocDocumentoASecciones(@Modulo,@eDoc) ds
ON ds.nombre = medd.Seccion
WHERE medd.eDoc = @eDoc
AND medd.Modulo = @Modulo
ORDER BY Orden
END ELSE IF @Compilar = 0
BEGIN
DECLARE creDocD CURSOR FAST_FORWARD FOR
SELECT CodigoSQL
FROM @eDocCompilacion 
END
IF PATINDEX('%CFDI_3.3%',@eDoc) > 0
SELECT @VersionCDFI = 1
OPEN creDocD
IF @Compilar = 1
FETCH NEXT FROM creDocD INTO @Orden, @Seccion, @SubSeccionDe, @Vista, @Cierre, @IDSeccion, @DocumentoSeccion
ELSE IF @Compilar = 0
FETCH NEXT FROM creDocD INTO @Select
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
IF @Compilar = 1
BEGIN
IF @VersionCDFI = 1
BEGIN
IF @ComplementoConcepto = 1
EXEC speDocParsearSeccionComplementoConcepto33 @Estacion, @Modulo, @eDoc, @IDSeccion, @Vista, @ID, @DocumentoSeccion, @SubSeccionDe, @Cierre, @Compilar, @Orden, @Select OUTPUT, @OrdenSeccion OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
ELSE
EXEC speDocParsearSeccion33 @Estacion, @Modulo, @eDoc, @IDSeccion, @Vista, @ID, @DocumentoSeccion, @SubSeccionDe, @Cierre, @Compilar, @Orden, @Select OUTPUT, @OrdenSeccion OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
END
ELSE
EXEC speDocParsearSeccion @Estacion, @Modulo, @eDoc, @IDSeccion, @Vista, @ID, @DocumentoSeccion, @SubSeccionDe, @Cierre, @Compilar, @Select OUTPUT, @OrdenSeccion OUTPUT, @Ok OUTPUT, @OkRef OUTPUT
INSERT eDocCompilacion (Modulo, eDoc, Orden, CodigoSQL) VALUES (@Modulo, @eDoc, @Orden, @Select)
END
SET @Select = REPLACE(@Select,'{Compilacion_Estacion}',RTRIM(LTRIM(CONVERT(varchar,ISNULL(@Estacion,@@SPID)))))
SET @Select = REPLACE(@Select,'{Compilacion_ID_Movimiento}',RTRIM(LTRIM(CONVERT(varchar,ISNULL(@ID,0.0)))))

--SELECT @Select

IF @Seccion = 'Encabezado' AND @Ok IS NULL
BEGIN
SELECT @NSelect = 'IF (SELECT ISNULL(COUNT(1),0) FROM ' + @Vista + ' WHERE ID = ' + CONVERT(varchar,@ID) + ' ) <> 1 SELECT @OK = 71680' 
EXECUTE sp_executesql @NSelect, N'@OK int OUTPUT', @OK OUTPUT
END
IF @Ok IS NULL
BEGIN
SET @NSelect = @Select
BEGIN TRY
EXECUTE sp_executesql @NSelect
END TRY
BEGIN CATCH
SELECT @Ok = 1, @OkRef = RTRIM(ISNULL(@eDoc,'')) + ':' + RTRIM(ISNULL(@Seccion,'')) + ':Error de mapeo, verifique la sintaxis de las expresiones SQL y que todas devuelvan valores tipo varchar (' + SUBSTRING(ERROR_MESSAGE(),1,48) + ')'
IF XACT_STATE() = -1
BEGIN
ROLLBACK TRAN
RAISERROR(@OkRef,20,1) WITH LOG
END
END CATCH
END
IF @Compilar = 1
FETCH NEXT FROM creDocD INTO @Orden, @Seccion, @SubSeccionDe, @Vista, @Cierre, @IDSeccion, @DocumentoSeccion
ELSE IF @Compilar = 0
FETCH NEXT FROM creDocD INTO @Select
END
CLOSE creDocD
DEALLOCATE creDocD
IF @@Version LIKE '%2005%'
BEGIN
DECLARE @SeccionTemporal TABLE(OrdenExportacion varchar(255),Documento text NULL) 
INSERT @SeccionTemporal(OrdenExportacion, Documento)
SELECT OrdenExportacion, Documento
FROM eDocSeccionTemporal
WHERE Estacion = @Estacion AND Modulo = @Modulo AND ModuloID = @ID
ORDER BY OrdenExportacion
SET @XML = ''
DECLARE creDocSeccionTemporal CURSOR FAST_FORWARD FOR
SELECT Documento
FROM @SeccionTemporal
ORDER BY OrdenExportacion
OPEN creDocSeccionTemporal 
FETCH NEXT FROM creDocSeccionTemporal INTO @DocumentoTexto
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
SET @XML = @XML + @DocumentoTexto
FETCH NEXT FROM creDocSeccionTemporal INTO @DocumentoTexto
END
CLOSE creDocSeccionTemporal
DEALLOCATE creDocSeccionTemporal
END
IF @@Version NOT LIKE '%2005%'
BEGIN
DECLARE @eDocSeccionTemporal TABLE(ID int identity(1,1),Documento text)
INSERT @eDocSeccionTemporal(Documento)
SELECT Documento
FROM eDocSeccionTemporal
WHERE Estacion = @Estacion AND Modulo = @Modulo AND ModuloID = @ID
ORDER BY OrdenExportacion
SET @XML = ''
SELECT @XML = dbo.clrconcatenate(Documento)
FROM @eDocSeccionTemporal
END
IF @TipoXML = 1
BEGIN
SELECT @TagSostener = ''
DECLARE crTagSostener CURSOR FOR
SELECT Tag
FROM eDocDTagSostener
WHERE Modulo = @Modulo
AND eDoc = @eDoc
OPEN crTagSostener
FETCH NEXT FROM crTagSostener INTO @Tag
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
SELECT @TagSostener = @TagSostener + ',' + @Tag
FETCH NEXT FROM crTagSostener INTO @Tag
END
CLOSE crTagSostener
DEALLOCATE crTagSostener
END
EXEC speDocLimpiarXML @Modulo, @eDoc, @XML OUTPUT
SELECT @XML = dbo.fneDocParsearConsecutivo(@XML)
SELECT @XML = dbo.fneDocParsearCuenta(@XML)
IF @TipoXML = 1
SELECT @XML = dbo.fneDocLimpiarXML(@XML, @TagSostener)
IF @TipoXML = 1
BEGIN
SET @XML = CONVERT(varchar(max),CONVERT(xml,@XML))
IF ISNULL(@CuadrarImportes,0) = 1
BEGIN
SET @XMLIN = @XML
EXEC spAjustaTotalesXML @XMLIN = @XMLIN OUTPUT, @VerDetalle = 0
SELECT @XML = CONVERT(varchar(max),@XMLIN)
END
EXEC speDocLimpiarXML @Modulo, @eDoc, @XML OUTPUT
EXEC speDocValidarXML @Modulo, @eDoc, @XML, @Ok OUTPUT, @OkRef OUTPUT
IF @VersionCDFI = 1 AND @ComplementoConcepto = 0 AND @Ok IS NULL
BEGIN
SELECT @MovID = MovID,  @Sucursal = Sucursal FROM Venta WHERE ID = @ID
EXEC spValidarXMLCFDI @Empresa, @Sucursal, @Modulo, @ID, @Mov, @MovID, @XML OUTPUT, @Ok, @OkRef
END
END
SELECT @XMLOut = @Prologo + @XML
IF ISNULL(@Registrar,0) = 1 AND @Ok IS NULL
BEGIN
IF EXISTS(SELECT * FROM MoveDoc WHERE ID = @ID AND Modulo = @Modulo AND Empresa = @Empresa)
BEGIN
UPDATE MoveDoc
SET eDoc = @XMLOUT
WHERE ID = @ID
AND Modulo = @Modulo
AND Empresa = @Empresa
IF @@ERROR <> 0 SET @Ok = 1
END
ELSE
BEGIN
INSERT MoveDoc (Empresa, Modulo, ID, eDoc) VALUES (@Empresa, @Modulo, @ID, @XMLOUT)
IF @@ERROR <> 0 SET @Ok = 1
END
END
IF @Compilar = 1 AND @Ok IS NULL UPDATE eDoc SET UltimaCompilacion = UltimoCambio WHERE Modulo = @Modulo AND eDoc = @eDoc
IF @OK IS NOT NULL
BEGIN
SELECT @RutaErrorMapeo = RTRIM(LTRIM(ISNULL(RutaTemporal,''))) + '\ErrorMapeo ' + CONVERT(VARCHAR(10),@@SPID) + '.txt' FROM EmpresaCFD WHERE Empresa = @Empresa
IF RIGHT(@RutaErrorMapeo, 1) = '\' SELECT @RutaErrorMapeo = SUBSTRING(@RutaErrorMapeo, 1, LEN(@RutaErrorMapeo)-1)
IF @OK = 1
SELECT @Referencia = @NSelect
ELSE
SELECT @Referencia = 'Error - ' + CONVERT(varchar(10),@Ok) + ' - ' + @OkRef
EXEC spEliminarArchivo @RutaErrorMapeo, NULL, NULL
EXEC spRegenerarArchivo @RutaErrorMapeo, @Referencia, NULL, NULL
END
ELSE
EXEC spEliminarArchivo @RutaErrorMapeo, NULL, NULL
IF EXISTS(SELECT * FROM MovTipoCFDFlex WHERE Modulo = @Modulo AND Mov = @Mov AND Comprobante = @eDoc AND (Contacto = @Contacto OR Contacto = '(Todos)')) AND @VersionCDFI = 1
BEGIN
EXEC speDocXMLComplementos @Estacion, @Empresa, @Modulo, @Mov, @ID, @eDoc, @Estatus, 0, 1,
@CompXMLCpto OUTPUT, @CompXMLCFD OUTPUT, @AddendaXMLCFD OUTPUT, @Ok OUTPUT, @OkRef OUTPUT, @LlamadaExterna, @Contacto
IF @CompXMLCpto IS NOT NULL
EXEC speDocXMLComplementoConcepto @ID, @CompXMLCpto, @XMLOut OUTPUT
SELECT @XMLOut = REPLACE(@XMLOut,'<cfdi:Complemento>_COMPLEMENTO_CFD_</cfdi:Complemento>',ISNULL(@CompXMLCFD,''))
SELECT @XMLOut = REPLACE(@XMLOut,'<cfdi:Addenda>_ADDENDA_DOCUMENTO_</cfdi:Addenda>',ISNULL(@AddendaXMLCFD,''))
SELECT @XMLOut = REPLACE(@XMLOut,'Confirmacion="_CONFIRMACION_"','')
SELECT @XMLOut = REPLACE(@XMLOut,'<cfdi:Impuestos/>','')
SELECT @XMLOut = REPLACE(@XMLOut,'<cfdi:Retenciones/>','')
SELECT @XMLOut = REPLACE(@XMLOut,'<cfdi:Traslados/>','')
SELECT @XMLOut = REPLACE(@XMLOut,'<cfdi:CuentaPredial/>','')
SELECT @XMLOut = REPLACE(@XMLOut,'<cfdi:InformacionAduanera />','')
END
END
GO

if exists(select * from SysTipoDatos WHERE Tabla = 'SerieLote' AND Campo = 'SerieLote' and Tamano=20) OR
exists(select * from SysTipoDatos WHERE Tabla = 'SerieLote' AND Campo = 'SubCuenta' and Tamano=20)
BEGIN
EXEC spEliminarPK 'SerieLote'
EXEC spALTER_COLUMN 'SerieLote', 'SerieLote', 'varchar(50) NOT NULL'
EXEC spALTER_COLUMN 'SerieLote', 'SubCuenta', 'varchar(50) NOT NULL', '""'
EXEC('ALTER TABLE SerieLote ADD CONSTRAINT priSerieLote PRIMARY KEY CLUSTERED (SerieLote, Articulo, SubCuenta, Almacen, Tarima, Sucursal, Empresa)')
END
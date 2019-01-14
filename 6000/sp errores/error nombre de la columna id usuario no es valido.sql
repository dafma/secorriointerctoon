/*Modificacion a tablas anteriores para anexar sucursal*/
EXEC spALTER_TABLE 'cuentascontables', 'sucursal', 'varchar(10) not null default '''''
EXEC spALTER_TABLE 'movcontables', 'sucursal', 'varchar(10) not null default '''''
EXEC spALTER_TABLE 'saldosini', 'sucursal', 'varchar(10) not null default '''''
EXEC spALTER_TABLE 'ximpiva', 'sucursal', 'varchar(10) not null default '''''
EXEC spALTER_TABLE 'DatosIeps', 'sucursal', 'varchar(10) not null default '''''
EXEC spALTER_TABLE 'ReportesPorLinea', 'ComandoDetalle', 'varchar(500) null default '''''
EXEC spALTER_TABLE 'ReportesPorLinea', 'TotalDecimales', 'smallint not null default 2'
EXEC spALTER_TABLE 'ReportesPorLinea', 'EsTituloSeccion', 'bit not null default 0'
/*comienza la creacion de tablas*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Usuarios]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Usuarios](
[idUsuario] [int] IDENTITY(1,1) NOT NULL,
[Nombre] [varchar](30) NULL,
[Mail] [varchar](30) NOT NULL,
[Password] [varbinary](500) NULL,
[Estatus] [bit] NULL,
CONSTRAINT [PK_Usuarios_1] PRIMARY KEY CLUSTERED
(
[idUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_Usuarios] ON [dbo].[Usuarios]
(
[Mail] ASC,
[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET IDENTITY_INSERT [dbo].[Usuarios] ON
insert into Usuarios (idUsuario,Nombre,Mail,Password,Estatus) values(1,'Administrador','admin@admin.com',null,1)
SET IDENTITY_INSERT [dbo].[Usuarios] off
end
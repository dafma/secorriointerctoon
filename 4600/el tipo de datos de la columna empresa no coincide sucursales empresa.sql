EXEC spALTER_TABLE 'Perfiles', 'Estatus', 'bit NULL default 1'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Sucursales]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Sucursales](
[Sucursal] [varchar](10) NOT NULL,
[empresa][varchar](5) not null,
[Nombre] [varchar](100) NULL,
[Estatus] [bit] NULL,
CONSTRAINT [PK_Sucursales] PRIMARY KEY CLUSTERED
(
[Sucursal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[Sucursales]  WITH CHECK ADD  CONSTRAINT [FK_Sucursales_Empresa] FOREIGN KEY([Empresa])
REFERENCES [dbo].[Empresa] ([Empresa])
ALTER TABLE [dbo].[Sucursales] CHECK CONSTRAINT [FK_Sucursales_Empresa]
end
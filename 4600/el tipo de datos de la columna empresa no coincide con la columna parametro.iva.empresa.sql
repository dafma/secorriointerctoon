/*Parametros de IVA*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ParametrosIVA]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ParametrosIVA](
[idParametroIva] [int] IDENTITY(1,1) NOT NULL,
[Empresa] [varchar](5) NULL,
[Ejercicio] [int] NULL,
[DeclaracionTotalRetencion] [bit] NULL,
[ImportacionContaBancos] [varchar](1) NULL,
CONSTRAINT [PK_ParametrosIVA] PRIMARY KEY CLUSTERED
(
[idParametroIva] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[ParametrosIVA]  WITH CHECK ADD  CONSTRAINT [FK_ParametrosIVA_Empresa] FOREIGN KEY([Empresa])
REFERENCES [dbo].[Empresa] ([Empresa])
ALTER TABLE [dbo].[ParametrosIVA] CHECK CONSTRAINT [FK_ParametrosIVA_Empresa]
CREATE UNIQUE NONCLUSTERED INDEX [IX_ParametrosIVA] ON [dbo].[ParametrosIVA]
(
[Empresa] ASC,
[Ejercicio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
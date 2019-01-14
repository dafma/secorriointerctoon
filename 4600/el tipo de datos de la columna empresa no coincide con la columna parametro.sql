IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ParametrosGrals]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ParametrosGrals](
[idParametroGral] [int] IDENTITY(1,1) NOT NULL,
[Empresa] [varchar](5) NULL,
[Ejercicio] [int] NULL,
[Periodo] [int] NULL,
[FechaIni] [datetime] NULL,
[FechaFin] [datetime] NULL,
[idContabilidad] [int] NULL,
[EstructuraCuentas] [varchar](30) NULL,
[CuentaResultadoEjer] [varchar](60) null,
[EjercicioActivo] [bit] NULL,
CONSTRAINT [PK_ParametrosGrals] PRIMARY KEY CLUSTERED
(
[idParametroGral] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
exec spALTER_COLUMN 'ParametrosGrals','FechaIni','datetime null'
exec spALTER_COLUMN 'ParametrosGrals','FechaFin','datetime null'
ALTER TABLE [dbo].[ParametrosGrals]  WITH CHECK ADD  CONSTRAINT [FK_ParametrosGrals_Empresa] FOREIGN KEY([Empresa])
REFERENCES [dbo].[Empresa] ([Empresa])
ALTER TABLE [dbo].[ParametrosGrals] CHECK CONSTRAINT [FK_ParametrosGrals_Empresa]
CREATE UNIQUE NONCLUSTERED INDEX [IX_ParametrosGrals] ON [dbo].[ParametrosGrals]
(
[Empresa] ASC,
[Ejercicio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
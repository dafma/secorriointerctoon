EXEC spALTER_TABLE 'Parametrosgrals', 'CuentaResultadoEjer', 'varchar(60) NULL'
EXEC spALTER_TABLE 'Parametrosgrals', 'RutaProcesoEtl', 'varchar(500) NULL'
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ParametrosISR]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ParametrosISR](
[idParametroISR] [int] IDENTITY(1,1) NOT NULL,
[Empresa] [varchar](5) NULL,
[Ejercicio] [int] NULL,
[TasaISR] [float] NULL,
[CoopSocAC] [bit] NULL,
[RetSubEmpleo] [varchar](1) NULL,
[AplicaPTUPP] [bit] NULL,
[IngFluctuacion] [varchar](1) NULL,
[SaldosContrarios] [varchar](1) NULL,
[InteresesDevengados] [varchar](1) NULL,
[Mes13] [bit] NULL,
[ActivosEnajenados] [varchar](1) NULL,
[InventarioAcum] [varchar](1) NULL,
[PerdidasInventario] [bit] NULL,
[PerdidasAmortizar] [bit] NULL,
[DolarAme] [varchar](5) NULL,
[ParidadPrimerDia] [bit] NULL,
[NumEmpleados] [int] NULL,
[CedulaReservas] [bit] NULL,
[CedulaAntClientes] [bit] NULL,
[CedulaPasNoDed] [bit] NULL,
[CVfiscal] [bit] NULL,
[InvFinalCosto] [varchar](1) NULL,
[MObraMaquilas] [varchar](1) NULL,
[ComprasNalImporta] [bit] NULL,
[PasivoyCapitalNegativo] [bit] NULL,
CONSTRAINT [PK_ParametrosISR] PRIMARY KEY CLUSTERED
(
[idParametroISR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[ParametrosISR]  WITH CHECK ADD  CONSTRAINT [FK_ParametrosISR_Empresa] FOREIGN KEY([Empresa])
REFERENCES [dbo].[Empresa] ([Empresa])
ALTER TABLE [dbo].[ParametrosISR] CHECK CONSTRAINT [FK_ParametrosISR_Empresa]
CREATE UNIQUE NONCLUSTERED INDEX [IX_ParametrosISR] ON [dbo].[ParametrosISR]
(
[Empresa] ASC,
[Ejercicio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
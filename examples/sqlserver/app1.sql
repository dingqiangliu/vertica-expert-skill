USE [BPMDB5]
GO

 
/****** Object:  Table [dbo].[AddSupplierScheduledOrderDetail]    Script Date: 3/1/2024 9:54:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AddSupplierScheduledOrderDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ORDERINDEX] [int] NULL,
	[TASKID] [int] NULL,
	[PO_Line] [int] NULL,
	[Ship_To_Site] [nvarchar](50) NULL,
	[Item_Number] [nvarchar](50) NULL,
	[Item_Desc] [nvarchar](250) NULL,
	[Taxable] [nvarchar](50) NULL,
	[Consignment] [nvarchar](50) NULL,
	[Location] [nvarchar](50) NULL,
	[Location_Desc] [nvarchar](50) NULL,
	[TAS_Class] [nvarchar](50) NULL,
	[TAS_Class_Desc] [nvarchar](50) NULL,
	[Unit_Of_Measure] [nvarchar](50) NULL,
	[UMConversion] [nvarchar](50) NULL,
	[MAX_Order_Qty] [nvarchar](50) NULL,
	[Type] [nvarchar](50) NULL,
	[Purchase_Account] [nvarchar](50) NULL,
	[Work_Order_ID] [nvarchar](50) NULL,
	[Sub_Account] [nvarchar](50) NULL,
	[Operation] [nvarchar](50) NULL,
	[CostCenter] [nvarchar](50) NULL,
	[Start_Effective] [date] NULL,
	[End_Effective] [date] NULL,
	[Comment] [nvarchar](max) NULL,
	[Firm_Days] [int] NULL,
	[Ship_Delivery_Pattern_Code] [nvarchar](50) NULL,
	[Schedule_Days] [int] NULL,
	[Schedule_Weeks] [int] NULL,
	[Schedule_Months] [int] NULL,
	[STD_Pack_Qty] [int] NULL,
	[Transport_Days] [int] NULL,
	[Safety_Days] [int] NULL,
	[PriceCode] [nvarchar](8) NULL,
	[ProductLine] [nvarchar](50) NULL,
	[UMFilter] [nvarchar](50) NULL,
	[PreviousPartNumber] [nvarchar](50) NULL,
	[Price] [decimal](18, 5) NULL,
	[FromRCPDate] [date] NULL,
	[MAX_QTY] [nvarchar](50) NULL,
 CONSTRAINT [PK_AddSupplierScheduledOrderDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[M_PI_AddSupplierScheduledOrderDetailPrice]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[M_PI_AddSupplierScheduledOrderDetailPrice](
	[ID] [int] NOT NULL,
	[ForeignKey] [int] NULL,
	[TASKID] [int] NULL,
	[ORDERINDEX] [int] NULL,
	[ItemID] [int] NULL,
	[Start_Effective] [date] NULL,
	[End_Effective] [date] NULL,
	[BasePrice] [decimal](18, 5) NULL,
	[PTP] [decimal](18, 5) NULL,
	[MCIP] [decimal](18, 5) NULL,
	[ECON] [decimal](18, 5) NULL,
	[FX] [decimal](18, 5) NULL,
	[DesignChange] [decimal](18, 5) NULL,
	[Allied] [decimal](18, 5) NULL,
	[ToolingAmortization] [decimal](18, 5) NULL,
	[Other] [decimal](18, 5) NULL,
	[ContractPrice] [decimal](18, 5) NULL,
	[HLine] [bit] NULL,
	[PO_Line] [int] NULL,
	[Item_Number] [nvarchar](50) NULL,
	[PriceCode] [nvarchar](8) NULL,
	[Unit_Of_Measure] [nvarchar](50) NULL,
	[Other1] [decimal](18, 5) NULL,
	[Friction] [decimal](18, 5) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[M_PI_adjust_SupplierScheduledOrderDetailPrice]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[M_PI_adjust_SupplierScheduledOrderDetailPrice](
	[new_ID] [int] NOT NULL,
	[ID] [int] NULL,
	[BasePrice] [decimal](18, 5) NULL,
	[PTP] [decimal](18, 5) NULL,
	[MCIP] [decimal](18, 5) NULL,
	[ECON] [decimal](18, 5) NULL,
	[FX] [decimal](18, 5) NULL,
	[DesignChange] [decimal](18, 5) NULL,
	[Allied] [decimal](18, 5) NULL,
	[ToolingAmortization] [decimal](18, 5) NULL,
	[Other] [decimal](18, 5) NULL,
	[Other1] [decimal](18, 5) NULL,
	[ContractPrice] [decimal](18, 5) NULL,
	[Item_Number] [nvarchar](50) NULL,
	[PO_Number] [nvarchar](50) NULL,
	[PO_Line] [int] NULL,
	[PriceCode] [nvarchar](8) NULL,
	[Unit_Of_Measure] [nvarchar](50) NULL,
	[Start_effective] [date] NULL,
	[End_Effective] [date] NULL,
	[result] [nvarchar](200) NULL,
	[TaskId] [int] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[M_PI_Scheduled_Order_EE]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[M_PI_Scheduled_Order_EE](
	[Domain] [nvarchar](500) NULL,
	[PONumber] [nvarchar](500) NULL,
	[Supplier] [nvarchar](500) NULL,
	[Complete] [bit] NULL,
	[SupplierName] [nvarchar](500) NULL,
	[HeaderTaxble] [nvarchar](500) NULL,
	[HeaderTaxClass] [nvarchar](500) NULL,
	[TaxClassDesc.] [nvarchar](500) NULL,
	[CreditTerms] [nvarchar](500) NULL,
	[PaymentConditionDescript] [nvarchar](500) NULL,
	[Currency] [nvarchar](500) NULL,
	[Rate] [money] NULL,
	[Buyer] [nvarchar](500) NULL,
	[BuyerName] [nvarchar](500) NULL,
	[MFG Duns_] [nvarchar](500) NULL,
	[Vendor Duns_] [nvarchar](500) NULL,
	[Incoterms 2010] [nvarchar](500) NULL,
	[Title Transfer] [nvarchar](500) NULL,
	[Site] [nvarchar](500) NULL,
	[SiteDesc] [nvarchar](500) NULL,
	[BillToAddress] [nvarchar](500) NULL,
	[Bill-ToAddressInf.] [nvarchar](500) NULL,
	[ShipToAddress] [nvarchar](500) NULL,
	[Ship-ToAddressInf.] [nvarchar](500) NULL,
	[Header Start Effective] [datetime] NULL,
	[Header End Effective] [datetime] NULL,
	[POLine] [int] NULL,
	[ItemNumber] [nvarchar](500) NULL,
	[ItemDesc] [nvarchar](500) NULL,
	[Location] [nvarchar](500) NULL,
	[Location_Desc] [nvarchar](500) NULL,
	[UnitofMeasure] [nvarchar](500) NULL,
	[Type] [nvarchar](500) NULL,
	[Work Order ID] [nvarchar](500) NULL,
	[Operation] [nvarchar](500) NULL,
	[Ship-To Site] [nvarchar](500) NULL,
	[Consignment] [nvarchar](500) NULL,
	[Detail Taxable] [nvarchar](500) NULL,
	[Detail Tax Class] [nvarchar](500) NULL,
	[TaxDetailClassDesc] [nvarchar](500) NULL,
	[Purchase Account] [nvarchar](500) NULL,
	[Sub-Account] [nvarchar](500) NULL,
	[Cost Center] [nvarchar](500) NULL,
	[Ship Delivery Pattern Code] [nvarchar](500) NULL,
	[Firm Days] [int] NULL,
	[Schedule Days] [int] NULL,
	[Schedule Weeks] [int] NULL,
	[Schedule Months] [int] NULL,
	[Transport Days] [int] NULL,
	[Supplier Item] [nvarchar](500) NULL,
	[Max Qty] [nvarchar](500) NULL,
	[Std Pack Qty] [decimal](18, 5) NULL,
	[PODStartEffective] [nvarchar](500) NULL,
	[PODEndEffective] [nvarchar](500) NULL,
	[PCStart] [date] NULL,
	[PCExpire] [date] NULL,
	[PCPrice] [decimal](20, 5) NULL,
	[Filter1] [nvarchar](500) NULL,
	[Filter2] [nvarchar](500) NULL,
	[Price List Code] [nvarchar](500) NULL,
	[ProductLine] [nvarchar](500) NULL,
	[PORev] [int] NULL,
	[PODConsignment] [nvarchar](50) NULL,
	[SafetyDays] [int] NULL,
	[RCPDate] [date] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[M_PI_SupplierScheduledOrderDetailPrice]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[M_PI_SupplierScheduledOrderDetailPrice](
	[ID] [int] NOT NULL,
	[ForeignKey] [int] NULL,
	[TASKID] [int] NULL,
	[ORDERINDEX] [int] NULL,
	[ItemID] [int] NULL,
	[Start_Effective] [date] NULL,
	[End_Effective] [date] NULL,
	[BasePrice] [decimal](18, 5) NULL,
	[PTP] [decimal](18, 5) NULL,
	[MCIP] [decimal](18, 5) NULL,
	[ECON] [decimal](18, 5) NULL,
	[FX] [decimal](18, 5) NULL,
	[DesignChange] [decimal](18, 5) NULL,
	[Allied] [decimal](18, 5) NULL,
	[ToolingAmortization] [decimal](18, 5) NULL,
	[Other] [decimal](18, 5) NULL,
	[ContractPrice] [decimal](18, 5) NULL,
	[HLine] [bit] NULL,
	[PO_Line] [int] NULL,
	[Item_Number] [nvarchar](50) NULL,
	[PriceCode] [nvarchar](8) NULL,
	[Unit_Of_Measure] [nvarchar](50) NULL,
	[Other1] [decimal](18, 5) NULL,
	[Friction] [decimal](18, 5) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_DataType_FM]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_DataType_FM](
	[DataType] [nvarchar](50) NULL,
	[Versionorder] [nvarchar](50) NULL,
	[Islatest] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_Forecast_ExchangeRate_L2]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_Forecast_ExchangeRate_L2](
	[Year] [int] NULL,
	[VersionType] [nvarchar](50) NULL,
	[BaseCurr] [nvarchar](50) NULL,
	[TransCurr] [nvarchar](50) NULL,
	[JanRate] [decimal](18, 5) NULL,
	[FebRate] [decimal](18, 5) NULL,
	[MarRate] [decimal](18, 5) NULL,
	[AprRate] [decimal](18, 5) NULL,
	[MayRate] [decimal](18, 5) NULL,
	[JunRate] [decimal](18, 5) NULL,
	[JulRate] [decimal](18, 5) NULL,
	[AugRate] [decimal](18, 5) NULL,
	[SepRate] [decimal](18, 5) NULL,
	[OctRate] [decimal](18, 5) NULL,
	[NovRate] [decimal](18, 5) NULL,
	[DecRate] [decimal](18, 5) NULL,
	[ID] [nvarchar](225) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_Intelex_Org]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_Intelex_Org](
	[Region] [nvarchar](50) NULL,
	[BU] [nvarchar](50) NULL,
	[Site] [nvarchar](50) NULL,
	[HREntity] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_M_Scheduled_Order]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_M_Scheduled_Order](
	[Domain] [nvarchar](500) NULL,
	[PONumber] [nvarchar](500) NULL,
	[Supplier] [nvarchar](500) NULL,
	[Complete] [bit] NULL,
	[SupplierName] [nvarchar](500) NULL,
	[HeaderTaxble] [nvarchar](500) NULL,
	[HeaderTaxClass] [nvarchar](500) NULL,
	[TaxClassDesc.] [nvarchar](500) NULL,
	[CreditTerms] [nvarchar](500) NULL,
	[PaymentConditionDescript] [nvarchar](500) NULL,
	[Currency] [nvarchar](500) NULL,
	[Rate] [money] NULL,
	[Buyer] [nvarchar](500) NULL,
	[BuyerName] [nvarchar](500) NULL,
	[MFG Duns_] [nvarchar](500) NULL,
	[Vendor Duns_] [nvarchar](500) NULL,
	[Incoterms 2010] [nvarchar](500) NULL,
	[Title Transfer] [nvarchar](500) NULL,
	[Site] [nvarchar](500) NULL,
	[SiteDesc] [nvarchar](500) NULL,
	[BillToAddress] [nvarchar](500) NULL,
	[Bill-ToAddressInf.] [nvarchar](500) NULL,
	[ShipToAddress] [nvarchar](500) NULL,
	[Ship-ToAddressInf.] [nvarchar](500) NULL,
	[Header Start Effective] [datetime] NULL,
	[Header End Effective] [datetime] NULL,
	[POLine] [int] NULL,
	[ItemNumber] [nvarchar](500) NULL,
	[ItemDesc] [nvarchar](500) NULL,
	[Location] [nvarchar](500) NULL,
	[Location_Desc] [nvarchar](500) NULL,
	[UnitofMeasure] [nvarchar](500) NULL,
	[Type] [nvarchar](500) NULL,
	[Work Order ID] [nvarchar](500) NULL,
	[Operation] [nvarchar](500) NULL,
	[Ship-To Site] [nvarchar](500) NULL,
	[Consignment] [nvarchar](500) NULL,
	[Detail Taxable] [nvarchar](500) NULL,
	[Detail Tax Class] [nvarchar](500) NULL,
	[TaxDetailClassDesc] [nvarchar](500) NULL,
	[Purchase Account] [nvarchar](500) NULL,
	[Sub-Account] [nvarchar](500) NULL,
	[Cost Center] [nvarchar](500) NULL,
	[Ship Delivery Pattern Code] [nvarchar](500) NULL,
	[Firm Days] [int] NULL,
	[Schedule Days] [int] NULL,
	[Schedule Weeks] [int] NULL,
	[Schedule Months] [int] NULL,
	[Transport Days] [int] NULL,
	[Supplier Item] [nvarchar](500) NULL,
	[Max Qty] [nvarchar](500) NULL,
	[Std Pack Qty] [decimal](18, 5) NULL,
	[PODStartEffective] [nvarchar](500) NULL,
	[PODEndEffective] [nvarchar](500) NULL,
	[PCStart] [date] NULL,
	[PCExpire] [date] NULL,
	[PCPrice] [decimal](20, 5)NULL,
	[Filter1] [nvarchar](500) NULL,
	[Filter2] [nvarchar](500) NULL,
	[Price List Code] [nvarchar](500) NULL,
	[ProductLine] [nvarchar](500) NULL,
	[PORev] [int] NULL,
	[PODConsignment] [nvarchar](50) NULL,
	[SafetyDays] [int] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Actual_Booked_Detail]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Actual_Booked_Detail](
	[Domain] [nvarchar](50) NULL,
	[Site] [nvarchar](50) NULL,
	[ponumber] [nvarchar](50) NULL,
	[poline] [nvarchar](50) NULL,
	[ComponentPN] [nvarchar](50) NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[rcvddate] [date] NULL,
	[rcvdqty] [decimal](18, 5) NULL,
	[POCurrency] [nvarchar](50) NULL,
	[CurrentFX] [decimal](18, 5) NULL,
	[P2Ptype] [nvarchar](50) NULL,
	[OriginalP2P] [decimal](18, 5) NULL,
	[P2PUSD] [decimal](18, 5) NULL,
	[RecpdateP2P] [decimal](18, 5) NULL,
	[SavingType] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Actual_FM]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Actual_FM](
	[Domain] [nvarchar](50) NULL,
	[Site] [nvarchar](50) NULL,
	[prh_nbr] [nvarchar](50) NULL,
	[prh_line] [nvarchar](50) NULL,
	[ComponentPN] [nvarchar](50) NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[POCurrency] [nvarchar](50) NULL,
	[CurrentFX] [decimal](18, 5) NULL,
	[P2Ptype] [nvarchar](50) NULL,
	[OriginalP2P] [decimal](18, 5) NULL,
	[P2PUSD] [decimal](18, 5) NULL,
	[lastdayoflastyearP2P] [decimal](18, 5) NULL,
	[avgoflastyearP2P] [decimal](18, 5) NULL,
	[SavingType] [nvarchar](50) NULL,
	[TotalRcvdbyMonth] [decimal](18, 5) NULL
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[PI_GSM_P2P_Baseprice_FM]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Baseprice_FM](
	[domain] [nvarchar](50) NULL,
	[ponumber] [nvarchar](50) NULL,
	[POLine] [int] NULL,
	[ItemNumber] [nvarchar](50) NULL,
	[RecordDate] [datetime] NULL,
	[PCStart] [date] NULL,
	[PCExpire] [date] NULL,
	[baseprice] [decimal](20, 5) NULL,
	[pcprice] [decimal](20, 5) NULL,
    [Index01] [nvarchar](50),
	[PTP] [decimal](20, 5) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Baseprice_FM_History]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Baseprice_FM_History](
	[domain] [nvarchar](50) NULL,
	[ponumber] [nvarchar](50) NULL,
	[POLine] [int] NULL,
	[ItemNumber] [nvarchar](50) NULL,
	[RecordDate] [datetime] NULL,
	[PCStart] [date] NULL,
	[PCExpire] [date] NULL,
	[baseprice] [decimal](20, 5) NULL,
	[pcprice] [decimal](20, 5) NULL,
    [Index01] [nvarchar](50),
	[PTP] [decimal](20, 5) NULL,
	[Savingtype] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Baseprice_FM_History_adjust_2023]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Baseprice_FM_History_adjust_2023](
	[domain] [nvarchar](50) NULL,
	[ponumber] [nvarchar](50) NULL,
	[POLine] [int] NULL,
	[ItemNumber] [nvarchar](50) NULL,
	[RecordDate] [datetime2](3) NULL,
	[PCStart] [date] NULL,
	[PCExpire] [date] NULL,
	[baseprice] [decimal](20, 5) NULL,
	[pcprice] [decimal](20, 5) NULL,
    [Index01] [nvarchar](50),
	[PTP] [decimal](20, 5) NULL,
	[Savingtype] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Baseprice_M1]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Baseprice_M1](
	[domain] [nvarchar](50) NULL,
	[ponumber] [nvarchar](50) NULL,
	[POLine] [int] NULL,
	[ItemNumber] [nvarchar](50) NULL,
	[RecordDate] [date] NULL,
	[PCStart] [date] NULL,
	[PCExpire] [date] NULL,
	[baseprice] [money] NULL,
	[pcprice] [money] NULL,
	[Index01] [nvarchar](50) NULL,
	[ParentIndex] [nvarchar](50) NULL,
	[IIndex] [int] NULL,
	[PTP] [money] NULL,
	[IsPTPAdj] [int] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Baseprice_M1_History]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Baseprice_M1_History](
	[domain] [nvarchar](50) NULL,
	[ponumber] [nvarchar](50) NULL,
	[POLine] [int] NULL,
	[ItemNumber] [nvarchar](50) NULL,
	[RecordDate] [date] NULL,
	[PCStart] [date] NULL,
	[PCExpire] [date] NULL,
	[baseprice] [money] NULL,
	[pcprice] [money] NULL,
	[Index01] [nvarchar](50) NULL,
	[ParentIndex] [nvarchar](50) NULL,
	[IIndex] [int] NULL,
	[PTP] [money] NULL,
	[IsPTPAdj] [int] NULL,
	[Savingtype] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Baseprice_M2]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Baseprice_M2](
	[domain] [nvarchar](50) NULL,
	[ponumber] [nvarchar](50) NULL,
	[POLine] [int] NULL,
	[ItemNumber] [nvarchar](50) NULL,
	[RecordDate] [date] NULL,
	[PCStart] [date] NULL,
	[PCExpire] [date] NULL,
	[baseprice] [money] NULL,
	[pcprice] [money] NULL,
	[Index01] [nvarchar](50) NULL,
	[ParentIndex] [nvarchar](50) NULL,
	[IIndex] [int] NULL,
	[PTP] [money] NULL,
	[IsPTPAdj] [int] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Baseprice_M2_History]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Baseprice_M2_History](
	[domain] [nvarchar](50) NULL,
	[ponumber] [nvarchar](50) NULL,
	[POLine] [int] NULL,
	[ItemNumber] [nvarchar](50) NULL,
	[RecordDate] [date] NULL,
	[PCStart] [date] NULL,
	[PCExpire] [date] NULL,
	[baseprice] [money] NULL,
	[pcprice] [money] NULL,
	[Index01] [nvarchar](50) NULL,
	[ParentIndex] [nvarchar](50) NULL,
	[IIndex] [int] NULL,
	[PTP] [money] NULL,
	[IsPTPAdj] [int] NULL,
	[Savingtype] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Baseprice_M3]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Baseprice_M3](
	[domain] [nvarchar](50) NULL,
	[ponumber] [nvarchar](50) NULL,
	[POLine] [int] NULL,
	[ItemNumber] [nvarchar](50) NULL,
	[RecordDate] [date] NULL,
	[PCStart] [date] NULL,
	[PCExpire] [date] NULL,
	[baseprice] [money] NULL,
	[pcprice] [money] NULL,
	[Index01] [nvarchar](50) NULL,
	[PTP] [money] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Baseprice_M3_History]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Baseprice_M3_History](
	[domain] [nvarchar](50) NULL,
	[ponumber] [nvarchar](50) NULL,
	[POLine] [int] NULL,
	[ItemNumber] [nvarchar](50) NULL,
	[RecordDate] [date] NULL,
	[PCStart] [date] NULL,
	[PCExpire] [date] NULL,
	[baseprice] [money] NULL,
	[pcprice] [money] NULL,
	[Index01] [nvarchar](50) NULL,
	[PTP] [money] NULL,
	[Savingtype] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Baseprice_M4]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Baseprice_M4](
	[ConfidencePhase] [nvarchar](50) NULL,
	[Domain] [nvarchar](50) NULL,
	[ID] [int] NULL,
	[TASKID] [int] NULL,
	[PO_Number] [nvarchar](50) NULL,
	[PO_Line] [int] NULL,
	[Item_Number] [nvarchar](50) NULL,
	[Start_Effective] [date] NULL,
	[End_Effective] [date] NULL,
	[BasePrice] [decimal](18, 5) NULL,
	[NewBasePrice] [decimal](18, 5) NULL,
	[PTP] [decimal](18, 5) NULL,
	[NewPTP] [decimal](18, 5) NULL,
	[ContractPrice] [decimal](18, 5) NULL,
	[ForecastYear] [int] NULL,
	[SavingType] [nvarchar](50) NULL,
	[SubSavingType] [nvarchar](50) NULL,
	[ConfidenceLevel] [nvarchar](50) NULL,
	[PKey] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Calendar]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Calendar](
	[Year] [int] NULL,
	[Month] [int] NULL,
	[Firstday] [date] NULL,
	[Lastday] [date] NULL,
	[Month_char] [nvarchar](50) NULL,
	[Month_char_Actual] [nvarchar](50) NULL,
	[Month_char_Manual] [nvarchar](50) NULL,
	[Month_char_Sale] [nvarchar](50) NULL,
	[Month_char_FinAPV] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_FM]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_FM](
	[Domain] [nvarchar](50) NULL,
	[Site] [nvarchar](50) NULL,
	[SalablePartNo] [nvarchar](50) NULL,
	[Customer] [nvarchar](50) NULL,
	[Programs] [nvarchar](50) NULL,
	[PL] [nvarchar](50) NULL,
	[PONumber] [nvarchar](50) NULL,
	[POLine] [nvarchar](50) NULL,
	[ComponentPN] [nvarchar](50) NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[POCurrency] [nvarchar](50) NULL,
	[CurrentFX] [decimal](18, 5) NULL,
	[P2Ptype] [nvarchar](50) NULL,
	[OriginalP2P] [decimal](18, 5) NULL,
	[P2PUSD] [decimal](18, 5) NULL,
	[FirstdayofmonthP2P] [decimal](18, 5) NULL,
	[avgoflastyearP2P] [decimal](18, 5) NULL,
	[lastdayoflastyearP2P] [decimal](18, 5) NULL,
	[SavingType] [nvarchar](50) NULL,
	[ConfidencePhase] [nvarchar](50) NULL,
	[SubSavingType] [nvarchar](50) NULL,
	[MonthQtyPur] [decimal](18, 5) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_M1]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_M1](
	[Domain] [nvarchar](50) NULL,
	[PO_Number] [nvarchar](50) NULL,
	[PO_Line] [int] NULL,
	[Item_Number] [nvarchar](50) NULL,
	[RcdQty] [decimal](18, 5) NULL,
	[PCPrice] [decimal](18, 5) NULL,
	[PTP] [decimal](18, 5) NULL,
	[MCIP] [decimal](18, 5) NULL,
	[ECON] [decimal](18, 5) NULL,
	[FX] [decimal](18, 5) NULL,
	[DesignChange] [decimal](18, 5) NULL,
	[Allied] [decimal](18, 5) NULL,
	[ToolingAortization] [decimal](18, 5) NULL,
	[Logistic] [decimal](18, 5) NULL,
	[Other] [decimal](18, 5) NULL,
	[Rcpdate] [date] NULL,
	[Curr] [nvarchar](50) NULL,
	[UM] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_M1_History]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_M1_History](
	[Domain] [nvarchar](50) NULL,
	[PO_Number] [nvarchar](50) NULL,
	[PO_Line] [int] NULL,
	[Item_Number] [nvarchar](50) NULL,
	[RcdQty] [decimal](18, 5) NULL,
	[PCPrice] [decimal](18, 5) NULL,
	[PTP] [decimal](18, 5) NULL,
	[MCIP] [decimal](18, 5) NULL,
	[ECON] [decimal](18, 5) NULL,
	[FX] [decimal](18, 5) NULL,
	[DesignChange] [decimal](18, 5) NULL,
	[Allied] [decimal](18, 5) NULL,
	[ToolingAortization] [decimal](18, 5) NULL,
	[Logistic] [decimal](18, 5) NULL,
	[Other] [decimal](18, 5) NULL,
	[Rcpdate] [date] NULL,
	[Curr] [nvarchar](50) NULL,
	[UM] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[PI_GSM_P2P_Sales_01]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PI_GSM_P2P_Sales_01](
	[DataType] [nvarchar](50) NULL,
	[Domain] [nvarchar](50) NULL,
	[Site] [nvarchar](50) NULL,
	[SalablePartNo] [nvarchar](50) NULL,
	[Customer] [nvarchar](50) NULL,
	[Programs] [nvarchar](500) NULL,
	[PL] [nvarchar](50) NULL,
	[D1] [decimal](18, 5) NULL,
	[D2] [decimal](18, 5) NULL,
	[D3] [decimal](18, 5) NULL,
	[D4] [decimal](18, 5) NULL,
	[D5] [decimal](18, 5) NULL,
	[D6] [decimal](18, 5) NULL,
	[D7] [decimal](18, 5) NULL,
	[D8] [decimal](18, 5) NULL,
	[D9] [decimal](18, 5) NULL,
	[D10] [decimal](18, 5) NULL,
	[D11] [decimal](18, 5) NULL,
	[D12] [decimal](18, 5) NULL,
	[SD1] [decimal](18, 5) NULL,
	[SD2] [decimal](18, 5) NULL,
	[SD3] [decimal](18, 5) NULL,
	[SD4] [decimal](18, 5) NULL,
	[SD5] [decimal](18, 5) NULL,
	[SD6] [decimal](18, 5) NULL,
	[SD7] [decimal](18, 5) NULL,
	[SD8] [decimal](18, 5) NULL,
	[SD9] [decimal](18, 5) NULL,
	[SD10] [decimal](18, 5) NULL,
	[SD11] [decimal](18, 5) NULL,
	[SD12] [decimal](18, 5) NULL,
	[Year] [nvarchar](50) NULL,
	[RM1] [decimal](18, 5) NULL,
	[RM2] [decimal](18, 5) NULL,
	[RM3] [decimal](18, 5) NULL,
	[RM4] [decimal](18, 5) NULL,
	[RM5] [decimal](18, 5) NULL,
	[RM6] [decimal](18, 5) NULL,
	[RM7] [decimal](18, 5) NULL,
	[RM8] [decimal](18, 5) NULL,
	[RM9] [decimal](18, 5) NULL,
	[RM10] [decimal](18, 5) NULL,
	[RM11] [decimal](18, 5) NULL,
	[RM12] [decimal](18, 5) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](200) NULL,
	[SelectedSalablePartNo] [nvarchar](50) NULL,
	[HFMplatform] [nvarchar](50) NULL,
	[SelectledPrograms] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TT_PI_M_BOM_BI_M2]    Script Date: 2/29/2024 12:14:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TT_PI_M_BOM_BI_M2](
	[Forecasttype] [nvarchar](50) NULL,
	[ps_domain] [nvarchar](50) NULL,
	[ps_par] [nvarchar](50) NULL,
	[ps_comp] [nvarchar](50) NULL,
	[psqtyper] [decimal](18, 5) NULL,
	[ps_start] [date] NULL,
	[ps_end] [date] NULL,
	[UM] [nvarchar](50) NULL,
	[ForecastYear] [int] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[M_PO_Supplier]    Script Date: 3/1/2024 8:09:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[M_PO_Supplier](
	[Vendor] [nvarchar](50) NOT NULL,
	[BusinessName] [nvarchar](200) NULL,
	[BusinessAddress] [nvarchar](200) NULL,
	[City] [nvarchar](50) NULL,
	[Country] [nvarchar](50) NULL,
	[Postal] [nvarchar](50) NULL,
	[TaxClass] [nvarchar](50) NULL,
	[TaxIncluded] [bit] NULL,
	[Taxable] [bit] NULL,
	[TaxEnv] [nvarchar](50) NULL,
	[DUNS] [nvarchar](50) NULL,
	[PaymentTerm] [nvarchar](50) NULL,
	[Buyer] [nvarchar](50) NULL,
	[Domain] [nvarchar](50) NULL,
	[Currency] [nvarchar](10) NULL,
	[Remark] [nvarchar](50) NULL,
	[BankName] [nvarchar](500) NULL,
	[BankAccount] [nvarchar](500) NULL,
	[SwiftCode] [nvarchar](500) NULL,
	[Complete] [bit] NULL,
	[vd_type] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BPMInstTasks]    Script Date: 3/1/2024 8:15:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BPMInstTasks](
	[TaskID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ProcessName] [nvarchar](50) NOT NULL,
	[OwnerAccount] [nvarchar](50) NULL,
	[AgentAccount] [nvarchar](50) NULL,
	[CreateAt] [datetime] NOT NULL,
	[Description] [ntext] NULL,
	[FinishAt] [datetime] NULL,
	[State] [char](10) NOT NULL,
	[SerialNum] [nvarchar](50) NULL,
	[OptUser] [nvarchar](50) NULL,
	[OptAt] [datetime] NULL,
	[OptMemo] [nvarchar](50) NULL,
	[FormDataSetID] [int] NULL,
	[ExtYear]  AS (datepart(year,[CreateAt])) PERSISTED,
	[ExtInitiator]  AS (isnull([AgentAccount],[OwnerAccount])) PERSISTED,
	[ExtDeleted]  AS (CONVERT([bit],case [State] when 'Deleted' then (1) else (0) end,(0))) PERSISTED,
	[OwnerPositionID] [int] NULL,
	[ParentTaskID] [int] NULL,
	[ParentStepID] [int] NULL,
	[ParentStepName] [nvarchar](50) NULL,
	[ProcessVersion] [nvarchar](10) NOT NULL,
	[ParentServerIdentity] [nvarchar](50) NULL,
	[ReturnToParent] [bit] NULL,
	[UrlParams] [nvarchar](500) NULL,
	[Context] [nvarchar](2000) NULL,
 CONSTRAINT [YZPK_BPMInstTasks] PRIMARY KEY CLUSTERED 
(
	[TaskID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[M_BOM_BI_M1]    Script Date: 3/1/2024 8:15:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[M_BOM_BI_M1](
	[ps_domain] [nvarchar](50) NULL,
	[ps_par] [nvarchar](50) NULL,
	[ps_comp] [nvarchar](50) NULL,
	[psqtyper] [decimal](18, 5) NULL,
	[ps_start] [date] NULL,
	[ps_end] [date] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[M_Value]    Script Date: 3/1/2024 8:15:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[M_Value](
	[id] [char](32) NOT NULL,
	[source_id] [char](32) NULL,
	[label] [nvarchar](max) NULL,
	[label_zh] [nvarchar](max) NULL,
	[value] [nvarchar](max) NULL,
	[filter] [nvarchar](max) NULL,
	[sort_order] [int] NULL,
	[orderIndex] [int] NULL,
	[filter2] [nvarchar](max) NULL,
	[filter3] [nvarchar](max) NULL,
	[filter4] [nvarchar](max) NULL,
	[filter5] [nvarchar](max) NULL,
	[filter6] [nvarchar](max) NULL,
	[filter7] [nvarchar](max) NULL,
	[filter8] [nvarchar](max) NULL,
	[filter9] [nvarchar](max) NULL,
	[filter10] [nvarchar](max) NULL,
	[filter11] [nvarchar](max) NULL,
 CONSTRAINT [PK_value] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SupplierScheduledOrder]    Script Date: 3/1/2024 8:15:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SupplierScheduledOrder](
	[TASKID] [int] NULL,
	[Domain] [nvarchar](50) NULL,
	[Site] [nvarchar](50) NULL,
	[IsSPSite] [nvarchar](50) NULL,
	[PO_Number] [nvarchar](50) NULL,
	[Supplier] [nvarchar](50) NULL,
	[Supplier_Name] [nvarchar](150) NULL,
	[Taxable] [nvarchar](50) NULL,
	[TAX_Class] [nvarchar](50) NULL,
	[TAX_Class_Desc] [nvarchar](50) NULL,
	[Ship_To] [nvarchar](50) NULL,
	[Ship_To_Address] [nvarchar](350) NULL,
	[Bill_To] [nvarchar](50) NULL,
	[Bill_To_Address] [nvarchar](350) NULL,
	[Credit_Terms] [nvarchar](50) NULL,
	[Credit_Terms_Desc] [nvarchar](150) NULL,
	[MFG_Duns] [nvarchar](50) NULL,
	[Vendor_Duns] [nvarchar](50) NULL,
	[Currency] [nvarchar](50) NULL,
	[Currency_Desc] [nvarchar](150) NULL,
	[Incoterms2010] [nvarchar](50) NULL,
	[Buyer] [nvarchar](50) NULL,
	[Buyer_Name] [nvarchar](50) NULL,
	[Title_Transfer] [nvarchar](50) NULL,
	[Comment] [nvarchar](max) NULL,
	[File1] [nvarchar](200) NULL,
	[Type] [nvarchar](50) NULL,
	[FormNo] [nvarchar](50) NULL,
	[Start_Effective] [datetime] NULL,
	[End_Effective] [datetime] NULL,
	[Complete] [bit] NULL,
	[ChangeList] [nvarchar](max) NULL,
	[ModifyComment] [nvarchar](100) NULL,
	[RequestName] [nvarchar](50) NULL,
	[poRev] [int] NULL,
	[Consignment] [nvarchar](50) NULL,
	[AlliedCompany] [nvarchar](50) NULL,
	[CostCenter] [nvarchar](50) NULL,
	[CostCenterDesc] [nvarchar](100) NULL,
	[CostCenterApprover] [nvarchar](50) NULL,
	[Plant] [nvarchar](50) NULL,
	[EDI] [bit] NULL,
	[PrintSchedule] [bit] NULL,
	[POCostPoint] [nvarchar](50) NULL,
	[TotalAmount] [decimal](18, 5) NULL,
	[Letter_comment] [nvarchar](50) NULL,
	[NLOCR] [nvarchar](50) NULL,
	[SN] [nvarchar](50) NULL,
	[PDate] [datetime] NULL,
	[APV] [decimal](18, 5) NULL,
	[Secure] [nvarchar](50) NULL,
	[Answer1] [nvarchar](500) NULL,
	[Answer2] [nvarchar](500) NULL,
	[Answer3] [nvarchar](500) NULL,
	[Answer4] [nvarchar](500) NULL,
	[Answer5] [nvarchar](500) NULL,
	[CheckTermsDay] [nvarchar](50) NULL,
	[SuppOfficialSeal] [nvarchar](20) NULL,
	[XXXOfficialSeal] [nvarchar](20) NULL,
	[CommercialMeetingApproval] [nvarchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SupplierScheduledOrderDetail]    Script Date: 3/1/2024 8:25:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SupplierScheduledOrderDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ORDERINDEX] [int] NULL,
	[TASKID] [int] NULL,
	[PO_Line] [int] NULL,
	[Ship_To_Site] [nvarchar](50) NULL,
	[Item_Number] [nvarchar](50) NULL,
	[Item_Desc] [nvarchar](250) NULL,
	[Taxable] [nvarchar](50) NULL,
	[Consignment] [nvarchar](50) NULL,
	[Location] [nvarchar](50) NULL,
	[Location_Desc] [nvarchar](100) NULL,
	[TAS_Class] [nvarchar](50) NULL,
	[TAS_Class_Desc] [nvarchar](50) NULL,
	[Unit_Of_Measure] [nvarchar](50) NULL,
	[UMConversion] [nvarchar](50) NULL,
	[MAX_Order_Qty] [nvarchar](50) NULL,
	[Type] [nvarchar](50) NULL,
	[Purchase_Account] [nvarchar](50) NULL,
	[Work_Order_ID] [nvarchar](50) NULL,
	[Sub_Account] [nvarchar](50) NULL,
	[Operation] [nvarchar](50) NULL,
	[CostCenter] [nvarchar](50) NULL,
	[Start_Effective] [date] NULL,
	[End_Effective] [date] NULL,
	[Comment] [nvarchar](max) NULL,
	[Firm_Days] [int] NULL,
	[Ship_Delivery_Pattern_Code] [nvarchar](50) NULL,
	[Schedule_Days] [int] NULL,
	[Schedule_Weeks] [int] NULL,
	[Schedule_Months] [int] NULL,
	[STD_Pack_Qty] [int] NULL,
	[Transport_Days] [int] NULL,
	[Safety_Days] [int] NULL,
	[SelectAll] [bit] NULL,
	[DeleteLine] [bit] NULL,
	[PriceCode] [nvarchar](8) NULL,
	[ProductLine] [nvarchar](50) NULL,
	[PreviousPartNumber] [nvarchar](50) NULL,
	[MonthsVolume] [numeric](18, 5) NULL,
	[Price] [numeric](18, 5) NULL,
	[FromRCPDate] [date] NULL,
	[MonthsVolumeCheck] [numeric](18, 5) NULL,
 CONSTRAINT [PK_SupplierScheduledOrderDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[SupplierScheduledOrderDetailPrice]    Script Date: 3/1/2024 8:15:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SupplierScheduledOrderDetailPrice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ForeignKey] [int] NULL,
	[TASKID] [int] NULL,
	[ORDERINDEX] [int] NULL,
	[ItemID] [int] NULL,
	[Start_Effective] [date] NULL,
	[End_Effective] [date] NULL,
	[BasePrice] [decimal](18, 5) NULL,
	[PTP] [decimal](18, 5) NULL,
	[MCIP] [decimal](18, 5) NULL,
	[ECON] [decimal](18, 5) NULL,
	[FX] [decimal](18, 5) NULL,
	[DesignChange] [decimal](18, 5) NULL,
	[Allied] [decimal](18, 5) NULL,
	[ToolingAmortization] [decimal](18, 5) NULL,
	[Other] [decimal](18, 5) NULL,
	[ContractPrice] [decimal](18, 5) NULL,
	[HLine] [bit] NULL,
	[PO_Line] [int] NULL,
	[Item_Number] [nvarchar](50) NULL,
	[PriceCode] [nvarchar](8) NULL,
	[Unit_Of_Measure] [nvarchar](50) NULL,
	[Other1] [decimal](18, 5) NULL,
	[Friction] [decimal](18, 5) NULL,
 CONSTRAINT [PK_SupplierScheduledOrderDetailPrice] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BPMInstTasks] ADD  CONSTRAINT [DF_BPMInstTasks_CreateAt]  DEFAULT (getdate()) FOR [CreateAt]
GO

ALTER TABLE [dbo].[BPMInstTasks] ADD  CONSTRAINT [DF_BPMInstTasks_Status]  DEFAULT ('running') FOR [State]
GO

ALTER TABLE [dbo].[BPMInstTasks] ADD  CONSTRAINT [DF__BPMInstTa__Proce__05D8E0BE]  DEFAULT ('1.0') FOR [ProcessVersion]
GO

ALTER TABLE [dbo].[M_Value] ADD  CONSTRAINT [DF_Value_id]  DEFAULT (replace(newid(),'-','')) FOR [id]
GO

ALTER TABLE [dbo].[SupplierScheduledOrderDetailPrice]  WITH CHECK ADD  CONSTRAINT [FK_SupplierScheduledOrderDetailPrice_SupplierScheduledOrderDetail] FOREIGN KEY([ForeignKey])
REFERENCES [dbo].[SupplierScheduledOrderDetail] ([ID])
GO

ALTER TABLE [dbo].[SupplierScheduledOrderDetailPrice] CHECK CONSTRAINT [FK_SupplierScheduledOrderDetailPrice_SupplierScheduledOrderDetail]
GO

/****** Object:  Table [dbo].[BPMSysUsers]    Script Date: 3/1/2024 8:29:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BPMSysUsers](
	[Account] [nvarchar](50) NOT NULL,
	[Password] [char](100) NOT NULL,
	[SysUser] [bit] NOT NULL,
	[DisplayName] [nvarchar](30) NULL,
	[Description] [nvarchar](200) NULL,
	[Sex] [char](7) NULL,
	[Birthday] [datetime] NULL,
	[HRID] [nvarchar](30) NULL,
	[DateHired] [datetime] NULL,
	[Office] [nvarchar](100) NULL,
	[CostCenter] [nvarchar](30) NULL,
	[OfficePhone] [nvarchar](30) NULL,
	[HomePhone] [nvarchar](30) NULL,
	[Mobile] [nvarchar](30) NULL,
	[EMail] [nvarchar](100) NULL,
	[WWWHomePage] [nvarchar](200) NULL,
	[Location] [nvarchar](50) NULL,
	[Age] [int] NULL,
	[UserLevel] [int] NULL,
	[家庭电话] [nvarchar](50) NULL,
	[SID] [char](36) NOT NULL,
	[LogonProvider] [nvarchar](30) NULL,
	[Disabled] [bit] NOT NULL,
	[NameSpell] [nvarchar](50) NULL,
	[ADACCOUNT] [nvarchar](50) NULL,
	[ADADDRESS] [nvarchar](50) NULL,
	[ADIdentification] [nvarchar](50) NULL,
	[Domain] [nvarchar](100) NULL,
	[Entity] [nvarchar](50) NULL,
	[PayeeName] [nvarchar](100) NULL,
	[BankAddress] [nvarchar](100) NULL,
	[BankName] [nvarchar](100) NULL,
	[BankAccount] [nvarchar](100) NULL,
	[ViewReportDomain] [nvarchar](100) NULL,
	[IsITUse] [nvarchar](10) NULL,
	[IsSpecial] [nvarchar](10) NULL,
	[IsPublic] [nvarchar](10) NULL,
	[POR] [nvarchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[ExpirationDate] [datetime] NULL,
	[SupplierCode] [nvarchar](200) NULL,
	[Grade] [int] NULL,
	[GradeDesc] [nvarchar](50) NULL,
 CONSTRAINT [YZPK_BPMSysUsers] PRIMARY KEY CLUSTERED 
(
	[Account] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BPMSysUsers] ADD  CONSTRAINT [DF_BPMSysUsers_SystemUser]  DEFAULT ((0)) FOR [SysUser]
GO

ALTER TABLE [dbo].[BPMSysUsers] ADD  CONSTRAINT [DF__BPMSysUsers__SID__30F848ED]  DEFAULT (newid()) FOR [SID]
GO

ALTER TABLE [dbo].[BPMSysUsers] ADD  CONSTRAINT [DF__BPMSysUse__Disab__4E88ABD4]  DEFAULT ((0)) FOR [Disabled]
GO


/****** Object:  Table [dbo].[CurrencyRata]    Script Date: 3/1/2024 9:05:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CurrencyRata](
	[Currency1] [nvarchar](50) NULL,
	[CurrencyDesc] [nvarchar](50) NULL,
	[Currency2] [nvarchar](50) NULL,
	[Rate] [decimal](18, 10) NULL
) ON [PRIMARY]
GO



/****** Object:  Table [dbo].[M_PO_Buyer]    Script Date: 3/1/2024 9:26:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[M_PO_Buyer](
	[code_domain] [nvarchar](50) NULL,
	[BuyerCode] [nvarchar](50) NULL,
	[BuyerName] [nvarchar](50) NULL,
	[EmployeeIsActive] [nvarchar](50) NULL,
	[BPMAccount] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[M_adjust_SupplierScheduledOrderDetailPrice]    Script Date: 3/1/2024 9:41:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[M_adjust_SupplierScheduledOrderDetailPrice](
	[new_ID] [int] IDENTITY(1,1) NOT NULL,
	[ID] [int] NULL,
	[BasePrice] [decimal](18, 5) NULL,
	[PTP] [decimal](18, 5) NULL,
	[MCIP] [decimal](18, 5) NULL,
	[ECON] [decimal](18, 5) NULL,
	[FX] [decimal](18, 5) NULL,
	[DesignChange] [decimal](18, 5) NULL,
	[Allied] [decimal](18, 5) NULL,
	[ToolingAmortization] [decimal](18, 5) NULL,
	[Other] [decimal](18, 5) NULL,
	[Other1] [decimal](18, 5) NULL,
	[ContractPrice] [decimal](18, 5) NULL,
	[Item_Number] [nvarchar](50) NULL,
	[PO_Number] [nvarchar](50) NULL,
	[PO_Line] [int] NULL,
	[PriceCode] [nvarchar](8) NULL,
	[Unit_Of_Measure] [nvarchar](50) NULL,
	[Start_effective] [date] NULL,
	[End_Effective] [date] NULL,
	[result] [nvarchar](200) NULL,
	[TaskId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[new_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


 
/****** Object:  Table [dbo].[M_PO_Company]    Script Date: 3/1/2024 9:48:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[M_PO_Company](
	[CompanyCode] [varchar](50) NOT NULL,
	[CompanyName] [varchar](200) NULL,
	[CompanyAddress] [varchar](200) NULL,
	[City] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Postal] [varchar](50) NULL,
	[Domain] [varchar](50) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[M_PO_PriceList]    Script Date: 3/1/2024 9:50:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[M_PO_PriceList](
	[pc_domain] [nvarchar](50) NULL,
	[pc_list] [nvarchar](50) NULL,
	[pc_desc] [nvarchar](100) NULL,
	[pc_part] [nvarchar](50) NULL,
	[ptdesc] [nvarchar](50) NULL,
	[pc_curr] [nvarchar](50) NULL,
	[pc_um] [nvarchar](50) NULL,
	[pc_start] [date] NULL,
	[pc_expire] [date] NULL,
	[Price] [decimal](20, 5)  NULL,
	[pc_list_classification] [int] NULL
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[AddSupplierScheduledOrderDetailPrice]    Script Date: 3/1/2024 9:54:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AddSupplierScheduledOrderDetailPrice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ForeignKey] [int] NULL,
	[TASKID] [int] NULL,
	[ORDERINDEX] [int] NULL,
	[ItemID] [int] NULL,
	[Start_Effective] [date] NULL,
	[End_Effective] [date] NULL,
	[BasePrice] [decimal](18, 5) NULL,
	[PTP] [decimal](18, 5) NULL,
	[MCIP] [decimal](18, 5) NULL,
	[ECON] [decimal](18, 5) NULL,
	[FX] [decimal](18, 5) NULL,
	[DesignChange] [decimal](18, 5) NULL,
	[Allied] [decimal](18, 5) NULL,
	[ToolingAmortization] [decimal](18, 5) NULL,
	[Other] [decimal](18, 5) NULL,
	[ContractPrice] [decimal](18, 5) NULL,
	[HLine] [bit] NULL,
	[PO_Line] [int] NULL,
	[Item_Number] [nvarchar](50) NULL,
	[PriceCode] [nvarchar](8) NULL,
	[Unit_Of_Measure] [nvarchar](50) NULL,
	[Other1] [decimal](18, 5) NULL,
	[Friction] [decimal](18, 5) NULL,
 CONSTRAINT [PK_AddSupplierScheduledOrderDetailPrice] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AddSupplierScheduledOrderDetailPrice]  WITH CHECK ADD  CONSTRAINT [FK_AddSupplierScheduledOrderDetailPrice_AddSupplierScheduledOrderDetail] FOREIGN KEY([ForeignKey])
REFERENCES [dbo].[AddSupplierScheduledOrderDetail] ([ID])
GO

ALTER TABLE [dbo].[AddSupplierScheduledOrderDetailPrice] CHECK CONSTRAINT [FK_AddSupplierScheduledOrderDetailPrice_AddSupplierScheduledOrderDetail]
GO


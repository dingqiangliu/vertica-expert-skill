USE [BPMDB5]
GO

/****** Object:  View [dbo].[CurrencyRata1]    Script Date: 3/1/2024 8:37:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CurrencyRata1]
AS
SELECT TOP (100) PERCENT exr_domain AS Domain, CASE WHEN b.exr_curr1 = 'cny' THEN b.exr_curr2 ELSE b.exr_curr1 END AS Currency1, CASE WHEN b.exr_curr2 = 'cny' THEN b.exr_curr2 ELSE b.exr_curr1 END AS Currency2, 
                  exr_start_date AS DateFrom, exr_end_date AS DateTo, CASE WHEN b.exr_curr1 = 'cny' THEN b.exr_rate ELSE b.exr_rate2 END AS Rate
FROM     pro2sql.dbo.exr_rate AS b WITH (nolock)
WHERE  (exr_domain = 'CHN02')
GO


/****** Object:  View [dbo].[v_PI_GSM_Datatype_FM]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_Datatype_FM]
AS
SELECT DISTINCT Year, DataType
FROM      dbo.PI_GSM_P2P_Sales_01
WHERE   (DataType <> '') AND (DataType IS NOT NULL)
GO


/****** Object:  View [dbo].[v_PI_GSM_P2P_03]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_03]
AS
SELECT        TOP (100) PERCENT a1.Domain, a1.Site, a1.SalablePartNo, a1.Customer, a1.Programs, a1.PL, a2.ps_comp, a2.psqtyper, a1.D1 * a2.psqtyper AS Jan_qty, a1.D2 * a2.psqtyper AS Feb_qty, a1.D3 * a2.psqtyper AS Mar_qty, 
                         a1.D4 * a2.psqtyper AS Apr_qty, a1.D5 * a2.psqtyper AS May_qty, a1.D6 * a2.psqtyper AS Jun_qty, a1.D7 * a2.psqtyper AS Jul_qty, a1.D8 * a2.psqtyper AS Aug_qty, a1.D9 * a2.psqtyper AS Sep_qty, 
                         a1.D10 * a2.psqtyper AS Oct_qty, a1.D11 * a2.psqtyper AS Nov_qty, a1.D12 * a2.psqtyper AS Dec_qty
FROM            dbo.PI_GSM_P2P_Sales_01 AS a1 INNER JOIN
                         dbo.M_BOM_BI_M1 AS a2 ON a1.Domain = a2.ps_domain AND a1.SalablePartNo = a2.ps_par
ORDER BY a1.Domain, a1.Site, a1.SalablePartNo, a1.Programs, a2.ps_comp, a2.psqtyper
GO

/****** Object:  View [dbo].[v_PI_GSM_P2P_04]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_04]
AS
SELECT        P.[Domain], P.[Site], P.[SalablePartNo],P.Customer, P.[Programs], P.PL,P.[ps_comp], P.[psqtyper], P.[CurrentYearMonth], P.MonthP2P
FROM            (SELECT        [Domain], [Site], [SalablePartNo], customer,[Programs], pl,[ps_comp], [psqtyper], [Jan_qty], [Feb_qty], [Mar_qty], [Apr_qty], [May_qty], [Jun_qty], [Jul_qty], [Aug_qty], [Sep_qty], [Oct_qty], [Nov_qty], [Dec_qty]
                          FROM            [BPMDB5].[dbo].[v_PI_GSM_P2P_03]) T UNPIVOT (MonthP2P FOR [CurrentYearMonth] IN ([Jan_qty], [Feb_qty], [Mar_qty], [Apr_qty], [May_qty], [Jun_qty], [Jul_qty], [Aug_qty], [Sep_qty], [Oct_qty], [Nov_qty], 
                         [Dec_qty])) P
GO

/****** Object:  View [dbo].[v_PI_GSM_SupplierScheduledOrderDetailPrice]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_SupplierScheduledOrderDetailPrice]
AS
SELECT        a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, CASE WHEN a1.baseprice <> a2.baseprice THEN a2.baseprice ELSE a1.baseprice END AS baseprice, 
                         CASE WHEN a1.PTP <> a2.PTP THEN a2.PTP ELSE a1.PTP END AS PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, a1.ToolingAmortization, a1.Other, a1.ContractPrice, a1.HLine, a1.PO_Line, a1.Item_Number, 
                         a1.PriceCode, a1.Unit_Of_Measure, a1.Other1, CASE WHEN a1.PTP <> a2.PTP THEN 1 ELSE 0 END AS IsPTPAdj, a1.PTP AS PTPBefore
FROM            dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1 LEFT OUTER JOIN
                         dbo.M_PI_adjust_SupplierScheduledOrderDetailPrice AS a2 ON a1.ID = a2.ID
GO


/****** Object:  View [dbo].[v_PI_GSM_P2P_05]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_05]
AS
SELECT        a1.Domain, a1.Site, a1.SalablePartNo, a1.Customer, a1.Programs, a1.PL, a1.ps_comp, a1.psqtyper, a1.CurrentYearMonth, a1.MonthP2P, a2.Year, a2.Month, a2.Lastday, a2.Month_char, a2.Firstday
FROM            dbo.v_PI_GSM_P2P_04 AS a1 INNER JOIN
                         dbo.PI_GSM_P2P_Calendar AS a2 ON a1.CurrentYearMonth = a2.Month_char
WHERE        (a2.Year = YEAR(GETDATE())) AND (a1.MonthP2P <> 0)
GO

/****** Object:  View [dbo].[v_PI_GSM_P2P_Baseprice_M1]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_Baseprice_M1]
AS
SELECT ROW_NUMBER() OVER (PARTITION BY (a1.domain + [ponumber] + CONVERT(nvarchar(50), [POLine]) + CONVERT(nvarchar(50), isnull([baseprice], 0)) + CONVERT(nvarchar(50), isnull([pcprice], 0)) + CONVERT(nvarchar(50), isnull([PTP], 0)) + CONVERT(nvarchar(50), IIndex))
ORDER BY [Index01] DESC) AS iCount, [domain], [ponumber], [POLine], [ItemNumber], [RecordDate], [PCStart], [PCExpire], [baseprice], [pcprice], [Index01], [ParentIndex], [IIndex], [PTP]
FROM   [dbo].PI_GSM_P2P_Baseprice_M1 AS a1 where PTP <> 0
GO

/****** Object:  View [dbo].[v_PI_GSM_P2P_Baseprice_M2]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_Baseprice_M2]
AS
SELECT        iCount, domain, ponumber, POLine, ItemNumber, RecordDate, PCStart, PCExpire, baseprice, pcprice, Index01, ParentIndex, IIndex, PTP
FROM            dbo.v_PI_GSM_P2P_Baseprice_M1
WHERE        (iCount = 1) AND (PTP <> 0) AND (Index01 NOT IN
                             (SELECT        ISNULL(ID, 0) AS Expr1
                               FROM            dbo.PI_GSM_P2P_Baseprice_M4))
GO

/****** Object:  View [dbo].[v_PI_GSM_P2P_Baseprice_M9]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_Baseprice_M9]
AS
SELECT        a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, a1.BasePrice, a1.PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, a1.ToolingAmortization, a1.Other, 
                         a1.ContractPrice, a1.HLine, a1.PO_Line, a1.Item_Number, a1.PriceCode, a1.Unit_Of_Measure, a1.Other1, a2.PO_Number, a2.Domain
FROM            dbo.BPMInstTasks AS a4 INNER JOIN
                         dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1 ON a4.TaskID = a1.TASKID INNER JOIN
                         dbo.SupplierScheduledOrder AS a2 ON a1.TASKID = a2.TASKID
WHERE        (a4.State = 'Approved') AND (a2.Domain = 'CHN02' OR
                         a2.Domain = 'CHN04' OR
                         a2.Domain = 'CHN07') AND (a2.Site <> 'SUZSP')
GO




/****** Object:  View [dbo].[v_PI_GSM_Forecast_ExchangeRate_L2]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_Forecast_ExchangeRate_L2]
AS
select a1.*,a2.Firstday,a2.Lastday
from
(
  SELECT        [Year]
      ,[VersionType]
      ,[BaseCurr]
      ,[TransCurr]
      ,[ID]
	  ,ForecastRate,
	  Month
FROM            (SELECT        [Year]
      ,[VersionType]
      ,[BaseCurr]
      ,[TransCurr]
      ,[JanRate]
      ,[FebRate]
      ,[MarRate]
      ,[AprRate]
      ,[MayRate]
      ,[JunRate]
      ,[JulRate]
      ,[AugRate]
      ,[SepRate]
      ,[OctRate]
      ,[NovRate]
      ,[DecRate]
      ,[ID]
                          FROM            [BPMDB5].[dbo].[PI_GSM_Forecast_ExchangeRate_L2]) T UNPIVOT (ForecastRate FOR Month IN ([JanRate]
      ,[FebRate]
      ,[MarRate]
      ,[AprRate]
      ,[MayRate]
      ,[JunRate]
      ,[JulRate]
      ,[AugRate]
      ,[SepRate]
      ,[OctRate]
      ,[NovRate]
      ,[DecRate])) P) AS a1 INNER JOIN
                         dbo.PI_GSM_P2P_Calendar AS a2 ON a1.Month = a2.[Month_char_Actual]
						 and  (a2.Year = a1.year)
GO

/****** Object:  View [dbo].[v_PI_GSM_P2P_Baseprice_M11]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_Baseprice_M11]
AS
SELECT   domain, ponumber, POLine, ItemNumber, RecordDate, PCStart, PCExpire, baseprice,
                             (SELECT   baseprice
                                FROM         dbo.PI_GSM_P2P_Baseprice_M2 AS a1
                                WHERE     (IIndex = 0) AND (domain = a3.domain) AND (ponumber = a3.ponumber) AND (POLine = a3.POLine) AND EXISTS
                                                             (SELECT   domain, ponumber, POLine, ItemNumber, RecordDate, PCStart, PCExpire, baseprice, pcprice, Index01, ParentIndex, IIndex, PTP, IsPTPAdj
                                                                FROM         dbo.PI_GSM_P2P_Baseprice_M2 AS a2
                                                                WHERE     (domain = a1.domain) AND (ponumber = a1.ponumber) AND (POLine = a1.POLine) AND (IIndex > 0) AND (pcprice = a1.baseprice))) AS Newbaseprice, pcprice, 
                         Index01, ParentIndex, IIndex, PTP, PTP - ISNULL
                             ((SELECT   SUM(PTP) AS Expr1
                                 FROM         dbo.PI_GSM_P2P_Baseprice_M2 AS a4
                                 WHERE     (domain = a3.domain) AND (ponumber = a3.ponumber) AND (POLine = a3.POLine) AND (IIndex > 1)
                                 GROUP BY ItemNumber), 0) AS NewPTP, IsPTPAdj
FROM         dbo.PI_GSM_P2P_Baseprice_M2 AS a3
WHERE     (IIndex = 1)
GO

/****** Object:  View [dbo].[v_PI_GSM_P2P_Baseprice_M12]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_Baseprice_M12]
AS
SELECT   domain, ponumber, POLine, ItemNumber, RecordDate, PCStart, PCExpire, baseprice, Newbaseprice, pcprice, Index01, ParentIndex, IIndex, PTP, NewPTP, IsPTPAdj
FROM         dbo.v_PI_GSM_P2P_Baseprice_M11
WHERE     (Newbaseprice IS NOT NULL) AND (RecordDate = PCStart)
GO

/****** Object:  View [dbo].[v_PI_GSM_P2P_Baseprice_M5]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_Baseprice_M5]
AS
SELECT        a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, ISNULL(a3.Newbaseprice, a2.BasePrice) AS BasePrice, ISNULL(a3.NewPTP, a2.PTP) AS PTP, a1.MCIP, a1.ECON, a1.FX, 
                         a1.DesignChange, a1.Allied, a1.ToolingAmortization, a1.Other, a1.ContractPrice, a1.HLine, a1.PO_Line, a1.Item_Number, a1.PriceCode, a1.Unit_Of_Measure, a1.Other1
FROM            dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1 INNER JOIN
                         dbo.M_PI_adjust_SupplierScheduledOrderDetailPrice AS a2 ON a1.ID = a2.ID AND a1.PTP <> a2.PTP LEFT OUTER JOIN
                         dbo.v_PI_GSM_P2P_Baseprice_M12 AS a3 ON a3.Index01 = a1.ID
GO




/****** Object:  View [dbo].[v_PI_GSM_P2P_13]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_13]
AS
SELECT        TOP (100) PERCENT a1.Domain, a1.Site, a1.SalablePartNo, a1.Customer, a1.Programs, a1.PL, b1.po_number AS PONumber, b1.PO_Line AS POLine, a2.ps_comp, a2.psqtyper, a1.D1 * a2.psqtyper AS Jan_qty, 
                         a1.D2 * a2.psqtyper AS Feb_qty, a1.D3 * a2.psqtyper AS Mar_qty, a1.D4 * a2.psqtyper AS Apr_qty, a1.D5 * a2.psqtyper AS May_qty, a1.D6 * a2.psqtyper AS Jun_qty, a1.D7 * a2.psqtyper AS Jul_qty, 
                         a1.D8 * a2.psqtyper AS Aug_qty, a1.D9 * a2.psqtyper AS Sep_qty, a1.D10 * a2.psqtyper AS Oct_qty, a1.D11 * a2.psqtyper AS Nov_qty, a1.D12 * a2.psqtyper AS Dec_qty
FROM            dbo.PI_GSM_P2P_Sales_01 AS a1 INNER JOIN
                         dbo.M_BOM_BI_M1 AS a2 ON a1.Domain = a2.ps_domain AND a1.SalablePartNo = a2.ps_par INNER JOIN
                             (SELECT DISTINCT domain, PO_Number, PO_Line, Item_Number
                               FROM            (SELECT        ROW_NUMBER() OVER (PARTITION BY (a1.domain + a1.item_number)
                                                         ORDER BY rcpdate DESC) AS iCount, a1.*
                               FROM            PI_GSM_P2P_M1 AS a1
                               WHERE        ptp <> 0) AS c1
WHERE        icount = 1) AS b1 ON b1.Domain = a1.Domain AND b1.Item_Number = a2.ps_comp
ORDER BY a1.Domain, a1.Site, a1.SalablePartNo, a1.Programs, a2.ps_comp, a2.psqtyper
GO




/****** Object:  View [dbo].[v_PI_GSM_P2P_09]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_09]
AS
SELECT        a1.prh_domain, a1.prh_site, a1.prh_nbr, a1.prh_line, a1.prh_part, a2.Year, a2.Month, a4.Firstday, SUM(a1.prh_rcvd) AS TotalRcvdbyMonth, a1.prh_curr, a1.prh_um
FROM            (SELECT        prh_domain, prh_site, prh_nbr, prh_line, prh_part, prh_rcvd, prh_type, CASE WHEN prh_um = 'EA' THEN 'PC' ELSE prh_um END AS prh_um, prh_curr, prh_rcp_date
                          FROM            pro2sql.dbo.prh_hist)
                          AS a1 INNER JOIN
                         pro2sql.dbo.po_mstr AS b1 ON b1.po_domain = a1.prh_domain AND b1.po_nbr = a1.prh_nbr INNER JOIN
                         dbo.PI_GSM_P2P_Calendar AS a2 ON YEAR(a1.prh_rcp_date) = a2.Year AND MONTH(a1.prh_rcp_date) = a2.Month INNER JOIN
                         dbo.PI_GSM_P2P_Calendar AS a4 ON a2.Year = a4.Year AND a2.Month = a4.Month
WHERE        (a2.Year = YEAR(GETDATE())) AND (a2.Month < MONTH(GETDATE())) AND (b1.po_sched = 1) AND (a1.prh_domain = 'CHN02' OR
                         a1.prh_domain = 'CHN04' OR
                         a1.prh_domain = 'CHN07') AND (a1.prh_type = '') AND (a1.prh_site <> 'SUZSP')
GROUP BY a1.prh_domain, a1.prh_site, a1.prh_nbr, a1.prh_line, a1.prh_part, a2.Year, a2.Month, a4.Firstday, a1.prh_curr, a1.prh_um
GO

/****** Object:  View [dbo].[v_PI_GSM_P2P_11]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_11]
AS
SELECT        a1.prh_domain, a1.prh_site, a1.prh_part, a2.Year, a2.Month, a1.prh_rcvd, a1.prh_rcp_date, a1.prh_nbr, a1.prh_line, ROUND(a1.prh_um_conv * a1.prh_pur_cost / a1.prh_ex_rate2, 5) AS RcvdPrice, 
                         a1.prh_um_conv * a1.prh_rcvd * a1.prh_pur_cost AS APVAmount, a1.prh_um_conv * a1.prh_rcvd * a1.prh_pur_cost / h3.Rate AS APVAmountUSD
FROM            pro2sql.dbo.prh_hist AS a1 INNER JOIN
                         pro2sql.dbo.po_mstr AS b1 ON b1.po_domain = a1.prh_domain AND b1.po_nbr = a1.prh_nbr INNER JOIN
                         dbo.PI_GSM_P2P_Calendar AS a2 ON YEAR(a1.prh_rcp_date) = a2.Year AND MONTH(a1.prh_rcp_date) = a2.Month LEFT OUTER JOIN
                         dbo.CurrencyRata1 AS h3 ON h3.Currency1 = 'USD' AND h3.Domain = a1.prh_domain AND h3.DateFrom <= a1.prh_rcp_date AND h3.DateTo >= a1.prh_rcp_date
WHERE        (a1.prh_domain = 'CHN02' OR
                         a1.prh_domain = 'CHN04' OR
                         a1.prh_domain = 'CHN07') AND (a1.prh_type = '') AND (a2.Year = YEAR(GETDATE())) AND (a2.Month < MONTH(GETDATE())) AND (b1.po_sched = 1) AND EXISTS
                             (SELECT        domain, ponumber, POLine, ItemNumber, RecordDate, PCStart, PCExpire, baseprice, pcprice, Index01, PTP
                               FROM            dbo.PI_GSM_P2P_Baseprice_FM AS b1
                               WHERE        (domain = a1.prh_domain) AND (ItemNumber = a1.prh_part))
GO



/****** Object:  View [dbo].[V_PO_Company]    Script Date: 3/1/2024 9:19:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_PO_Company]
AS
SELECT        ad_mstr_1.ad_domain, ad_mstr_1.ad_addr, LTRIM(RTRIM(businessrelation_1.businessrelationname1 + businessrelation_1.businessrelationname2 + businessrelation_1.businessrelationname3)) AS Name, 
                         LTRIM(RTRIM(address_1.addressstreet1 + address_1.addressstreet2 + address_1.addressstreet3)) AS Address, address_1.addresscity, ad_mstr_1.ad_country, address_1.addresszip
FROM            pro2sql.dbo.ad_mstr AS ad_mstr_1 INNER JOIN
                         pro2sql.dbo.businessrelation AS businessrelation_1 ON ad_mstr_1.ad_bus_relation = businessrelation_1.businessrelationcode INNER JOIN
                         pro2sql.dbo.address AS address_1 ON businessrelation_1.businessrelation_id = address_1.businessrelation_id
WHERE        (ad_mstr_1.ad_type = 'company') AND (ad_mstr_1.ad_domain = 'CHN02') AND (ad_mstr_1.ad_addr NOT LIKE '%SUZ01%') AND (ad_mstr_1.ad_addr LIKE '%-%') OR
                         (ad_mstr_1.ad_type = 'company') AND (ad_mstr_1.ad_domain <> 'CHN02') OR
                         (ad_mstr_1.ad_addr = 'SUZ5X')
GO


/****** Object:  View [dbo].[v_PO_Taxclass]    Script Date: 3/1/2024 9:21:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PO_Taxclass]
AS
SELECT tx2_domain, tx2_pt_taxc AS TaxClass, tx2_desc AS Description, '1' AS SpecialMeaning, ISNULL(tx2_tax_pct / 100, '0') AS TaxNum
FROM   pro2sql.dbo.tx2_mstr AS tx2_mstr_1
WHERE (tx2_pt_taxc <> '') AND (tx2_exp_date IS NULL) AND (tx2_tax_type = 'VAT')
GO


/****** Object:  View [dbo].[v_PaymentTerm]    Script Date: 3/1/2024 9:23:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PaymentTerm]
AS
SELECT        TOP (200) PaymentCondition_1.paymentconditioncode, ISNULL(pro2sql.dbo.translationstring.translationstringtext, PaymentCondition_1.paymentconditiondescript) AS PaymentConditionDescript, 
                         PaymentCondition_1.paymentconditiondaysmonths, PaymentCondition_1.paymentconditionperiodtype, 
                         CASE WHEN PaymentConditionPeriodType = 'DAYS' THEN PaymentConditionDaysMonths ELSE PaymentConditionDaysMonths * 30 END AS RPaymentDays, '1' AS SpecialMeaning
FROM            pro2sql.dbo.paymentcondition AS PaymentCondition_1 LEFT OUTER JOIN
                         pro2sql.dbo.translationstring ON pro2sql.dbo.translationstring.parentobject_id = PaymentCondition_1.paymentcondition_id AND pro2sql.dbo.translationstring.lng_id = 71228
GO

/****** Object:  View [dbo].[M_CurrencyRata]    Script Date: 3/1/2024 9:25:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[M_CurrencyRata]
AS
SELECT        Currency1, CurrencyDesc, Currency2, Rate
FROM            dbo.CurrencyRata
GO


/****** Object:  View [dbo].[v_PO_Supplier]    Script Date: 3/1/2024 9:20:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PO_Supplier]
AS
SELECT        a.Vendor, a.BusinessName, a.BusinessAddress, a.City, a.Postal, a.TaxIncluded, CAST(a.Taxable AS varchar) AS Taxable, a.TaxEnv, a.DUNS AS MFGDUNS, a.DUNS AS VendorDUNS, a.Domain, a.Currency, a.Remark, 
                         a.BankName, a.BankAccount, a.SwiftCode, a.Complete, b.TaxClass, b.Description AS TaxClassDesc, c.paymentconditioncode, c.PaymentConditionDescript, d.Rate, d.Currency1 AS CurrencyDesc, e.BuyerCode, e.BuyerName, 
                         '1' AS SpecialMeaning, a.Country, a.PaymentTerm
FROM            dbo.M_PO_Supplier AS a LEFT OUTER JOIN
                         dbo.v_PO_Taxclass AS b ON a.Domain = b.tx2_domain AND a.TaxClass = b.TaxClass LEFT OUTER JOIN
                         dbo.v_PaymentTerm AS c ON a.PaymentTerm = c.paymentconditioncode LEFT OUTER JOIN
                         dbo.M_CurrencyRata AS d ON a.Currency = d.Currency1 LEFT OUTER JOIN
                         dbo.M_PO_Buyer AS e ON a.Buyer = e.BuyerCode AND a.Domain = e.code_domain
GO

/****** Object:  View [dbo].[v_plantsplit_polist]    Script Date: 3/1/2024 8:52:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[v_plantsplit_polist]
AS
SELECT        a1.po_domain AS Domain, a2.pod_site AS Site, 
                         CASE WHEN pod_site = 'SUZ51' THEN 'XXX Co., Ltd - Plant 51' WHEN pod_site = 'SUZ53' THEN 'XXX Co., Ltd - Plant 53' WHEN pod_site = 'SUZEN' THEN 'XXX Co., Ltd - Engineering'
                          END AS SiteName, a1.po_vend AS SupplierCode, a6.BusinessName AS SupplierName, a1.po_ship AS [Ship-To], a4.Address AS [Ship-To address], a1.po_bill AS [Bill-To], a5.Address AS [Bill-To address], 
                         a1.po_nbr AS PONumber, a2.pod_line AS POLine, a2.pod__chr01 AS OldPONumber, a2.pod__chr02 AS OldPOLine, a2.pod_part AS ItemNumber, ISNULL(a7.pt_desc2, a2.pod_desc) AS [Desc.], 
                         CASE WHEN pod_sched = 1 THEN NULL ELSE pod_qty_ord END AS OrderQty, a2.pod_sched, a2.pod_start_eff__1, a2.pod_end_eff__1, a2.pod_type
FROM            pro2sql.dbo.po_mstr AS a1 INNER JOIN
                         pro2sql.dbo.pod_det AS a2 ON a1.po_domain = a2.pod_domain AND a1.po_nbr = a2.pod_nbr LEFT OUTER JOIN
                         pro2sql.dbo.pt_mstr AS a3 ON a1.po_domain = a3.pt_domain AND a2.pod_part = a3.pt_part LEFT OUTER JOIN
                         dbo.V_PO_Company AS a4 ON a4.ad_addr = a1.po_ship AND a4.ad_domain = a1.po_domain LEFT OUTER JOIN
                         dbo.V_PO_Company AS a5 ON a5.ad_addr = a1.po_bill AND a5.ad_domain = a1.po_domain LEFT OUTER JOIN
                         dbo.v_PO_Supplier AS a6 ON a6.Domain = a1.po_domain AND a6.Vendor = a1.po_vend LEFT OUTER JOIN
                         pro2sql.dbo.pt_mstr AS a7 ON a7.pt_domain = a1.po_domain AND a7.pt_part = a2.pod_part
WHERE        (a2.pod_site IN ('SUZ51', 'SUZ53', 'SUZEN')) AND (a1.po_nbr NOT LIKE 'A%')
GO


/****** Object:  View [dbo].[v_plantsplit_polist_02]    Script Date: 3/1/2024 8:54:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_plantsplit_polist_02]
AS
SELECT        a1.po_domain AS Domain, a2.pod_site AS Site, 
                         CASE WHEN pod_site = 'SUZ51' THEN 'XXX Co., Ltd - Plant 51' WHEN pod_site = 'SUZ53' THEN 'XXX Co., Ltd - Plant 53' WHEN pod_site = 'SUZEN' THEN 'XXX Co., Ltd - Engineering'
                          END AS SiteName, a1.po_vend AS SupplierCode, a6.BusinessName AS SupplierName, a1.po_ship AS [Ship-To], a4.Address AS [Ship-To address], a1.po_bill AS [Bill-To], a5.Address AS [Bill-To address], 
                         a1.po_nbr AS PONumber, a2.pod_line AS POLine, a2.pod__chr01 AS OldPONumber, a2.pod__chr02 AS OldPOLine, a2.pod_part AS ItemNumber, ISNULL(a7.pt_desc2, a2.pod_desc) AS [Desc.], 
                         CASE WHEN pod_sched = 1 THEN NULL ELSE pod_qty_ord END AS OrderQty, a2.pod_sched, a2.pod_start_eff__1, a2.pod_end_eff__1, a2.pod_type
FROM            pro2sql.dbo.po_mstr AS a1 INNER JOIN
                         pro2sql.dbo.pod_det AS a2 ON a1.po_domain = a2.pod_domain AND a1.po_nbr = a2.pod_nbr LEFT OUTER JOIN
                         pro2sql.dbo.pt_mstr AS a3 ON a1.po_domain = a3.pt_domain AND a2.pod_part = a3.pt_part LEFT OUTER JOIN
                         dbo.V_PO_Company AS a4 ON a4.ad_addr = a1.po_ship AND a4.ad_domain = a1.po_domain LEFT OUTER JOIN
                         dbo.V_PO_Company AS a5 ON a5.ad_addr = a1.po_bill AND a5.ad_domain = a1.po_domain LEFT OUTER JOIN
                         dbo.v_PO_Supplier AS a6 ON a6.Domain = a1.po_domain AND a6.Vendor = a1.po_vend LEFT OUTER JOIN
                         pro2sql.dbo.pt_mstr AS a7 ON a7.pt_domain = a1.po_domain AND a7.pt_part = a2.pod_part
WHERE        (a2.pod_site IN ('SUZ51', 'SUZ53', 'SUZEN'))
GO


/****** Object:  View [dbo].[v_PI_GSM_P2P_20]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_20]
AS
SELECT DISTINCT a1.prh_domain, a1.prh_site, a1.prh_nbr, a1.prh_line, a1.prh_part, a3.OldPONumber, a3.OldPOLine
FROM            pro2sql.dbo.prh_hist AS a1 INNER JOIN
                         dbo.PI_GSM_P2P_Calendar AS a2 ON YEAR(a1.prh_rcp_date) = a2.Year AND MONTH(a1.prh_rcp_date) = a2.Month LEFT OUTER JOIN
                         dbo.v_plantsplit_polist AS a3 ON a3.Domain = a1.prh_domain AND a3.PONumber = a1.prh_nbr AND a3.POLine = a1.prh_line
WHERE        (a1.prh_domain = 'CHN02' OR
                         a1.prh_domain = 'CHN04' OR
                         a1.prh_domain = 'CHN07') AND (a1.prh_type = '') AND (a2.Year = YEAR(GETDATE())) AND (a2.Month <= MONTH(GETDATE())) AND EXISTS
                             (SELECT        domain, ponumber, POLine, ItemNumber, RecordDate, PCStart, PCExpire, baseprice, pcprice, Index01, PTP
                               FROM            dbo.PI_GSM_P2P_Baseprice_FM AS b1
                               WHERE        (domain = a1.prh_domain) AND (ItemNumber = a1.prh_part))
GROUP BY a1.prh_domain, a1.prh_nbr, a1.prh_line, a1.prh_site, a1.prh_part, a2.Year, a2.Month, a3.OldPONumber, a3.OldPOLine
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_GSM_P2P_Baseprice_M9_adjust]
AS
SELECT        a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, a1.BasePrice, a1.PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, a1.ToolingAmortization, a1.Other, 
                         a1.ContractPrice, a1.HLine, ISNULL(a3.POLine, a1.PO_Line) AS PO_Line, a1.Item_Number, a1.PriceCode, a1.Unit_Of_Measure, a1.Other1, a2.PO_Number, a2.Domain
FROM            dbo.BPMInstTasks AS a4 INNER JOIN
                         dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1 ON a4.TaskID = a1.TASKID INNER JOIN
                         dbo.SupplierScheduledOrder AS a2 ON a1.TASKID = a2.TASKID LEFT OUTER JOIN
                         dbo.v_plantsplit_polist_02 AS a3 ON a3.PONumber NOT LIKE 'A%' AND a2.PO_Number = a3.OldPONumber AND a1.PO_Line = a3.OldPOLine AND a3.ItemNumber = a3.ItemNumber AND a3.OldPONumber <> ''
WHERE        (a4.State = 'Approved') AND (a2.Domain = 'CHN02' OR
                         a2.Domain = 'CHN04' OR
                         a2.Domain = 'CHN07') AND (a2.Site <> 'SUZSP')
GO


/****** Object:  View [dbo].[v_PI_M_Scheduled_Order]    Script Date: 2/29/2024 12:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_PI_M_Scheduled_Order]
AS
SELECT        po_mstr_1.po_domain AS Domain, po_mstr_1.po_nbr AS [PO Number], po_mstr_1.po_vend AS Supplier, po_mstr_1.po_taxable AS [Header Taxable], po_mstr_1.po_taxc AS [Header Tax Class], 
                         po_mstr_1.po_cr_terms AS [Credit Terms], po_mstr_1.po_curr AS Currency, po_mstr_1.po_buyer AS Buyer, po_mstr_1.po__chr09 AS [MFG Duns_], po_mstr_1.po__chr01 AS [Vendor Duns_], 
                         po_mstr_1.po__chr02 AS [Incoterms 2010], po_mstr_1.po__chr03 AS [Title Transfer], po_mstr_1.po_site AS Site, po_mstr_1.po_bill AS [Bill-To Address], po_mstr_1.po_ship AS [Ship-To Address], 
                         po_mstr_1.po_eff_strt AS [Header Start Effective], po_mstr_1.po_eff_to AS [Header End Effective], pod_det_1.pod_line AS [PO Line], pod_det_1.pod_part AS [Item Number], pod_det_1.pod_desc AS [Item Desc], 
                         pod_det_1.pod_pr_list AS [Price List Code], pod_det_1.pod_loc AS Location, pod_det_1.pod_um AS [Unit of Measure], pod_det_1.pod_type AS Type, pod_det_1.pod_wo_lot AS [Work Order ID], pod_det_1.pod_op AS Operation, 
                         pod_det_1.pod_site AS [Ship-To Site], po_mstr_1.po_consignment AS Consignment, pod_det_1.pod_taxable AS [Detail Taxable], pod_det_1.pod_taxc AS [Detail Tax Class], pod_det_1.pod_acct AS [Purchase Account], 
                         pod_det_1.pod_sub AS [Sub-Account], pod_det_1.pod_cc AS [Cost Center], pod_det_1.pod_sd_pat AS [Ship Delivery Pattern Code], pod_det_1.pod_firm_days AS [Firm Days], pod_det_1.pod_plan_days AS [Schedule Days], 
                         pod_det_1.pod_plan_weeks AS [Schedule Weeks], pod_det_1.pod_plan_mths AS [Schedule Months], pod_det_1.pod_translt_days AS [Transport Days], pod_det_1.pod_vpart AS [Supplier Item], 
                         pod_det_1.pod_cum_qty__3 AS [Max Order Qty], pod_det_1.pod_ord_mult AS [Std Pack Qty], pod_det_1.pod_start_eff__1 AS [Detail Start Effective], pod_det_1.pod_end_eff__1 AS [Detail End Effective], 
                         po_mstr_1.po_rev AS PORev, pod_det_1.pod_consignment AS PODConsignment, pod_det_1.pod_sftylt_days AS SafetyDays, pod_det_1.pod__dte02 AS RCPDate, pod_det_1.pod_um_conv
FROM            pro2sql.dbo.po_mstr AS po_mstr_1 INNER JOIN
                         pro2sql.dbo.pod_det AS pod_det_1 ON po_mstr_1.po_domain = pod_det_1.pod_domain AND po_mstr_1.po_nbr = pod_det_1.pod_nbr
WHERE        (po_mstr_1.po_sched = 1)
GO


/****** Object:  View [dbo].[PO_Taxclass]    Script Date: 3/1/2024 9:42:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PO_Taxclass]
AS
SELECT DISTINCT tx2_domain, tx2_pt_taxc AS TaxClass, MAX(tx2_desc) AS Description, tx2_tax_type AS TaxType, tx2_tax_pct AS TaxRate, tx2_ap_acct AS APInvTaxAcct, tx2_tax_code
FROM   pro2sql.dbo.tx2_mstr AS tx2_mstr_1
WHERE (tx2_pt_taxc <> '') AND (tx2_exp_date IS NULL)
GROUP BY tx2_domain, tx2_pt_taxc, tx2_tax_type, tx2_tax_pct, tx2_ap_acct, tx2_tax_code
UNION
SELECT 'SHP', 'V0', 'NON TAX', '', 0, '', ''
GO


/****** Object:  View [dbo].[PaymentTerm]    Script Date: 3/1/2024 9:43:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PaymentTerm]
AS
SELECT   PaymentCondition_1.paymentconditioncode, ISNULL(pro2sql.dbo.translationstring.translationstringtext, 
                PaymentCondition_1.paymentconditiondescript) AS PaymentConditionDescript, 
                PaymentCondition_1.paymentconditiondaysmonths, PaymentCondition_1.paymentconditionperiodtype, 
                CASE WHEN PaymentConditionPeriodType = 'DAYS' THEN PaymentConditionDaysMonths ELSE PaymentConditionDaysMonths
                 * 30 END AS RPaymentDays
FROM      pro2sql.dbo.paymentcondition AS PaymentCondition_1 LEFT OUTER JOIN
                pro2sql.dbo.translationstring ON 
                pro2sql.dbo.translationstring.parentobject_id = PaymentCondition_1.paymentcondition_id AND 
                pro2sql.dbo.translationstring.lng_id = 71228
WHERE   (PaymentCondition_1.paymentconditionisactive = '1')
GO


/****** Object:  View [dbo].[v_PO_Buyer]    Script Date: 3/1/2024 9:44:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[v_PO_Buyer]
AS
SELECT   code_domain, BuyerCode, BuyerName, '1' AS SpecialMeaning
FROM      dbo.M_PO_Buyer

GO


/****** Object:  View [dbo].[v_SparepartsDefaultSite]    Script Date: 3/1/2024 9:47:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_SparepartsDefaultSite]
AS
SELECT        dbo.M_Value.id, dbo.M_Value.source_id, dbo.M_Value.label AS Domain, dbo.M_Value.label_zh AS Site, dbo.M_Value.value AS POShipTo, dbo.M_Value.filter AS GoodsRecipient, dbo.M_Value.filter2 AS RecipientEmail, 
                         dbo.M_Value.filter3 AS RecipientExt, dbo.M_Value.filter4 AS ResponsibleStaff, b.DisplayName AS ResponsibleName, dbo.M_Value.filter5 AS ReasonforPurchase, dbo.M_Value.filter6 AS DeliveryAddressCH, 
                         dbo.M_Value.filter7 AS DeliveryAddressEN, dbo.BPMSysUsers.Account AS RecipientAccount, dbo.M_Value.filter8 AS CostCenter, dbo.M_Value.filter9 AS Location, dbo.M_Value.filter10 AS tcJournalCode, 
                         dbo.M_Value.filter11 AS QADEntity
FROM            dbo.M_Value LEFT OUTER JOIN
                         dbo.BPMSysUsers ON dbo.BPMSysUsers.EMail = dbo.M_Value.filter2 LEFT OUTER JOIN
                         dbo.BPMSysUsers AS b ON b.Account = dbo.M_Value.filter4
WHERE        (dbo.M_Value.source_id = '595EAD185D1A4651BCFE2103CB88EC74')
GO

/****** Object:  View [dbo].[M_PO_Site]    Script Date: 3/1/2024 9:45:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[M_PO_Site]
AS
SELECT        TOP (100) CASE WHEN si_site = 'SUE01' THEN 'Z' + si_site ELSE si_site END AS SiteIndex, si_desc AS SiteDesc, si_db AS Domain, si_entity AS Entity, si_site + ' ' + si_desc AS SiteName, CASE WHEN a2.site IS NULL 
                         THEN 0 ELSE 1 END AS Isspsite, si_site AS Site
FROM            pro2sql.dbo.si_mstr AS si_mstr_1 LEFT OUTER JOIN
                         v_SparepartsDefaultSite AS a2 ON si_mstr_1.si_db = a2.domain AND si_mstr_1.si_site = a2.site
WHERE        (si_type = 'True') and si_site <> 'SUZ01'
UNION
SELECT        'IN811', 'XXX India', 'IN81', 'IN81', 'Bangalore Plant 81', 0, 'IN811'
UNION
SELECT        'IN812', 'XXX India', 'IN81', 'IN81', 'Gurgaon Plant 82', 0, 'IN812'
UNION
SELECT        'IN813', 'XXX India', 'IN81', 'IN81', 'Pune Plant 83', 0, 'IN813'
UNION
SELECT        'IN814', 'XXX India', 'IN81', 'IN81', 'Chennai Plant 84', 0, 'IN814'
UNION
SELECT '','','CHN02', '','',0,''

GO

/****** Object:  View [dbo].[PO_Location]    Script Date: 3/1/2024 9:49:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PO_Location]
AS
SELECT        'CHN10' AS Domain, 'ZHZ01' AS Site, '' AS Location, '' AS Desciption, '' AS LocDesc, 0 AS InspectFlag
UNION ALL
SELECT        'CHN10' AS Domain, 'ZHZ02' AS Site, '' AS Location, '' AS Desciption, '' AS LocDesc, 0 AS InspectFlag
UNION ALL
SELECT        'CHN11' AS Domain, 'WUH01' AS Site, '' AS Location, '' AS Desciption, '' AS LocDesc, 0 AS InspectFlag
UNION ALL
SELECT        'CHN11' AS Domain, 'WUH02' AS Site, '' AS Location, '' AS Desciption, '' AS LocDesc, 0 AS InspectFlag
UNION ALL
SELECT        'CHN10' AS Domain, 'ZHZ01' AS Site, 'blank' AS Location, '' AS Desciption, '' AS LocDesc, 0 AS InspectFlag
UNION ALL
SELECT        'CHN10' AS Domain, 'ZHZ02' AS Site, 'blank' AS Location, '' AS Desciption, '' AS LocDesc, 0 AS InspectFlag
UNION ALL
SELECT        'CHN11' AS Domain, 'WUH01' AS Site, 'blank' AS Location, '' AS Desciption, '' AS LocDesc, 0 AS InspectFlag
UNION ALL
SELECT        'CHN11' AS Domain, 'WUH02' AS Site, 'blank' AS Location, '' AS Desciption, '' AS LocDesc, 0 AS InspectFlag
UNION ALL
SELECT        TOP (1000) loc_domain AS Domain, loc_site AS Site, loc_loc AS Location, loc_desc AS Desciption, loc_loc + ' ' + loc_desc AS LocDesc, 
                         CASE WHEN loc_loc = 'I00001' THEN 1 ELSE 0 END AS InspectFlag
FROM            pro2sql.dbo.loc_mstr AS loc_mstr_1
GO

/****** Object:  View [dbo].[MasterData_ItemList]    Script Date: 3/1/2024 9:51:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MasterData_ItemList]
AS
SELECT TOP (100000) pt_domain, pt_part, pt_desc1, pt_desc2, pt_um, pt_draw, pt_prod_line, pt_group, pt_part_type, pt_status, pt_rev, pt_site, pt_buyer, pt_ms, pt_ord_max, pt_ord_min, pt_ord_mult, pt_ord_per, pt_phantom, pt_plan_ord, pt_pm_code, pt_sfty_stk, pt_sfty_time, pt_timefence, 
             pt_yield_pct, pt_loc, pt_abc, pt_lot_ser, pt_article, pt_break_cat, pt__chr10 AS [HS Code], pt_drwg_size, pt_promo, pt_dsgn_grp, pt_added
FROM   pro2sql.dbo.pt_mstr AS pt_mstr_1
GO

/****** Object:  View [dbo].[v_SupplierScheduledOrderDetailPrice_adjust]    Script Date: 3/1/2024 9:52:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[v_SupplierScheduledOrderDetailPrice_adjust]
AS
SELECT        a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, a1.BasePrice, a1.PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, a1.ToolingAmortization, a1.Other, 
                         a1.ContractPrice, a1.HLine, ISNULL(b1.newpoline, a1.PO_Line) AS PO_Line, a1.Item_Number, a1.PriceCode, a1.Unit_Of_Measure, a1.Other1, a1.Friction
FROM            dbo.SupplierScheduledOrderDetailPrice AS a1 LEFT OUTER JOIN
                             (SELECT DISTINCT a1.domain, a1.ponumber, a1.POLine, a1.ItemNumber, a1.Index01, a2.PONumber AS newponumber, a2.POLine AS newpoline
                               FROM            dbo.PI_GSM_P2P_Baseprice_FM_History_adjust_2023 AS a1 INNER JOIN
                                                         dbo.v_plantsplit_polist_02 AS a2 ON a1.ItemNumber + a1.ponumber + CONVERT(nvarchar(5), a1.POLine) = a2.ItemNumber + a2.OldPONumber + CONVERT(nvarchar(5), a2.OldPOLine)
                               WHERE        (a2.PONumber NOT LIKE 'A%')) AS b1 ON a1.ID = b1.Index01 AND a1.Item_Number = b1.ItemNumber AND b1.POLine = a1.PO_Line
GO

/****** Object:  View [dbo].[v_M_adjust_SupplierScheduledOrderDetailPrice_adjust]    Script Date: 3/1/2024 9:52:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[v_M_adjust_SupplierScheduledOrderDetailPrice_adjust]
AS
SELECT        a1.new_ID, a1.ID, a1.BasePrice, a1.PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, a1.ToolingAmortization, a1.Other, a1.Other1, a1.ContractPrice, a1.Item_Number, a1.PO_Number, ISNULL(b1.newpoline, 
                         a1.PO_Line) AS PO_Line, a1.PriceCode, a1.Unit_Of_Measure, a1.Start_effective, a1.End_Effective, a1.result, a1.TaskId
FROM            dbo.M_adjust_SupplierScheduledOrderDetailPrice AS a1 LEFT OUTER JOIN
                             (SELECT DISTINCT a1.domain, a1.ponumber, a1.POLine, a1.ItemNumber, a1.Index01, a2.PONumber AS newponumber, a2.POLine AS newpoline
                               FROM            dbo.PI_GSM_P2P_Baseprice_FM_History_adjust_2023 AS a1 INNER JOIN
                                                         dbo.v_plantsplit_polist_02 AS a2 ON a1.ItemNumber + a1.ponumber + CONVERT(nvarchar(5), a1.POLine) = a2.ItemNumber + a2.OldPONumber + CONVERT(nvarchar(5), a2.OldPOLine)
                               WHERE        (a2.PONumber NOT LIKE 'A%')) AS b1 ON a1.ID = b1.Index01 AND a1.Item_Number = b1.ItemNumber AND b1.POLine = a1.PO_Line
GO

/****** Object:  View [dbo].[v_AddSupplierScheduledOrderDetailPrice_adjust]    Script Date: 3/1/2024 9:53:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[v_AddSupplierScheduledOrderDetailPrice_adjust]
AS
SELECT        a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, a1.BasePrice, a1.PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, a1.ToolingAmortization, a1.Other, 
                         a1.ContractPrice, a1.HLine, ISNULL(b1.newpoline, a1.PO_Line) AS PO_Line, a1.Item_Number, a1.PriceCode, a1.Unit_Of_Measure, a1.Other1, a1.Friction
FROM            dbo.AddSupplierScheduledOrderDetailPrice AS a1 LEFT OUTER JOIN
                             (SELECT DISTINCT a1.domain, a1.ponumber, a1.POLine, a1.ItemNumber, a1.Index01, a2.PONumber AS newponumber, a2.POLine AS newpoline
                               FROM            dbo.PI_GSM_P2P_Baseprice_FM_History_adjust_2023 AS a1 INNER JOIN
                                                         dbo.v_plantsplit_polist_02 AS a2 ON a1.ItemNumber + a1.ponumber + CONVERT(nvarchar(5), a1.POLine) = a2.ItemNumber + a2.OldPONumber + CONVERT(nvarchar(5), a2.OldPOLine)
                               WHERE        (a2.PONumber NOT LIKE 'A%')) AS b1 ON a1.ID = b1.Index01 AND a1.Item_Number = b1.ItemNumber AND b1.POLine = a1.PO_Line
GO





-- /****** Object:  View [dbo].[v_PI_GSM_M_Scheduled_Order_M4]    Script Date: 2/29/2024 12:16:55 PM ******/
-- SET ANSI_NULLS ON
-- GO
-- 
-- SET QUOTED_IDENTIFIER ON
-- GO
-- 
-- CREATE VIEW [dbo].[v_PI_GSM_M_Scheduled_Order_M4]
-- AS
-- SELECT        *
-- FROM            v_PI_GSM_M_Scheduled_Order_M3
-- UNION
-- SELECT        [Domain], [PONumber], [Supplier], [Complete], [SupplierName], [HeaderTaxble], [HeaderTaxClass], [TaxClassDesc.], [CreditTerms], [PaymentConditionDescript], [Currency], [Rate], [Buyer], [BuyerName], [MFG Duns_], 
--                          [Vendor Duns_], [Incoterms 2010], [Title Transfer], [Site], [SiteDesc], [BillToAddress], [Bill-ToAddressInf.], [ShipToAddress], [Ship-ToAddressInf.], [Header Start Effective], [Header End Effective], [POLine], [ItemNumber], [ItemDesc], 
--                          [Location], [Location_Desc], [UnitofMeasure], [Type], [Work Order ID], [Operation], [Ship-To Site], [Consignment], [Detail Taxable], [Detail Tax Class], [TaxDetailClassDesc], [Purchase Account], [Sub-Account], [Cost Center], 
--                          [Ship Delivery Pattern Code], [Firm Days], [Schedule Days], [Schedule Weeks], [Schedule Months], [Transport Days], [Supplier Item], [Max Qty], [Std Pack Qty], [PODStartEffective], [PODEndEffective], [PCStart], [PCExpire], 
--                          [PCPrice], [Filter1], [Filter2], [Price List Code], [ProductLine], [PORev], [PODConsignment], [SafetyDays]
-- FROM            dbo.M_PI_Scheduled_Order_EE AS a1
-- WHERE        NOT EXISTS
--                              (SELECT        *
--                                FROM            [dbo].v_PI_GSM_M_Scheduled_Order_M3 AS a2
--                                WHERE        a1.domain = a2.domain AND a1.itemnumber = a2.itemnumber) AND (PODEndEffective IS NULL OR
--                          PODEndEffective >= GETDATE() ) AND ([Header End Effective] IS NULL OR
--                          [Header End Effective] >= GETDATE()) AND PCExpire >= dateadd(year, datediff(year, 0, dateadd(year, 0, getdate() )), 0)
-- GO


-- /****** Object:  View [dbo].[v_PI_GSM_M_Scheduled_Order_M5]    Script Date: 2/29/2024 12:16:55 PM ******/
-- SET ANSI_NULLS ON
-- GO
-- 
-- SET QUOTED_IDENTIFIER ON
-- GO
-- 
-- 
-- CREATE VIEW [dbo].[v_PI_GSM_M_Scheduled_Order_M5]
-- AS
-- SELECT        [Domain], [PONumber], [Supplier], [Complete], [SupplierName], [HeaderTaxble], [HeaderTaxClass], [TaxClassDesc.], [CreditTerms], [PaymentConditionDescript], [Currency], [Rate], [Buyer], [BuyerName], [MFG Duns_], 
--                          [Vendor Duns_], [Incoterms 2010], [Title Transfer], [Site], [SiteDesc], [BillToAddress], [Bill-ToAddressInf.], [ShipToAddress], [Ship-ToAddressInf.], [Header Start Effective], [Header End Effective], [POLine], [ItemNumber], [ItemDesc], 
--                          [Location], [Location_Desc], [UnitofMeasure], [Type], [Work Order ID], [Operation], [Ship-To Site], [Consignment], [Detail Taxable], [Detail Tax Class], [TaxDetailClassDesc], [Purchase Account], [Sub-Account], [Cost Center], 
--                          [Ship Delivery Pattern Code], [Firm Days], [Schedule Days], [Schedule Weeks], [Schedule Months], [Transport Days], [Supplier Item], [Max Qty], [Std Pack Qty], [PODStartEffective], [PODEndEffective], [PCStart], [PCExpire], 
--                          [PCPrice], [Filter1], [Filter2], [Price List Code], [ProductLine], [PORev], [PODConsignment], [SafetyDays]
-- FROM            (SELECT        ROW_NUMBER() OVER (PARTITION BY (a1.domain + a1.itemnumber)
--                           ORDER BY domain, ponumber DESC, poline DESC) AS iCount, a1.*
-- FROM            [BPMDB5].[dbo].[v_PI_GSM_M_Scheduled_Order_M4] AS a1) AS b1
-- WHERE        icount = 1
-- GO


-- /****** Object:  View [dbo].[v_PI_GSM_M_Scheduled_Order_M6]    Script Date: 2/29/2024 12:16:55 PM ******/
-- SET ANSI_NULLS ON
-- GO
-- 
-- SET QUOTED_IDENTIFIER ON
-- GO
-- 
-- CREATE VIEW [dbo].[v_PI_GSM_M_Scheduled_Order_M6]
-- AS
-- SELECT        a1.Domain, a1.PONumber, a1.Supplier, a1.Complete, a1.SupplierName, a1.HeaderTaxble, a1.HeaderTaxClass, a1.[TaxClassDesc.], a1.CreditTerms, a1.PaymentConditionDescript, a1.Currency, a1.Rate, a1.Buyer, 
--                          a1.BuyerName, a1.[MFG Duns_], a1.[Vendor Duns_], a1.[Incoterms 2010], a1.[Title Transfer], a1.Site, a1.SiteDesc, a1.BillToAddress, a1.[Bill-ToAddressInf.], a1.ShipToAddress, a1.[Ship-ToAddressInf.], a1.[Header Start Effective], 
--                          a1.[Header End Effective], a1.POLine, a1.ItemNumber, a1.ItemDesc, a1.Location, a1.Location_Desc, a1.UnitofMeasure, a1.Type, a1.[Work Order ID], a1.Operation, a1.[Ship-To Site], a1.Consignment, a1.[Detail Taxable], 
--                          a1.[Detail Tax Class], a1.TaxDetailClassDesc, a1.[Purchase Account], a1.[Sub-Account], a1.[Cost Center], a1.[Ship Delivery Pattern Code], a1.[Firm Days], a1.[Schedule Days], a1.[Schedule Weeks], a1.[Schedule Months], 
--                          a1.[Transport Days], a1.[Supplier Item], a1.[Max Qty], a1.[Std Pack Qty], a1.PODStartEffective, a1.PODEndEffective, a1.PCStart, a1.PCExpire, a1.PCPrice, a1.Filter1, a1.Filter2, a1.[Price List Code], a1.ProductLine, a1.PORev, 
--                          a1.PODConsignment, a1.SafetyDays
-- FROM            dbo.v_PI_GSM_M_Scheduled_Order_M4 AS a1 INNER JOIN
--                          dbo.v_PI_GSM_M_Scheduled_Order_M5 AS a2 ON a1.Domain = a2.Domain AND a1.PONumber = a2.PONumber AND a1.POLine = a2.POLine AND a1.ItemNumber = a2.ItemNumber
-- GO


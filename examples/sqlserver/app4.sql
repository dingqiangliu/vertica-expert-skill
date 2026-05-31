USE [BPMDB5]
GO


/****** Object:  StoredProcedure [dbo].[P_PI_GSM_P2P_01]    Script Date: 2/29/2024 12:17:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PI_GSM_P2P_01] (@savingtype nvarchar(50))
	-- Add the parameters for the stored procedure here
AS
BEGIN
declare @d0 nvarchar(200)
declare @d1 nvarchar(200)
declare @d2 int
declare @d3 nvarchar(200)
declare @d4 decimal(18,5)
declare @avgoflastyearP2P decimal(18,5)
declare @lastdayoflastyearP2P decimal(18,5)
declare @d5 date
declare @p0 nvarchar(200)
declare @p1 nvarchar(200)
declare @p3 nvarchar(200)
declare @p4 nvarchar(200)
declare @POCurr nvarchar(200)
declare @POCurr2 nvarchar(200)
declare @unitofmeasure nvarchar(200)
declare @p2 nvarchar(200)
declare @p11 decimal(18,5)
declare @p12 decimal(18,5)
declare @p13 decimal(18,5)
declare @p14 decimal(18,5)
declare @p15 decimal(18,5)
declare @p16 decimal(18,5)
declare @p17 decimal(18,5)
declare @p18 decimal(18,5)
declare @p19 decimal(18,5)
declare @p20 decimal(18,5)
declare @p21 decimal(18,5)
declare @p22 decimal(18,5)
declare @p31 nvarchar(200)
declare @p32 nvarchar(200)
declare @p33 nvarchar(200)
declare @p34 nvarchar(200)
declare @dd0 date
declare @dd1 date
declare @dd2 date
declare @dd3 date
set @dd0 = dateadd(year, datediff(year, 0, dateadd(year, -1, getdate())), 0)
--2020-01-01 00:00:00.000
set @dd1 = dateadd(year, datediff(year, 0, dateadd(year, 0, getdate())), -1)
--2020-12-31 00:00:00.000
set @dd2 = dateadd(year, datediff(year, 0, dateadd(year, -1, getdate())), -1)
--2019-12-31 00:00:00.000
set @dd3 = dateadd(year, datediff(year, 0, dateadd(year, 0, getdate())), 0)
--2021-01-01 00:00:00.000
--声明游标
DECLARE PI_GSM_P2P_RC_00 CURSOR FAST_FORWARD FOR
select distinct Domain , Site ,ponumber,poline, ps_comp from v_PI_GSM_P2P_13  
delete  PI_GSM_P2P_FM where P2Ptype = 'Carryover' and savingtype = @savingtype

OPEN PI_GSM_P2P_RC_00 


--取第一条记录
FETCH NEXT FROM PI_GSM_P2P_RC_00 INTO @p0,@p1,@p3,@p4,@p2
WHILE @@FETCH_STATUS=0
BEGIN


set @avgoflastyearP2P = 
(select sum(rcdqty * PTP )/ iif(sum(rcdqty) = 0 , 1 ,isnull(sum(rcdqty),1)) from PI_GSM_P2P_M1 where domain = @p0 and po_number = @p3 and po_line = @p4 and item_number = @p2  group by domain,item_number)


set @lastdayoflastyearP2P = 
(select ISNULL(SUM(a1.PTP), 0) AS PTP
from PI_GSM_P2P_Baseprice_FM as a1 where a1.domain = @p0 and a1.ponumber = @p3 and a1.POLine = @p4 and a1.itemnumber = @p2  and year(a1.recorddate) = year(@dd0) and a1.pcstart >= @dd0 and a1.pcstart <= @dd1
group by a1.domain)


set @POCurr = 
(select top 1 currency
from M_PI_Scheduled_Order_EE as a1 where a1.domain = @p0 and a1.ponumber = @p3 and a1.POLine = @p4 and a1.itemnumber = @p2  
)


set @unitofmeasure = 
(select top 1 unitofmeasure
from M_PI_Scheduled_Order_EE as a1 where a1.domain = @p0 and a1.ponumber = @p3 and a1.POLine = @p4 and a1.itemnumber = @p2  
)


-- get past year P2P
-- calculate P2P Carryover

insert into PI_GSM_P2P_FM
select h1.Domain,h1.Site,SalablePartNo,Customer,Programs,PL,@p3,@p4,ps_comp,h1.Year,h1.Month,@POCurr,isnull(h3.forecastrate,1),'Carryover',isnull((@lastdayoflastyearP2P - @avgoflastyearP2P ) * ISNULL(MonthP2P / pod_um_conv, MonthP2P),0) ,
case when @pocurr<> 'CNY' then isnull((@lastdayoflastyearP2P - @avgoflastyearP2P) * ISNULL(MonthP2P / pod_um_conv, MonthP2P) * isnull(h2.forecastrate,0) / iif(h3.forecastrate = 0,1,isnull(h3.forecastrate,0)),0) else isnull((@lastdayoflastyearP2P - @avgoflastyearP2P) * ISNULL(MonthP2P / pod_um_conv, MonthP2P)  / iif(h3.forecastrate = 0 , 1,isnull(h3.forecastrate,0)),0) end as P2PUSD,0, @avgoflastyearP2P ,@lastdayoflastyearP2P,@savingtype,'Booked','Price reduction'
,ISNULL(MonthP2P / pod_um_conv, MonthP2P) as MonthQtyPur
from dbo.v_PI_GSM_P2P_05 as h1 left outer join
pro2sql.dbo.pod_det as z1 on z1.pod_domain = @p0 and z1.pod_nbr = @p3 and z1.pod_line = @p4
left outer join
 v_PI_GSM_Datatype_FM as b1 on 1=1
left outer join v_PI_GSM_Forecast_ExchangeRate_L2 as h2 on h2.transcurr = @POCurr and h2.firstday<= h1.firstday and h2.lastday >= h1.firstday 
and h2.versiontype = 'Budget' and h2.year = b1.year
left outer join v_PI_GSM_Forecast_ExchangeRate_L2 as h3 on h3.transcurr ='USD' and h3.firstday<= h1.firstday and h3.lastday >= h1.firstday 
and h3.versiontype  = 'Budget' and h3.year = b1.year
where  h1.domain = @p0 and ps_comp = @p2  AND (h1.Year = YEAR(GETDATE())) AND (h1.Month >= MONTH(GETDATE()))
-- calculate P2P of last day of each month

-- insert to final result



FETCH NEXT FROM PI_GSM_P2P_RC_00 INTO @p0,@p1,@p3,@p4,@p2
END

-- 关闭游标
CLOSE PI_GSM_P2P_RC_00 

-- 释放游标
DEALLOCATE PI_GSM_P2P_RC_00

END
GO

/****** Object:  StoredProcedure [dbo].[P_PI_BOM_BI_M1]    Script Date: 2/29/2024 12:17:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PI_BOM_BI_M1]
	-- Add the parameters for the stored procedure here
AS
BEGIN
declare @d0 nvarchar(200)
declare @d1 nvarchar(200)
--声明游标
DECLARE PI_M_BOM_BI_M1 CURSOR FAST_FORWARD FOR
select distinct domain, salablepartno from [dbo].[PI_GSM_P2P_Sales_01] 
truncate table M_BOM_BI_M1
OPEN PI_M_BOM_BI_M1 

--取第一条记录
FETCH NEXT FROM PI_M_BOM_BI_M1 INTO @d0,@d1
WHILE @@FETCH_STATUS=0
BEGIN



with temp as (
select ps_domain, ps_par,cast(ps_comp as NVARCHAR(MAX)) as pscomp,convert(decimal(18,5),ps_qty_per) as psqtyper,ps_start,ps_end from pro2sql.dbo.ps_mstr as a 
 where (ps_domain = 'CHN02' or ps_domain = 'CHN04' or ps_domain = 'CHN07') and (ps_start <= getdate()  or ps_start is null)
and (dateadd(second,-1,dateadd(day, 1, ps_end)) >= getdate() or ps_end is null) 
UNION ALL
select a.ps_domain, a.ps_par,cast( b.pscomp as NVARCHAR(MAX)) as pscomp,convert(decimal(18,5),a.ps_qty_per * b.psqtyper) as psqtyper,b.ps_start,b.ps_end from pro2sql.dbo.ps_mstr as a   inner join temp as b 
on b.ps_par = a.ps_comp and b.ps_domain = a.ps_domain
 where (a.ps_domain = 'CHN02' or a.ps_domain = 'CHN04' or a.ps_domain = 'CHN07') and (a.ps_start <= getdate() or a.ps_start is null)
and (dateadd(second,-1,dateadd(day, 1, a.ps_end)) >= getdate() or a.ps_end is null)
)
insert into M_BOM_BI_M1 
select ps_domain,ps_par,pscomp,sum(psqtyper) as psqtyper,NULL,NULL from temp , pro2sql.dbo.pt_mstr where ps_domain = @d0 and ps_par = @d1 and pt_domain = ps_domain and pt_part = pscomp and pt_phantom = 0
and not exists(select ps_par from temp as a1 where a1.ps_domain = temp.ps_domain and a1.ps_par = temp.pscomp and  pt_pm_code = 'L')
  group by 
ps_domain,ps_par,pscomp

FETCH NEXT FROM PI_M_BOM_BI_M1 INTO @d0,@d1
END

-- 关闭游标
CLOSE PI_M_BOM_BI_M1 

-- 释放游标
DEALLOCATE PI_M_BOM_BI_M1


insert into M_BOM_BI_M1 
select ps_domain,ps_par,ps_comp,sum(psqtyper) as psqtyper,NULL,NULL from TT_PI_M_BOM_BI_M2 as a1, pro2sql.dbo.pt_mstr,
(select distinct datatype,year from [dbo].[PI_GSM_P2P_Sales_01]) as a3 where a3.datatype = a1.Forecasttype and a3.year = a1.forecastyear and pt_domain = ps_domain and pt_part = ps_comp and pt_phantom = 0
and ps_domain + ps_par not in (select distinct ps_domain + ps_par from M_BOM_BI_M1)
  group by 
ps_domain,ps_par,ps_comp

insert into M_BOM_BI_M1 
select ps_domain,ps_par,ps_comp,sum(psqtyper) as psqtyper,NULL,NULL from TT_PI_M_BOM_BI_M2 as a1 left outer join pro2sql.dbo.pt_mstr as a2
on a1.ps_domain = pt_domain and ps_comp = pt_part
where pt_domain is null
  group by 
ps_domain,ps_par,ps_comp



insert into M_BOM_BI_M1 
select distinct domain,salablepartno,salablepartno,1,NULL,NULL
from [dbo].[PI_GSM_P2P_Sales_01] as a1 , pro2sql.dbo.pt_mstr as a2
where a1.domain = a2.pt_domain and a1.salablepartno = a2.pt_part and pt_prod_line like 'RM%' and
not exists(select ps_par from M_BOM_BI_M1 as a3 where a2.pt_domain = a3.ps_domain and a2.pt_part = a3.ps_par) 


truncate table dbo.M_PI_Scheduled_Order_EE
insert into dbo.M_PI_Scheduled_Order_EE 
SELECT          a1.Domain, [PO Number], Supplier,Complete,businessname, [Header Taxable], [Header Tax Class],a3.Description ,[Credit Terms],PaymentConditionDescript, a1.Currency,a5.rate, a1.Buyer, a6.BuyerName,[mfg duns_], [Vendor Duns_], [Incoterms 2010], [Title Transfer], a1.Site, sitename,[Bill-To Address],a8.CompanyAddress, [Ship-To Address], a9.CompanyAddress,
                         [Header Start Effective], [Header End Effective], [PO Line], [Item Number], isnull(pt_desc1+pt_desc2,[item desc]), a1.Location,a10.LocDesc, [Unit of Measure], Type, [Work Order ID], Operation, [Ship-To Site], Consignment, [Detail Taxable], 
                         [Detail Tax Class],a11.Description, [Purchase Account], [Sub-Account], [Cost Center], [Ship Delivery Pattern Code], [Firm Days], [Schedule Days], [Schedule Weeks], [Schedule Months], [Transport Days], [Supplier Item], [Max Order Qty], 
                         [Std Pack Qty], CONVERT(varchar(100), [Detail Start Effective], 23) as [Detail Start Effective], CONVERT(varchar(100), [Detail End Effective], 23) as [Detail End Effective] ,pc_start,pc_expire,a12.Price,  
						 a1.domain + a1.[PO Number], a1.domain + a1.[PO Number]+ convert(nvarchar(3),[PO Line]),a1.[Price List Code],a13.pt_prod_line,
						     PORev, PODConsignment, SafetyDays , RCPDate
FROM            dbo.v_PI_M_Scheduled_Order as a1  left outer join m_po_supplier as a2 on a1.domain = a2.domain and a1.Supplier = a2.Vendor 
left outer join PO_Taxclass as a3 on a1.domain = a3.tx2_domain and a1.[Header Tax Class] = a3.TaxClass 
left outer join PO_Taxclass as a11 on a1.domain = a11.tx2_domain and a1.[Detail Tax Class] = a11.TaxClass 
left outer join PaymentTerm as a4 on a4.paymentconditioncode = a1.[Credit Terms] 
left outer join CurrencyRata as a5 on a5.Currency1 = a1.currency
left outer join v_po_buyer as a6 on a6.code_domain = a1.domain and a6.BuyerCode = a1.Buyer
left outer join [dbo].[M_PO_Site] as a7 on a7.site = a1.site and a7.domain = a1.domain 
left outer join m_po_company as a8 on a8.domain = a1.domain and a8.CompanyCode = a1.[Bill-To Address]
left outer join m_po_company as a9 on a9.domain = a1.domain and a9.CompanyCode = a1.[Ship-To Address]
left outer join PO_Location as a10 on a10.Domain = a1.domain and a10.Location = a1.Location and a10.site = a1.site
left outer join M_PO_PriceList as a12 on a12.pc_domain = a1.domain and a12.pc_list = a1.[Price List Code] and a12.pc_part = a1.[Item Number] and a12.pc_curr = a1.Currency and pc_um = a1.[Unit of Measure] 
left outer join MasterData_ItemList as a13 on a13.pt_domain = a1.domain and a13.pt_part = a1.[Item Number]


delete [dbo].[PI_GSM_M_Scheduled_Order]
-- insert into [PI_GSM_M_Scheduled_Order]
-- select * from [v_PI_GSM_M_Scheduled_Order_M6] 
END
GO



/****** Object:  StoredProcedure [dbo].[P_PI_GSM_P2P_Carryover_Actual]    Script Date: 2/29/2024 12:17:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PI_GSM_P2P_Carryover_Actual] (@savingtype nvarchar(50))
	-- Add the parameters for the stored procedure here
AS
BEGIN
declare @d0 nvarchar(200)
declare @d1 nvarchar(200)
declare @d2 int
declare @d3 nvarchar(200)
declare @d4 decimal(18,5)
declare @d6 decimal(18,5)
declare @avgoflastyearP2P decimal(18,5)
declare @lastdayoflastyearP2P decimal(18,5)
declare @d5 date
declare @p0 nvarchar(200)
declare @p1 nvarchar(200)
declare @p3 nvarchar(200)
declare @p4 nvarchar(200)
declare @POCurr nvarchar(200)
declare @unitofmeasure nvarchar(50)
declare @p2 nvarchar(200)
declare @p11 decimal(18,5)
declare @p12 decimal(18,5)
declare @p13 decimal(18,5)
declare @p14 decimal(18,5)
declare @p15 decimal(18,5)
declare @p16 decimal(18,5)
declare @p17 decimal(18,5)
declare @p18 decimal(18,5)
declare @p19 decimal(18,5)
declare @p20 decimal(18,5)
declare @p21 decimal(18,5)
declare @p22 decimal(18,5)
declare @p31 nvarchar(200)
declare @p32 nvarchar(200)
declare @p33 nvarchar(200)
declare @p34 nvarchar(200)
declare @dd0 date
declare @dd1 date
declare @dd2 date
declare @dd3 date
declare @POPrice decimal(18,5)
set @dd0 = dateadd(year, datediff(year, 0, dateadd(year, -1, getdate())), 0)
--2020-01-01 00:00:00.000
set @dd1 = dateadd(year, datediff(year, 0, dateadd(year, 0, getdate())), -1)
--2020-12-31 00:00:00.000
set @dd2 = dateadd(year, datediff(year, 0, dateadd(year, -1, getdate())), -1)
--2019-12-31 00:00:00.000
set @dd3 = dateadd(year, datediff(year, 0, dateadd(year, 0, getdate())), 0)
--2021-01-01 00:00:00.000
--声明游标
DECLARE PI_GSM_P2P_RC_00 CURSOR FAST_FORWARD FOR
select prh_domain,prh_site,prh_nbr,prh_line, prh_part from v_PI_GSM_P2P_20  
truncate table PI_GSM_P2P_M1


OPEN PI_GSM_P2P_RC_00 


--取第一条记录
FETCH NEXT FROM PI_GSM_P2P_RC_00 INTO @p0,@p1,@p3,@p4,@p2
WHILE @@FETCH_STATUS=0
BEGIN

--声明游标
DECLARE PI_GSM_P2P_RC_01 CURSOR FAST_FORWARD FOR
	SELECT        prh_domain,  prh_nbr, prh_line,prh_part, prh_rcvd, prh_rcp_date,ROUND(prh_um_conv * prh_pur_cost / prh_ex_rate2, 5)
FROM            pro2sql.dbo.prh_hist
WHERE        (prh_domain = @p0) AND prh_nbr = @p3 and prh_line = @p4 and (prh_part = @p2) AND (prh_rcp_date >= @dd0) AND (prh_rcp_date <= @dd1) and prh_type = '' 
	order by prh_part


OPEN PI_GSM_P2P_RC_01 


--取第一条记录
FETCH NEXT FROM PI_GSM_P2P_RC_01 INTO @d0,@d1,@d2,@d3,@d4,@d5,@d6

WHILE @@FETCH_STATUS=0
BEGIN

set @POPrice = 
(select top 1 pcprice
from M_PI_Scheduled_Order_EE as a1 where a1.domain = @d0 and a1.ponumber = @d1 and a1.poline = @d2  and a1.itemnumber = @d3  and a1.pcstart <= @d5 and a1.pcexpire >= @d5
)
if (round(@POPrice,4) <> round(@d6,4))
begin
Insert into PI_GSM_P2P_M1
select a2.domain,a2.ponumber,a2.poline,a2.itemnumber,@d4 as RcdQty,0,ISNULL(SUM(isnull(a1.PTP,0)), 0) AS PTP,0,0,0,0,0,0,0,0,@d5 as Rcpdate,a2.currency,a2.unitofmeasure
from (select * from M_PI_Scheduled_Order_EE as a1 where a1.domain = @d0 and a1.ponumber = @d1 and a1.poline = @d2  and a1.itemnumber = @d3  and a1.pcstart <= @d5 and a1.pcexpire >= @d5) as a2 left outer join 
PI_GSM_P2P_Baseprice_FM as a1 on a1.domain = a2.domain and a1.ponumber = a2.ponumber and a1.poline = a2.poline 
and a1.domain = @d0 and a1.PONumber = @d1 and  a1.POLine = @d2 and  (a1.ItemNumber = @d3)  AND (a1.pcstart >= @dd0) AND (a1.pcstart <= @d5) and year(a1.recorddate) = year(@dd0) and
exists(select b1.PTP from PI_GSM_P2P_Baseprice_FM as b1 where b1.domain = @d0 and b1.ponumber = @d1 and b1.poline = @d2 and b1.itemnumber = @d3 and year(b1.recorddate) = year(@dd0) and  b1.pcprice = @d6 and b1.pcstart <= @d5 and a1.PCStart <= b1.PCStart)
group by a2.domain,a2.ponumber,a2.poline,a2.itemnumber, a2.currency,a2.unitofmeasure
end
else 
begin
Insert into PI_GSM_P2P_M1
select a2.domain,a2.ponumber,a2.poline,a2.itemnumber,@d4 as RcdQty,0,ISNULL(SUM(isnull(a1.PTP,0)), 0) AS PTP,0,0,0,0,0,0,0,0,@d5 as Rcpdate,a2.currency,a2.unitofmeasure
from (select * from M_PI_Scheduled_Order_EE as a1 where a1.domain = @d0 and a1.ponumber = @d1 and a1.poline = @d2  and a1.itemnumber = @d3  and a1.pcstart <= @d5 and a1.pcexpire >= @d5) as a2 left outer join 
PI_GSM_P2P_Baseprice_FM as a1 on a1.domain = a2.domain and a1.ponumber = a2.ponumber and a1.poline = a2.poline 
and a1.domain = @d0 and a1.PONumber = @d1 and  a1.POLine = @d2 and  (a1.ItemNumber = @d3)  AND (a1.pcstart >= @dd0) AND (a1.pcstart <= @d5) and year(a1.recorddate) = year(@dd0) 
group by a2.domain,a2.ponumber,a2.poline,a2.itemnumber, a2.currency,a2.unitofmeasure
end



	 -- 取下一条记录
    FETCH NEXT FROM PI_GSM_P2P_RC_01 INTO @d0,@d1,@d2,@d3,@d4,@d5,@d6
END

-- 关闭游标
CLOSE PI_GSM_P2P_RC_01 

-- 释放游标
DEALLOCATE PI_GSM_P2P_RC_01 
-- get receive data end

set @POCurr = 
(select top 1 currency
from M_PI_Scheduled_Order_EE as a1 where a1.domain = @d0 and a1.ponumber = @d1 and a1.poline = @d2  and a1.itemnumber = @d3  
)


set @avgoflastyearP2P = 
(select sum(rcdqty * PTP )/ iif(sum(rcdqty) = 0 , 1 ,isnull(sum(rcdqty),1))  from PI_GSM_P2P_M1 where domain = @p0 and po_number = @p3 and po_line = @p4 and item_number = @p2  group by domain,item_number)
-- get past year avg P2P

set @lastdayoflastyearP2P = 
(select ISNULL(SUM(a1.PTP), 0) AS PTP
from PI_GSM_P2P_Baseprice_FM as a1 where a1.domain = @p0 and a1.ponumber = @p3 and a1.POLine = @p4 and a1.itemnumber = @p2  and year(a1.recorddate) = year(@dd0) and a1.pcstart >= @dd0 and a1.pcstart <= @dd1
group by a1.domain)



-- get past year P2P
-- calculate P2P Carryover


insert into PI_GSM_P2P_Actual_FM
select h1.prh_domain,h1.prh_site,prh_nbr,prh_line,prh_part,h1.Year,h1.Month,@POCurr,isnull(h3.forecastrate,1),'Carryover',ISNULL((@lastdayoflastyearP2P - @avgoflastyearP2P ) * TotalRcvdbyMonth,0) ,
case when @pocurr<> 'CNY' then ISNULL((@lastdayoflastyearP2P - @avgoflastyearP2P) * TotalRcvdbyMonth * isnull(h2.forecastrate,0) / isnull(h3.forecastrate,0),0) else ISNULL((@lastdayoflastyearP2P - @avgoflastyearP2P) * TotalRcvdbyMonth  / isnull(h3.forecastrate,0),0) end as P2PUSD,
@lastdayoflastyearP2P as lastdayoflastyearP2P , @avgoflastyearP2P as avgoflastyearP2P,@savingtype,TotalRcvdbyMonth
from [v_PI_GSM_P2P_09] as h1 
left outer join
 v_PI_GSM_Datatype_FM as b1 on 1=1
left outer join v_PI_GSM_Forecast_ExchangeRate_L2 as h2 on h2.transcurr = @POCurr and h2.firstday<= h1.firstday and h2.lastday >= h1.firstday 
and h2.versiontype = 'Budget' and h2.year = b1.year
left outer join v_PI_GSM_Forecast_ExchangeRate_L2 as h3 on h3.transcurr ='USD' and h3.firstday<= h1.firstday and h3.lastday >= h1.firstday 
and h3.versiontype  = 'Budget' and h3.year = b1.year
where  h1.prh_domain = @p0 and h1.prh_nbr = @p3 and prh_line = @p4 and prh_part = @p2 and prh_curr = @POCurr
-- calculate P2P of last day of each month

-- insert to final result



FETCH NEXT FROM PI_GSM_P2P_RC_00 INTO @p0,@p1,@p3,@p4,@p2
END

-- 关闭游标
CLOSE PI_GSM_P2P_RC_00 

-- 释放游标
DEALLOCATE PI_GSM_P2P_RC_00


insert into PI_GSM_P2P_M1_history
select 
*
from PI_GSM_P2P_M1

END
GO


/****** Object:  StoredProcedure [dbo].[P_PI_P2P_Core_M4]    Script Date: 2/29/2024 12:17:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PI_P2P_Core_M4] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @dd3 date
declare @dd2 date
declare @dd4 date
set @dd3 = dateadd(year, datediff(year, 0, dateadd(year, -1, getdate())), 0)
-- 2020-01-01 00:00:00.000
set @dd2 = dateadd(year, datediff(year, 1, dateadd(year, 0, getdate())), -1)
-- 2020-12-31 00:00:00.000
DECLARE @cnt INT = 1;
declare @dd1 date
set @dd1 = dateadd(year, datediff(year, 0, dateadd(year, -1, getdate())), -1)
-- 2019-12-31 00:00:00.000

set @dd4 = dateadd(year, datediff(year, 0, dateadd(year, -2, getdate())), 0)
-- 2019-01-01 00:00:00.000
delete PI_GSM_P2P_Baseprice_M2

insert into PI_GSM_P2P_Baseprice_M2
select domain, po_number, PO_Line, Item_Number,@dd3,A1.Start_Effective,a1.End_Effective,BasePrice as Baseprice,ContractPrice,ID as Index01, '' as ParentIdex  , 1 as IIndex , PTP , 1 as IsPTPAdj
from
dbo.SupplierScheduledOrder AS a2 ,
dbo.v_PI_GSM_P2P_Baseprice_M5 AS a1  ,
                         dbo.BPMInstTasks AS a4 
WHERE a1.TASKID = a4.TaskID  and a1.TASKID = a2.TASKID 
   and (a4.[State] = 'Approved')
   and (a1.Start_Effective = @dd3 ) 
    and a1.baseprice <> a1.contractprice 

insert into PI_GSM_P2P_Baseprice_M2
select a1.domain, a1.ponumber, a1.POLine, a1.ItemNumber,@dd1,a1.PCStart,a1.PCExpire,a1.pcprice as Baseprice,a1.pcprice as ContractPrice,'firstdayofperiod-1' as Index01, '' as ParentIdex  , 0 as IIndex , 0 as P2P , 0 as IsPTPAdj
from PI_GSM_M_Scheduled_Order as a1 , PI_GSM_P2P_Baseprice_M2 as a2 where 
a1.PCStart <= @dd1 and a1.PCExpire>= @dd1 and a1.domain = a2.domain and  a1.ponumber = a2.ponumber and a1.poline = a2.poline 


WHILE @cnt < 10
BEGIN
SET @cnt = @cnt + 1;
insert into PI_GSM_P2P_Baseprice_M2
select a2.domain, po_number, PO_Line, Item_Number,@dd3,A1.Start_Effective,a1.End_Effective,a1.BasePrice as Baseprice,a1.ContractPrice,a1.ID as Index01, '' as ParentIdex  , @cnt as IIndex , a1.PTP , 1 as IsPTPAdj
 from
dbo.SupplierScheduledOrder AS a2 ,
dbo.v_PI_GSM_SupplierScheduledOrderDetailPrice AS a1  ,
                         dbo.BPMInstTasks AS a4 ,PI_GSM_P2P_Baseprice_M2 as a3
WHERE a1.TASKID = a4.TaskID  and a1.TASKID = a2.TASKID and a3.Domain = a2.domain  and 
 a3.ponumber = a2.po_number and a3.poline = a1.PO_Line and  (a3.ItemNumber = a1.item_number)  
   and (a4.[State] = 'Approved')
   and (a1.Start_Effective >= @dd4) and (a1.Start_Effective <= @dd1) and a1.baseprice <> a1.contractprice
   and ((IIndex = 1 and round(a1.baseprice,4) = round(a3.baseprice,4)) or ( IIndex>1 and round(a1.baseprice,4) = round(a3.pcprice,4) ))
   and convert(nvarchar(50),a1.id) not in (select a4.Index01 from PI_GSM_P2P_Baseprice_M2 as a4 ) and a3.IIndex <> 0
end;

    -- Insert statements for procedure here
END
GO

/****** Object:  StoredProcedure [dbo].[P_PI_P2P_Core_M3]    Script Date: 2/29/2024 12:17:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PI_P2P_Core_M3] (@savingtype nvarchar(50))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @dd3 date
declare @dd2 date
set @dd3 = dateadd(year, datediff(year, 0, dateadd(year, -1, getdate())), 0)
-- 2020-01-01 00:00:00.000
set @dd2 = dateadd(year, datediff(year, 1, dateadd(year, 0, getdate())), -1)
-- 2020-12-31 00:00:00.000
DECLARE @cnt INT = 1;
declare @dd1 date
set @dd1 = dateadd(year, datediff(year, 0, dateadd(year, -1, getdate())), -1)
-- 2019-12-31 00:00:00.000
delete PI_GSM_P2P_Baseprice_M1
delete PI_GSM_P2P_Baseprice_M3






insert into PI_GSM_P2P_Baseprice_M1
select domain, ponumber, POLine, ItemNumber,@dd2,PCStart,PCExpire,pcprice as Baseprice,pcprice as ContractPrice,'lastdayofperiod' as Index01, '' as ParentIdex  , 0 as IIndex , 0 as P2P , 0 as IsPTPAdj
from M_PI_Scheduled_Order_EE where PCStart <= @dd2 and PCExpire>= @dd2


insert into PI_GSM_P2P_Baseprice_M1
select domain, ponumber, POLine, ItemNumber,@dd1,PCStart,PCExpire,pcprice as Baseprice,pcprice as ContractPrice,'firstdayofperiod-1' as Index01, '' as ParentIdex  , @cnt as IIndex , 0 as P2P , 0 as IsPTPAdj
from M_PI_Scheduled_Order_EE where PCStart <= @dd1 and PCExpire>= @dd1

WHILE @cnt < 10
BEGIN
SET @cnt = @cnt + 1;


insert into PI_GSM_P2P_Baseprice_M1
select a2.domain, a2.po_number,a1.po_line,a1.item_number,@dd3,a1.start_effective,a1.end_effective,a1.baseprice,contractprice,convert(nvarchar(50),a1.id) as Index01, a3.Index01 AS ParentIdex,@cnt,a1.PTP , 1 
from
dbo.SupplierScheduledOrder AS a2 ,
dbo.v_PI_GSM_P2P_Baseprice_M5 AS a1  ,
                         dbo.BPMInstTasks AS a4 ,PI_GSM_P2P_Baseprice_M1 as a3
WHERE a1.TASKID = a4.TaskID  and a1.TASKID = a2.TASKID and a3.Domain = a2.domain  and 
 a3.ponumber = a2.po_number and a3.poline = a1.PO_Line and  (a3.ItemNumber = a1.item_number)  
   and (a4.[State] = 'Approved')
   and (a1.Start_Effective >= @dd3) and (a1.Start_Effective <= @dd2) and round(a1.baseprice,4) = round(a3.pcprice,4)
   and ((@cnt = 2 and a3.Index01 = 'firstdayofperiod-1') OR (@cnt > 2 and a3.iindex > 1 and convert(nvarchar(50),a1.id) not in (select a4.Index01 from PI_GSM_P2P_Baseprice_M1 as a4 ))) and (a1.baseprice <> a1.contractprice or a1.PTP <> 0)
   and (a2.Domain = 'CHN02' OR
             a2.Domain = 'CHN04' OR a2.Domain = 'CHN07')  AND (a2.Site <> 'SUZSP' or a2.Site is null)


insert into PI_GSM_P2P_Baseprice_M1
select a2.domain, a2.po_number,a1.po_line,a1.item_number,@dd3,a1.start_effective,a1.end_effective,a1.baseprice,contractprice,convert(nvarchar(50),a1.id) as Index01, a3.Index01 AS ParentIdex,@cnt,a1.PTP , 0 as IsPTPAdj
from
dbo.SupplierScheduledOrder AS a2 ,
dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1  ,
                         dbo.BPMInstTasks AS a4 ,PI_GSM_P2P_Baseprice_M1 as a3
WHERE a1.TASKID = a4.TaskID  and a1.TASKID = a2.TASKID and a3.Domain = a2.domain  and 
 a3.ponumber = a2.po_number and a3.poline = a1.PO_Line and  (a3.ItemNumber = a1.item_number)  
   and (a4.[State] = 'Approved')
   and (a1.Start_Effective >= @dd3) and (a1.Start_Effective <= @dd2) and round(a1.baseprice,4) = round(a3.pcprice,4)
   and ((@cnt = 2 and a3.Index01 = 'firstdayofperiod-1') OR (@cnt > 2 and a3.iindex > 1 and convert(nvarchar(50),a1.id) not in (select a4.Index01 from PI_GSM_P2P_Baseprice_M1 as a4 ))) and convert(nvarchar(50),a1.id) not in (select a5.ID from v_PI_GSM_P2P_Baseprice_M5 as a5 ) and  (a1.baseprice <> a1.contractprice or a1.PTP <> 0)
      and (a2.Domain = 'CHN02' OR
             a2.Domain = 'CHN04' OR a2.Domain = 'CHN07')  AND (a2.Site <> 'SUZSP' or a2.Site is null)



END;
    -- Insert statements for procedure here

insert into PI_GSM_P2P_Baseprice_M4
select 'Booked',Domain, ID, TASKID, PO_Number, PO_Line, Item_Number, Start_Effective, End_Effective, BasePrice,NULL, PTP,NULL, ContractPrice,year(@dd3),@savingtype,'Price reduction','Carryover'
from
(
SELECT Domain, ID, TASKID, PO_Number, PO_Line, Item_Number, Start_Effective, End_Effective, BasePrice, PTP, ContractPrice
FROM   
(
SELECT a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, a1.BasePrice, a1.PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, a1.ToolingAmortization, a1.Other, a1.ContractPrice, a1.HLine, a1.PO_Line, a1.Item_Number, a1.PriceCode, 
             a1.Unit_Of_Measure, a1.Other1, a2.PO_Number, a2.Domain
FROM   dbo.BPMInstTasks AS a4 INNER JOIN
             dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1 ON a4.TaskID = a1.TASKID INNER JOIN
             dbo.SupplierScheduledOrder AS a2 ON a1.TASKID = a2.TASKID
WHERE (a4.State = 'Approved') AND (a1.Start_Effective >= @dd3) AND (a1.Start_Effective <= @dd2)  AND (a2.Domain = 'CHN02' OR
             a2.Domain = 'CHN04' OR a2.Domain = 'CHN07') AND (a1.PTP <> 0) AND (a2.Site <> 'SUZSP' or a2.Site is null)
) AS a1
WHERE (CONVERT(nvarchar(50), ID)  NOT IN
                 (SELECT Index01 
                 FROM    dbo.v_PI_GSM_P2P_Baseprice_M2 AS a2))
            AND (CONVERT(nvarchar(50), ID)  NOT IN
                 (SELECT  ID 
                 FROM    
				 (SELECT Domain, CONVERT(nvarchar(50), ID) as ID, TASKID, PO_Number, PO_Line, Item_Number, Start_Effective, End_Effective, BasePrice, PTP, ContractPrice
FROM   (SELECT a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, a1.BasePrice, a1.PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, a1.ToolingAmortization, a1.Other, a1.ContractPrice, a1.HLine, a1.PO_Line, a1.Item_Number, a1.PriceCode, 
             a1.Unit_Of_Measure, a1.Other1, a2.PO_Number, a2.Domain
FROM   dbo.BPMInstTasks AS a4 INNER JOIN
             dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1 ON a4.TaskID = a1.TASKID INNER JOIN
             dbo.SupplierScheduledOrder AS a2 ON a1.TASKID = a2.TASKID
WHERE (a4.State = 'Approved') AND (a1.Start_Effective >= @dd3) AND (a1.Start_Effective <= @dd2)  AND (a2.Domain = 'CHN02' OR
             a2.Domain = 'CHN04' OR a2.Domain = 'CHN07') AND (a1.PTP <> 0) AND (a2.Site <> 'SUZSP' or a2.Site is null)) AS a1
WHERE 
not exists 
				 (
				 select domain, ponumber, POLine, ItemNumber
from M_PI_Scheduled_Order_EE as d1 where PCStart <= @dd1 and PCExpire>= @dd1 and d1.domain = a1.domain and d1.ponumber = a1.po_number and d1.poline = a1.po_line 
				 ) and
EXISTS
                 (SELECT Domain, PO_Number, PO_Line, Item_Number
                 FROM    (SELECT Domain, PO_Number, PO_Line, Item_Number
                               FROM    dbo.v_PI_GSM_P2P_Baseprice_M9 where baseprice <> contractprice
                               GROUP BY Domain, PO_Number, PO_Line, Item_Number
                               HAVING (MIN(Start_Effective) >= @dd3)) AS a2
                 WHERE (a1.Domain = Domain) AND (a1.PO_Number = PO_Number) AND (a1.PO_Line = PO_Line))) as d1
				 ))
UNION
SELECT a1.Domain, a1.Index01, a3.taskid, ponumber, poline, itemnumber, pcstart, pcexpire, a1.baseprice, a1.PTP, pcprice
FROM   v_PI_GSM_P2P_Baseprice_M2 AS a1, M_PI_SupplierScheduledOrderDetailPrice AS a3
WHERE a1.index01 = a3.id AND EXISTS
                 (SELECT domain, ponumber, poline, recorddate, IINDEX
                 FROM    v_PI_GSM_P2P_Baseprice_M1 AS a2
                 WHERE a2.domain = a1.domain AND a2.ponumber = a1.ponumber AND a2.poline = a1.poline AND a1.recorddate = a2.recorddate AND PTP <> 0 AND IINDEX > 1
                 GROUP BY domain, ponumber, poline, recorddate, baseprice, IINDEX
                 HAVING count(IINDEX) > 1) ) as b1 where  not exists (select id from PI_GSM_P2P_Baseprice_M4 as c1 where c1.id = b1.id and c1.savingtype = @savingtype and c1.forecastyear = year(@dd3) )


insert into PI_GSM_P2P_Baseprice_M3
SELECT   Domain,  PO_Number, PO_Line, Item_Number,@dd3 as RecordDate, Start_Effective, End_Effective, BasePrice,  ContractPrice,id,PTP
FROM    
(
SELECT   a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, a1.BasePrice, a1.PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, 
                         a1.ToolingAmortization, a1.Other, a1.ContractPrice, a1.HLine, a1.PO_Line, a1.Item_Number, a1.PriceCode, a1.Unit_Of_Measure, a1.Other1, a2.PO_Number, a2.Domain
FROM         dbo.BPMInstTasks AS a4 INNER JOIN
                         dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1 ON a4.TaskID = a1.TASKID INNER JOIN
                         dbo.SupplierScheduledOrder AS a2 ON a1.TASKID = a2.TASKID
WHERE     (a4.State = 'Approved') AND (a1.Start_Effective >= @dd3) AND (a1.Start_Effective <= @dd2)  AND (a2.Domain = 'CHN02' OR
                         a2.Domain = 'CHN04' OR a2.Domain = 'CHN07') AND (a1.PTP <> 0) AND (a2.Site <> 'SUZSP' or a2.Site is null)
)
 AS a1
WHERE  (CONVERT(nvarchar(50), ID) NOT IN
                 (SELECT Index01
                 FROM    dbo.v_PI_GSM_P2P_Baseprice_M2 AS a2)) and not exists 
				 (
				 select domain, ponumber, POLine, ItemNumber
from M_PI_Scheduled_Order_EE as d1 where PCStart <= @dd1 and PCExpire>= @dd1 and d1.domain = a1.domain and d1.ponumber = a1.po_number and d1.poline = a1.po_line 
				 )
				  and  EXISTS
                             (SELECT   Domain, PO_Number, PO_Line, Item_Number
                                FROM         (SELECT   Domain, PO_Number, PO_Line, Item_Number
                                                           FROM         dbo.v_PI_GSM_P2P_Baseprice_M9 where baseprice <> contractprice
                                                           GROUP BY Domain, PO_Number, PO_Line, Item_Number
                                                           HAVING   (MIN(Start_Effective) >= @dd3)) AS a2
                                WHERE     (a1.Domain = Domain) AND (a1.PO_Number = PO_Number) AND (a1.PO_Line = PO_Line))

insert into [PI_GSM_P2P_Baseprice_M4]
select 'Booked',a3.Domain,ID,a1.Taskid,PO_Number,PO_Line,Item_Number,a1.Start_Effective,a1.End_Effective,BasePrice,NULL AS NewBasePrice,PTP,NULL AS newPTP,ContractPrice,year(a1.start_effective) as ForecastYear,@savingtype,'Price reduction','Carryover'
from M_PI_AddSupplierScheduledOrderDetailPrice as a1 ,[dbo].[SupplierScheduledOrder] AS a3, BPMInstTasks as a2  where a1.taskid = a3.taskid and a1.taskid = a2.taskid and a2.state = 'Approved' and ptp <> 0 and a1.start_effective >= @dd3 and 
a1.start_effective <= @dd2 and
(CONVERT(nvarchar(50), a1.ID) + @savingtype) not in (select CONVERT(nvarchar(50), ID) + savingtype from [dbo].[PI_GSM_P2P_Baseprice_M4])

delete PI_GSM_P2P_Baseprice_FM where year(recorddate) = year(@dd3)
insert into PI_GSM_P2P_Baseprice_FM
select *from 
(SELECT [domain], [ponumber], [POLine], [ItemNumber], [RecordDate], [PCStart], [PCExpire], [baseprice], [pcprice], [Index01], [PTP]
FROM   PI_GSM_P2P_Baseprice_M3
UNION
SELECT [domain], [ponumber], [POLine], [ItemNumber], [RecordDate], [PCStart], [PCExpire], [baseprice], [pcprice], [Index01], [PTP]
FROM   v_PI_GSM_P2P_Baseprice_M2
UNION
SELECT [Domain], [PO_Number], [PO_Line], [Item_Number], dateadd(year, datediff(year, 0, dateadd(year, 0, start_effective)), 0), [Start_Effective], [End_Effective], [NewBasePrice], [ContractPrice], id, [NewPTP]
FROM   [dbo].[PI_GSM_P2P_Baseprice_M4] where year(@dd3) = year(start_effective)and savingtype = @savingtype and confidencephase = 'Booked' and confidencelevel in ('New Booked','Carryover')) as d1

insert into PI_GSM_P2P_Baseprice_M1_history
select 
[domain]
      ,[ponumber]
      ,[POLine]
      ,[ItemNumber]
      ,[RecordDate]
      ,[PCStart]
      ,[PCExpire]
      ,[baseprice]
      ,[pcprice]
      ,[Index01]
      ,[ParentIndex]
      ,[IIndex]
      ,[PTP]
      ,[IsPTPAdj]
	  ,@savingtype
From PI_GSM_P2P_Baseprice_M1
insert into PI_GSM_P2P_Baseprice_M2_history
select [domain]
      ,[ponumber]
      ,[POLine]
      ,[ItemNumber]
      ,[RecordDate]
      ,[PCStart]
      ,[PCExpire]
      ,[baseprice]
      ,[pcprice]
      ,[Index01]
      ,[ParentIndex]
      ,[IIndex]
      ,[PTP]
      ,[IsPTPAdj]
	  ,@savingtype
From PI_GSM_P2P_Baseprice_M2
insert into PI_GSM_P2P_Baseprice_M3_history
select 
[domain]
      ,[ponumber]
      ,[POLine]
      ,[ItemNumber]
      ,[RecordDate]
      ,[PCStart]
      ,[PCExpire]
      ,[baseprice]
      ,[pcprice]
      ,[Index01]
      ,[PTP]
	  ,@savingtype
From PI_GSM_P2P_Baseprice_M3

insert into PI_GSM_P2P_Baseprice_FM_History
select 
[domain]
      ,[ponumber]
      ,[POLine]
      ,[ItemNumber]
      ,[RecordDate]
      ,[PCStart]
      ,[PCExpire]
      ,[baseprice]
      ,[pcprice]
      ,[Index01]
      ,[PTP]
	  ,@savingtype
from PI_GSM_P2P_Baseprice_FM where year(recorddate) = year(@dd3)



END
GO

/****** Object:  StoredProcedure [dbo].[P_PI_P2P_Core_M2]    Script Date: 2/29/2024 12:17:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PI_P2P_Core_M2] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @dd3 date
declare @dd2 date
declare @dd4 date
set @dd3 = dateadd(year, datediff(year, 0, dateadd(year, 0, getdate())), 0)
-- 2021-01-01 00:00:00.000
set @dd2 = dateadd(year, datediff(year, 1, dateadd(year, 1, getdate())), -1)
-- 2021-12-31 00:00:00.000
DECLARE @cnt INT = 1;
declare @dd1 date
set @dd1 = dateadd(year, datediff(year, 0, dateadd(year, 0, getdate())), -1)
-- 2020-12-31 00:00:00.000

set @dd4 = dateadd(year, datediff(year, 0, dateadd(year, -1, getdate())), 0)
-- 2020-01-01 00:00:00.000
delete PI_GSM_P2P_Baseprice_M2


insert into PI_GSM_P2P_Baseprice_M2
select domain, po_number, PO_Line, Item_Number,@dd3,A1.Start_Effective,a1.End_Effective,BasePrice as Baseprice,ContractPrice,ID as Index01, '' as ParentIdex  , 1 as IIndex , PTP , 1 as IsPTPAdj
from
dbo.SupplierScheduledOrder AS a2 ,
dbo.v_PI_GSM_P2P_Baseprice_M5 AS a1  ,
                         dbo.BPMInstTasks AS a4 
WHERE a1.TASKID = a4.TaskID  and a1.TASKID = a2.TASKID 
   and (a4.[State] = 'Approved')
   and (a1.Start_Effective = @dd3 ) 
    and a1.baseprice <> a1.contractprice 

insert into PI_GSM_P2P_Baseprice_M2
select a1.domain, a1.ponumber, a1.POLine, a1.ItemNumber,@dd1,a1.PCStart,a1.PCExpire,a1.pcprice as Baseprice,a1.pcprice as ContractPrice,'firstdayofperiod-1' as Index01, '' as ParentIdex  , 0 as IIndex , 0 as P2P , 0 as IsPTPAdj
from PI_GSM_M_Scheduled_Order as a1 , PI_GSM_P2P_Baseprice_M2 as a2 where 
a1.PCStart <= @dd1 and a1.PCExpire>= @dd1 and a1.domain = a2.domain and  a1.ponumber = a2.ponumber and a1.poline = a2.poline 


WHILE @cnt < 10
BEGIN
SET @cnt = @cnt + 1;
insert into PI_GSM_P2P_Baseprice_M2
select a2.domain, po_number, PO_Line, Item_Number,@dd3,A1.Start_Effective,a1.End_Effective,a1.BasePrice as Baseprice,a1.ContractPrice,a1.ID as Index01, '' as ParentIdex  , @cnt as IIndex , a1.PTP , 1 as IsPTPAdj
 from
dbo.SupplierScheduledOrder AS a2 ,
dbo.v_PI_GSM_SupplierScheduledOrderDetailPrice AS a1  ,
                         dbo.BPMInstTasks AS a4 ,PI_GSM_P2P_Baseprice_M2 as a3
WHERE a1.TASKID = a4.TaskID  and a1.TASKID = a2.TASKID and a3.Domain = a2.domain  and 
 a3.ponumber = a2.po_number and a3.poline = a1.PO_Line and  (a3.ItemNumber = a1.item_number)  
   and (a4.[State] = 'Approved')
   and (a1.Start_Effective >= @dd4) and (a1.Start_Effective <= @dd1) and a1.baseprice <> a1.contractprice
   and ((IIndex = 1 and round(a1.baseprice,4) = round(a3.baseprice,4)) or ( IIndex>1 and round(a1.baseprice,4) = round(a3.pcprice,4) ))
   and convert(nvarchar(50),a1.id) not in (select a4.Index01 from PI_GSM_P2P_Baseprice_M2 as a4 ) and a3.IIndex <> 0
end;

    -- Insert statements for procedure here
END
GO

/****** Object:  StoredProcedure [dbo].[P_PI_P2P_Core_M1]    Script Date: 2/29/2024 12:17:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PI_P2P_Core_M1] (@savingtype nvarchar(50))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @dd3 date
declare @dd2 date
set @dd3 = dateadd(year, datediff(year, 0, dateadd(year, 0, getdate())), 0)
-- 2021-01-01 00:00:00.000
set @dd2 = dateadd(year, datediff(year, 1, dateadd(year, 1, getdate())), -1)
-- 2021-12-31 00:00:00.000
DECLARE @cnt INT = 1;
declare @dd1 date
set @dd1 = dateadd(year, datediff(year, 0, dateadd(year, 0, getdate())), -1)
-- 2020-12-31 00:00:00.000
delete PI_GSM_P2P_Baseprice_M1
delete PI_GSM_P2P_Baseprice_M3

insert into PI_GSM_P2P_Baseprice_M1
select domain, ponumber, POLine, ItemNumber,@dd2,PCStart,PCExpire,pcprice as Baseprice,pcprice as ContractPrice,'lastdayofperiod' as Index01, '' as ParentIdex  , 0 as IIndex , 0 as P2P , 0 as IsPTPAdj
from M_PI_Scheduled_Order_EE where PCStart <= @dd2 and PCExpire>= @dd2


insert into PI_GSM_P2P_Baseprice_M1
select domain, ponumber, POLine, ItemNumber,@dd1,PCStart,PCExpire,pcprice as Baseprice,pcprice as ContractPrice,'firstdayofperiod-1' as Index01, '' as ParentIdex  , @cnt as IIndex , 0 as P2P , 0 as IsPTPAdj
from M_PI_Scheduled_Order_EE where PCStart <= @dd1 and PCExpire>= @dd1

WHILE @cnt < 10
BEGIN
SET @cnt = @cnt + 1;


insert into PI_GSM_P2P_Baseprice_M1
select a2.domain, a2.po_number,a1.po_line,a1.item_number,@dd3,a1.start_effective,a1.end_effective,a1.baseprice,contractprice,convert(nvarchar(50),a1.id) as Index01, a3.Index01 AS ParentIdex,@cnt,a1.PTP , 1 
from
dbo.SupplierScheduledOrder AS a2 ,
dbo.v_PI_GSM_P2P_Baseprice_M5 AS a1  ,
                         dbo.BPMInstTasks AS a4 ,PI_GSM_P2P_Baseprice_M1 as a3
WHERE a1.TASKID = a4.TaskID  and a1.TASKID = a2.TASKID and a3.Domain = a2.domain  and 
 a3.ponumber = a2.po_number and a3.poline = a1.PO_Line and  (a3.ItemNumber = a1.item_number)  
   and (a4.[State] = 'Approved')
   and (a1.Start_Effective >= @dd3) and (a1.Start_Effective <= @dd2) and round(a1.baseprice,4) = round(a3.pcprice,4)
   and ((@cnt = 2 and a3.Index01 = 'firstdayofperiod-1') OR (@cnt > 2 and a3.iindex > 1 and convert(nvarchar(50),a1.id) not in (select a4.Index01 from PI_GSM_P2P_Baseprice_M1 as a4 ))) and (a1.baseprice <> a1.contractprice or a1.PTP <> 0)
      and (a2.Domain = 'CHN02' OR
             a2.Domain = 'CHN04' OR a2.Domain = 'CHN07')  AND (a2.Site <> 'SUZSP' or a2.Site is null)


insert into PI_GSM_P2P_Baseprice_M1
select a2.domain, a2.po_number,a1.po_line,a1.item_number,@dd3,a1.start_effective,a1.end_effective,a1.baseprice,contractprice,convert(nvarchar(50),a1.id) as Index01, a3.Index01 AS ParentIdex,@cnt,a1.PTP , 0 as IsPTPAdj
from
dbo.SupplierScheduledOrder AS a2 ,
dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1  ,
                         dbo.BPMInstTasks AS a4 ,PI_GSM_P2P_Baseprice_M1 as a3
WHERE a1.TASKID = a4.TaskID  and a1.TASKID = a2.TASKID and a3.Domain = a2.domain  and 
 a3.ponumber = a2.po_number and a3.poline = a1.PO_Line and  (a3.ItemNumber = a1.item_number)  
   and (a4.[State] = 'Approved')
   and (a1.Start_Effective >= @dd3) and (a1.Start_Effective <= @dd2) and round(a1.baseprice,4) = round(a3.pcprice,4)
   and ((@cnt = 2 and a3.Index01 = 'firstdayofperiod-1') OR (@cnt > 2 and a3.iindex > 1 and convert(nvarchar(50),a1.id) not in (select a4.Index01 from PI_GSM_P2P_Baseprice_M1 as a4 ))) and convert(nvarchar(50),a1.id) not in (select a5.ID from v_PI_GSM_P2P_Baseprice_M5 as a5 ) and  (a1.baseprice <> a1.contractprice OR a1.PTP <> 0)
      and (a2.Domain = 'CHN02' OR
             a2.Domain = 'CHN04' OR a2.Domain = 'CHN07')  AND (a2.Site <> 'SUZSP' or a2.Site is null)



END;
    -- Insert statements for procedure here

insert into PI_GSM_P2P_Baseprice_M4
select 'Booked',Domain, ID, TASKID, PO_Number, PO_Line, Item_Number, Start_Effective, End_Effective, BasePrice,NULL, PTP,NULL, ContractPrice,year(@dd3),@savingtype,'Price reduction','New Booked'
from
(
SELECT Domain, ID, TASKID, PO_Number, PO_Line, Item_Number, Start_Effective, End_Effective, BasePrice, PTP, ContractPrice
FROM   
(
SELECT a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, a1.BasePrice, a1.PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, a1.ToolingAmortization, a1.Other, a1.ContractPrice, a1.HLine, a1.PO_Line, a1.Item_Number, a1.PriceCode, 
             a1.Unit_Of_Measure, a1.Other1, a2.PO_Number, a2.Domain
FROM   dbo.BPMInstTasks AS a4 INNER JOIN
             dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1 ON a4.TaskID = a1.TASKID INNER JOIN
             dbo.SupplierScheduledOrder AS a2 ON a1.TASKID = a2.TASKID
WHERE (a4.State = 'Approved') AND (a1.Start_Effective >= @dd3) AND (a1.Start_Effective <= @dd2) AND (a2.Domain = 'CHN02' OR
             a2.Domain = 'CHN04' OR a2.Domain = 'CHN07') AND (a1.PTP <> 0) AND (a2.Site <> 'SUZSP' or a2.Site is null)
) AS a1
WHERE (CONVERT(nvarchar(50), ID)  NOT IN
                 (SELECT Index01 
                 FROM    dbo.v_PI_GSM_P2P_Baseprice_M2 AS a2))
            AND (CONVERT(nvarchar(50), ID)  NOT IN
                 (SELECT  ID  
                 FROM    
				 (SELECT Domain, CONVERT(nvarchar(50), ID) as ID, TASKID, PO_Number, PO_Line, Item_Number, Start_Effective, End_Effective, BasePrice, PTP, ContractPrice
FROM   (SELECT a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, a1.BasePrice, a1.PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, a1.ToolingAmortization, a1.Other, a1.ContractPrice, a1.HLine, a1.PO_Line, a1.Item_Number, a1.PriceCode, 
             a1.Unit_Of_Measure, a1.Other1, a2.PO_Number, a2.Domain
FROM   dbo.BPMInstTasks AS a4 INNER JOIN
             dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1 ON a4.TaskID = a1.TASKID INNER JOIN
             dbo.SupplierScheduledOrder AS a2 ON a1.TASKID = a2.TASKID
WHERE (a4.State = 'Approved') AND (a1.Start_Effective >= @dd3) AND (a1.Start_Effective <= @dd2)  AND (a2.Domain = 'CHN02' OR
             a2.Domain = 'CHN04' OR a2.Domain = 'CHN07') AND (a1.PTP <> 0) AND (a2.Site <> 'SUZSP' or a2.Site is null)) AS a1
WHERE 
not exists 
				 (
				 select domain, ponumber, POLine, ItemNumber
from M_PI_Scheduled_Order_EE as d1 where PCStart <= @dd1 and PCExpire>= @dd1 and d1.domain = a1.domain and d1.ponumber = a1.po_number and d1.poline = a1.po_line 
				 ) and
EXISTS
                 (SELECT Domain, PO_Number, PO_Line, Item_Number
                 FROM    (SELECT Domain, PO_Number, PO_Line, Item_Number
                               FROM    dbo.v_PI_GSM_P2P_Baseprice_M9_adjust where baseprice <> contractprice
                               GROUP BY Domain, PO_Number, PO_Line, Item_Number
                               HAVING (MIN(Start_Effective) >= @dd3)) AS a2
                 WHERE (a1.Domain = Domain) AND (a1.PO_Number = PO_Number) AND (a1.PO_Line = PO_Line))) as d1
				 ))
UNION
SELECT a1.Domain, a1.Index01, a3.taskid, ponumber, poline, itemnumber, pcstart, pcexpire, a1.baseprice, a1.PTP, pcprice
FROM   v_PI_GSM_P2P_Baseprice_M2 AS a1, M_PI_SupplierScheduledOrderDetailPrice AS a3
WHERE a1.index01 = a3.id AND EXISTS
                 (SELECT domain, ponumber, poline, recorddate, IINDEX
                 FROM    v_PI_GSM_P2P_Baseprice_M1 AS a2
                 WHERE a2.domain = a1.domain AND a2.ponumber = a1.ponumber AND a2.poline = a1.poline AND a1.recorddate = a2.recorddate AND PTP <> 0 AND IINDEX > 1
                 GROUP BY domain, ponumber, poline, recorddate, baseprice, IINDEX
                 HAVING count(IINDEX) > 1) ) as b1 where  not exists (select id from PI_GSM_P2P_Baseprice_M4 as c1 where c1.id = b1.id and c1.savingtype = @savingtype and c1.forecastyear = year(@dd3) )


insert into PI_GSM_P2P_Baseprice_M3
SELECT   Domain,  PO_Number, PO_Line, Item_Number,@dd3 as RecordDate, Start_Effective, End_Effective, BasePrice,  ContractPrice,id,PTP
FROM    
(
SELECT   a1.ID, a1.ForeignKey, a1.TASKID, a1.ORDERINDEX, a1.ItemID, a1.Start_Effective, a1.End_Effective, a1.BasePrice, a1.PTP, a1.MCIP, a1.ECON, a1.FX, a1.DesignChange, a1.Allied, 
                         a1.ToolingAmortization, a1.Other, a1.ContractPrice, a1.HLine, a1.PO_Line, a1.Item_Number, a1.PriceCode, a1.Unit_Of_Measure, a1.Other1, a2.PO_Number, a2.Domain
FROM         dbo.BPMInstTasks AS a4 INNER JOIN
                         dbo.M_PI_SupplierScheduledOrderDetailPrice AS a1 ON a4.TaskID = a1.TASKID INNER JOIN
                         dbo.SupplierScheduledOrder AS a2 ON a1.TASKID = a2.TASKID
WHERE     (a4.State = 'Approved') AND (a1.Start_Effective >= @dd3) AND (a1.Start_Effective <= @dd2)  AND (a2.Domain = 'CHN02' OR
                         a2.Domain = 'CHN04' OR a2.Domain = 'CHN07') AND (a1.PTP <> 0) AND (a2.Site <> 'SUZSP' or a2.Site is null)
)
 AS a1
WHERE  (CONVERT(nvarchar(50), ID) NOT IN
                 (SELECT Index01
                 FROM    dbo.v_PI_GSM_P2P_Baseprice_M2 AS a2)) and not exists 
				 (
				 select domain, ponumber, POLine, ItemNumber
from M_PI_Scheduled_Order_EE as d1 where PCStart <= @dd1 and PCExpire>= @dd1 and d1.domain = a1.domain and d1.ponumber = a1.po_number and d1.poline = a1.po_line 
				 )
				  and  EXISTS
                             (SELECT   Domain, PO_Number, PO_Line, Item_Number
                                FROM         (SELECT   Domain, PO_Number, PO_Line, Item_Number
                                                           FROM         dbo.v_PI_GSM_P2P_Baseprice_M9_adjust where baseprice <> contractprice
                                                           GROUP BY Domain, PO_Number, PO_Line, Item_Number
                                                           HAVING   (MIN(Start_Effective) >= @dd3)) AS a2
                                WHERE     (a1.Domain = Domain) AND (a1.PO_Number = PO_Number) AND (a1.PO_Line = PO_Line))


insert into [PI_GSM_P2P_Baseprice_M4]
select 'Booked',a3.Domain,ID,a1.Taskid,PO_Number,PO_Line,Item_Number,a1.Start_Effective,a1.End_Effective,BasePrice,NULL AS NewBasePrice,PTP,NULL AS newPTP,ContractPrice,year(a1.start_effective) as ForecastYear,@savingtype,'Price reduction','New Booked'
from M_PI_AddSupplierScheduledOrderDetailPrice as a1 ,[dbo].[SupplierScheduledOrder] AS a3, BPMInstTasks as a2  where a1.taskid = a3.taskid and a1.taskid = a2.taskid and a2.state = 'Approved' and ptp <> 0 and a1.start_effective >= @dd3 and 
a1.start_effective <= dateadd(year, datediff(year, 1, dateadd(year, 1, getdate())), -1) and
(CONVERT(nvarchar(50), a1.ID) + @savingtype) not in (select CONVERT(nvarchar(50), ID) + savingtype from [dbo].[PI_GSM_P2P_Baseprice_M4])


delete PI_GSM_P2P_Baseprice_FM where year(recorddate) = year(@dd3)
insert into PI_GSM_P2P_Baseprice_FM
select *from 
(SELECT [domain], [ponumber], [POLine], [ItemNumber], [RecordDate], [PCStart], [PCExpire], [baseprice], [pcprice], [Index01], [PTP]
FROM   PI_GSM_P2P_Baseprice_M3
UNION
SELECT [domain], [ponumber], [POLine], [ItemNumber], [RecordDate], [PCStart], [PCExpire], [baseprice], [pcprice], [Index01], [PTP]
FROM   v_PI_GSM_P2P_Baseprice_M2
UNION
SELECT [Domain], [PO_Number], [PO_Line], [Item_Number], dateadd(year, datediff(year, 0, dateadd(year, 0, start_effective)), 0), [Start_Effective], [End_Effective], [NewBasePrice], [ContractPrice], id, [NewPTP]
FROM   [dbo].[PI_GSM_P2P_Baseprice_M4] where year(@dd3) = year(start_effective) and savingtype = @savingtype and confidencephase = 'Booked' and confidencelevel in ('New Booked','Carryover')) as d1


insert into PI_GSM_P2P_Baseprice_M1_history
select 
[domain]
      ,[ponumber]
      ,[POLine]
      ,[ItemNumber]
      ,[RecordDate]
      ,[PCStart]
      ,[PCExpire]
      ,[baseprice]
      ,[pcprice]
      ,[Index01]
      ,[ParentIndex]
      ,[IIndex]
      ,[PTP]
      ,[IsPTPAdj]
	  ,@savingtype
From PI_GSM_P2P_Baseprice_M1
insert into PI_GSM_P2P_Baseprice_M2_history
select [domain]
      ,[ponumber]
      ,[POLine]
      ,[ItemNumber]
      ,[RecordDate]
      ,[PCStart]
      ,[PCExpire]
      ,[baseprice]
      ,[pcprice]
      ,[Index01]
      ,[ParentIndex]
      ,[IIndex]
      ,[PTP]
      ,[IsPTPAdj]
	  ,@savingtype
From PI_GSM_P2P_Baseprice_M2
insert into PI_GSM_P2P_Baseprice_M3_history
select 
[domain]
      ,[ponumber]
      ,[POLine]
      ,[ItemNumber]
      ,[RecordDate]
      ,[PCStart]
      ,[PCExpire]
      ,[baseprice]
      ,[pcprice]
      ,[Index01]
      ,[PTP]
	  ,@savingtype
From PI_GSM_P2P_Baseprice_M3

insert into PI_GSM_P2P_Baseprice_FM_History
select 
[domain]
      ,[ponumber]
      ,[POLine]
      ,[ItemNumber]
      ,[RecordDate]
      ,[PCStart]
      ,[PCExpire]
      ,[baseprice]
      ,[pcprice]
      ,[Index01]
      ,[PTP]
	  ,@savingtype
from PI_GSM_P2P_Baseprice_FM where year(recorddate) = year(@dd3)
END
GO



/****** Object:  StoredProcedure [dbo].[Get_New_PTP_2]    Script Date: 3/1/2024 9:40:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Get_New_PTP_2] 
	
AS
BEGIN
	TRUNCATE TABLE M_adjust_SupplierScheduledOrderDetailPrice ;--删除表数据

	create table #temp  --创建临时表#temp 
	(
   		new_ID  int IDENTITY (1,1)  primary key   not null, --创建列ID,并且每次新增一条记录就会加1
   		ID int null, 
		BasePrice decimal(18,5)  null,
		NewBasePrice decimal(18,5)  null,
		PTP decimal(18,5)  null,
		MCIP decimal(18,5)  null,
		ECON decimal(18,5)  null,
		FX decimal(18,5)  null,
		DesignChange decimal(18,5)  null,
		Allied decimal(18,5)  null,
		ToolingAmortization decimal(18,5)  null,
		Other decimal(18,5)  null,
		Other1 decimal(18,5)  null,
		ContractPrice decimal(18,5)  null,
		Item_Number nvarchar(50)  null,
		PO_Number nvarchar(50)  null,
		PO_Line int  null,
		PriceCode  nvarchar(8)  null,
		Unit_Of_Measure  nvarchar(50)  null,
		Start_effective date  null,
		End_Effective date null,
		result nvarchar(200)   null,
		TaskId int null    
	);
	DECLARE 
	--表参数
	@BasePrice decimal(18,5),@PTP decimal(18,5),@ID int ,@TaskId int,@index int=1,@ContractPrice decimal(18,5),
	@MCIP decimal(18,5),@ECON decimal(18,5),@FX decimal(18,5),@DesignChange decimal(18,5),@Allied decimal(18,5),@ToolingAmortization decimal(18,5),@Other decimal(18,5),
	@Other1 decimal(18,5),
	@End_Effective date,@PO_Line int ,@PriceCode  nvarchar(8),@Unit_Of_Measure  nvarchar(50),
	@result nvarchar(100),@Item_Number nvarchar(50),@PO_Number nvarchar(50) ,@Start_effective date,
	--临时表参数
	@temp_PTP decimal(18,5),@temp_NewID int,@temp_ContractPrice decimal(18,5),@temp_BasePrice decimal(18,5),@temp_Item_Number nvarchar(50),@temp_PO_Number nvarchar(50) ,
	@temp_Start_effective date,@temp_TaskId int,
	@temp_MCIP decimal(18,5),@temp_ECON decimal(18,5),@temp_FX decimal(18,5),@temp_DesignChange decimal(18,5),@temp_Allied decimal(18,5),
	@temp_ToolingAmortization decimal(18,5),@temp_Other decimal(18,5),@temp_Other1 decimal(18,5),
	--新参数的值
	@new_PTP decimal(18,5),
	@new_MCIP decimal(18,5),@new_ECON decimal(18,5),@new_FX decimal(18,5),@new_DesignChange decimal(18,5),@new_Allied decimal(18,5),
	@new_ToolingAmortization decimal(18,5),@new_Other decimal(18,5),@new_Other1 decimal(18,5),
	@totalsum decimal(18,5),@temp_totalsum decimal(18,5)
	;
	
	DECLARE cursor_name CURSOR FOR --定义游标
		  select a1.TASKID TaskId,ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,
		  ContractPrice,Item_Number,PO_Number,PO_Line,PriceCode,
		 Unit_Of_Measure,a1.Start_effective,a1.End_Effective 
		 from SupplierScheduledOrderDetailPrice as a1 with(nolock) ,SupplierScheduledOrder as a3  with(nolock), dbo.BPMInstTasks as a2  with(nolock)
		  where a1.taskid = a2.taskid
		  and a1.taskid = a3.taskid
		  and a2.state = 'Approved'  
		  and (isnull(a1.PTP,0)<>0 
			or  isnull(a1.MCIP,0)<>0 or  isnull(a1.ECON,0)<>0 or  isnull(a1.FX,0)<>0 or  isnull(a1.DesignChange,0)<>0 
			or  isnull(a1.Allied,0)<>0 or  isnull(a1.ToolingAmortization,0)<>0 or  isnull(a1.Other,0)<>0 or  isnull(a1.Other1,0)<>0
		   )
		  order by a1.TASKID,Item_Number,PO_Number,a1.Start_effective
	OPEN cursor_name --打开游标
	FETCH NEXT FROM cursor_name INTO  @TaskId ,@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective 
	--抓取下一行游标数据
	WHILE @@FETCH_STATUS = 0
    BEGIN
		if(@index=1)
		begin 
			--第一条
			set @result='第一条';
			insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,
			ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
			values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,
			@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
		end 
		else
		begin

			set @totalsum=isnull(@PTP,0)+isnull(@MCIP,0)+isnull(@ECON,0)+isnull(@FX,0)+isnull(@DesignChange,0)+isnull(@Allied,0)+isnull(@ToolingAmortization,0)+isnull(@Other,0)+isnull(@Other1,0);
			--判断总值等于0，不参与计算
			if(isnull(@totalsum,0)=0 )  
			begin
				set @result='总值等于0，不参与计算';  
				insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,
				ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
				values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,
				@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
			end 
			else begin 
				--判断总值不等于0，Price相等，不参与计算
				if(@ContractPrice=@BasePrice)
				begin 
					set @result='总值不等于0，Price相等，不参与计算';  
					insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,
					ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
					values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,
					@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
				end
				else
				begin 
					--查找临时表满足条件的最新的数据new_ID
					select @temp_NewID = max(new_ID) from #temp 
					where TaskId=@TaskId and PO_Number=@PO_Number and Item_Number=@Item_Number and BasePrice=@BasePrice and Start_effective < @Start_effective and result not like N'%不参与计算'  ;
					--判断数据是否是第一条
					if(isnull(@temp_NewID,'')='')
					begin 
						set @result='第一条';
						insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,
						ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
						values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,
						@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
					end 
					else
					begin
						--根据new_ID查找数据
						select @temp_ContractPrice = ContractPrice,@temp_BasePrice=BasePrice,@temp_Start_effective = Start_effective,@temp_PO_Number=PO_Number ,@temp_Item_Number = Item_Number,@temp_TaskId=TaskId from #temp where new_ID =@temp_NewID;
						--临时表中PTP总和 处理多个字段有值
						select @temp_PTP=sum(isnull(PTP,0)),@temp_MCIP=sum(isnull(MCIP,0)),@temp_ECON=sum(isnull(ECON,0)),@temp_FX=sum(isnull(FX,0)),@temp_DesignChange=sum(isnull(DesignChange,0)), @temp_Allied=sum(isnull(Allied,0)),@temp_ToolingAmortization=sum(isnull(ToolingAmortization,0)),@temp_Other=sum(isnull(Other,0)),@temp_Other1=sum(isnull(Other1,0)) 
						from #temp where TaskId=@TaskId and PO_Number=@PO_Number and Item_Number=@Item_Number and ContractPrice<>@ContractPrice and BasePrice=@BasePrice and Start_effective < @Start_effective and result not like '%不参与计算'  ;
						--所有字段总和  处理多个字段有值
						set @temp_totalsum=isnull(@temp_PTP,0)+isnull(@temp_MCIP,0)+isnull(@temp_ECON,0)+isnull(@temp_FX,0)+isnull(@temp_DesignChange,0)+isnull(@temp_Allied,0)+isnull(@temp_ToolingAmortization,0)+isnull(@temp_Other,0)+isnull(@temp_Other1,0);
						if(@temp_ContractPrice=@ContractPrice)--ContractPrice相等,不参与计算
						begin 
							set @result='ContractPrice相等,不参与计算';
							insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,
							ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
							values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,
							@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
						end 
						else if(@temp_TaskId=@Taskid and @temp_Item_Number=@Item_Number and @temp_PO_Number=@PO_Number and @temp_BasePrice=@BasePrice and @temp_Start_effective<@Start_effective )
						begin --TaskId,Item_Number，PO_Number，BasePrice相等，Start_effective大于上一条
							if((isnull(@PTP,0)=0 or isnull(@temp_PTP,0)=0) and (isnull(@MCIP,0)=0 or isnull(@temp_MCIP,0)=0) and (isnull(@ECON,0)=0 or isnull(@temp_ECON,0)=0)
							and( isnull(@FX,0)=0 or isnull(@temp_FX,0)=0) and ( isnull(@DesignChange,0)=0 or isnull(@temp_DesignChange,0)=0 )
							and( isnull(@Allied,0)=0 or isnull(@temp_Allied,0)=0) and ( isnull(@ToolingAmortization,0)=0 or isnull(@temp_ToolingAmortization,0)=0)
							and (isnull(@Other,0)=0 or isnull(@temp_Other,0)=0) and (isnull(@Other1,0)=0 or isnull(@temp_Other1,0)=0)
							)
							begin
								set @result='值为空,即第一条';
								insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,
								ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId) 
								values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,
								@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId);
							end
							else if(isnull(@MCIP,0)=0 and isnull(@ECON,0)=0 and isnull(@FX,0)=0 and isnull(@DesignChange,0)=0 and isnull(@Allied,0)=0 and isnull(@ToolingAmortization,0)=0 and isnull(@Other,0)=0 and isnull(@Other1,0)=0 and (isnull(@PTP,0)<>0 and isnull(@temp_PTP,0)<>0))
							begin --只有PTP有值的 正常数据
								select @temp_PTP=sum(isnull(PTP,0))+sum(isnull(MCIP,0))+sum(isnull(ECON,0))+sum(isnull(FX,0))+sum(isnull(DesignChange,0))+sum(isnull(Allied,0))+sum(isnull(ToolingAmortization,0))+sum(isnull(Other,0))+sum(isnull(Other1,0)) from #temp where isnull(PTP,0)<>0 and TaskId=@TaskId and  PO_Number=@PO_Number and Item_Number=@Item_Number and ContractPrice<>@ContractPrice and BasePrice=@BasePrice and Start_effective < @Start_effective and result not like N'%不参与计算'  ;
								set @new_PTP = @PTP - @temp_PTP;--算出新的PTP值
								if(@ContractPrice=(@temp_ContractPrice+@new_PTP))--验证数据是否正确
								begin
									set @result='PIP成功1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,
									ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@new_PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,
									@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,@temp_ContractPrice);
								end
								else
								begin 
									set @result='PIP失败1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,
									ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,
									@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
								end 
							end 
							else if((isnull(@MCIP,0)<>0 and isnull(@temp_MCIP,0)<>0) and isnull(@PTP,0)=0 and isnull(@ECON,0)=0 and isnull(@FX,0)=0 and isnull(@DesignChange,0)=0 and isnull(@Allied,0)=0 and isnull(@ToolingAmortization,0)=0 and isnull(@Other,0)=0 and isnull(@Other1,0)=0)
							begin --只有MCIP有值的 正常数据
								select @temp_MCIP=sum(isnull(MCIP,0)) from #temp where isnull(MCIP,0)<>0 and TaskId=@TaskId and PO_Number=@PO_Number and Item_Number=@Item_Number and ContractPrice<>@ContractPrice and BasePrice=@BasePrice and Start_effective < @Start_effective and result not like N'%不参与计算'  ;
								set @new_MCIP = @MCIP - @temp_MCIP;--算出新的MCIP值
								if(@ContractPrice=(@temp_ContractPrice+@new_MCIP))--验证数据是否正确
								begin 
									set @result='MCIP成功1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@new_MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,@temp_ContractPrice);
								end 
								else
								begin 
									set @result='MCIP失败1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
								end 
							end 
							else if((isnull(@ECON,0)<>0 and isnull(@temp_ECON,0)<>0) and isnull(@PTP,0)=0 and isnull(@MCIP,0)=0 and isnull(@FX,0)=0 and isnull(@DesignChange,0)=0 and isnull(@Allied,0)=0 and isnull(@ToolingAmortization,0)=0 and isnull(@Other,0)=0 and isnull(@Other1,0)=0)
							begin --只有ECON有值的 正常数据
								select @temp_ECON=sum(isnull(ECON,0)) from #temp where isnull(ECON,0)<>0 and TaskId=@TaskId and PO_Number=@PO_Number and Item_Number=@Item_Number and ContractPrice<>@ContractPrice and BasePrice=@BasePrice and Start_effective < @Start_effective and result not like N'%不参与计算'  ;
								set @new_ECON = @ECON - @temp_ECON;--算出新的ECON值
								if(@ContractPrice=(@temp_ContractPrice+@new_ECON))--验证数据是否正确
								begin 
									set @result='ECON成功1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@new_ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,@temp_ContractPrice);
								end 
								else
								begin 
									set @result='ECON失败1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
								end  
							end 
							else if((isnull(@FX,0)<>0 and isnull(@temp_FX,0)<>0) and isnull(@PTP,0)=0 and isnull(@MCIP,0)=0 and isnull(@ECON,0)=0 and isnull(@DesignChange,0)=0 and isnull(@Allied,0)=0 and isnull(@ToolingAmortization,0)=0 and isnull(@Other,0)=0 and isnull(@Other1,0)=0)
							begin --只有FX有值的 正常数据
								select @temp_FX=sum(isnull(ECON,0)) from #temp where isnull(FX,0)<>0 and TaskId=@TaskId and PO_Number=@PO_Number and Item_Number=@Item_Number and ContractPrice<>@ContractPrice and BasePrice=@BasePrice and Start_effective < @Start_effective and result not like N'%不参与计算'  ;
								set @new_FX = @FX - @temp_FX;--算出新的FX值
								if(@ContractPrice=(@temp_ContractPrice+@new_FX))--验证数据是否正确
								begin 
									set @result='FX成功1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@new_FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,@temp_ContractPrice);
								end 
								else
								begin 
									set @result='FX失败1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
								end 
							end 
							else if((isnull(@DesignChange,0)<>0 and isnull(@temp_DesignChange,0)<>0) and isnull(@PTP,0)=0 and isnull(@MCIP,0)=0 and isnull(@FX,0)=0 and isnull(@ECON,0)=0 and isnull(@Allied,0)=0 and isnull(@ToolingAmortization,0)=0 and isnull(@Other,0)=0 and isnull(@Other1,0)=0)
							begin --只有DesignChange有值的 正常数据
								select @temp_DesignChange=sum(isnull(DesignChange,0)) from #temp where isnull(DesignChange,0)<>0 and TaskId=@TaskId and PO_Number=@PO_Number and Item_Number=@Item_Number and ContractPrice<>@ContractPrice and BasePrice=@BasePrice and Start_effective < @Start_effective and result not like N'%不参与计算'  ;
								set @new_DesignChange = @DesignChange - @temp_DesignChange;--算出新的DesignChange值
								if(@ContractPrice=(@temp_ContractPrice+@new_DesignChange))--验证数据是否正确
								begin 
									set @result='DesignChange成功1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@new_DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,@temp_ContractPrice);
								end 
								else
								begin 
									set @result='DesignChange失败1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
								end 
							end 
							else if((isnull(@Allied,0)<>0 and isnull(@temp_Allied,0)<>0) and isnull(@PTP,0)=0 and isnull(@MCIP,0)=0 and isnull(@FX,0)=0 and isnull(@DesignChange,0)=0 and isnull(@ECON,0)=0 and isnull(@ToolingAmortization,0)=0 and isnull(@Other,0)=0 and isnull(@Other1,0)=0)
							begin --只有Allied有值的 正常数据
								select @temp_Allied=sum(isnull(Allied,0)) from #temp where isnull(Allied,0)<>0 and TaskId=@TaskId and PO_Number=@PO_Number and Item_Number=@Item_Number and ContractPrice<>@ContractPrice and BasePrice=@BasePrice and Start_effective < @Start_effective and result not like N'%不参与计算'  ;
								set @new_Allied = @Allied - @temp_Allied;--算出新的Allied值
								if(@ContractPrice=(@temp_ContractPrice+@new_Allied))--验证数据是否正确
								begin 
									set @result='Allied成功1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@new_Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,@temp_ContractPrice);
								end 
								else
								begin 
									set @result='Allied失败1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
								end 
							end	
							else if((isnull(@ToolingAmortization,0)<>0 and isnull(@temp_ToolingAmortization,0)<>0) and isnull(@PTP,0)=0 and isnull(@MCIP,0)=0 and isnull(@FX,0)=0 and isnull(@DesignChange,0)=0 and isnull(@Allied,0)=0 and isnull(@ECON,0)=0 and isnull(@Other,0)=0 and isnull(@Other1,0)=0)
							begin --只有ToolingAmortization有值的 正常数据
								select @temp_ToolingAmortization=sum(isnull(ToolingAmortization,0)) from #temp where isnull(ToolingAmortization,0)<>0 and TaskId=@TaskId and PO_Number=@PO_Number and Item_Number=@Item_Number and ContractPrice<>@ContractPrice and BasePrice=@BasePrice and Start_effective < @Start_effective and result not like N'%不参与计算'  ;
								set @new_ToolingAmortization = @ToolingAmortization - @temp_ToolingAmortization;--算出新的ToolingAmortization值
								if(@ContractPrice=(@temp_ContractPrice+@new_ToolingAmortization))--验证数据是否正确
								begin 
									set @result='ToolingAmortization成功1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@new_ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,@temp_ContractPrice);
								end 
								else
								begin 
									set @result='ToolingAmortization失败1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
								end 
							end 
							else if((isnull(@Other,0)<>0 and isnull(@temp_Other,0)<>0) and isnull(@PTP,0)=0 and isnull(@MCIP,0)=0 and isnull(@FX,0)=0 and isnull(@DesignChange,0)=0 and isnull(@Allied,0)=0 and isnull(@ToolingAmortization,0)=0 and isnull(@ECON,0)=0 and isnull(@Other1,0)=0)
							begin --只有Other有值的 正常数据
								select @temp_Other=sum(isnull(Other,0)) from #temp where isnull(Other,0)<>0 and TaskId=@TaskId and PO_Number=@PO_Number and Item_Number=@Item_Number and ContractPrice<>@ContractPrice and BasePrice=@BasePrice and Start_effective < @Start_effective and result not like N'%不参与计算'  ;
								set @new_Other = @Other - @temp_Other;--算出新的Other值
								if(@ContractPrice=(@temp_ContractPrice+@new_Other))--验证数据是否正确
								begin 
									set @result='Other成功1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@new_Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,@temp_ContractPrice);
								end 
								else
								begin 
									set @result='Other失败1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
								end 
							end 
							else if((isnull(@Other1,0)<>0 and isnull(@temp_Other1,0)<>0) and isnull(@PTP,0)=0 and isnull(@MCIP,0)=0 and isnull(@FX,0)=0 and isnull(@DesignChange,0)=0 and isnull(@Allied,0)=0 and isnull(@ToolingAmortization,0)=0 and isnull(@Other,0)=0 and isnull(@ECON,0)=0)
							begin --只有Other1有值的 正常数据
								select @temp_Other1=sum(isnull(Other1,0)) from #temp where isnull(Other1,0)<>0 and TaskId=@TaskId and PO_Number=@PO_Number and Item_Number=@Item_Number and ContractPrice<>@ContractPrice and BasePrice=@BasePrice and Start_effective < @Start_effective and result not like N'%不参与计算'  ;
								set @new_Other1 = @Other1 - @temp_Other1;--算出新的Other1值
								if(@ContractPrice=(@temp_ContractPrice+@new_Other1))--验证数据是否正确
								begin 
									set @result='Other1成功1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@temp_ContractPrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@new_Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,@temp_ContractPrice);
								end 
								else
								begin 
									set @result='Other1失败1';
									insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
									values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
								end 
							end 
							else 
							begin 
						
								----所有字段总和
								set @result='多列有值';
								insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId,NewBasePrice) 
								values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId,NULL);
							end 
						end
						else begin --判断数据是否是第一条
							set @result='不符合条件,第一条';
							insert into #temp (ID,BasePrice,PTP,MCIP,ECON,FX,DesignChange,Allied,ToolingAmortization,Other,Other1,
							ContractPrice,result,Item_Number,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,End_Effective,TaskId) 
							values(@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,
							@ContractPrice,@result,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective,@TaskId);
						end 
					end  
				end
			end  
		end 
		set @index=@index+1;

		FETCH NEXT FROM cursor_name INTO @TaskId ,@ID,@BasePrice,@PTP,@MCIP,@ECON,@FX,@DesignChange,@Allied,@ToolingAmortization,@Other,@Other1,@ContractPrice,@Item_Number,@PO_Number,@PO_Line,@PriceCode,@Unit_Of_Measure,@Start_effective,@End_Effective  
		
    END
	CLOSE cursor_name --关闭游标
	DEALLOCATE cursor_name --释放游标

	insert into M_adjust_SupplierScheduledOrderDetailPrice
	select ID , case when isnull(NewBasePrice,0)=0 then BasePrice else NewBasePrice end Price ,PTP ,MCIP,ECON ,FX ,DesignChange ,Allied ,ToolingAmortization,Other,Other1 ,
		ContractPrice ,Item_Number ,PO_Number,PO_Line,PriceCode,Unit_Of_Measure,Start_effective,
		End_Effective ,result,TaskId  from #temp ;

	drop table #temp;
END
GO


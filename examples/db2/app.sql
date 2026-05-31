-- 创建表: 临时表编目录
create table XT_TEMPTABLECATALOG
(
   TABLENAME            VARCHAR(255)           not null,
   CREATINGTIME         TIMESTAMP                   not null,
   EXPIRINGTIME         TIMESTAMP,
   CONNECTIONPOOLNAME   VARCHAR(255),
   constraint PK_BLECATALOG primary key (TABLENAME)
)
@

comment on table XT_TEMPTABLECATALOG is
'临时表编目录。持久化已申请的临时表信息'
@

comment on column XT_TEMPTABLECATALOG.TABLENAME is
'TABLENAME'
@

comment on column XT_TEMPTABLECATALOG.CREATINGTIME is
'创建时间'
@

comment on column XT_TEMPTABLECATALOG.EXPIRINGTIME is
'过期时间'
@

comment on column XT_TEMPTABLECATALOG.CONNECTIONPOOLNAME is
'临时表所在数据库的连接池名称，为空表示在生产环境（使用缺省池）。删除临时表时将使用该连接池。'
@

create index IDX_XT_TEMPTABLECA on XT_TEMPTABLECATALOG (
   CREATINGTIME         ASC,
   EXPIRINGTIME         ASC
)
@

-- 创建表: 系统参数
create table XT_XTCS
(
   CSXH                 VARCHAR2(5)                not null,
   JG_DM                VARCHAR2(15)               not null,
   CSMC                 VARCHAR(80)            not null,
   CSNR                 VARCHAR(500)           not null,
   SYSM                 VARCHAR(200),
   XYBZ                 CHAR(1)                not null,
   JZSZBZ               CHAR(1),
   constraint PK_XT_XTCS primary key (CSXH, JG_DM)
)
@

comment on table XT_XTCS is
'系统参数'
@

comment on column XT_XTCS.CSXH is
'参数序号'
@

comment on column XT_XTCS.JG_DM is
'机构代码'
@

comment on column XT_XTCS.CSMC is
'参数名称'
@

comment on column XT_XTCS.CSNR is
'参数内容'
@

comment on column XT_XTCS.SYSM is
'使用说明'
@

comment on column XT_XTCS.XYBZ is
'选用标志'
@

comment on column XT_XTCS.JZSZBZ is
'集中设置标志'
@



insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10000', 'PUBLIC', '系统名称', 'ADP 集成工作平台', '设置系统名称', 'Y', 'Y')
@
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
  values ('10001', 'PUBLIC', '序号生成器', '9', '9', 'Y', 'Y')
@

commit
@

-- ============================================================
--   修改日期：   2010-10-26
--   修改人：     geyx
--   修改内容：
--			插入密码配置数据
-- ============================================================

insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10002', 'PUBLIC', '密码规则正则表达式', '\d+', '用于校验用户修改密码时新密码组成规则 ("\d+"为全数字,禁止删除,设置值为0时为不限制)', 'Y', 'Y')
@
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10003', 'PUBLIC', '允许最大密码输入错误次数', '5', '在一段时间内用户可尝试的最大密码输入错误次数 (禁止删除,设置值为0时为不限制)', 'Y', 'Y')
@
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10004', 'PUBLIC', '密码输入错误连续重试限制时间', '30', '密码输入错误连续重试的限制时间,单位:分钟 (禁止删除,设置值为0时为不限制)', 'Y', 'Y')
@
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10005', 'PUBLIC', '达到最大密码输入错误次数后处理方式', '1', '1:指定时间后允许重试;2:锁定用户 (禁止删除,设置值为0时为不处理)', 'Y', 'Y')
@
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10006', 'PUBLIC', '限制用户重试时间', '30', '用户达到最大密码输入错误次数后限制登录的时间段,单位:分钟 (禁止删除,设置值为0时为不限制)', 'Y', 'Y')
@

commit
@
	
-- 创建表: 业务环节代码
create table DM_YWHJ
(
   YWHJ_DM              VARCHAR(6)                not null,
   YWHJ_MC              VARCHAR(80)            not null,
   XYBZ                 CHAR(1)                not null,
   YXBZ                 CHAR(1)                not null,
   constraint PK_DM_YWHJ primary key (YWHJ_DM)
)
@

comment on table DM_YWHJ is
'业务环节代码'
@

comment on column DM_YWHJ.YWHJ_DM is
'业务环节代码'
@

comment on column DM_YWHJ.YWHJ_MC is
'业务环节名称'
@

comment on column DM_YWHJ.XYBZ is
'选用标志'
@

comment on column DM_YWHJ.YXBZ is
'有效标志'
@

insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('010000', '行政管理环节', 'N', 'Y')
@
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('020000', '党务管理环节', 'N', 'Y')
@
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('030400', '资料档案管理', 'Y', 'Y')
@
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('040000', '数据管理', 'Y', 'Y')
@
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('040100', '数据采集', 'Y', 'Y')
@
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('040200', '数据分析审计', 'Y', 'Y')
@
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('000000', '综合', 'Y', 'Y')
@
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('090000', '系统维护', 'Y', 'Y')
@
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('090100', '权限管理', 'Y', 'Y')
@
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('090200', '数据字典', 'Y', 'Y')
@

commit
@

-- 创建表: 系统
create table QX_SYSTEM
(
   SYSTEMNAME           VARCHAR(80)            not null,
   DESCRIPTION          VARCHAR(50),
   ICONURL              VARCHAR(50),
   VIRTRULROOTNAME      VARCHAR(50),
   COOKIENAME           VARCHAR(50),
   REALROOTURL          VARCHAR(200),
   WELCOMETITTLE        VARCHAR(50),
   WELCOMEURL           VARCHAR(200),
   LOGINURL             VARCHAR(500),
   LOGINTYPE            VARCHAR(10)            not null,
   LOGOUTURL            VARCHAR(200),
   LOGOUTTYPE           VARCHAR(10)            not null,
   USERPARAMNAME        VARCHAR(50),
   PASSWORDPARAMNAME    VARCHAR(50),
   LOGINSUCCESSTAG      VARCHAR(200),
   TESTURL              VARCHAR(200),
   SORTORDER            VARCHAR(2)             not null,
   XYBZ                 VARCHAR(1)             not null,
   YXBZ                 VARCHAR(1)             not null,
   BASEURL              VARCHAR(100),
   LOGINTIME            VARCHAR(1),
   SCRIPT               LONG VARCHAR,
   SESSIONKEEP          VARCHAR(1),
   SESSIONKEEPTYPE      VARCHAR(10),
   SESSIONKEEPURL       VARCHAR(500),
   UNIUSERTYPE          VARCHAR(10),
   UNIUSERON            VARCHAR(1),
   UNIUSERDATA          VARCHAR(200),
   constraint SYS_C0029388 primary key (SYSTEMNAME)
)
@
comment on table QX_SYSTEM
  is '系统'
@
comment on column QX_SYSTEM.SYSTEMNAME
  is '系统名称'
@
comment on column QX_SYSTEM.DESCRIPTION
  is '系统描述'
@
comment on column QX_SYSTEM.WELCOMETITTLE
  is '欢迎标题'
@
comment on column QX_SYSTEM.WELCOMEURL
  is '欢迎页url'
@
comment on column QX_SYSTEM.LOGINURL
  is '登录地址'
@
comment on column QX_SYSTEM.LOGINTYPE
  is '登录类型'
@
comment on column QX_SYSTEM.LOGOUTURL
  is '退出地址'
@
comment on column QX_SYSTEM.LOGOUTTYPE
  is '退出类型'
@
comment on column QX_SYSTEM.BASEURL
  is '基本路径'
@
comment on column QX_SYSTEM.LOGINSUCCESSTAG
  is '登录成功标志'
@
comment on column QX_SYSTEM.SCRIPT
  is '执行脚本'
@


insert into QX_SYSTEM (SYSTEMNAME, DESCRIPTION, ICONURL, VIRTRULROOTNAME, COOKIENAME, REALROOTURL, WELCOMETITTLE, WELCOMEURL, LOGINURL, LOGINTYPE, LOGOUTURL, LOGOUTTYPE, USERPARAMNAME, PASSWORDPARAMNAME, LOGINSUCCESSTAG, TESTURL, SORTORDER, XYBZ, YXBZ, BASEURL, LOGINTIME, SCRIPT, SESSIONKEEP, SESSIONKEEPTYPE, SESSIONKEEPURL, UNIUSERTYPE, UNIUSERON, UNIUSERDATA)
values ('系统管理', '系统管理', null, null, null, null, null, null, null, 'U', '../entry/loginOut?type=ipc&purpose=LogInService&module=Entry', 'U', null, null, ':CONSOLE:', null, '00', 'Y', 'Y', '/adp', 'F', null, 'Y', 'U', '../index.htm', 'L', 'N', null)
@

commit
@



create table QX_SYSTEM_USER
(
   SYSTEMNAME           VARCHAR(50)            not null,
   USERID               VARCHAR(11)               not null,
   NAME                 VARCHAR(20),
   CZRY_MC              VARCHAR(60),
   LOGINNAME            VARCHAR(40)            not null,
   PASSWORD             VARCHAR(40),
   constraint QX_SYSTEM_USER_PK primary key (SYSTEMNAME, USERID)
)
@

create index IDX_QX_SYS on QX_SYSTEM_USER (
   SYSTEMNAME           ASC
)
@

create index IDX_QX_USER on QX_SYSTEM_USER (
   USERID               ASC
)
@


-- 创建表: 岗位
create table QX_GW
(
   GW_DM                VARCHAR(15)               not null,
   GW_MC                VARCHAR(80)            not null,
   GWLX                 VARCHAR(2),
   YWBS                 VARCHAR(5),
   SJ_GW_DM             VARCHAR(15),
   QX_JG_DM             VARCHAR(15)               not null,
   JG_DM                VARCHAR(15)               not null,
   YWHJ_DM              VARCHAR(6)                not null,
   constraint PK_QX_GW primary key (GW_DM)
)
@


alter table QX_GW
   add constraint FK_QX_GW_YWHJ_DM foreign key (YWHJ_DM)
      references DM_YWHJ (YWHJ_DM)
      on delete no action on update restrict
@


comment on column QX_GW.GW_DM is
'岗位代码'
@

comment on column QX_GW.GW_MC is
'岗位名称'
@

comment on column QX_GW.GWLX is
'岗位类型'
@

comment on column QX_GW.YWBS is
'业务标识'
@

comment on column QX_GW.SJ_GW_DM is
'上级岗位代码'
@

comment on column QX_GW.QX_JG_DM is
'权限机关代码'
@

comment on column QX_GW.JG_DM is
'机关代码'
@

comment on column QX_GW.YWHJ_DM is
'业务环节代码'
@


insert into QX_GW (GW_DM, GW_MC, GWLX, YWBS, SJ_GW_DM, QX_JG_DM, JG_DM, YWHJ_DM)
values ('000000000000000', '超级用户岗', '01', '01   ', null, '000000000000000', '000000000000000', '000000')
@
commit
@


-- 创建表: 岗位扩展
create table QX_GW_EX
(
   GW_DM                VARCHAR(15)               not null,
   QX_JG_DM             VARCHAR(15)               not null,
   constraint PK_QX_GW_EX primary key (GW_DM, QX_JG_DM)
)
@

create index IDX_QX_GW_EX_GW_DM on QX_GW_EX (
   GW_DM                ASC
)
@

-- 创建表: 岗位角色（功能模板）
create table QX_GW_GNMB
(
   GW_DM                VARCHAR(15)               not null,
   GNMB_DM              VARCHAR(11)               not null,
   constraint PK_QX_GW_GNMB primary key (GW_DM, GNMB_DM)
)
@


alter table QX_GW_GNMB
   add constraint FK_B_GNMB_DM foreign key (GNMB_DM)
      references QX_GNMB (GNMB_DM)
      on delete no action on update restrict
@

alter table QX_GW_GNMB
   add constraint FK_B_GW_DM foreign key (GW_DM)
      references QX_GW (GW_DM)
      on delete no action on update restrict
@

comment on column QX_GW_GNMB.GW_DM is
'岗位代码'
@

comment on column QX_GW_GNMB.GNMB_DM is
'功能模板代码'
@


insert into QX_GW_GNMB (GW_DM, GNMB_DM) values ('000000000000000', '00000000001')
@

commit
@




-- 创建表: 
create table QX_SYSTEM_GW
(
   SYSTEMNAME           VARCHAR(50)            not null,
   GW_DM                VARCHAR(15)            not null,
   GW_MC                VARCHAR(100),
   SYSTEM_GW_DM         VARCHAR(15)            not null,
   SYSTEM_GW_MC         VARCHAR(100),
   constraint QX_SYSTEM_GW_PK primary key (SYSTEMNAME, GW_DM)
)
@



-- 创建表: 模块类型代码
create table DM_MKLX
(
   MKLX_DM              VARCHAR(2)                not null,
   MKLX_MC              VARCHAR(20)            not null,
   XYBZ                 CHAR(1)                not null,
   YXBZ                 CHAR(1)                not null,
   constraint PK_DM_MKLX primary key (MKLX_DM)
)
@

comment on column DM_MKLX.MKLX_DM is
'模块类型代码'
@

comment on column DM_MKLX.MKLX_MC is
'模块类型名称'
@

comment on column DM_MKLX.XYBZ is
'选用标志'
@

comment on column DM_MKLX.YXBZ is
'有效标志'
@


insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('01', '专用系统URL', 'Y', 'Y')
@
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('02', 'MDI窗口', 'Y', 'Y')
@
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('03', 'SHEET窗口', 'Y', 'Y')
@
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('07', '工具项', 'Y', 'Y')
@
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('04', 'EXE文件', 'Y', 'Y')
@
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('05', '通用系统URL', 'Y', 'Y')
@
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('06', '脚本', 'Y', 'Y')
@
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('10', 'web资源', 'Y', 'Y')
@
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('11', '业务对象', 'Y', 'Y')
@

commit
@



-- 创建表: 功能模块(资源)
create table QX_GNMK
(
   GNMK_DM              VARCHAR(256)               not null,
   GNMK_HZMC            VARCHAR(80)    default '功能模块'        not null,
   GNMK_LJMC            VARCHAR(80)            not null,
   MKLX_DM              VARCHAR(2)                not null,
   YWHJ_DM              VARCHAR(6)                not null,
   CYBJ                 CHAR(1),
   GZL_BZ               CHAR(1),
   CFDK                 CHAR(1)                not null,
   DKWZ                 CHAR(1)                not null,
   SHOWLEFT             CHAR(1)                not null,
   SHOWTOP              CHAR(1)                not null,
   SHOWINTREE           CHAR(1)                not null,
   SYSTEMNAME           VARCHAR(80)    default '系统管理'         not null,
	 YXBZ  CHAR(1) default 'Y' not null,
   constraint PK_QX_GNMK primary key (GNMK_DM)
)
@

alter table QX_GNMK
   add constraint FK_YSTEMNAME foreign key (SYSTEMNAME)
      references QX_SYSTEM (SYSTEMNAME)
      on delete no action on update restrict
@

alter table QX_GNMK
   add constraint FK_WHJ_DM foreign key (YWHJ_DM)
      references DM_YWHJ (YWHJ_DM)
      on delete no action on update restrict
@

comment on column QX_GNMK.GNMK_DM is
'功能模块代码'
@

comment on column QX_GNMK.GNMK_HZMC is
'功能模块汉字名称'
@

comment on column QX_GNMK.GNMK_LJMC is
'功能模块路径名称'
@

comment on column QX_GNMK.MKLX_DM is
'模块类型代码'
@

comment on column QX_GNMK.YWHJ_DM is
'业务环节代码'
@

comment on column QX_GNMK.CYBJ is
'常用标记'
@


insert into QX_GNMK (GNMK_DM, GNMK_HZMC, GNMK_LJMC, MKLX_DM, YWHJ_DM, CYBJ, GZL_BZ, CFDK, DKWZ, SHOWLEFT, SHOWTOP, SHOWINTREE, SYSTEMNAME) 
  values ('FFFFFFFFFFF', '文件夹', 'FFFFFF', '00', '000000', 'N', 'N', 'Y', '0', 'Y', 'Y', 'Y', '系统管理')
@

commit
@


--==============================================================
-- Table: QX_GNMK_TREE
--==============================================================
create table QX_GNMK_TREE
(
   JD_DM                VARCHAR(21)            not null,
   FJD_DM               VARCHAR(21)            not null,
   JD_MC                VARCHAR(80)            not null,
   GNMK_DM              VARCHAR(256),
   JDLX_DM              VARCHAR(2),
   JD_ORDER             NUMERIC(5)             not null,
   constraint PK_QX_GNMK_TREE primary key (JD_DM)
)
@

alter table QX_GNMK_TREE
   add constraint FK_REE_GNMK_DM foreign key (GNMK_DM)
      references QX_GNMK (GNMK_DM)
      on delete no action on update restrict
@


comment on column QX_GNMK_TREE.JD_DM is
'功能模块代码'
@

comment on column QX_GNMK_TREE.FJD_DM is
'节点类型代码'
@

comment on column QX_GNMK_TREE.JD_MC is
'节点名称'
@

comment on column QX_GNMK_TREE.GNMK_DM is
'节点代码'
@

comment on column QX_GNMK_TREE.JDLX_DM is
'父节点代码'
@

comment on column QX_GNMK_TREE.JD_ORDER is
'节点顺序'
@


insert into QX_GNMK_TREE (JD_DM, FJD_DM, JD_MC, GNMK_DM, JDLX_DM, JD_ORDER)
  values ('0', '0', '资源树', 'FFFFFFFFFFF', '0', 0)
@

commit
@



-- 创建表: 功能模块帮助
create table HLP_GNMK
(
   ID                   CHAR(40)               not null,
   CZRY_DATE            TIMESTAMP              not null WITH DEFAULT CURRENT TIMESTAMP,
   CZRY_MC              VARCHAR(60),
   CZRY_DM              CHAR(11),
   KEYWORD              VARCHAR(2000),
   REMARK               VARCHAR(2000),
   GNMK_DM              VARCHAR(256),
   GNMK_HZMC            VARCHAR(120),
   YWHJ_DM              CHAR(6),
   CONTENT              VARCHAR(4000),
   PATH               VARCHAR(256),
   constraint SYS_C0029363 primary key (ID)
)
@
comment on table HLP_GNMK
  is '帮助-功能模块操作手册'
@
comment on column HLP_GNMK.CZRY_MC
  is '操作人员名称'
@
comment on column HLP_GNMK.CZRY_DM
  is '操作人员代码'
@
comment on column HLP_GNMK.KEYWORD
  is '操作关键字'
@
comment on column HLP_GNMK.GNMK_DM
  is '功能模块代码'
@
comment on column HLP_GNMK.GNMK_HZMC
  is '功能模块名称'
@
comment on column HLP_GNMK.YWHJ_DM
  is '业务环节代码'
@
comment on column HLP_GNMK.REMARK
  is '备注'
@
comment on column HLP_GNMK.CONTENT
  is '操作手册内容'
@
comment on column HLP_GNMK.PATH
  is '操作手册文件路径'
@


-- 创建表: 功能模块收藏
create table QX_FAV_GNMK
(
   USERID               VARCHAR(11)               not null,
   GNMK_DM              VARCHAR(256)               not null,
   GW_DM                VARCHAR(15)               not null,
   JD_MC                VARCHAR(80)            not null,
   constraint PK_QX_FAV_GNMK primary key (USERID, GW_DM, GNMK_DM)
)
@

create index IDX_QX_FAV_GNMK_US on QX_FAV_GNMK (
   USERID               ASC
)
@


-- 创建表: 
create table QX_JG_GNMK
(
  JG_DM   VARCHAR(15)		not null,
  GNMK_DM VARCHAR(256))		not null,
  SDATE   TIMESTAMP		not null,
  EDATE   TIMESTAMP		not null,
  constraint PK_QX_JG_GNMK primary key (JG_DM, GNMK_DM)
)
@
create index IDX_JG_GNMK_GW_DM on QX_JG_GNMK (JG_DM ASC)
@

create or replace view V_QX_GNMK_TREE as
select JD_DM, FJD_DM, JD_MC, JDLX_DM, JD_ORDER, QX_GNMK.GNMK_DM, GNMK_HZMC, GNMK_LJMC, MKLX_DM, YWHJ_DM, CYBJ, GZL_BZ, CFDK, DKWZ, SHOWLEFT, SHOWTOP, SHOWINTREE, SYSTEMNAME, YXBZ
   from QX_GNMK_TREE inner join QX_GNMK on QX_GNMK_TREE.GNMK_DM=QX_GNMK.GNMK_DM
@


-- 创建表: 功能模板(角色)
create table QX_GNMB
(
   GNMB_DM              VARCHAR(11)               not null,
   GNMB_MC              VARCHAR(80)            not null,
   SS_GW_DM             VARCHAR(15),
   JSSX_DM              VARCHAR(2)                not null,
   JG_DM                VARCHAR(15)               not null,
   SFGXJS               CHAR(1)                not null,
   constraint PK_QX_GNMB primary key (GNMB_DM)
)
@

comment on table QX_GNMB
  is '功能模(角色)'
@

comment on column QX_GNMB.GNMB_DM is
'功能模板代码'
@

comment on column QX_GNMB.GNMB_MC is
'功能模板名称'
@

comment on column QX_GNMB.SS_GW_DM is
'所属岗位代码'
@

comment on column QX_GNMB.JSSX_DM is
'角色属性'
@


insert into QX_GNMB (GNMB_DM, GNMB_MC, SS_GW_DM, JSSX_DM, JG_DM, SFGXJS)
values ('00000000001', 'admin', null, '01', '000000000000000', 'N')
@

commit
@



-- 创建表: 功能模板的功能模块(角色的资源)
create table QX_GNMB_GNMK
(
   GNMB_DM              VARCHAR(11)               not null,
   GNMK_DM              VARCHAR(256)               not null,
   JD_DM                VARCHAR(21)            not null,
   FJD_DM               VARCHAR(21)            not null,
   JD_MC                VARCHAR(80)            not null,
   JD_ORDER             NUMERIC(5)             not null,
   constraint PK_QX_GNMB_GNMK primary key (GNMB_DM, GNMK_DM, JD_DM, FJD_DM)
)
@


alter table QX_GNMB_GNMK
   add constraint FK_NMK_GNMB_DM foreign key (GNMB_DM)
      references QX_GNMB (GNMB_DM)
      on delete no action on update restrict
@

alter table QX_GNMB_GNMK
   add constraint FK_NMK_GNMK_DM foreign key (GNMK_DM)
      references QX_GNMK (GNMK_DM)
      on delete no action on update restrict
@

comment on column QX_GNMB_GNMK.GNMB_DM is
'功能模板代码'
@

comment on column QX_GNMB_GNMK.GNMK_DM is
'功能模块代码'
@

comment on column QX_GNMB_GNMK.JD_DM is
'节点名称'
@

comment on column QX_GNMB_GNMK.FJD_DM is
'节点代码'
@

comment on column QX_GNMB_GNMK.JD_MC is
'父节点代码'
@


-- 正在创建表     ---QX_GNMB_GNMK_OPERATION
create table QX_GNMB_GNMK_OPERATION
(
    GNMB_DM                         VARCHAR2(11)                 not null       ,
    GNMK_DM                         varchar(256)            not null       ,
    OPERATION_DM                    varchar(256)            not null       ,
    constraint PK_QX_MB_MK_OP primary key (GNMB_DM,GNMK_DM,OPERATION_DM)
)
@

alter table QX_GNMB_GNMK_OPERATION
   add constraint FK_QX_O_GNMB_DM foreign key (GNMB_DM)
      references QX_GNMB (GNMB_DM)
      ON DELETE CASCADE on update restrict
@

alter table QX_GNMB_GNMK_OPERATION
   add constraint FK_QX_O_GNMK_DM foreign key (GNMK_DM)
      references QX_GNMK (GNMK_DM)
      ON DELETE CASCADE on update restrict
@


-- 正在创建表注释 ---QX_GNMB_GNMK_OPERATION
comment on table QX_GNMB_GNMK_OPERATION is '权限功能模板功能模块操作'
@
comment on column QX_GNMB_GNMK_OPERATION.GNMB_DM is '功能模板代码'
@
comment on column QX_GNMB_GNMK_OPERATION.GNMK_DM is '功能模块代码'
@
comment on column QX_GNMB_GNMK_OPERATION.OPERATION_DM is '操作代码'
@


create table QX_GNMB_SX_JG
(
   GNMB_DM              VARCHAR(11)               not null,
   JG_DM                VARCHAR(15)               not null,
   QX_JG_DM             VARCHAR(15)               not null,
   GW_DM                VARCHAR(15)               not null,
   constraint PK_QX_GNMB_SX_JG primary key (GNMB_DM, JG_DM)
)
@

alter table QX_GNMB_SX_JG
   add constraint FK_X_JG_GNMB_DM foreign key (GNMB_DM)
      references QX_GNMB (GNMB_DM)
      on delete no action on update restrict
@

comment on table QX_GNMB_SX_JG is
'权限－功能模板(角色)的机关属性设置(用于根据角色批量生成岗位)'
@

comment on column QX_GNMB_SX_JG.GNMB_DM is
'功能模板代码'
@

comment on column QX_GNMB_SX_JG.JG_DM is
'机关代码'
@

comment on column QX_GNMB_SX_JG.QX_JG_DM is
'权限机关代码'
@

comment on column QX_GNMB_SX_JG.GW_DM is
'岗位代码'
@



-- 正在创建表     ---WSQCZCLFS
create table WSQCZCLFS
(
    WSQCZCLFS_DM                         varchar(16)        default '00' not null,
    WSQCZCLFS_MC                         varchar(256)       default '未授权操作方式' not null,
    YXBZ                                 CHAR(1)            default 'Y' not null,
    XYBZ                                 CHAR(1)            default 'Y' not null,
    constraint PK_WSQCZCLFS primary key (WSQCZCLFS_DM)
)
@

-- 正在创建表注释 ---WSQCZCLFS
comment on table WSQCZCLFS is '未授权操作处理方式'
@
comment on column WSQCZCLFS.WSQCZCLFS_DM is '未授权操作处理方式代码'
@
comment on column WSQCZCLFS.WSQCZCLFS_MC is '未授权操作处理方式名称'
@
comment on column WSQCZCLFS.YXBZ is '有效标志'
@
comment on column WSQCZCLFS.XYBZ is '选用标志'
@

-- 正在创建表     ---QX_OPERATION
create table QX_OPERATION
(
    OPERATION_DM                         varchar(256)            not null,
    OPERATION_MC                         varchar(120)            default '操作' not null,
    GNMK_DM                              varchar(256)            not null       ,
    OPERATION_DESCRIPTION                varchar(256)               ,
    YXBZ                                 char(1)                 default 'Y' not null,
    WSQCZCLFS_DM                         varchar(16)             default '00' not null,
    constraint PK_QX_OPERATION primary key (OPERATION_DM,GNMK_DM) 
)
@

alter table QX_OPERATION
   add constraint FK_QX_OP_GNMK_DM foreign key (GNMK_DM)
      references QX_GNMK (GNMK_DM)
       ON DELETE CASCADE on update restrict
@

-- 正在创建表注释 ---QX_OPERATION
comment on table QX_OPERATION is '操作'
@
comment on column QX_OPERATION.OPERATION_DM is '操作代码'
@
comment on column QX_OPERATION.OPERATION_MC is '操作名称'
@
comment on column QX_OPERATION.GNMK_DM is '功能模块代码'
@
comment on column QX_OPERATION.OPERATION_DESCRIPTION is '操作描述'
@
comment on column QX_OPERATION.YXBZ is '有效标志'
@
comment on column QX_OPERATION.WSQCZCLFS_DM is '未授权操作处理方式代码'
@


DROP PROCEDURE P_DEL_GNMK(CHAR)
@
DROP PROCEDURE P_GET_JD_DM(VARCHAR(1000), VARCHAR(2), VARCHAR(30))
@
DROP PROCEDURE P_DEL_ML(VARCHAR(1000), VARCHAR(30))
@
DROP PROCEDURE P_GET_JD_NEW(VARCHAR(30), VARCHAR(30), VARCHAR(1), VARCHAR(30))
@
DROP PROCEDURE P_ADD_ML(VARCHAR(1000), VARCHAR(30))
@
DROP PROCEDURE P_ADD_GNMK(VARCHAR(1000), VARCHAR(60), VARCHAR(100), VARCHAR(100), VARCHAR(10))
@
DROP PROCEDURE P_GET_JDH(VARCHAR(4000), FLOAT)
@
DROP PROCEDURE P_SEQUENCE_STANDARD(FLOAT,VARCHAR(4000), VARCHAR(4000))
@


CREATE PROCEDURE P_DEL_GNMK(IN AC_GNMK CHAR)
LANGUAGE SQL
BEGIN
     DELETE FROM QX_GNMB_GNMK WHERE GNMK_DM LIKE AC_GNMK;
     DELETE FROM QX_GNMK_TREE WHERE GNMK_DM LIKE AC_GNMK;
     DELETE FROM  QX_GNMK WHERE GNMK_DM LIKE AC_GNMK;
END
 @

CREATE PROCEDURE P_GET_JD_DM (AC_FULL VARCHAR(1000),
                              AC_FLAG VARCHAR(2),
                               OUT RETURN_VAL VARCHAR(30) )
LANGUAGE SQL
BEGIN
    DECLARE LC_FULL VARCHAR(1000);
    DECLARE LN_POS BIGINT;
    DECLARE LC_JD_MC VARCHAR(1000);
    DECLARE LC_FJD_DM VARCHAR(30);
    SET LC_FULL = AC_FULL;
    SET LC_FJD_DM = '0';
    LOOP
        SET LN_POS = posstr(LC_FULL, '~');
        IF LN_POS = 0 THEN
            SET LC_JD_MC = LC_FULL;
        ELSE
            SET LC_JD_MC = SUBSTR(LC_FULL, 1, int(LN_POS) - 1);
            SET LC_FULL = SUBSTR(LC_FULL, int(LN_POS) + 1);
        END IF;
        BEGIN
            DECLARE SQLERRM VARCHAR(255);
            DECLARE MSG VARCHAR(70);
            DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING, NOT FOUND
                BEGIN
                    GET DIAGNOSTICS EXCEPTION 1 SQLERRM = MESSAGE_TEXT;
                    SET MSG = '查找路径名称错误：' || COALESCE(LC_JD_MC, '') || '？' || COALESCE(SQLERRM, '');
                    SIGNAL SQLSTATE '70000' SET MESSAGE_TEXT = MSG;
                END;
            IF AC_FLAG = '0' THEN
                SELECT JD_DM INTO LC_FJD_DM FROM QX_GNMK_TREE WHERE FJD_DM = LC_FJD_DM AND JD_MC = LC_JD_MC;
            ELSE
                SELECT JD_DM INTO LC_FJD_DM FROM QX_GNMB_GNMK WHERE FJD_DM = LC_FJD_DM AND JD_MC = LC_JD_MC AND GNMB_DM = '00000000001';
            END IF;
        END;
        IF LN_POS = 0 THEN
            SET RETURN_VAL = LC_FJD_DM;
            RETURN 0;
        END IF;
    END LOOP ;
end 
@

 CREATE PROCEDURE P_DEL_ML(
     IN AC_FULL    VARCHAR(1000),--全路径名称 各级间用~隔开 如：征收监控~申报征收~增值税申报
     IN AC_HZMC    VARCHAR(30) --目录名称
 )
 LANGUAGE SQL
 BEGIN
  DECLARE  LC_JD_DM   VARCHAR(21);
  DECLARE LN_ROW     BIGINT;
  
    DECLARE MSG VARCHAR(70);
    DECLARE SQLERRM VARCHAR(1000);

    DECLARE ADPEXCEPTION CONDITION FOR SQLSTATE '80000'; 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING, NOT FOUND
    BEGIN
	    GET DIAGNOSTICS EXCEPTION 1 SQLERRM = MESSAGE_TEXT;
	    SET MSG = COALESCE(SQLERRM, '');
	    SIGNAL SQLSTATE '80001' SET MESSAGE_TEXT = MSG;
    END;
    DECLARE EXIT HANDLER FOR ADPEXCEPTION
    BEGIN
	    GET DIAGNOSTICS EXCEPTION 1 SQLERRM = MESSAGE_TEXT;
	    SET MSG = COALESCE(SQLERRM, '');
	    SIGNAL SQLSTATE '80001' SET MESSAGE_TEXT = MSG;
    END;
     --通过目录名称查找节点代码
     CALL P_GET_JD_DM(AC_FULL||'~'||AC_HZMC,'0', LC_JD_DM);
     SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_JD_DM;
     IF LN_ROW>0 THEN
	 SIGNAL SQLSTATE '80000' SET MESSAGE_TEXT = '功能模块树存在下属节点，无法删除！';
     END IF;
     DELETE FROM QX_GNMK_TREE WHERE JD_DM=LC_JD_DM;
 
     --同步超级用户树(地税)
     CALL P_GET_JD_DM(AC_FULL||'~'||AC_HZMC,'1', LC_JD_DM);
     SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_JD_DM;
     IF LN_ROW>0 THEN
	  SIGNAL SQLSTATE '80000' SET MESSAGE_TEXT = '功能模块树存在下属节点，无法删除！';
     END IF;
     DELETE FROM QX_GNMB_GNMK WHERE GNMB_DM='00000000001' AND JD_DM=LC_JD_DM;
 END
@

CREATE PROCEDURE P_GET_JD_NEW(
     IN AC_FJD_DM VARCHAR(30), --父节点代码
     IN AC_JD_MC  VARCHAR(30),  --节点名称
     IN AC_FLAG VARCHAR(1),  --'0'表示查找QX_GNMK_TREE;'1'表示查找QX_GNMB_GNMK(只限于超级用户)
     OUT RETURN_VAL    VARCHAR(30)
     )
LANGUAGE SQL
BEGIN
DECLARE V_LN_ROW    VARCHAR(30);  --节点代码
DECLARE V_LN_COUNT  INT; -- 行数，临时变量
DECLARE MSG VARCHAR(70);
DECLARE SQLERRM VARCHAR(1000);
DECLARE LN_ROW_TEMP1 VARCHAR(30);
DECLARE LN_ROW_TEMP2 VARCHAR(30);
DECLARE LN_ROW_TEMP3 VARCHAR(30);
DECLARE ADPEXCEPTION CONDITION FOR SQLSTATE '80000';
DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING, NOT FOUND
BEGIN
   GET DIAGNOSTICS EXCEPTION 1 SQLERRM = MESSAGE_TEXT;
   SET MSG = COALESCE(SQLERRM, '');
   SIGNAL SQLSTATE '80001' SET MESSAGE_TEXT = MSG;
END;
DECLARE EXIT HANDLER FOR ADPEXCEPTION
BEGIN
   GET DIAGNOSTICS EXCEPTION 1 SQLERRM = MESSAGE_TEXT;
   SET MSG = COALESCE(SQLERRM, '');
   SIGNAL SQLSTATE '80001' SET MESSAGE_TEXT = MSG;
END;
   IF AC_FLAG = '0' THEN
     SELECT RTRIM(CHAR(COUNT(*))) INTO V_LN_ROW FROM QX_GNMK_TREE WHERE JD_DM=AC_FJD_DM AND (JDLX_DM='01' or jdlx_dm='0'); --add by liuming
     IF V_LN_ROW<>'1' THEN
         -- RAISE_APPLICATION_ERROR(-20000,'父节点代码：'||AC_FJD_DM||' 不是目录，无法向下扩展');
	  SET MSG = '父节点代码：' || AC_FJD_DM || ' 不是目录，无法向下扩展';
	  SIGNAL SQLSTATE '80000' SET MESSAGE_TEXT = MSG;
     END IF;
 
     SELECT RTRIM(CHAR(COUNT(*))) INTO V_LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=AC_FJD_DM AND JD_MC=AC_JD_MC;
     IF V_LN_ROW>'0' THEN
         -- RAISE_APPLICATION_ERROR(-20000,'节点名称重复：'||AC_JD_MC);
	  SET MSG = '节点名称重复：'||AC_JD_MC;
	  SIGNAL SQLSTATE '80000' SET MESSAGE_TEXT = MSG;
     END IF;
 
     IF LENGTH(AC_FJD_DM)>18 THEN
      SELECT MAX(JD_DM) INTO V_LN_ROW FROM QX_GNMK_TREE WHERE JD_DM>='0' AND JD_DM<='9';
      IF LENGTH(V_LN_ROW)> 12 THEN 
         set LN_ROW_TEMP1 = RIGHT(V_LN_ROW, 10);
				 set LN_ROW_TEMP2 = RTRIM(CHAR(INT(LN_ROW_TEMP1) + 1));
				 set LN_ROW_TEMP3 = SUBSTR(V_LN_ROW,1,(LENGTH(V_LN_ROW)-10));
				 set V_LN_ROW = LN_ROW_TEMP3 || LN_ROW_TEMP2;
      ELSE     
         set V_LN_ROW=RTRIM(CHAR(INT(V_LN_ROW)+1));
      END IF;          
      SET RETURN_VAL = V_LN_ROW;
    ELSE
      SELECT RTRIM(CHAR(MAX(JD_ORDER))) INTO V_LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=AC_FJD_DM;
      IF V_LN_ROW IS NULL THEN
          SET V_LN_ROW='1';
      ELSEIF V_LN_ROW>='999' THEN
          SET V_LN_ROW=RTRIM(CHAR(INT(V_LN_ROW)+1));
      END IF;
 
       -- 避免与现有代码重复
       SELECT COUNT(*) INTO V_LN_COUNT FROM QX_GNMK_TREE WHERE JD_DM=AC_FJD_DM||RTRIM(CHAR(RIGHT(REPEAT('0',10)||V_LN_ROW,3)));
       --WHILE V_LN_COUNT > 0 LOOP
       fetch_loop1:
       LOOP
       IF V_LN_COUNT = 0 THEN
	leave fetch_loop1;
       END IF;
       --IF V_LN_COUNT > 0 THEN
           SET V_LN_ROW=RTRIM(CHAR(INT(V_LN_ROW)+1));
           SELECT COUNT(*) INTO V_LN_COUNT FROM QX_GNMK_TREE WHERE JD_DM=AC_FJD_DM||RTRIM(CHAR(RIGHT(REPEAT('0',10)||V_LN_ROW,3)));
       --END IF;
       END LOOP fetch_loop1;
 
       --RETURN AC_FJD_DM||LPAD(LN_ROW,3,'0');
	SET RETURN_VAL =  AC_FJD_DM||RTRIM(CHAR(RIGHT(REPEAT('0',10)||V_LN_ROW,3)));
     END IF;
 
   ELSE
     SELECT RTRIM(CHAR(COUNT(*))) INTO V_LN_ROW FROM QX_GNMB_GNMK WHERE JD_DM=AC_FJD_DM AND GNMK_DM='FFFFFFFFFFF' AND GNMB_DM='00000000001';
     IF INT(V_LN_ROW)<>1 THEN
         --RAISE_APPLICATION_ERROR(-20000,'父节点代码：'||AC_FJD_DM||' 不是目录，无法向下扩展');
	  SET MSG = '父节点代码：'||AC_FJD_DM||' 不是目录，无法向下扩展';
	  SIGNAL SQLSTATE '80000' SET MESSAGE_TEXT = MSG;
     END IF;
 
     SELECT RTRIM(CHAR(COUNT(*))) INTO V_LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=AC_FJD_DM AND JD_MC=AC_JD_MC AND GNMB_DM='00000000001';
     IF INT(V_LN_ROW)>0 THEN
         -- RAISE_APPLICATION_ERROR(-20000,'节点名称重复：'||AC_JD_MC);
	  SET MSG = '节点名称重复：'||AC_JD_MC;
	  SIGNAL SQLSTATE '80000' SET MESSAGE_TEXT = MSG;
     END IF;
 
     IF LENGTH(AC_FJD_DM)>18 THEN
       SELECT RTRIM(CHAR(INT(MAX(JD_DM))+1)) INTO V_LN_ROW FROM QX_GNMB_GNMK WHERE GNMB_DM='00000000001' AND JD_DM>='0' AND JD_DM<='9';
       --RETURN LN_ROW;
       SET RETURN_VAL = V_LN_ROW;
     ELSE
       --通过父节点代码向下扩展三位，生成新节点代码
       SELECT RTRIM(CHAR(MAX(JD_ORDER))) INTO V_LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=AC_FJD_DM AND GNMB_DM='00000000001';
       IF V_LN_ROW IS NULL THEN
          SET V_LN_ROW='1';
       ELSE IF V_LN_ROW>='999' THEN
          SET V_LN_ROW=RTRIM(CHAR(INT(V_LN_ROW)+1));
       END IF;
 
       -- 避免与现有代码重复
       SELECT COUNT(*) INTO V_LN_COUNT FROM QX_GNMB_GNMK WHERE JD_DM=AC_FJD_DM||RTRIM(CHAR(RIGHT(REPEAT('0',10)||V_LN_ROW,3)));
       --WHILE V_LN_COUNT > 0 LOOP
        fetch_loop2:
       LOOP
        IF V_LN_COUNT = 0 THEN
	leave fetch_loop2;
       END IF;
       --IF V_LN_COUNT > 0 THEN
         SET V_LN_ROW=RTRIM(CHAR(INT(V_LN_ROW)+1));
           SELECT COUNT(*) INTO V_LN_COUNT FROM QX_GNMB_GNMK WHERE JD_DM=AC_FJD_DM||RTRIM(CHAR(RIGHT(REPEAT('0',10)||V_LN_ROW,3)));
	--END IF;
       END LOOP fetch_loop2;
 
       --RETURN AC_FJD_DM||LPAD(LN_ROW,3,'0');
       SET RETURN_VAL =  AC_FJD_DM||RTRIM(CHAR(RIGHT(REPEAT('0',10)||V_LN_ROW,3)));
     END IF;
   END IF;
   END IF;
 END@

CREATE PROCEDURE P_ADD_ML(
    IN AC_FULL    VARCHAR(1000),--全路径名称 各级间用~隔开
    IN AC_HZMC    VARCHAR(30) --目录名称
)
LANGUAGE SQL
BEGIN
    DECLARE LC_FJD_DM  VARCHAR(21);
    DECLARE LC_JD_DM   VARCHAR(21);
    DECLARE LN_ROW     BIGINT;

    DECLARE MSG VARCHAR(70);
    DECLARE SQLERRM VARCHAR(1000);
    
    DECLARE ADPEXCEPTION CONDITION FOR SQLSTATE '80000'; 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING, NOT FOUND
    BEGIN
	    GET DIAGNOSTICS EXCEPTION 1 SQLERRM = MESSAGE_TEXT;
	    SET MSG = COALESCE(SQLERRM, '');
	    SIGNAL SQLSTATE '80001' SET MESSAGE_TEXT = MSG;
    END;
    DECLARE EXIT HANDLER FOR ADPEXCEPTION
    BEGIN
	    GET DIAGNOSTICS EXCEPTION 1 SQLERRM = MESSAGE_TEXT;
	    SET MSG = COALESCE(SQLERRM, '');
	    SIGNAL SQLSTATE '80001' SET MESSAGE_TEXT = MSG;
    END;
    --通过目录名称查找父节点代码
    --SET LC_FJD_DM=P_GET_JD_DM(AC_FULL,'0');
    CALL P_GET_JD_DM(AC_FULL, '0', LC_FJD_DM);
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_FJD_DM AND JD_MC=AC_HZMC;
    IF LN_ROW=0 THEN
       BEGIN
				    --获取新节点代码
				    CALL P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'0', LC_JD_DM);
						--    LN_ROW:=SUBSTR(LC_JD_DM,LENGTH(LC_JD_DM)-2,3);
				    SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_FJD_DM;
				    IF LN_ROW IS NULL THEN
				        SET LN_ROW=1;
				    ELSEIF LN_ROW>=999 THEN
				    --RAISE_APPLICATION_ERROR(-20000,'下属节点超过999，无法扩展！');
						--SET MSG = ;
						SIGNAL SQLSTATE '80000' SET MESSAGE_TEXT = '下属节点超过999，无法扩展！';
				    ELSE
				        SET LN_ROW=LN_ROW+1;
				    END IF;
				    insert into QX_GNMK_TREE(JD_DM,FJD_DM,JD_MC,GNMK_DM,JDLX_DM,JD_ORDER)
				    VALUES (LC_JD_DM,LC_FJD_DM,AC_HZMC, 'FFFFFFFFFFF','01',LN_ROW);
       END;
    END IF;
        
    --通过目录名称查找父节点代码
    CALL P_GET_JD_DM(AC_FULL,'1', LC_FJD_DM);
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=LC_FJD_DM AND JD_MC=AC_HZMC AND GNMB_DM='00000000001';
    IF LN_ROW=0 THEN
       BEGIN
			    --获取新节点代码
			    CALL P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'1', LC_JD_DM);
					--LN_ROW:=SUBSTR(LC_JD_DM,LENGTH(LC_JD_DM)-2,3);
			    SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=LC_FJD_DM AND GNMB_DM='00000000001';
			    IF LN_ROW IS NULL THEN
			        SET LN_ROW=1;
			    ELSEIF LN_ROW>=999 THEN
			        --RAISE_APPLICATION_ERROR(-20000,'下属节点超过999，无法扩展！');
					SIGNAL SQLSTATE '80000' SET MESSAGE_TEXT = '下属节点超过999，无法扩展！';
			    ELSE
			        SET LN_ROW=LN_ROW+1;
			    END IF;
			    INSERT INTO QX_GNMB_GNMK(GNMB_DM,JD_DM,FJD_DM,JD_MC,GNMK_DM,JD_ORDER)
			    VALUES ('00000000001',LC_JD_DM,LC_FJD_DM,AC_HZMC,'FFFFFFFFFFF',LN_ROW);
			END;
    END IF;
END
@

CREATE PROCEDURE P_ADD_GNMK(
    IN AC_FULL    VARCHAR(1000),--全路径名称
    IN AC_GNMK    VARCHAR(60),--模块代码
    IN AC_HZMC    VARCHAR(100),--汉字名称
    IN AC_LJMC    VARCHAR(100),--路径名称
    IN AC_YWHJ    VARCHAR(10)--业务环节代码
)
LANGUAGE SQL
 BEGIN

DECLARE    LC_FJD_DM  VARCHAR(30);
DECLARE    LC_JD_DM   VARCHAR(30);
DECLARE LN_ROW     BIGINT;

DECLARE MSG VARCHAR(70);
DECLARE SQLERRM VARCHAR(1000);
    
DECLARE ADPEXCEPTION CONDITION FOR SQLSTATE '80000'; 
DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING, NOT FOUND
BEGIN
   GET DIAGNOSTICS EXCEPTION 1 SQLERRM = MESSAGE_TEXT;
   SET MSG = COALESCE(SQLERRM, '');
   SIGNAL SQLSTATE '80001' SET MESSAGE_TEXT = MSG;
END;
DECLARE EXIT HANDLER FOR ADPEXCEPTION
BEGIN
   GET DIAGNOSTICS EXCEPTION 1 SQLERRM = MESSAGE_TEXT;
   SET MSG = COALESCE(SQLERRM, '');
   SIGNAL SQLSTATE '80001' SET MESSAGE_TEXT = MSG;
END;

IF AC_GNMK='FFFFFFFFFFF' THEN--增加目录
        --RAISE_APPLICATION_ERROR(-20000,'增加目录请调用P_ADD_ML');
	 SIGNAL SQLSTATE '80000' SET MESSAGE_TEXT = '增加目录请调用P_ADD_ML';
    END IF;

    --开始插入数据
    BEGIN
        insert into QX_GNMK (GNMK_DM, GNMK_HZMC, GNMK_LJMC, MKLX_DM, YWHJ_DM, CYBJ)
        values (AC_GNMK, AC_HZMC, AC_LJMC,'01', AC_YWHJ, 'N');--常用标记为N
    END;

    IF AC_FULL IS NOT NULL THEN--AC_FULL为空，表示不在树上显示
        --通过目录名称查找父节点代码
        CALL P_GET_JD_DM(AC_FULL,'0', LC_FJD_DM);
        --获取新节点代码
        CALL P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'0', LC_JD_DM);
 --       LN_ROW:=SUBSTR(LC_JD_DM,LENGTH(LC_JD_DM)-2,3);
        SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_FJD_DM;
        IF LN_ROW IS NULL THEN
            SET LN_ROW=1;
        ELSEIF LN_ROW>=999 THEN
            --RAISE_APPLICATION_ERROR(-20000,'下属节点超过999，无法扩展！');
	     SIGNAL SQLSTATE '80000' SET MESSAGE_TEXT = '下属节点超过999，无法扩展！';
        ELSE
            SET LN_ROW=LN_ROW+1;
        END IF;
        insert into QX_GNMK_TREE(JD_DM,FJD_DM,JD_MC,GNMK_DM,JDLX_DM,JD_ORDER)
        VALUES (LC_JD_DM,LC_FJD_DM,AC_HZMC, AC_GNMK,'02',LN_ROW);

        --通过目录名称查找父节点代码
        CALL P_GET_JD_DM(AC_FULL,'1',LC_FJD_DM);
        --获取新节点代码
        CALL P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'1', LC_JD_DM);
        SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=LC_FJD_DM AND GNMB_DM='00000000001';
        IF LN_ROW IS NULL THEN
            SET LN_ROW=1;
        ELSEIF LN_ROW>=999 THEN
            --RAISE_APPLICATION_ERROR(-20000,'下属节点超过999，无法扩展！');
	    SIGNAL SQLSTATE '80000' SET MESSAGE_TEXT = '下属节点超过999，无法扩展！';
        ELSE
            SET LN_ROW=LN_ROW+1;
        END IF;
--        LN_ROW:=SUBSTR(LC_JD_DM,LENGTH(LC_JD_DM)-2,3);
        INSERT INTO QX_GNMB_GNMK(GNMB_DM,JD_DM,FJD_DM,JD_MC,GNMK_DM,JD_ORDER)
        VALUES ('00000000001',LC_JD_DM,LC_FJD_DM,AC_HZMC,AC_GNMK,LN_ROW);
    END IF;
 END
@

CREATE PROCEDURE P_GET_JDH ( OUT ac_jdh VARCHAR(4000),
                             OUT RETURN_VAL FLOAT )
LANGUAGE SQL

BEGIN
     set ac_jdh = (SELECT CSNR
    FROM XT_XTCS
    WHERE CSXH = '10001'
          AND JG_DM = 'PUBLIC');

--|     if ac_jdh is null then

    IF ac_jdh IS NULL THEN

--|        Raise_application_error(-20000, '没有初始化“节点号”[CSXH = ''10001'']系统参数！');

        SIGNAL SQLSTATE '70000' SET MESSAGE_TEXT = '没有初始化“节点号”[CSXH = ''10001'']系统参数！';

    END IF;

--|     return 100;

    SET RETURN_VAL = 100;
    RETURN 0;

END 
@


CREATE PROCEDURE P_SEQUENCE_STANDARD ( OUT RETURN_VAL FLOAT,OUT sequenceNo VARCHAR(4000),
                                       IN sequenceName VARCHAR(4000) )
--| -----------------------------------------------------------------------------
--| -----------------------------------------------------------------------------
--| --                              存储过程说明
--| --过 程 名：P_SEQUENCE_STANDARD
--| --功能描述：标准序列计算函数
--| --输入参数：序列名称
--| --输出参数：序列值
--| --返 回 值：100成功 其他值 系统错误
--| --调用来自：序列发生器
--| --编写时间：2007年07月30日
--| --修改序号：
--| -----------------------------------------------------------------------------
--| -----------------------------------------------------------------------------
LANGUAGE SQL

BEGIN

    DECLARE jdno VARCHAR(4);

    DECLARE ln_return BIGINT;

    DECLARE execStr VARCHAR(4000);

    DECLARE RETURN_VAL1 FLOAT;

    DECLARE stmt STATEMENT;

    DECLARE curs CURSOR FOR stmt;
   SET execStr = ' select char(NEXTVAL FOR '||sequenceName|| ')  from sysibm.sysdummy1 ';

    PREPARE stmt FROM execStr;
    OPEN curs;
    FETCH FROM curs INTO sequenceNo;
    CLOSE curs;

    CALL P_GET_JDH(jdno,RETURN_VAL1);
    SET ln_return = sysfun.round(RETURN_VAL1,0);
    IF ln_return = 100 THEN
              SET sequenceNo =rtrim('00000000'||sequenceNo);
        SET sequenceNo = COALESCE((COALESCE(jdno, '') || COALESCE(substr(to_char(CURRENT TIMESTAMP,'yyyy-mm-dd hh24:mi:ss'),3,2), '')), '') || '9' || substr(sequenceNo, length(sequenceNo)-7) || '000';

    END IF;
    SET RETURN_VAL = ln_return;
    RETURN 0;

end
@

--| TODO : 缺过程P_ADD_ROOT/P_DEL_ROOT
--| CREATE OR REPLACE PROCEDURE P_ADD_ROOT(
--|     AC_JD_DM    VARCHAR2,
--|     AC_JD_MC    VARCHAR2,
--|     AC_JD_ORDER NUMBER default null
--| )IS
--|     LN_COUNT NUMBER(10);
--|     LN_JD_ORDER NUMBER(10);
--| BEGIN
--|      IF AC_JD_ORDER is null THEN
--|         BEGIN
--|              SELECT MAX(JD_ORDER) INTO LN_JD_ORDER FROM QX_GNMK_TREE WHERE FJD_DM='0';
--|              IF LN_JD_ORDER IS NULL THEN
--|                 LN_JD_ORDER:=1;
--|              ELSIF LN_JD_ORDER>=999 THEN
--|                 RAISE_APPLICATION_ERROR(-20000,'根节点超过999，无法扩展！');
--|              ELSE
--|                  LN_JD_ORDER:=LN_JD_ORDER+1;
--|              END IF;
--|         END;
--|      ELSE 
--|         LN_JD_ORDER:=AC_JD_ORDER;
--|      END IF;
--| 
--|      SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMK_TREE WHERE JD_DM=AC_JD_DM;
--|      IF LN_COUNT =0 THEN
--|          insert into QX_GNMK_TREE(JD_DM,FJD_DM,JD_MC,GNMK_DM,JDLX_DM,JD_ORDER)  
--|          values (AC_JD_DM, '0',AC_JD_MC,'FFFFFFFFFFF', '01', LN_JD_ORDER);
--|      END IF;
--|      
--|      SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMB_GNMK WHERE JD_DM=AC_JD_DM AND GNMB_DM='00000000001';
--|      IF LN_COUNT =0 THEN
--|          INSERT INTO QX_GNMB_GNMK(GNMB_DM,GNMK_DM,JD_DM,FJD_DM,JD_MC,JD_ORDER)
--|          values ('00000000001','FFFFFFFFFFF',AC_JD_DM,'0', AC_JD_MC, LN_JD_ORDER);
--|      END IF;
--|      
--| END;
--| /
--| CREATE OR REPLACE PROCEDURE P_DEL_ROOT(
--|     AC_JD_DM    VARCHAR2
--| )IS
--|     LN_COUNT NUMBER(10);
--| BEGIN
--|      SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMK_TREE WHERE FJD_DM=AC_JD_DM;
--|      IF LN_COUNT >0 THEN
--|         RAISE_APPLICATION_ERROR(-20000,'QX_GNMK_TREE根节点存在下属节点，无法删除！');
--|      ELSE
--|         DELETE FROM QX_GNMK_TREE WHERE JD_DM=AC_JD_DM;
--|      END IF;
--|      
--|      SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMB_GNMK WHERE FJD_DM=AC_JD_DM;
--|      IF LN_COUNT >0 THEN
--|         RAISE_APPLICATION_ERROR(-20000,'QX_GNMB_GNMK根节点存在下属节点，无法删除！');
--|      ELSE
--|         DELETE FROM QX_GNMB_GNMK WHERE JD_DM=AC_JD_DM AND GNMB_DM='00000000001';
--|      END IF;
--|      
--| END;
--| /


call P_ADD_ROOT('systemmanage','系统管理', 90)
@
call P_ADD_ML('系统管理','组织权限')
@
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.org','机构初始化','../security/org/zzjg.do?method=tree','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.org'
@
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.operator','操作人员初始化','../work/portal/csh_czry/CzrycshService.czrycsh2.do','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.operator'
@
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.reg','资源注册','../security/model/zyzc.do?method=queryList','000000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.resource.reg'
@
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.limitation','资源时效性','../work/portal/gnmksxx/GnmksxxBndService.getGnmksxxs.do','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.resource.limitation'
@
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.operation','操作注册','../security/operation/operation.do','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.resource.operation'
@
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.role','角色设置','../security/role/jssz.do?method=init','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.role'
@
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.position','岗位设置','../security/position/gwsz.do?method=gwszPageInit','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.position'
@
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.user','用户设置','../security/user/user.do','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.user'
@
commit
@

-- 创建表: 单位隶属关系
create table DM_DWLSGX
(
   DWLSGX_DM            VARCHAR(2)                not null,
   DWLSGX_MC            VARCHAR(24)               not null,
   DWLSGX_SM            VARCHAR(256),
   XYBZ                 CHAR(1)                not null,
   YXBZ                 CHAR(1)                not null
)
@

CREATE VIEW V_DM_DWLSGX AS
	SELECT "DWLSGX_DM","DWLSGX_MC","XYBZ","YXBZ"
	FROM DM_DWLSGX
	WHERE YXBZ='Y' AND XYBZ = 'Y'
@


insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('10', '中央            ', '包括全国人大常委会、中共中央、国务院各部委及其所属机构，国务院各直属机构、办事机构及其所属机构', 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('20', '省              ', '包括自治区、直辖市', 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('40', '市、地区        ', '包括自治州、盟、省辖市、直辖市辖区（县）', 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('50', '县              ', '包括地(州、盟)辖市、省辖市辖区、自治县（旗）、旗、县级市', 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('60', '街道、镇、乡    ', null, 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('61', '街道            ', null, 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('62', '镇              ', null, 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('63', '乡              ', null, 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('70', '居民、村民委员会', null, 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('71', '居民委员会      ', null, 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('72', '村民委员会      ', null, 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('80', '组              ', null, 'Y', 'Y')
@
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('90', '其他            ', null, 'Y', 'Y')
@
commit
@


-- 创建表: 机构
create table DM_JG
(
   JG_DM                VARCHAR(15)               not null,
   JG_MC                VARCHAR(80)            not null,
   JG_JC                VARCHAR(50)            not null,
   JG_BZ                CHAR(1)                not null,
   SJ_JG_DM             VARCHAR(15)               not null,
   DWLSGX_DM            VARCHAR(2)                not null,
   JG_JG                VARCHAR(10),
   JGYB                 VARCHAR(6),
   JGDZ                 VARCHAR(80),
   JGDH                 VARCHAR(30),
   CZDH                 VARCHAR(30),
   DYDZ                 VARCHAR(50),
   XZQH_DM              VARCHAR(15),
   JGFZR_DM             VARCHAR(11),
   JBDM                 VARCHAR(30)            not null,
   JCDM                 CHAR(1)                not null,
   XYBZ                 CHAR(1)                not null,
   YXBZ                 CHAR(1)                not null,
   constraint PK_DM_JG primary key (JG_DM)
)
@

comment on table DM_JG is
'机构'
@

comment on column DM_JG.JG_DM is
'机构代码'
@

comment on column DM_JG.JG_MC is
'机构名称'
@

comment on column DM_JG.JG_JC is
'机构简称'
@

comment on column DM_JG.JG_BZ is
'机构标志'
@

comment on column DM_JG.SJ_JG_DM is
'上级机构代码'
@

comment on column DM_JG.DWLSGX_DM is
'机构级次代码'
@

comment on column DM_JG.JG_JG is
'机构局轨'
@

comment on column DM_JG.JGYB is
'机构邮编'
@

comment on column DM_JG.JGDZ is
'机构地址'
@

comment on column DM_JG.JGDH is
'机构电话'
@

comment on column DM_JG.CZDH is
'传真电话'
@

comment on column DM_JG.DYDZ is
'电邮地址'
@

comment on column DM_JG.XZQH_DM is
'行政区划代码'
@

comment on column DM_JG.JGFZR_DM is
'负责人'
@

comment on column DM_JG.JBDM is
'级别代码'
@

comment on column DM_JG.JCDM is
'级次代码'
@

comment on column DM_JG.XYBZ is
'选用标志'
@

comment on column DM_JG.YXBZ is
'有效标志'
@

create unique index IDX_DM_JG_JBDM on DM_JG (
   JBDM                 ASC
)
@



insert into DM_JG (JG_DM, JG_MC, JG_JC, JG_BZ, SJ_JG_DM, DWLSGX_DM, JG_JG, JGYB, JGDZ, JGDH, CZDH, DYDZ, XZQH_DM, JGFZR_DM, JBDM, JCDM, XYBZ, YXBZ)
values ('000000000000000', '国家管理中心', '国家管理中心', 'J', '999999999999999', '10', null, '100000', '北京市', '010-63417114', '34', null, '000000000000000', '00000000000', '0000', '0', 'Y', 'Y')
@

commit
@


create view v_dm_jg as
	SELECT * FROM(
	select
	"JG_DM",
	"JG_MC",
	"JG_JC",
	"JG_BZ",
	"SJ_JG_DM",
	"DWLSGX_DM",
	"JG_JG",
	"JGYB",
	"JGDZ",
	"JGDH",
	"CZDH",
	"DYDZ",
	"XZQH_DM",
	"JGFZR_DM",
	"JBDM",
	"JCDM",
	"XYBZ",
	"YXBZ"
	from DM_JG
	where YXBZ = 'Y'
	and XYBZ = 'Y' order by JG_DM ) AS E
@



CREATE VIEW V_DM_BM AS
	SELECT "JG_DM",
	"JG_MC",
	"JG_JC","JG_BZ","SJ_JG_DM","DWLSGX_DM","JG_JG","JGYB","JGDZ","JGDH","CZDH","DYDZ","XZQH_DM","JGFZR_DM","JBDM","JCDM","XYBZ","YXBZ"
	  FROM DM_JG
	 WHERE YXBZ='Y'
	   AND XYBZ = 'Y'
	   AND JG_BZ='B'
@


create table QX_JG_QXJG
(
   JG_DM                VARCHAR(15)               not null,
   QX_JG_DM             VARCHAR(15)               not null,
   constraint PK_QX_JG_QXJG primary key (JG_DM)
)
@

 
-- 创建表: 操作人员
create table DM_CZRY
(
   CZRY_DM              VARCHAR(11)               not null,
   JG_DM                VARCHAR(15)               not null,
   CZRY_MC              VARCHAR(60)            not null,
   XYBZ                 CHAR(1)                not null,
   YXBZ                 CHAR(1)                not null,
   ZJHM                 VARCHAR(18),
   ADDRESS              VARCHAR(80),
   DHHM                 VARCHAR(30),
   SJHM                 VARCHAR(30),
   EMAIL                VARCHAR(50),
   constraint PK_DM_CZRY primary key (CZRY_DM)
)
@

alter table DM_CZRY
   add constraint FK_DM_CZRY_JG_DM foreign key (JG_DM)
      references DM_JG (JG_DM)
      on delete no action on update restrict
@

create index IDX_DM_CZRY_JG_DM on DM_CZRY (
   JG_DM                ASC
)
@

comment on table DM_CZRY is
'操作人员代码'
@

comment on column DM_CZRY.CZRY_DM is
'操作人员代码'
@

comment on column DM_CZRY.JG_DM is
'机构代码'
@

comment on column DM_CZRY.CZRY_MC is
'操作人员名称'
@

comment on column DM_CZRY.XYBZ is
'选用标志'
@

comment on column DM_CZRY.YXBZ is
'有效标志'
@


insert into DM_CZRY (CZRY_DM, JG_DM, CZRY_MC, XYBZ, YXBZ, ZJHM, ADDRESS, DHHM, SJHM, EMAIL)
values ('00000000000', '000000000000000', 'admin', 'Y', 'Y', '111111111111111110', '北京', '1234567', '13500001111', '123@163.com')
@

commit
@


-- 创建表: 用户
create table QX_USER
(
   USERID               VARCHAR(11)               not null,
   NAME               VARCHAR(30)            not null,
   CZRY_DM              VARCHAR(11)               not null,
   PASSWORD             VARCHAR(40)            not null,
   KLLX                 VARCHAR(2)                not null,
   PWRQQ                DATE,
   PWRQZ                DATE,
   GRANTROLE            CHAR(1),
   constraint PK_QX_USER primary key (USERID)
)
@


alter table QX_USER
   add constraint FK_QX_USER_RY_DM foreign key (CZRY_DM)
      references DM_CZRY (CZRY_DM)
      on delete no action on update restrict
@

create unique index IDX_QX_USER_NAME on QX_USER (
   NAME               ASC
)
@

create index IDX_QX_USER_RY_DM on QX_USER (
   CZRY_DM              ASC
)
@


comment on table QX_USER is
'用户'
@

comment on column QX_USER.USERID is
'用户ID'
@

comment on column QX_USER.NAME is
'用户名'
@

comment on column QX_USER.CZRY_DM is
'人员代码'
@

comment on column QX_USER.PASSWORD is
'口令'
@

comment on column QX_USER.KLLX is
'口令类型'
@

comment on column QX_USER.PWRQQ is
'口令起始日期'
@

comment on column QX_USER.PWRQZ is
'口令终止日期'
@

comment on column QX_USER.GRANTROLE is
'角色授权标记'
@


insert into QX_USER (USERID, NAME, CZRY_DM, PASSWORD, KLLX, PWRQQ, PWRQZ, GRANTROLE)
  values ('00000000000', 'admin', '00000000000', 'M0hn9rFM+RSrf8iOFvT9+5U1AcXah/ecrLo/Mg==', '1 ', date('2007-08-05'), date('2007-08-31'), '0')
@

commit
@


-- 创建表: 用户的岗位
create table QX_USER_GW
(
   USERID               VARCHAR(11)               not null,
   GW_DM                VARCHAR(15)               not null,
   constraint PK_QX_USER_GW primary key (USERID, GW_DM)
)
@


alter table QX_USER_GW
   add constraint FK_W_GW_DM foreign key (GW_DM)
      references QX_GW (GW_DM)
      on delete no action on update restrict
@

alter table QX_USER_GW
   add constraint FK_W_USERID foreign key (USERID)
      references QX_USER (USERID)
      on delete no action on update restrict
@

comment on column QX_USER_GW.USERID is
'用户ID'
@

comment on column QX_USER_GW.GW_DM is
'岗位代码'
@


insert into QX_USER_GW (USERID, GW_DM)
  values ('00000000000', '000000000000000')
@

commit
@


CREATE FUNCTION ISYSZ(rydm varchar(11) )
    RETURNS varchar(11)
LANGUAGE SQL

BEGIN ATOMIC
    declare rynum  integer;
   set rynum = ( select count(*)  from qx_user u where u.czry_dm = rydm);
   if (rynum > 0) then
    return '1';
  else
    return '0';
  end if;
END
@

create view v_dm_czry as
	select dm_czry.czry_dm,czry_mc,jg_dm,zjhm,address,dhhm,sjhm,email,isysz(dm_czry.czry_dm)as isysz,qx_user.userid as userid
	from dm_czry left join qx_user on dm_czry.czry_dm=qx_user.czry_dm
@


-- 创建表: 公共消息
create table MESSAGE_COMMON
(
   ID                   VARCHAR(40)               not null,
   QX_JG_DM             VARCHAR(15)               not null,
   CZRY_MC              VARCHAR(60),
   CZRY_DM              VARCHAR(11)               not null,
   CZ_DATE              TIMESTAMP                   not null,
   ISSUE_FLAG           CHAR(1)                not null,
   PRIORITY             CHAR(1)                not null,
   CONTENT              VARCHAR(400),
   constraint SYS_C0029403 primary key (ID)
)
@

comment on table MESSAGE_COMMON is
'公共消息'
@

comment on column MESSAGE_COMMON.ISSUE_FLAG is
'发布标识：0草稿 1发布'
@

comment on column MESSAGE_COMMON.PRIORITY is
'消息类型 0普通 3重要'
@

-- 创建表: 
create table MESSAGE_COMMON_OTM
(
   ID                   VARCHAR(40)               not null,
   QX_JG_DM             VARCHAR(15)               not null,
   constraint PK_OMMON_OTM primary key (ID, QX_JG_DM)
)
@

alter table MESSAGE_COMMON_OTM
   add constraint FK_OMMON_OTM foreign key (ID)
      references MESSAGE_COMMON (ID)
      on delete no action on update restrict
@


insert into MESSAGE_COMMON (ID, QX_JG_DM, CZRY_MC, CZRY_DM, CZ_DATE, ISSUE_FLAG, PRIORITY, CONTENT)
  values ('8a8118e2-15a11f28-0115-a122ce44-0001', '000000000000000', 'admin', '00000000000', to_date('2007-10-18 09:47:12','yyyy-mm-dd hh24:mi:ss'), '1', '0', '发达三分')
@

insert into MESSAGE_COMMON_OTM (ID, QX_JG_DM)
  values ('8a8118e2-15a11f28-0115-a122ce44-0001', '000000000000000')
@

commit
@
call P_ADD_ROOT('systemmanage','系统管理', 90)
@
call P_ADD_ML('系统管理','系统初始化')
@
call P_ADD_GNMK('系统管理~系统初始化','message.common','公共消息维护','../work/message/common/index.jsp','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'message.common'
@
commit
@create table print_template(
  templateId        VARCHAR(32)     not null,
  templateName      VARCHAR(100)    not null,
  templateVersion   INTEGER         not null,
  expiredDate       DATE            not null,
  templateContent   BLOB            not null
)
@
alter table print_template add constraint PK_component_print primary key (templateId)
@

comment on table print_template is
'打印模板'
@
comment on column print_template.templateId is
'模板ID'
@
comment on column print_template.templateName is
'模板名称'
@
comment on column print_template.templateVersion is
'版本号'
@
comment on column print_template.expiredDate is
'有效期'
@
comment on column print_template.templateContent is
'模板内容'
@call P_ADD_ROOT('systemmanage','系统管理', 90)
@
call P_ADD_ML('系统管理','系统初始化')
@
call P_ADD_GNMK('系统管理~系统初始化','systemmanage.int.print','打印模板管理','../print/listPrintTemplate.iface','000000')
@
commit
@
-- 创建表: 处理状态代码
create table PI_DM_CLZT
(
   PI_CLZT_DM           VARCHAR(2)             not null,
   PI_CLZT_MC           VARCHAR(20),
   constraint PK_PI_DM_CLZT primary key (PI_CLZT_DM)
)
@

comment on table PI_DM_CLZT is
'处理状态'
@

comment on column PI_DM_CLZT.PI_CLZT_DM is
'处理状态代码'
@

comment on column PI_DM_CLZT.PI_CLZT_MC is
'处理状态名称'
@


insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('10', '准备执行')
@
insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('15', '正在执行')
@
insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('20', '堵塞')
@
insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('21', '取消')
@
insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('29', '执行失败')
@
insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('99', '成功结束')
@

commit
@

-- 创建表: 时间频度代码
create table PI_DM_SJPD
(
   PI_SJPD_DM           VARCHAR(2)             not null,
   PI_SJPD_MC           VARCHAR(10)            not null,
   constraint PK_PI_DM_SJPD primary key (PI_SJPD_DM)
)
@

comment on table PI_DM_SJPD is
'时间频度代码'
@

comment on column PI_DM_SJPD.PI_SJPD_DM is
'时间频度代码'
@

comment on column PI_DM_SJPD.PI_SJPD_MC is
'时间频度名称'
@


insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('02', '分')
@
insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('04', '小时')
@
insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('11', '天')
@
insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('16', '周')
@
insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('20', '月')
@
insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('29', '月末')
@

commit
@


-- 创建表: 任务
create table PI_TASK
(
   RWH                  VARCHAR(20)            not null,
   TITLE                VARCHAR(80)            not null,
   GROUPID              VARCHAR(20)            not null,
   YXJB                 NUMERIC(10)            not null,
   ZCYDSBZ              VARCHAR(1)             not null,
   REDO                 VARCHAR(1)             not null,
   EXECUTOR             VARCHAR(4000)          not null,
   constraint PK_PI_TASK primary key (RWH)
)
@

comment on table PI_TASK is
'任务组'
@

comment on column PI_TASK.RWH is
'任务号'
@

comment on column PI_TASK.TITLE is
'任务描述'
@

comment on column PI_TASK.GROUPID is
'所属组ID'
@

comment on column PI_TASK.YXJB is
'任务优先级'
@

comment on column PI_TASK.ZCYDSBZ is
'堵塞标志'
@

comment on column PI_TASK.REDO is
'失败后是否重做'
@

comment on column PI_TASK.EXECUTOR is
'执行体'
@

-- 创建表: 任务组
create table PI_TASK_GROUP
(
   GROUPID              VARCHAR(20)            not null,
   GYXJB                NUMERIC(10)            not null,
   GTITLE               VARCHAR(80)            not null,
   YWHJ_DM              VARCHAR(6)             not null,
   LRR_DM               VARCHAR(11)            not null,
   LRRQ                 TIMESTAMP              not null,
   constraint PK_PI_TASK_GROUP primary key (GROUPID)
)
@

comment on table PI_TASK_GROUP is
'任务组定义'
@

comment on column PI_TASK_GROUP.GROUPID is
'组ID'
@

comment on column PI_TASK_GROUP.GYXJB is
'组优先级'
@

comment on column PI_TASK_GROUP.GTITLE is
'组描述'
@

comment on column PI_TASK_GROUP.YWHJ_DM is
'业务环节代码'
@

comment on column PI_TASK_GROUP.LRR_DM is
'录入人'
@

comment on column PI_TASK_GROUP.LRRQ is
'录入日期'
@

-- 创建表: 任务调度
create table PI_TASK_SCHEDULE
(
   DDH                  VARCHAR(20)            not null,
   PH                   VARCHAR(20)            not null,
   RWH                  VARCHAR(20)            not null,
   SJXLH                VARCHAR(20),
   PI_CLZT_DM           VARCHAR(2)             not null,
   REDO                 VARCHAR(1)             not null,
   CLXX                 VARCHAR(250),
   KSSJ                 TIMESTAMP,
   JSSJ                 TIMESTAMP,
   LRRQ                 TIMESTAMP                   not null,
   BZ                   VARCHAR(200),
   constraint PK_CHEDULE primary key (DDH)
)
@

comment on table PI_TASK_SCHEDULE is
'任务调度信息'
@

comment on column PI_TASK_SCHEDULE.DDH is
'调度号'
@

comment on column PI_TASK_SCHEDULE.PH is
'批号'
@

comment on column PI_TASK_SCHEDULE.RWH is
'任务号'
@

comment on column PI_TASK_SCHEDULE.SJXLH is
'时间序列号'
@

comment on column PI_TASK_SCHEDULE.PI_CLZT_DM is
'处理状态'
@

comment on column PI_TASK_SCHEDULE.REDO is
'失败后是否重做'
@

comment on column PI_TASK_SCHEDULE.CLXX is
'处理信息'
@

comment on column PI_TASK_SCHEDULE.KSSJ is
'开始时间'
@

comment on column PI_TASK_SCHEDULE.JSSJ is
'结束时间'
@

comment on column PI_TASK_SCHEDULE.LRRQ is
'录入日期'
@

comment on column PI_TASK_SCHEDULE.BZ is
'调度备注'
@

create index IDX_PI_TASK_SCHEDU on PI_TASK_SCHEDULE (
   SJXLH                ASC
)
@

-- 创建表: 时间任务
create table PI_TIMER
(
   SJXLH                VARCHAR(20)            not null,
   JS                   VARCHAR(200)           not null,
   DAYNO                NUMERIC(10),
   TIMEOFDAY            VARCHAR(20),
   PI_SJPD_DM           VARCHAR(2),
   PD                   NUMERIC(10)            not null,
   STARTDATETIME        TIMESTAMP                   not null,
   PI_CLZT_DM           VARCHAR(2)             not null,
   LRR_DM               VARCHAR(11)            not null,
   LRRQ                 TIMESTAMP                   not null,
   SCZXSJ               TIMESTAMP,
   XCZXSJ               TIMESTAMP,
   ZZSJ                 TIMESTAMP,
   constraint PK_PI_TIMER primary key (SJXLH)
)
@

comment on table PI_TIMER is
'时间任务定义'
@

comment on column PI_TIMER.SJXLH is
'时间序列号'
@

comment on column PI_TIMER.JS is
'说明'
@

comment on column PI_TIMER.DAYNO is
'第几天'
@

comment on column PI_TIMER.TIMEOFDAY is
'当前的具体时间: 时分秒'
@

comment on column PI_TIMER.PI_SJPD_DM is
'时间频度代码'
@

comment on column PI_TIMER.PD is
'频度'
@

comment on column PI_TIMER.STARTDATETIME is
'启动时间'
@

comment on column PI_TIMER.PI_CLZT_DM is
'处理状态'
@

comment on column PI_TIMER.LRR_DM is
'录入人'
@

comment on column PI_TIMER.LRRQ is
'录入日期'
@

comment on column PI_TIMER.SCZXSJ is
'上次执行时间'
@

comment on column PI_TIMER.XCZXSJ is
'下次执行时间'
@

comment on column PI_TIMER.ZZSJ is
'中止时间'
@

-- 创建表: 时间任务与任务组
create table PI_TIMER_GROUP
(
   SJXLH                VARCHAR(20)            not null,
   GROUPID              VARCHAR(20)            not null,
   constraint PK_PI_TIMER_GROUP primary key (SJXLH, GROUPID)
)
@

comment on table PI_TIMER_GROUP is
'时间任务与任务组关联'
@

comment on column PI_TIMER_GROUP.SJXLH is
'时间序列号'
@

comment on column PI_TIMER_GROUP.GROUPID is
'组ID'
@




-- Create sequence 
create sequence SEQ_PI_PHDDH
minvalue 1
maxvalue 99999999
start with 81
increment by 1
cache 20
cycle
@
call P_ADD_ROOT('systemmanage','系统管理', 90)
@
call P_ADD_ML('系统管理','批处理')
@
call P_ADD_GNMK('系统管理~批处理','systemmanage.batch.jobgroup','任务组定义','../work/pi/rwzdy/RwzdyBndService.searchTaskGroup.do','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.batch.jobgroup'
@
call P_ADD_GNMK('系统管理~批处理','systemmanage.batch.timer','时间管理','../work/pi/sjgl/TimerdyBndService.initTimer.do','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.batch.timer'
@
call P_ADD_GNMK('系统管理~批处理','systemmanage.batch.console','调度监控','../work/pi/ddjk/index.jsp','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.batch.console'
@
commit
@
-- 创建表: 功能模块点击状态
create table MON_GNMK_CLICK
(
   USERID               VARCHAR(11)               not null,
   GNMK_DM              VARCHAR(256)               not null,
   STAT                 NUMERIC                not null,
   STAT_DATE            TIMESTAMP                   not null,
   constraint PK_MLICKMK_CLICK primary key (USERID, GNMK_DM)
)
@
call P_ADD_ROOT('systemmanage','系统管理', 90)
@
call P_ADD_ML('系统管理','监控管理')
@
call P_ADD_GNMK('系统管理~监控管理','systemmanage.monitoring.onlineusers','在线用户','../work/mon/user/SessionService.getOnlineUsers.do','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.monitoring.onlineusers'
@
call P_ADD_GNMK('系统管理~监控管理','systemmanage.monitoring.userlogs','在线用户历史','../work/mon/user/UserService.getOnlineUsersHistory.do','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.monitoring.userlogs'
@
-- 操作注册
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('00000000000', '过滤','systemmanage.monitoring.onlineusers', '')
@
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('00000000001', '刷新','systemmanage.monitoring.onlineusers', '')
@
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('00000000002', '踢出','systemmanage.monitoring.onlineusers', '')
@
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values ('00000000001', 'systemmanage.monitoring.onlineusers', '00000000000')
@
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values ('00000000001', 'systemmanage.monitoring.onlineusers', '00000000002')
@
commit
@
-- 创建表: 在线用户
create table MON_ONLINE_USER
(
   USERID               VARCHAR(20)            not null,
   CZRY_MC              VARCHAR(30),
   CZRY_DM              VARCHAR(11),
   LOGIN_DATE           TIMESTAMP              not null WITH DEFAULT CURRENT TIMESTAMP,
   LOGOUT_DATE          TIMESTAMP,
   JG_MC                VARCHAR(60),
   IP                   VARCHAR(200),
   SESSIONID            VARCHAR(200),
   FLAG                 CHAR(1)                not null,
   JG_DM                VARCHAR(15),
   ID                   VARCHAR(40)               not null,
   constraint PK_MON_ONLINE_USER primary key (ID)
)
@

create index IDX_MON_JG_DM on MON_ONLINE_USER (
   JG_DM                ASC
)
@

create index IDX_MON_LOGIN_DATE on MON_ONLINE_USER (
   LOGIN_DATE           ASC
)
@

create index IDX_MON_USERID on MON_ONLINE_USER (
   USERID               ASC
)
@

create index IDX_MON_USERID_ID on MON_ONLINE_USER (
   USERID               ASC,
   ID                   ASC
)
@


comment on table MON_ONLINE_USER
  is '在线用户'
@
comment on column MON_ONLINE_USER.USERID
  is '用户id'
@
comment on column MON_ONLINE_USER.CZRY_MC
  is '操作人员名称'
@
comment on column MON_ONLINE_USER.CZRY_DM
  is '操作人员代码'
@
comment on column MON_ONLINE_USER.LOGIN_DATE
  is '登录时间'
@
comment on column MON_ONLINE_USER.LOGOUT_DATE
  is '退出时间'
@
comment on column MON_ONLINE_USER.JG_MC
  is '所属机构名称'
@
comment on column MON_ONLINE_USER.IP
  is '用户ip地址'
@
comment on column MON_ONLINE_USER.JG_DM
  is '所属机构代码'
@
comment on column MON_ONLINE_USER.FLAG
  is '状态'
@


commit
@

call P_ADD_ROOT('systemmanage','系统管理', 90)
@
call P_ADD_ML('系统管理','待办已办')
@
call P_ADD_GNMK('系统管理~待办已办','systemmanage.todo.setting','待办事宜设置','../work/message/dynacol/extDynacol.html','090000')
@
call P_ADD_GNMK('系统管理~待办已办','systemmanage.todo.dashboard','待办事宜','../work/message/main/index.jsp?type=1&gnmk_dm=systemmanage.todo.dashboard','090000')
@
call P_ADD_GNMK('系统管理~待办已办','systemmanage.done.dashboard','已办事宜','../work/message/main/index.jsp?type=2&gnmk_dm=systemmanage.done.dashboard','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.todo.setting'
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.todo.dashboard';
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.done.dashboard';
@
-- 操作注册
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('filterByPriority', '按优先级过滤', 'systemmanage.todo.dashboard', '')
@
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('filterByType', '按类型过滤', 'systemmanage.todo.dashboard', '')
@
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.todo.dashboard','filterByPriority')
@
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.todo.dashboard','filterByType')
@

insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM) values ('filterByPriority', '按优先级过滤', 'systemmanage.done.dashboard');
@
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM) values ('filterByType', '按类型过滤', 'systemmanage.done.dashboard');
@
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.done.dashboard','filterByPriority');
@
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.done.dashboard','filterByType');
@
commit
@



-- 创建表: 消息系统
create table MESSAGE_SYSTEM
(
   ID                   VARCHAR(4)             not null,
   NAME               VARCHAR(64)            not null,
   KEY_NAME                VARCHAR(16)            not null,
   IS_LEGACY            CHAR(1)                not null,
   HANDLER_CLASS        VARCHAR(256)           not null,
   MAPPING_BUILDER_CLASS VARCHAR(256)           not null,
   DESCRIPTION          VARCHAR(256),
   IS_ENABLED           CHAR(1)                not null,
   constraint PK_MESSAGE_SYSTEM primary key (ID),
   constraint UNI_E_SYSTEM_KEY unique (KEY)
)
@

comment on table MESSAGE_SYSTEM is
'消息系统'
@

comment on column MESSAGE_SYSTEM.ID is
'消息系统id'
@

comment on column MESSAGE_SYSTEM.NAME is
'消息系统名称'
@

comment on column MESSAGE_SYSTEM.KEY_NAME is
'消息系统key，key_id为消息UID'
@

comment on column MESSAGE_SYSTEM.IS_LEGACY is
'是否为遗留系统，Y：遗留系统，N：非遗留系统'
@

comment on column MESSAGE_SYSTEM.HANDLER_CLASS is
'消息处理类，必须继承自MessageHandler'
@

comment on column MESSAGE_SYSTEM.MAPPING_BUILDER_CLASS is
'映射处理类，必须实现MappingBuilder接口'
@

comment on column MESSAGE_SYSTEM.DESCRIPTION is
'消息系统描述'
@

comment on column MESSAGE_SYSTEM.IS_ENABLED is
'是否启用此消息系统'
@



insert into MESSAGE_SYSTEM (ID, NAME, KEY_NAME, IS_LEGACY, HANDLER_CLASS, MAPPING_BUILDER_CLASS, DESCRIPTION, IS_ENABLED)
  values ('1000', '缺省消息系统', 'GENERIC', 'N', 'message.handler.GenericMessageHandler', 'message.mapping.GenericORMappingBuilder', null, 'Y')
@

commit
@


-- 创建表: 消息类型
create table MESSAGE_TYPE
(
   ID                   CHAR(6)                not null,
   NAME               VARCHAR(64)            not null,
   constraint PK_MESSAGE_TYPE primary key (ID)
)
@

comment on table MESSAGE_TYPE is
'消息类型'
@

comment on column MESSAGE_TYPE.ID is
'消息类型id'
@

comment on column MESSAGE_TYPE.NAME is
'消息类型名称'
@


insert into MESSAGE_TYPE (ID, NAME)
values ('100000', '任务')
@
insert into MESSAGE_TYPE (ID, NAME)
values ('200000', '提示')
@
insert into MESSAGE_TYPE (ID, NAME)
values ('300000', '预警')
@
insert into MESSAGE_TYPE (ID, NAME)
values ('900000', '消息')
@

commit
@

-- 创建表: 消息
create table MESSAGE
(
   ID                   VARCHAR(20)            not null,
   SYSTEM_NAME          VARCHAR(50),
   MESSAGE_SYSTEM_ID    VARCHAR(4),
   TOPIC                VARCHAR(512)           not null,
   TOPIC_URL            VARCHAR(512),
   TYPE               CHAR(6),
   PRIORITY             CHAR(1),
   ALLOW_DELETE         CHAR(1),
   CREATE_TIME          TIMESTAMP                   not null,
   CREATED_BY           CHAR(11),
   LAST_RECEIVED_BY     CHAR(11),
   LAST_RECEIVE_TIME    TIMESTAMP,
   IS_ARCHIVED          CHAR(1)                not null,
   ARCHIVE_TIME         TIMESTAMP,
   AVAILABLE_UNTIL      TIMESTAMP,
   COMMENTS             VARCHAR(4000),
   constraint PK_MESSAGE primary key (ID)
)
@


alter table MESSAGE
   add constraint FK_SG_SYSTEM foreign key (MESSAGE_SYSTEM_ID)
      references MESSAGE_SYSTEM (ID)
      on delete no action on update restrict
@

alter table MESSAGE
   add constraint FK_MESSAGE_SYSTEM foreign key (SYSTEM_NAME)
      references QX_SYSTEM (SYSTEMNAME)
      on delete no action on update restrict
@

alter table MESSAGE
   add constraint FK_MESSAGE_TYPE foreign key (TYPE)
      references MESSAGE_TYPE (ID)
      on delete no action on update restrict
@

comment on table MESSAGE is
'通用消息'
@

comment on column MESSAGE.ID is
'消息id'
@

comment on column MESSAGE.SYSTEM_NAME is
'系统名称（参照qx_system）'
@

comment on column MESSAGE.MESSAGE_SYSTEM_ID is
'消息系统id'
@

comment on column MESSAGE.TOPIC is
'消息主题'
@

comment on column MESSAGE.TOPIC_URL is
'消息主题链接url'
@

comment on column MESSAGE.TYPE is
'消息类型'
@

comment on column MESSAGE.PRIORITY is
'优先级，H：高，M：中等，L：低'
@

comment on column MESSAGE.ALLOW_DELETE is
'是否允许删除，Y：允许，N：不允许'
@

comment on column MESSAGE.CREATE_TIME is
'创建时间'
@

comment on column MESSAGE.CREATED_BY is
'创建人'
@

comment on column MESSAGE.LAST_RECEIVED_BY is
'最后接收人'
@

comment on column MESSAGE.LAST_RECEIVE_TIME is
'最后接收时间'
@

comment on column MESSAGE.IS_ARCHIVED is
'是否归档，Y：已归档，N：未归档'
@

comment on column MESSAGE.ARCHIVE_TIME is
'归档时间'
@

comment on column MESSAGE.AVAILABLE_UNTIL is
'任务的办结期限，消息的有效期限'
@

comment on column MESSAGE.COMMENTS is
'注释'
@

-- 创建表: 消息字段定义
create table MESSAGE_FIELD_DEFINITION
(
   NAME               VARCHAR(128)           not null,
   IS_CUSTOM            CHAR(1)                not null,
   CONTENT_TYPE         CHAR(2),
   DESCRIPTION          VARCHAR(256),
   constraint PK_IELD_DEF primary key (NAME)
)
@

comment on table MESSAGE_FIELD_DEFINITION is
'消息字段定义'
@

comment on column MESSAGE_FIELD_DEFINITION.NAME is
'消息字段名称'
@

comment on column MESSAGE_FIELD_DEFINITION.IS_CUSTOM is
'是否为自定义字段'
@

comment on column MESSAGE_FIELD_DEFINITION.CONTENT_TYPE is
'字段内容类型（暂不支持，留空）'
@

comment on column MESSAGE_FIELD_DEFINITION.DESCRIPTION is
'字段说明'
@



insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('ID', 'N', null, '消息编号')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('SYSTEMNAME', 'N', null, '系统名称')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('MESSAGESYSTEMID', 'N', null, '来源消息系统号')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('TOPIC', 'N', null, '主题')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('TOPICURL', 'N', null, '主题链接url')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('TYPE', 'N', null, '任务类型')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('PRIORITY', 'N', null, '优先级')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('ALLOWDELETE', 'N', null, '是否允许删除')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('CREATETIME', 'N', null, '创建时间')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('CREATEDBY', 'N', null, '创建人')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('LASTRECEIVEDBY', 'N', null, '最后接收人')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('ISARCHIVED', 'N', null, '是否归档')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('ARCHIVETIME', 'N', null, '归档时间')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('AVAILABLEUNTIL', 'N', null, '有效期/办结期限')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('COMMENTS', 'N', null, '备注')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('STATUS', 'Y', null, '状态')
@
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('LASTRECEIVETIME', 'N', null, '最后接收时间')
@

commit
@


-- 创建表: 消息扩展
create table MESSAGE_EXTENSION
(
   MESSAGE_ID           VARCHAR(10)            not null,
   CUSTOM_FIELD_NAME    VARCHAR(128)           not null,
   FIELD_VALUE          VARCHAR(4000),
   constraint PK_MESSAGE_EXT primary key (MESSAGE_ID, CUSTOM_FIELD_NAME)
)
@


alter table MESSAGE_EXTENSION
   add constraint FK_XT_FIELD foreign key (CUSTOM_FIELD_NAME)
      references MESSAGE_FIELD_DEFINITION (NAME)
      on delete no action on update restrict
@

alter table MESSAGE_EXTENSION
   add constraint FK_XT_MESSAGE foreign key (MESSAGE_ID)
      references MESSAGE (ID)
      on delete no action on update restrict
@

comment on table MESSAGE_EXTENSION is
'通用消息扩展'
@

comment on column MESSAGE_EXTENSION.MESSAGE_ID is
'消息id'
@

comment on column MESSAGE_EXTENSION.CUSTOM_FIELD_NAME is
'自定义字段名称'
@

comment on column MESSAGE_EXTENSION.FIELD_VALUE is
'自定义字段值'
@



-- 创建表: 消息字段展示定义
create table MESSAGE_FIELD_DISPLAY
(
   USER_ID              VARCHAR(11)            not null,
   FIELD_NAME           VARCHAR(128)           not null,
   DISPLAY_ORDER        NUMERIC                not null,
   DISPLAY_NAME         VARCHAR(128),
   WIDTH                VARCHAR(16),
   SORTORDER            VARCHAR(2),
   SORTDIRECTION        VARCHAR(2),
   constraint PK_IELD_DISPLAY primary key (USER_ID, FIELD_NAME, DISPLAY_ORDER)
)
@


alter table MESSAGE_FIELD_DISPLAY
   add constraint FK_IELD_DISPLAY foreign key (FIELD_NAME)
      references MESSAGE_FIELD_DEFINITION (NAME)
      on delete no action on update restrict
@

comment on table MESSAGE_FIELD_DISPLAY is
'消息字段展示定义（分用户）'
@

comment on column MESSAGE_FIELD_DISPLAY.USER_ID is
'用户id（操作人员代码）'
@

comment on column MESSAGE_FIELD_DISPLAY.FIELD_NAME is
'通用消息字段名称'
@

comment on column MESSAGE_FIELD_DISPLAY.DISPLAY_ORDER is
'显示顺序，数值越小越靠前'
@

comment on column MESSAGE_FIELD_DISPLAY.DISPLAY_NAME is
'显示名称'
@

comment on column MESSAGE_FIELD_DISPLAY.WIDTH is
'显示宽度'
@

-- 创建表: 消息系统的消息字段
create table MESSAGE_SYSTEM_FIELD
(
   MESSAGE_SYSTEM_ID    VARCHAR(4)             not null,
   FIELD_NAME           VARCHAR(128)           not null,
   constraint PK_YSTEM_FIELD primary key (MESSAGE_SYSTEM_ID, FIELD_NAME)
)
@


alter table MESSAGE_SYSTEM_FIELD
   add constraint FK_YSTEM_FIELD_ID foreign key (MESSAGE_SYSTEM_ID)
      references MESSAGE_SYSTEM (ID)
      on delete no action on update restrict
@

alter table MESSAGE_SYSTEM_FIELD
   add constraint FK_D_NAME foreign key (FIELD_NAME)
      references MESSAGE_FIELD_DEFINITION (NAME)
      on delete no action on update restrict
@

comment on table MESSAGE_SYSTEM_FIELD is
'消息系统和消息字段对照关系'
@

comment on column MESSAGE_SYSTEM_FIELD.MESSAGE_SYSTEM_ID is
'消息系统id'
@

comment on column MESSAGE_SYSTEM_FIELD.FIELD_NAME is
'消息字段名称'
@



insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'ALLOWDELETE')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'ARCHIVETIME')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'AVAILABLEUNTIL')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'COMMENTS')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'CREATEDBY')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'CREATETIME')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'ID')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'ISARCHIVED')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'LASTRECEIVEDBY')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'LASTRECEIVETIME')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'MESSAGESYSTEMID')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'PRIORITY')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'STATUS')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'SYSTEMNAME')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'TOPIC')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'TOPICURL')
@
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'TYPE')
@


commit
@

-- 创建表: 消息字段映射
create table MESSAGE_FIELD_MAPPING
(
   MESSAGE_SYSTEM_ID    VARCHAR(4),
   FIELD_NAME           VARCHAR(128),
   LEGACY_TABLE_NAME    VARCHAR(32)            not null,
   LEGACY_FIELD_EXP     VARCHAR(256)           not null
)
@


alter table MESSAGE_FIELD_MAPPING
   add constraint FK__MAPPING_FN foreign key (FIELD_NAME)
      references MESSAGE_FIELD_DEFINITION (NAME)
      on delete no action on update restrict
@

alter table MESSAGE_FIELD_MAPPING
   add constraint FK__MAPPING_ID foreign key (MESSAGE_SYSTEM_ID, FIELD_NAME)
      references MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
      on delete no action on update restrict
@

comment on table MESSAGE_FIELD_MAPPING is
'通用消息字段映射'
@

comment on column MESSAGE_FIELD_MAPPING.MESSAGE_SYSTEM_ID is
'消息系统id'
@

comment on column MESSAGE_FIELD_MAPPING.FIELD_NAME is
'字段名称'
@

comment on column MESSAGE_FIELD_MAPPING.LEGACY_TABLE_NAME is
'对应的遗留系统表名称'
@

comment on column MESSAGE_FIELD_MAPPING.LEGACY_FIELD_EXP is
'对应的遗留系统字段表达式（SQL语法）'
@

-- 创建表: 消息字段渲染器
create table MESSAGE_FIELD_RENDER
(
   ID                   VARCHAR(10),
   NAME               VARCHAR(32),
   MESSAGE_SYSTEM_ID    VARCHAR(4),
   DESCRIPTION          VARCHAR(256),
   FIELD_NAME           VARCHAR(128),
   RENDER_CLASS         VARCHAR(256)
)
@

alter table MESSAGE_FIELD_RENDER
   add constraint FK_IELD_RENDER foreign key (FIELD_NAME)
      references MESSAGE_FIELD_DEFINITION (NAME)
      on delete no action on update restrict
@

comment on table MESSAGE_FIELD_RENDER is
'通用消息字段渲染器'
@

comment on column MESSAGE_FIELD_RENDER.ID is
'渲染器id'
@

comment on column MESSAGE_FIELD_RENDER.NAME is
'渲染器名称'
@

comment on column MESSAGE_FIELD_RENDER.MESSAGE_SYSTEM_ID is
'消息系统id'
@

comment on column MESSAGE_FIELD_RENDER.DESCRIPTION is
'渲染器描述'
@

comment on column MESSAGE_FIELD_RENDER.FIELD_NAME is
'字段名称'
@

comment on column MESSAGE_FIELD_RENDER.RENDER_CLASS is
'渲染器类'
@



insert into MESSAGE_FIELD_RENDER (ID, NAME, MESSAGE_SYSTEM_ID, DESCRIPTION, FIELD_NAME, RENDER_CLASS)
values ('00000001', 'SGYTOPIC', '9001', null, 'TOPIC', 'ctais.business.message.common.SgyTopicMessageRender')
@
insert into MESSAGE_FIELD_RENDER (ID, NAME, MESSAGE_SYSTEM_ID, DESCRIPTION, FIELD_NAME, RENDER_CLASS)
values ('00000002', 'TODOTOPIC', '9000', null, 'TOPIC', 'ctais.business.message.common.TodoTopicMessageRender')
@
insert into MESSAGE_FIELD_RENDER (ID, NAME, MESSAGE_SYSTEM_ID, DESCRIPTION, FIELD_NAME, RENDER_CLASS)
values ('00000003', 'TODOLSTOPIC', '9002', null, 'TOPIC', 'ctais.business.message.common.TodoTopicMessageRender')
@
insert into MESSAGE_FIELD_RENDER (ID, NAME, MESSAGE_SYSTEM_ID, DESCRIPTION, FIELD_NAME, RENDER_CLASS)
values ('00000004','reptodotopic','1000','','TOPIC','ctais.business.message.common.TodoTopicMessageRender')
@


commit
@

call P_ADD_ROOT('systemmanage','系统管理', 90)
@
call P_ADD_ML('系统管理','监控管理')
@
call P_ADD_GNMK('系统管理~监控管理','systemmanage.monitoring.track','跟踪','../track/index.jsp','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.monitoring.track'
@call P_ADD_ROOT('demo','范例', 99)
@
call P_ADD_ML('范例','查询框架')
@
call P_ADD_GNMK('范例~查询框架','demo.query.operatorquery','操作人员查询','../work/query/index.jsp?gnmk_dm=demo.query.operatorquery&queryid=test.test1&GZBZ=N','000000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'demo.query.operatorquery';
@
commit
@
-- 创建表: 查询模块代码
create table DM_CXMK
(
   CXMK_DM              VARCHAR(6)                not null,
   CXMK_MC              VARCHAR(50)            not null,
   YM_RIGHT             VARCHAR(50)            not null,
   YM_TOP               VARCHAR(50)            not null,
   XYBZ                 CHAR(1)                not null,
   YXBZ                 CHAR(1)                not null,
   constraint PK_DM_CXMK primary key (CXMK_DM)
)
@

comment on table DM_CXMK is
'查询模块代码'
@

comment on column DM_CXMK.CXMK_DM is
'查询模块代码（前两位子系统分类，如SB1101）'
@

comment on column DM_CXMK.CXMK_MC is
'查询模块名称'
@

comment on column DM_CXMK.YM_RIGHT is
'页面（结果显示页面链接RIGHT.HTM全路径）'
@

comment on column DM_CXMK.YM_TOP is
'页面（用户条件定制页面链接TOP.JSP全路径）'
@

comment on column DM_CXMK.XYBZ is
'选用标志'
@

comment on column DM_CXMK.YXBZ is
'有效标志'
@


-- 创建表: 异步查询
create table CX_ASYNQUERY
(
   ASYNQUERYID          VARCHAR(255)           not null,
   QUERYID              VARCHAR(255)           not null,
   CONDITION_NAME          VARCHAR(2000)          not null,
   CACHETYPE            VARCHAR(20)            not null,
   QUERYTIME            TIMESTAMP                   not null,
   constraint PK_CX_ASYNQUERY primary key (ASYNQUERYID)
)
@

comment on table CX_ASYNQUERY is
'异步查询'
@

comment on column CX_ASYNQUERY.ASYNQUERYID is
'异步查询ID'
@

comment on column CX_ASYNQUERY.QUERYID is
'查询ID'
@

comment on column CX_ASYNQUERY.CONDITION_NAME is
'查询条件'
@

comment on column CX_ASYNQUERY.CACHETYPE is
'缓存类型。none(无缓存)、db(数据库)、mem(内存)，默认为db。'
@

comment on column CX_ASYNQUERY.QUERYTIME is
'查询时间'
@

-- 创建表: 查询缓存
create table CX_CACHE
(
   QUERYID              VARCHAR(255)           not null,
   CONDITION_NAME          VARCHAR(700)          not null,
   CREATINGTIME         TIMESTAMP                   not null,
   EXPIRINGTIME         TIMESTAMP,
   DETAILRESULT         VARCHAR(255),
   DETAILRESULTSZIE     NUMERIC(10),
   STATRESULT           VARCHAR(255),
   STATRESULTSZIE       NUMERIC(10),
   SUMRESULT            VARCHAR(255),
   constraint PK_CX_CACHE primary key (QUERYID, CONDITION_NAME)
)
@

comment on table CX_CACHE is
'查询缓存'
@

comment on column CX_CACHE.QUERYID is
'查询ID'
@

comment on column CX_CACHE.CONDITION_NAME is
'查询条件'
@

comment on column CX_CACHE.CREATINGTIME is
'缓存创建时间'
@

comment on column CX_CACHE.EXPIRINGTIME is
'缓存过期时间'
@

comment on column CX_CACHE.DETAILRESULT is
'明细查询结果表名'
@

comment on column CX_CACHE.DETAILRESULTSZIE is
'明细查询结果行数'
@

comment on column CX_CACHE.STATRESULT is
'统计查询结果表名'
@

comment on column CX_CACHE.STATRESULTSZIE is
'统计查询结果行数'
@

comment on column CX_CACHE.SUMRESULT is
'合计查询结果表名'
@


create table QX_FAV_GNMK_TREE
(
  JD_DM    VARCHAR(21) not null,
  FJD_DM   VARCHAR(21) not null,
  JD_MC    VARCHAR(80) not null,
  GNMK_DM  VARCHAR(256),
  JDLX_DM  VARCHAR(2),
  JD_ORDER NUMERIC(5) not null,
  USERID   VARCHAR(11) not null,
  constraint PK_QX_FAV_GNMK_TREE primary key (JD_DM,USERID)
)
@

comment on column QX_FAV_GNMK_TREE.JD_DM
  is '功能模块代码'
@
comment on column QX_FAV_GNMK_TREE.FJD_DM
  is '节点类型代码'
@
comment on column QX_FAV_GNMK_TREE.JD_MC
  is '节点名称'
@
comment on column QX_FAV_GNMK_TREE.GNMK_DM
  is '节点代码'
@
comment on column QX_FAV_GNMK_TREE.JDLX_DM
  is '父节点代码'
@
comment on column QX_FAV_GNMK_TREE.JD_ORDER
  is '节点顺序'
@
comment on column QX_FAV_GNMK_TREE.USERID
  is '用户ID'
@
--alter table QX_FAV_GNMK_TREE
--  add constraint FK_QX_FAV_GNMK_TREE_USERID foreign key (USERID)
--  references QX_USER (USERID)
--@

call P_ADD_ROOT('systemmanage','系统管理', 90)
@
call P_ADD_ML('系统管理','组织权限')
@
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.system','业务系统注册','../portal/system/SystemBndService.ywxtzclist.do','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.system'
@
commit
@create table DASHBOARD_TABINFO
(
   tabid              VARCHAR(36)            not null,
   tabtype            VARCHAR(15)            not null,
   userid             VARCHAR(11),
   jsdm               VARCHAR(11),
   tabtitle           VARCHAR(50)            not null,
   tabcolumsnum       INT                    not null,
   tabitemheight      INT                    not null,
   createtime         TIME                   not null,
   constraint P_Key_1 primary key (tabid)
);

comment on column DASHBOARD_TABINFO.tabid is
'tabid';

comment on column DASHBOARD_TABINFO.tabType is
'tab类型 portal/table1/table2';

comment on column DASHBOARD_TABINFO.userid is
'userid';

comment on column DASHBOARD_TABINFO.jsdm is
'角色代码';

comment on column DASHBOARD_TABINFO.tabtitle is
'tab页标题';

comment on column DASHBOARD_TABINFO.tabcolumsnum is
'tab页中内容列数';

comment on column DASHBOARD_TABINFO.tabitemheight is
'tab页中portlet高度';

comment on column DASHBOARD_TABINFO.createtime is
'添加时间';

create table DASHBOARD_TABCONTENTINFO
(
   tabid              VARCHAR(36)            not null,
   tabcontent         VARCHAR(2000),
   constraint P_Key_1 primary key (tabid)
);

comment on column DASHBOARD_TABCONTENTINFO.tabid is
'tabid';

comment on column DASHBOARD_TABCONTENTINFO.tabcontent is
'tab页中内容';call P_ADD_ROOT('systemmanage','系统管理', 90)
@
call P_ADD_ML('系统管理','系统初始化')
@
call P_ADD_GNMK('系统管理~系统初始化','systemmanage.init.roleDashboard','角色主页管理','../dashboard/dashboard.jsp?dashboardType=role','000000')
@
commit
@call P_ADD_ROOT('systemmanage','系统管理', 90)
@
call P_ADD_ML('系统管理','组织权限')
@
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.help','资源在线帮助','../portal/help/GnmkBndService.select.do','090000')
@
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.resource.help'
@
commit
@

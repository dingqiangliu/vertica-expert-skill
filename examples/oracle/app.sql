

-- 创建表: 临时表编目录
create table XT_TEMPTABLECATALOG
(
  TABLENAME          VARCHAR2(255) not null,
  CREATINGTIME       DATE not null,
  EXPIRINGTIME       DATE,
  CONNECTIONPOOLNAME VARCHAR2(255)
)
;
comment on table XT_TEMPTABLECATALOG
  is '临时表编目录。持久化已申请的临时表信息';
comment on column XT_TEMPTABLECATALOG.TABLENAME
  is 'TABLENAME';
comment on column XT_TEMPTABLECATALOG.CREATINGTIME
  is '创建时间';
comment on column XT_TEMPTABLECATALOG.EXPIRINGTIME
  is '过期时间';
comment on column XT_TEMPTABLECATALOG.CONNECTIONPOOLNAME
  is '临时表所在数据库的连接池名称，为空表示在生产环境（使用缺省池）。删除临时表时将使用该连接池。';
alter table XT_TEMPTABLECATALOG
  add constraint PK_XT_TEMPTABLECATALOG primary key (TABLENAME);
create index IDX_XT_TEMPTABLECATALOG on XT_TEMPTABLECATALOG (CREATINGTIME, EXPIRINGTIME);



-- 创建表: 系统参数
create table XT_XTCS
(
  CSXH   VARCHAR2(5) not null,
  JG_DM  VARCHAR2(15) not null,
  CSMC   VARCHAR2(80) not null,
  CSNR   VARCHAR2(500) not null,
  SYSM   VARCHAR2(200),
  XYBZ   CHAR(1) not null,
  JZSZBZ CHAR(1)
)
;
comment on table XT_XTCS
  is '系统参数';
comment on column XT_XTCS.CSXH
  is '参数序号';
comment on column XT_XTCS.JG_DM
  is '机构代码';
comment on column XT_XTCS.CSMC
  is '参数名称';
comment on column XT_XTCS.CSNR
  is '参数内容';
comment on column XT_XTCS.SYSM
  is '使用说明';
comment on column XT_XTCS.XYBZ
  is '选用标志';
comment on column XT_XTCS.JZSZBZ
  is '集中设置标志';
alter table XT_XTCS
  add constraint PK_XT_XTCS primary key (CSXH, JG_DM);


insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10000', 'PUBLIC', '系统名称', 'ADP 集成工作平台', '设置系统名称', 'Y', 'Y');
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
  values ('10001', 'PUBLIC', '序号生成器', '9', '9', 'Y', 'Y');

commit;




-- ============================================================
--   修改日期：   2010-10-26
--   修改内容：
--			插入密码配置数据
-- ============================================================

insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10002', 'PUBLIC', '密码规则正则表达式', '\d+', '用于校验用户修改密码时新密码组成规则("\d+"为全数字,禁止删除,设置值为0时为不限制)', 'Y', 'Y');
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10003', 'PUBLIC', '允许最大密码输入错误次数', '5', '在一段时间内用户可尝试的最大密码输入错误次数 (禁止删除,设置值为0时为不限制)', 'Y', 'Y');
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10004', 'PUBLIC', '密码输入错误连续重试限制时间', '30', '密码输入错误连续重试的限制时间,单位:分钟 (禁止删除,设置值为0时为不限制)', 'Y', 'Y');
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10005', 'PUBLIC', '达到最大密码输入错误次数后处理方式', '1', '1:指定时间后允许重试;2:锁定用户 (禁止删除,设置值为0时为不处理)', 'Y', 'Y');
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10006', 'PUBLIC', '限制用户重试时间', '30', '用户达到最大密码输入错误次数后限制登录的时间段,单位:分钟 (禁止删除,设置值为0时为不限制)', 'Y', 'Y');

commit;

-- 创建表: 业务环节代码
create table DM_YWHJ
(
  YWHJ_DM VARCHAR2(6) not null,
  YWHJ_MC VARCHAR2(80) not null,
  XYBZ    CHAR(1) not null,
  YXBZ    CHAR(1) not null
)
;
comment on table DM_YWHJ
  is '业务环节代码';
comment on column DM_YWHJ.YWHJ_DM
  is '业务环节代码';
comment on column DM_YWHJ.YWHJ_MC
  is '业务环节名称';
comment on column DM_YWHJ.XYBZ
  is '选用标志';
comment on column DM_YWHJ.YXBZ
  is '有效标志';
alter table DM_YWHJ
  add constraint PK_DM_YWHJ primary key (YWHJ_DM);

insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('010000', '行政管理环节', 'N', 'Y');
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('020000', '党务管理环节', 'N', 'Y');
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('030400', '资料档案管理', 'Y', 'Y');
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('040000', '数据管理', 'Y', 'Y');
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('040100', '数据采集', 'Y', 'Y');
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('040200', '数据分析审计', 'Y', 'Y');
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('000000', '综合', 'Y', 'Y');
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('090000', '系统维护', 'Y', 'Y');
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('090100', '权限管理', 'Y', 'Y');
insert into DM_YWHJ (YWHJ_DM, YWHJ_MC, XYBZ, YXBZ)
values ('090200', '数据字典', 'Y', 'Y');

commit;



-- 创建表: 系统
create table QX_SYSTEM
(
  SYSTEMNAME        VARCHAR2(80) not null,
  DESCRIPTION       VARCHAR2(50),
  ICONURL           VARCHAR2(50),
  VIRTRULROOTNAME   VARCHAR2(50),
  COOKIENAME        VARCHAR2(50),
  REALROOTURL       VARCHAR2(200),
  WELCOMETITTLE     VARCHAR2(50),
  WELCOMEURL        VARCHAR2(200),
  LOGINURL          VARCHAR2(500),
  LOGINTYPE         VARCHAR2(10) default 'U' not null,
  LOGOUTURL         VARCHAR2(200),
  LOGOUTTYPE        VARCHAR2(10) default 'U' not null,
  USERPARAMNAME     VARCHAR2(50),
  PASSWORDPARAMNAME VARCHAR2(50),
  LOGINSUCCESSTAG   VARCHAR2(200) default ':CONSOLE:',
  TESTURL           VARCHAR2(200),
  SORTORDER         VARCHAR2(2) default '99' not null,
  XYBZ              VARCHAR2(1) default 'Y' not null,
  YXBZ              VARCHAR2(1) default 'Y' not null,
  BASEURL           VARCHAR2(100) default '/ctais',
  LOGINTIME         VARCHAR2(1) default 'S',
  SCRIPT            clob,
  SESSIONKEEP       VARCHAR2(1) default 'Y',
  SESSIONKEEPTYPE   VARCHAR2(10) default 'U',
  SESSIONKEEPURL    VARCHAR2(500),
  UNIUSERTYPE       VARCHAR2(10) default 'L',
  UNIUSERON         VARCHAR2(1) default 'N',
  UNIUSERDATA       VARCHAR2(200)
)
;
alter table QX_SYSTEM
  add primary key (SYSTEMNAME);
 comment on table QX_SYSTEM
  is '系统';
comment on column QX_SYSTEM.SYSTEMNAME
  is '系统名称';
comment on column QX_SYSTEM.DESCRIPTION
  is '系统描述';
comment on column QX_SYSTEM.WELCOMETITTLE
  is '欢迎标题';
comment on column QX_SYSTEM.WELCOMEURL
  is '欢迎页url';
comment on column QX_SYSTEM.LOGINURL
  is '登录地址';
comment on column QX_SYSTEM.LOGINTYPE
  is '登录类型';
comment on column QX_SYSTEM.LOGOUTURL
  is '退出地址';
comment on column QX_SYSTEM.LOGOUTTYPE
  is '退出类型';
comment on column QX_SYSTEM.BASEURL
  is '基本路径';
comment on column QX_SYSTEM.LOGINSUCCESSTAG
  is '登录成功标志';
comment on column QX_SYSTEM.SCRIPT
  is '执行脚本';


insert into QX_SYSTEM (SYSTEMNAME, DESCRIPTION, ICONURL, VIRTRULROOTNAME, COOKIENAME, REALROOTURL, WELCOMETITTLE, WELCOMEURL, LOGINURL, LOGINTYPE, LOGOUTURL, LOGOUTTYPE, USERPARAMNAME, PASSWORDPARAMNAME, LOGINSUCCESSTAG, TESTURL, SORTORDER, XYBZ, YXBZ, BASEURL, LOGINTIME, SCRIPT, SESSIONKEEP, SESSIONKEEPTYPE, SESSIONKEEPURL, UNIUSERTYPE, UNIUSERON, UNIUSERDATA)
  values ('系统管理', '系统管理', null, null, null, null, null, null, null, 'U', '../entry/loginOut?type=ipc&purpose=LogInService&module=Entry', 'U', null, null, ':CONSOLE:', null, '00', 'Y', 'Y', '/adp', 'F', null, 'Y', 'U', '../index.htm', 'L', 'N', null);

commit;


create table QX_SYSTEM_USER
(
  SYSTEMNAME VARCHAR2(50) not null,
  USERID     VARCHAR2(11) not null,
  NAME       VARCHAR2(20),
  CZRY_MC    VARCHAR2(60),
  LOGINNAME  VARCHAR2(40) not null,
  PASSWORD   VARCHAR2(40)
)
;
alter table QX_SYSTEM_USER
  add constraint QX_SYSTEM_USER_PK primary key (SYSTEMNAME, USERID);
create index IDX_QX_SYSTEM_USER_SYS on QX_SYSTEM_USER (SYSTEMNAME);
create index IDX_QX_SYSTEM_USER_USER on QX_SYSTEM_USER (USERID);







-- 创建表: 岗位
create table QX_GW
(
  GW_DM    VARCHAR2(15) not null,
  GW_MC    VARCHAR2(80) not null,
  GWLX     VARCHAR2(2),
  YWBS     VARCHAR2(5),
  SJ_GW_DM VARCHAR2(15),
  QX_JG_DM VARCHAR2(15) not null,
  JG_DM    VARCHAR2(15) not null,
  YWHJ_DM  VARCHAR2(6) not null
)
;
comment on column QX_GW.GW_DM
  is '岗位代码';
comment on column QX_GW.GW_MC
  is '岗位名称';
comment on column QX_GW.GWLX
  is '岗位类型';
comment on column QX_GW.YWBS
  is '业务标识';
comment on column QX_GW.SJ_GW_DM
  is '上级岗位代码';
comment on column QX_GW.QX_JG_DM
  is '权限机关代码';
comment on column QX_GW.JG_DM
  is '机关代码';
comment on column QX_GW.YWHJ_DM
  is '业务环节代码';
alter table QX_GW
  add constraint PK_QX_GW primary key (GW_DM);
alter table QX_GW
  add constraint FK_QX_GW_YWHJ_DM foreign key (YWHJ_DM)
  references DM_YWHJ (YWHJ_DM);


insert into QX_GW (GW_DM, GW_MC, GWLX, YWBS, SJ_GW_DM, QX_JG_DM, JG_DM, YWHJ_DM)
  values ('000000000000000', '超级用户岗', '01', '01   ', null, '000000000000000', '000000000000000', '000000');

commit;


-- 创建表: 岗位扩展
create table QX_GW_EX
(
  GW_DM    VARCHAR2(15) not null,
  QX_JG_DM VARCHAR2(15) not null
)
;
alter table QX_GW_EX
  add constraint PK_QX_GW_EX primary key (GW_DM, QX_JG_DM);
create index IDX_QX_GW_EX_GW_DM on QX_GW_EX (GW_DM);

-- 创建表: 功能模板(角色)
create table QX_GNMB
(
  GNMB_DM  VARCHAR2(11) not null,
  GNMB_MC  VARCHAR2(80) not null,
  SS_GW_DM VARCHAR2(15),
  JSSX_DM  VARCHAR2(2) not null,
  JG_DM    VARCHAR2(15) default '00000000000' not null,
  SFGXJS   CHAR(1) default 'N' not null
)
;
alter table QX_GNMB
  add constraint PK_QX_GNMB primary key (GNMB_DM);
comment on table QX_GNMB
  is '功能模(角色)';
comment on column QX_GNMB.GNMB_DM
  is '功能模板代码';
comment on column QX_GNMB.GNMB_MC
  is '功能模板名称';
comment on column QX_GNMB.SS_GW_DM
  is '所属岗位代码';
comment on column QX_GNMB.JSSX_DM
  is '角色属性';


insert into QX_GNMB (GNMB_DM, GNMB_MC, SS_GW_DM, JSSX_DM, JG_DM, SFGXJS)
  values ('00000000001', '超级管理员角色', null, '01', '000000000000000', 'N');

commit;


-- 创建表: 岗位角色（功能模板）
create table QX_GW_GNMB
(
  GW_DM   VARCHAR2(15) not null,
  GNMB_DM VARCHAR2(11) not null
)
;
comment on column QX_GW_GNMB.GW_DM
  is '岗位代码';
comment on column QX_GW_GNMB.GNMB_DM
  is '功能模板代码';
alter table QX_GW_GNMB
  add constraint PK_QX_GW_GNMB primary key (GW_DM, GNMB_DM);
alter table QX_GW_GNMB
  add constraint FK_QX_GW_GNMB_GNMB_DM foreign key (GNMB_DM)
  references QX_GNMB (GNMB_DM);
alter table QX_GW_GNMB
  add constraint FK_QX_GW_GNMB_GW_DM foreign key (GW_DM)
  references QX_GW (GW_DM);


insert into QX_GW_GNMB (GW_DM, GNMB_DM) values ('000000000000000', '00000000001');

commit;




-- 创建表:
create table QX_SYSTEM_GW
(
  SYSTEMNAME   VARCHAR2(50) not null,
  GW_DM        VARCHAR2(15) not null,
  GW_MC        VARCHAR2(100),
  SYSTEM_GW_DM VARCHAR2(15) not null,
  SYSTEM_GW_MC VARCHAR2(100)
)
;
alter table QX_SYSTEM_GW
  add constraint QX_SYSTEM_GW_PK primary key (SYSTEMNAME, GW_DM);






-- 创建表: 模块类型代码
create table DM_MKLX
(
  MKLX_DM VARCHAR2(2) not null,
  MKLX_MC VARCHAR2(20) not null,
  XYBZ    CHAR(1) default 'Y' not null,
  YXBZ    CHAR(1) default 'Y' not null
)
;
comment on column DM_MKLX.MKLX_DM
  is '模块类型代码';
comment on column DM_MKLX.MKLX_MC
  is '模块类型名称';
comment on column DM_MKLX.XYBZ
  is '选用标志';
comment on column DM_MKLX.YXBZ
  is '有效标志';
alter table DM_MKLX
  add constraint PK_DM_MKLX primary key (MKLX_DM);


insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('01', '专用系统URL', 'Y', 'Y');
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('02', 'MDI窗口', 'Y', 'Y');
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('03', 'SHEET窗口', 'Y', 'Y');
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('04', 'EXE文件', 'Y', 'Y');
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('05', '通用系统URL', 'Y', 'Y');
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('06', '脚本', 'Y', 'Y');
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('07', '工具项', 'Y', 'Y');
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('10', 'web资源', 'Y', 'Y');
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('11', '业务对象', 'Y', 'Y');

commit;




-- 创建表: 功能模块(资源)
create table QX_GNMK
(
  GNMK_DM    VARCHAR2(256) not null,
  GNMK_HZMC  VARCHAR2(80) default '功能模块' not null,
  GNMK_LJMC  VARCHAR2(4000) not null,
  MKLX_DM    VARCHAR(2) default '00' not null,
  YWHJ_DM    VARCHAR(6) not null,
  CYBJ       CHAR(1),
  GZL_BZ     CHAR(1),
  CFDK       CHAR(1) default 'Y' not null,
  DKWZ       CHAR(1) default '0' not null,
  SHOWLEFT   CHAR(1) default 'Y' not null,
  SHOWTOP    CHAR(1) default 'Y' not null,
  SHOWINTREE CHAR(1) default 'Y' not null,
  SYSTEMNAME VARCHAR2(80) default '系统管理' not null,
	YXBZ  CHAR(1) default 'Y' not null
)
;
comment on column QX_GNMK.GNMK_DM
  is '功能模块代码';
comment on column QX_GNMK.GNMK_HZMC
  is '功能模块汉字名称';
comment on column QX_GNMK.GNMK_LJMC
  is '功能模块路径名称';
comment on column QX_GNMK.MKLX_DM
  is '模块类型代码';
comment on column QX_GNMK.YWHJ_DM
  is '业务环节代码';
comment on column QX_GNMK.CYBJ
  is '常用标记';
alter table QX_GNMK
  add constraint PK_QX_GNMK primary key (GNMK_DM);
alter table QX_GNMK
  add constraint FK_QX_GNMK_SYSTEMNAME foreign key (SYSTEMNAME)
  references QX_SYSTEM (SYSTEMNAME);
alter table QX_GNMK
  add constraint FK_QX_GNMK_YWHJ_DM foreign key (YWHJ_DM)
  references DM_YWHJ (YWHJ_DM);


insert into QX_GNMK (GNMK_DM, GNMK_HZMC, GNMK_LJMC, MKLX_DM, YWHJ_DM, CYBJ, GZL_BZ, CFDK, DKWZ, SHOWLEFT, SHOWTOP, SHOWINTREE, SYSTEMNAME)
  values ('FFFFFFFFFFF', '文件夹', 'FFFFFF', '00', '000000', 'N', 'N', 'Y', '0', 'Y', 'Y', 'Y', '系统管理');

commit;


create table QX_GNMK_TREE
(
  JD_DM    VARCHAR2(21) not null,
  FJD_DM   VARCHAR2(21) not null,
  JD_MC    VARCHAR2(80) not null,
  GNMK_DM  VARCHAR2(256),
  JDLX_DM  VARCHAR2(2),
  JD_ORDER NUMBER(5) not null
)
;
comment on column QX_GNMK_TREE.JD_DM
  is '功能模块代码';
comment on column QX_GNMK_TREE.FJD_DM
  is '节点类型代码';
comment on column QX_GNMK_TREE.JD_MC
  is '节点名称';
comment on column QX_GNMK_TREE.GNMK_DM
  is '节点代码';
comment on column QX_GNMK_TREE.JDLX_DM
  is '父节点代码';
comment on column QX_GNMK_TREE.JD_ORDER
  is '节点顺序';
alter table QX_GNMK_TREE
  add constraint PK_QX_GNMK_TREE primary key (JD_DM);
alter table QX_GNMK_TREE
  add constraint FK_QX_GNMK_TREE_GNMK_DM foreign key (GNMK_DM)
  references QX_GNMK (GNMK_DM);


insert into QX_GNMK_TREE (JD_DM, FJD_DM, JD_MC, GNMK_DM, JDLX_DM, JD_ORDER) values ('0', '0', '资源树', 'FFFFFFFFFFF', '0', 0);

commit;


-- 创建表: 功能模块帮助
create table HLP_GNMK
(
  ID        CHAR(40) not null,
  CZRY_DATE DATE default sysdate not null,
  CZRY_MC   VARCHAR2(60),
  CZRY_DM   CHAR(11),
  KEYWORD   VARCHAR2(2000),
  REMARK    VARCHAR2(2000),
  GNMK_DM   VARCHAR2(256),
  GNMK_HZMC VARCHAR2(120),
  YWHJ_DM   CHAR(6),
  CONTENT   VARCHAR2(4000),
  PATH      VARCHAR2(256)
)
;
alter table HLP_GNMK
  ADD CONSTRAINT PK_HLP_GNMK primary key (ID);
comment on table HLP_GNMK
  is '帮助-功能模块操作手册';
comment on column HLP_GNMK.CZRY_MC
  is '操作人员名称';
comment on column HLP_GNMK.CZRY_DM
  is '操作人员代码';
comment on column HLP_GNMK.KEYWORD
  is '操作关键字';
comment on column HLP_GNMK.GNMK_DM
  is '功能模块代码';
comment on column HLP_GNMK.GNMK_HZMC
  is '功能模块名称';
comment on column HLP_GNMK.YWHJ_DM
  is '业务环节代码';
comment on column HLP_GNMK.REMARK
  is '备注';
comment on column HLP_GNMK.CONTENT
  is '操作手册内容';
comment on column HLP_GNMK.PATH
  is '操作手册文件路径';


-- 创建表: 功能模块收藏
create table QX_FAV_GNMK
(
  USERID  VARCHAR2(11) not null,
  GNMK_DM VARCHAR2(256) not null,
  GW_DM   VARCHAR2(15) not null,
  JD_MC   VARCHAR2(80) not null
)
;
alter table QX_FAV_GNMK
  add constraint PK_QX_FAV_GNMK primary key (USERID, GW_DM, GNMK_DM);
create index IDX_QX_FAV_GNMK_USERID_ID on QX_FAV_GNMK (USERID);


-- 创建表:
create table QX_JG_GNMK
(
  JG_DM   VARCHAR2(15) not null,
  GNMK_DM VARCHAR2(256) not null,
  SDATE   DATE not null,
  EDATE   DATE not null
)
;
alter table QX_JG_GNMK
  add constraint PK_QX_JG_GNMK primary key (JG_DM, GNMK_DM);
create index IDX_QX_JG_GNMK_GW_DM on QX_JG_GNMK (JG_DM);


create or replace view V_QX_GNMK_TREE as
select JD_DM, FJD_DM, JD_MC, JDLX_DM, JD_ORDER, QX_GNMK.GNMK_DM, GNMK_HZMC, GNMK_LJMC, MKLX_DM, YWHJ_DM, CYBJ, GZL_BZ, CFDK, DKWZ, SHOWLEFT, SHOWTOP, SHOWINTREE, SYSTEMNAME, YXBZ
   from QX_GNMK_TREE inner join QX_GNMK on QX_GNMK_TREE.GNMK_DM=QX_GNMK.GNMK_DM;



-- 创建表: 功能模板的功能模块(角色的资源)
create table QX_GNMB_GNMK
(
  GNMB_DM  VARCHAR2(11) not null,
  GNMK_DM  VARCHAR2(256) not null,
  JD_DM    VARCHAR2(21) not null,
  FJD_DM   VARCHAR2(21) not null,
  JD_MC    VARCHAR2(80) not null,
  JD_ORDER NUMBER(5) default 0 not null
)
;
comment on column QX_GNMB_GNMK.GNMB_DM
  is '功能模板代码';
comment on column QX_GNMB_GNMK.GNMK_DM
  is '功能模块代码';
comment on column QX_GNMB_GNMK.JD_DM
  is '节点名称';
comment on column QX_GNMB_GNMK.FJD_DM
  is '节点代码';
comment on column QX_GNMB_GNMK.JD_MC
  is '父节点代码';
alter table QX_GNMB_GNMK
  add constraint PK_QX_GNMB_GNMK primary key (GNMB_DM, GNMK_DM, JD_DM, FJD_DM);
alter table QX_GNMB_GNMK
  add constraint FK_QX_GNMB_GNMK_GNMB_DM foreign key (GNMB_DM)
  references QX_GNMB (GNMB_DM);
alter table QX_GNMB_GNMK
  add constraint FK_QX_GNMB_GNMK_GNMK_DM foreign key (GNMK_DM)
  references QX_GNMK (GNMK_DM);


PROMPT 正在创建表     ---QX_GNMB_GNMK_OPERATION
create table QX_GNMB_GNMK_OPERATION
(
    GNMB_DM                         varchar2(11)                 not null       ,
    GNMK_DM                         varchar2(256)            not null       ,
    OPERATION_DM                    varchar2(256)            not null       ,
    OPERATIONAUTH_ID                varchar2(21),
    constraint PK_QX_GNMB_GNMK_OPERATION primary key (GNMB_DM,GNMK_DM,OPERATION_DM),
    constraint FK_QX_GNMB_GNMK_O_GNMB_DM foreign key (GNMB_DM) references QX_GNMB (GNMB_DM) ON DELETE CASCADE,
    constraint FK_QX_GNMB_GNMK_O_GNMK_DM foreign key (GNMK_DM) references QX_GNMK (GNMK_DM) ON DELETE CASCADE
)
/


PROMPT 正在创建表注释 ---QX_GNMB_GNMK_OPERATION
comment on table QX_GNMB_GNMK_OPERATION is '权限功能模板功能模块操作';
comment on column QX_GNMB_GNMK_OPERATION.GNMB_DM is '功能模板代码';
comment on column QX_GNMB_GNMK_OPERATION.GNMK_DM is '功能模块代码';
comment on column QX_GNMB_GNMK_OPERATION.OPERATION_DM is '操作代码';

create table QX_GNMB_SX_JG
(
  GNMB_DM  VARCHAR2(11) not null,
  JG_DM    VARCHAR2(15) not null,
  QX_JG_DM VARCHAR2(15) not null,
  GW_DM    VARCHAR2(15) not null
)
;
comment on table QX_GNMB_SX_JG
  is '权限－功能模板(角色)的机关属性设置(用于根据角色批量生成岗位)';
comment on column QX_GNMB_SX_JG.GNMB_DM
  is '功能模板代码';
comment on column QX_GNMB_SX_JG.JG_DM
  is '机关代码';
comment on column QX_GNMB_SX_JG.QX_JG_DM
  is '权限机关代码';
comment on column QX_GNMB_SX_JG.GW_DM
  is '岗位代码';
alter table QX_GNMB_SX_JG
  add constraint PK_QX_GNMB_SX_JG primary key (GNMB_DM, JG_DM);
alter table QX_GNMB_SX_JG
  add constraint FK_QX_GNMB_SX_JG_GNMB_DM foreign key (GNMB_DM)
  references QX_GNMB (GNMB_DM);





PROMPT 正在创建表     ---WSQCZCLFS
create table WSQCZCLFS
(
    WSQCZCLFS_DM                         varchar2(16)        default '00' not null,
    WSQCZCLFS_MC                         varchar2(256)       default '未授权操作方式' not null,
    YXBZ                                 CHAR(1)             default 'Y' not null,
    XYBZ                                 CHAR(1)             default 'Y' not null,
    constraint PK_WSQCZCLFS primary key (WSQCZCLFS_DM)
)
/

PROMPT 正在创建表注释 ---WSQCZCLFS
comment on table WSQCZCLFS is '未授权操作处理方式';
comment on column WSQCZCLFS.WSQCZCLFS_DM is '未授权操作处理方式代码';
comment on column WSQCZCLFS.WSQCZCLFS_MC is '未授权操作处理方式名称';
comment on column WSQCZCLFS.YXBZ is '有效标志';
comment on column WSQCZCLFS.XYBZ is '选用标志';



PROMPT 正在创建表     ---QX_OPERATION
create table QX_OPERATION
(
    OPERATION_DM                         varchar2(256)            not null       ,
    OPERATION_MC                         varchar2(120)            default '操作' not null       ,
    GNMK_DM                              varchar2(256)            not null       ,
    OPERATION_DESCRIPTION                varchar2(256)               ,
    YXBZ                                 char(1)                  default 'Y' not null,
    WSQCZCLFS_DM                         varchar2(16)             default '00' not null,
    constraint PK_QX_OPERATION primary key (OPERATION_DM,GNMK_DM),
    constraint FK_QX_OPERATION_GNMK_DM foreign key (GNMK_DM) references QX_GNMK (GNMK_DM) ON DELETE CASCADE
)
/

PROMPT 正在创建表注释 ---QX_OPERATION
comment on table QX_OPERATION is '操作';
comment on column QX_OPERATION.OPERATION_DM is '操作代码';
comment on column QX_OPERATION.OPERATION_MC is '操作名称';
comment on column QX_OPERATION.GNMK_DM is '功能模块代码';
comment on column QX_OPERATION.OPERATION_DESCRIPTION is '操作描述';
comment on column QX_OPERATION.YXBZ is '有效标志';
comment on column QX_OPERATION.WSQCZCLFS_DM is '未授权操作处理方式代码';


create or replace function P_GET_JDH(ac_jdh out varchar2)
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--                              存储过程说明
--过 程 名：P_GET_JDH
--功能描述：取节点号
--输入参数：无
--输出参数：节点号
--返 回 值：100成功 其他值 系统错误
--调用来自：
--编写时间：
--修改序号：
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
return number is
begin
    select CSNR into ac_jdh from XT_XTCS where CSXH = '10001' and JG_DM='PUBLIC';
    if ac_jdh is null then
       Raise_application_error(-20000, '没有初始化“节点号”[CSXH = ''10001'']系统参数！');
    end if;

    return 100;
end;
/
CREATE OR REPLACE FUNCTION P_GET_JD_DM(
    AC_FULL VARCHAR2, --全路径名称 各级间用~隔开
    AC_FLAG VARCHAR2  --'0'表示查找QX_GNMK_TREE;'1'表示查找QX_GNMB_GNMK(只限于超级用户)
)RETURN VARCHAR2 IS
    LC_FULL     VARCHAR2(1000);--全路径名称
    LN_POS      NUMBER(10);    --~位置
    LC_JD_MC    VARCHAR2(1000);--节点名称
    LC_FJD_DM   VARCHAR2(30);  --父节点代码
BEGIN
    LC_FULL :=AC_FULL;
    LC_FJD_DM:='0';--从根节点0开始
    LOOP
        LN_POS:=INSTR(LC_FULL,'~');
        IF LN_POS=0 THEN
            LC_JD_MC:=LC_FULL;
        ELSE --如果有~，就拆分名称
            LC_JD_MC:=SUBSTR(LC_FULL,1,LN_POS-1);
            LC_FULL:=SUBSTR(LC_FULL,LN_POS+1);
        END IF;
        BEGIN
            --dbms_output.put_line(lc_jd_mc||' '||lc_fjd_dm);
            IF AC_FLAG='0' THEN
              SELECT JD_DM INTO LC_FJD_DM FROM QX_GNMK_TREE WHERE FJD_DM=LC_FJD_DM AND JD_MC=LC_JD_MC;
            ELSE
              SELECT JD_DM INTO LC_FJD_DM FROM QX_GNMB_GNMK WHERE FJD_DM=LC_FJD_DM AND JD_MC=LC_JD_MC AND GNMB_DM='00000000001';
          END IF;
        EXCEPTION
            WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20000,'查找路径名称错误：'||LC_JD_MC||' ? '||SQLERRM);
        END;
        IF LN_POS=0 THEN
            RETURN LC_FJD_DM;--返回节点代码
        END IF;
    END LOOP;
END;
/
CREATE OR REPLACE FUNCTION P_GET_JD_NEW(
    AC_FJD_DM VARCHAR2, --父节点代码
    AC_JD_MC  VARCHAR2,  --节点名称
    AC_FLAG VARCHAR2  --'0'表示查找QX_GNMK_TREE;'1'表示查找QX_GNMB_GNMK(只限于超级用户)
)RETURN VARCHAR2 IS
    LN_ROW    VARCHAR2(30);  --节点代码
    LN_COUNT  NUMBER(10); -- 行数，临时变量
BEGIN
  IF AC_FLAG = '0' THEN
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE JD_DM=AC_FJD_DM AND (JDLX_DM='01' or jdlx_dm='0'); --add by liuming
    IF LN_ROW<>1 THEN
        RAISE_APPLICATION_ERROR(-20000,'父节点代码：'||AC_FJD_DM||' 不是目录，无法向下扩展');
    END IF;

    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=AC_FJD_DM AND JD_MC=AC_JD_MC;
    IF LN_ROW>0 THEN
        RAISE_APPLICATION_ERROR(-20000,'节点名称重复：'||AC_JD_MC);
    END IF;

    IF LENGTH(AC_FJD_DM)>18 THEN
      SELECT MAX(JD_DM)+1 INTO LN_ROW FROM QX_GNMK_TREE WHERE JD_DM>='0' AND JD_DM<='9';
      RETURN LN_ROW;
    ELSE
      --通过父节点代码向下扩展三位，生成新节点代码
      SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=AC_FJD_DM;
      IF LN_ROW IS NULL THEN
          LN_ROW:=1;
      ELSIF LN_ROW>=999 THEN
          RAISE_APPLICATION_ERROR(-20000,'下属节点超过999，无法扩展！');
      ELSE
          LN_ROW:=LN_ROW+1;
      END IF;

      -- 避免与现有代码重复
      SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMK_TREE WHERE JD_DM=AC_FJD_DM||LPAD(LN_ROW,3,'0');
      WHILE LN_COUNT > 0 LOOP
          LN_ROW:=LN_ROW+1;
          SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMK_TREE WHERE JD_DM=AC_FJD_DM||LPAD(LN_ROW,3,'0');
      END LOOP;

      RETURN AC_FJD_DM||LPAD(LN_ROW,3,'0');
    END IF;

  ELSE
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMB_GNMK WHERE JD_DM=AC_FJD_DM AND GNMK_DM='FFFFFFFFFFF' AND GNMB_DM='00000000001';
    IF LN_ROW<>1 THEN
        RAISE_APPLICATION_ERROR(-20000,'父节点代码：'||AC_FJD_DM||' 不是目录，无法向下扩展');
    END IF;

    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=AC_FJD_DM AND JD_MC=AC_JD_MC AND GNMB_DM='00000000001';
    IF LN_ROW>0 THEN
        RAISE_APPLICATION_ERROR(-20000,'节点名称重复：'||AC_JD_MC);
    END IF;

    IF LENGTH(AC_FJD_DM)>18 THEN
      SELECT MAX(JD_DM)+1 INTO LN_ROW FROM QX_GNMB_GNMK WHERE GNMB_DM='00000000001' AND JD_DM>='0' AND JD_DM<='9';
      RETURN LN_ROW;
    ELSE
      --通过父节点代码向下扩展三位，生成新节点代码
      SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=AC_FJD_DM AND GNMB_DM='00000000001';
      IF LN_ROW IS NULL THEN
          LN_ROW:=1;
      ELSIF LN_ROW>=999 THEN
          RAISE_APPLICATION_ERROR(-20000,'下属节点超过999，无法扩展！');
      ELSE
          LN_ROW:=LN_ROW+1;
      END IF;

      -- 避免与现有代码重复
      SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMB_GNMK WHERE JD_DM=AC_FJD_DM||LPAD(LN_ROW,3,'0');
      WHILE LN_COUNT > 0 LOOP
          LN_ROW:=LN_ROW+1;
          SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMB_GNMK WHERE JD_DM=AC_FJD_DM||LPAD(LN_ROW,3,'0');
      END LOOP;

      RETURN AC_FJD_DM||LPAD(LN_ROW,3,'0');
    END IF;
  END IF;
END;
/
CREATE OR REPLACE FUNCTION P_SEQUENCE_STANDARD(sequenceNo out varchar2, sequenceName in varchar2)

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--                              存储过程说明
--过 程 名：P_SEQUENCE_STANDARD
--功能描述：标准序列计算函数
--输入参数：序列名称
--输出参数：序列值
--返 回 值：100成功 其他值 系统错误
--调用来自：序列发生器
--编写时间：2007年07月30日
--修改序号：
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
return  number is
    jdno    varchar2(4); -- 节点号
    ln_return  number(10); -- 返回值
begin
    execute immediate 'select to_char(' || sequenceName || '.nextval) from dual' into sequenceNo;
    ln_return := P_GET_JDH(jdno);
    if ln_return = 100 then
      sequenceno := lpad(sequenceno,8,'0');
      sequenceNo := jdno||to_char(sysdate,'yy')||'9'||sequenceno||'000';
  end if;

  return ln_return;
end;
/


CREATE OR REPLACE PROCEDURE P_ADD_GNMK(
    AC_FULL    VARCHAR2,--全路径名称
    AC_GNMK    CHAR,--模块代码
    AC_HZMC    VARCHAR2,--汉字名称
    AC_LJMC    VARCHAR2,--路径名称
    AC_YWHJ    CHAR,--业务环节代码
    AC_MKLX_DM    VARCHAR2 default '05', --模块类型代码
    AC_SYSTEMNAME    VARCHAR2 default '系统管理' --业务系统名称
)IS
    LC_FJD_DM  VARCHAR2(30);
    LC_JD_DM   VARCHAR2(30);
    LN_ROW     NUMBER(10);
BEGIN
    IF AC_GNMK='FFFFFFFFFFF' THEN--增加目录
        RAISE_APPLICATION_ERROR(-20000,'增加目录请调用P_ADD_ML');
    END IF;

    --开始插入数据
    BEGIN
        insert into QX_GNMK (GNMK_DM, GNMK_HZMC, GNMK_LJMC, MKLX_DM, YWHJ_DM, SYSTEMNAME, CYBJ)
        values (AC_GNMK, AC_HZMC, AC_LJMC, AC_MKLX_DM, AC_YWHJ, AC_SYSTEMNAME, 'N');--常用标记为N
    EXCEPTION
        WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20000,'GNMK_DM='||AC_GNMK||' ? '||SQLERRM);
    END;

    IF AC_FULL IS NOT NULL THEN--AC_FULL为空，表示不在树上显示
        --通过目录名称查找父节点代码
        LC_FJD_DM:=P_GET_JD_DM(AC_FULL,'0');
        --获取新节点代码
        LC_JD_DM:=P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'0');
 --       LN_ROW:=SUBSTR(LC_JD_DM,LENGTH(LC_JD_DM)-2,3);
        SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_FJD_DM;
        IF LN_ROW IS NULL THEN
            LN_ROW:=1;
        ELSIF LN_ROW>=999 THEN
            RAISE_APPLICATION_ERROR(-20000,'下属节点超过999，无法扩展！');
        ELSE
            LN_ROW:=LN_ROW+1;
        END IF;
        insert into QX_GNMK_TREE(JD_DM,FJD_DM,JD_MC,GNMK_DM,JDLX_DM,JD_ORDER)
        VALUES (LC_JD_DM,LC_FJD_DM,AC_HZMC, AC_GNMK,'02',LN_ROW);

        --通过目录名称查找父节点代码
        LC_FJD_DM:=P_GET_JD_DM(AC_FULL,'1');
        --获取新节点代码
        LC_JD_DM:=P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'1');
        SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=LC_FJD_DM AND GNMB_DM='00000000001';
        IF LN_ROW IS NULL THEN
            LN_ROW:=1;
        ELSIF LN_ROW>=999 THEN
            RAISE_APPLICATION_ERROR(-20000,'下属节点超过999，无法扩展！');
        ELSE
            LN_ROW:=LN_ROW+1;
        END IF;
--        LN_ROW:=SUBSTR(LC_JD_DM,LENGTH(LC_JD_DM)-2,3);
        INSERT INTO QX_GNMB_GNMK(GNMB_DM,JD_DM,FJD_DM,JD_MC,GNMK_DM,JD_ORDER)
        VALUES ('00000000001',LC_JD_DM,LC_FJD_DM,AC_HZMC,AC_GNMK,LN_ROW);
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE P_ADD_ML(
    AC_FULL    VARCHAR2,--全路径名称 各级间用~隔开
    AC_HZMC    VARCHAR2 --目录名称
)IS
    LC_FJD_DM  VARCHAR2(21);
    LC_JD_DM   VARCHAR2(21);
    LN_ROW     NUMBER(10);
BEGIN
    --通过目录名称查找父节点代码
    LC_FJD_DM:=P_GET_JD_DM(AC_FULL,'0');
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_FJD_DM AND JD_MC=AC_HZMC;
    IF LN_ROW=0 THEN
       BEGIN
          --获取新节点代码
          LC_JD_DM:=P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'0');
          --    LN_ROW:=SUBSTR(LC_JD_DM,LENGTH(LC_JD_DM)-2,3);
          SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_FJD_DM;
          IF LN_ROW IS NULL THEN
              LN_ROW:=1;
          ELSIF LN_ROW>=999 THEN
              RAISE_APPLICATION_ERROR(-20000,'下属节点超过999，无法扩展！');
          ELSE
              LN_ROW:=LN_ROW+1;
          END IF;
          insert into QX_GNMK_TREE(JD_DM,FJD_DM,JD_MC,GNMK_DM,JDLX_DM,JD_ORDER)
          VALUES (LC_JD_DM,LC_FJD_DM,AC_HZMC, 'FFFFFFFFFFF','01',LN_ROW);
       END;
    END IF;



    --通过目录名称查找父节点代码
    LC_FJD_DM:=P_GET_JD_DM(AC_FULL,'1');
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=LC_FJD_DM AND JD_MC=AC_HZMC AND GNMB_DM='00000000001';
    IF LN_ROW=0 THEN
       BEGIN
          --获取新节点代码
          LC_JD_DM:=P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'1');
          --    LN_ROW:=SUBSTR(LC_JD_DM,LENGTH(LC_JD_DM)-2,3);
          SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=LC_FJD_DM AND GNMB_DM='00000000001';
          IF LN_ROW IS NULL THEN
              LN_ROW:=1;
          ELSIF LN_ROW>=999 THEN
              RAISE_APPLICATION_ERROR(-20000,'下属节点超过999，无法扩展！');
          ELSE
              LN_ROW:=LN_ROW+1;
          END IF;
          INSERT INTO QX_GNMB_GNMK(GNMB_DM,JD_DM,FJD_DM,JD_MC,GNMK_DM,JD_ORDER)
          VALUES ('00000000001',LC_JD_DM,LC_FJD_DM,AC_HZMC,'FFFFFFFFFFF',LN_ROW);
        END;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE P_DEL_GNMK(AC_GNMK VARCHAR2)
IS
BEGIN
    DELETE QX_GNMB_GNMK WHERE GNMK_DM = AC_GNMK;
    DELETE QX_GNMK_TREE WHERE GNMK_DM = AC_GNMK;
    DELETE QX_GNMK WHERE GNMK_DM = AC_GNMK;
END;
/

CREATE OR REPLACE PROCEDURE P_DEL_ML(
    AC_FULL    VARCHAR2,--全路径名称 各级间用~隔开 如：征收监控~申报征收~增值税申报
    AC_HZMC    VARCHAR2 --目录名称
)IS
    LC_JD_DM   VARCHAR2(21);
    LN_ROW     NUMBER(10);
BEGIN
    --通过目录名称查找节点代码
    LC_JD_DM:=P_GET_JD_DM(AC_FULL||'~'||AC_HZMC,'0');
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_JD_DM;
    IF LN_ROW>0 THEN
        RAISE_APPLICATION_ERROR(-20000,'功能模块树存在下属节点，无法删除！');
    END IF;
    DELETE QX_GNMK_TREE WHERE JD_DM=LC_JD_DM;

    --同步超级用户树(地税)
    LC_JD_DM:=P_GET_JD_DM(AC_FULL||'~'||AC_HZMC,'1');
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_JD_DM;
    IF LN_ROW>0 THEN
        RAISE_APPLICATION_ERROR(-20000,'功能模块树存在下属节点，无法删除！');
    END IF;
    DELETE QX_GNMB_GNMK WHERE GNMB_DM='00000000001' AND JD_DM=LC_JD_DM;
END;
/

CREATE OR REPLACE PROCEDURE P_ADD_ROOT(
    AC_JD_DM    VARCHAR2,
    AC_JD_MC    VARCHAR2,
    AC_JD_ORDER NUMBER default null
)IS
    LN_COUNT NUMBER(10);
    LN_JD_ORDER NUMBER(10);
BEGIN
     IF AC_JD_ORDER is null THEN
        BEGIN
             SELECT MAX(JD_ORDER) INTO LN_JD_ORDER FROM QX_GNMK_TREE WHERE FJD_DM='0';
             IF LN_JD_ORDER IS NULL THEN
                LN_JD_ORDER:=1;
             ELSIF LN_JD_ORDER>=999 THEN
                RAISE_APPLICATION_ERROR(-20000,'根节点超过999，无法扩展！');
             ELSE
                 LN_JD_ORDER:=LN_JD_ORDER+1;
             END IF;
        END;
     ELSE
        LN_JD_ORDER:=AC_JD_ORDER;
     END IF;

     SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMK_TREE WHERE JD_DM=AC_JD_DM;
     IF LN_COUNT =0 THEN
         insert into QX_GNMK_TREE(JD_DM,FJD_DM,JD_MC,GNMK_DM,JDLX_DM,JD_ORDER)
         values (AC_JD_DM, '0',AC_JD_MC,'FFFFFFFFFFF', '01', LN_JD_ORDER);
     END IF;

     SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMB_GNMK WHERE JD_DM=AC_JD_DM AND GNMB_DM='00000000001';
     IF LN_COUNT =0 THEN
         INSERT INTO QX_GNMB_GNMK(GNMB_DM,GNMK_DM,JD_DM,FJD_DM,JD_MC,JD_ORDER)
         values ('00000000001','FFFFFFFFFFF',AC_JD_DM,'0', AC_JD_MC, LN_JD_ORDER);
     END IF;

END;
/

CREATE OR REPLACE PROCEDURE P_DEL_ROOT(
    AC_JD_DM    VARCHAR2
)IS
    LN_COUNT NUMBER(10);
BEGIN
     SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMK_TREE WHERE FJD_DM=AC_JD_DM;
     IF LN_COUNT >0 THEN
        RAISE_APPLICATION_ERROR(-20000,'QX_GNMK_TREE根节点存在下属节点，无法删除！');
     ELSE
        DELETE FROM QX_GNMK_TREE WHERE JD_DM=AC_JD_DM;
     END IF;

     SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMB_GNMK WHERE FJD_DM=AC_JD_DM;
     IF LN_COUNT >0 THEN
        RAISE_APPLICATION_ERROR(-20000,'QX_GNMB_GNMK根节点存在下属节点，无法删除！');
     ELSE
        DELETE FROM QX_GNMB_GNMK WHERE JD_DM=AC_JD_DM AND GNMB_DM='00000000001';
     END IF;

END;
/


begin
	P_ADD_ROOT('systemmanage','系统管理', 90);
	P_ADD_ML('系统管理','组织权限');
	P_ADD_GNMK('系统管理~组织权限','systemmanage.security.org','机构初始化','../security/org/zzjg.do?method=tree','090000');
	P_ADD_GNMK('系统管理~组织权限','systemmanage.security.operator','操作人员初始化','../security/operator/index.jsp','090000');
	P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.reg','资源注册','../security/model/zyzc.do?method=queryList','000000');
	P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.limitation','资源时效性','../work/portal/gnmksxx/GnmksxxBndService.getGnmksxxs.do','090000');
	P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.operation','操作注册','../security/operation/operation.do','090000');
	P_ADD_GNMK('系统管理~组织权限','systemmanage.security.role','角色设置','../security/role/jssz.do?method=init','090000');
	P_ADD_GNMK('系统管理~组织权限','systemmanage.security.position','岗位设置','../security/position/gwsz.do?method=gwszPageInit','090000');
	P_ADD_GNMK('系统管理~组织权限','systemmanage.security.user','用户设置','../security/user/user.do','090000');
end;
/
commit;








-- 创建表: 单位隶属关系
create table DM_DWLSGX
(
  DWLSGX_DM VARCHAR2(2) not null,
  DWLSGX_MC VARCHAR2(16) not null,
  DWLSGX_SM VARCHAR2(256),
  XYBZ      CHAR(1) default 'Y' not null,
  YXBZ      CHAR(1) default 'Y' not null
)
;
comment on table DM_DWLSGX
  is '单位隶属关系代码';
comment on column DM_DWLSGX.DWLSGX_DM
  is '单位隶属关系代码';
comment on column DM_DWLSGX.DWLSGX_MC
  is '单位隶属关系名称';
comment on column DM_DWLSGX.DWLSGX_SM
  is '单位隶属关系说明';
comment on column DM_DWLSGX.XYBZ
  is '选用标志';
comment on column DM_DWLSGX.YXBZ
  is '有效标志';

CREATE OR REPLACE VIEW V_DM_DWLSGX AS
	SELECT "DWLSGX_DM","DWLSGX_MC","XYBZ","YXBZ"
	FROM DM_DWLSGX
	WHERE YXBZ='Y' AND XYBZ = 'Y'
/

insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('10', '中央            ', '包括全国人大常委会、中共中央、国务院各部委及其所属机构，国务院各直属机构、办事机构及其所属机构', 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('20', '省              ', '包括自治区、直辖市', 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('40', '市、地区        ', '包括自治州、盟、省辖市、直辖市辖区（县）', 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('50', '县              ', '包括地(州、盟)辖市、省辖市辖区、自治县（旗）、旗、县级市', 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('60', '街道、镇、乡    ', null, 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('61', '街道            ', null, 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('62', '镇              ', null, 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('63', '乡              ', null, 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('70', '居民、村民委员会', null, 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('71', '居民委员会      ', null, 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('72', '村民委员会      ', null, 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('80', '组              ', null, 'Y', 'Y');
insert into DM_DWLSGX (DWLSGX_DM, DWLSGX_MC, DWLSGX_SM, XYBZ, YXBZ)
values ('90', '其他            ', null, 'Y', 'Y');
commit;


-- 创建表: 机构
create table DM_JG
(
  JG_DM     VARCHAR2(15) not null,
  JG_MC     VARCHAR2(80) not null,
  JG_JC     VARCHAR2(50) not null,
  JG_BZ     CHAR(1) not null,
  SJ_JG_DM  VARCHAR2(15) not null,
  DWLSGX_DM VARCHAR2(2) not null,
  JG_JG     VARCHAR2(10),
  JGYB      VARCHAR2(6),
  JGDZ      VARCHAR2(80),
  JGDH      VARCHAR2(30),
  CZDH      VARCHAR2(30),
  DYDZ      VARCHAR2(50),
  XZQH_DM   VARCHAR2(15),
  JGFZR_DM  VARCHAR2(11),
  JBDM      VARCHAR2(30) not null,
  JCDM      CHAR(1) not null,
  XYBZ      CHAR(1) default 'Y' not null,
  YXBZ      CHAR(1) default 'Y' not null
)
;
comment on table DM_JG
  is '机构';
comment on column DM_JG.JG_DM
  is '机构代码';
comment on column DM_JG.JG_MC
  is '机构名称';
comment on column DM_JG.JG_JC
  is '机构简称';
comment on column DM_JG.JG_BZ
  is '机构标志';
comment on column DM_JG.SJ_JG_DM
  is '上级机构代码';
comment on column DM_JG.DWLSGX_DM
  is '机构级次代码';
comment on column DM_JG.JG_JG
  is '机构局轨';
comment on column DM_JG.JGYB
  is '机构邮编';
comment on column DM_JG.JGDZ
  is '机构地址';
comment on column DM_JG.JGDH
  is '机构电话';
comment on column DM_JG.CZDH
  is '传真电话';
comment on column DM_JG.DYDZ
  is '电邮地址';
comment on column DM_JG.XZQH_DM
  is '行政区划代码';
comment on column DM_JG.JGFZR_DM
  is '负责人';
comment on column DM_JG.JBDM
  is '级别代码';
comment on column DM_JG.JCDM
  is '级次代码';
comment on column DM_JG.XYBZ
  is '选用标志';
comment on column DM_JG.YXBZ
  is '有效标志';
alter table DM_JG
  add constraint PK_DM_JG primary key (JG_DM);
alter table DM_JG
  add constraint CHK_DM_JG_1
  check ("JG_BZ"='J' OR "JG_BZ"='B' OR "JG_BZ"='Q');
create unique index IDX_DM_JG_JBDM on DM_JG (JBDM);


insert into DM_JG (JG_DM, JG_MC, JG_JC, JG_BZ, SJ_JG_DM, DWLSGX_DM, JG_JG, JGYB, JGDZ, JGDH, CZDH, DYDZ, XZQH_DM, JGFZR_DM, JBDM, JCDM, XYBZ, YXBZ)
values ('000000000000000', '国家管理中心', '国家管理中心', 'J', '999999999999999', '10', null, '100000', '北京市', '010-63417114', '34', null, '000000000000000', '00000000000', '0000', '0', 'Y', 'Y');

COMMIT;


create or replace view v_dm_jg as
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
	and XYBZ = 'Y'
	order by JG_DM
/

CREATE OR REPLACE VIEW V_DM_BM AS
	SELECT "JG_DM",
	"JG_MC",
	"JG_JC","JG_BZ","SJ_JG_DM","DWLSGX_DM","JG_JG","JGYB","JGDZ","JGDH","CZDH","DYDZ","XZQH_DM","JGFZR_DM","JBDM","JCDM","XYBZ","YXBZ"
	  FROM DM_JG
	 WHERE YXBZ='Y'
	   AND XYBZ = 'Y'
	   AND JG_BZ='B'
/


create table QX_JG_QXJG
(
  JG_DM    VARCHAR2(15) not null,
  QX_JG_DM VARCHAR2(15) not null
)
;
alter table QX_JG_QXJG
  add constraint PK_QX_JG_QXJG primary key (JG_DM);






-- 创建表: 操作人员
create table DM_CZRY
(
  CZRY_DM VARCHAR2(11) not null,
  JG_DM   VARCHAR2(15) not null,
  CZRY_MC VARCHAR2(30) not null,
  XYBZ    CHAR(1) default 'Y' not null,
  YXBZ    CHAR(1) default 'Y' not null,
  ZJHM    VARCHAR2(18),
  ADDRESS VARCHAR2(80),
  DHHM    VARCHAR2(30),
  SJHM    VARCHAR2(30),
  EMAIL   VARCHAR2(50)
)
;
comment on table DM_CZRY
  is '操作人员代码';
comment on column DM_CZRY.CZRY_DM
  is '操作人员代码';
comment on column DM_CZRY.JG_DM
  is '机构代码';
comment on column DM_CZRY.CZRY_MC
  is '操作人员名称';
comment on column DM_CZRY.XYBZ
  is '选用标志';
comment on column DM_CZRY.YXBZ
  is '有效标志';
alter table DM_CZRY
  add constraint PK_DM_CZRY primary key (CZRY_DM);
alter table DM_CZRY
  add constraint FK_DM_CZRY_JG_DM foreign key (JG_DM)
  references DM_JG (JG_DM);
create index IDX_DM_CZRY_JG_DM on DM_CZRY (JG_DM);



insert into DM_CZRY (CZRY_DM, JG_DM, CZRY_MC, XYBZ, YXBZ, ZJHM, ADDRESS, DHHM, SJHM, EMAIL)
  values ('00000000000', '000000000000000', '超级管理员', 'Y', 'Y', null, null, null, null, null);

commit;


-- 创建表: 用户
create table QX_USER
(
  USERID    VARCHAR2(11) not null,
  NAME      VARCHAR2(30) not null,
  CZRY_DM   VARCHAR2(11) not null,
  PASSWORD  VARCHAR2(40) not null,
  KLLX      VARCHAR2(2) not null,
  PWRQQ     DATE,
  PWRQZ     DATE,
  GRANTROLE CHAR(1)
)
;
alter table QX_USER
  add constraint PK_QX_USER primary key (USERID);
alter table QX_USER
  add constraint FK_QX_USER_RY_DM foreign key (CZRY_DM)
  references DM_CZRY (CZRY_DM);
create unique index IDX_QX_USER_NAME on QX_USER (NAME);
create index IDX_QX_USER_RY_DM on QX_USER (CZRY_DM);

comment on table QX_USER
  is '用户';
comment on column QX_USER.USERID
  is '用户ID';
comment on column QX_USER.NAME
  is '用户名';
comment on column QX_USER.CZRY_DM
  is '人员代码';
comment on column QX_USER.PASSWORD
  is '口令';
comment on column QX_USER.KLLX
  is '口令类型';
comment on column QX_USER.PWRQQ
  is '口令起始日期';
comment on column QX_USER.PWRQZ
  is '口令终止日期';
comment on column QX_USER.GRANTROLE
  is '角色授权标记';


insert into QX_USER (USERID, NAME, CZRY_DM, PASSWORD, KLLX, PWRQQ, PWRQZ, GRANTROLE)
  values ('00000000000', 'admin', '00000000000', 'M0hn9rFM+RSrf8iOFvT9+5U1AcXah/ecrLo/Mg==', '1 ', to_date('05-08-2007', 'dd-mm-yyyy'), to_date('31-08-2007', 'dd-mm-yyyy'), '0');

commit;


-- 创建表: 用户的岗位
create table QX_USER_GW
(
  USERID VARCHAR2(11) not null,
  GW_DM  VARCHAR2(15) not null
)
;
comment on column QX_USER_GW.USERID
  is '用户ID';
comment on column QX_USER_GW.GW_DM
  is '岗位代码';
alter table QX_USER_GW
  add constraint PK_QX_USER_GW primary key (USERID, GW_DM);
alter table QX_USER_GW
  add constraint FK_QX_USER_GW_GW_DM foreign key (GW_DM)
  references QX_GW (GW_DM);
alter table QX_USER_GW
  add constraint FK_QX_USER_GW_USERID foreign key (USERID)
  references QX_USER (USERID);

insert into QX_USER_GW (USERID, GW_DM)
  values ('00000000000', '000000000000000');

commit;



create or replace function ISYSZ(rydm in varchar2)
return varchar2
is
  rynum integer;
begin
  select count(*) into rynum from qx_user u where u.czry_dm = rydm;
  if (rynum > 0) then
    return '1';
  else
    return '0';
  end if;
end ISYSZ;
/

create or replace view v_dm_czry as
	select dm_czry.czry_dm,czry_mc,jg_dm,zjhm,address,dhhm,sjhm,email,isysz(dm_czry.czry_dm)as isysz,qx_user.userid as userid
	from dm_czry left join qx_user on dm_czry.czry_dm=qx_user.czry_dm
/




-- 创建表: 公共消息
create table MESSAGE_COMMON
(
  ID         VARCHAR2(40) not null,
  QX_JG_DM   VARCHAR2(15) not null,
  CZRY_MC    VARCHAR2(60),
  CZRY_DM    VARCHAR(11) not null,
  CZ_DATE    DATE default sysdate not null,
  ISSUE_FLAG CHAR(1) default '0' not null,
  PRIORITY   CHAR(1) default '0' not null,
  CONTENT    VARCHAR2(400)
)
;
alter table MESSAGE_COMMON
  add primary key (ID);
comment on table MESSAGE_COMMON
  is '公共消息';
comment on column MESSAGE_COMMON.ISSUE_FLAG
  is '发布标识：0草稿 1发布';
comment on column MESSAGE_COMMON.PRIORITY
  is '消息类型 0普通 3重要';


-- 创建表:
create table MESSAGE_COMMON_OTM
(
  ID       VARCHAR2(40) not null,
  QX_JG_DM VARCHAR2(15) not null
)
;
alter table MESSAGE_COMMON_OTM
  add constraint PK_MESSAGE_COMMON_OTM primary key (ID, QX_JG_DM);
alter table MESSAGE_COMMON_OTM
  add constraint FK_MESSAGE_COMMON_OTM foreign key (ID)
  references MESSAGE_COMMON (ID);


insert into MESSAGE_COMMON (ID, QX_JG_DM, CZRY_MC, CZRY_DM, CZ_DATE, ISSUE_FLAG, PRIORITY, CONTENT)
	values ('8a8118e2-15a11f28-0115-a122ce44-0001', '000000000000000', 'ds_admin', '00000000000', to_date('18-10-2007 09:47:12', 'dd-mm-yyyy hh24:mi:ss'), '1', '0', '欢迎使用ADP应用开发平台，请尽快完成系统初始化工作。');

insert into MESSAGE_COMMON_OTM (ID, QX_JG_DM)
	values ('8a8118e2-15a11f28-0115-a122ce44-0001', '000000000000000');

commit;




begin
	P_ADD_ROOT('systemmanage','系统管理', 90);
	P_ADD_ML('系统管理','系统初始化');
	P_ADD_GNMK('系统管理~系统初始化','message.common','公共消息维护','../work/message/common/index.jsp','090000');
end;
/
commit;





create table print_template
(
  templateId        VARCHAR2(32)     not null,
  templateName      VARCHAR2(100)    not null,
  templateVersion   number           not null,
  expiredDate       date             not null,
  templateContent   blob             not null
);
alter table print_template add constraint PK_component_print primary key (templateId);

comment on table print_template is
'打印模板'
;
comment on column print_template.templateId is
'模板ID'
;
comment on column print_template.templateName is
'模板名称'
;
comment on column print_template.templateVersion is
'版本号'
;
comment on column print_template.expiredDate is
'有效期'
;
comment on column print_template.templateContent is
'模板内容'
;


begin
		P_ADD_ROOT('systemmanage','系统管理', 90);
		P_ADD_ML('系统管理','系统初始化');
    P_ADD_GNMK('系统管理~系统初始化','systemmanage.int.print','打印模板管理','../print/listPrintTemplate.iface','000000');
end;
/
commit;




-- 创建表: 处理状态代码
create table PI_DM_CLZT
(
  PI_CLZT_DM VARCHAR2(2) not null,
  PI_CLZT_MC VARCHAR2(20)
)
;
comment on table PI_DM_CLZT
  is '处理状态';
comment on column PI_DM_CLZT.PI_CLZT_DM
  is '处理状态代码';
comment on column PI_DM_CLZT.PI_CLZT_MC
  is '处理状态名称';
alter table PI_DM_CLZT
  add constraint PK_PI_DM_CLZT primary key (PI_CLZT_DM);


insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('10', '准备执行');
insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('15', '正在执行');
insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('20', '堵塞');
insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('21', '取消');
insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('29', '执行失败');
insert into PI_DM_CLZT (PI_CLZT_DM, PI_CLZT_MC)
values ('99', '成功结束');

commit;


-- 创建表: 时间频度代码
create table PI_DM_SJPD
(
  PI_SJPD_DM VARCHAR2(2) not null,
  PI_SJPD_MC VARCHAR2(10) not null
)
;
comment on table PI_DM_SJPD
  is '时间频度代码';
comment on column PI_DM_SJPD.PI_SJPD_DM
  is '时间频度代码';
comment on column PI_DM_SJPD.PI_SJPD_MC
  is '时间频度名称';
alter table PI_DM_SJPD
  add constraint PK_PI_DM_SJPD primary key (PI_SJPD_DM);


insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('02', '分');
insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('04', '小时');
insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('11', '天');
insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('16', '周');
insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('20', '月');
insert into PI_DM_SJPD (PI_SJPD_DM, PI_SJPD_MC)
values ('29', '月末');

commit;

-- 创建表: 任务
create table PI_TASK
(
  RWH      VARCHAR2(20) not null,
  TITLE    VARCHAR2(80) not null,
  GROUPID  VARCHAR2(20) not null,
  YXJB     NUMBER(10) not null,
  ZCYDSBZ  VARCHAR2(1) not null,
  REDO     VARCHAR2(1) not null,
  EXECUTOR VARCHAR2(4000) not null
)
;
comment on table PI_TASK
  is '任务';
comment on column PI_TASK.RWH
  is '任务号';
comment on column PI_TASK.TITLE
  is '任务描述';
comment on column PI_TASK.GROUPID
  is '所属组ID';
comment on column PI_TASK.YXJB
  is '任务优先级';
comment on column PI_TASK.ZCYDSBZ
  is '堵塞标志';
comment on column PI_TASK.REDO
  is '失败后是否重做';
comment on column PI_TASK.EXECUTOR
  is '执行体';
alter table PI_TASK
  add constraint PK_PI_TASK primary key (RWH);


-- 创建表: 任务组
create table PI_TASK_GROUP
(
  GROUPID VARCHAR2(20) not null,
  GYXJB   NUMBER(10) not null,
  GTITLE  VARCHAR2(80) not null,
  YWHJ_DM VARCHAR2(6) not null,
  LRR_DM  VARCHAR2(11) not null,
  LRRQ    DATE not null
)
;
comment on table PI_TASK_GROUP
  is '任务组定义';
comment on column PI_TASK_GROUP.GROUPID
  is '组ID';
comment on column PI_TASK_GROUP.GYXJB
  is '组优先级';
comment on column PI_TASK_GROUP.GTITLE
  is '组描述';
comment on column PI_TASK_GROUP.YWHJ_DM
  is '业务环节代码';
comment on column PI_TASK_GROUP.LRR_DM
  is '录入人';
comment on column PI_TASK_GROUP.LRRQ
  is '录入日期';
alter table PI_TASK_GROUP
  add constraint PK_PI_TASK_GROUP primary key (GROUPID);


-- 创建表: 任务调度
create table PI_TASK_SCHEDULE
(
  DDH        VARCHAR2(20) not null,
  PH         VARCHAR2(20) not null,
  RWH        VARCHAR2(20) not null,
  SJXLH      VARCHAR2(20),
  PI_CLZT_DM VARCHAR2(2) not null,
  REDO       VARCHAR2(1) not null,
  CLXX       VARCHAR2(250),
  KSSJ       DATE,
  JSSJ       DATE,
  LRRQ       DATE not null,
  BZ         VARCHAR2(200)
)
;
comment on table PI_TASK_SCHEDULE
  is '任务调度信息';
comment on column PI_TASK_SCHEDULE.DDH
  is '调度号';
comment on column PI_TASK_SCHEDULE.PH
  is '批号';
comment on column PI_TASK_SCHEDULE.RWH
  is '任务号';
comment on column PI_TASK_SCHEDULE.SJXLH
  is '时间序列号';
comment on column PI_TASK_SCHEDULE.PI_CLZT_DM
  is '处理状态';
comment on column PI_TASK_SCHEDULE.REDO
  is '失败后是否重做';
comment on column PI_TASK_SCHEDULE.CLXX
  is '处理信息';
comment on column PI_TASK_SCHEDULE.KSSJ
  is '开始时间';
comment on column PI_TASK_SCHEDULE.JSSJ
  is '结束时间';
comment on column PI_TASK_SCHEDULE.LRRQ
  is '录入日期';
comment on column PI_TASK_SCHEDULE.BZ
  is '调度备注';
alter table PI_TASK_SCHEDULE
  add constraint PK_PI_TASK_SCHEDULE primary key (DDH);
create index IDX_PI_TASK_SCHEDULE on PI_TASK_SCHEDULE (SJXLH);


-- 创建表: 时间任务
create table PI_TIMER
(
  SJXLH         VARCHAR2(20) not null,
  JS            VARCHAR2(200) not null,
  DAYNO         NUMBER(10),
  TIMEOFDAY     VARCHAR2(20),
  PI_SJPD_DM    VARCHAR2(2),
  PD            NUMBER(10) not null,
  STARTDATETIME DATE not null,
  PI_CLZT_DM    VARCHAR2(2) not null,
  LRR_DM        VARCHAR2(11) not null,
  LRRQ          DATE not null,
  SCZXSJ        DATE,
  XCZXSJ        DATE,
  ZZSJ          DATE
)
;
comment on table PI_TIMER
  is '时间任务定义';
comment on column PI_TIMER.SJXLH
  is '时间序列号';
comment on column PI_TIMER.JS
  is '说明';
comment on column PI_TIMER.DAYNO
  is '第几天';
comment on column PI_TIMER.TIMEOFDAY
  is '当前的具体时间: 时分秒';
comment on column PI_TIMER.PI_SJPD_DM
  is '时间频度代码';
comment on column PI_TIMER.PD
  is '频度';
comment on column PI_TIMER.STARTDATETIME
  is '启动时间';
comment on column PI_TIMER.PI_CLZT_DM
  is '处理状态';
comment on column PI_TIMER.LRR_DM
  is '录入人';
comment on column PI_TIMER.LRRQ
  is '录入日期';
comment on column PI_TIMER.SCZXSJ
  is '上次执行时间';
comment on column PI_TIMER.XCZXSJ
  is '下次执行时间';
comment on column PI_TIMER.ZZSJ
  is '中止时间';
alter table PI_TIMER
  add constraint PK_PI_TIMER primary key (SJXLH);


-- 创建表: 时间任务与任务组
create table PI_TIMER_GROUP
(
  SJXLH   VARCHAR2(20) not null,
  GROUPID VARCHAR2(20) not null
)
;
alter table PI_TIMER_GROUP
  add constraint PK_PI_TIMER_GROUP primary key (SJXLH, GROUPID);
comment on table PI_TIMER_GROUP
  is '时间任务与任务组关联';
comment on column PI_TIMER_GROUP.SJXLH
  is '时间序列号';
comment on column PI_TIMER_GROUP.GROUPID
  is '组ID';



-- Sequence creation
create sequence SEQ_PI_PHDDH
minvalue 1
maxvalue 99999999
start with 101
increment by 1
cache 20
cycle;



begin
	P_ADD_ROOT('systemmanage','系统管理', 90);
	P_ADD_ML('系统管理','批处理');
	P_ADD_GNMK('系统管理~批处理','systemmanage.batch.jobgroup','任务组定义','../work/pi/rwzdy/RwzdyBndService.searchTaskGroup.do','090000');
	P_ADD_GNMK('系统管理~批处理','systemmanage.batch.timer','时间管理','../work/pi/sjgl/TimerdyBndService.initTimer.do','090000');
	P_ADD_GNMK('系统管理~批处理','systemmanage.batch.console','调度监控','../work/pi/ddjk/index.jsp','090000');
end;
/
commit;








-- 创建表: 功能模块点击状态
create table MON_GNMK_CLICK
(
  USERID    VARCHAR2(11) not null,
  GNMK_DM   VARCHAR2(256) not null,
  STAT      NUMBER default 9999 not null,
  STAT_DATE DATE default sysdate not null
)
;
alter table MON_GNMK_CLICK
  add constraint PKMON_GNMK_CLICKMK_CLICK primary key (USERID, GNMK_DM);



begin
	P_ADD_ROOT('systemmanage','系统管理', 90);
	P_ADD_ML('系统管理','监控管理');
	P_ADD_GNMK('系统管理~监控管理','systemmanage.monitoring.onlineusers','在线用户','../work/mon/user/SessionService.getOnlineUsers.do','090000');
	P_ADD_GNMK('系统管理~监控管理','systemmanage.monitoring.userlogs','在线用户历史','../work/mon/user/UserService.getOnlineUsersHistory.do','090000');

	-- 操作注册
	insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('00000000000', '过滤','systemmanage.monitoring.onlineusers', '');
	insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('00000000001', '刷新','systemmanage.monitoring.onlineusers', '');
	insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('00000000002', '踢出','systemmanage.monitoring.onlineusers', '');
  insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values ('00000000001', 'systemmanage.monitoring.onlineusers', '00000000000');
  insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values ('00000000001', 'systemmanage.monitoring.onlineusers', '00000000002');
end;
/
commit;








-- 创建表: 在线用户
create table MON_ONLINE_USER
(
  USERID      VARCHAR2(20) not null,
  CZRY_MC     VARCHAR2(30),
  CZRY_DM     VARCHAR2(11),
  LOGIN_DATE  DATE default sysdate not null,
  LOGOUT_DATE DATE,
  JG_MC       VARCHAR2(60),
  IP          VARCHAR2(200),
  SESSIONID   VARCHAR2(200),
  FLAG        CHAR(1) not null,
  JG_DM       VARCHAR2(15),
  ID          VARCHAR2(40) not null
)
;
alter table MON_ONLINE_USER
  add primary key (ID);
create index IDX_MON_ONLINE_USER_JG_DM on MON_ONLINE_USER (JG_DM);
create index IDX_MON_ONLINE_USER_LOGIN_DATE on MON_ONLINE_USER (LOGIN_DATE);
create index IDX_MON_ONLINE_USER_USERID on MON_ONLINE_USER (USERID);
create index IDX_MON_ONLINE_USER_USERID_ID on MON_ONLINE_USER (USERID, ID);
comment on table MON_ONLINE_USER
  is '在线用户';
comment on column MON_ONLINE_USER.USERID
  is '用户id';
comment on column MON_ONLINE_USER.CZRY_MC
  is '操作人员名称';
comment on column MON_ONLINE_USER.CZRY_DM
  is '操作人员代码';
comment on column MON_ONLINE_USER.LOGIN_DATE
  is '登录时间';
comment on column MON_ONLINE_USER.LOGOUT_DATE
  is '退出时间';
comment on column MON_ONLINE_USER.JG_MC
  is '所属机构名称';
comment on column MON_ONLINE_USER.IP
  is '用户ip地址';
comment on column MON_ONLINE_USER.JG_DM
  is '所属机构代码';
comment on column MON_ONLINE_USER.FLAG
  is '状态';


commit;


begin
	P_ADD_ROOT('systemmanage','系统管理', 90);
	P_ADD_ML('系统管理','监控管理');
	P_ADD_GNMK('系统管理~监控管理','adplogger','日志管理','../logger/index.iface','000000');
end;
/

insert into HLP_GNMK (ID, CZRY_DATE, CZRY_MC, CZRY_DM, KEYWORD, REMARK, GNMK_DM, GNMK_HZMC, YWHJ_DM, CONTENT, PATH)
values (
    'adplogger-0001', to_date('2010-01-28', 'yyyy-mm-dd'), '超级管理员', '00000000000', '日志管理特点', NULL, 'adplogger', '日志管理', NULL
  , '<p>日志管理的特点：<br />
1、查询<br />
2、删除<br />
3、备份全部日志，下载备份文件<br />
4、清空全部日志<br />
&nbsp;</p>'
  , NULL
);

commit;


create table LOGMESSAGES
(
  ID       NUMBER(20) not null,
  LOGTIME  TIMESTAMP(6),
  LOGCLASS VARCHAR2(100),
  LOGLEVEL VARCHAR2(5),
  LOGUSER  VARCHAR2(20),
  MESSAGE  VARCHAR2(3000),
  BUSIID   VARCHAR2(50),
  EXPTID   VARCHAR2(50),
  primary key (ID)
);

begin
	P_ADD_ROOT('systemmanage','系统管理', 90);
	P_ADD_ML('系统管理','待办已办');
	P_ADD_GNMK('系统管理~待办已办','systemmanage.todo.setting','待办事宜设置','../work/message/dynacol/extDynacol.html','090000');
	P_ADD_GNMK('系统管理~待办已办','systemmanage.todo.dashboard','待办事宜','../work/message/main/index.jsp?type=1&gnmk_dm=systemmanage.todo.dashboard','090000');
	P_ADD_GNMK('系统管理~待办已办','systemmanage.done.dashboard','已办事宜','../work/message/main/index.jsp?type=2&gnmk_dm=systemmanage.done.dashboard','090000');

	-- 操作注册
	insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM) values ('filterByPriority', '按优先级过滤', 'systemmanage.todo.dashboard');
	insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM) values ('filterByType', '按类型过滤', 'systemmanage.todo.dashboard');
	insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.todo.dashboard','filterByPriority');
	insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.todo.dashboard','filterByType');

	insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM) values ('filterByPriority', '按优先级过滤', 'systemmanage.done.dashboard');
	insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM) values ('filterByType', '按类型过滤', 'systemmanage.done.dashboard');
	insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.done.dashboard','filterByPriority');
	insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.done.dashboard','filterByType');
end;
/

commit;





-- 创建表: 消息系统
create table MESSAGE_SYSTEM
(
  ID                    VARCHAR2(4) not null,
  NAME                  VARCHAR2(64) not null,
  KEY_NAME                   VARCHAR2(16) not null,
  IS_LEGACY             CHAR(1) not null,
  HANDLER_CLASS         VARCHAR2(256) not null,
  MAPPING_BUILDER_CLASS VARCHAR2(256) not null,
  DESCRIPTION           VARCHAR2(256),
  IS_ENABLED            CHAR(1) default 'Y' not null
)
;
comment on table MESSAGE_SYSTEM
  is '消息系统';
comment on column MESSAGE_SYSTEM.ID
  is '消息系统id';
comment on column MESSAGE_SYSTEM.NAME
  is '消息系统名称';
comment on column MESSAGE_SYSTEM.KEY_NAME
  is '消息系统key，key_id为消息UID';
comment on column MESSAGE_SYSTEM.IS_LEGACY
  is '是否为遗留系统，‘Y’：遗留系统，‘N’：非遗留系统';
comment on column MESSAGE_SYSTEM.HANDLER_CLASS
  is '消息处理类，必须继承自MessageHandler';
comment on column MESSAGE_SYSTEM.MAPPING_BUILDER_CLASS
  is '映射处理类，必须实现MappingBuilder接口';
comment on column MESSAGE_SYSTEM.DESCRIPTION
  is '消息系统描述';
comment on column MESSAGE_SYSTEM.IS_ENABLED
  is '是否启用此消息系统';
alter table MESSAGE_SYSTEM
  add constraint PK_MESSAGE_SYSTEM primary key (ID);
alter table MESSAGE_SYSTEM
  add constraint UNI_MESSAGE_SYSTEM_KEY unique (KEY_NAME);


insert into MESSAGE_SYSTEM (ID, NAME, KEY_NAME, IS_LEGACY, HANDLER_CLASS, MAPPING_BUILDER_CLASS, DESCRIPTION, IS_ENABLED)
  values ('1000', '缺省消息系统', 'GENERIC', 'N', 'message.handler.GenericMessageHandler', 'message.mapping.GenericORMappingBuilder', null, 'Y');

commit;



-- 创建表: 消息类型
create table MESSAGE_TYPE
(
  ID   CHAR(6) not null,
  NAME VARCHAR2(64) not null
)
;
comment on table MESSAGE_TYPE
  is '消息类型';
comment on column MESSAGE_TYPE.ID
  is '消息类型id';
comment on column MESSAGE_TYPE.NAME
  is '消息类型名称';
alter table MESSAGE_TYPE
  add constraint PK_MESSAGE_TYPE primary key (ID);


insert into MESSAGE_TYPE (ID, NAME)
values ('100000', '任务');
insert into MESSAGE_TYPE (ID, NAME)
values ('200000', '提示');
insert into MESSAGE_TYPE (ID, NAME)
values ('300000', '预警');
insert into MESSAGE_TYPE (ID, NAME)
values ('900000', '消息');

commit;


-- 创建表: 消息
create table MESSAGE
(
  ID                VARCHAR2(20) not null,
  SYSTEM_NAME       VARCHAR2(50),
  MESSAGE_SYSTEM_ID VARCHAR2(4),
  TOPIC             VARCHAR2(512) not null,
  TOPIC_URL         VARCHAR2(512),
  TYPE              CHAR(6),
  PRIORITY          CHAR(1),
  ALLOW_DELETE      CHAR(1),
  CREATE_TIME       DATE default sysdate not null,
  CREATED_BY        CHAR(11),
  LAST_RECEIVED_BY  CHAR(11),
  LAST_RECEIVE_TIME DATE,
  IS_ARCHIVED       CHAR(1) default 'N' not null,
  ARCHIVE_TIME      DATE,
  AVAILABLE_UNTIL   DATE,
  COMMENTS          VARCHAR2(4000)
)
;
comment on table MESSAGE
  is '通用消息';
comment on column MESSAGE.ID
  is '消息id';
comment on column MESSAGE.SYSTEM_NAME
  is '系统名称（参照qx_system）';
comment on column MESSAGE.MESSAGE_SYSTEM_ID
  is '消息系统id';
comment on column MESSAGE.TOPIC
  is '消息主题';
comment on column MESSAGE.TOPIC_URL
  is '消息主题链接url';
comment on column MESSAGE.TYPE
  is '消息类型';
comment on column MESSAGE.PRIORITY
  is '优先级，‘H’：高，‘M’：中等，‘L’：低';
comment on column MESSAGE.ALLOW_DELETE
  is '是否允许删除，‘Y’：允许，‘N’：不允许';
comment on column MESSAGE.CREATE_TIME
  is '创建时间';
comment on column MESSAGE.CREATED_BY
  is '创建人';
comment on column MESSAGE.LAST_RECEIVED_BY
  is '最后接收人';
comment on column MESSAGE.LAST_RECEIVE_TIME
  is '最后接收时间';
comment on column MESSAGE.IS_ARCHIVED
  is '是否归档，‘Y’：已归档，‘N’：未归档';
comment on column MESSAGE.ARCHIVE_TIME
  is '归档时间';
comment on column MESSAGE.AVAILABLE_UNTIL
  is '任务的办结期限，消息的有效期限';
comment on column MESSAGE.COMMENTS
  is '注释';
alter table MESSAGE
  add constraint PK_MESSAGE primary key (ID);
alter table MESSAGE
  add constraint FK_MESSAGE_MSG_SYSTEM foreign key (MESSAGE_SYSTEM_ID)
  references MESSAGE_SYSTEM (ID);
alter table MESSAGE
  add constraint FK_MESSAGE_SYSTEM foreign key (SYSTEM_NAME)
  references QX_SYSTEM (SYSTEMNAME);
alter table MESSAGE
  add constraint FK_MESSAGE_TYPE foreign key (TYPE)
  references MESSAGE_TYPE (ID);


-- 创建表: 消息字段定义
create table MESSAGE_FIELD_DEFINITION
(
  NAME         VARCHAR2(128) not null,
  IS_CUSTOM    CHAR(1) not null,
  CONTENT_TYPE CHAR(2),
  DESCRIPTION  VARCHAR2(256)
)
;
comment on table MESSAGE_FIELD_DEFINITION
  is '消息字段定义';
comment on column MESSAGE_FIELD_DEFINITION.NAME
  is '消息字段名称';
comment on column MESSAGE_FIELD_DEFINITION.IS_CUSTOM
  is '是否为自定义字段';
comment on column MESSAGE_FIELD_DEFINITION.CONTENT_TYPE
  is '字段内容类型（暂不支持，留空）';
comment on column MESSAGE_FIELD_DEFINITION.DESCRIPTION
  is '字段说明';
alter table MESSAGE_FIELD_DEFINITION
  add constraint PK_MESSAGE_FIELD_DEF primary key (NAME);

insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('ID', 'N', null, '消息编号');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('SYSTEMNAME', 'N', null, '系统名称');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('MESSAGESYSTEMID', 'N', null, '来源消息系统号');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('TOPIC', 'N', null, '主题');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('TOPICURL', 'N', null, '主题链接url');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('TYPE', 'N', null, '任务类型');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('PRIORITY', 'N', null, '优先级');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('ALLOWDELETE', 'N', null, '是否允许删除');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('CREATETIME', 'N', null, '创建时间');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('CREATEDBY', 'N', null, '创建人');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('LASTRECEIVEDBY', 'N', null, '最后接收人');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('ISARCHIVED', 'N', null, '是否归档');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('ARCHIVETIME', 'N', null, '归档时间');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('AVAILABLEUNTIL', 'N', null, '有效期/办结期限');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('COMMENTS', 'N', null, '备注');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('STATUS', 'Y', null, '状态');
insert into MESSAGE_FIELD_DEFINITION (NAME, IS_CUSTOM, CONTENT_TYPE, DESCRIPTION)
values ('LASTRECEIVETIME', 'N', null, '最后接收时间');

commit;



-- 创建表: 消息扩展
create table MESSAGE_EXTENSION
(
  MESSAGE_ID        VARCHAR2(20) not null,
  CUSTOM_FIELD_NAME VARCHAR2(128) not null,
  FIELD_VALUE       VARCHAR2(4000)
)
;
comment on table MESSAGE_EXTENSION
  is '通用消息扩展';
comment on column MESSAGE_EXTENSION.MESSAGE_ID
  is '消息id';
comment on column MESSAGE_EXTENSION.CUSTOM_FIELD_NAME
  is '自定义字段名称';
comment on column MESSAGE_EXTENSION.FIELD_VALUE
  is '自定义字段值';
alter table MESSAGE_EXTENSION
  add constraint PK_MESSAGE_EXT primary key (MESSAGE_ID, CUSTOM_FIELD_NAME);
alter table MESSAGE_EXTENSION
  add constraint FK_MESSAGE_EXT_FIELD foreign key (CUSTOM_FIELD_NAME)
  references MESSAGE_FIELD_DEFINITION (NAME);
alter table MESSAGE_EXTENSION
  add constraint FK_MESSAGE_EXT_MESSAGE foreign key (MESSAGE_ID)
  references MESSAGE (ID);


-- 创建表: 消息字段展示定义
create table MESSAGE_FIELD_DISPLAY
(
  USER_ID       VARCHAR2(11) not null,
  FIELD_NAME    VARCHAR2(128) not null,
  DISPLAY_ORDER INTEGER not null,
  DISPLAY_NAME  VARCHAR2(128),
  WIDTH         VARCHAR2(16),
  SORTORDER     VARCHAR2(2),
  SORTDIRECTION  VARCHAR2(2)
)
;
alter table MESSAGE_FIELD_DISPLAY
  add constraint PK_MESSAGE_FIELD_DISPLAY primary key (USER_ID, FIELD_NAME, DISPLAY_ORDER);
alter table MESSAGE_FIELD_DISPLAY
  add constraint FK_MESSAGE_FIELD_DISPLAY foreign key (FIELD_NAME)
  references MESSAGE_FIELD_DEFINITION (NAME);
comment on table MESSAGE_FIELD_DISPLAY
  is '消息字段展示定义（分用户）';
comment on column MESSAGE_FIELD_DISPLAY.USER_ID
  is '用户id（操作人员代码）';
comment on column MESSAGE_FIELD_DISPLAY.FIELD_NAME
  is '通用消息字段名称';
comment on column MESSAGE_FIELD_DISPLAY.DISPLAY_ORDER
  is '显示顺序，数值越小越靠前';
comment on column MESSAGE_FIELD_DISPLAY.DISPLAY_NAME
  is '显示名称';
comment on column MESSAGE_FIELD_DISPLAY.WIDTH
  is '显示宽度';
comment on column MESSAGE_FIELD_DISPLAY.SORTORDER  is '缺省排序顺序';
comment on column MESSAGE_FIELD_DISPLAY.SORTDIRECTION  is '排序方式:Y升序,N降序';


-- 创建表: 消息系统的消息字段
create table MESSAGE_SYSTEM_FIELD
(
  MESSAGE_SYSTEM_ID VARCHAR2(4) not null,
  FIELD_NAME        VARCHAR2(128) not null
)
;
comment on table MESSAGE_SYSTEM_FIELD
  is '消息系统和消息字段对照关系';
comment on column MESSAGE_SYSTEM_FIELD.MESSAGE_SYSTEM_ID
  is '消息系统id';
comment on column MESSAGE_SYSTEM_FIELD.FIELD_NAME
  is '消息字段名称';
alter table MESSAGE_SYSTEM_FIELD
  add constraint PK_MESSAGE_SYSTEM_FIELD primary key (MESSAGE_SYSTEM_ID, FIELD_NAME);
alter table MESSAGE_SYSTEM_FIELD
  add constraint FK_MESSAGE_SYSTEM_FIELD_ID foreign key (MESSAGE_SYSTEM_ID)
  references MESSAGE_SYSTEM (ID);
alter table MESSAGE_SYSTEM_FIELD
  add constraint FK_MESSAGE_SYSTEM_FIELD_NAME foreign key (FIELD_NAME)
  references MESSAGE_FIELD_DEFINITION (NAME);



insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'ALLOWDELETE');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'ARCHIVETIME');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'AVAILABLEUNTIL');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'COMMENTS');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'CREATEDBY');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'CREATETIME');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'ID');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'ISARCHIVED');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'LASTRECEIVEDBY');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'LASTRECEIVETIME');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'MESSAGESYSTEMID');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'PRIORITY');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'STATUS');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'SYSTEMNAME');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'TOPIC');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'TOPICURL');
insert into MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME)
values ('1000', 'TYPE');

commit;



-- 创建表: 消息字段映射
create table MESSAGE_FIELD_MAPPING
(
  MESSAGE_SYSTEM_ID VARCHAR2(4),
  FIELD_NAME        VARCHAR2(128),
  LEGACY_TABLE_NAME VARCHAR2(32) not null,
  LEGACY_FIELD_EXP  VARCHAR2(256) not null
)
;
comment on table MESSAGE_FIELD_MAPPING
  is '通用消息字段映射';
comment on column MESSAGE_FIELD_MAPPING.MESSAGE_SYSTEM_ID
  is '消息系统id';
comment on column MESSAGE_FIELD_MAPPING.FIELD_NAME
  is '字段名称';
comment on column MESSAGE_FIELD_MAPPING.LEGACY_TABLE_NAME
  is '对应的遗留系统表名称';
comment on column MESSAGE_FIELD_MAPPING.LEGACY_FIELD_EXP
  is '对应的遗留系统字段表达式（SQL语法）';
alter table MESSAGE_FIELD_MAPPING
  add constraint FK_MSG_FIELD_MAPPING_FN foreign key (FIELD_NAME)
  references MESSAGE_FIELD_DEFINITION (NAME);
alter table MESSAGE_FIELD_MAPPING
  add constraint FK_MSG_FIELD_MAPPING_ID foreign key (MESSAGE_SYSTEM_ID, FIELD_NAME)
  references MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME);


-- 创建表: 消息字段渲染器
create table MESSAGE_FIELD_RENDER
(
  ID                VARCHAR2(10),
  NAME              VARCHAR2(32),
  MESSAGE_SYSTEM_ID VARCHAR2(4),
  DESCRIPTION       VARCHAR2(256),
  FIELD_NAME        VARCHAR2(128),
  RENDER_CLASS      VARCHAR2(256)
)
;
comment on table MESSAGE_FIELD_RENDER
  is '通用消息字段渲染器';
comment on column MESSAGE_FIELD_RENDER.ID
  is '渲染器id';
comment on column MESSAGE_FIELD_RENDER.NAME
  is '渲染器名称';
comment on column MESSAGE_FIELD_RENDER.MESSAGE_SYSTEM_ID
  is '消息系统id';
comment on column MESSAGE_FIELD_RENDER.DESCRIPTION
  is '渲染器描述';
comment on column MESSAGE_FIELD_RENDER.FIELD_NAME
  is '字段名称';
comment on column MESSAGE_FIELD_RENDER.RENDER_CLASS
  is '渲染器类';
alter table MESSAGE_FIELD_RENDER
  add constraint FK_MESSAGE_FIELD_RENDER foreign key (FIELD_NAME)
  references MESSAGE_FIELD_DEFINITION (NAME);




insert into MESSAGE_FIELD_RENDER (ID, NAME, MESSAGE_SYSTEM_ID, DESCRIPTION, FIELD_NAME, RENDER_CLASS)
values ('00000001', 'SGYTOPIC', '9001', null, 'TOPIC', 'ctais.business.message.common.SgyTopicMessageRender');
insert into MESSAGE_FIELD_RENDER (ID, NAME, MESSAGE_SYSTEM_ID, DESCRIPTION, FIELD_NAME, RENDER_CLASS)
values ('00000002', 'TODOTOPIC', '9000', null, 'TOPIC', 'ctais.business.message.common.TodoTopicMessageRender');
insert into MESSAGE_FIELD_RENDER (ID, NAME, MESSAGE_SYSTEM_ID, DESCRIPTION, FIELD_NAME, RENDER_CLASS)
values ('00000003', 'TODOLSTOPIC', '9002', null, 'TOPIC', 'ctais.business.message.common.TodoTopicMessageRender');
insert into MESSAGE_FIELD_RENDER (ID, NAME, MESSAGE_SYSTEM_ID, DESCRIPTION, FIELD_NAME, RENDER_CLASS)
values ('00000004', 'reptodotopic', '1000', null, 'TOPIC', 'ctais.business.message.common.TodoTopicMessageRender');
commit;



begin
	P_ADD_ROOT('systemmanage','系统管理', 90);
	P_ADD_ML('系统管理','监控管理');
	P_ADD_GNMK('系统管理~监控管理','systemmanage.monitoring.track','跟踪','../track/index.jsp','090000');
end;
/
commit;


begin
	P_ADD_ROOT('demo','范例', 99);
	P_ADD_ML('范例','查询框架');
	P_ADD_GNMK('范例~查询框架','demo.query.operatorquery','操作人员查询','../work/query/index.jsp?gnmk_dm=demo.query.operatorquery&queryid=test.test1&GZBZ=N','000000');
end;
/
commit;








-- 创建表: 查询模块代码
create table DM_CXMK
(
  CXMK_DM  VARCHAR2(6) not null,
  CXMK_MC  VARCHAR2(50) not null,
  YM_RIGHT VARCHAR2(50) not null,
  YM_TOP   VARCHAR2(50) not null,
  XYBZ     CHAR(1) default 'Y' not null,
  YXBZ     CHAR(1) default 'Y' not null
)
;
comment on table DM_CXMK
  is '查询模块代码';
comment on column DM_CXMK.CXMK_DM
  is '查询模块代码（前两位子系统分类，如SB1101）';
comment on column DM_CXMK.CXMK_MC
  is '查询模块名称';
comment on column DM_CXMK.YM_RIGHT
  is '页面（结果显示页面链接RIGHT.HTM全路径）';
comment on column DM_CXMK.YM_TOP
  is '页面（用户条件定制页面链接TOP.JSP全路径）';
comment on column DM_CXMK.XYBZ
  is '选用标志';
comment on column DM_CXMK.YXBZ
  is '有效标志';
alter table DM_CXMK
  add constraint PK_DM_CXMK primary key (CXMK_DM);


-- 创建表: 异步查询
create table CX_ASYNQUERY
(
  ASYNQUERYID VARCHAR2(255) not null,
  QUERYID     VARCHAR2(255) not null,
  CONDITION_NAME   VARCHAR2(2000) not null,
  CACHETYPE   VARCHAR2(20) default 'db' not null,
  QUERYTIME   DATE not null
)
;
comment on table CX_ASYNQUERY
  is '异步查询';
comment on column CX_ASYNQUERY.ASYNQUERYID
  is '异步查询ID';
comment on column CX_ASYNQUERY.QUERYID
  is '查询ID';
comment on column CX_ASYNQUERY.CONDITION_NAME
  is '查询条件';
comment on column CX_ASYNQUERY.CACHETYPE
  is '缓存类型。none(无缓存)、db(数据库)、mem(内存)，默认为db。';
comment on column CX_ASYNQUERY.QUERYTIME
  is '查询时间';
alter table CX_ASYNQUERY
  add constraint PK_CX_ASYNQUERY primary key (ASYNQUERYID);


-- 创建表: 查询缓存
create table CX_CACHE
(
  QUERYID          VARCHAR2(255) not null,
  CONDITION_NAME        VARCHAR2(2000) not null,
  CREATINGTIME     DATE not null,
  EXPIRINGTIME     DATE,
  DETAILRESULT     VARCHAR2(255),
  DETAILRESULTSZIE NUMBER(10) default 0,
  STATRESULT       VARCHAR2(255),
  STATRESULTSZIE   NUMBER(10) default 0,
  SUMRESULT        VARCHAR2(255)
)
;
comment on table CX_CACHE
  is '查询缓存';
comment on column CX_CACHE.QUERYID
  is '查询ID';
comment on column CX_CACHE.CONDITION_NAME
  is '查询条件';
comment on column CX_CACHE.CREATINGTIME
  is '缓存创建时间';
comment on column CX_CACHE.EXPIRINGTIME
  is '缓存过期时间';
comment on column CX_CACHE.DETAILRESULT
  is '明细查询结果表名';
comment on column CX_CACHE.DETAILRESULTSZIE
  is '明细查询结果行数';
comment on column CX_CACHE.STATRESULT
  is '统计查询结果表名';
comment on column CX_CACHE.STATRESULTSZIE
  is '统计查询结果行数';
comment on column CX_CACHE.SUMRESULT
  is '合计查询结果表名';
alter table CX_CACHE
  add constraint PK_CX_CACHE primary key (QUERYID, CONDITION_NAME);


----文书凭证序号
  -----------------------------------------------
-- Export file for user RPT                  --
-- Created by CHENYLE on 2009-9-11, 23:09:57 --
-----------------------------------------------
create sequence SEQ_WSPZXH
minvalue 1
maxvalue 9999999999
start with 1
increment by 1
cache 20
cycle;



create table QX_FAV_GNMK_TREE
(
  JD_DM    VARCHAR2(21) not null,
  FJD_DM   VARCHAR2(21) not null,
  JD_MC    VARCHAR2(80) not null,
  GNMK_DM  VARCHAR2(256),
  JDLX_DM  VARCHAR2(2),
  JD_ORDER NUMBER(5) not null,
  USERID   VARCHAR2(11) not null
)
;
comment on column QX_FAV_GNMK_TREE.JD_DM
  is '功能模块代码';
comment on column QX_FAV_GNMK_TREE.FJD_DM
  is '节点类型代码';
comment on column QX_FAV_GNMK_TREE.JD_MC
  is '节点名称';
comment on column QX_FAV_GNMK_TREE.GNMK_DM
  is '节点代码';
comment on column QX_FAV_GNMK_TREE.JDLX_DM
  is '父节点代码';
comment on column QX_FAV_GNMK_TREE.JD_ORDER
  is '节点顺序';
comment on column QX_FAV_GNMK_TREE.USERID
  is '用户ID';
alter table QX_FAV_GNMK_TREE
  add constraint PK_QX_FAV_GNMK_TREE primary key (JD_DM,USERID);
--alter table QX_FAV_GNMK_TREE
--  add constraint FK_QX_FAV_GNMK_TREE_USERID foreign key (USERID)
--  references QX_USER (USERID);

commit;



begin
	P_ADD_ROOT('systemmanage','系统管理', 90);
	P_ADD_ML('系统管理','组织权限');
	P_ADD_GNMK('系统管理~组织权限','systemmanage.security.system','业务系统注册','../portal/system/SystemBndService.ywxtzclist.do','090000');
end;
/
commit;






create table DASHBOARD_TABINFO  (
   tabid              VARCHAR2(36)                    not null,
   tabtype            VARCHAR2(15)                    not null,
   userid             VARCHAR2(11),
   jsdm               VARCHAR2(11),
   tabtitle           VARCHAR2(50)                    not null,
   tabcolumsnum       INT                             not null,
   tabitemheight      INT,
   createtime         TIMESTAMP                       not null,
   constraint PK_DASHBOARD_TABINFO primary key (tabid)
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

create table DASHBOARD_TABCONTENTINFO  (
   tabid              VARCHAR2(36)                     not null,
   tabcontent         VARCHAR2(2000),
   constraint PK_DASHBOARD_TABCONTENTINFO primary key (tabid)
);

comment on column DASHBOARD_TABCONTENTINFO.tabid is
'tabid';

comment on column DASHBOARD_TABCONTENTINFO.tabcontent is
'tab页中内容';


begin
		P_ADD_ROOT('systemmanage','系统管理', 90);
		P_ADD_ML('系统管理','系统初始化');
    P_ADD_GNMK('系统管理~系统初始化','systemmanage.init.roleDashboard','角色主页管理','../dashboard/dashboard.jsp?dashboardType=role','000000');
end;
/
commit;


begin
  P_ADD_ROOT('systemmanage','系统管理', 90);
  P_ADD_ML('系统管理','业务导航');
  P_ADD_GNMK('系统管理~业务导航','systemmanage.bussinessnav','业务导航配置','../pageflow/index/index.jsp','000000');
--  P_ADD_ROOT('demo','范例', 99);
--  P_ADD_ML('范例','业务导航');
--  P_ADD_GNMK('范例~业务导航','sample.bussinessnav.firstPage','业务导航测试页面1','../pageflow/testpage/firstPage.html','000000');
--  P_ADD_GNMK('范例~业务导航','sample.bussinessnav.secondPage','业务导航测试页面2','../pageflow/testpage/secondPage.html','000000');

end;
/
commit;


-- ============================================================
--   TABLE:      PAGEFLOW_ZB
--   汉字名称:   页面流程服务主表
--   创建日期：  2009-10-28
--   修改日期：
--   修改内容：
-- ============================================================
-- Table creation
create table PAGEFLOW_ZB
(
  PAGEFLOW_ID   VARCHAR2(6) not null,
  PAGEFLOW_SIZE NUMBER(2) not null,
  NAME          VARCHAR2(100) not null,
  DESCRIPTION   VARCHAR2(200)
);
-- Add comments to the table
comment on table PAGEFLOW_ZB
  is '页面流程服务主表';
-- Add comments to the columns
comment on column PAGEFLOW_ZB.PAGEFLOW_ID
  is '页面流程服务标识ID';
comment on column PAGEFLOW_ZB.PAGEFLOW_SIZE
  is '页数';
comment on column PAGEFLOW_ZB.NAME
  is '名称';
comment on column PAGEFLOW_ZB.DESCRIPTION
  is '描述';
-- Create/Recreate primary, unique and foreign key constraints
alter table PAGEFLOW_ZB
  add constraint PK_PAGEFLOW_ZB primary key (PAGEFLOW_ID)
  using index ;
-- ============================================================
--   TABLE:      PAGEFLOW_PAGE
--   汉字名称:   页面信息配置表
--   创建日期：  2009-10-28
--   修改日期：
--   修改内容：
-- ============================================================
create table PAGEFLOW_PAGE
(
  PAGE_ID      VARCHAR2(20) not null,
  PAGEFLOW_ID  VARCHAR2(6) not null,
  SYSTEM       VARCHAR2(100) not null,
  PAGEINDEX    NUMBER(2) not null,
  SYSTEM_TYPE  NUMBER(1) not null,
  PAGE_URL     VARCHAR2(500),
  PAGELINKTYPE CHAR(1),
  PAGE_MOD_ID  VARCHAR2(100)
);
-- Add comments to the table
comment on table PAGEFLOW_PAGE
  is '页面流程表';
-- Add comments to the columns
comment on column PAGEFLOW_PAGE.PAGE_ID
  is '页面ID';
comment on column PAGEFLOW_PAGE.PAGEFLOW_ID
  is '页面流程标识ID';
comment on column PAGEFLOW_PAGE.SYSTEM
  is '业务系统';
comment on column PAGEFLOW_PAGE.PAGEINDEX
  is '第几页';
comment on column PAGEFLOW_PAGE.SYSTEM_TYPE
  is '系统类型（1：b/s；2：c/s）';
comment on column PAGEFLOW_PAGE.PAGE_URL
  is '页面URL';
comment on column PAGEFLOW_PAGE.PAGELINKTYPE
  is '页面链接类型';
comment on column PAGEFLOW_PAGE.PAGE_MOD_ID
  is '页面模块ID';
-- Create/Recreate primary, unique and foreign key constraints
alter table PAGEFLOW_PAGE
  add constraint PK_PAGE_ID primary key (PAGE_ID)
  using index;
alter table PAGEFLOW_PAGE
  add constraint FK_PAGEFLOW_ID foreign key (PAGEFLOW_ID)
  references PAGEFLOW_ZB (PAGEFLOW_ID);


-- ============================================================
--   TABLE:      PAGEFLOW_PARAMETER
--   汉字名称:   页面参数信息配置表
--   创建日期：  2009-10-28
--   修改日期：
--   修改内容：
-- ============================================================
-- Table creation
create table PAGEFLOW_PARAMETER
(
  PARAMETER_ID VARCHAR2(20) not null,
  PAGEFLOW_ID  VARCHAR2(6) not null,
  PAGE_ID      VARCHAR2(20) not null,
  PAGE_GET     VARCHAR2(100),
  PAGE_GET_VAR VARCHAR2(100),
  PAGE_SET     VARCHAR2(100),
  PAGE_SET_VAR VARCHAR2(100),
  PAGE_EVENT   VARCHAR2(100)
);
-- Add comments to the table
comment on table PAGEFLOW_PARAMETER
  is '页面参数表';
-- Add comments to the columns
comment on column PAGEFLOW_PARAMETER.PARAMETER_ID
  is '参数标识ID';
comment on column PAGEFLOW_PARAMETER.PAGE_ID
  is '页面标识ID';
comment on column PAGEFLOW_PARAMETER.PAGE_GET
  is '获取页面参数';
comment on column PAGEFLOW_PARAMETER.PAGE_SET
  is '向页面设值';
comment on column PAGEFLOW_PARAMETER.PAGE_EVENT
  is '所取页面参数改变时取值';
comment on column PAGEFLOW_PARAMETER.PAGEFLOW_ID
  is '流程ID';
comment on column PAGEFLOW_PARAMETER.PAGE_GET_VAR
  is 'GET方法对应的页面参数';
comment on column PAGEFLOW_PARAMETER.PAGE_SET_VAR
  is 'SET方法对应的页面参数';
-- Create/Recreate primary, unique and foreign key constraints
alter table PAGEFLOW_PARAMETER
  add constraint PK_PARAMETER_ID primary key (PARAMETER_ID)
  using index;
alter table PAGEFLOW_PARAMETER
  add constraint FK_PAGE_ID foreign key (PAGE_ID)
  references PAGEFLOW_PAGE (PAGE_ID);



-- ============================================================
--   TABLE:      PAGEFLOW_VARIABLE
--   汉字名称:   流程变量信息配置表
--   创建日期：  2009-10-28
--   修改日期：
--   修改内容：
-- ============================================================
-- Table creation
create table PAGEFLOW_VARIABLE
(
  VARIABLE_ID    VARCHAR2(20) not null,
  PAGEFLOW_ID    VARCHAR2(6) not null,
  VARNAME        VARCHAR2(100) not null,
  FLOW_VAR       VARCHAR2(100) not null,
  VARDESCRIPTION VARCHAR2(200)
);
-- Add comments to the table
comment on table PAGEFLOW_VARIABLE
  is '流程参数表';
-- Add comments to the columns
comment on column PAGEFLOW_VARIABLE.VARIABLE_ID
  is '流程参数ID';
comment on column PAGEFLOW_VARIABLE.PAGEFLOW_ID
  is '流程ID';
comment on column PAGEFLOW_VARIABLE.VARNAME
  is '流程参数名称';
comment on column PAGEFLOW_VARIABLE.FLOW_VAR
  is '流程参数';
comment on column PAGEFLOW_VARIABLE.VARDESCRIPTION
  is '流程参数描述';
-- Create/Recreate primary, unique and foreign key constraints
alter table PAGEFLOW_VARIABLE
  add constraint PK_VARIABLE_ID primary key (VARIABLE_ID)
  using index ;
alter table PAGEFLOW_VARIABLE
  add constraint FK_VARIABLE_ID foreign key (PAGEFLOW_ID)
  references PAGEFLOW_ZB (PAGEFLOW_ID);



-- ============================================================
--   汉字名称:   获取参数ID
--   创建日期：  2009-10-28
--   修改日期：
--   修改内容：
-- ============================================================

-- Sequence creation
create sequence SEQ_PAGEFLOW_PARAMETER_ID
minvalue 1
maxvalue 99999
start with 1
increment by 1
cache 20
cycle;
-- ============================================================
--   汉字名称:   获取变量ID
--   创建日期：  2009-10-28
--   修改日期：
--   修改内容：
-- ============================================================
-- Sequence creation
create sequence SEQ_PAGEFLOW_VARIABLE_ID
minvalue 1
maxvalue 999999
start with 1
increment by 1
cache 20
cycle;

-- ============================================================
--   汉字名称:   获取页面ID
--   创建日期：  2009-10-28
--   修改日期：
--   修改内容：
-- ============================================================
-- Sequence creation
create sequence SEQ_PAGEFLOW_PAGE_ID
minvalue 1
maxvalue 999999
start with 1
increment by 1
cache 20
cycle;

begin
  P_ADD_ROOT('systemmanage','系统管理', 90);
	P_ADD_ML('系统管理','辅助信息管理');
	P_ADD_GNMK('系统管理~辅助信息管理','systemmanage.fzxx','辅助信息维护','../fzxx/dcone/xxgl/index.jsp','000000');
--	P_ADD_ROOT('demo','范例', 99);
--	P_ADD_ML('范例','辅助信息管理');
--	P_ADD_GNMK('范例~辅助信息管理','sample.fzxxTest','辅助信息范例页面','../fzxx/dcone/xxgl/xxss/fzxxTestPage.jsp','000000');

end;
/
commit;



begin
  	P_ADD_ROOT('systemmanage','系统管理', 90);
	P_ADD_ML('系统管理','疑点纳税人预警');
	P_ADD_GNMK('系统管理~疑点纳税人预警','systemmanage.suspicionwarning.infomaintenance','疑点纳税人预警信息维护','../fzxx/dcone/warning/infoMaintenance/index.jsp','000000');
end;
/
commit;


--   Table: NSR_SUSPICION
--   汉字名称: 纳税人疑点信息表
--   创建日期：2010-8-4
--   修改日期：
--   修改内容：
-- ============================================================
create table NSR_SUSPICION
(
  ID      NUMBER(20) not null,
  NSRSBH  VARCHAR2(20) not null,
  NSRMC   VARCHAR2(80) not null,
  BT      VARCHAR2(40) not null,
  YDNR    VARCHAR2(4000) not null,
  LRSJ    DATE,
  LRRID   VARCHAR2(11) not null,
  LRRDM   VARCHAR2(11) not null,
  LRRMC   VARCHAR2(20) not null,
  LRRJGDM VARCHAR2(15) not null,
  LRRJGMC VARCHAR2(60)
);
-- Add comments to the columns
comment on column NSR_SUSPICION.ID
  is '序号';
comment on column NSR_SUSPICION.NSRSBH
  is '纳税人识别号';
comment on column NSR_SUSPICION.NSRMC
  is '纳税人名称';
comment on column NSR_SUSPICION.YDNR
  is '疑点内容';
comment on column NSR_SUSPICION.BT
  is '标题';
comment on column NSR_SUSPICION.LRSJ
  is '录入时间';
comment on column NSR_SUSPICION.LRRID
  is '录入人ID';
comment on column NSR_SUSPICION.LRRDM
  is '录入人代码';
comment on column NSR_SUSPICION.LRRMC
  is '录入人名称';
comment on column NSR_SUSPICION.LRRJGDM
  is '录入人机关代码';
comment on column NSR_SUSPICION.LRRJGMC
  is '录入人机关名称';
-- Create/Recreate primary, unique and foreign key constraints
alter table NSR_SUSPICION
  add constraint PK_NSR_SUSPICION primary key (ID);

create index INDEX_NSR_SUSPICION on NSR_SUSPICION (BT);
-- ============================================================
--   Sequence: SEQ_NSR_SUSPICION
--   汉字名称: 纳税人疑点信息序列
--   创建日期：2010-8-4
--   修改日期：
--   修改内容：
-- ============================================================
create sequence SEQ_NSR_SUSPICION
minvalue 1
maxvalue 99999999
start with 1
increment by 1
cache 20
cycle;

-- ============================================================
--   Table: NSR_SUSPICION_SERVICE
--   汉字名称: 服务管理表
--   创建日期：2010-8-11
--   修改日期：
--   修改内容：
-- ============================================================
create table NSR_SUSPICION_SERVICE
(
  ID        NUMBER(20) not null,
  BT        VARCHAR2(50) not null,
--  URL       VARCHAR2(100) not null,
  SERVICEID VARCHAR2(20) not null,
  BZ        VARCHAR2(500) not null
);
-- Add comments to the columns
comment on column NSR_SUSPICION_SERVICE.ID
  is 'ID';
comment on column NSR_SUSPICION_SERVICE.BT
  is '标题';
--comment on column NSR_SUSPICION_SERVICE.URL
--  is '显示页面的地址';
comment on column NSR_SUSPICION_SERVICE.SERVICEID
  is '服务ID';
comment on column NSR_SUSPICION_SERVICE.BZ
  is '备注';
-- Create/Recreate primary, unique and foreign key constraints
alter table NSR_SUSPICION_SERVICE
  add constraint PK_NSR_SUSPICION_SERVICE primary key (ID)
  using index ;
create index INDEX_NSR_SUSPICION_SERVICE on NSR_SUSPICION_SERVICE (BT);

-- ============================================================
--   数据: NSR_SUSPICION_SERVICE
--   汉字名称: 初始化测试数据
--   创建日期：2010-8-27
--   修改日期：
--   修改内容：
-- ============================================================
insert into NSR_SUSPICION_SERVICE (ID, BT, SERVICEID, BZ) values (1, '增值税', 'UWPSJYPZ001', '增值税');
commit;

-- ============================================================
--   Table: FZXX_DM_LX
--   汉字名称: 类型代码表
--   创建日期：2009-2-9
--   修改日期：
--   修改内容：
-- ============================================================
create table FZXX_DM_LX
(
  LXDM VARCHAR2(10) not null,
  LXMC VARCHAR2(50) not null
);

-- Add comments to the columns
comment on column FZXX_DM_LX.LXDM
  is '类型代码';
comment on column FZXX_DM_LX.LXMC
  is '类型名称';
-- Create/Recreate primary, unique and foreign key constraints
alter table FZXX_DM_LX
  add constraint PK_FZXX_DM_LX primary key (LXDM);


-- ============================================================
--   Function: F_FZXX_GET_LXMC
--   汉字名称: 根据类型代码读取类型名称
--   创建日期：2009-2-9
--   修改日期：
--   修改内容：
-- ============================================================
create or replace function F_FZXX_GET_LXMC(ac_lxdm in varchar2)
return varchar2 is
ac_lxmc varchar2(50);
all_count number;
begin
    select count(*) into all_count from FZXX_DM_LX where LXDM=ac_lxdm;
    if (all_count=0) then
    return ac_lxmc;
    end if;
    select LXMC into ac_lxmc from FZXX_DM_LX where LXDM= ac_lxdm;
    return ac_lxmc;
end;
/


-- ============================================================
--   数据: FZXX_DM_LX
--   汉字名称: 初始化类型表数据
--   创建日期：2009-3-6
--   修改日期：
--   修改内容：
-- ============================================================
insert into FZXX_DM_LX (LXDM, LXMC) values ('05', '出口退税');
insert into FZXX_DM_LX (LXDM, LXMC) values ('01', '法律');
insert into FZXX_DM_LX (LXDM, LXMC) values ('02', '法规');
insert into FZXX_DM_LX (LXDM, LXMC) values ('04', '核心征管');
insert into FZXX_DM_LX (LXDM, LXMC) values ('03', '防伪税控');
insert into FZXX_DM_LX (LXDM, LXMC) values ('00', '其他');
commit;

-- ============================================================
--   Table: FZXX_XXGL
--   汉字名称: 信息管理表
--   创建日期：2009-2-9
--   修改日期：
--   修改内容：
-- ============================================================
create table FZXX_XXGL
(
  ID      NUMBER(20) not null,
  BT      VARCHAR2(50) not null,
  NR      VARCHAR2(4000) not null,
  GJZ     VARCHAR2(50) not null,
  LXDM      VARCHAR2(10) not null,
  LRSJ    DATE,
  FBSJ    DATE,
  JG      VARCHAR2(10),
  ZG      VARCHAR2(10),
  NH      NUMBER(10),
  WH      NUMBER(10),
  LRRID   VARCHAR2(11) not null,
  LRRDM   VARCHAR2(11) not null,
  LRRMC   VARCHAR2(20) not null,
  LRRJGDM VARCHAR2(15) not null,
  LRRJGMC VARCHAR2(60) not null
);
-- Add comments to the columns
comment on column FZXX_XXGL.ID
  is '序号';
comment on column FZXX_XXGL.BT
  is '标题';
comment on column FZXX_XXGL.NR
  is '内容';
comment on column FZXX_XXGL.GJZ
  is '关键字';
comment on column FZXX_XXGL.LXDM
  is '类型代码';
comment on column FZXX_XXGL.LRSJ
  is '录入时间';
comment on column FZXX_XXGL.FBSJ
  is '发布时间';
comment on column FZXX_XXGL.JG
  is '局轨';
comment on column FZXX_XXGL.ZG
  is '字轨';
comment on column FZXX_XXGL.NH
  is '年号';
comment on column FZXX_XXGL.WH
  is '文号';
comment on column FZXX_XXGL.LRRDM
  is '录入人ID';
comment on column FZXX_XXGL.LRRDM
  is '录入人代码';
comment on column FZXX_XXGL.LRRMC
  is '录入人名称';
comment on column FZXX_XXGL.LRRJGDM
  is '录入人机关代码';
comment on column FZXX_XXGL.LRRJGMC
  is '录入人机关名称';
-- Create/Recreate primary, unique and foreign key constraints
alter table FZXX_XXGL
  add constraint PK_FZXX_XXGL primary key (ID);
alter table FZXX_XXGL
  add constraint FK_FZXX_XXGL foreign key (LXDM)
  references FZXX_DM_LX (LXDM);
-- Create/Recreate indexes
create index INDEX_XXGL_GJZ on FZXX_XXGL (GJZ);

-- ============================================================
--   Sequence: SEQ_FZXX_XXGL
--   汉字名称: 信息管理序列
--   创建日期：2009-2-9
--   修改日期：
--   修改内容：
-- ============================================================
create sequence SEQ_FZXX_XXGL
minvalue 1
maxvalue 99999999
start with 1
increment by 1
cache 20
cycle;

-- ============================================================
--   Table: FZXX_FWGL
--   汉字名称: 服务管理表
--   创建日期：2009-2-9
--   修改日期：
--   修改内容：
-- ============================================================
create table FZXX_FWGL
(
  ID        NUMBER not null,
  BT        VARCHAR2(50) not null,
  URL       VARCHAR2(100) not null,
  LXDM      VARCHAR2(10) not null,
  SERVICEID VARCHAR2(20) not null,
  GJZ       VARCHAR2(50) not null,
  BZ        VARCHAR2(500) not null
);
-- Add comments to the columns
comment on column FZXX_FWGL.ID
  is 'ID';
comment on column FZXX_FWGL.BT
  is '标题';
comment on column FZXX_FWGL.URL
  is '显示页面的地址';
comment on column FZXX_FWGL.LXDM
  is '类型代码';
comment on column FZXX_FWGL.SERVICEID
  is '服务ID';
comment on column FZXX_FWGL.GJZ
  is '关键字';
comment on column FZXX_FWGL.BZ
  is '备注';
-- Create/Recreate primary, unique and foreign key constraints
alter table FZXX_FWGL
  add constraint PK_FWGL_ID primary key (ID)
  using index ;
alter table FZXX_FWGL
  add constraint FK_FZXXFWGL foreign key (LXDM)
  references FZXX_DM_LX (LXDM);
-- Create/Recreate indexes
create index INDEX_FWGL_GJZ on FZXX_FWGL (GJZ);
-- ============================================================
--   数据: FZXX_FWGL
--   汉字名称: 范例初始化数据
--   创建日期：2009-3-27
--   修改日期：
--   修改内容：
-- ============================================================
insert into FZXX_FWGL (ID, BT, URL, LXDM, SERVICEID, GJZ, BZ) values (1, '欠税信息', '../xslt/index.jsp', '04', 'UWPZHCXXX001', '增值税纳税申报', '欠税信息');
insert into FZXX_FWGL (ID, BT, URL, LXDM, SERVICEID, GJZ, BZ) values (2, '发票认证信息', '../xslt/index.jsp', '03', 'UWPZHCXXX002', '增值税纳税申报', '发票认证信息');
insert into FZXX_FWGL (ID, BT, URL, LXDM, SERVICEID, GJZ, BZ) values (3, '纳税人基本信息', '../xslt/index.jsp', '04', 'UWPZHCXXX003', '增值税纳税申报', '纳税人基本信息');
insert into FZXX_FWGL (ID, BT, URL, LXDM, SERVICEID, GJZ, BZ) values (4, '模拟测试', '../xslt/index.jsp', '00', 'UWPSJYPZ001', '增值税纳税申报', '测试WebService和EJB');
insert into FZXX_FWGL (ID, BT, URL, LXDM, SERVICEID, GJZ, BZ) values (5, '测试服务', '../xslt/index.jsp', '00', 'UWPSJYPZ001', '测试服务', '测试辅助信息服务');

commit;

begin
	P_ADD_ROOT('systemmanage','系统管理', 90);
	P_ADD_ML('系统管理','组织权限');
	P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.help','资源在线帮助','../portal/help/GnmkBndService.select.do','090000');
end;
/

commit;


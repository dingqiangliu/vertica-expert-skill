-- 创建表: 临时表编目录
create table XT_TEMPTABLECATALOG
(
  TABLENAME          VARCHAR(255) not null,
  CREATINGTIME       DATE not null,
  EXPIRINGTIME       DATE,
  CONNECTIONPOOLNAME VARCHAR(255)
)
;
alter table XT_TEMPTABLECATALOG
  add constraint PK_XT_TEMPTABLECATALOG primary key (TABLENAME);
create index IDX_XT_TEMPTABLECATALOG on XT_TEMPTABLECATALOG (CREATINGTIME, EXPIRINGTIME);

-- 创建表: 系统参数
create table XT_XTCS
(
  CSXH   VARCHAR(5) not null,
  JG_DM  VARCHAR(15) not null,
  CSMC   VARCHAR(80) not null,
  CSNR   VARCHAR(500) not null,
  SYSM   VARCHAR(200),
  XYBZ   CHAR(1) not null,
  JZSZBZ CHAR(1)
)
;
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
	values ('10002', 'PUBLIC', '密码规则正则表达式', '\d+', '用于校验用户修改密码时新密码组成规则 ("\d+"为全数字,禁止删除,设置值为0时为不限制)', 'Y', 'Y');
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10003', 'PUBLIC', '允许最大密码输入错误次数', '5', '在一段时间内用户可尝试的最大密码输入错误次数 (禁止删除,设置值为0时为不限制)', 'Y', 'Y');
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10004', 'PUBLIC', '密码输入错误连续重试限制时间', '30', '密码输入错误连续重试的限制时间,单位:分钟 (禁止删除,设置值为0时为不限制)', 'Y', 'Y');
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10005', 'PUBLIC', '达到最大密码输入错误次数后处理方式', '1', '1:指定时间后允许重试;2:锁定用户 (禁止删除,设置值为0时为不处理)', 'Y', 'Y');
insert into XT_XTCS (CSXH, JG_DM, CSMC, CSNR, SYSM, XYBZ, JZSZBZ)
	values ('10006', 'PUBLIC', '限制用户重试时间', '30', '用户达到最大密码输入错误次数后限制登录的时间段,单位:分钟 (禁止删除,设置值为0时为不限制)', 'Y', 'Y');

commit;insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
  values ('07', '工具项', 'Y', 'Y');

commit;

-- DM_YWHJ

 
-- 创建表: 业务环节代码
create table DM_YWHJ
(
  YWHJ_DM VARCHAR(6) not null,
  YWHJ_MC VARCHAR(80) not null,
  XYBZ    CHAR(1) not null,
  YXBZ    CHAR(1) not null
)
;
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
  SYSTEMNAME        VARCHAR(80) not null,
  DESCRIPTION       VARCHAR(50),
  ICONURL           VARCHAR(50),
  VIRTRULROOTNAME   VARCHAR(50),
  COOKIENAME        VARCHAR(50),
  REALROOTURL       VARCHAR(200),
  WELCOMETITTLE     VARCHAR(50),
  WELCOMEURL        VARCHAR(200),
  LOGINURL          VARCHAR(500),
  LOGINTYPE         VARCHAR(10) default 'U' not null,
  LOGOUTURL         VARCHAR(200),
  LOGOUTTYPE        VARCHAR(10) default 'U' not null,
  USERPARAMNAME     VARCHAR(50),
  PASSWORDPARAMNAME VARCHAR(50),
  LOGINSUCCESSTAG   VARCHAR(200) default ':CONSOLE:',
  TESTURL           VARCHAR(200),
  SORTORDER         VARCHAR(2) default '99' not null,
  XYBZ              VARCHAR(1) default 'Y' not null,
  YXBZ              VARCHAR(1) default 'Y' not null,
  BASEURL           VARCHAR(100) default '/ctais',
  LOGINTIME         VARCHAR(1) default 'S',
  SCRIPT            TEXT,
  SESSIONKEEP       VARCHAR(1) default 'Y',
  SESSIONKEEPTYPE   VARCHAR(10) default 'U',
  SESSIONKEEPURL    VARCHAR(500),
  UNIUSERTYPE       VARCHAR(10) default 'L',
  UNIUSERON         VARCHAR(1) default 'N',
  UNIUSERDATA       VARCHAR(200)
)
;
alter table QX_SYSTEM
  add primary key (SYSTEMNAME);

 
insert into QX_SYSTEM (SYSTEMNAME, DESCRIPTION, ICONURL, VIRTRULROOTNAME, COOKIENAME, REALROOTURL, WELCOMETITTLE, WELCOMEURL, LOGINURL, LOGINTYPE, LOGOUTURL, LOGOUTTYPE, USERPARAMNAME, PASSWORDPARAMNAME, LOGINSUCCESSTAG, TESTURL, SORTORDER, XYBZ, YXBZ, BASEURL, LOGINTIME, SCRIPT, SESSIONKEEP, SESSIONKEEPTYPE, SESSIONKEEPURL, UNIUSERTYPE, UNIUSERON, UNIUSERDATA)
  values ('系统管理', '系统管理', null, null, null, null, null, null, null, 'U', '../entry/loginOut?type=ipc&purpose=LogInService&module=Entry', 'U', null, null, ':CONSOLE:', null, '00', 'Y', 'Y', '/adp', 'F', null, 'Y', 'U', '../index.htm', 'L', 'N', null);
 
commit;

 
create table QX_SYSTEM_USER
(
  SYSTEMNAME VARCHAR(50) not null,
  USERID     VARCHAR(11) not null,
  NAME       VARCHAR(20),
  CZRY_MC    VARCHAR(60),
  LOGINNAME  VARCHAR(40) not null,
  PASSWORD   VARCHAR(40)
)
;
alter table QX_SYSTEM_USER
  add constraint QX_SYSTEM_USER_PK primary key (SYSTEMNAME, USERID);
create index IDX_QX_SYSTEM_USER_SYS on QX_SYSTEM_USER (SYSTEMNAME);
create index IDX_QX_SYSTEM_USER_USER on QX_SYSTEM_USER (USERID);

-- 创建表: 岗位
create table QX_GW
(
  GW_DM    VARCHAR(15) not null,
  GW_MC    VARCHAR(80) not null,
  GWLX     VARCHAR(2),
  YWBS     VARCHAR(5),
  SJ_GW_DM VARCHAR(15),
  QX_JG_DM VARCHAR(15) not null,
  JG_DM    VARCHAR(15) not null,
  YWHJ_DM  VARCHAR(6) not null
)
;
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
  GW_DM    VARCHAR(15) not null,
  QX_JG_DM VARCHAR(15) not null
)
;
alter table QX_GW_EX
  add constraint PK_QX_GW_EX primary key (GW_DM, QX_JG_DM);
create index IDX_QX_GW_EX_GW_DM on QX_GW_EX (GW_DM);

-- 创建表: 功能模板(角色)
create table QX_GNMB
(
  GNMB_DM  VARCHAR(11) not null,
  GNMB_MC  VARCHAR(80) not null,
  SS_GW_DM VARCHAR(15),
  JSSX_DM  VARCHAR(2) not null,
  JG_DM    VARCHAR(15) default '00000000000' not null,
  SFGXJS   CHAR(1) default 'N' not null
)
;
alter table QX_GNMB
  add constraint PK_QX_GNMB primary key (GNMB_DM);

insert into QX_GNMB (GNMB_DM, GNMB_MC, SS_GW_DM, JSSX_DM, JG_DM, SFGXJS)
  values ('00000000001', '超级管理员角色', null, '01', '000000000000000', 'N');

commit;

 
-- 创建表: 岗位角色（功能模板）
create table QX_GW_GNMB
(
  GW_DM   VARCHAR(15) not null,
  GNMB_DM VARCHAR(11) not null
)
;
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
  SYSTEMNAME   VARCHAR(50) not null,
  GW_DM        VARCHAR(15) not null,
  GW_MC        VARCHAR(100),
  SYSTEM_GW_DM VARCHAR(15) not null,
  SYSTEM_GW_MC VARCHAR(100)
)
;
alter table QX_SYSTEM_GW
  add constraint QX_SYSTEM_GW_PK primary key (SYSTEMNAME, GW_DM);

 
-- 创建表: 模块类型代码
create table DM_MKLX
(
  MKLX_DM VARCHAR(2) not null,
  MKLX_MC VARCHAR(20) not null,
  XYBZ    CHAR(1) default 'Y' not null,
  YXBZ    CHAR(1) default 'Y' not null
)
;
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
values ('10', 'web资源', 'Y', 'Y');
insert into DM_MKLX (MKLX_DM, MKLX_MC, XYBZ, YXBZ)
values ('11', '业务对象', 'Y', 'Y');

commit;


-- 创建表: 功能模块(资源)
create table QX_GNMK
(
  GNMK_DM    VARCHAR(256) not null,
  GNMK_HZMC  VARCHAR(80) default '功能模块' not null,
  GNMK_LJMC  VARCHAR(4000) not null,
  MKLX_DM    VARCHAR(2) default '00' not null,
  YWHJ_DM    VARCHAR(6) not null,
  CYBJ       CHAR(1),
  GZL_BZ     CHAR(1),
  CFDK       CHAR(1) default 'Y' not null,
  DKWZ       CHAR(1) default '0' not null,
  SHOWLEFT   CHAR(1) default 'Y' not null,
  SHOWTOP    CHAR(1) default 'Y' not null,
  SHOWINTREE CHAR(1) default 'Y' not null,
  SYSTEMNAME VARCHAR(80) default '系统管理' not null,
  YXBZ  CHAR(1) default 'Y' not null
)
;
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
  JD_DM    VARCHAR(21) not null,
  FJD_DM   VARCHAR(21) not null,
  JD_MC    VARCHAR(80) not null,
  GNMK_DM  VARCHAR(256),
  JDLX_DM  VARCHAR(2),
  JD_ORDER INT not null
)
;
alter table QX_GNMK_TREE
  add constraint PK_QX_GNMK_TREE primary key (JD_DM);
alter table QX_GNMK_TREE
  add constraint FK_QX_GNMK_TREE_GNMK_DM foreign key (GNMK_DM)
  references QX_GNMK (GNMK_DM);


insert into QX_GNMK_TREE (JD_DM, FJD_DM, JD_MC, GNMK_DM, JDLX_DM, JD_ORDER)
  values ('0', '0', '资源树', 'FFFFFFFFFFF', '0', 0);

commit;




 
-- 创建表: 功能模块帮助
create table HLP_GNMK
(
  ID        CHAR(40) not null,
  CZRY_DATE DATE  not null,
  CZRY_MC   VARCHAR(60),
  CZRY_DM   CHAR(11),
  KEYWORD   VARCHAR(2000),
  REMARK    VARCHAR(2000),
  GNMK_DM   VARCHAR(256),
  GNMK_HZMC VARCHAR(120),
  YWHJ_DM   CHAR(6),
  CONTENT   VARCHAR(4000),
  PATH      VARCHAR(256)
)
;
alter table HLP_GNMK
  add primary key (ID);

 
-- 创建表: 功能模块收藏
create table QX_FAV_GNMK
(
  USERID  VARCHAR(11) not null,
  GNMK_DM VARCHAR(256) not null,
  GW_DM   VARCHAR(15) not null,
  JD_MC   VARCHAR(80) not null
)
;
alter table QX_FAV_GNMK
  add constraint PK_QX_FAV_GNMK primary key (USERID, GW_DM, GNMK_DM);
create index IDX_QX_FAV_GNMK_USERID_ID on QX_FAV_GNMK (USERID);

 
-- 创建表: 
create table QX_JG_GNMK
(
  JG_DM   VARCHAR(15) not null,
  GNMK_DM VARCHAR(256) not null,
  SDATE   datetime not null,
  EDATE   datetime not null
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
  GNMB_DM  VARCHAR(11) not null,
  GNMK_DM  VARCHAR(256) not null,
  JD_DM    VARCHAR(21) not null,
  FJD_DM   VARCHAR(21) not null,
  JD_MC    VARCHAR(80) not null,
  JD_ORDER INT default 0 not null
)
;
alter table QX_GNMB_GNMK
  add constraint PK_QX_GNMB_GNMK primary key (GNMB_DM, GNMK_DM, JD_DM, FJD_DM);
alter table QX_GNMB_GNMK
  add constraint FK_QX_GNMB_GNMK_GNMB_DM foreign key (GNMB_DM)
  references QX_GNMB (GNMB_DM);
alter table QX_GNMB_GNMK
  add constraint FK_QX_GNMB_GNMK_GNMK_DM foreign key (GNMK_DM)
  references QX_GNMK (GNMK_DM);


-- 正在创建表     ---QX_GNMB_GNMK_OPERATION
create table QX_GNMB_GNMK_OPERATION
(
    GNMB_DM                         VARCHAR(11)                 not null comment '功能模板代码'     ,
    GNMK_DM                         VARCHAR(256)            not null comment '功能模块代码'      ,
    OPERATION_DM                    VARCHAR(128)            not null comment '操作代码'      ,
    constraint PK_QX_GNMB_GNMK_OPERATION primary key (GNMB_DM,GNMK_DM,OPERATION_DM),
    constraint FK_QX_GNMB_GNMK_O_GNMB_DM foreign key (GNMB_DM) references QX_GNMB (GNMB_DM) ON DELETE CASCADE,
    constraint FK_QX_GNMB_GNMK_O_GNMK_DM foreign key (GNMK_DM) references QX_GNMK (GNMK_DM) ON DELETE CASCADE
) comment '权限功能模板功能模块操作'
;

 
create table QX_GNMB_SX_JG
(
  GNMB_DM  VARCHAR(11) not null,
  JG_DM    VARCHAR(15) not null,
  QX_JG_DM VARCHAR(15) not null,
  GW_DM    VARCHAR(15) not null
)
;
alter table QX_GNMB_SX_JG
  add constraint PK_QX_GNMB_SX_JG primary key (GNMB_DM, JG_DM);
alter table QX_GNMB_SX_JG
  add constraint FK_QX_GNMB_SX_JG_GNMB_DM foreign key (GNMB_DM)
  references QX_GNMB (GNMB_DM);


-- 正在创建表     ---WSQCZCLFS
create table WSQCZCLFS
(
    WSQCZCLFS_DM                         VARCHAR(16)        default '00' not null comment '未授权操作处理方式代码',
    WSQCZCLFS_MC                         VARCHAR(256)       default '未授权操作方式' not null comment '未授权操作处理方式名称',
    YXBZ                                 CHAR(1)             default 'Y' not null comment '有效标志',
    XYBZ                                 CHAR(1)             default 'Y' not null comment '选用标志',
    constraint PK_WSQCZCLFS primary key (WSQCZCLFS_DM)
)
;


-- 正在创建表     ---QX_OPERATION
create table QX_OPERATION
(
    OPERATION_DM                         VARCHAR(128)            not null comment '操作代码'      ,
    OPERATION_MC                         VARCHAR(120)            default '操作' not null comment '操作名称'      ,
    GNMK_DM                              VARCHAR(256)            not null  comment '功能模块代码'     ,
    OPERATION_DESCRIPTION                VARCHAR(256) comment '操作描述'              ,
    YXBZ                                 char(1)                  default 'Y' not null comment '有效标志',
    WSQCZCLFS_DM                         VARCHAR(16)             default '00' not null comment '未授权操作处理方式代码',
    constraint PK_QX_OPERATION primary key (OPERATION_DM,GNMK_DM),
    constraint FK_QX_OPERATION_GNMK_DM foreign key (GNMK_DM) references QX_GNMK (GNMK_DM) ON DELETE CASCADE
) comment '操作'
;


delimiter //

 
 
-- 在mysql 里面由于 函数在参数没有out 类型 ， 所以改成 存储过程 
create  PROCEDURE P_GET_JDH( out ac_jdh  VARCHAR(20))
 comment '功能描述：取节点号
           输入参数：无
           输出参数：节点号'
begin
    select CSNR into ac_jdh from XT_XTCS where CSXH = '10001' and JG_DM='PUBLIC';
    if ac_jdh is null then
         set ac_jdh = "-1";     
    end if;

   
end;

//

CREATE FUNCTION P_GET_JD_DM(AC_FULL VARCHAR(255), AC_FLAG VARCHAR(1)) RETURNS VARCHAR(30)
BEGIN
	DECLARE LC_FULL VARCHAR(255);
    DECLARE LN_POS INT(10);
    DECLARE LC_JD_MC  VARCHAR(255);
    DECLARE LC_FJD_DM  VARCHAR(255);
    DECLARE LC_FJD_DM_VAR  VARCHAR(255);
    
    SET LC_FULL = AC_FULL;
    SET LC_FJD_DM_VAR = '0';
    LOOP
        SET LC_FJD_DM = LC_FJD_DM_VAR;
        SET LC_FJD_DM_VAR = NULL;
        
        SET LN_POS = INSTR(LC_FULL,'~');
        IF LN_POS=0 THEN
            SET LC_JD_MC = LC_FULL;
        ELSE
            SET LC_JD_MC=SUBSTR(LC_FULL,1,LN_POS-1);
            SET LC_FULL=SUBSTR(LC_FULL,LN_POS+1);
        END IF;
        
       BEGIN
       		-- TODO: 怎么抛异常？
        	DECLARE SQLERRM VARCHAR(255);
        	DECLARE MSG VARCHAR(70);
        	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING, NOT FOUND
            IF AC_FLAG='0' THEN
              SELECT JD_DM INTO LC_FJD_DM_VAR FROM QX_GNMK_TREE WHERE FJD_DM=LC_FJD_DM AND JD_MC=LC_JD_MC;
            ELSE
              SELECT JD_DM INTO LC_FJD_DM_VAR FROM QX_GNMB_GNMK WHERE FJD_DM=LC_FJD_DM AND JD_MC=LC_JD_MC AND GNMB_DM='00000000001';
         	END IF;
            SET SQLERRM=ERRORS;
            SET MSG = "error";
        END;
        IF (LN_POS=0) OR (LC_FJD_DM_VAR IS NULL) THEN
            RETURN LC_FJD_DM_VAR;
        END IF;
    END LOOP;
END;
//


-- P_GET_JD_NEW函数中由于字符串加1会导致变成科学计数法,导致主键重复  IF LENGTH(LN_ROW)> 12 THEN  这行

CREATE FUNCTION P_GET_JD_NEW(AC_FJD_DM VARCHAR(30),AC_JD_MC  VARCHAR(30),AC_FLAG VARCHAR(1)) RETURNS VARCHAR(30)
BEGIN
DECLARE LN_ROW    VARCHAR(30);
DECLARE LN_COUNT  INT(10);
DECLARE LN_ROW_TEMP1 VARCHAR(30);
DECLARE LN_ROW_TEMP2 VARCHAR(30);
DECLARE LN_ROW_TEMP3 VARCHAR(30);
  IF AC_FLAG = '0' THEN
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE JD_DM=AC_FJD_DM AND (JDLX_DM='01' OR JDLX_DM='0');
		IF LN_ROW<>1 THEN
			RETURN "";
		END IF;
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=AC_FJD_DM AND JD_MC=AC_JD_MC;
		IF LN_ROW>0 THEN
      RETURN "";
    END IF;

    IF LENGTH(AC_FJD_DM)>18 THEN
      SELECT MAX(JD_DM) INTO LN_ROW FROM QX_GNMK_TREE WHERE JD_DM>='0' AND JD_DM<='9';
      IF LENGTH(LN_ROW)> 12 THEN 
         set LN_ROW_TEMP1 = RIGHT(LN_ROW, 10);
				 set LN_ROW_TEMP2 = LN_ROW_TEMP1 + 1;
				 set LN_ROW_TEMP3 = SUBSTRING(LN_ROW,1,(LENGTH(LN_ROW)-10));
				 set LN_ROW = CONCAT(LN_ROW_TEMP3,LN_ROW_TEMP2);
      ELSE     
         set LN_ROW=LN_ROW+1;
      END IF;          
      RETURN LN_ROW;
    ELSE
      SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=AC_FJD_DM;
      IF LN_ROW IS NULL THEN
          SET LN_ROW='1';
      ELSEIF LN_ROW>=999 THEN
          SET LN_ROW=LN_ROW+1;
      END IF;

      SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMK_TREE WHERE JD_DM=CONCAT(AC_FJD_DM,LPAD(LN_ROW,3,'0'));
      WHILE LN_COUNT > 0 DO
          SET LN_ROW=LN_ROW+1;
          SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMK_TREE WHERE JD_DM=CONCAT(AC_FJD_DM,LPAD(LN_ROW,3,'0'));
      END WHILE;

      RETURN CONCAT(AC_FJD_DM,LPAD(LN_ROW,3,'0'));
    END IF;

  ELSE
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMB_GNMK WHERE JD_DM=AC_FJD_DM AND GNMK_DM='FFFFFFFFFFF' AND GNMB_DM='00000000001';

    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=AC_FJD_DM AND JD_MC=AC_JD_MC AND GNMB_DM='00000000001';

    IF LENGTH(AC_FJD_DM)>18 THEN
      SELECT MAX(JD_DM)+1 INTO LN_ROW FROM QX_GNMB_GNMK WHERE GNMB_DM='00000000001' AND JD_DM>='0' AND JD_DM<='9';
      RETURN LN_ROW;
    ELSE
      SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=AC_FJD_DM AND GNMB_DM='00000000001';
      IF LN_ROW IS NULL THEN
          SET LN_ROW=1;
      ELSEIF LN_ROW>=999 THEN
          SET LN_ROW=LN_ROW+1;
      END IF;

      SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMB_GNMK WHERE JD_DM=CONCAT(AC_FJD_DM,LPAD(LN_ROW,3,'0'));
      WHILE LN_COUNT > 0 DO
          SET LN_ROW=LN_ROW+1;
          SELECT COUNT(*) INTO LN_COUNT FROM QX_GNMB_GNMK WHERE JD_DM=CONCAT(AC_FJD_DM,LPAD(LN_ROW,3,'0'));
      END WHILE;

      RETURN CONCAT(AC_FJD_DM,LPAD(LN_ROW,3,'0'));
    END IF;
  END IF;
END;

//


CREATE TABLE `mocha_be_sequence` (
  `ID` BIGINT(20) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`ID`)

)
//

create  PROCEDURE P_SEQUENCE_STANDARD( out sequenceNo  VARCHAR(20),in sequenceName VARCHAR(20) )
  comment '功能描述：标准序列计算函数
           输入参数：序列名称
           输出参数：序列值'
begin
    DECLARE ac_jdh VARCHAR(10);
    DECLARE ac_no int; 
    select CSNR into ac_jdh from XT_XTCS where CSXH = '10001' and JG_DM='PUBLIC';
    if ac_jdh is null then
         set ac_jdh = "-1";     
         
    end if;
   INSERT INTO MOCHA_BE_SEQUENCE VALUES(NULL);
    SELECT LAST_INSERT_ID() into ac_no;
    
    set sequenceNo = CONCAT(ac_jdh,DATE_FORMAT(CURDATE(),'%y'),'9',lpad(CONCAT(ac_no),8,'0'),'000');
    
   
end;

//

CREATE  FUNCTION to_date(sdate varchar(24),stype varchar(24)) RETURNS DATE
 BEGIN
  return cast(sdate as date);
 END;
 
//

CREATE  FUNCTION to_number(num varchar(100)) RETURNS varchar(100)
 BEGIN
  return num;   
 END;
 
 //
 
-- 提供与ORACLE功能相同的用户自定义函数：RPAD
CREATE FUNCTION `rpad`(source VARCHAR(4000), len INTEGER, pad CHAR(1)) RETURNS VARCHAR(4000)
BEGIN
  IF length(source) < len then
    RETURN CONCAT(source, repeat(pad, len-length(source)));
  ELSE
  	RETURN source;
  END IF;
END;

//

CREATE PROCEDURE P_ADD_GNMK(AC_FULL VARCHAR(255),AC_GNMK CHAR(255),AC_HZMC VARCHAR(255),AC_LJMC VARCHAR(255),AC_YWHJ CHAR(255))
BEGIN
	DECLARE LC_FJD_DM  VARCHAR(30);
    DECLARE LC_JD_DM   VARCHAR(30);
    DECLARE LN_ROW     INT(10);

    BEGIN
        INSERT INTO QX_GNMK (GNMK_DM, GNMK_HZMC, GNMK_LJMC, MKLX_DM, YWHJ_DM, CYBJ) VALUES (AC_GNMK, AC_HZMC, AC_LJMC,'01', AC_YWHJ, 'N');
    END;

    IF AC_FULL IS NOT NULL THEN
        SET LC_FJD_DM=P_GET_JD_DM(AC_FULL,'0');
        SET LC_JD_DM=P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'0');
        SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_FJD_DM;
        IF LN_ROW IS NULL THEN
            SET LN_ROW=1;
        ELSE
            SET LN_ROW=LN_ROW+1;
        END IF;
        insert into QX_GNMK_TREE(JD_DM,FJD_DM,JD_MC,GNMK_DM,JDLX_DM,JD_ORDER)
        VALUES (LC_JD_DM,LC_FJD_DM,AC_HZMC, AC_GNMK,'02',LN_ROW);

        SET LC_FJD_DM=P_GET_JD_DM(AC_FULL,'1');
        SET LC_JD_DM=P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'1');
        SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=LC_FJD_DM AND GNMB_DM='00000000001';
        IF LN_ROW IS NULL THEN
            SET LN_ROW=1;
        ELSE
            SET LN_ROW=LN_ROW+1;
        END IF;
        INSERT INTO QX_GNMB_GNMK(GNMB_DM,JD_DM,FJD_DM,JD_MC,GNMK_DM,JD_ORDER)
        VALUES ('00000000001',LC_JD_DM,LC_FJD_DM,AC_HZMC,AC_GNMK,LN_ROW);
    END IF;
END;
//


CREATE PROCEDURE P_ADD_ML(
    AC_FULL VARCHAR(255),
    AC_HZMC VARCHAR(255)
)
BEGIN
	DECLARE LC_FJD_DM  VARCHAR(21);
    DECLARE LC_JD_DM   VARCHAR(21);
    DECLARE LN_ROW     INT(10);
    
    SET LC_FJD_DM=P_GET_JD_DM(AC_FULL,'0');
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_FJD_DM AND JD_MC=AC_HZMC; 
    IF LN_ROW=0 THEN
		BEGIN
			SET LC_JD_DM=P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'0');
			SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_FJD_DM;
			IF LN_ROW IS NULL THEN
				SET LN_ROW=1;
			ELSE
				SET LN_ROW=LN_ROW+1;
			END IF;
			INSERT INTO QX_GNMK_TREE(JD_DM,FJD_DM,JD_MC,GNMK_DM,JDLX_DM,JD_ORDER)
			VALUES (LC_JD_DM,LC_FJD_DM,AC_HZMC, 'FFFFFFFFFFF','01',LN_ROW);
		END;
    END IF;
    
	SET LC_FJD_DM=P_GET_JD_DM(AC_FULL,'1');
	SELECT COUNT(*) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=LC_FJD_DM AND JD_MC=AC_HZMC AND GNMB_DM='00000000001';
	IF LN_ROW=0 THEN
		BEGIN
			SET LC_JD_DM=P_GET_JD_NEW(LC_FJD_DM,AC_HZMC,'1');
			SELECT MAX(JD_ORDER) INTO LN_ROW FROM QX_GNMB_GNMK WHERE FJD_DM=LC_FJD_DM AND GNMB_DM='00000000001';
			IF LN_ROW IS NULL THEN
				SET LN_ROW=1;
			ELSE
				SET LN_ROW=LN_ROW+1;
			END IF;
			INSERT INTO QX_GNMB_GNMK(GNMB_DM,JD_DM,FJD_DM,JD_MC,GNMK_DM,JD_ORDER)
			VALUES ('00000000001',LC_JD_DM,LC_FJD_DM,AC_HZMC,'FFFFFFFFFFF',LN_ROW);
		END;
	END IF;    
END;
//


CREATE PROCEDURE P_DEL_GNMK(AC_GNMK  VARCHAR(255))
BEGIN
    DELETE FROM QX_GNMB_GNMK WHERE GNMK_DM = AC_GNMK;
    DELETE FROM QX_GNMK_TREE WHERE GNMK_DM = AC_GNMK;
    DELETE FROM QX_GNMK WHERE GNMK_DM = AC_GNMK;
END;
//

CREATE PROCEDURE P_DEL_ML(
    AC_FULL    VARCHAR(255),
    AC_HZMC    VARCHAR(255)
)
BEGIN
	DECLARE LC_JD_DM   VARCHAR(21);
    DECLARE LN_ROW     INT(10);
    SET LC_JD_DM=P_GET_JD_DM(CONCAT(AC_FULL,'~',AC_HZMC),'0');
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_JD_DM;
    IF LN_ROW = 0 THEN
    	DELETE FROM QX_GNMK_TREE WHERE JD_DM=LC_JD_DM;
	END IF;

    SET LC_JD_DM=P_GET_JD_DM(CONCAT(AC_FULL,'~',AC_HZMC),'1');
    SELECT COUNT(*) INTO LN_ROW FROM QX_GNMK_TREE WHERE FJD_DM=LC_JD_DM;
    IF LN_ROW = 0 THEN
    	DELETE FROM QX_GNMB_GNMK WHERE GNMB_DM='00000000001' AND JD_DM=LC_JD_DM;
	END IF;
END;
//

CREATE PROCEDURE P_ADD_ROOT(
    AC_JD_DM VARCHAR(255),
    AC_JD_MC VARCHAR(255),
    AC_JD_ORDER int(10)
)
BEGIN
    DECLARE LN_JD_ORDER  INT(10);
    DECLARE LN_COUNT     INT(10);
    
    IF AC_JD_ORDER is null THEN
        BEGIN
             SELECT MAX(JD_ORDER) INTO LN_JD_ORDER FROM QX_GNMK_TREE WHERE FJD_DM='0';
             IF LN_JD_ORDER IS NULL THEN
             		SET LN_JD_ORDER=1;
             ELSE
                SET LN_JD_ORDER=LN_JD_ORDER+1;
             END IF;
        END;
     ELSE 
        SET LN_JD_ORDER=AC_JD_ORDER;
     END IF;

     SELECT COUNT(JD_DM) INTO LN_COUNT FROM QX_GNMK_TREE WHERE JD_DM=AC_JD_DM;
     IF LN_COUNT =0 THEN
         INSERT INTO QX_GNMK_TREE(JD_DM,FJD_DM,JD_MC,GNMK_DM,JDLX_DM,JD_ORDER)  
         VALUES (AC_JD_DM, '0',AC_JD_MC,'FFFFFFFFFFF', '01', LN_JD_ORDER);
     END IF;
     
     SELECT COUNT(JD_DM) INTO LN_COUNT FROM QX_GNMB_GNMK WHERE JD_DM=AC_JD_DM;
     IF LN_COUNT =0 THEN
         INSERT INTO QX_GNMB_GNMK(GNMB_DM,GNMK_DM,JD_DM,FJD_DM,JD_MC,JD_ORDER)
         VALUES ('00000000001','FFFFFFFFFFF',AC_JD_DM,'0', AC_JD_MC, LN_JD_ORDER);
     END IF;
END;
//

CREATE PROCEDURE P_DEL_ROOT(
    AC_JD_DM VARCHAR(255)
)
BEGIN
	DECLARE LN_COUNT INT(10);
	
	SELECT COUNT(JD_DM) INTO LN_COUNT FROM QX_GNMK_TREE WHERE FJD_DM=AC_JD_DM;
	IF LN_COUNT =0 THEN
		DELETE FROM QX_GNMK_TREE WHERE JD_DM=AC_JD_DM;       
	END IF;
	
	SELECT COUNT(JD_DM) INTO LN_COUNT FROM QX_GNMB_GNMK WHERE FJD_DM=AC_JD_DM;
	IF LN_COUNT =0 THEN
		DELETE FROM QX_GNMB_GNMK WHERE JD_DM=AC_JD_DM AND GNMB_DM='00000000001';         
	END IF;
END;
//

delimiter ;

call P_ADD_ROOT('systemmanage','系统管理', 90);
call P_ADD_ML('系统管理','组织权限');
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.org','机构初始化','../security/org/zzjg.do?method=tree','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.org';
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.operator','操作人员初始化','../work/portal/csh_czry/CzrycshService.czrycsh2.do','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.operator';
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.reg','资源注册','../security/model/zyzc.do?method=queryList','000000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.resource.reg';
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.limitation','资源时效性','../work/portal/gnmksxx/GnmksxxBndService.getGnmksxxs.do','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.resource.limitation';
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.operation','操作注册','../security/operation/operation.do','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.resource.operation';
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.role','角色设置','../security/role/jssz.do?method=init','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.role';
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.position','岗位设置','../security/position/gwsz.do?method=gwszPageInit','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.position';
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.user','用户设置','../security/user/user.do','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.user';
commit;
-- 创建表: 单位隶属关系
create table DM_DWLSGX
(
  DWLSGX_DM VARCHAR(2) not null,
  DWLSGX_MC VARCHAR(16) not null,
  DWLSGX_SM VARCHAR(256),
  XYBZ      CHAR(1) default 'Y' not null,
  YXBZ      CHAR(1) default 'Y' not null
)
;

CREATE OR REPLACE VIEW V_DM_DWLSGX AS
SELECT DWLSGX_DM,DWLSGX_MC,XYBZ,YXBZ
FROM DM_DWLSGX
WHERE YXBZ='Y' AND XYBZ = 'Y'
;

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
  JG_DM     VARCHAR(15) not null,
  JG_MC     VARCHAR(80) not null,
  JG_JC     VARCHAR(50) not null,
  JG_BZ     CHAR(1) not null,
  SJ_JG_DM  VARCHAR(15) not null,
  DWLSGX_DM VARCHAR(2) not null,
  JG_JG     VARCHAR(10),
  JGYB      VARCHAR(6),
  JGDZ      VARCHAR(80),
  JGDH      VARCHAR(30),
  CZDH      VARCHAR(30),
  DYDZ      VARCHAR(50),
  XZQH_DM   VARCHAR(15),
  JGFZR_DM  VARCHAR(11),
  JBDM      VARCHAR(30) not null,
  JCDM      CHAR(1) not null,
  XYBZ      CHAR(1) default 'Y' not null,
  YXBZ      CHAR(1) default 'Y' not null
)
;
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
	JG_DM,
	JG_MC,
	JG_JC,
	JG_BZ,
	SJ_JG_DM,
	DWLSGX_DM,
	JG_JG,
	JGYB,
	JGDZ,
	JGDH,
	CZDH,
	DYDZ,
	XZQH_DM,
	JGFZR_DM,
	JBDM,
	JCDM,
	XYBZ,
	YXBZ
	from DM_JG
	where YXBZ = 'Y'
	and XYBZ = 'Y'
	order by JG_DM
;


CREATE OR REPLACE VIEW V_DM_BM AS
SELECT JG_DM,
JG_MC,
JG_JC,JG_BZ,SJ_JG_DM,DWLSGX_DM,JG_JG,JGYB,JGDZ,JGDH,CZDH,DYDZ,XZQH_DM,JGFZR_DM,JBDM,JCDM,XYBZ,YXBZ
  FROM DM_JG
 WHERE YXBZ='Y'
   AND XYBZ = 'Y'
   AND JG_BZ='B'
;


create table QX_JG_QXJG
(
  JG_DM    VARCHAR(15) not null,
  QX_JG_DM VARCHAR(15) not null
)
;
alter table QX_JG_QXJG
  add constraint PK_QX_JG_QXJG primary key (JG_DM);

-- 创建表: 操作人员
create table DM_CZRY
(
  CZRY_DM VARCHAR(11) not null,
  JG_DM   VARCHAR(15) not null,
  CZRY_MC VARCHAR(30) not null,
  XYBZ    CHAR(1) default 'Y' not null,
  YXBZ    CHAR(1) default 'Y' not null,
  ZJHM    VARCHAR(18),
  ADDRESS VARCHAR(80),
  DHHM    VARCHAR(30),
  SJHM    VARCHAR(30),
  EMAIL   VARCHAR(50)
)
;
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
  USERID    VARCHAR(11) not null,
  NAME      VARCHAR(30) not null,
  CZRY_DM   VARCHAR(11) not null,
  PASSWORD  VARCHAR(40) not null,
  KLLX      VARCHAR(2) not null,
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


insert into QX_USER (USERID, NAME, CZRY_DM, PASSWORD, KLLX, PWRQQ, PWRQZ, GRANTROLE)
  values ('00000000000', 'admin', '00000000000', 'M0hn9rFM+RSrf8iOFvT9+5U1AcXah/ecrLo/Mg==', '1 ', '2007-05-08', '2007-08-30', '0');

commit;


-- 创建表: 用户的岗位
create table QX_USER_GW
(
  USERID VARCHAR(11) not null,
  GW_DM  VARCHAR(15) not null
)
;
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



delimiter //

CREATE  FUNCTION ISYSZ (rydm varchar(20)) RETURNS varchar(1)
 BEGIN
   DECLARE   rynum int;
   select count(*) into rynum from qx_user u where u.czry_dm = rydm;
  if (rynum > 0) then
    return '1';
  else
    return '0';
  end if;
 END;
 
 //
 
delimiter ;



create or replace view v_dm_czry as
	select dm_czry.czry_dm,czry_mc,jg_dm,zjhm,address,dhhm,sjhm,email,isysz(dm_czry.czry_dm)as isysz,qx_user.userid as userid
	from dm_czry left join qx_user on dm_czry.czry_dm=qx_user.czry_dm
;

-- 创建表: 公共消息
create table MESSAGE_COMMON
(
  ID         VARCHAR(40) not null,
  QX_JG_DM   VARCHAR(15) not null,
  CZRY_MC    VARCHAR(60),
  CZRY_DM    VARCHAR(11) not null,
  CZ_DATE    DATE   not null,
  ISSUE_FLAG CHAR(1) default '0' not null,
  PRIORITY   CHAR(1) default '0' not null,
  CONTENT    VARCHAR(400)
)
;
alter table MESSAGE_COMMON
  add primary key (ID);

 
-- 创建表: 
create table MESSAGE_COMMON_OTM
(
  ID       VARCHAR(40) not null,
  QX_JG_DM VARCHAR(15) not null
)
;
alter table MESSAGE_COMMON_OTM
  add constraint PK_MESSAGE_COMMON_OTM primary key (ID, QX_JG_DM);
alter table MESSAGE_COMMON_OTM
  add constraint FK_MESSAGE_COMMON_OTM foreign key (ID)
  references MESSAGE_COMMON (ID);


insert into MESSAGE_COMMON (ID, QX_JG_DM, CZRY_MC, CZRY_DM, CZ_DATE, ISSUE_FLAG, PRIORITY, CONTENT)
   values ('8a8118e2-15a11f28-0115-a122ce44-0001', '000000000000000', 'ds_admin', '00000000000', '2007-10-08 09:47:12', '1', '0', '欢迎使用ADP应用开发平台，请尽快完成系统初始化工作。');
  
insert into MESSAGE_COMMON_OTM (ID, QX_JG_DM)
   values ('8a8118e2-15a11f28-0115-a122ce44-0001', '000000000000000');

commit;
call P_ADD_ROOT('systemmanage','系统管理', 90);
call P_ADD_ML('系统管理','系统初始化');
call P_ADD_GNMK('系统管理~系统初始化','message.common','公共消息维护','../work/message/common/index.jsp','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'message.common';
commit;create table print_template(
  templateId        VARCHAR(32)     not null     comment '模板ID',
  templateName      VARCHAR(100)    not null     comment '模板名称',
  templateVersion   int(10)         not null     comment '版本号',
  expiredDate       date            not null     comment '有效期',
  templateContent   longblob        not null     comment '模板内容',
  primary key (templateid)
);call P_ADD_ROOT('systemmanage','系统管理', 90);
call P_ADD_ML('系统管理','系统初始化');
call P_ADD_GNMK('系统管理~系统初始化','systemmanage.int.print','打印模板管理','../print/listPrintTemplate.iface','000000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.int.print';
commit;
 
-- 创建表: 处理状态代码
create table PI_DM_CLZT
(
  PI_CLZT_DM VARCHAR(2) not null,
  PI_CLZT_MC VARCHAR(20)
)
;
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
  PI_SJPD_DM VARCHAR(2) not null,
  PI_SJPD_MC VARCHAR(10) not null
)
;
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
  RWH      VARCHAR(20) not null,
  TITLE    VARCHAR(80) not null,
  GROUPID  VARCHAR(20) not null,
  YXJB     BIGINT not null,
  ZCYDSBZ  VARCHAR(1) not null,
  REDO     VARCHAR(1) not null,
  EXECUTOR VARCHAR(4000) not null
)
;
alter table PI_TASK
  add constraint PK_PI_TASK primary key (RWH);

 
-- 创建表: 任务组
create table PI_TASK_GROUP
(
  GROUPID VARCHAR(20) not null,
  GYXJB   BIGINT not null,
  GTITLE  VARCHAR(80) not null,
  YWHJ_DM VARCHAR(6) not null,
  LRR_DM  VARCHAR(11) not null,
  LRRQ    DATETIME not null
)
;
alter table PI_TASK_GROUP
  add constraint PK_PI_TASK_GROUP primary key (GROUPID);

 
-- 创建表: 任务调度
create table PI_TASK_SCHEDULE
(
  DDH        VARCHAR(20) not null,
  PH         VARCHAR(20) not null,
  RWH        VARCHAR(20) not null,
  SJXLH      VARCHAR(20),
  PI_CLZT_DM VARCHAR(2) not null,
  REDO       VARCHAR(1) not null,
  CLXX       VARCHAR(250),
  KSSJ       DATETIME,
  JSSJ       DATETIME,
  LRRQ       DATETIME not null,
  BZ         VARCHAR(200)
)
;
alter table PI_TASK_SCHEDULE
  add constraint PK_PI_TASK_SCHEDULE primary key (DDH);
create index IDX_PI_TASK_SCHEDULE on PI_TASK_SCHEDULE (SJXLH);

 
-- 创建表: 时间任务
create table PI_TIMER
(
  SJXLH         VARCHAR(20) not null,
  JS            VARCHAR(200) not null,
  DAYNO         BIGINT,
  TIMEOFDAY     VARCHAR(20),
  PI_SJPD_DM    VARCHAR(2),
  PD            BIGINT not null,
  STARTDATETIME DATETIME not null,
  PI_CLZT_DM    VARCHAR(2) not null,
  LRR_DM        VARCHAR(11) not null,
  LRRQ          DATETIME not null,
  SCZXSJ        DATETIME,
  XCZXSJ        DATETIME,
  ZZSJ          DATETIME
)
;
alter table PI_TIMER
  add constraint PK_PI_TIMER primary key (SJXLH);

 
-- 创建表: 时间任务与任务组
create table PI_TIMER_GROUP
(
  SJXLH   VARCHAR(20) not null,
  GROUPID VARCHAR(20) not null
)
;
alter table PI_TIMER_GROUP
  add constraint PK_PI_TIMER_GROUP primary key (SJXLH, GROUPID);

call P_ADD_ROOT('systemmanage','系统管理', 90);
call P_ADD_ML('系统管理','批处理');
call P_ADD_GNMK('系统管理~批处理','systemmanage.batch.jobgroup','任务组定义','../work/pi/rwzdy/RwzdyBndService.searchTaskGroup.do','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.batch.jobgroup';
call P_ADD_GNMK('系统管理~批处理','systemmanage.batch.timer','时间管理','../work/pi/sjgl/TimerdyBndService.initTimer.do','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.batch.timer';
call P_ADD_GNMK('系统管理~批处理','systemmanage.batch.console','调度监控','../work/pi/ddjk/index.jsp','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.batch.console';
commit;-- 创建表: 功能模块点击状态
create table MON_GNMK_CLICK
(
  USERID    VARCHAR(11) not null,
  GNMK_DM   VARCHAR(256) not null,
  STAT      int default 9999 not null,
  STAT_DATE DATE   not null
)
;
alter table MON_GNMK_CLICK
  add constraint PKMON_GNMK_CLICKMK_CLICK primary key (USERID, GNMK_DM);
call P_ADD_ROOT('systemmanage','系统管理', 90);
call P_ADD_ML('系统管理','监控管理');
call P_ADD_GNMK('系统管理~监控管理','systemmanage.monitoring.onlineusers','在线用户','../work/mon/user/SessionService.getOnlineUsers.do','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.monitoring.onlineusers';
call P_ADD_GNMK('系统管理~监控管理','systemmanage.monitoring.userlogs','在线用户历史','../work/mon/user/UserService.getOnlineUsersHistory.do','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.monitoring.userlogs';
-- 操作注册
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('00000000000', '过滤','systemmanage.monitoring.onlineusers', '');
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('00000000001', '刷新','systemmanage.monitoring.onlineusers', '');
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('00000000002', '踢出','systemmanage.monitoring.onlineusers', '');
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values ('00000000001', 'systemmanage.monitoring.onlineusers', '00000000000');
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values ('00000000001', 'systemmanage.monitoring.onlineusers', '00000000002');
commit; 
-- 创建表: 在线用户
create table MON_ONLINE_USER
(
  USERID      VARCHAR(20) not null,
  CZRY_MC     VARCHAR(30),
  CZRY_DM     VARCHAR(11),
  LOGIN_DATE  DATETIME   not null,
  LOGOUT_DATE DATETIME,
  JG_MC       VARCHAR(60),
  IP          VARCHAR(200),
  SESSIONID   VARCHAR(200),
  FLAG        CHAR(1) not null,
  JG_DM       VARCHAR(15),
  ID          VARCHAR(40) not null
)
;
alter table MON_ONLINE_USER
  add primary key (ID);
create index IDX_MON_ONLINE_USER_JG_DM on MON_ONLINE_USER (JG_DM);
create index IDX_MON_ONLINE_USER_LOGIN_DATE on MON_ONLINE_USER (LOGIN_DATE);
create index IDX_MON_ONLINE_USER_USERID on MON_ONLINE_USER (USERID);
create index IDX_MON_ONLINE_USER_USERID_ID on MON_ONLINE_USER (USERID, ID);

commit;
call  P_ADD_ROOT('systemmanage','系统管理', 90);
call	P_ADD_ML('系统管理','监控管理');
call	P_ADD_GNMK('系统管理~监控管理','adplogger','日志管理','../logger/index.iface','000000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'adplogger';

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
  ID       BIGINT(20) not null AUTO_INCREMENT,
  LOGTIME  TIMESTAMP,
  LOGCLASS VARCHAR(100),
  LOGLEVEL VARCHAR(5),
  LOGUSER  VARCHAR(20),
  MESSAGE  VARCHAR(3000),
  BUSIID  VARCHAR(50),
  EXPTID  VARCHAR(50),
  primary key (ID)
);

call P_ADD_ROOT('systemmanage','系统管理', 90);
call P_ADD_ML('系统管理','待办已办');
call P_ADD_GNMK('系统管理~待办已办','systemmanage.todo.setting','待办事宜设置','../work/message/dynacol/extDynacol.html','090000');
call P_ADD_GNMK('系统管理~待办已办','systemmanage.todo.dashboard','待办事宜','../work/message/main/index.jsp?type=1&gnmk_dm=systemmanage.todo.dashboard','090000');
call P_ADD_GNMK('系统管理~待办已办','systemmanage.done.dashboard','已办事宜','../work/message/main/index.jsp?type=2&gnmk_dm=systemmanage.done.dashboard','090000');

update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.todo.setting';
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.todo.dashboard';
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.done.dashboard';


-- 操作注册
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('filterByPriority', '按优先级过滤', 'systemmanage.todo.dashboard', '');
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM, OPERATION_DESCRIPTION) values ('filterByType', '按类型过滤', 'systemmanage.todo.dashboard', '');
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.todo.dashboard','filterByPriority');
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.todo.dashboard','filterByType');

insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM) values ('filterByPriority', '按优先级过滤', 'systemmanage.done.dashboard');
insert into QX_OPERATION (OPERATION_DM, OPERATION_MC, GNMK_DM) values ('filterByType', '按类型过滤', 'systemmanage.done.dashboard');
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.done.dashboard','filterByPriority');
insert into QX_GNMB_GNMK_OPERATION (GNMB_DM, GNMK_DM, OPERATION_DM) values('00000000001','systemmanage.done.dashboard','filterByType');
commit;

-- 创建表: 消息系统
create table MESSAGE_SYSTEM
(
  ID                    VARCHAR(4) not null,
  NAME                  VARCHAR(64) not null,
  KEY_NAME                   VARCHAR(16) not null,
  IS_LEGACY             CHAR(1) not null,
  HANDLER_CLASS         VARCHAR(256) not null,
  MAPPING_BUILDER_CLASS VARCHAR(256) not null,
  DESCRIPTION           VARCHAR(256),
  IS_ENABLED            CHAR(1) default 'Y' not null
)
;
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
  NAME VARCHAR(64) not null
)
;
 
    
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
  ID                VARCHAR(20) not null,
  SYSTEM_NAME       VARCHAR(50),
  MESSAGE_SYSTEM_ID VARCHAR(4),
  TOPIC             VARCHAR(512) not null,
  TOPIC_URL         VARCHAR(512),
  TYPE              CHAR(6),
  PRIORITY          CHAR(1),
  ALLOW_DELETE      CHAR(1),
  CREATE_TIME       DATE   not null,
  CREATED_BY        CHAR(11),
  LAST_RECEIVED_BY  CHAR(11),
  LAST_RECEIVE_TIME DATE,
  IS_ARCHIVED       CHAR(1) default 'N' not null,
  ARCHIVE_TIME      DATE,
  AVAILABLE_UNTIL   DATE,
  COMMENTS          VARCHAR(4000)
)
;
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
  NAME         VARCHAR(128) not null,
  IS_CUSTOM    CHAR(1) not null,
  CONTENT_TYPE CHAR(2),
  DESCRIPTION  VARCHAR(256)
)
;
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
  MESSAGE_ID        VARCHAR(20) not null,
  CUSTOM_FIELD_NAME VARCHAR(128) not null,
  FIELD_VALUE       VARCHAR(4000)
)
;
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
  USER_ID       VARCHAR(11) not null,
  FIELD_NAME    VARCHAR(128) not null,
  DISPLAY_ORDER INTEGER not null,
  DISPLAY_NAME  VARCHAR(128),
  WIDTH         VARCHAR(16),
  SORTORDER     VARCHAR(2),
  SORTDIRECTION  VARCHAR(2)
)
;
alter table MESSAGE_FIELD_DISPLAY
   add constraint PK_MESSAGE_FIELD_DISPLAY primary key (USER_ID, FIELD_NAME, DISPLAY_ORDER); 
alter table MESSAGE_FIELD_DISPLAY
  add constraint FK_MESSAGE_FIELD_DISPLAY foreign key (FIELD_NAME)
  references MESSAGE_FIELD_DEFINITION (NAME);

 
-- 创建表: 消息系统的消息字段
create table MESSAGE_SYSTEM_FIELD
(
  MESSAGE_SYSTEM_ID VARCHAR(4) not null,
  FIELD_NAME        VARCHAR(128) not null
)
;
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
  MESSAGE_SYSTEM_ID VARCHAR(4),
  FIELD_NAME        VARCHAR(128),
  LEGACY_TABLE_NAME VARCHAR(32) not null,
  LEGACY_FIELD_EXP  VARCHAR(256) not null
)
;
alter table MESSAGE_FIELD_MAPPING
  add constraint FK_MSG_FIELD_MAPPING_FN foreign key (FIELD_NAME)
  references MESSAGE_FIELD_DEFINITION (NAME);
alter table MESSAGE_FIELD_MAPPING
  add constraint FK_MSG_FIELD_MAPPING_ID foreign key (MESSAGE_SYSTEM_ID, FIELD_NAME)
  references MESSAGE_SYSTEM_FIELD (MESSAGE_SYSTEM_ID, FIELD_NAME);

 
-- 创建表: 消息字段渲染器
create table MESSAGE_FIELD_RENDER
(
  ID                VARCHAR(10),
  NAME              VARCHAR(32),
  MESSAGE_SYSTEM_ID VARCHAR(4),
  DESCRIPTION       VARCHAR(256),
  FIELD_NAME        VARCHAR(128),
  RENDER_CLASS      VARCHAR(256)
)
;
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
call P_ADD_ROOT('systemmanage','系统管理', 90);
call P_ADD_ML('系统管理','监控管理');
call P_ADD_GNMK('系统管理~监控管理','systemmanage.monitoring.track','跟踪','../track/index.jsp','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.monitoring.track';call P_ADD_ROOT('demo','范例', 99);
call P_ADD_ML('范例','查询框架');
call P_ADD_GNMK('范例~查询框架','demo.query.operatorquery','操作人员查询','../work/query/index.jsp?gnmk_dm=demo.query.operatorquery&queryid=test.test1&GZBZ=N','000000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'demo.query.operatorquery';
commit;
-- 创建表: 查询模块代码
create table DM_CXMK
(
  CXMK_DM  VARCHAR(6) not null,
  CXMK_MC  VARCHAR(50) not null,
  YM_RIGHT VARCHAR(50) not null,
  YM_TOP   VARCHAR(50) not null,
  XYBZ     CHAR(1) default 'Y' not null,
  YXBZ     CHAR(1) default 'Y' not null
)
;
alter table DM_CXMK
  add constraint PK_DM_CXMK primary key (CXMK_DM);


-- 创建表: 异步查询
create table CX_ASYNQUERY
(
  ASYNQUERYID VARCHAR(128) not null,
  QUERYID     VARCHAR(128) not null,
  CONDITION_NAME   VARCHAR(2000) not null,
  CACHETYPE   VARCHAR(20) default 'db' not null,
  QUERYTIME   DATE not null
)
;
  
alter table CX_ASYNQUERY
  add constraint PK_CX_ASYNQUERY primary key (ASYNQUERYID);

 
-- 创建表: 查询缓存
create table CX_CACHE
(
  QUERYID          VARCHAR(128) not null,
  CONDITION_NAME        VARCHAR(300) not null,
  CREATINGTIME     DATE not null,
  EXPIRINGTIME     DATE,
  DETAILRESULT     VARCHAR(255),
  DETAILRESULTSZIE BIGINT default 0,
  STATRESULT       VARCHAR(255),
  STATRESULTSZIE   BIGINT default 0,
  SUMRESULT        VARCHAR(255)
)
;
 
alter table CX_CACHE
  add constraint PK_CX_CACHE primary key (QUERYID, CONDITION_NAME);


create table QX_FAV_GNMK_TREE
(
  JD_DM    VARCHAR(21) not null comment '节点代码',
  FJD_DM   VARCHAR(21) not null comment '父节点代码',
  JD_MC    VARCHAR(80) not null comment '节点名称',
  GNMK_DM  VARCHAR(256) comment '功能模块代码',
  JDLX_DM  VARCHAR(2) comment '节点类型代码',
  JD_ORDER INT not null comment '节点顺序',
  USERID   VARCHAR(11) not null comment '用户ID',
  constraint PK_QX_FAV_GNMK_TREE primary key (JD_DM,USERID)
);

commit;call P_ADD_ROOT('systemmanage','系统管理', 90);
call P_ADD_ML('系统管理','组织权限');
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.system','业务系统注册','../portal/system/SystemBndService.ywxtzclist.do','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.system';
commit;create table DASHBOARD_TABINFO
(
   tabid                varchar(36) not null comment 'tabid',
   tabtype              varchar(15) not null comment 'tab类型 portal/table1/table2',
   userid               varchar(11)          comment 'userid',
   jsdm                 varchar(11)          comment '角色代码',
   tabtitle             varchar(50) not null comment 'tab页标题',
   tabcolumsnum         int not null comment 'tab页中内容列数',
   tabitemheight        int comment 'tab页中portlet高度',
   createtime           datetime comment '添加时间',
   primary key (tabid)
);

create table DASHBOARD_TABCONTENTINFO
(
   tabid                varchar(36) not null comment 'tabid',
   tabcontent           varchar(2000) comment 'tab页中内容',
   primary key (tabid)
);call P_ADD_ROOT('systemmanage','系统管理', 90);
call P_ADD_ML('系统管理','系统初始化');
call P_ADD_GNMK('系统管理~系统初始化','systemmanage.init.roleDashboard','角色主页管理','../dashboard/dashboard.jsp?dashboardType=role','000000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.init.roleDashboard';
commit;call P_ADD_ROOT('systemmanage','系统管理', 90);
call P_ADD_ML('系统管理','组织权限');
call P_ADD_GNMK('系统管理~组织权限','systemmanage.security.resource.help','资源在线帮助','../portal/help/GnmkBndService.select.do','090000');
update QX_GNMK set MKLX_DM = '05' where GNMK_DM = 'systemmanage.security.resource.help';
commit;

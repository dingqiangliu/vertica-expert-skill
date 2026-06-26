##############################################################################
# BTEQ script in Perl, generate by Script Wizard
#
# Date Time    : 2010-12-07
#
# Target Table : RECRM_IC_SUM_CUST			信用卡客户汇总表
#
# Source Table : RECRM_IC_ACCOUNT								信用卡客户帐户信息表   
#                RECRM_AVG_INCOME_PARA     
#                RDM_REF_CC_EXCHG_RATE_V				信用卡汇率信息（V）
#                RDM_REF_CURRENCY_COMPARE_CD_V	币种代码对照表        
#
# Script File  : recrm_ic_sum_cust0300.pl
#
# Author       : 
#
# Function     : 无
#
# remark       : 零售分池:信用卡客户帐户信息表
#
# Version      :
###############################################################################

use strict; # Declare using Perl strict syntax
use File::Basename;
use Cwd 'abs_path';

#
# If you are using other Perl's package, declare here'
#

######################################################################
# Variable Section
my $AUTO_HOME = $ENV{"AUTO_HOME"};

my $TXNDATE;

my $LOGON_STR;
my $LOGON_FILE = "${AUTO_HOME}/etc/LOGON_LDM";

my $SCRIPT = basename("$0");

######################################################################
# BTEQ function
sub run_bteq_command
{
   my $rc = open(BTEQ, "| bteq");

   # To see if bteq command invoke ok?
   unless ($rc) {
      print "Could not invoke BTEQ command\n";
      return -1;
   }

   ### Below are BTEQ scripts ###
   print BTEQ <<ENDOFINPUT;

${LOGON_STR}
--.LOGON xkdbc/dwpbscuser,dwpbscuser

.WIDTH 256

/*将T02_EXCHANGE_RATE_H替换为RDM_REF_CC_EXCHG_RATE_V 20101207*/
CREATE MULTISET VOLATILE TABLE VT_RDM_REF_CC_EXCHG_RATE_V,NO LOG
(  
    Middle_Rate DECIMAL(38,20)
    ,Contra_Currency_Cd CHAR(3) 
)
PRIMARY INDEX (Middle_Rate ,Contra_Currency_Cd)
;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;

/*插入临时表*/
INSERT INTO 
    VT_RDM_REF_CC_EXCHG_RATE_V
SELECT
    Middle_Rate
    ,Contra_Currency_Sign_Cd 
FROM 
    RECRM.RDM_REF_CC_EXCHG_RATE_V 
WHERE 
    Exchg_Rate_Type_Cd  = '10'         
AND  
    Currency_Sign_Cd = '156'              
AND   
    Start_Dt <= CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD')
AND  
    End_Dt > CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD') 
;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;

/*计算所有的相关金额*/
CREATE MULTISET VOLATILE TABLE VT_ALL_AMT, NO LOG
(             PARTY_ID            CHAR(32)
             ,CM_CUSTOMER_NMBR    VARCHAR(40)               --国际卡客户号
             ,LOAN_BAL            DECIMAL(18,2)             --贷款余额
             ,LOAN_BAL2           DECIMAL(18,2)             --贷款余额2
             ,CREDIT_LIMIT        DECIMAL(18,2)             --信用额度
             ,CM_CRLIMIT_PERM     DECIMAL(18,2)             --永久信用额度 add by xiongwei 2010-01-25
             ,CM_CRLIMIT_2        DECIMAL(18,2)             --观察期倒数第二个月月底的信用额度
             ,CM_CRLIMIT_3        DECIMAL(18,2)             --观察期倒数第3个月月底的信用额度
             ,CM_CRLIMIT_4        DECIMAL(18,2)             --观察期倒数第4个月月底的信用额度
             ,CM_CRLIMIT_5        DECIMAL(18,2)             --观察期倒数第5个月月底的信用额度
             ,CM_CRLIMIT_6        DECIMAL(18,2)             --观察期倒数第6个月月底的信用额度
             ,TAKE_CASH_BALANCE   DECIMAL(18,2)             --取现余额
             ,CONSUME_BALANCE     DECIMAL(18,2)             --消费余额
             ,MONTH_BALANCE       DECIMAL(18,2)             --月末余额
             ,SRC_DEBITS          DECIMAL(18,2)             --取现借记金额
             ,SRC_CREDITS         DECIMAL(18,2)             --取现贷记金额
             ,SRR_DEBITS          DECIMAL(18,2)             --消费借记金额
             ,SRR_CREDITS         DECIMAL(18,2)             --消费贷记金额
             ,SRR_BEG_BALANCE     DECIMAL(18,2)             --期初消费余额
             ,SRC_BEG_BALANCE     DECIMAL(18,2)             --期初取现余额
             ,LOW_PAYMENT_FEE     DECIMAL(18,2)             --最低还款额
             ,CM_INSTL_BAL        DECIMAL(18,2)             --分期余额
             ,CM_INSTL_LIMIT      DECIMAL(18,2)             --分期额度
             ,NUM_ACCT            DECIMAL(18,0)             --账户数目
             ,aActive             VARCHAR(30)               --是否活跃
             ,SR_CREDIT_LIMIT     DECIMAL(18,2)             --账单信用额度
             ,CM_CYCLE_DUE        VARCHAR(30)               --客户逾期状态
             ,rtl_deliquency      CHAR(1)                   --是否年费逾期
             ,rtl_default         CHAR(1)                   --是否年费违约
)
PRIMARY INDEX (CM_CUSTOMER_NMBR)
ON COMMIT PRESERVE ROWS;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;


/* MODIFY BEGIN BY WUXIN:2009-12-27 此段为了保证程序的扩展性，修改了部分CASE WHEN判断逻辑 */
INSERT INTO VT_ALL_AMT
    (
              PARTY_ID
             ,CM_CUSTOMER_NMBR                              --国际卡客户号
             ,LOAN_BAL                                      --贷款余额
             ,LOAN_BAL2                                     --贷款余额2
             ,CREDIT_LIMIT                                  --信用额度
             ,CM_CRLIMIT_PERM                               --永久信用额度 add by xiongwei 2010-01-25
             ,CM_CRLIMIT_2                                  --观察期倒数第二个月月底的信用额度
             ,CM_CRLIMIT_3                                  --观察期倒数第3个月月底的信用额度
             ,CM_CRLIMIT_4                                  --观察期倒数第4个月月底的信用额度
             ,CM_CRLIMIT_5                                  --观察期倒数第5个月月底的信用额度
             ,CM_CRLIMIT_6                                  --观察期倒数第6个月月底的信用额度
             ,TAKE_CASH_BALANCE                             --取现余额
             ,CONSUME_BALANCE                               --消费余额
             ,MONTH_BALANCE                                 --月末余额
             ,SRC_DEBITS                                    --取现借记金额
             ,SRC_CREDITS                                   --取现贷记金额
             ,SRR_DEBITS                                    --消费借记金额
             ,SRR_CREDITS                                   --消费贷记金额
             ,SRR_BEG_BALANCE                               --期初消费余额
             ,SRC_BEG_BALANCE                               --期初取现余额
             ,low_payment_fee                               --最低还款额
             ,CM_INSTL_BAL                                  --分期余额
             ,CM_INSTL_LIMIT                                --分期额度
             ,NUM_ACCT                                      --账户数目
             ,aActive                                       --是否活跃
             ,SR_CREDIT_LIMIT                               --账单信用额度
             ,CM_CYCLE_DUE                                  --客户逾期状态
             ,rtl_deliquency                                --是否年费逾期
             ,rtl_default                                    --是否年费违约
    )
SELECT
      MAX(A1.PARTY_ID)
         ,A1.CM_CUSTOMER_NMBR                                           --国际卡客户号
--         ,sum(
--                    case
--                            when trim(A1.CM_ORG_NMBR) ='168' 
--                            then cast((A1.SRR_CURR_BALANCE + A1.SRC_CURR_BALANCE)* (COALESCE(A15.Middle_Rate,1)) AS DECIMAL(18,2))
--                    else (A1.SRR_CURR_BALANCE + A1.SRC_CURR_BALANCE)
--          END)
    ,SUM(
               CASE
                       WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                       THEN (A1.SRR_CURR_BALANCE + A1.SRC_CURR_BALANCE)
               ELSE CAST((A1.SRR_CURR_BALANCE + A1.SRC_CURR_BALANCE)* (COALESCE(A15.Middle_Rate,1)) AS DECIMAL(18,2))
     END)                                                                                                                          --贷款余额
--         ,sum(
--              case
--                  when trim(A1.CM_ORG_NMBR) ='168' 
--                  then cast(A1.loan_bal2* (COALESCE(A15.Middle_Rate,1)) AS DECIMAL(18,2))
--                  else A1.loan_bal2
--          END)                                                                      --贷款余额2
    ,SUM(
         CASE
             WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
             THEN A1.loan_bal2
             ELSE CAST(A1.loan_bal2* (COALESCE(A15.Middle_Rate,1)) AS DECIMAL(18,2))
     END)
    ,MAX(
               CASE
                   WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                   THEN A1.CM_CRLIMIT
               ELSE  0
     END)
    ,MAX(
               CASE
                   WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                   THEN A1.CM_CRLIMIT_PERM
               ELSE  0
     END)                                                                                                                                                 --信用额度
--         ,max(
--                    case
--                        when trim(A1.CM_ORG_NMBR) ='168' 
--                        then cast(A1.CM_CRLIMIT_2 * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                    else A1.CM_CRLIMIT_2
--           END)
    ,MAX(
              CASE
                  WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                  THEN A1.CM_CRLIMIT_2
              ELSE CAST(A1.CM_CRLIMIT_2 * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
     END)                                                                                                                            --观察期倒数第二个月月底的信用额度
--     ,max(
--        case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.CM_CRLIMIT_3* (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--            else A1.CM_CRLIMIT_3
--        END)
    ,MAX(
              CASE
                  WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                  THEN A1.CM_CRLIMIT_3
              ELSE CAST(A1.CM_CRLIMIT_3 * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
     END)                                                                                                                                         --观察期倒数第3个月月底的信用额度
--     ,max(
--                case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.CM_CRLIMIT_4* (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--            else A1.CM_CRLIMIT_4
--        END)
    ,MAX(
              CASE
                  WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                  THEN A1.CM_CRLIMIT_4
              ELSE CAST(A1.CM_CRLIMIT_4 * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
     END)                                                                                                                                       --观察期倒数第4个月月底的信用额度
--     ,max(
--                 case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.CM_CRLIMIT_5 * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                else A1.CM_CRLIMIT_5
--        END)                                                --观察期倒数第5个月月底的信用额度
    ,MAX(
              CASE
                  WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                  THEN A1.CM_CRLIMIT_5
              ELSE CAST(A1.CM_CRLIMIT_5 * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
     END)
--     ,max(
--               case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.CM_CRLIMIT_6 * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                else A1.CM_CRLIMIT_6
--        END)                                                --观察期倒数第6个月月底的信用额度
    ,MAX(
              CASE
                  WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                  THEN A1.CM_CRLIMIT_6
              ELSE CAST(A1.CM_CRLIMIT_6 * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
     END)
--     ,sum(
--                 case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.SRC_CURR_BALANCE * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                else A1.SRC_CURR_BALANCE
--        END)
     ,SUM(
                 CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                THEN A1.SRC_CURR_BALANCE
                ELSE CAST(A1.SRC_CURR_BALANCE * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
        END)                                                   --取现余额
--     ,sum(
--                case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.SRR_CURR_BALANCE * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--            else A1.SRR_CURR_BALANCE
--        END)                             --消费余额
     ,SUM(
                CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                THEN A1.SRR_CURR_BALANCE
            ELSE CAST(A1.SRR_CURR_BALANCE * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
        END)                             --消费余额
--     ,sum(
--                case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.month_balance * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                else A1.month_balance
--        END)                                      --月末余额
     ,SUM(
                CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                THEN A1.month_balance
                ELSE CAST(A1.month_balance * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
        END)                                      --月末余额
--     ,sum(
--                case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.SRC_DEBITS * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                else A1.SRC_DEBITS
--        END)                                        --取现借记金额
     ,SUM(
                CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                THEN A1.SRC_DEBITS
                ELSE CAST(A1.SRC_DEBITS * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
        END)                                        --取现借记金额
--     ,sum(
--                case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.SRC_CREDITS * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--            else A1.SRC_CREDITS
--        END)                                        --取现贷记金额
     ,SUM(
                CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                THEN A1.SRC_CREDITS
            ELSE CAST(A1.SRC_CREDITS * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
        END)                                        --取现贷记金额
--     ,sum(
--                case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.SRR_DEBITS * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                else A1.SRR_DEBITS
--        END)                                        --消费借记金额
     ,SUM(
                CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                THEN A1.SRR_DEBITS
                ELSE CAST(A1.SRR_DEBITS * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
        END)                                        --消费借记金额
--     ,sum(
--                case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.SRR_CREDITS * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                else A1.SRR_CREDITS
--        END)                                --消费贷记金额
     ,SUM(
                CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                THEN A1.SRR_CREDITS
                ELSE CAST(A1.SRR_CREDITS * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
        END)                                --消费贷记金额
--     ,sum(
--                case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.SRR_BEG_BALANCE * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                else A1.SRR_BEG_BALANCE
--        END)                                --期初消费余额
     ,SUM(
                CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                THEN A1.SRR_BEG_BALANCE
                ELSE CAST(A1.SRR_BEG_BALANCE * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
        END)                                --期初消费余额
--     ,sum(
--                case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.SRC_BEG_BALANCE * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                else A1.SRC_BEG_BALANCE
--        END)                            --期初取现余额
     ,SUM(
                CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                THEN A1.SRC_BEG_BALANCE
                ELSE CAST(A1.SRC_BEG_BALANCE * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
        END)                            --期初取现余额
--     ,sum(
--                case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.SR_CURR_PYMT_DUE * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                else A1.SR_CURR_PYMT_DUE
--        END)                                --最低还款额
     ,SUM(
                CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                THEN A1.SR_CURR_PYMT_DUE
                ELSE CAST(A1.SR_CURR_PYMT_DUE * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
        END)                                --最低还款额
--     ,sum(
--                case
--                when trim(A1.CM_ORG_NMBR) ='168' 
--                then cast(A1.CM_INSTL_BAL  * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
--                else A1.CM_INSTL_BAL
--        END)                                   --分期余额
     ,SUM(
          CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
                THEN A1.CM_INSTL_BAL
                ELSE CAST(A1.CM_INSTL_BAL  * (COALESCE(A15.Middle_Rate,1))AS DECIMAL(18,2))
          END)                                   --分期余额
     ,MAX(
      CASE
            WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
            THEN A1.CM_INSTL_LIMIT
            ELSE 0
      END)                              --分期额度  额度只取人民币,不必转美元 ,而且只取最大的.
     ,COUNT(CASE WHEN TRIM(A1.CM_ORG_NMBR) ='169' 
              THEN 1
              ELSE 0
            END)                        --账户数目
      ,MAX(CASE
            WHEN A1.SRR_DEBITS IS NULL
             AND A1.SRC_DEBITS IS NULL
             AND A1.SRR_CREDITS IS NULL
             AND A1.SRC_CREDITS IS NULL
             AND A1.SRC_CURR_BALANCE IS NULL
             AND A1.SRR_CURR_BALANCE IS NULL    THEN NULL
           WHEN A1.SRR_DEBITS + A1.SRC_DEBITS > 0                                    --消费借记金额 + 取现借记金额
             OR A1.SRR_CREDITS + A1.SRC_CREDITS >0
             OR A1.SRC_CURR_BALANCE + A1.SRR_CURR_BALANCE > 0
           THEN '1'
           ELSE '0'
           END)                                                                                                     --是否活跃
      ,MAX(
            CASE
                WHEN TRIM(A1.CM_ORG_NMBR) ='169' THEN A1.SR_CREDIT_LIMIT
                ELSE 0
            END
         )             --账单信用额度
       ,MAX(CM_CYCLE_DUE)    --客户逾期状态
       ,MAX(rtl_deliquency)                                     --是否年费逾期
       ,MAX(rtl_default)                                        --是否年费违约

FROM
             RECRM.RECRM_IC_ACCOUNT A1
LEFT JOIN
--        RECRM.T98_CURRENCY_CD_REF A2     --modify 20101207
     RECRM.RDM_REF_CURRENCY_COMPARE_CD_V A2
ON
     A1.CM_ORG_NMBR = A2.Original_Currency_Cd
AND  
     A2.Original_Currency_Cd <> '169'
LEFT JOIN
--    VT_T02_EXCHANGE_RATE_H A15                       /*upd-100814 优化脚本修改语句*/
    VT_RDM_REF_CC_EXCHG_RATE_V A15    --modify 20101207
ON   
    A2.Currency_Cd = A15.Contra_Currency_Cd 
-- upd-100814 优化脚本删除语句 start    
--    RECRM.T02_EXCHANGE_RATE_H A15
----ON (case
----        when trim(A1.CM_ORG_NMBR) ='169' then '156'
----        when trim(A1.CM_ORG_NMBR) ='168' then '840'
----         END)  = A15.Contra_Currency_Cd
----and  A15.Exch_rate_Type_Cd  = '05'
--ON
--     A2.Currency_Cd = A15.Contra_Currency_Cd
--AND  A15.Exch_rate_Type_Cd  = '10'                  /* MODIFY BEGIN BY WUXIN:2009-12-27 取国际卡个人卡汇率Exch_rate_Type_Cd  = '11'  */
--
--and  A15.Currency_Cd = '156'
--and   A15.Start_Date <= CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD')
--and   A15.End_Date > CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD')
--upd-100814 优化脚本删除语句 end
WHERE  
    A1.REPORT_DATE =CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD')
GROUP BY  
    A1.CM_CUSTOMER_NMBR
;
 .IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;


 /*计算客户的状态 */
 CREATE MULTISET VOLATILE TABLE VT_ACCT_STATUS, NO LOG
(
     CM_CUSTOMER_NMBR    VARCHAR(40)                     --国际卡客户号
      ,acct_before_1_status        VARCHAR(30)    -- 前1期账户中最差的状态
      ,acct_before_2_status        VARCHAR(30)    -- 前2期账户中最差的状态
      ,acct_before_3_status        VARCHAR(30)    -- 前3期账户中最差的状态
      ,acct_before_4_status        VARCHAR(30)    -- 前4期账户中最差的状态
      ,acct_before_5_status        VARCHAR(30)    -- 前5期账户中最差的状态
      ,acct_before_6_status        VARCHAR(30)    -- 前6期账户中最差的状态
      ,acct_before_7_status        VARCHAR(30)    -- 前7期账户中最差的状态
      ,acct_before_8_status        VARCHAR(30)    -- 前8期账户中最差的状态
      ,acct_before_9_status        VARCHAR(30)    -- 前9期账户中最差的状态
      ,acct_before_10_status       VARCHAR(30)    -- 前10期账户中最差的状态
      ,acct_before_11_status       VARCHAR(30)    -- 前11期账户中最差的状态
      ,acct_before_12_status       VARCHAR(30)    -- 前12期账户中最差的状态
 ) PRIMARY INDEX (CM_CUSTOMER_NMBR)
ON COMMIT PRESERVE ROWS;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;

INSERT INTO VT_ACCT_STATUS
(
     CM_CUSTOMER_NMBR                               -- 国际卡客户号
      ,ACCT_BEFORE_1_STATUS                       -- 前1期账户中最差的状态
      ,ACCT_BEFORE_2_STATUS                       -- 前2期账户中最差的状态
      ,ACCT_BEFORE_3_STATUS                       -- 前3期账户中最差的状态
      ,ACCT_BEFORE_4_STATUS                       -- 前4期账户中最差的状态
      ,ACCT_BEFORE_5_STATUS                       -- 前5期账户中最差的状态
      ,ACCT_BEFORE_6_STATUS                       -- 前6期账户中最差的状态
      ,ACCT_BEFORE_7_STATUS                       -- 前7期账户中最差的状态
      ,ACCT_BEFORE_8_STATUS                       -- 前8期账户中最差的状态
      ,ACCT_BEFORE_9_STATUS                       -- 前9期账户中最差的状态
      ,ACCT_BEFORE_10_STATUS                      -- 前10期账户中最差的状态
      ,ACCT_BEFORE_11_STATUS                      -- 前11期账户中最差的状态
      ,ACCT_BEFORE_12_STATUS                      -- 前12期账户中最差的状态
 )
 SELECT
      A1.CM_CUSTOMER_NMBR
    ,MAX(CASE
       WHEN
                  A1.Acct_Before_1_Status = 'B'
         THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.Acct_Before_1_Status = '0'
         THEN '-2'
       WHEN
                  A1.Acct_Before_1_Status = 'Z'
         THEN '-1'                          /*CJZ 20090808*/
        ELSE  A1.Acct_Before_1_Status   END)
    ,MAX(CASE
       WHEN
                  A1.Acct_Before_2_Status = 'B'
        THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.Acct_Before_2_Status = '0'
         THEN '-2'
       WHEN
                  A1.Acct_Before_2_Status = 'Z'
          THEN '-1'                          /*CJZ 20090808*/
        ELSE  A1.Acct_Before_2_Status   END)
    ,MAX(CASE
       WHEN
                  A1.Acct_Before_3_Status = 'B'
         THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.Acct_Before_3_Status = '0'
         THEN '-2'
       WHEN
                  A1.Acct_Before_3_Status = 'Z'
          THEN '-1'                          /*CJZ 20090808*/
        ELSE  A1.Acct_Before_3_Status   END)
    ,MAX(CASE
       WHEN
                  A1.Acct_Before_4_Status = 'B'
         THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.Acct_Before_4_Status = '0'
         THEN '-2'
       WHEN
                  A1.Acct_Before_4_Status = 'Z'
          THEN '-1'                          /*CJZ 20090808*/
        ELSE  A1.Acct_Before_4_Status   END)
    ,MAX(CASE
       WHEN
                  A1.Acct_Before_5_Status = 'B'
         THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.Acct_Before_5_Status = '0'
         THEN '-2'
       WHEN
                  A1.Acct_Before_5_Status = 'Z'
          THEN '-1'                          /*CJZ 20090808*/
        ELSE  A1.Acct_Before_5_Status   END)
    ,MAX(CASE
       WHEN
                  A1.Acct_Before_6_Status = 'B'
         THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.Acct_Before_6_Status = '0'
         THEN '-2'
       WHEN
                  A1.Acct_Before_6_Status = 'Z'
          THEN '-1'                          /*CJZ 20090808*/
        ELSE  A1.Acct_Before_6_Status   END)
    ,MAX(CASE
       WHEN
                  A1.Acct_Before_7_Status = 'B'
         THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.Acct_Before_7_Status = '0'
         THEN '-2'
       WHEN
                  A1.Acct_Before_7_Status = 'Z'
          THEN '-1'                          /*CJZ 20090808*/
        ELSE  A1.Acct_Before_7_Status   END)
    ,MAX(CASE
       WHEN
                  A1.Acct_Before_8_Status = 'B'
         THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.Acct_Before_8_Status = '0'
         THEN '-2'
       WHEN
                  A1.Acct_Before_8_Status = 'Z'
          THEN '-1'                          /*CJZ 20090808*/
        ELSE  A1.Acct_Before_8_Status   END)
    ,MAX(CASE
       WHEN
                  A1.Acct_Before_9_Status = 'B'
         THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.Acct_Before_9_Status = '0'
         THEN '-2'
       WHEN
                  A1.Acct_Before_9_Status = 'Z'
          THEN '-1'                          /*CJZ 20090808*/
        ELSE  A1.Acct_Before_9_Status   END)
    ,MAX(CASE
       WHEN
                  A1.Acct_Before_10_Status = 'B'
         THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.Acct_Before_10_Status = '0'
         THEN '-2'
       WHEN
                  A1.Acct_Before_10_Status = 'Z'
          THEN '-1'                          /*CJZ 20090808*/
        ELSE  A1.Acct_Before_10_Status   END)
    ,MAX(CASE
       WHEN
                  A1.Acct_Before_11_Status = 'B'
         THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.Acct_Before_11_Status = '0'
         THEN '-2'
       WHEN
                  A1.Acct_Before_11_Status = 'Z'
          THEN '-1'                          /*CJZ 20090808*/
        ELSE  A1.Acct_Before_11_Status   END)
   ,MAX(CASE
       WHEN
                  A1.Acct_Before_12_Status = 'B'
         THEN '-3'                          /*CJZ 20090808*/
       WHEN
                  A1.acct_before_12_status = '0'
         THEN '-2'
       WHEN
                  A1.acct_before_12_status = 'Z'
          THEN '-1'                          /*CJZ 20090808*/
       ELSE  A1.acct_before_12_status   END)
 FROM
   RECRM.RECRM_IC_ACCOUNT A1
  WHERE  A1.REPORT_DATE =CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD')
  GROUP BY 1
  ;
 .IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;

 /*计算客户最差逾期状态*/
 CREATE MULTISET VOLATILE TABLE VT_on_overdue_cd, NO LOG
(
   CM_CUSTOMER_NMBR    VARCHAR(40)                    --国际卡客户号
    ,on_overdue_cd        VARCHAR(30)                   --开户6个月内最差逾期状态

 ) PRIMARY INDEX (CM_CUSTOMER_NMBR)
ON COMMIT PRESERVE ROWS;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;

INSERT INTO VT_on_overdue_cd
(
                       CM_CUSTOMER_NMBR                               --国际卡客户号
                        ,on_overdue_cd                                      --开户6个月内最差逾期状态
  ) SELECT
            CM_CUSTOMER_NMBR
             ,(CASE
                    WHEN ACCT_BEFORE_1_STATUS >= ACCT_BEFORE_2_STATUS
                    AND  ACCT_BEFORE_1_STATUS >= ACCT_BEFORE_3_STATUS
                    AND  ACCT_BEFORE_1_STATUS >= ACCT_BEFORE_4_STATUS
                    AND  ACCT_BEFORE_1_STATUS >= ACCT_BEFORE_5_STATUS
                    AND  ACCT_BEFORE_1_STATUS >= ACCT_BEFORE_6_STATUS
                    THEN  ACCT_BEFORE_1_STATUS
                    WHEN ACCT_BEFORE_2_STATUS >= ACCT_BEFORE_1_STATUS
                    AND  ACCT_BEFORE_2_STATUS >= ACCT_BEFORE_3_STATUS
                    AND  ACCT_BEFORE_2_STATUS >= ACCT_BEFORE_4_STATUS
                    AND  ACCT_BEFORE_2_STATUS >= ACCT_BEFORE_5_STATUS
                    AND  ACCT_BEFORE_2_STATUS >= ACCT_BEFORE_6_STATUS
                    THEN  ACCT_BEFORE_2_STATUS
                    WHEN ACCT_BEFORE_3_STATUS >= ACCT_BEFORE_2_STATUS
                    AND  ACCT_BEFORE_3_STATUS >= ACCT_BEFORE_1_STATUS
                    AND  ACCT_BEFORE_3_STATUS >= ACCT_BEFORE_4_STATUS
                    AND  ACCT_BEFORE_3_STATUS >= ACCT_BEFORE_5_STATUS
                    AND  ACCT_BEFORE_3_STATUS >= ACCT_BEFORE_6_STATUS
                    THEN  ACCT_BEFORE_3_STATUS
                    WHEN ACCT_BEFORE_4_STATUS >= ACCT_BEFORE_2_STATUS
                    AND  ACCT_BEFORE_4_STATUS >= ACCT_BEFORE_3_STATUS
                    AND  ACCT_BEFORE_4_STATUS >= ACCT_BEFORE_1_STATUS
                    AND  ACCT_BEFORE_4_STATUS >= ACCT_BEFORE_5_STATUS
                    AND  ACCT_BEFORE_4_STATUS >= ACCT_BEFORE_6_STATUS
                    THEN  ACCT_BEFORE_4_STATUS
                    WHEN ACCT_BEFORE_5_STATUS >= ACCT_BEFORE_2_STATUS
                    AND  ACCT_BEFORE_5_STATUS >= ACCT_BEFORE_3_STATUS
                    AND  ACCT_BEFORE_5_STATUS >= ACCT_BEFORE_4_STATUS
                    AND  ACCT_BEFORE_5_STATUS >= ACCT_BEFORE_1_STATUS
                    AND  ACCT_BEFORE_5_STATUS >= ACCT_BEFORE_6_STATUS
                    THEN  ACCT_BEFORE_5_STATUS
                ELSE  ACCT_BEFORE_6_STATUS
                 END)

  FROM
            VT_ACCT_STATUS
  ;
 .IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;





 /*计算 客户的 申请变量*/
CREATE MULTISET VOLATILE TABLE VT_APPLY_VARIABLE, NO LOG
(
           CM_CUSTOMER_NMBR    VARCHAR(25)                    --入帐账号
          ,card_type    VARCHAR(30)                           --卡类
          ,CM_SOURCE_CODE      CHAR(4)                        --来源码20090805
--          ,CM_BLOCK_CODE   CHAR(3)                            --封锁码
          ,name VARCHAR(30)                                   --客户姓名
          ,gender_code    VARCHAR(30)                         --性别
          ,age    INTEGER                                     --年龄
          ,id_type    VARCHAR(30)                             --证件类型
          ,id_code    VARCHAR(40)                             --证件号码
          ,education_code VARCHAR(30)                         --教育程度
          ,marriage_status_code   VARCHAR(30)                 --婚姻/子女状况
          ,debt_acct_nbr_mode VARCHAR(30)                     --是否约定还款
          ,comp_income    DECIMAL(18,2)                       --相对月收入
          ,area_code  VARCHAR(30)                             --区域代码
          ,on_book  INTEGER                                   --在册时间
          ,CM_DTE_OPENED  DATE   format 'YYYY-MM-DD'          --最早开户日  add by xjs 20110226
  )
PRIMARY INDEX (CM_CUSTOMER_NMBR)
ON COMMIT PRESERVE ROWS;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;

/*upd-100814 100709 脚本跑数优化，把A1表打横，更改在册时间字段取法*/
/*收集统计信息：collect statistics on dwrecrmMart.RECRM_IC_ACCOUNT column (branch_no);*/
INSERT INTO VT_APPLY_VARIABLE
(
              CM_CUSTOMER_NMBR
              ,CARD_TYPE                          --卡类
              ,CM_SOURCE_CODE                     --来源码20090805
--              ,CM_BLOCK_CODE                      --封锁码
              ,name                               --客户姓名
              ,gender_code                        --性别
              ,age                                --年龄
              ,id_type                            --证件类型
              ,id_code                            --证件号码
              ,education_code                     --教育程度
              ,marriage_status_code               --婚姻/子女状况
              ,debt_acct_nbr_mode                 --是否约定还款
              ,comp_income                        --相对月收入
              ,area_code                          --区域代码
              ,on_book                            --在册时间
              ,CM_DTE_OPENED                      --最早开户日   add by xjs 20110226
)
SELECT
             CM_CUSTOMER_NMBR
            ,MAX(CM_TYPE)           --卡类
            ,MAX(CM_SOURCE_CODE)    --开户最早的 卡的来源码
--            ,max(CM_BLOCK_CODE)           --封锁码
            ,MAX(A1.CM_SHORT_NAME)                                            --客户姓名
            ,MAX(A1.CR_EU_SEX)                                 --性别
            ,MAX(
               CASE
               WHEN  SUBSTR(CAST(A1.CR_DTE_BIRTH AS DATE FORMAT 'yyyy-mm-dd'), 1, 4) <> '0001' 
               THEN
                  SUBSTR(CAST('${TXNDATE}' AS DATE FORMAT 'yyyy-mm-dd'), 1, 4)
                  - SUBSTR(CAST(A1.CR_DTE_BIRTH AS DATE FORMAT 'yyyy-mm-dd'), 1, 4)
            ELSE ''
            END
              )                                             --年龄
            ,MAX('100')                                                                      --证件类型
            ,MAX(A1.CM_CO_OWNER)                                                             --证件号码
            ,MAX(A1.education_cd)                                                            --教育程度
            ,MAX(A1.MARITALSTATUS)                                                           --婚姻/子女状况
            ,MAX(debt_acct_nbr_mode )                          --是否约定还款
            ,MAX(CAST(A1.COMP_INCOME/(A4.AVERAGE_INCOME/12) AS DECIMAL(18,2))  )                                   --相对月收入20090810修改 区域月收入平均
            ,MAX(branch_no  )                                 --区域代码
            ,(SUBSTR(CAST('${TXNDATE}' AS DATE FORMAT 'yyyy-mm-dd'), 1, 4) 
              -   SUBSTR(CAST(MIN(CM_DTE_OPENED) AS DATE FORMAT 'yyyy-mm-dd'),1,4)) * 12 
              + (SUBSTR(CAST('${TXNDATE}' AS DATE FORMAT 'yyyy-mm-dd'), 6, 2) 
              -   SUBSTR(CAST(MIN(CM_DTE_OPENED) AS DATE FORMAT 'yyyy-mm-dd'),6,2) + 1)  --在册时间 upd-100814 优化脚本语句
--          ,max((substr(cast('${TXNDATE}' as date format 'yyyy-mm-dd'), 1, 4)
--               -   substr(cast(A1.CM_DTE_OPENED as date format 'yyyy-mm-dd'),1,4)) * 12
--               + (substr(cast('${TXNDATE}' as date format 'yyyy-mm-dd'), 6, 2)
--               -   substr(cast(A1.CM_DTE_OPENED as date format 'yyyy-mm-dd'),6,2))+1)  --在册时间
            ,min(CM_DTE_OPENED)           --最早开户日  add by xjs 20110226
FROM
            RECRM.RECRM_IC_ACCOUNT  A1
    LEFT JOIN
         RECRM.RECRM_AVG_INCOME_PARA A4
     ON  A1.branch_no  = A4.AREA_CODE
WHERE A1.REPORT_DATE = CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD')
--upd-100814 优化脚本删除语句 start
-- and
--    (CM_CUSTOMER_NMBR,CM_DTE_OPENED)
--   in
--(
--    select
--        CM_CUSTOMER_NMBR
--    ,min(CM_DTE_OPENED)
--from
--        RECRM.RECRM_IC_ACCOUNT A1
--where A1.REPORT_DATE =CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD')
--group by 1
--)
--upd-100814 优化脚本删除语句 end 
GROUP BY 1
;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;

/*根据客户封锁码判断是否参与分池*/
CREATE MULTISET VOLATILE TABLE VT_CUSTOMER_1, NO LOG
(
       CM_CUSTOMER_NMBR    VARCHAR(40)    --国际卡客户号
      ,CM_BLOCK_CODE       VARCHAR(4)     --封锁码
      ,CM_BLOCK_CODE_TMP   VARCHAR(4)     --临时封锁码
      ,CM_STATUS           VARCHAR(4)     --卡状态
      ,CARD_STATUS_CD      VARCHAR(4)     --卡激活标志
      ,Corp_Card_Ind       CHAR(1)        --公司卡标志

)
PRIMARY INDEX (CM_CUSTOMER_NMBR)
ON COMMIT PRESERVE ROWS;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;

INSERT INTO VT_CUSTOMER_1
(
    CM_CUSTOMER_NMBR
    ,CM_BLOCK_CODE
    ,CM_BLOCK_CODE_TMP
    ,CM_STATUS
    ,CARD_STATUS_CD
    ,Corp_Card_Ind
)
SELECT
 A1.CM_CUSTOMER_NMBR
,MIN(CASE
     WHEN CM_BLOCK_CODE = '840' 
     THEN '0001'    --迟缴180天以上
     WHEN CM_BLOCK_CODE = '836' 
     THEN '0002'    --迟缴90-179天
     WHEN CM_BLOCK_CODE = '833' 
     THEN '0003'    --伪冒卡
     WHEN CM_BLOCK_CODE = '829' 
     THEN '0004'    --银行停用卡
     WHEN CM_BLOCK_CODE = '837' 
     THEN '0005'    --连动封锁码
     WHEN CM_BLOCK_CODE = '834' 
     THEN '0006'    --迟缴60-89天
     WHEN CM_BLOCK_CODE = '844' 
     Then '0007'    --怀疑欺诈卡
     WHEN CM_BLOCK_CODE = '830' 
     Then '0008'    --迟缴30-59天 
     WHEN CM_BLOCK_CODE = '899' 
     Then '2001'    --不活跃
     WHEN CM_BLOCK_CODE = '846' 
     THEN '2002'    --临时挂失卡 
     WHEN CM_BLOCK_CODE = '838' 
     Then '2003'    --遗失/被盗不补发卡    
     WHEN CM_BLOCK_CODE = '847' 
     THEN '2004'    --邮寄卡片遗失(未达卡) 
     WHEN CM_BLOCK_CODE = '828' 
     THEN '2005'    --未激活卡片
     WHEN CM_BLOCK_CODE = '845' 
     Then '2006'    --持卡人申请卡片停用                  
     ELSE '1'||COALESCE(CM_BLOCK_CODE,'000')  --正常      /*mod by jsxu 2011-02-26*/
     END) 
,MIN(CASE
     WHEN CM_BLOCK_CODE = '840' 
     THEN '0001'    --迟缴180天以上
     WHEN CM_BLOCK_CODE = '836' 
     THEN '0002'    --迟缴90-179天
     WHEN CM_BLOCK_CODE = '833' 
     THEN '0003'    --伪冒卡
     WHEN CM_BLOCK_CODE = '829' 
     THEN '0004'    --银行停用卡
     WHEN CM_BLOCK_CODE = '837' 
     THEN '0005'    --连动封锁码
     WHEN CM_BLOCK_CODE = '834' 
     THEN '0006'    --迟缴60-89天
     WHEN CM_BLOCK_CODE = '844' 
     Then '0007'    --怀疑欺诈卡
     WHEN CM_BLOCK_CODE = '830' 
     Then '0008'    --迟缴30-59天 
     WHEN CM_BLOCK_CODE = '899' 
     Then '2001'    --不活跃
     WHEN CM_BLOCK_CODE = '846' 
     THEN '2002'    --临时挂失卡 
     WHEN CM_BLOCK_CODE = '838' 
     Then '2003'    --遗失/被盗不补发卡    
     WHEN CM_BLOCK_CODE = '847' 
     THEN '2004'    --邮寄卡片遗失(未达卡) 
     WHEN CM_BLOCK_CODE = '828' 
     THEN '2005'    --未激活卡片
     WHEN CM_BLOCK_CODE = '845' 
     Then '2006'    --持卡人申请卡片停用          
     ELSE '3'||COALESCE(CM_BLOCK_CODE,'000')  --正常  
     END)     
,min(CM_STATUS)
,MIN(CASE WHEN CARD_STATUS_CD = '220'
      THEN CARD_STATUS_CD
      ELSE '000'
  END)
,MAX(Corp_Card_Ind)
FROM RECRM.RECRM_IC_ACCOUNT A1
LEFT JOIN VT_APPLY_VARIABLE A2
ON A1.CM_CUSTOMER_NMBR = A2.CM_CUSTOMER_NMBR
WHERE REPORT_DATE =CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD') 
AND A1.CM_CUSTOMER_NMBR IS NOT NULL
GROUP BY 1
;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;



CREATE MULTISET VOLATILE TABLE VT_CUSTOMER, NO LOG
(
      CM_CUSTOMER_NMBR    VARCHAR(40)     --国际卡客户号
      ,CM_BLOCK_CODE       VARCHAR(4)     --封锁码
      ,CM_BLOCK_CODE_TMP   VARCHAR(4)     --临时封锁码
      ,CM_STATUS           VARCHAR(4)     --卡状态
      ,IS_Sub_Pool         CHAR(1)        --是否参与分池
)
PRIMARY INDEX (CM_CUSTOMER_NMBR)
ON COMMIT PRESERVE ROWS
;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;

INSERT INTO VT_CUSTOMER
SELECT
    CM_CUSTOMER_NMBR
    ,CASE WHEN CM_BLOCK_CODE='0001' 
          THEN '840'
          WHEN CM_BLOCK_CODE='0002' 
          THEN '836'
          WHEN CM_BLOCK_CODE='0003' 
          THEN '833'
          WHEN CM_BLOCK_CODE='0004' 
          THEN '829'
          WHEN CM_BLOCK_CODE='0005' 
          THEN '837'
          WHEN CM_BLOCK_CODE='0006' 
          THEN '834'
          WHEN CM_BLOCK_CODE='0007' 
          THEN '844'
          WHEN CM_BLOCK_CODE='0008' 
          THEN '830'
          WHEN CM_BLOCK_CODE='2001' 
          THEN '899'
          WHEN CM_BLOCK_CODE='2002' 
          THEN '846'
          WHEN CM_BLOCK_CODE='2003' 
          THEN '838'
--          WHEN SUBSTR(CM_STATUS,2) in ('805','806','809','810') 
--          THEN '845'
          WHEN CM_BLOCK_CODE='2004' 
          THEN '847'
          WHEN CM_BLOCK_CODE='2005' 
          THEN '828'
          WHEN CM_BLOCK_CODE='2006' 
          THEN '845'
          WHEN CM_BLOCK_CODE LIKE '1%'   
          THEN SUBSTR(CM_BLOCK_CODE,2)
     END
    ,CASE WHEN CM_BLOCK_CODE_TMP='0001' 
          THEN '840'
          WHEN CM_BLOCK_CODE_TMP='0002' 
          THEN '836'
          WHEN CM_BLOCK_CODE_TMP='0003' 
          THEN '833'
          WHEN CM_BLOCK_CODE_TMP='0004' 
          THEN '829'
          WHEN CM_BLOCK_CODE_TMP='0005' 
          THEN '837'
          WHEN CM_BLOCK_CODE_TMP='0006' 
          THEN '834'
          WHEN CM_BLOCK_CODE_TMP='0007' 
          THEN '844'
          WHEN CM_BLOCK_CODE_TMP='0008' 
          THEN '830'
          WHEN CM_BLOCK_CODE_TMP='2001' 
          THEN '899'
          WHEN CM_BLOCK_CODE_TMP='2002' 
          THEN '846'
          WHEN CM_BLOCK_CODE_TMP='2003' 
          THEN '838'
--          WHEN SUBSTR(CM_STATUS,2) in ('805','806','809','810') 
--          THEN '845'
          WHEN CM_BLOCK_CODE_TMP='2004' 
          THEN '847'
          WHEN CM_BLOCK_CODE_TMP='2005' 
          THEN '828'
          WHEN CM_BLOCK_CODE_TMP='2006' 
          THEN '845'
          WHEN CM_BLOCK_CODE_TMP LIKE '3%' 
          THEN SUBSTR(CM_BLOCK_CODE_TMP,2)
     END
    ,CM_STATUS
    ,CASE WHEN Corp_Card_Ind = '1'
          THEN '2' --对公卡（商务卡）
          WHEN (CM_BLOCK_CODE IN ('0003','0004','0005','0007','2002','2003','2004','2006')
               ) AND Corp_Card_Ind = '0'
          THEN '0'
          WHEN CM_BLOCK_CODE = '2005'  --未激活
          THEN '3'
          ELSE '1'
      END
FROM
    VT_CUSTOMER_1
;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;
CREATE MULTISET VOLATILE TABLE VT_CUSTOMER_ID_CODE, NO LOG
(
      CM_CUSTOMER_NMBR    VARCHAR(40)     --国际卡客户号
      ,ID_CODE            VARCHAR(30)     --证件号码
)
PRIMARY INDEX (CM_CUSTOMER_NMBR)
ON COMMIT PRESERVE ROWS
;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;
INSERT INTO VT_CUSTOMER_ID_CODE
select 
CM_CUSTOMER_NMBR
,CM_CO_OWNER
from RECRM.RECRM_IC_ACCOUNT
where REPORT_DATE =CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD') 
qualify row_number() over
(partition by CM_CUSTOMER_NMBR order by CM_DTE_OPENED desc ) = 1
;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;



BT;

DELETE FROM
        RECRM.RECRM_IC_SUM_CUST
WHERE   REPORT_DATE = CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD')
;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;


INSERT INTO  RECRM.RECRM_IC_SUM_CUST
(
                PARTY_ID                                       --团体标示
               ,CM_CUSTOMER_NMBR                              --客户号
               ,REPORT_DATE                                   --报告期
               ,ISMERGE                                       --是否归并
               ,CARD_TYPE                                     --卡类
               ,NAME                                          --客户姓名
               ,GENDER_CODE                                   --性别
               ,AGE                                           --年龄
               ,ID_TYPE                                       --证件类型
               ,ID_CODE                                       --证件号码
               ,EDUCATION_CODE                                --教育程度
               ,MARRIAGE_STATUS_CODE                          --婚姻/子女状况
               ,DEBT_ACCT_NBR_MODE                            --是否约定还款
               ,COMP_INCOME                                   --实际月收入
               ,AREA_CODE                                     --区域代码
               ,ON_BOOK                                       --在册时间
               ,AACTIVE                                       --是否活跃
               ,LOAN_BAL                                      --贷款余额
               ,LOAN_BAL2                                      --贷款余额2
               ,CREDIT_LIMIT                                  --信用额度
               ,SR_CREDIT_LIMIT                               --账单信用额度
               ,CM_CRLIMIT_PERM                               --永久信用额度 add by xiongwei 2010-01-25
               ,CM_SOURCE_CODE                                --来源码
               ,CM_BLOCK_CODE                                 --封锁码
               ,CM_BLOCK_CODE_TMP                             --临时封锁码
               ,CM_STATUS                                     --卡状态
               ,CM_CRLIMIT_2                                  --观察期倒数第二个月月底的信用额度
               ,CM_CRLIMIT_3                                  --观察期倒数第3个月月底的信用额度
               ,CM_CRLIMIT_4                                  --观察期倒数第4个月月底的信用额度
               ,CM_CRLIMIT_5                                  --观察期倒数第5个月月底的信用额度
               ,CM_CRLIMIT_6                                  --观察期倒数第6个月月底的信用额度
               ,take_cash_balance                             --取现余额
               ,consume_balance                               --消费余额
               ,month_balance                                 --月末余额
               ,SRC_DEBITS                                    --取现借记金额
               ,SRC_CREDITS                                   --取现贷记金额
               ,SRR_DEBITS                                    --消费借记金额
               ,SRR_CREDITS                                   --消费贷记金额
               ,SRR_BEG_BALANCE                               --期初消费余额
               ,SRC_BEG_BALANCE                               --期初取现余额
               ,LOW_PAYMENT_FEE                               --最低还款额
               ,CUST_STATUS                                   --客户逾期状态
               ,NUM_ACCT                                      --账户数目
               ,rtl_deliquency                                --是否年费逾期
               ,rtl_default                                   --是否年费违约
               ,ON_OVERDUE_CD                                 --开户6个月内最差逾期状态
               ,ACCT_BEFORE_1_STATUS                          -- 前1期账户中最差的状态
               ,ACCT_BEFORE_2_STATUS                          -- 前2期账户中最差的状态
               ,ACCT_BEFORE_3_STATUS                          -- 前3期账户中最差的状态
               ,ACCT_BEFORE_4_STATUS                          -- 前4期账户中最差的状态
               ,ACCT_BEFORE_5_STATUS                          -- 前5期账户中最差的状态
               ,ACCT_BEFORE_6_STATUS                          -- 前6期账户中最差的状态
               ,ACCT_BEFORE_7_STATUS                          -- 前7期账户中最差的状态
               ,ACCT_BEFORE_8_STATUS                          -- 前8期账户中最差的状态
               ,ACCT_BEFORE_9_STATUS                          -- 前9期账户中最差的状态
               ,ACCT_BEFORE_10_STATUS                         -- 前10期账户中最差的状态
               ,ACCT_BEFORE_11_STATUS                         -- 前11期账户中最差的状态
               ,ACCT_BEFORE_12_STATUS                         -- 前12期账户中最差的状态
               ,CM_INSTL_BAL                                  --分期余额
               ,CM_INSTL_LIMIT                                --分期额度
               ,IS_Sub_Pool                                   --是否参与分池
               ,LOAD_TIME                                     --加载日期
			         ,CM_DTE_OPENED     
 )
SELECT
                 COALESCE(A2.PARTY_ID,'')                                       --团体标示
                 ,A1.CM_CUSTOMER_NMBR                              --客户号
                 ,CAST('${TXNDATE}' AS DATE FORMAT 'YYYY-MM-DD')   --报告期
                 ,'0'                                              --是否归并 /*已经没有意义*/
                 ,A5.CARD_TYPE                                     --卡类
                 ,A5.NAME                                          --客户姓名
                 ,A5.GENDER_CODE                                   --性别
                 ,A5.AGE                                           --年龄
                 ,A5.ID_TYPE                                       --证件类型
                 ,A6.ID_CODE                                       --证件号码
                 ,A5.EDUCATION_CODE                                --教育程度
                 ,A5.MARRIAGE_STATUS_CODE                          --婚姻/子女状况
                 ,A5.DEBT_ACCT_NBR_MODE                            --是否约定还款
                 ,A5.COMP_INCOME                                   --实际月收入
                 ,A5.AREA_CODE                                     --区域代码
                 ,A5.ON_BOOK                                       --在册时间
                 ,A2.aActive                                       --是否活跃
                 ,A2.LOAN_BAL                                      --贷款余额
                 ,A2.LOAN_BAL2                                     --贷款余额
                 ,A2.CREDIT_LIMIT                                  --信用额度
                 ,A2.SR_CREDIT_LIMIT                               --账单信用额度
                 ,A2.CM_CRLIMIT_PERM
                 ,A5.CM_SOURCE_CODE                                --来源码
                 ,A1.CM_BLOCK_CODE                                 --封锁码
                 ,A1.CM_BLOCK_CODE_TMP                             --临时封锁码
                 ,A1.CM_STATUS                                     --卡状态
                 ,A2.CM_CRLIMIT_2                                  --观察期倒数第二个月月底的信用额度
                 ,A2.CM_CRLIMIT_3                                  --观察期倒数第3个月月底的信用额度
                 ,A2.CM_CRLIMIT_4                                  --观察期倒数第4个月月底的信用额度
                 ,A2.CM_CRLIMIT_5                                  --观察期倒数第5个月月底的信用额度
                 ,A2.CM_CRLIMIT_6                                  --观察期倒数第6个月月底的信用额度
                 ,A2.take_cash_balance                             --取现余额
                 ,A2.consume_balance                               --消费余额
                 ,A2.month_balance                                 --月末余额
                 ,A2.SRC_DEBITS                                    --取现借记金额
                 ,A2.SRC_CREDITS                                   --取现贷记金额
                 ,A2.SRR_DEBITS                                    --消费借记金额
                 ,A2.SRR_CREDITS                                   --消费贷记金额
                 ,A2.SRR_BEG_BALANCE                               --期初消费余额
                 ,A2.SRC_BEG_BALANCE                               --期初取现余额
                 ,A2.LOW_PAYMENT_FEE                               --最低还款额
                 ,A2.CM_CYCLE_DUE                                   --客户逾期状态
                 ,A2.NUM_ACCT                                      --账户数目
                              ,A2.rtl_deliquency                                         --是否年费逾期
                 ,A2.rtl_default                                               --是否年费违约
                 ,(CASE
                       WHEN A4.ON_OVERDUE_CD = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A4.ON_OVERDUE_CD = '-2' 
                       THEN  '0'
                       WHEN A4.ON_OVERDUE_CD = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE  A4.ON_OVERDUE_CD
                  END )
                 ,(CASE
                       WHEN A3.ACCT_BEFORE_1_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_1_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_1_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE A3.ACCT_BEFORE_1_STATUS
                   END)
                  ,(CASE
                       WHEN A3.ACCT_BEFORE_2_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_2_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_2_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE  A3.ACCT_BEFORE_2_STATUS
                    END)
                  ,(CASE
                       WHEN A3.ACCT_BEFORE_3_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_3_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_3_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE  A3.ACCT_BEFORE_3_STATUS 
                    END)
                  ,(CASE
                       WHEN A3.ACCT_BEFORE_4_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_4_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_4_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE  A3.ACCT_BEFORE_4_STATUS 
                       END)
                  ,(CASE
                       WHEN A3.ACCT_BEFORE_5_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_5_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_5_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE  A3.ACCT_BEFORE_5_STATUS 
                    END)
                  ,(CASE
                       WHEN A3.ACCT_BEFORE_6_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_6_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_6_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE  A3.ACCT_BEFORE_6_STATUS 
                    END)
                  ,(CASE
                       WHEN A3.ACCT_BEFORE_7_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_7_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_7_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE  A3.ACCT_BEFORE_7_STATUS 
                    END)
                  ,(CASE
                       WHEN A3.ACCT_BEFORE_8_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_8_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_8_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE  A3.ACCT_BEFORE_8_STATUS 
                    END)
                  ,(CASE
                       WHEN A3.ACCT_BEFORE_9_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_9_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_9_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE  A3.ACCT_BEFORE_9_STATUS 
                    END)
                  ,(CASE
                       WHEN A3.ACCT_BEFORE_10_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_10_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_10_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE  A3.ACCT_BEFORE_10_STATUS 
                    END)
                  ,(CASE
                       WHEN A3.ACCT_BEFORE_11_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_11_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_11_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE  A3.ACCT_BEFORE_11_STATUS 
                    END)
                  ,(CASE
                       WHEN A3.ACCT_BEFORE_12_STATUS = '-1' 
                       THEN  'Z'   /*CJZ 20090808*/
                       WHEN A3.ACCT_BEFORE_12_STATUS = '-2' 
                       THEN  '0'
                       WHEN A3.ACCT_BEFORE_12_STATUS = '-3' 
                       THEN  'B'   /*CJZ 20090808*/
                       ELSE A3.ACCT_BEFORE_12_STATUS 
                    END)
                       ,A2.CM_INSTL_BAL                                  --分期余额
                       ,A2.CM_INSTL_LIMIT                                --分期额度
                       ,A1.IS_Sub_Pool                                   --是否参与分池
                       ,CAST(CURRENT_TIMESTAMP AS CHAR(10))              --加载日期
                       ,A5.CM_DTE_OPENED
  FROM
  VT_CUSTOMER A1
LEFT JOIN
  VT_ALL_AMT A2
ON A1.CM_CUSTOMER_NMBR =A2.CM_CUSTOMER_NMBR
LEFT JOIN
    VT_ACCT_STATUS A3
ON A1.CM_CUSTOMER_NMBR = A3.CM_CUSTOMER_NMBR
LEFT JOIN
    VT_on_overdue_cd A4
ON A1.CM_CUSTOMER_NMBR = A4.CM_CUSTOMER_NMBR
LEFT JOIN
VT_APPLY_VARIABLE A5
ON A1.CM_CUSTOMER_NMBR = A5.CM_CUSTOMER_NMBR
inner join VT_CUSTOMER_ID_CODE A6
ON A1.CM_CUSTOMER_NMBR = A6.CM_CUSTOMER_NMBR
;
.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT;
ET;


.LOGOFF;
.QUIT 0;
.LABEL ERRORQUIT
.IF ERRORCODE <> 0 THEN .QUIT 12;

ENDOFINPUT

   ### End of BTEQ scripts ###
   close(BTEQ);

   my $RET_CODE = $? >> 8;

   # if the return code is 12, that means something error happen
   # so we return 1, otherwise, we return 0 means ok
   if ( $RET_CODE == 12 ) {
      return 1;
   }
   else {
      return 0;
   }
}

######################################################################
# main function
sub main
{
   my $ret;
   open(LOGONFILE_H, "${LOGON_FILE}");
   $LOGON_STR = <LOGONFILE_H>;
   close(LOGONFILE_H);

   # Get the decoded logon string

   # Call bteq command to load data
   $ret = run_bteq_command();

   print "run_bteq_command() = $ret";
   return $ret;
}

######################################################################
# program section

$TXNDATE = "2026-01-31";
if ( $#ARGV == 0 ) {
  if ($ARGV[0] =~/^\d{4}-\d{2}-\d{2}$/) {
    $TXNDATE = $ARGV[0];
  }
}

open(STDERR, ">&STDOUT");

my $ret = main();

exit($ret);

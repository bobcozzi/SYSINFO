
   -- Get System/Partition Information (SYSINFO)
   -- (c) 2024 - R. Cozzi, Jr.

CREATE or REPLACE FUNCTION IOPEN.sysinfo( )
       RETURNS table (mchtype varchar(4),
                      model   varchar(4),
                      srlnbr  varchar(10),
                      feature_Code varchar(4),
                      Processor_Group  varchar(4),

                      IBM_Customer_ID  varchar(8),

                      IBMi_VRM varchar(6),
                      IBMi_TR  smallInt,
                      IBMi_VER smallInt,

                      PARTITION_ID      SMALLINT,
                      PARTITION_SYSNAME varchar(8),
                      PARTITION_CPName  varchar(8),
                      PARTITION_SRLNBR  varchar(10),
                      PARTITION_Count   SMALLINT,

                      HOSTNAME   VARCHAR(64),

                      PROCESSOR_Count SMALLINT,
                      TOTAL_MEMORY_GB SMALLINT,

                      IBMCUSTID2 VARCHAR(8),
                      IBMCUSTID3 VARCHAR(8),
                      IBMCUSTID4 VARCHAR(8),
                      IBMCUSTID5 VARCHAR(8)
                     )
     LANGUAGE RPGLE
     NO  SQL
     NO  FINAL CALL
     NOT FENCED
     DETERMINISTIC
     SCRATCHPAD 32
     CARDINALITY 1
     SPECIFIC IO_SYSINFO
     EXTERNAL NAME 'IOPEN/SYSINFO'
     PARAMETER STYLE DB2SQL;

LABEL on specific routine IOPEN.IO_SYSINFO IS
'Retrieve IBM i Operating System "Machine" Info';

comment on SPECIFIC FUNCTION IOPEN.IO_SYSINFO is
'Retrieve the system configuration attributes such as
Machine Type, Model Number, Serial Number, Feature Code, System name,
CPU count, Total RAM, and Processor Group. In addition the IBM Contact record
Customer ID is returned, along with the current IBM i version and TR level.';
             

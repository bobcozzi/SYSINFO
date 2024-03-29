
           ctl-opt MAIN(SYSINFO)
                   DFTACTGRP(*NO)
                   COPYRIGHT('(c) 2024 by Bob Cozzi - All right reserved.');

              // This is an external program for an IBM i SQL UDTF.
              // The UDTF is named SYSINFO in the iOPEN library.
              // You may create it in any library you want, simply modify
              // the SYSINFO.SQL source to point at the correct library name.

              // NOTE: It is purposely created as one lengthy source member
              // to avoid managing all the /copy's that would be required.

              // If you like this kind of content, ask your employer to
              // purchase a license to Bob Cozzi's SQL Tools and SQL iQuery.
              //    www.SQLiQuery.com
              // Your support for these products helps us continue to
              // development this and the myriad other free IBM i utilities
              // that we have contributed to the community over the decades.


               // Literals for MATMATR1 MI Inst (parm 2)
           Dcl-C MMTR_SERIAL                CONST(X'0004');
           Dcl-C MMTR_UUID                  CONST(X'0008');
           Dcl-C MMTR_TOD                   CONST(X'0100');
           Dcl-C MMTR_TODOFS                CONST(X'0101');
           Dcl-C MMTR_INITPR                CONST(X'0104');
           Dcl-C MMTR_MISR                  CONST(X'0108');
           Dcl-C MMTR_UPS_DELAY             CONST(X'0118');
           Dcl-C MMTR_VPD                   CONST(X'012C');
           Dcl-C MMTR_APPN                  CONST(X'0130');
           Dcl-C MMTR_DATE_FORMAT           CONST(X'0134');
           Dcl-C MMTR_LEAP_YEAR             CONST(X'0138');
           Dcl-C MMTR_TIMED_POWER_ON        CONST(X'013C');
           Dcl-C MMTR_TIMED_POWER_ON_ED     CONST(X'0140');
           Dcl-C MMTR_REMOTE_POWER_ON_ED    CONST(X'0144');
           Dcl-C MMTR_AUTO_POWER_RESTART_ED CONST(X'0148');
           Dcl-C MMTR_DATE_SEP              CONST(X'014C');
           Dcl-C MMTR_SYS_SEC_INDICATORS    CONST(X'0151');
           Dcl-C MMTR_HWD_CHECK             CONST(X'0161');
           Dcl-C MMTR_UPS_TYPE              CONST(X'0164');
           Dcl-C MMTR_PANEL_STATUS          CONST(X'0168');
           Dcl-C MMTR_XMISR                 CONST(X'016C');
           Dcl-C MMTR_ALT_PRCS              CONST(X'0170');
           Dcl-C MMTR_HW_PROTECT            CONST(X'0178');
           Dcl-C MMTR_TIME_SEP              CONST(X'0180');
           Dcl-C MMTR_SW_ERROR_LOG          CONST(X'0184');
           Dcl-C MMTR_EVENT_CTL             CONST(X'0188');
           Dcl-C MMTR_SERVICE_ATTRIBUTES    CONST(X'01A8');
           Dcl-C MMTR_SIG_CTLS              CONST(X'01B0');
           Dcl-C MMTR_CRYTPOGRAPHY          CONST(X'01C8');
           Dcl-C MMTR_COMM_NET_ATTR         CONST(X'01D0');
           Dcl-C MMTR_PROCESSOR_COUNT       CONST(X'01DC');
           Dcl-C MMTR_LPAR_INFO             CONST(X'01E0');
           Dcl-C MMTR_PARTITION_STATUS      CONST(X'01E1');
           Dcl-C MMTR_PARTITION_ATTRIBUTES  CONST(X'01E2');
           Dcl-C MMTR_LS_RESERVED           CONST(X'01EC');
           Dcl-C MMTR_POD_DATA              CONST(X'01F4');
           Dcl-C MMTR_MEM_CUOD_DATA         CONST(X'01F6');
           Dcl-C MMTR_IPL_NUMBER            CONST(X'01F8');
           Dcl-C MMTR_E_LICENSING           CONST(X'01FC');
           Dcl-C MMTR_WAIT_STATE_DATA       CONST(X'0200');
           Dcl-C MMTR_HMC_INFO              CONST(X'0204');
           Dcl-C MMTR_KEEP_DISK_CFG         CONST(X'0208');
           Dcl-C MMTR_LIC_VRM               CONST(X'020C');
           Dcl-C MMTR_SHR_POOL              CONST(X'0210');
           Dcl-C MMTR_PROC_FLAGS            CONST(X'0220');
           Dcl-C MMTR_SUSP_CTRL             CONST(X'0224');
           Dcl-C MMTR_SUSP_STAT             CONST(X'0228');
           Dcl-C MMTR_ENERGY_CONTROL        CONST(X'0234');

             // Create a user space
           dcl-pr QUSCRTUS extpgm('QUSCRTUS');
              userSpaceName char(20) CONST;
              objAttr       char(10) CONST;
              initSize      int(10) CONST;
              initValue     char(1) CONST;
              pubAut        char(10) CONST;  // *LIBCRTAUT
              objText       char(50) CONST OPTIONS(*NOPASS);
              REPLACE       char(10) CONST OPTIONS(*NOPASS);  // REPLACE
              ec            likeDS(QUSEC_T) OPTIONS(*NOPASS : *VARSIZE);
           end-pr;

             // Delete user space object
           dcl-pr QUSDLTUS extpgm('QUSDLTUS');
              userSpaceName char(20) CONST;
              ec            likeDS(QUSEC_T) OPTIONS(*NOPASS : *VARSIZE);
           end-pr;

             // Get a pointer to a user space
           dcl-pr QUSPTRUS extpgm('QUSPTRUS');
              userSpaceName char(20) CONST;
              ptr           pointer;
              ec            likeDS(QUSEC_T) OPTIONS(*NOPASS : *VARSIZE);
           end-pr;

             // Generate a "temp" (unique) file name
           dcl-pr tmpName pointer extproc('tmpnam');
              rtnBuffer char(32767) OPTIONS(*VARSIZE:*OMIT);
           end-pr;

             // Produce a list of Group PTFs
           dcl-pr getptfGroups extproc('QpzListPtfGroups');
             userspaceName char(20) CONST;
             APIFMT        char(8)  CONST;
             desc_CCSID    int(10)  CONST;
             ec            likeDS(QUSEC_T) OPTIONS(*VARSIZE);
           end-pr;

             // Get Host Name
           dcl-pr gethostname int(10) extproc('gethostname');
             rtnBuffer pointer   VALUE;
             rtnSize   int(10)   VALUE;
           end-pr;

             // In this program we use these types for MATMATR1
           dcl-s m0130 uns(5) inz(MMTR_APPN);      // 0x0130
           dcl-s m012C uns(5) inz(MMTR_VPD);      // 0x0130
           dcl-s m01E0 uns(5) inz(MMTR_LPAR_INFO);      // 0x0130
           dcl-s m01DC uns(5) inz(MMTR_PROCESSOR_COUNT);      // 0x0130

             // Materialize Machine Attributes (MATMATR1) MI Inst prototype
           dcl-pr MATMATR1 extproc('_MATMATR1');
              rtnAttributes CHAR(256) OPTIONS(*VARSIZE);
              operation     int(5)  Const;
           end-pr;


             // Exception/Error feedback area for CEExxxx APIs
           Dcl-Ds Feedback_T Qualified Template;
             MsgSev Int(10);
             MsgNo  Int(10);
             flags  char(1);
             Case     uns(3) Overlay(Flags);
             Severity uns(3) Overlay(Flags);
             Control  uns(3) Overlay(Flags);
             Facility_ID Char(3);
             I_S_Info Int(10);
           End-Ds;

             // Inline function to extract the IBM i OS Version/Release
           dcl-pr CEEGPID  extproc('CEEGPID');
              version  int(10);
              platform int(10);
              feedback likeDS(FEEDBACK_T) OPTIONS(*OMIT);
           end-pr;

           // RPG IV equivalent of struct Qus_Generic_Header_0100
           DCL-Ds Qus_Generic_Header_0100 Qualified Template Inz;
             User_Area               Char(64);
             Size_Generic_Header     Int(10);
             Structure_Release_Level Char(4);
             Format_Name             Char(8);
             Api_Used                Char(10);
             Date_Time_Created       Char(13);
             Information_Status      Char(1);
             Size_User_Space         Int(10);
             Offset_Input_Parameter  Int(10);
             Size_Input_Parameter    Int(10);
             Offset_Header_Section   Int(10);
             Size_Header_Section     Int(10);
             Offset_List_Data        Int(10);
             Size_List_Data          Int(10);
             Number_List_Entries     Int(10);
             Size_Each_Entry         Int(10);
             CCSID_List_Ent          Int(10);
             Country_ID              Char(2);
             Language_ID             Char(3);
             Subset_List_Indicator   Char(1);
             Reserved Char(42);
           End-Ds;

             // MATMATR1 templates
           dcl-ds Gen_Mat_ID_T;
             Type_Subtype Int(10);
             Name         CHAR(30);
           end-ds;

             // Installed processor count
           Dcl-Ds MMTR_01DC_T Qualified Template;
             numProcessors uns(5);
           End-Ds;

             // Network attributes
           Dcl-Ds MMTR_0130_T Qualified Template;
            Sys_Name Char(8);         // System Name
            Name_Len Int(5);         // System Name Length
            Sys_Name_New Char(8);     // System Name new
            Name_Len_New Int(5);     // System Name Length new
            Net_ID Char(8);           // local net ID
            Net_ID_Len Int(5);       // local net ID length
            Enode_Compress Int(10);   // End node data compression
            Inode_Compress Int(10);   // Intermediate node compress
            reserved1 Char(2);
            CP_Name Char(8);          // local cp name
            CP_Name_Len Int(5);      // local cp name length
            Max_Appn_LUDS Int(5);    // Max LUDs on virt. CDs
            PathSwT_Netw Int(5);     // Path Sw Timer, Net Pri
            PathSwT_High Int(5);     // Path Sw Timer, Hi Pri
            PathSwT_Med Int(5);      // Path Sw Timer, Med Pri
            PathSwT_Low Int(5);      // Path Sw Timer, Low Pri
            Def_Loc Char(8);          // default location name
            Def_Loc_Len Int(5);      // default location name len
            Def_Mode Char(8);         // Default mode name
            Def_Mode_Len Int(5);     // Default mode name length
            Max_Inter Int(5);        // Max # of intermediate sess
            Max_Converse Int(5);     // Max # of conversations/LUD
            Node_Type Char(1);        // Local system node type X'01'
            reserved3 Char(1);
            Resist Int(5);           // Route addition resistance
            Server Char(8) Dim(5);    // 5 Net Server ID's
            Server_Len Int(5) Dim(5); // 5 Net Server ID lengths
            Server_CP Char(8) Dim(5); // 5 Net Server CP ID's
            Server_Len_CP Int(5) Dim(5); // 5 Net Server CP ID Lengths

            Flag Char(2);             // Dummy flag subfield (16 bits)
            A_Priority uns(3) Overlay(Flag:1); // Alert priority focal point (bit 1)
            A_Default uns(3) Overlay(Flag:1);  // Alert default focal point (bit 2)
            // reserved4 Overlay(flag:1);  // the other 6 bits of Flag(1)
            Init_Attr uns(3) Overlay(Flag:2);  // Net attributes initialized (bit 1)
            Pend_Name uns(3) Overlay(Flag:2);  // Name change pending (bit 2)
            Allow_ANY uns(3) Overlay(Flag:2);  // Allow ANYNET support (bit 3)
            Allow_VCD uns(3) Overlay(Flag:2);  // APPN may use virt CDs (bit 4)
            HPR_Tower uns(3) Overlay(Flag:2);  // Tower sup OK for APPN (bit 5)
            Enable_BrEx uns(3) Overlay(Flag:2); // Enable Branch extender (bit 6)
                                          // network node
            reserved5 uns(3) overlay(flag:2);   // bits 7-8 of flag(2)
           End-Ds;

             // Partitioning information
           Dcl-Ds MMTR_01E0_T Qualified Template;
             num_of_partition Char(1);
             partition_id     Char(1);
             prim_partition   Char(1);
             Srvc_Partition   Char(1);
             Firmware_Level   Char(1);
             reserved1        Char(3) inz(*ALLX'00');
             logical_ser_num  Char(10);
             reserved2        Char(5) inz(*ALLX'00');

             Flag1 Char(1);
               Cur_Partition_Shared Uns(3) Overlay(Flag1:1);
               Lpar_Uncapped        Uns(3) Overlay(Flag1:1);
               Lpar_Proc_Donation   Uns(3) Overlay(Flag1:1);
               reserved4            Uns(3) Overlay(Flag1:1);

             min_processors   Uns(5);
             max_processors   Uns(5);
             cur_processors   Uns(5);
             reserved5        char(2) inz(*ALLX'00');
             cur_min_memory   Uns(10);
             cur_max_memory   Uns(10);
             cur_avail_memory Uns(10);
             min_percentage_int_work uns(3);
             max_percentage_int_work uns(3);
             cur_percentage_int_work uns(3);
             reserved6               Char(1) inz(*ALLX'00');

             flag2 Char(2);
               High_Speed_Link Uns(3) Overlay(Flag2:1); // BitSize(1)
               reserved10      Uns(3) Overlay(Flag2:1); // BitSize(15)
             flag3 Char(2);
               Internal_Link   Uns(3) Overlay(Flag3:1); // BitSize(1)
               reserved12      Uns(3) Overlay(Flag3:1); // BitSize(15)

             Min_Proc_Capacity Uns(10);
             Max_Proc_Capacity Uns(10);
             Cur_Proc_Capacity Uns(10);
             Cur_Avail_Proc_Cap_Shared Uns(10);
             Num_Phy_Proc_Shared       Uns(5);
             reserved13                Char(2) inz(*ALLX'00');
             Mach_Hypervisor_Memory    Uns(10);
             Uncapped_Weight      Uns(5);
             Min_Portion_Int_Work Uns(5);
             Max_Portion_Int_Work Uns(5);
             Cur_Portion_Int_Work Uns(5);
             reserved14           Char(4) inz(*ALLX'00');
             num_of_partition2    Uns(5);
             partition_id2        Uns(5);
             prim_partition2      Uns(5);
             Srvc_Partition2      Uns(5);
             reserved15           Char(16) inz(*ALLX'00');
           End-Ds;

           // Memory Vital Product Data
           dcl-ds MEM_VPD_T Qualified Template;
             Mem_Status Char(2);      // memory data
             Mem_Card_Size Int(5);   // memory card size in meg
             CCINS Char(1);           // no. of CCINS for this card
             CCINS_Array Char(32);    // array of CCINS for card
             Slot Char(1);            // slot no. for this card
             reserved Char(26);
           end-ds;

           // Processor Vital Product Data
           dcl-ds PROC_VPD_T Qualified Template;
             Status Char(4);         // processor status
             CCIN Char(4);           // CCIN number
             Model Char(4);          // processor model no.
             Part Char(12);          // part no.
             reserved1 Char(4);      // reserved
             Maufacture Char(4);     // manufacturing ID
             reserved2 Char(4);      // reserved
             Serial_No Char(10);     // Serial number
             reserved3 Char(34);     // reserved
           end-ds;

           // Columbia/Columis Info
           dcl-ds COL_VPD_T Qualified Template;
             reserved1 Char(4);      // reserved
             CCIN Char(4);           // CCIN number
             Model Char(4);          // card model number
             reserved2 Char(16);     // reserved
             Maufacturing Char(4);   // manufacturing ID
             Serial_No Char(10);     // Serial number
             reserved3 Char(22);     // reserved
           end-ds;

           // CEC Vital Product Data
           dcl-ds CEC_VPD_T Qualified Template;
             CEC_read Char(4);       // status of last CEC read
             Manufacturing Char(4);  // manufacturing ID
             reserved1 Char(4);      // reserved
             Type Char(4);           // system type
             Model Char(4);          // model number
             Pseudo_Model Char(4);   // pseudo model no.
             Group_Id Char(4);       // processor group id
             reserved2 Char(4);      // reserved
             Sys_Type_Ext Char(1);   // system type extension
             Feature_Code Char(4);   // processor feature code
             Serial_No Char(10);     // serial number
             reserved3 Char(1);      // reserved
           end-ds;

           // Panel Info
           dcl-ds PANEL_VPD_T Qualified Template;
             reserved1 Char(2);      // reserved
             Panel_Type Char(4);     // panel type
             Model Char(3);          // panel model number
             Part Char(12);          // part number
             reserved2 Char(4);      // reserved
             Manufacturing Char(4);  // manufacturing ID
             ROS_Part Char(12);      // alterable ROS part #
             ROS_Card Char(10);      // alterable ROS card #
             ROS_ID Char(1);         // alterable ROS ID
             ROS_Flag Char(1);       // alterable ROS flag
             ROS_Fix Char(1);        // alterable ROS fix ID
             Serial_No Char(10);     // serial number
           end-ds;

           // Vital Product Data
           dcl-ds MMTR_012C_T Qualified Template;
             Reserved Char(8);
             Mem_Offset Int(10);          // Offset to memory VPD
             Proc_Offset Int(10);         // Offset to processor VPD
             Col_Offset Int(10);          // Offset to Columbia/Colomis
             CEC_Offset Int(10);          // Offset to CEC VPD
             Panel_Offset Int(10);        // Offset to Panel VPD
             Reserved2 Char(12);
             Mem_Installed Int(5);       // Memory installed in Meg
             Mem_Required Int(5);        // Min. mem needed in Meg
             Mem_Installed_B Uns(10);      // Memory installed in Meg - a bigger field
             Mem_Required_B Uns(10);       // Min. mem needed in Meg - a bigger field
             reserved3 Char(4);           // reserved

             Mem_Array LikeDs(MEM_VPD_T) Dim(16);   // 1024 bytes memory info
             Proc_Array LikeDs(PROC_VPD_T) Dim(16); // 1280 bytes processor info
             Col_Array LikeDs(COL_VPD_T) Dim(2);    // 1=>reserved 2=>columis
             CEC_Info LikeDs(CEC_VPD_T);
             Panel_Info LikeDs(PANEL_VPD_T);
             Proc_Feature Char(4);         // Processor feature
             Int_Feature Char(4);          // Interactive feature
           end-ds;

           dcl-ds APPN_data LIKEDS(MMTR_0130_T) ;  // Network Attributes
           dcl-ds VPD_data  LIKEDS(MMTR_012C_T);   // Virt Partition Description
           dcl-ds LPAR_data LIKEDS(MMTR_01E0_T) ;  // Logical Partitioning Info
           dcl-ds PROC_data LIKEDS(MMTR_01DC_T) ;  // Physical Processors Installed

             // MATMATR1 container structure (use as a Template)
           dcl-ds MMTR_TEMPLATE_T Qualified Template;
             template_Size int(10);
             bytes_Used    int(10);
             return_buffer char(4096);
               VPD_data  LIKEDS(MMTR_012C_T) POS(9);   // Virt Partition Description
               APPN_data LIKEDS(MMTR_0130_T) POS(9);   // Network Attributes
               PROC_data LIKEDS(MMTR_01DC_T) POS(9);   // Physical Processors Installed
               LPAR_data LIKEDS(MMTR_01E0_T) POS(9);   // Logical Partitioning Info
           end-ds;

             // Primary return variable from the MATMATR1 MI Inst.
           dcl-ds MCHINFO LikeDS(MMTR_Template_T) Inz;

             // Retrieve IBM Customer Contract Information Record
           dcl-pr QEDRTVCI extpgm('QEDRTVCI');
             rtnContactInfo LIKEDS(CNTI0100_t) OPTIONS(*VARSIZE);
             rtnSize        int(10) CONST;
             APIFMT         CHAR(8) CONST;
             ec             LIKEDS(QUSEC_T);
           end-pr;

             // Resulting structure from call to the QEDRTVCI API
           dcl-ds CNTI0100_t Qualified Template Inz;
             Bytes_Return Int(10);
             Bytes_Available Int(10);
             Company_Name Char(36);
             Contact_Name Char(36);
             Primary_Telephone Char(20);
             Helpdesk_Pagenumber Char(20);
             Primary_Fax Char(20);
             Alternative_Fax Char(20);
             Street_Address_L1 Char(36);
             Street_Address_L2 Char(36);
             Street_Address_L3 Char(36);
             City_Locality Char(36);
             State_Province Char(36);
             Country_Region Char(20);
             Postal_Code Char(12);
             Offset_Email_Address Int(10);
             Length_Email_Address Int(10);
             Offset_Email_Address2 Int(10);
             Length_Email_Address2 Int(10);
             Media_Mailing_PTF Int(10);
             National_Language_Version Char(4);
             Call_Central_Site_Sprt Int(10);
             Customer_Number_Id1 Char(8);
             Customer_Number_Id2 Char(8);
             Customer_Number_Id3 Char(8);
             Customer_Number_Id4 Char(8);
             Customer_Number_Id5 Char(8);
             Contract_Number_Id1 Char(7);
             Contract_Number_Id2 Char(7);
             Contract_Number_Id3 Char(7);
             Contract_Number_Id4 Char(7);
             Contract_Number_Id5 Char(7);
             Reserved Char(1);
             Offset_Customer_Desc1 Int(10);
             Length_Customer_Desc1 Int(10);
             Offset_Customer_Desc2 Int(10);
             Length_Customer_Desc2 Int(10);
             Offset_Customer_Desc3 Int(10);
             Length_Customer_Desc3 Int(10);
             Offset_Customer_Desc4 Int(10);
             Length_Customer_Desc4 Int(10);
             Offset_Customer_Desc5 Int(10);
             Length_Customer_Desc5 Int(10);
             Offset_Contract_Desc1 Int(10);
             Length_Contract_Desc1 Int(10);
             Offset_Contract_Desc2 Int(10);
             Length_Contract_Desc2 Int(10);
             Offset_Contract_Desc3 Int(10);
             Length_Contract_Desc3 Int(10);
             Offset_Contract_Desc4 Int(10);
             Length_Contract_Desc4 Int(10);
             Offset_Contract_Desc5 Int(10);
             Length_Contract_Desc5 Int(10);
           end-ds;

             // Structure to receive results from call to the QEDRTVCI API
           dcl-ds contactInfo likeDS(CNTI0100_t) INZ;

             // The SQL scratch pad passed between calls to this UDTF
           dcl-ds scratch_t Qualified Template;
              eof int(10);
              counter int(10);
           end-ds;

             // The standard API exception error structure
           dcl-ds QUSEC_T qualified template;
             bytes_Provided int(10) inz(%size(qusec_t));
             bytes_Returned int(10) inz;
             msgid          char(7) inz(*ALLX'00');
             reserved1      char(1) inz(X'00');
             msgdata        char(128) inz(*ALLX'00');
           end-ds;

             // Receiver variables for the CEEPGID API
           dcl-s ver      int(10);
           dcl-s platform int(10);

              // Maximum length of the HOSTNAME structure
              // (although it is usually under 80 bytes)
           dcl-c MAXHOSTNAMELEN CONST(255);

             // Variables to retrieve the system's host name
           dcl-s hostname  char(MAXHOSTNAMELEN);
           dcl-s pHostName pointer inz(%addr(hostname));

             // THe sqlopcode values (ported to RPGIV from qsysinc/h/sqludf
           DCL-C SQLUDF_ENUM_CALLTYPE_MINUS2 CONST(-2);
           DCL-C SQLUDF_ENUM_CALLTYPE_MINUS1 CONST(-1);
           DCL-C SQLUDF_ENUM_CALLTYPE_ZERO CONST(0);
           DCL-C SQLUDF_ENUM_CALLTYPE_PLUS1 CONST(1);
           DCL-C SQLUDF_ENUM_CALLTYPE_PLUS2 CONST(2);
           DCL-C SQLUDF_ENUM_CALLTYPE_PLUS255 CONST(255);
           DCL-C SQLUDF_ENUM_CALLTYPE_END CONST(X'7FFFFFFF');

           DCL-S SQLUDF_TF_FIRST INT(10) INZ(SQLUDF_ENUM_CALLTYPE_MINUS2);
           DCL-S SQLUDF_TF_OPEN  INT(10) INZ(SQLUDF_ENUM_CALLTYPE_MINUS1);
           DCL-S SQLUDF_TF_FETCH INT(10) INZ(SQLUDF_ENUM_CALLTYPE_ZERO);
           DCL-S SQLUDF_TF_CLOSE INT(10) INZ(SQLUDF_ENUM_CALLTYPE_PLUS1);
           DCL-S SQLUDF_TF_FINAL INT(10) INZ(SQLUDF_ENUM_CALLTYPE_PLUS2);
           DCL-S SQLUDF_TF_FINAL_CRA INT(10) INZ(SQLUDF_ENUM_CALLTYPE_PLUS255);

             // ------------------------------------------------
             // MAIN Entry Point Procedures: SYSINFO
             // ------------------------------------------------
           dcl-proc SYSINFO;
           dcl-pi   SYSINFO extpgm('SYSINFO');

             // ------------------------------------------------
             // Input Parameters
             // No input parameters
             // ------------------------------------------------

             // ------------------------------------------------
             // Output Columns
             // ------------------------------------------------
             outType    varchar(4);   // Machine Type
             outModel   varchar(4);   // Model number
             outSrlNbr  varchar(10);  // System Serial number
             outFeature varchar(4);   // Feature Code
             outProcGrp varchar(4);   // Processor Proup

             outCustID1 varchar(8);   // Your IBM Customer, if entered

             outIBMiVRM varchar(6);   // IBM i VxRyMz
             outTR      int(5);       // IBM i technology refersh level
             outIBMiVER int(5);       // IBM i OS version/release as an INT

             outPARTID  int(5);        // Parition ID
             outPARTNM  varchar(8);    // Partition System Name
             outPARTCP  varchar(8);    // Partition Local CP Name
             outPARTSN  varchar(10);   // Partition Serial Number
             outPARTCNT int(5);        // Number of Partitions

             outHOSTNM  varchar(64);   // Host name

             outPROCCNT int(5);  // Physical processor count
             outRAMGB   int(5);  // Total RAM (in GB)

             outCUSTID2 varchar(8);  // Additional IBM Customer Number 2
             outCUSTID3 varchar(8);  // Additional IBM Customer Number 3
             outCUSTID4 varchar(8);  // Additional IBM Customer Number 4
             outCUSTID5 varchar(8);  // Additional IBM Customer Number 5

             // ------------------------------------------------
             // Input Indicators
             // (NO Input parameters, hence no Input Indicator variables)
             // ------------------------------------------------

             // ------------------------------------------------
             // Output Indicators
             // ------------------------------------------------
             outIndyType    int(5);
             outIndyModel   int(5);
             outIndySrlNbr  int(5);
             outIndyFeature int(5);
             outIndyProcGrp int(5);
             outIndyIBMiVRM int(5);
             outIndyTR      int(5);
             outIndyIBMiVER int(5);
             outIndyCustID1 int(5);
             outIndyPARTCNT int(5);
             outIndyPARTID  int(5);
             outIndyPARTNM  int(5);
             outIndyPARTCP  int(5);
             outIndyPARTSN  int(5);

             outIndyHOSTNM  int(5);

             outIndyPROCCNT int(5);
             outIndyRAMGB   int(5);  // Total_RAM_IN_GB

             outIndyCUSTID2 int(5);
             outIndyCUSTID3 int(5);
             outIndyCUSTID4 int(5);
             outIndyCUSTID5 int(5);

             // Standard SQL parmaeters
             SQLSTATE char(5);
             FUNCNAME char(255);
             specName char(255);
             sqlmsgtext char(128);
             scratchpad LIKEDS(scratch_t);
             sqlOpCode int(10);
          end-pi;


             // ------------------------------------------------
             // MAIN(SYSINFO) BEGIN
             // ------------------------------------------------

             // ------------------------------------------------
             // If SQL OPCODE = OPEN, then do startup things if needed.
             // ------------------------------------------------
             if (sqlOpCode = SQLUDF_TF_OPEN);
                scratchPad = *ALLX'00';
                scratchpad.eof = 0;
                scratchpad.counter = 0;
             endif;

             // ------------------------------------------------
             // If END-OF-FILE is on, we set SQLSTATE and return
             // ------------------------------------------------
             if (scratchPad.eof <> 0);
                 sqlstate = '02000';
                 return;
             endif;

             // ------------------------------------------------
             // If SQL OPCODE = FETCH, then "read" the data
             // and set each output column to their value.
             // ------------------------------------------------
             if (sqlOpCode = SQLUDF_TF_FETCH);
               // Since we're returning only 1 row, we immediately set on EOF
               scratchPad.EOF = 1;  // Only one pass through allowed

               // Get the dotted host name using the BSD 4.3 syntax
               if (gethostname(pHostname : %size(hostname)) = 0);
                 outHOSTNM = %str(pHostName);
               endif;

               // Get the contact inforamtion record from the contact database
               // Note: This is the IBM Customer's contact info.
               // That is, the IBM Customer who owns this system.
               if (getContactInfo( contactInfo ) > 0);
                 if (contactInfo.Customer_Number_Id1 <> ' ');
                   outCustID1 = contactInfo.Customer_Number_Id1;
                 endif;
                 if (contactInfo.Customer_Number_Id2 <> ' ');
                   outCUSTID2 = contactInfo.Customer_Number_Id2;
                 endif;
                 if (contactInfo.Customer_Number_Id3 <> ' ');
                   outCUSTID3 = contactInfo.Customer_Number_Id3;
                 endif;
                 if (contactInfo.Customer_Number_Id4 <> ' ');
                   outCUSTID4 = contactInfo.Customer_Number_Id4;
                 endif;
                 if (contactInfo.Customer_Number_Id5 <> ' ');
                   outCUSTID5 = contactInfo.Customer_Number_Id5;
                 endif;
               endif;

               // Generate the simple IBM i operating system version/release
               // using CEEGPID. It is extracted as an int but is returned
               // as an SQL SMALLINT (or RPG IV INT(5)) value.
              CEEGPID( VER : platform : *OMIT);
              outIBMiVER = VER;

               // Find the IBM i Technology Refresh Level.
               // If a parameter is passed, then it is populated
               // with the IBM i operating system version/release/modification
               // using the format VxRyMz
               //
              outTR = getTR(outIBMiVRM);

                // Use MATMATR1 to get Network Information
              mchInfo.return_Buffer = *ALLX'00';
              mchInfo.Template_Size = %size(mchInfo);
              mchInfo.bytes_Used    = 0;
              MATMATR1( mchInfo : m0130);
              APPN_data = mchInfo.APPN_DATA;

                // Use MATMATR1 to get Virtual Product Information
              mchInfo.return_Buffer = *ALLX'00';
              mchInfo.Template_Size = %size(mchInfo);
              mchInfo.bytes_Used    = 0;
              MATMATR1( mchInfo : m012C);
              VPD_data = mchInfo.VPD_DATA;

                // Use MATMATR1 to get Virtual Partition Information
              mchInfo.return_Buffer = *ALLX'00';
              mchInfo.Template_Size = %size(mchInfo);
              mchInfo.bytes_Used    = 0;
              MATMATR1( mchInfo : m01E0);
              LPAR_data = mchInfo.LPAR_DATA;

                // Use MATMATR1 to get Processor Information
              mchInfo.return_Buffer = *ALLX'00';
              mchInfo.Template_Size = %size(mchInfo);
              mchInfo.bytes_Used    = 0;
              MATMATR1( mchInfo : m01DC);
              PROC_data = mchInfo.PROC_DATA;


             // ------------------------------------------------
             // Copy each collected dataset to the output columns
             // ------------------------------------------------

                 // VPD_Data
              outFeature = VPD_data.CEC_Info.Feature_Code;
              outSrlNbr  = VPD_data.CEC_Info.Serial_No;
              outModel   = %TRIML(VPD_data.CEC_Info.Model);
              outType    = VPD_data.CEC_Info.Type;
              outProcGrp = %TRIM(VPD_data.CEC_Info.Group_Id);

              outRAMGB = VPD_data.Mem_Installed_B / 1024;


                 // APPN_Data
                 // Local Control Point name
               outPARTCP = %trimR(APPN_data.CP_Name);
               outPARTNM = %trimR(APPN_data.Sys_Name);

                 // LPAR_Data
               outPARTSN = LPAR_data.logical_ser_num;
               outPARTID = LPAR_data.partition_id2;
               outPARTCNT = LPAR_data.num_of_partition2;

                 // PROC_Data
               outPROCCNT = PROC_data.numProcessors;

            endif;
         end-proc;


             // ------------------------------------------------
             // Extract the Customer contact record
             // ------------------------------------------------
         dcl-proc getContactInfo ;
          dcl-pi  getContactInfo int(10);
            custInfo likeDS(CNTI0100_t);
          end-pi;
           dcl-s APIFMT CHAR(8) INZ('CNTI0100');
           dcl-s rtnSize INT(10) inz(%size(CNTI0100_t));
           dcl-ds ec  LIKEDS(QUSEC_T) Inz(*LIKEDS);

           custInfo = *ALLX'00';

           QEDRTVCI(custInfo : rtnSize : APIFMT : ec);
           if (ec.Bytes_Returned = 0);
             return custInfo.Bytes_Return;
           endif;
           return -1;
         end-proc;


             // ------------------------------------------------
             // Find the IBM i OS VRM and TR Level
             // ------------------------------------------------
         dcl-proc getTR;
           dcl-pi getTR int(10);
            rtnVRM varchar(6) options(*nopass);
          end-pi;
           // RPG IV equivalent of struct Qpz_LSTG0100
           dcl-ds Qpz_LSTG0100_t Qualified Template;
             Name Char(60);
             Description Char(100);
             Level Int(10);
             Status Int(10);
             Tgt_Rls Char(6);            // Target release
             Reserved Char(2);           // Boundary alignment
           End-Ds;

            dcl-s pBuffer pointer;
            dcl-s pList   pointer;
            dcl-s pGenHdr pointer;
            dcl-s pPeak pointer;
            dcl-s pEntry pointer;
            dcl-ds ENTRY  likeds(Qpz_LSTG0100_t) BASED(pENTRY);
            dcl-ds GENHDR likeds(Qus_Generic_Header_0100) BASED(pGenHdr);

            dcl-s APIFMT char(8) inz('LSTG0100');
            dcl-s OSVRM  char(6);
            dcl-s RTNCCSID int(10);
            dcl-s TR int(10) inz(0);
            dcl-s ptfName varchar(1024);
            dcl-s ptfDesc varchar(1024);
            dcl-c trDesc const('TECHNOLOGY REFRESH');
            dcl-s trSize int(10) inz(%SIZE(trDESC));

            dcl-ds fc likeDS(FEEDBACK_T) Inz;
            dcl-ds ec  LIKEDS(QUSEC_T) Inz(*LIKEDS);
            dcl-s osVER    int(10);
            dcl-s platform int(10);
            dcl-s vrm int(10);
            dcl-s rm int(10);
            dcl-s v int(10);
            dcl-s r int(10);
            dcl-s m int(10);
            dcl-s i int(10);
            dcl-s PTFGRP char(20);

            pBuffer = crtTempUsrSpace(PTFGRP);

            TR = 0;

            // 0730
            // 0730 / 100 = 7 REM(30)
            // Materialize the operation system version/release level
            CEEGPID(osVER:platform: *OMIT);
            vrm = %rem(osVER:100);
            v = %DIV(osVER:100);  // V7
            r = %rem(osVER:100);  // R30
            m = %rem(R : 10);     // M0
            r = %DIV(r : 10);     // R3

            osVRM = 'V' + %char(v) + 'R' + %char(r) + 'M' + %char(m);

            getptfGroups(PTFGRP: APIFMT: RTNCCSID: ec);
            if (ec.bytes_Returned > 0);
              return -1;
            endif;

            pGenHdr = pBuffer;
            pList   = pBuffer + genHdr.Offset_List_Data;

            for i = 1 to genHdr.Number_List_Entries;
              pEntry = pList + ((i - 1) * genHdr.Size_Each_Entry);
              if (Entry.Status = 4); // 4=*INSTALLED
                if (%subst(Entry.Description : 1 : trSize) = trDesc and
                    Entry.Tgt_Rls = osvrm );
                  if (entry.Level > TR);
                    TR = entry.Level;
                  endif;
                endif;
              endif;
            endfor;

            if (%Parms() >= %ParmNum(rtnVRM) and %addr(rtnVRM) <> *null);
              rtnVRM = osVRM;
            endif;

            reset ec;
            QUSDLTUS( PTFGRP : ec );
            return TR;
          end-proc;

             // ------------------------------------------------
             // Helper function to create a uniquely named
             // *USRSPC (user space) in library QTEMP.
             // ------------------------------------------------
           dcl-proc crtTempUsrSpace;
             dcl-pi crtTempUsrSpace pointer;
                rtnUsrSpaceName char(20) OPTIONS(*NOPASS);
             end-pi;
             dcl-s tempName char(20) INZ(*ALLX'00');
             dcl-s pos int(10);
             dcl-s pUS pointer;
             dcl-s initSize int(10) inz(4096000);
             dcl-s auth char(10) inz('*LIBCRTAUT');
             dcl-s initChar char(1) inz(X'00');
             dcl-s REPLACE char(10) INZ('*YES');
             dcl-ds ec LIKEDS(QUSEC_T) INZ(*LIKEDS);
                // have the system come up with a unique/temp name
             tmpName( tempName );
                // Find the slash (returned as lib/xxxxxxxxxxxx)
             pos = %scan('/' : tempName);
                // Extract just the file name
             tempName = %subst(tempName : pos + 1);
                // Qualify the file to QTEMP
             %subst(tempName : 11: 10) = 'QTEMP';
                // Create a *USRSPC in QTEMP using the unique name
             QUSCRTUS( tempName : 'GROUP_PTFS' :
                       initSize :
                       initChar :
                       auth :
                       'Temp user space for MCHINFO SQL UDF' :
                       REPLACE :
                       ec);
             if (ec.Bytes_Returned = 0);  // Okay to go?
               reset ec;
                // Grap the point to that *USRSPC to return it to caller
               QUSPTRUS( tempName : pUS : ec);
             endif;
                // If the user passed in a name parameter
                // then copy the temp user space name to that parameter.
             if (%parms() >= %ParmNUM(rtnUsrSpaceName) and
                 %addr(rtnUsrSpaceName) <> *NULL);
                rtnUsrSpaceName = tempName;
             endif;
              // return a pointer to the user space (can be ignored)
             return pUS;
           end-proc;
 

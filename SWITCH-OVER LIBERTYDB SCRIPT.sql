		
SWITCH-OVER SCRIPT:-
---------------------

Table of Contents
1.0	PURPOSE:	4
2.0	SCOPE:	4
3.0	RESPONSIBILITIES:	4
4.0	PREREQUISITES	4
5.0	SWITCHING OVER A DATABASE :	4

 
1.0	 PURPOSE:
This SOP provides detail  procedure for performing a Manual switchover between the primary and 
standby databases in an Oracle environment. This process Ensures the continuity of database operations 
with minimal downtime. 
2.0	 SCOPE:
This SOP applies To all database Administrators (DBAs) responsible for managing Oracle databases that 
are configured with Data Guard.
3.0	 RESPONSIBILITIES:
•	Database Administrator (DBA): Execute the procedure, ensure prerequisites are met, and verify the success of the switchover.

•	System Administrator: Approve the switchover plan and notify the stakeholders of planned downtime. 
4.0	PREREQUISITES
1.	Primary and Standby Configuration: Ensure you have a properly configured Oracle Data Guard environment with a primary and at least one standby database.
2.	Synchronization: Both databases must be synchronized (apply all logs).
3.	Verify Readiness: Verify that the primary and standby are ready for a switchover using the SWITCHOVER_STATUS column in the V$DATABASE view.
5.0	 SWITCHING OVER A DATABASE :
Switching over a database in Oracle typically involves transitioning the primary database To a standby 
role and the standby database To a primary role. This process is commonly used in disaster recovery and 
high availability configurations and is often part of Oracle Data Guard. 

Data Guard:
Switchover
•	Planned failover To standby database
•	Original primary becomes new standby
•	Original standby becomes new primary
•	No data loss
•	Can switchback at any time

•	Switching over a database in Oracle involves transitioning From the primary database To a standby database. Here are basic steps for a manual switchover:

•	The main steps involve ensuring that both the primary and standby databases are synchronized, followed by executing the switchover commands provided below.

Step1: Check Prerequisites: 
•	Total Time taken for the activity To complete Duration:30 Minutes

•	Ensure check the status of database and services in primary and standby :

DC-1 SOURCE :-

•	IP Address : 10.102.123.11/12
•	Host name : prdbawdb1.cdchial.in, prdbawdb2.cdchial.in
•	Database name : LIBERTYDB

DC-2 TARGET :-

•	IP Address : 10.102.223.11/12
•	Host name : cdc2prdbawdb1.cdchial.in , cdc2prdbawdb2.cdchial.in
•	Database name : LIBERTYDBSTBY


TO KNOW DATABASE DETAILS:-

ps -ef | grep pmon
srvctl status database -d LIBERTYDB
srvctl status service -d LIBERTYDB
srvctl status listener
lsnrctl status
 

Grid:-

crsctl check cluster -all
crsctl check crs
crsctl status resource -t
---------------------------------------------------------------------------
---------------------------------------------------------------------------

•	Ensure both primary and standby databases are in sync: Duration: 15 Minutes

set lines 200 pages 200;
select name,INSTANCE_NUMBER,INSTANCE_NAME,STATUS,OPEN_MODE,switchover_status from gv$instance a,gv$database b  where a.inst_id=b.inst_id;


•	Verify that the databases are running in ARCHIVELOG mode:

archive log list;


•	Confirm the Data Guard configuration is properly set up:

show parameter DB_UNIQUE_NAME=PRIM
show parameter LOG_ARCHIVE_CONFIG='DG_CONFIG=(PRIM,STANBY)'
show parameter LOG_ARCHIVE_DEST_STATE_1=ENABLE
show parameter LOG_ARCHIVE_DEST_STATE_2=ENABLE
show parameter LOG_ARCHIVE_DEST_1='LOCATION=/arch1/ VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=PRIM'  sid='*' scope=both;
show parameter LOG_ARCHIVE_DEST_2='SERVICE=STANBY VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=STANBY'

PRIMARY NODE-1:-
 
PRIMARY NODE-2:-

STANDBY NODE-1:-

STANDBY NODE-2:-
 
•	Confirm the RAM & STORAGE configuration is properly set up: 
df -h
free -h

PRIMARY NODE-1:-

PRIMARY NODE-2:-
 
STANDBY NODE-1:-

STANDBY NODE-2:-
---------------------------------------------------------------------------
---------------------------------------------------------------------------


•	Time Taken for Backup procedure To complete  Duration:09 Minutes

sh /dbbkp/scripts/backupliberty.sh LIBERTYD1  full  > /tmp/full_libbackup.log


---------------------------------------------------------------------------
---------------------------------------------------------------------------

Step 2: Verify Switchover Readiness

•	Verify the readiness of the standby database for switchover:
•	First, we should know the database name, role,db unique name,mode IN BOTH SIDES.
•	 Time taken for readiness check Duration: 04 Minutes

SQL >
set lines 200 pages 200;
select name,INSTANCE_NUMBER,INSTANCE_NAME,STATUS,OPEN_MODE,switchover_status from gv$instance a,gv$database b  where a.inst_id=b.inst_id;


SQL >	
set lines 300 pages 300;
col DB_UNIQUE_NAME for a10;
select name,db_unique_name,open_mode,DATABASE_ROLE,PROTECTION_MODE,SWITCHOVER#,SWITCHOVER_status,current_scn from v$database;


SQL >
select STATUS, GAP_STATUS from V$ARCHIVE_DEST_STATUS where DEST_ID = 2;

---------------------------------------------------------------------------
---------------------------------------------------------------------------

Step 3: Connect To Primary Database
•	Use SQL*Plus or another SQL client To connect database.
•	Run the command below To connect the primary database and verify switchover status.

Command: Primary> SQL > alter database switchover To LIBERTYDBSTBY verify;
 
•	Time taken To connect Duration: 01 Minutes.


•	Run the command below To verify the gap status.

For Primary: SQL > select STATUS, GAP_STATUS From V$ARCHIVE_DEST_STATUS where DEST_ID = 2;

For Standby: SQL > select NAME, VALUE, DATUM_TIME From V$DATAGUARD_STATS;


•	Shutdown the second node in primary database duration:01 minute
For Primary: SQL > shut immediate;


•	Shutdown the second node in standby database  Duration:01 Minute
For Standby: SQL > shut immediate;

---------------------------------------------------------------------------
---------------------------------------------------------------------------

Step 4: Initiate Switchover on Primary

•	On the primary database, initiate the switchover:

Command: SQL >	ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;

•	Time taken for switchover  Duration:02 Minutes

---------------------------------------------------------------------------
---------------------------------------------------------------------------

Step 5: Monitor Switchover

•	Run the command below to monitor the switchover progress:

Command: SQL >	SELECT SWITCHOVER_STATUS FROM V$DATABASE;

•	Time taken: Duration:02 Minutes

---------------------------------------------------------------------------
---------------------------------------------------------------------------

Step 6: Connect Standby Database

•	Connect To the standby database using SQL*Plus or another SQL client.
•	Time taken: Duration:02 Minutes
---------------------------------------------------------------------------
---------------------------------------------------------------------------

Step 7: Complete Switchover:

•	Run the below command on the standby database to complete the switchover process.

Command: SQL > ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;  
---------------------------------------------------------------------------
---------------------------------------------------------------------------

Step 8: Monitor Switchback Process

•	Run the command below to monitor switchback process

Command: SQL >	SELECT SWITCHOVER_STATUS FROM V$DATABASE;

•	Time taken: Duration:03 Minutes

---------------------------------------------------------------------------
---------------------------------------------------------------------------

Step 9: Verify Switchover Success:

•	Confirm the switchover success on both the primary and standby databases.
•	Command: new primary > alter database open;
stand by >	alter database open;
•	Time taken: Duration:10 Minutes
---------------------------------------------------------------------------
---------------------------------------------------------------------------

Step 10: Start the Services

•	Start the services and check the status by using srvctl command. 

srvctl status service -d libertydbstby
srvctl start service -d libertydbstby
srvctl status service -d libertydbstby

•	Time takenDuration:07 Minutes
•	Update client connections to point the new primary database.
---------------------------------------------------------------------------
---------------------------------------------------------------------------

Step 11: Check Status

•	Check the sync status from DC2 to DC1.
•	Both primary and standby databases are in sync gap as of now Duration:25 Minutes 
•	Enable Primary.

------------------------------------------------------------
alter system set log_archive_dest_state_2=defer scope=both sid='*';
alter system set log_archive_dest_state_2=enable scope=both sid='*';


For gap checkup in primary:-
-------------------------------
set scan on
set feed off
set linesize 200
BREAK ON ROW SKIP 1s
column thread format a6;
column "PR - Archived" format a13;
column "STBY - Archived" format a15;
column "STBY - Applied" format a14;
column "Shipping GAP (PR -> STBY)" format a25;
column "Applied GAP (STBY -> STBY)" format a26;
--ACCEPT DEST PROMPT 'Enter the Standby Archive Log Destination :  '
SELECT   *
FROM   (SELECT   LPAD (t1, 4, ' ') "Thread",
LPAD (pricre, 9, ' ') "PR - Archived",
LPAD (stdcre, 10, ' ') "STBY - Archived",
LPAD (stdnapp, 9, ' ') "STBY - Applied",
LPAD (pricre - stdcre, 13, ' ')
"Shipping GAP (PR -> STBY)",
LPAD (stdcre - stdnapp, 15, ' ')
"Applied GAP (STBY -> STBY)"
FROM   (  SELECT   MAX (sequence#) stdcre, thread# t1
FROM   v$archived_log
WHERE   standby_dest = 'YES'
AND resetlogs_id IN
(SELECT   MAX (RESETLOGS_ID)
FROM   v$archived_log)
AND thread# IN (1, 2, 3, 4)
GROUP BY   thread#) a,
(  SELECT   MAX (sequence#) stdnapp, thread# t2
FROM   v$archived_log
WHERE   standby_dest = 'YES'
AND resetlogs_id IN
(SELECT   MAX (RESETLOGS_ID)
FROM   v$archived_log)
AND thread# IN (1, 2, 3, 4)
AND applied = 'YES'
GROUP BY   thread#) b,
(  SELECT   MAX (sequence#) pricre, thread# t3
FROM   v$archived_log
WHERE   standby_dest = 'NO'
AND resetlogs_id IN
(SELECT   MAX (RESETLOGS_ID)
FROM   v$archived_log)
AND thread# IN (1, 2, 3, 4)
GROUP BY   thread#) c
WHERE   a.t1 = b.t2 AND b.t2 = c.t3 AND c.t3 = a.t1)
ORDER BY   1
/
set feed on
break on off



---------------------------------------------------------------------------
---------------------------------------------------------------------------

IN STANDBY CHECK UP:-
----------------------
SELECT ARCH.THREAD# "Thread", ARCH.SEQUENCE# "Last Sequence Received", APPL.SEQUENCE# "Last Sequence Applied", (ARCH.SEQUENCE# - APPL.SEQUENCE#) "Difference"
          FROM
         (SELECT THREAD# ,SEQUENCE# FROM V$ARCHIVED_LOG WHERE (THREAD#,FIRST_TIME ) IN (SELECT THREAD#,MAX(FIRST_TIME) FROM V$ARCHIVED_LOG GROUP BY THREAD#)) ARCH,
         (SELECT THREAD# ,SEQUENCE# FROM V$LOG_HISTORY WHERE (THREAD#,FIRST_TIME ) IN (SELECT THREAD#,MAX(FIRST_TIME) FROM V$LOG_HISTORY GROUP BY THREAD#)) APPL
         WHERE
         ARCH.THREAD# = APPL.THREAD#
          ORDER BY 1;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
set lines 100;
set pages 100;
select status,process,thread#,SEQUENCE#,block#,blocks From v$managed_standby;






/*
____________ ___  ___  ___   _   _	
|  _  \ ___ \|  \/  | / _ \ | \ | |	
| | | | |_/ /| .  . |/ /_\ \|  \| |	
| | | | ___ \| |\/| ||  _  || . ` |	
| |/ /| |_/ /| |  | || | | || |\  |	
|___/ \____/ \_|  |_/\_| |_/\_| \_/	
         ______						
        |_2016_|						
*/

create procedure dbo.sp_who2k5
 @activeOnly   bit = null,  -- If set (1), we return information on active requests only…
 @includeSqlText  bit = 0,  -- If set (1), we return the full sql text for the available sql_handle's…
 @includeQueryPlan bit = 0   -- If set (1), we return the XML query plan for the available plan handle's…
as
/*



NOTE: This procedure requires the following modules:


 1) master.dbo.fn_getProcessData()
 
*/
set nocount on;


-- Print some usage data for usability if needed…
if @activeOnly is null begin
 print 'USAGE: ';
 print '    exec dbo.sp_who2k5 @activeOnly, @includeSqlText, @includeQueryPlan;';
 print '';
 print '    @activeOnly – If set (1), we return information on active requests only';
 print '    @includeSqlText – If set (1), we return the full sql text for the available sql_handles';
 print '    @includeQueryPlan – If set (1), we return the XML query plan for the available plan handles';
 print '';
 print '    Wrapper procedure around the UDF master.dbo.fn_getProcessData() – accepts exact same arguments.';
 print '';
end


-- Format as needed…
select @activeOnly = case when @activeOnly > 0 then @activeOnly else 0 end;


-- Get the response…
select sessionId,blockingSessionId,requestStatus,dbName,waitType,waitTime,lastWaitType,requestCommand,loginName,originalLoginName,
  openTranCount,openResultSetCount,percentComplete,requestCpuTime,requestElapsedTime,requestReads,requestWrites,waitResource,
  requestId,requestStartTime,requestLogicalReads,requestRowCount,requestQueryMemory,sessionStatus,loginTime,hostName,programName,
  sessionLastRequestStartTime,sessionLastRequestEndTime,sessionReads,sessionWrites,sessionLogicalReads,sessionRowCount,connectTime,
  netTransport,connectionPacketReads,connectionPacketWrites,netPacketSize,clientNetAddress,connectionMostRecentSqlHandle,sessionCpuTime,
  sessionMemUsage,sessionScheduledTime,sessionElapsedTime,clientInterface,contextInfo,authScheme,connectionLastRead,connectionLastWrite,
  planHandle,sqlHandle,queryPlan,sqlText
from master.dbo.fn_getProcessData(@activeOnly, @includeSqlText, @includeQueryPlan);
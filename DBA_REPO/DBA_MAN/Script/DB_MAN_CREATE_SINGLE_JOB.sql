drop procedure [dbo].[DB_MAN_CREATE_SINGLE_JOB] 
go
CREATE procedure [dbo].[DB_MAN_CREATE_SINGLE_JOB] 
@job nvarchar(128),
@mycommand nvarchar(max), 
@servername nvarchar(28),
@startdate nvarchar(8),
@starttime nvarchar(8)
as

--delete if exists
DECLARE @jobId BINARY(16)

SELECT @jobId = CONVERT(uniqueidentifier, job_id) FROM msdb.dbo.sysjobs
WHERE name = @job



if @jobId is not null 
	EXEC msdb.dbo.sp_delete_job @job_id=@jobId, @delete_unused_schedule=1


EXEC msdb.dbo.sp_add_job
    @job_name = @job ,
	@description=N'Jobs Create by DB MAN '	;
--Add a job step named process step. This step runs the stored procedure
EXEC msdb.dbo.sp_add_jobstep
    @job_name = @job,
    @step_name = N'DBA MAN Step',
    @subsystem = N'TSQL',
    @command = @mycommand
--Schedule the job at a specified date and time
exec msdb.dbo.sp_add_jobschedule @job_name = @job,

			@name = 'DBA MAN Daily schedule',
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=1, 
			@freq_subday_interval=0, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=@startdate, 
			@active_end_date=99991231, 
			@active_start_time=@starttime, 
			@active_end_time=235959
-- Add the job to the SQL Server Server
EXEC msdb.dbo.sp_add_jobserver
    @job_name =  @job,
    @server_name = @servername



/*
exec dbo.DB_MAN_CREATE_SINGLE_JOB 
@job = 'DB_MAN_JOB_#1', -- The job name
@mycommand = 'exec DB_MAN_Get_List_Backup', -- The T-SQL command to run in the step
@servername = @@Servername, -- SQL Server name. If running localy, you can use @servername=@@Servername
@startdate = '20160801', -- The date August 29th, 2013
@starttime = '000000' -- The time, 16:00:00

exec dbo.DB_MAN_CREATE_SINGLE_JOB 
@job = 'DB_MAN_JOB_#2', -- The job name
@mycommand = 'exec DB_MAN_Get_List_Backup', -- The T-SQL command to run in the step
@servername = @@Servername, -- SQL Server name. If running localy, you can use @servername=@@Servername
@startdate = '20160801', -- The date August 29th, 2013
@starttime = '010000' -- The time, 16:00:00

exec dbo.DB_MAN_CREATE_SINGLE_JOB 
@job = 'DB_MAN_JOB_#3', -- The job name
@mycommand = 'exec DB_MAN_Gen_AuditLevel', -- The T-SQL command to run in the step
@servername = @@Servername, -- SQL Server name. If running localy, you can use @servername=@@Servername
@startdate = '20160801', -- The date August 29th, 2013
@starttime = '010000' -- The time, 16:00:00
*/
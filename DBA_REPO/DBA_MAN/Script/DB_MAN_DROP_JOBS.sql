create procedure DB_MAN_DROP_JOBS
	(
	@JOBS_NAME varchar(1000)
	)
as

BEGIN
	DECLARE @jobId BINARY(16)

	SELECT @jobId = CONVERT(uniqueidentifier, job_id) FROM msdb.dbo.sysjobs
	WHERE name = @JOBS_NAME

	EXEC msdb.dbo.sp_delete_job @job_id=@jobId, @delete_unused_schedule=1
END 

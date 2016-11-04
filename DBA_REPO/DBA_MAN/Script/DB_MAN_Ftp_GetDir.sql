
if exists (select * from sysobjects where id = object_id(N'[dbo].[DB_MAN_Ftp_GetDir]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].DB_MAN_Ftp_GetDir
GO

Create procedure DB_MAN_Ftp_GetDir
	@FTPServer	varchar(128) ,
	@FTPUser	varchar(128) ,
	@FTPPWD		varchar(128) ,
	@FTPPath	varchar(128) ,
	@workdir	varchar(128)
as
/*
exec DB_MAN_Ftp_GetDir  'firewall.securitysend.org', 'friedrich', 'kill.,2005', '', 'F:\DBA_MAN\gen_file\'
*/

declare	@cmd varchar(1000)
declare @workfilename varchar(128)
	
	select @workfilename = 'ftpcmd.txt'
	
	-- deal with special characters for echo commands
	select @FTPServer	= replace(replace(replace(@FTPServer, '|', '^|'),'<','^<'),'>','^>')
	select @FTPUser		= replace(replace(replace(@FTPUser, '|', '^|'),'<','^<'),'>','^>')
	select @FTPPWD		= replace(replace(replace(@FTPPWD, '|', '^|'),'<','^<'),'>','^>')
	select @FTPPath		= replace(replace(replace(@FTPPath, '|', '^|'),'<','^<'),'>','^>')
	
	select	@cmd = 'echo '					+ 'open ' + @FTPServer
			+ ' > ' + @workdir + @workfilename
	exec master..xp_cmdshell @cmd , no_output 
	select	@cmd = 'echo '					+ @FTPUser
			+ '>> ' + @workdir + @workfilename
	exec master..xp_cmdshell @cmd, no_output

	select	@cmd = 'echo '					+ @FTPPWD
			+ '>> ' + @workdir + @workfilename
	exec master..xp_cmdshell @cmd ,no_output

	select	@cmd = 'echo '					+ 'dir ' + @FTPPath
			+ ' >> ' + @workdir + @workfilename
	exec master..xp_cmdshell @cmd ,no_output

	select	@cmd = 'echo '					+ 'quit'
			+ ' >> ' + @workdir + @workfilename

	exec master..xp_cmdshell @cmd ,no_output

	
	select @cmd = 'ftp -s:' + @workdir + @workfilename
	


	create table #a (
					id int identity(1,1), 
					s varchar(1000),

					)
	
	insert #a
	exec master..xp_cmdshell @cmd
	

	
	delete from #a where s is null 
	delete top(5) from #a 
	delete from #a where s='quit'
	
	--select id, s from #a
	--select id, replace(s,' ',',') from #a
	update #a set s=[dbo].[DB_MAN_Clean_Space](s) 
	
	SELECT 
	id
	,dbo.DB_MAN_SplitIndex(' ', s, 1) as [right] 
	--,upper(substring(dbo.DB_MAN_SplitIndex(' ', s, 1),1,1)) as [npi]
	
	,case upper(substring(dbo.DB_MAN_SplitIndex(' ', s, 1),1,1))
		When 'D' Then 'Directory'
		When '-' Then 'File'
		Else  'none'
	End as Structure
	
	, dbo.DB_MAN_SplitIndex(' ', s, 2) as SubItem 
	, dbo.DB_MAN_SplitIndex(' ', s, 3) as ownergroup 
	, dbo.DB_MAN_SplitIndex(' ', s, 4) as ownerlocal
	, dbo.DB_MAN_SplitIndex(' ', s, 5) as size
	, dbo.DB_MAN_SplitIndex(' ', s, 6) as [Month]
	, dbo.DB_MAN_SplitIndex(' ', s, 7) as [Day]
	, dbo.DB_MAN_SplitIndex(' ', s, 8) as [Time_Year]	
	, SUBSTRING(s,CHARINDEX(dbo.DB_MAN_SplitIndex(' ', s, 8), s)+len(dbo.DB_MAN_SplitIndex(' ', s, 8)),len(s)) as [Folder_File]
	,s as [FULL_STRING] 
	into #Output
	from #a
	Select * from #Output
	drop table #Output
	drop table #a

go

/*
exec DB_MAN_Ftp_GetDir  'firewall.securitysend.org', 'friedrich', 'kill.,2005', '/friedrich', 'F:\DBA_MAN\gen_file\'
*/



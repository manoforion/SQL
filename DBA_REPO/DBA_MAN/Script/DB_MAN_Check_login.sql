
drop procedure DB_MAN_Check_login
go
create procedure DB_MAN_Check_login
as
BEGIN

	create table #result
		(	name varchar(1000),
			[action] varchar(1000),
			[registry] varchar(1000),
			[alert] int
		) 

	insert into #result 
	SELECT name,type_desc,'Empty' as Type_fail,3
	FROM sys.sql_logins 
	WHERE PWDCOMPARE('',password_hash)=1;

	insert into #result 
	SELECT name,type_desc,'Login and Password the same' as Type_fail,3
	FROM sys.sql_logins 
	WHERE PWDCOMPARE(name,password_hash)=1;

	--select * from #result 

	delete from [DB_MAN].[dbo].[DB_MAN_ALERT] where [action] ='SQL_LOGIN'
	
	insert into [DB_MAN].[dbo].[DB_MAN_ALERT] 
	--select * from  [DB_MAN].[dbo].[DB_MAN_ALERT] 
	
	select db_id('msdb') as id_db,'MSDB' as [db_name],'SQL_LOGIN' as [action] , [DB_MAN_CATALOG_OBJET]  as [value] , [registry]   as [registry] , alert FROM #Result

	drop table #result 

END

DB_MAN_Check_login
select * from  [DB_MAN].[dbo].[DB_MAN_ALERT] 


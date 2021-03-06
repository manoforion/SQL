
CREATE Procedure DB_MAN_SHOW_NOTIF

--Sistema de Notificacion de Permisos de SQL por mail

As
Begin

declare @name as nvarchar( max)
declare @cmd as nvarchar( max)
declare @cnt int

set @cnt = 1

create table #temp
(server_name nvarchar (max ),
level nvarchar (max ),
login_name sysname,
dbname nvarchar( max),
db_role sysname,
issysadmin bit,
issecurityadmin bit,
isserveradmin bit,
issetupadmin bit,
isprocessadmin bit,
isdiskadmin bit,
isdbcreator bit,
isbulkadmin bit)

--set @name = (select top 1 name from sys .sysdatabases order by name)
set @name = (select    top 1 name from sys .sysdatabases where not [version] is null and version <> 0 order by name)
while @name IS NOT NULL
begin

set @cmd = 'select @@servername as server_name,
case when (l.sysadmin = 1) then ''server'' else ''database'' end as level,
u1.name as login_name, ''' +@name + ''', u2.name as role_db,
l.sysadmin as issysadmin, l.securityadmin as issecurityadmin, l.serveradmin as isserveradmin,
l.setupadmin as issetupadmin, l.processadmin as isprocessadmin, l.diskadmin as isdiskadmin,
l.dbcreator as isdbcreator, l.bulkadmin as isbulkadmin
from ['+@name +'].sys.sysusers u1,
['+@name +'].sys.sysusers u2,
['+@name +'].sys.database_role_members p,
['+@name +'].sys.syslogins l
where u1.uid = p.member_principal_id and u2.uid = p.role_principal_id
and l.sid = u1.sid'

insert into #temp
exec sp_executesql @cmd

set @cnt = @cnt+1

set @name = (select top 1 name from sys .sysdatabases where name > @name and (not [version] is null and version <> 0 ) order by name)
end

declare @GLOSA as Varchar( max),
            @Notificacion as Varchar (1024),
            @TO as varchar (128),

            @CC as varchar (128),
            @asunto as varchar (512),
            @incrustado as Varchar (max),
            @firma as varchar (512)

             DECLARE @Html AS VARCHAR( MAX)
             DECLARE @TEMP as VARCHAR( MAX)

             -- limpio lo que no se debe ver
             delete from #temp where [level] ='server'
             delete from #temp where db_role ='db_datareader'
             delete from #temp where db_role ='sololectura'

             SET @TEMP = 'select * from #temp'
             EXECUTE DB_MAN_ConvertTableToHtml_include @temp, @Html OUTPUT

             set @TO = 'claudio.aguilera@vitamina.com'
             set @CC = 'friedrich@vitamina.com'
             Set @GLOSA = 'Estimado Claudio <br> De acuerdo al Sistema automatico de registro de acceso a las Bases de Datos :'
             set @notificacion = 'Solicitamos  notificar que permisos en las bases de datos se deben desactivar.'
             set @asunto = 'Envio de reporte de Base de Datos'
             set @incrustado = @Html
             set @firma = 'DB_MAN'

             exec DB_MAN_TEMPLATE_MAIL @TO ,@CC ,@asunto ,@GLOSA , @Notificacion ,@incrustado ,@firma

 --select * from #temp
drop table #temp
end
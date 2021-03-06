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
CREATE procedure dbo.sp_cmddir @path varchar(300)
as
/*
Procedure to list files in folder @path
using xp_cmdshell and DOS dir command
*/
set nocount on
declare @err int ; set @err = 0
declare @cmd varchar(350)

create table #dir([filename] varchar(200) NULL)

set @cmd = 'DIR /B /A-D ' + @path

insert #dir exec master.dbo.xp_cmdshell @cmd
select @err = @@error

if @err<>0
begin
        raiserror('Error listing files',16,1)
        return 1
end

select [filename] from #dir 
where NULLIF([filename],'') IS NOT NULL

drop table #dir
return 0

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
CREATE procedure dbo.sp_xpdir @path varchar(300)
as
/*
Procedure to list files in folder @path
xp_dirtree is undocumented and unsupported
the alternative is to use xp_cmdshell and DIR
*/
set nocount on
declare @err int ; set @err = 0

create table #dir([filename] varchar(200) NOT NULL,
                  [depth] int NOT NULL,
                  [file] int NOT NULL)

insert #dir exec master.dbo.xp_dirtree @path,1,1
select @err = @@error

if @err<>0
begin
        raiserror('Error listing files',16,1)
        return 1
end

select [filename] from #dir 
 where [file]=1 and [depth]=1

drop table #dir
return 0

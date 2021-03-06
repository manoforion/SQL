/*
____________ ___  ___  ___   _   _	
|  _  \ ___ \|  \/  | / _ \ | \ | |	
| | | | |_/ /| .  . |/ /_\ \|  \| |	
| | | | ___ \| |\/| ||  _  || . ` |	
| |/ /| |_/ /| |  | || | | || |\  |	
|___/ \____/ \_|  |_/\_| |_/\_| \_/	
         ______						
        |_2016_|						
*/create PROCEDURE [dbo].[Log]
    @Message NVARCHAR(512),
    @RowCount INT = null OUTPUT,
    @Delimiter NCHAR(1) = N' ',
    @PadChar NCHAR(1) = N'-'
AS
    BEGIN
        SET @RowCount = @@ROWCOUNT;

        DECLARE @LogDate AS NVARCHAR(50);
        DECLARE @RowCountPadded AS NCHAR(8);

        SET @LogDate = CONVERT(NVARCHAR(50),GETDATE(),121);
        SELECT @RowCountPadded = CASE @RowCount WHEN 0 THEN REPLICATE(@PadChar,8) ELSE REPLACE(STR(@RowCount, 8), SPACE(1), @PadChar) END; 

        SET @Message = @LogDate + @Delimiter + @RowCountPadded + @Delimiter + @Message;
        RAISERROR (@Message, 0, 1) WITH NOWAIT;
    END

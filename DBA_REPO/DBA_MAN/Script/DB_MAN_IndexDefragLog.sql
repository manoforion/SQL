/* First, we need to take care of schema updates, in case you have a legacy
   version of the script installed */
DECLARE @indexDefragLog_rename      VARCHAR(128)
  , @indexDefragExclusion_rename    VARCHAR(128)
  , @indexDefragStatus_rename       VARCHAR(128);

SELECT  @indexDefragLog_rename = 'DB_MAN_IndexDefragLog_obsolete_' + CONVERT(VARCHAR(10), GETDATE(), 112)
      , @indexDefragExclusion_rename = 'DB_MAN_IndexDefragExclusion_obsolete_' + CONVERT(VARCHAR(10), GETDATE(), 112);

IF EXISTS ( SELECT  [object_id]
            FROM    sys.indexes
            WHERE   name = 'PK_indexDefragLog' )
    EXECUTE sp_rename DB_MAN_IndexDefragLog, @indexDefragLog_rename;

IF EXISTS ( SELECT  [object_id]
            FROM    sys.indexes
            WHERE   name = 'PK_indexDefragExclusion' )
    EXECUTE sp_rename DB_MAN_IndexDefragExclusion, @indexDefragExclusion_rename;

IF NOT EXISTS ( SELECT  [object_id]
                FROM    sys.indexes
                WHERE   name = 'PK_indexDefragLog_v40' )
BEGIN

    CREATE TABLE dbo.DB_MAN_IndexDefragLog
    (
         indexDefrag_id     INT IDENTITY(1, 1)  NOT NULL
       , databaseID         INT                 NOT NULL
       , databaseName       NVARCHAR(128)       NOT NULL
       , objectID           INT                 NOT NULL
       , objectName         NVARCHAR(128)       NOT NULL
       , indexID            INT                 NOT NULL
       , indexName          NVARCHAR(128)       NOT NULL
       , partitionNumber    SMALLINT            NOT NULL
       , fragmentation      FLOAT               NOT NULL
       , page_count         INT                 NOT NULL
       , dateTimeStart      DATETIME            NOT NULL
       , dateTimeEnd        DATETIME            NULL
       , durationSeconds    INT                 NULL
       , sqlStatement       VARCHAR(4000)       NULL
       , errorMessage       VARCHAR(1000)       NULL

        CONSTRAINT PK_indexDefragLog_v40
            PRIMARY KEY CLUSTERED (indexDefrag_id)
    );

    PRINT 'DB_MAN_IndexDefragLog Table Created';

END

IF NOT EXISTS ( SELECT  [object_id]
                FROM    sys.indexes
                WHERE   name = 'PK_indexDefragExclusion_v40' )
BEGIN

    CREATE TABLE dbo.DB_MAN_IndexDefragExclusion
    (
         databaseID         INT             NOT NULL
       , databaseName       NVARCHAR(128)   NOT NULL
       , objectID           INT             NOT NULL
       , objectName         NVARCHAR(128)   NOT NULL
       , indexID            INT             NOT NULL
       , indexName          NVARCHAR(128)   NOT NULL
       , exclusionMask      INT             NOT NULL
            /* 1=Sunday, 2=Monday, 4=Tuesday, 8=Wednesday, 16=Thursday, 32=Friday, 64=Saturday */

         CONSTRAINT PK_indexDefragExclusion_v40
            PRIMARY KEY CLUSTERED (databaseID, objectID, indexID)
    );

    PRINT 'DB_MAN_IndexDefragExclusion Table Created';

END

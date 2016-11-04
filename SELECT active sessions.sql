/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [UserSessionID]
      ,s.[UserID]
      ,au.LastName
      ,s.[LoginTime]
      ,s.[LastAccessTime]
      ,s.[LogoutTime]
      ,s.[RefUserSessionEndActionID]
      ,s.[IPAddress]
      ,s.[Active]
      ,s.[IsApi]
  FROM [CareWebQIDb].[dbo].[UserSession] s
  join appuser au on s.userid = au.userid
  where au.LastName like 'load%'
  order by s.[LoginTime] desc
  
  --delete from [UserSession] where [LogoutTime] is null
  
  
--  select getutcdate()
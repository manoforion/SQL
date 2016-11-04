'Borramos todo para hacer las pruebas generales
HOST 		=  	"127.0.0.1"
User 		= 	"sa2"
Password 	= 	"sa2"

call Execute_app("osql -U "&User&" -P "&Password&" -S "&HOST&" -i F:\DBA_REPO\DBA_MAN\Script\DB_MAN_KILL_ALL.sql"  )

QUERY = "IF isnull(db_id('DB_MAN'),0) > 0  DROP DATABASE [DB_MAN] "
out = Exec_SQL (QUERY,Host,User,Password)

QUERY = "IF EXISTS (SELECT * FROM sys.syslogins WHERE name = N'DBA_MAN_ADMIN') DROP LOGIN [DBA_MAN_ADMIN]"
out = Exec_SQL (QUERY,Host,User,Password)

WriteIni "F:\DBA_INSTALL\DBA_MAN.cfg", "BASIC", "HOST", "127.0.0.1"
WriteIni "F:\DBA_INSTALL\DBA_MAN.cfg", "BASIC", "USER", "sa2"
WriteIni "F:\DBA_INSTALL\DBA_MAN.cfg", "BASIC", "PASSWORD", "sa2"
WriteIni "F:\DBA_INSTALL\DBA_MAN.cfg", "BASIC", "WORKPLACE", "F:\"
WriteIni "F:\DBA_INSTALL\DBA_MAN.cfg", "BASIC", "REPOS", "http://127.0.0.1:777/DBA_MAN/"



WScript.Echo 

'Borramos todo para hacer las pruebas generales




'Variables
Dim WshShell, ActualPath

'object 
Set WshShell = CreateObject("WScript.Shell")

'assign
ActualPath    = WshShell.CurrentDirectory
Set WshShell = Nothing

wscript.echo "Iniciando la Validacion"

QUERY 		=	"Select isnull(db_id('DB_MAN'),0) as out"
HOST 		=  	ReadIni (ActualPath&"\DBA_MAN.cfg", "BASIC", "HOST")
User 		= 	ReadIni (ActualPath&"\DBA_MAN.cfg", "BASIC", "USER")
Password 	= 	ReadIni (ActualPath&"\DBA_MAN.cfg", "BASIC", "PASSWORD")
Workplace 	=	ReadIni (ActualPath&"\DBA_MAN.cfg", "BASIC", "WORKPLACE")
repos		= 	ReadIni (ActualPath&"\DBA_MAN.cfg", "BASIC", "REPOS")

out = Exec_SQL_OUT (QUERY,Host,User,Password,"out")

if out<>0 then 
		wscript.echo "Cannot create Database ... Exist in the Server"
		Wscript.Quit 
	else 
		wscript.echo "Database Not Exist ... Ok"
		wscript.echo Get_valida
		
		wscript.echo "Create database DBA_MAN ... "
		QUERY = "CREATE DATABASE [DB_MAN] "
		out = Exec_SQL (QUERY,Host,User,Password)
		
		wscript.echo "Creating DBA MAN ADMIN ..." 
		QUERY = "USE [master]; CREATE LOGIN [DBA_MAN_ADMIN]  WITH PASSWORD = N'DB_MAN', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;"
		out = Exec_SQL (QUERY,Host,User,Password)
	
		wscript.echo "Assign Role To DBA_MAN_ADMIN ..."
		QUERY = "USE [master];EXEC sp_addsrvrolemember @loginame = N'DBA_MAN_ADMIN', @rolename = N'sysadmin';"
		out = Exec_SQL (QUERY,Host,User,Password)
		
		wscript.echo "Create Table DBA_MAN Config ... "
		QUERY = "CREATE TABLE [DB_MAN].[dbo].[Db_Man_Config]([Id_Db_Man_Config] [int] IDENTITY(1,1) NOT NULL,[Db_Man_Config_Param] [varchar](1000) NOT NULL,[Db_Man_Config_Value] [varchar](1000) NOT NULL) ON [PRIMARY]"
		out = Exec_SQL (QUERY,Host,User,Password)
		
		wscript.echo "Validate Path ..."
		wscript.echo ActualPath 
		
		wscript.echo "Gen Workplace ..."
		Install_to = Workplace & "DBA_MAN\"
		CreateFolderRecursive Install_to
		CreateFolderRecursive Install_to&"log"
		CreateFolderRecursive Install_to&"script"
		CreateFolderRecursive Install_to&"update"
		CreateFolderRecursive Install_to&"backup"
		CreateFolderRecursive Install_to&"download"
		CreateFolderRecursive Install_to&"gen_file"

		wscript.echo "download files ..."
		call Execute_app("wget.exe -v "&repos&"/Install/dba_man.zip -O "&Install_to&"download/dba_man.zip")
		call Execute_app("wget.exe -v "&repos&"/Install/7za.exe -O "&Install_to&"download/7za.exe")
		call Execute_app(""&Install_to&"download/7za.exe x "&Install_to&"download/dba_man.zip -y -o"&Install_to&"script\")

		call Get_File_Folder(Install_to&"script\",Install_to&"gen_file\gen_file.bat","-o"&Install_to&"log\[FILENAME].log","osql -U DBA_MAN_ADMIN -P DB_MAN -S "&HOST&" -d DB_MAN -i") 
		wscript.echo "install files ..."
		call Execute_app(Install_to&"gen_file\gen_file.bat")
	
		wscript.echo "Execute Querys ..."
		call Execute_app("osql -U "&User&" -P "&Password&" -S "&HOST&" -d DB_MAN -Q ""exec [DB_MAN_Gen_AuditLevel]"" -o"&Install_to&"log\DB_MAN_Gen_AuditLevel.log")
		call Execute_app("osql -U "&User&" -P "&Password&" -S "&HOST&" -d DB_MAN -Q ""exec [DB_MAN_ADD_CONFIG] 'notification','friedrich@drpex.com'"" -o"&Install_to&"log\notification.log")
		call Execute_app("osql -U "&User&" -P "&Password&" -S "&HOST&" -d DB_MAN -Q ""exec [DB_MAN_ADD_CONFIG] 'notification_cc','friedrich@drpex.com'"" -o"&Install_to&"log\notification.log")
		call Execute_app("osql -U "&User&" -P "&Password&" -S "&HOST&" -d DB_MAN -Q ""exec [DB_MAN_ADD_CONFIG] 'logo','http://www.drpex.com/logo.png'"" -o"&Install_to&"log\logo.log")
		
		
		
	end if 
	
	wscript.echo "Fin De instalacion "


	
	
Function Exec_SQL_OUT (QUERY,Host,User,Password,OUT)
' SQL connection string
strSQLConn = "Driver={SQL Server};Server="&Host&";Database=master;UID="&User&";PWD="&Password&";"
' Create database connection object
Set objConn = CreateObject( "ADODB.Connection" )

' Connection properties
objConn.ConnectionTimeout = 800
objConn.CommandTimeout = 800
objConn.Provider = "SQLOLEDB"

' Open Connection to Database
objConn.Open strSQLConn

' Clear variables
strSQLConn = Empty

' Run the SQL query
Set objRS = objConn.Execute( QUERY )

Exec_SQL_OUT = objRS.Fields(OUT).Value 
' Clear variables
QUERY = Empty
End Function

Function Exec_SQL (QUERY,Host,User,Password)
' SQL connection string
strSQLConn = "Driver={SQL Server};Server="&Host&";Database=master;UID="&User&";PWD="&Password&";"
' Create database connection object
Set objConn = CreateObject( "ADODB.Connection" )

' Connection properties
objConn.ConnectionTimeout = 800
objConn.CommandTimeout = 800
objConn.Provider = "SQLOLEDB"

' Open Connection to Database
objConn.Open strSQLConn

' Clear variables
strSQLConn = Empty

' Run the SQL query
Set objRS = objConn.Execute( QUERY )

Exec_SQL = "ok"
' Clear variables
QUERY = Empty
End Function


Function ReadIni( myFilePath, mySection, myKey )
    ' This function returns a value read from an INI file
    '
    ' Arguments:
    ' myFilePath  [string]  the (path and) file name of the INI file
    ' mySection   [string]  the section in the INI file to be searched
    ' myKey       [string]  the key whose value is to be returned
    '
    ' Returns:
    ' the [string] value for the specified key in the specified section
    '
    ' CAVEAT:     Will return a space if key exists but value is blank
    '
    ' Written by Keith Lacelle
    ' Modified by Denis St-Pierre and Rob van der Woude

    Const ForReading   = 1
    Const ForWriting   = 2
    Const ForAppending = 8

    Dim intEqualPos
    Dim objFSO, objIniFile
    Dim strFilePath, strKey, strLeftString, strLine, strSection

    Set objFSO = CreateObject( "Scripting.FileSystemObject" )

    ReadIni     = ""
    strFilePath = Trim( myFilePath )
    strSection  = Trim( mySection )
    strKey      = Trim( myKey )

    If objFSO.FileExists( strFilePath ) Then
        Set objIniFile = objFSO.OpenTextFile( strFilePath, ForReading, False )
        Do While objIniFile.AtEndOfStream = False
            strLine = Trim( objIniFile.ReadLine )

            ' Check if section is found in the current line
            If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
                strLine = Trim( objIniFile.ReadLine )

                ' Parse lines until the next section is reached
                Do While Left( strLine, 1 ) <> "["
                    ' Find position of equal sign in the line
                    intEqualPos = InStr( 1, strLine, "=", 1 )
                    If intEqualPos > 0 Then
                        strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
                        ' Check if item is found in the current line
                        If LCase( strLeftString ) = LCase( strKey ) Then
                            ReadIni = Trim( Mid( strLine, intEqualPos + 1 ) )
                            ' In case the item exists but value is blank
                            If ReadIni = "" Then
                                ReadIni = " "
                            End If
                            ' Abort loop when item is found
                            Exit Do
                        End If
                    End If

                    ' Abort if the end of the INI file is reached
                    If objIniFile.AtEndOfStream Then Exit Do

                    ' Continue with next line
                    strLine = Trim( objIniFile.ReadLine )
                Loop
            Exit Do
            End If
        Loop
        objIniFile.Close
    Else
        WScript.Echo strFilePath & " doesn't exists. Exiting..."
        Wscript.Quit 1
    End If
End Function

Function CreateFolderRecursive(FullPath)
  Dim arr, dir, path
  Dim oFs

  Set oFs = WScript.CreateObject("Scripting.FileSystemObject")
  arr = split(FullPath, "\")
  path = ""
  For Each dir In arr
    If path <> "" Then path = path & "\"
    path = path & dir
    If oFs.FolderExists(path) = False Then oFs.CreateFolder(path)
  Next
End Function

Sub WriteIni( myFilePath, mySection, myKey, myValue )
    ' This subroutine writes a value to an INI file
    '
    ' Arguments:
    ' myFilePath  [string]  the (path and) file name of the INI file
    ' mySection   [string]  the section in the INI file to be searched
    ' myKey       [string]  the key whose value is to be written
    ' myValue     [string]  the value to be written (myKey will be
    '                       deleted if myValue is <DELETE_THIS_VALUE>)
    '
    ' Returns:
    ' N/A
    '
    ' CAVEAT:     WriteIni function needs ReadIni function to run
    '
    ' Written by Keith Lacelle
    ' Modified by Denis St-Pierre, Johan Pol and Rob van der Woude

    Const ForReading   = 1
    Const ForWriting   = 2
    Const ForAppending = 8

    Dim blnInSection, blnKeyExists, blnSectionExists, blnWritten
    Dim intEqualPos
    Dim objFSO, objNewIni, objOrgIni, wshShell
    Dim strFilePath, strFolderPath, strKey, strLeftString
    Dim strLine, strSection, strTempDir, strTempFile, strValue

    strFilePath = Trim( myFilePath )
    strSection  = Trim( mySection )
    strKey      = Trim( myKey )
    strValue    = Trim( myValue )

    Set objFSO   = CreateObject( "Scripting.FileSystemObject" )
    Set wshShell = CreateObject( "WScript.Shell" )

    strTempDir  = wshShell.ExpandEnvironmentStrings( "%TEMP%" )
    strTempFile = objFSO.BuildPath( strTempDir, objFSO.GetTempName )

    Set objOrgIni = objFSO.OpenTextFile( strFilePath, ForReading, True )
    Set objNewIni = objFSO.CreateTextFile( strTempFile, False, False )

    blnInSection     = False
    blnSectionExists = False
    ' Check if the specified key already exists
    blnKeyExists     = ( ReadIni( strFilePath, strSection, strKey ) <> "" )
    blnWritten       = False

    ' Check if path to INI file exists, quit if not
    strFolderPath = Mid( strFilePath, 1, InStrRev( strFilePath, "\" ) )
    If Not objFSO.FolderExists ( strFolderPath ) Then
        WScript.Echo "Error: WriteIni failed, folder path (" _
                   & strFolderPath & ") to ini file " _
                   & strFilePath & " not found!"
        Set objOrgIni = Nothing
        Set objNewIni = Nothing
        Set objFSO    = Nothing
        WScript.Quit 1
    End If

    While objOrgIni.AtEndOfStream = False
        strLine = Trim( objOrgIni.ReadLine )
        If blnWritten = False Then
            If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
                blnSectionExists = True
                blnInSection = True
            ElseIf InStr( strLine, "[" ) = 1 Then
                blnInSection = False
            End If
        End If

        If blnInSection Then
            If blnKeyExists Then
                intEqualPos = InStr( 1, strLine, "=", vbTextCompare )
                If intEqualPos > 0 Then
                    strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
                    If LCase( strLeftString ) = LCase( strKey ) Then
                        ' Only write the key if the value isn't empty
                        ' Modification by Johan Pol
                        If strValue <> "<DELETE_THIS_VALUE>" Then
                            objNewIni.WriteLine strKey & "=" & strValue
                        End If
                        blnWritten   = True
                        blnInSection = False
                    End If
                End If
                If Not blnWritten Then
                    objNewIni.WriteLine strLine
                End If
            Else
                objNewIni.WriteLine strLine
                    ' Only write the key if the value isn't empty
                    ' Modification by Johan Pol
                    If strValue <> "<DELETE_THIS_VALUE>" Then
                        objNewIni.WriteLine strKey & "=" & strValue
                    End If
                blnWritten   = True
                blnInSection = False
            End If
        Else
            objNewIni.WriteLine strLine
        End If
    Wend

    If blnSectionExists = False Then ' section doesn't exist
        objNewIni.WriteLine
        objNewIni.WriteLine "[" & strSection & "]"
            ' Only write the key if the value isn't empty
            ' Modification by Johan Pol
            If strValue <> "<DELETE_THIS_VALUE>" Then
                objNewIni.WriteLine strKey & "=" & strValue
            End If
    End If

    objOrgIni.Close
    objNewIni.Close

    ' Delete old INI file
    objFSO.DeleteFile strFilePath, True
    ' Rename new INI file
    objFSO.MoveFile strTempFile, strFilePath

    Set objOrgIni = Nothing
    Set objNewIni = Nothing
    Set objFSO    = Nothing
    Set wshShell  = Nothing
End Sub


function Execute_app(path)
	Dim WshShell, oExec
	
	'wscript.echo path 
	
	Set WshShell = CreateObject("WScript.Shell")

	Set oExec = WshShell.Exec(path)

	Do While oExec.Status = 0
		WScript.Sleep 100
	Loop

	IF oExec.Status = 1 then
		WScript.Echo  path & " --> OK"
	else 
		WScript.Echo  path & " --> NOK"
	end if 	
end function


Function Get_File_Folder (path,outfile,after,before)
	Dim fso, folder, files, OutputFile
	Dim strPath

	' Create a FileSystemObject  
	Set fso = CreateObject("Scripting.FileSystemObject")

	Set folder = fso.GetFolder(path)
	Set files = folder.Files	

	' Create text file to output test data
	Set OutputFile = fso.CreateTextFile(outfile, True)

	' Loop through each file  
	For each item In files

	' Output file properties to a text file
	
	'OutputFile.WriteLine(item.Name)
	'OutputFile.WriteLine(item.Attributes)
	'OutputFile.WriteLine(item.DateCreated)
	'OutputFile.WriteLine(item.DateLastAccessed)
	'OutputFile.WriteLine(item.DateLastModified)
	'OutputFile.WriteLine(item.Drive)
	'OutputFile.WriteLine(item.Name)
	'OutputFile.WriteLine(item.ParentFolder )  
	OutputFile.WriteLine(replace(before,"[FILENAME]",item.Name) & " " & item.Path & " " & replace(after,"[FILENAME]",item.Name))
	'OutputFile.WriteLine(item.ShortName)
	'OutputFile.WriteLine(item.ShortPath)
	'OutputFile.WriteLine(item.Size)
	'OutputFile.WriteLine(item.Type)   
	'OutputFile.WriteLine("")

	Next

	' Close text file
	OutputFile.Close

end Function


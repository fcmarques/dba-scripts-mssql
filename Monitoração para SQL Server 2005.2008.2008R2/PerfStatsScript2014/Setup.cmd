@REM  To register the collector as a service, open a command prompt, change to this 
@REM  directory, and run: 
@REM  
@REM     SQLDIAG /R /I "%cd%\SQLDiagPerfStats_Trace.XML" /O "%cd%\SQLDiagOutput" /P
@REM  
@REM  You can then start collection by running "SQLDIAG START" from Start->Run, and 
@REM  stop collection by running "SQLDIAG STOP". 


@rem the command below sets sqldiag.exe path.  if your installation is different, adjust accordinly
@rem if you are on a 64 bit machine and you only want to capture 32 bit instances, change your sqldiagcmd as the following
@rem  set SQLDIAGCMD=C:\Program Files\Microsoft SQL Server\110\Tools\Binn\SQLdiag.exe

@rem set SQLDIAGCMD="C:\Program Files\Microsoft SQL Server\110\Tools\Binn\SQLdiag.exe"


SQLDiag.exe /R /A MSSQL2012A /I "%cd%\SQLDiagPerfStats_NoTrace.XML" /O "%cd%\Output\SQLDiagOutput" /P %cd% /C 1 /N 2
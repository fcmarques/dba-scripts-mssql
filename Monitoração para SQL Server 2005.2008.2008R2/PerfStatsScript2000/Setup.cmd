REM  To register the collector as a service, open a command prompt, change to this 
@REM  directory, and run: 
@REM  
@REM     PSSDIAG /R /I "%cd%\SQLDiagPerfStats_Trace.XML" /O "%cd%\SQLDiagOutput" /P
@REM  
@REM  You can then start collection by running "SQLDIAG START" from Start->Run, and 
@REM  stop collection by running "SQLDIAG STOP". 


@rem the command below sets sqldiag.exe path.  if your installation is different, adjust accordinly
@rem if you are on a 64 bit machine and you only want to capture 32 bit instances, change your sqldiagcmd as the following
@rem  set SQLDIAGCMD=C:\Program Files (x86)\Microsoft SQL Server\90\Tools\Binn\SQLdiag.exe

@rem set SQLDIAGCMD="C:\ProActiveMon\PerfStats2000\PSSdiag.exe"


PSSDiag.exe /R /A MSSQL2000B /I "%cd%\PSSDiag.INI" /O "%cd%\Output\PSSDiagOutput" /P %cd% /C 1 /N 2
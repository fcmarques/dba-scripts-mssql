set SQLDIAGCMD=C:\Program Files\Microsoft SQL Server\100\Tools\Binn\SQLdiag.exe
"%SQLDIAGCMD%" /I "%cd%\SQLDiagPerfStats_NoTrace.XML" /O "%cd%\SQLDiagOutput" /P

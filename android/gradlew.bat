@ECHO OFF
SET DIR=%~dp0
CALL gradle -p %DIR% %*

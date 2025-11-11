REM -------------------------------------------------------------------------------------------
REM Install This App to windwos Service. 
REM install -i  # install it 
REM install -u  # uninstall it 
REM -------------------------------------------------------------------------------------------


REM ---- windwos service variables define  -----------------------------------------------------
set serviceApp="JobAgent.exe"
set serviceName="JobAgent"
set serviceDescription="This is a Windows task scheduling system called JobAgent.";
set current=%~dp0
set bin="%current%\%serviceApp%"
REM --------------------------------------------------------------------------------------------


@echo off
cls

REM Must go to the current path to call bat script file.
cd /d %~dp0

NET FILE 1>NUL 2>NUL

::echo %1
::echo '%errorlevel%'

if '%errorlevel%' == '0' (
	::echo no error
	 if '%1'=='install' ( 
		 goto gotoAdminInstall 
	 ) else if '%1'=='uninstall' ( 
		 goto gotoAdminUnInstall 
	 ) else ( 
		 goto gotoTip 
	 )
) else (
	::echo need private.
	goto getPrivileges 
)


:getPrivileges
  echo You have no admin rights! You need to start your CMD in admin mode to %1 the windows service
  pause


:gotoAdminInstall
  echo Creating service with the name %serviceName% ...
  sc create %serviceName% binPath=%bin%
  sc description %serviceName% %serviceDescription% start=auto
  REM echo Try to start the service %serviceName%
  REM net start %serviceName%
  goto end


:gotoAdminUnInstall
  net stop %serviceName%
  taskkill /F /IM mmc.exe 
  sc delete %serviceName%
  goto end


:gotoTip
  echo To call directly, please add the parameter install or uninstall .
  echo or
  echo Please choose you want:
  echo -----------------------------------------------------------
  echo i:   Install the %serviceName% windows service.
  echo u: UnInstall the %serviceName% windows service.
  echo x: Exit this bat script.
  echo -----------------------------------------------------------
  set /p choice=Please input you choose:
  if "%choice%"=="i" (
		call :gotoAdminInstall
	) else if "%choice%"=="u" (
		call :gotoAdminUnInstall
	) else if "%choice%"=="x" (
		goto :eof
	) else (
		echo Invalid selection, please try again.
		goto :gotoTip
	)
  goto end


:end
  goto :eof


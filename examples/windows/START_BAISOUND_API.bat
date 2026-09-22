@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Start-BAISoundApi.ps1"
if errorlevel 1 (
  echo.
  echo BAISOUND API startup failed. Review the message above.
  pause
)
endlocal

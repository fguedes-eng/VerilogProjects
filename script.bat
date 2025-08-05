@echo off
setlocal

if "%~1"=="" (
    exit /b 1
)

set "PASTA=%~1"
set "ARQUIVO=logic_filelist.txt"

type nul > "%ARQUIVO%"
> "%ARQUIVO%" (
  for %%f in ("%PASTA%\*.sv") do echo %PASTA%\%%~nxf
)
endlocal
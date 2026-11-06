@echo off
setlocal
set CLIENT_DIR=%~dp0build\windows\x64\runner\Release\vynex_client
if not exist "%CLIENT_DIR%\vynex_client.exe" (
    set CLIENT_DIR=%~dp0rustdesk\flutter\build\windows\x64\runner\Release
)
cd /d "%CLIENT_DIR%"
start "" "%CLIENT_DIR%\vynex_client.exe" %*

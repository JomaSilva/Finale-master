@echo off
REM Desliga o servidor do jogo NA HORA (mata o dd.exe).
REM Use ISTO em vez de Ctrl+C -- o Ctrl+C faz o dd.exe travar eternamente no "shutdown".
REM Pode rodar mesmo com a janela do servidor travada: o dd.exe morre e a janela libera.
echo Desligando o servidor (dd.exe)...
taskkill /F /IM dd.exe >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Servidor desligado.
) else (
    echo Nenhum servidor (dd.exe) estava rodando.
)
timeout /t 2 >nul

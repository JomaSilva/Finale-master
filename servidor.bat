@echo off
REM Sobe o SERVIDOR do jogo no proprio CMD (dd.exe = DreamDaemon de console).
REM Duplo-clique para subir. Compile antes com compilar.bat.
REM Porta 30000 -- mude o numero abaixo se quiser outra porta.
set PORTA=30000

if not exist "%~dp0Dragonball Jandirus.dmb" (
    echo.
    echo ============================================================
    echo  .dmb nao encontrado. Compile primeiro com compilar.bat
    echo ============================================================
    pause
    exit /b
)

echo ============================================================
echo  Subindo "Dragonball Jandirus" na porta %PORTA% (console no CMD).
echo.
echo  PARA DESLIGAR: rode  parar-servidor.bat  (desliga na hora).
echo  NAO use Ctrl+C aqui: o dd.exe trava no "shutdown" e nao fecha.
echo  (Fechar no X tambem funciona, mas demora uns segundos.)
echo ============================================================
echo.
"E:\BYOND\bin\dd.exe" "%~dp0Dragonball Jandirus.dmb" %PORTA% -trusted -console
REM Se o dd encerrar por conta propria (ou via parar-servidor.bat), limpa orfaos:
taskkill /F /IM dd.exe >nul 2>&1
echo.
echo Servidor encerrado.
pause

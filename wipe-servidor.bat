@echo off
REM Faz o WIPE do servidor: apaga TODO o estado de jogo (saves de player,
REM sagas de boss, reputacao dos planetas, banco, ranks, relogio/ano, mapa salvo).
REM NAO toca em config de admin (Admins, BANS, Mutes.sav, Illegal, Intro, Rules,
REM STORY, PersistantSettings) nem nos logs.
REM Rode parar-servidor.bat ANTES: com o dd.exe aberto ele regrava os saves ao fechar.

tasklist /FI "IMAGENAME eq dd.exe" 2>nul | find /I "dd.exe" >nul
if not errorlevel 1 (
    echo.
    echo ============================================================
    echo  O servidor ainda esta RODANDO. Rode parar-servidor.bat
    echo  primeiro -- senao o dd.exe regrava os saves ao fechar.
    echo ============================================================
    pause
    exit /b
)

echo ============================================================
echo  WIPE do "Dragonball Jandirus" -- isto apaga:
echo    - Save\            (todos os personagens dos players)
echo    - BossEvents       (estado das sagas Freeza/Cell/Boo)
echo    - PlanetRep        (reputacao dos planetas)
echo    - Conquest         (dominios planetarios da conquista)
echo    - PerWipeSettings  (planetas destruidos, config por-wipe)
echo    - Bank_Save / RANK / Year / GAIN
echo    - MapSave / MapSaveBck / AreaSave / ItemSave / MobSave
echo  Config de admin e logs NAO sao tocados.
echo ============================================================
set /p CONFIRMA="Digite SIM para confirmar o wipe: "
if /I not "%CONFIRMA%"=="SIM" (
    echo Wipe cancelado.
    pause
    exit /b
)

cd /d "%~dp0"
if exist "Save" rmdir /s /q "Save"
for %%F in (BossEvents PlanetRep Conquest PerWipeSettings Bank_Save RANK Year GAIN MapSave MapSaveBck AreaSave ItemSave MobSave Galaxy PlanetCache) do (
    if exist "%%F" del /f /q "%%F"
)

echo.
echo Wipe concluido. Pode subir o servidor com servidor.bat
pause

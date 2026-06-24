@echo off
REM Compila o projeto via dm.exe (NAO reseta o FILE_DIR como a IDE do DreamMaker faz).
REM Duplo-clique para compilar. Use isto em vez do botao de compilar da IDE.
"E:\BYOND\bin\dm.exe" "%~dp0Dragonball Climax.dme"
echo.
echo ============================================================
echo Compilacao terminada. Veja acima se deu "0 errors".
echo ============================================================
pause

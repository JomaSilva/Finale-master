@echo off
REM Compila a DLL de terreno procedural (Tools\jandirus_noise.c) em 32-BIT
REM (o dd.exe do BYOND e x86 -- uma DLL 64-bit NAO carrega!).
REM Requer o Zig (winget install zig.zig). Rode apos editar o .c.
set ZIG=%LOCALAPPDATA%\Microsoft\WinGet\Packages\zig.zig_Microsoft.Winget.Source_8wekyb3d8bbwe\zig-x86_64-windows-0.16.0\zig.exe
if not exist "%ZIG%" set ZIG=zig
"%ZIG%" cc -target x86-windows-gnu -shared -O2 -o "%~dp0jandirus_noise.dll" "%~dp0Tools\jandirus_noise.c"
if errorlevel 1 (
    echo.
    echo ERRO na compilacao da DLL.
) else (
    echo.
    echo jandirus_noise.dll gerada com sucesso (32-bit).
)
pause

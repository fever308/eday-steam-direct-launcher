@echo off
setlocal EnableExtensions DisableDelayedExpansion
title E-Day Steam - Full Game

rem Test launcher, not verified against an installed E-Day Steam build.
rem Open Steam and sign in to the account that owns the full game.
rem Put this BAT beside the actual game EXE and double-click it.
rem It searches its own folder and subfolders for the known game EXE names.
rem The full-game Steam App ID is fixed; there is no edition menu.
rem Use the actual game executable in Binaries, not start_protected_game.exe.
rem Keep this window open until the game exits so cleanup can run.
rem The null anti-cheat client does not authenticate protected multiplayer.
rem
rem Sources:
rem https://dev.epicgames.com/docs/epic-online-services/trust-and-safety/anti-cheat-interfaces/anti-cheat-integration-check-list
rem https://partner.steamgames.com/doc/api/steam_api#SteamAPI_RestartAppIfNecessary
rem Full game: https://store.steampowered.com/app/3010850/

set "EDAY_APPID=3010850"
set "EDAY_CREATED_ID="
set "EDAY_EXITCODE=1"
set "EDAY_TARGET="
set "EDAY_MATCHES=0"
for /r "%~dp0" %%G in (GoWEDay.exe GoWEDay-Win64-Shipping.exe GoWEDay-WinGDK-Shipping.exe GoWEDay-Steam.exe) do (
    if exist "%%~fG" (
        set "EDAY_TARGET=%%~fG"
        set /a EDAY_MATCHES+=1 >nul
    )
)
if "%EDAY_MATCHES%"=="0" goto missing_exe
if not "%EDAY_MATCHES%"=="1" goto multiple_exes
for %%G in ("%EDAY_TARGET%") do set "EDAY_DIR=%%~dpG"

tasklist /FI "IMAGENAME eq steam.exe" /NH 2>nul | find /I "steam.exe" >nul
if errorlevel 1 goto steam_not_running

echo Launching E-Day - Steam full game
echo Target: "%EDAY_TARGET%"

pushd "%EDAY_DIR%"
if errorlevel 1 goto folder_error
if exist "steam_appid.txt" goto existing_id
>"steam_appid.txt" echo %EDAY_APPID%
if errorlevel 1 goto write_error
set "EDAY_CREATED_ID=1"
goto launch

:existing_id
findstr /L /X /C:"%EDAY_APPID%" "steam_appid.txt" >nul
if errorlevel 1 goto id_mismatch
echo Keeping the existing steam_appid.txt.

:launch
set "EOS_USE_ANTICHEATCLIENTNULL=1"
set "SteamAppId=%EDAY_APPID%"
echo.
echo Starting with Steam App ID %EDAY_APPID% and the EOS null client enabled.
echo This tests local startup; it does not enable protected matchmaking.
echo Leave this window open while the game runs.
echo If EAC or a launch error appears, record the exact message.
echo.
start "" /wait "%EDAY_TARGET%"
set "EDAY_EXITCODE=%errorlevel%"
if not defined EDAY_CREATED_ID goto finished
del "steam_appid.txt" 2>nul
if exist "steam_appid.txt" echo Cleanup failed: remove the steam_appid.txt created by this run.

:finished
echo.
echo Launched process exited with code %EDAY_EXITCODE%.
popd
if not "%EDAY_EXITCODE%"=="0" pause
exit /b %EDAY_EXITCODE%

:missing_exe
echo Could not find a known E-Day executable in "%~dp0" or its subfolders.
echo Put this BAT beside the actual GoWEDay.exe and double-click it.
echo If the game uses a different name, report that name so the launcher can be updated.
goto fail

:multiple_exes
echo Found more than one possible game executable under "%~dp0".
echo Move this BAT beside the actual game EXE inside Binaries and double-click it.
goto fail

:steam_not_running
echo Open Steam, sign in to the account that owns the full game, then try again.
echo Run this launcher with the same permissions as Steam.
goto fail

:folder_error
echo Cannot open the executable folder: "%EDAY_DIR%".
goto fail

:write_error
echo Cannot create steam_appid.txt in "%EDAY_DIR%".
echo Check the folder permissions. No game executable has been changed.
popd
goto fail

:id_mismatch
echo Existing steam_appid.txt does not contain the full-game App ID %EDAY_APPID%.
echo It has been left unchanged. Check that this is the full-game installation.
popd

:fail
pause
exit /b 1

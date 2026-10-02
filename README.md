# E-Day Steam Direct Launcher — EAC Disabled

A plain-text Windows batch launcher for the Steam full release of **Gears of War: E-Day**. It launches the game directly with Epic's null anti-cheat client setting enabled.

I created this so I could use **DLSS 5** with the game. I have tested the launcher with the Steam version and confirmed that it works. The launcher itself does not install or configure DLSS.

> **WARNING: DO NOT USE THIS LAUNCHER TO PLAY ONLINE.**
>
> I have not attempted playing online with EAC disabled. The game detects that anti-cheat is not enabled and displays a message saying online capabilities are **“limited.”** This launcher is intended for offline use only; it does not force the game offline.

## Installation

1. Open Steam and sign in to the account that owns the full game.
2. Download and extract the ZIP archive.
3. Place `Eday_Steam_Direct_Launch.bat` beside `GoWEDay-Steam.exe` in the game's installation folder, typically inside **Binaries**.
4. Double-click the batch file.
5. Leave the console window open until the game closes so cleanup can finish.

For desktop access, create a shortcut to the batch file and leave the original in the game folder.

The launcher always targets the full-game Steam App ID, `3010850`. It automatically searches its folder and subfolders for these executable names:

- `GoWEDay-Steam.exe`
- `GoWEDay.exe`
- `GoWEDay-Win64-Shipping.exe`
- `GoWEDay-WinGDK-Shipping.exe`

If it finds multiple candidates, place the batch file directly beside the actual game executable and run it again.

## Source review and build instructions

**There is no compilation step.** `Eday_Steam_Direct_Launch.bat` is both the complete launcher source and the runnable file. Windows Command Prompt executes it directly. This repository includes the script supplied for review, including the corrected `GoWEDay-Steam.exe` detection.

The script:

1. Locates a supported executable and checks that the Steam client is running.
2. Uses the game executable's directory as its working directory.
3. Creates `steam_appid.txt` with the full-game App ID when needed. An existing matching file is preserved; a conflicting App ID stops the launch.
4. Sets `EOS_USE_ANTICHEATCLIENTNULL=1` and `SteamAppId=3010850` for this launch using a local command environment.
5. Starts the game executable directly and waits for that process to exit.
6. Removes the App ID file only if this run created it.

The launcher uses built-in Windows commands. It does not download files, make network requests, modify the registry, patch game executables, or include compiled code. Steam and the game retain their own normal behavior and network activity.

To package the mod for distribution, run this command in PowerShell from the repository folder:

```powershell
Compress-Archive -LiteralPath .\Eday_Steam_Direct_Launch.bat -DestinationPath .\Eday_Steam_Direct_Launch.zip -Force
```

The resulting ZIP contains the batch file directly, with no nested archive. Packaging does not compile or transform the script.

For Nexus review, compare the batch file extracted from the submitted mod ZIP with the source in this repository. If comparing hashes, use copies with identical line endings; this repository requests Windows CRLF for batch files.

## Reporting problems

Include the exact error message, game version, and executable filename and location. Compatibility may change after game updates.

## Uninstallation

Delete the batch file and any shortcut you created.

## References

- [Epic Online Services anti-cheat integration checklist](https://dev.epicgames.com/docs/epic-online-services/trust-and-safety/anti-cheat-interfaces/anti-cheat-integration-check-list)
- [Steamworks direct launch and restart behavior](https://partner.steamgames.com/doc/api/steam_api#SteamAPI_RestartAppIfNecessary)
- [Gears of War: E-Day on Steam](https://store.steampowered.com/app/3010850/)
- [Nexus Mods: Why has my mod been quarantined?](https://help.nexusmods.com/article/117-why-has-my-mod-been-quarantined)

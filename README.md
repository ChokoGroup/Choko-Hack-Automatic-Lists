# Choko Hack Automatic Lists
Create Lists of Games to Play in CHA
(to load from USB or install in CHA)
with the Choko Hack v12 or later


## What's new
- Updated to work with Choko Hack v12, that allows navigation with joystick and any folder names under `roms/` and automatically creates menu items for them.
- Automatically creates lists based in content of roms/ subfolders.
- Added fbneo_libretro.so extracted from Lakka, that fixes a problem with "Dungeons & Dragons: Shadow Over Mystara" - now player two can select and use weapons/magic.
- Support for clones roms (tries to find parent rom's assets).
- Updated the games installer/uninstaller. Easily install games lists into the CHA (you should expand the partition to make space for the roms - better yet, add a SD card reader: https://cha-choko-mod.fandom.com/wiki/SD_Card_reader_MOD ).
- Moved the SSH and FTP servers to the Choko Hack pack ( https://github.com/ChokoGroup/Choko-Hack inside 'Extras' folder).


## Instructions
The most basic: put `CHA Choko Games Lists` in the root of USB pendrive, create folders inside `CHA Choko Games Lists/roms` and put your roms in them.
Read the file '00 - Instructions.txt' and/or watch the videos for details.

If you change the roms in one subfolder of `CHA Choko Games Lists/roms` just delete the `*.txt` file with the same name of the folder (in `CHA Choko Games Lists`) and the list will be recreated the next time you select it in menu.
We can have as many lists as we want, just create subfolders inside `CHA Choko Games Lists/roms`.


## Folder structure
- `roms/SUBFOLDER_WITH_ANY_NAME`      has the games roms to be loaded by the correspondent list. Support is mostly for parent roms but can be easily extended.
- `assets`    has the icons, buttons layout and sounds for games in carousel. You can change them or add your own assets.
- `patches`   has the 'fba_libretro.so' used by default in all lists (and some extra cores we can use/test).
- `patches/SUBFOLDERS_WITH_ANY_NAME`  has specific files to the correspondent list, for UI customization or using patched binaries (look into examples included).


## Notes:
- `SUBFOLDER_WITH_ANY_NAME.txt` will be automatically generated, if don't exist when loading, with the roms found in the correspondent folder `roms/SUBFOLDER_WITH_ANY_NAME`
- if a rom is not listed in `games_all.txt` it will be assigned a "generic" png with a name (if found) or number to facilitate navigation in carousel.
- We can't guess buttons profile of games not in `games_all.txt`, so default is 'A'.
- If buttons are not well configured, you should edit the correspondent line in `SUBFOLDER_WITH_ANY_NAME.txt` and change the very first character ('A') to 'B', 'C', 'D' or 'E'. When OK, you can copy the entire line to `games_all.txt` for future use.
- When installing games into the CHA, it only copies the needed assets, but required space is a guess and can be wrong.
- When deleting games installed in the CHA, the assets used by the correspondent games are deleted. If you have a game repeated, in more than one list, you'll need to reinstall the other lists to reinstall the assets.


## Regarding roms
- Always use lowercase in filenames.
- For the *.png and *.ogg files use the same name as the roms and also all lowercase.
- Don't forget BIOS files (for example, `neogeo.zip`).
- For some sub systems, FB Neo core needs roms to be in special subfolders. The possible folder names are as follows:

```
* CBS ColecoVision :              coleco | colecovision
* Fairchild ChannelF :            chf | channelf
* MSX 1 :                         msx | msx1
* Nec PC-Engine :                 pce | pcengine
* Nec SuperGrafX :                sgx | supergrafx
* Nec TurboGrafx-16 :             tg16
* Nintendo Entertainment System : nes
* Nintendo Family Disk System :   fds
* Sega GameGear :                 gamegear
* Sega Master System :            sms | mastersystem
* Sega Megadrive :                megadriv | megadrive | genesis
* Sega SG-1000 :                  sg1000
* SNK Neo-Geo Pocket :            ngp
* ZX Spectrum :                   spectrum | zxspectrum
```

For example, to use Mega Drive roms you need to put roms in folder `roms/SUBFOLDERS_WITH_ANY_NAME/megadrive` (and use FB Neo core).
More in https://docs.libretro.com/library/fbneo/


## Creating new assets
- Of course you can create and add/replace icons to any game. Just save it as a PNG file with the same name as the rom file, in the folder `assets/games`
- Music for the games in carousel go to the folder `assets/sounds/music/set2` in OGG format.
- The in-game buttons layout go to `assets/options` and `assets/options/large`, also in PNG format.

We will appreciate all users contributions to enlarge this database.


## Game Manager
There is a folder with an alpha version of Game Manager.
It very helpful to edit each games data and add it to games_all.txt, also see the assets for each game in a list.
Be warned, it's still in a very early development stage.

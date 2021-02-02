# Choko Hack Automatic Lists
Create Lists of Games to Play in CHA
(to load from USB or install in CHA)
with the Choko Hack v11 or later


## Quick instructions to create a new list
(Example to assign a list to Player 1 button A)

1) Copy the folder `CHA Choko Games Lists` to the root of a USB pen disk;
2) Open that folder in USB, and remove `.disabled` from the NFO file name that corresponds to the button you want to use (in this example, rename  `games1A.nfo.disabled` to `games1A.nfo` for Player 1 button A);
3) Open the file you renamed (in this example, `games1A.nfo`) with a text editor and write a nice name for your list;
4) Copy some roms to the folder `roms/games1A`
5) Safely eject the pen disk, insert in USB EXT of the CHA and power on the CHA.
6) Follow the menu options to select the list you just created.

That's all.
If you change the roms in `roms/games1A` just delete `games1A.txt` and it will be created again the next time you load the list.


## Folder structure
- `assets`            has the icons, buttons layout and sounds for games in carousel.
- `patches`           has the 'fba_libretro.so' used by default in all lists (and some extra cores we can use/test).
- `patches/games??`   has specific files to the correspondent list, for UI customuzation or using patched binaries.
- `roms/games??`      has the roms to be loaded by the correspondent list.

Look inside the folder `patches` for more details.


## Notes:
- `games??.txt` will be automatically generated, if don't exist when loading, with the roms found in the correspondent folder `roms/games??`
- if a rom is not listed in `games_all.txt` it will be assigned a "generic" png with a name (if found) or number to facilitate navigation in carousel.
- We can't guess buttons profile of games not in `games_all.txt`, so default is 'A'.
- If buttons are not well configured, you should edit the correpondent line in `games??.txt` and change the very first 'A' to 'B', 'C', 'D' or 'E'. When OK, you can copy the entire line to `games_all.txt` for future use.
- When installing games into the CHA, it adds all `assets` folder plus `fba_libretro.so` size to the needed space, regardeless what assets already are in the CHA. We can't go through every game assets and this way we also get some free space left to avoid system instability.


## Regarding roms
- Don't forget BIOS files (for example, `neogeo.zip`).
- For some sub systems, FB Neo core needs roms to be in special subfolders. The possible folder names are as follows (they follow the mame system names):

```
coleco
gamegear
megadriv
neocd
msx
pce
sg1000
spectrum
sgx
sms
tg16
```

For example, to use Mega Drive roms in list 1A you need to put roms in folder `roms/games1A/megadriv` (and use FB Neo core).


## Creating new assets
- Of course you can create and add/replace icons to any game. Just save it as a PNG file with the same name as the rom file, in the folder `assets\games`
- Music for the games in carousel go to the folder `assets/sounds/music/set2` in OGG format.
- The in-game buttons layout go to `assets/options` and `assets/options/large`, also in PNG format.

We will appreciate all users contributions to enlarge this database.

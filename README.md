# Choko Hack Automatic Lists
Create Lists of Games to Play in CHA (to load from USB or install in CHA)
with the Choko Hack v11 or later


## Quick instructions to create a new list
(Example to assign a list to Player 1 button A)

1) Copy the folder `CHA Choko Games Lists` to the root of a USB pen disk;
2) Open that folder, and make a copy `games0A.nfo` and `games0A.sh`;
3) Rename them to the correspondent button you want to use (in this example, `games1A.nfo` and `games1A.sh` for Player 1 button A - NOT __games1a.*__ );
4) Open with a text editor the `games1A.nfo` file you created in the previous step and write a nice name for your list;
5) Copy some roms to the folder `roms/games1A`
6) Safelly eject the pen disk, insert in USB EXT of the CHA and power on the CHA.

That's all.
If you change the roms in `roms/games1A` just delete `games1A.txt` and it will be created again the next time you load the list.
You can have up to 12 lists: games1A, games1B, games1C, games1D, games1E, games1F, games2A, games2B, games2C, games2D, games2E, games2F.


## Folder structure
- `assets`            has the icons, buttons layout and sounds for games in carousel.
- `patches`           has the 'fba_libretro.so' used by default in all lists.
- `patches/games??`   has specific files to the correspondent list, for UI customuzation or using patched binaries.
- `roms/games??`      has the roms to be loaded by the correspondent list.

games0A and games0B are files or folders you can copy and rename to assign lists to any buttons.
Look inside the folder `patches` for more details.

## Notes:
- `games??.txt` will be automatically generated, if don't exist when loading, with the roms found in the correspondent folder `roms/games??`
- if a rom is not listed in `games_all.txt` it will be assigned a "generic" png with a name (if found) or number to facilitate navigation in carousel.
- We can't guess buttons profile of games not in `games_all.txt`, so default is 'A'.
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

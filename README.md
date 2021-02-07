# Choko Hack Automatic Lists
Create Lists of Games to Play in CHA
(to load from USB or install in CHA)
with the Choko Hack v11 or later


## Intructions
Read the file '00 - Instructions.txt' and/or whatch the videos (*.mkv files).

If you change the roms in `roms/games1A` just delete `games1A.txt` and the list will be created again the next time you select it in menu.
We can have up to 12 lists in one folder (from games1A to games2F) and we can have up to 12 folders (just change the folder's name).


## Folder structure
- `assets`            has the icons, buttons layout and sounds for games in carousel. You can change and add your own asstes.
- `patches`           has the 'fba_libretro.so' used by default in all lists (and some extra cores we can use/test).
- `patches/games??`   has specific files to the correspondent list, for UI customuzation or using patched binaries (look into examples games0A and games0B).
- `roms/games??`      has the roms to be loaded by the correspondent list.


## Notes:
- `games??.txt` will be automatically generated, if don't exist when loading, with the roms found in the correspondent folder `roms/games??`
- if a rom is not listed in `games_all.txt` it will be assigned a "generic" png with a name (if found) or number to facilitate navigation in carousel.
- We can't guess buttons profile of games not in `games_all.txt`, so default is 'A'.
- If buttons are not well configured, you should edit the correpondent line in `games??.txt` and change the very first character ('A') to 'B', 'C', 'D' or 'E'. When OK, you can copy the entire line to `games_all.txt` for future use.
- When installing games into the CHA, it only copies the needed assets, but required space is a guess and can be wrong.
- When deleting games installed in the CHA, the assets used by the correpondent games are deleted. If you have a game repeated, in more than one list, you'll need to reinstall the other lists to reinstall the assets.


## Regarding roms
- Always use lowercase in filenames.
- For the *.png and *.ogg files use the same name as the ROMs and also all lowercase.
- Don't forget BIOS files (for example, `neogeo.zip`).
- For some sub systems, FB Neo core needs roms to be in special subfolders. The possible folder names are as follows (they follow the MAME system names):

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
- Of course you can create and add/replace icons to any game. Just save it as a PNG file with the same name as the rom file, in the folder `assets/games`
- Music for the games in carousel go to the folder `assets/sounds/music/set2` in OGG format.
- The in-game buttons layout go to `assets/options` and `assets/options/large`, also in PNG format.

We will appreciate all users contributions to enlarge this database.


## SSH and FTP server
We include in the pack SSH and FTP servers that can be enabled by removing the `.disabled` part from the folders names.
user: `root`
password: `Choko`

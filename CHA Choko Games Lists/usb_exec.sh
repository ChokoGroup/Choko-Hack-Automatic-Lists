#! /bin/sh
# usb_exec.sh
# For Choko Hack 12.0.0+

# Simple string compare, since until 10.0.0 CHOKOVERSION wasn't set
# Future versions need to keep this in mind
if [ "$CHOKOVERSION" \< "12.0.0" ]
then
  echo -e "\nYou are running an outdated version of Choko Hack.\nYou need v12.0.0 or later.";
  COUNTDOWN=5
  while [ $COUNTDOWN -ge 0 ]
  do
    echo -ne "\rRebooting in $COUNTDOWN seconds... "
    COUNTDOWN=$((COUNTDOWN - 1))
    sleep 1
  done
  echo -e "\r\e[K"
  if [ "$CHOKOVERSION" \< "10.0.0" ]
  then
    reboot -f
  else
    exit 200
  fi
fi

RUNNINGFROM="$(dirname "$(readlink -f "$0")")"
LISTNAME="$*"

# Where are the ROMs
if [ "$RUNNINGFROM" = "/.choko" ]
then
  ROMSFOLDER="/usr/share/roms/$LISTNAME"
else
  ROMSFOLDER="$RUNNINGFROM/roms/$LISTNAME"
fi


creategamestxt () {
  echo -n "Creating \"$LISTNAME.txt\""
  FIRSTLINE="Y"
  ICONNUMBER=0
  # Make 'for' loops use entire lines
  OIFS="$IFS"
  IFS=$'\n'
  # Go to folder to avoid problems with apostrophes in folders names
  cd "$ROMSFOLDER"
  for FNAME in $(find . -mindepth 1 -maxdepth 2 -name '*.zip' -type f -print 2> /dev/null | sort -f)
  do
    FNAME="${FNAME#./}"; FNAME="${FNAME%.zip}"
    # Ignore BIOS only zip files
    if [ "$FNAME" != "neogeo" ] && [ "$FNAME" != "neocdz" ] && [ "$FNAME" != "decocass" ] && [ "$FNAME" != "isgsm" ] && [ "$FNAME" != "midssio" ] && [ "$FNAME" != "nmk004" ] && [ "$FNAME" != "pgm" ] && [ "$FNAME" != "skns" ] && [ "$FNAME" != "ym2608" ] && [ "$FNAME" != "cchip" ] && [ "$FNAME" != "bubsys" ] && [ "$FNAME" != "namcoc69" ] && [ "$FNAME" != "namcoc70" ] && [ "$FNAME" != "namcoc75" ] && [ "$FNAME" != "coleco" ] && [ "$FNAME" != "fdsbios" ] && [ "$FNAME" != "msx" ] && [ "$FNAME" != "ngp" ] && [ "$FNAME" != "spectrum" ] && [ "$FNAME" != "spec128" ] && [ "$FNAME" != "channelf" ]
    then
      FPARENT="$FNAME"
      GAMESTXTLINE="$(grep -m 1 " $FPARENT.zip" "$RUNNINGFROM/games_all.txt")"
      # Search for parent rom in games_all.txt if exact zip not found n games_all.txt
      while [ -z "$GAMESTXTLINE" ] && [ ${#FPARENT} -gt 1 ]
      do
        FPARENT="${FPARENT%?}"
        GAMESTXTLINE="$(grep -m 1 " $FPARENT.zip" "$RUNNINGFROM/games_all.txt")"
      done

      if [ "$FIRSTLINE" = "N" ]
      then
        echo -en "\n" >> "$RUNNINGFROM/$LISTNAME.txt"
      else
        FIRSTLINE="N"
      fi
      if [ -n "$GAMESTXTLINE" ]
      then
        # Line found in games_all.txt
        if [ "$FNAME" != "$FPARENT" ]
        then
          TMPFNAME="${FNAME//\//\\\/}"
          TMPFPARENT="${FPARENT//\//\\\/}"
          eval "GAMESTXTLINE=\"\${GAMESTXTLINE/ $TMPFPARENT.zip/ $TMPFNAME.zip}\""
        fi
        # Check if png exists and look for parent png if not
        ASSETSFILENAME="${GAMESTXTLINE:11}"; ASSETSFILENAME="${ASSETSFILENAME%%' '*}"
        if [ ! -f "$RUNNINGFROM/assets/games/$ASSETSFILENAME" ]
        then
          TMPASSETSFILENAME="${ASSETSFILENAME//\//\\\/}"
          FPARENT="$FNAME"
          while [ ! -f "$RUNNINGFROM/assets/games/$FPARENT.png" ] && [ ${#FPARENT} -gt 1 ]
          do
            FPARENT="${FPARENT%?}"
          done
          if [ -f "$RUNNINGFROM/assets/games/$FPARENT.png" ]
          then
            TMPFPARENT="${FPARENT//\//\\\/}"
            eval "GAMESTXTLINE=\"\${GAMESTXTLINE/ $TMPASSETSFILENAME/ $TMPFPARENT.png}\""
          else
            ICONNUMBER=$((ICONNUMBER + 1))
            if [ ${#ICONNUMBER} -eq 1 ]
            then
              eval "GAMESTXTLINE=\"\${GAMESTXTLINE/ $TMPASSETSFILENAME/ game0$ICONNUMBER.png}\""
            else
              eval "GAMESTXTLINE=\"\${GAMESTXTLINE/ $TMPASSETSFILENAME/ game$ICONNUMBER.png}\""
            fi
          fi
        fi
        # Check if ogg exists and look for parent ogg if not
        ASSETSFILENAME="${GAMESTXTLINE#*'.zip '}"; ASSETSFILENAME="${ASSETSFILENAME%%' '*}"
        if [ ! -f "$RUNNINGFROM/assets/sounds/$ASSETSFILENAME" ] && [ ! -f "$RUNNINGFROM/assets/sounds/music/set2/$ASSETSFILENAME" ]
        then
          FPARENT="$FNAME"
          while [ ! -f "$RUNNINGFROM/assets/sounds/$FPARENT.ogg" ] && [ ! -f "$RUNNINGFROM/assets/sounds/music/set2/$FPARENT.ogg" ] && [ ${#FPARENT} -gt 1 ]
          do
            FPARENT="${FPARENT%?}"
          done
          if [ -f "$RUNNINGFROM/assets/sounds/$FPARENT.ogg" ] || [ -f "$RUNNINGFROM/assets/sounds/music/set2/$FPARENT.ogg" ]
          then
            TMPASSETSFILENAME="${ASSETSFILENAME//\//\\\/}"
            TMPFPARENT="${FPARENT//\//\\\/}"
            eval "GAMESTXTLINE=\"\${GAMESTXTLINE/ $TMPASSETSFILENAME/ $TMPFPARENT.ogg}\""
          fi
        fi
        echo -n "$GAMESTXTLINE" >> "$RUNNINGFROM/$LISTNAME.txt"
      else
        # Line not found in games_all.txt
        # Search for rom assets or parent rom assets
        FPARENT="$FNAME"
        while [ ! -f "$RUNNINGFROM/assets/games/$FPARENT.png" ] && [ ${#FPARENT} -gt 1 ]
        do
          FPARENT="${FPARENT%?}"
        done
        if [ -f "$RUNNINGFROM/assets/games/$FPARENT.png" ]
        then
          echo -n "A 0 B 0000 $FPARENT.png $FNAME.zip $FPARENT.ogg 0 $FPARENT" >> "$RUNNINGFROM/$LISTNAME.txt"
        else
          ICONNUMBER=$((ICONNUMBER + 1))
          if [ ${#ICONNUMBER} -eq 1 ]
          then
            echo -n "A 0 B 0000 game0$ICONNUMBER.png $FNAME.zip $FNAME.ogg 0 $FNAME" >> "$RUNNINGFROM/$LISTNAME.txt"
          else
            echo -n "A 0 B 0000 game$ICONNUMBER.png $FNAME.zip $FNAME.ogg 0 $FNAME" >> "$RUNNINGFROM/$LISTNAME.txt"
          fi
        fi
      fi
      echo -n "."
    fi
  done
  cd "$RUNNINGFROM"
  IFS="$OIFS"
  echo " Done!"
}

if [ -n "$LISTNAME" ] && [ -d "$ROMSFOLDER" ]
then

  # Create $LISTNAME.txt if it does not exist
  [ -f "$RUNNINGFROM/$LISTNAME.txt" ] || creategamestxt

  if [ -f "$RUNNINGFROM/$LISTNAME.txt" ]
  then
    # Mount assets for games
    # Remember to choose Remix in music settings
    for DIR in \
      assets/games \
      assets/options \
      assets/sounds
    do
      mount --bind "$RUNNINGFROM/$DIR" /opt/capcom/$DIR
    done

    # Mount assets to change UI if they exist
    if [ -f "$RUNNINGFROM/patches/$LISTNAME/assets/capcom-home-arcade-last.png" ]
    then
      mount --bind "$RUNNINGFROM/patches/$LISTNAME/assets/capcom-home-arcade-last.png" /opt/capcom/assets/capcom-home-arcade-last.png
    else
      mount --bind "$RUNNINGFROM/assets/capcom-home-arcade-last.png" /opt/capcom/assets/capcom-home-arcade-last.png
    fi
    [ -d "$RUNNINGFROM/patches/$LISTNAME/assets/retro" ] && mount --bind "$RUNNINGFROM/patches/$LISTNAME/assets/retro" /opt/capcom/assets/retro
    [ -d "$RUNNINGFROM/patches/$LISTNAME/assets/screen" ] && mount --bind "$RUNNINGFROM/patches/$LISTNAME/assets/screen" /opt/capcom/assets/screen
    [ -f "$RUNNINGFROM/patches/$LISTNAME/assets/bg.png" ] && mount --bind "$RUNNINGFROM/patches/$LISTNAME/assets/bg.png" /opt/capcom/assets/bg.png
    [ -f "$RUNNINGFROM/patches/$LISTNAME/assets/bg_single.png" ] && mount --bind "$RUNNINGFROM/patches/$LISTNAME/assets/bg_single.png" /opt/capcom/assets/bg_single.png
    [ -f "$RUNNINGFROM/patches/$LISTNAME/assets/CP1.png" ] && mount --bind "$RUNNINGFROM/patches/$LISTNAME/assets/CP1.png" /opt/capcom/assets/CP1.png
    [ -f "$RUNNINGFROM/patches/$LISTNAME/assets/CP2.png" ] && mount --bind "$RUNNINGFROM/patches/$LISTNAME/assets/CP2.png" /opt/capcom/assets/CP2.png
    [ -f "$RUNNINGFROM/patches/$LISTNAME/assets/sounds/movement.ogg" ] && mount --bind "$RUNNINGFROM/patches/$LISTNAME/assets/sounds/movement.ogg" /opt/capcom/assets/sounds/movement.ogg

    # Don't ruin Easter Egg
    if [ -f "$RUNNINGFROM/patches/$LISTNAME/assets/gold/BARS_top.png" ] && [ "$LUCKY" = "10" ] && [ -f /opt/capcom/assets/gold/bg.png ]
    then
      mount --bind "$RUNNINGFROM/patches/$LISTNAME/assets/gold/BARS_top.png" /opt/capcom/assets/BARS_top.png
    else
      [ -f "$RUNNINGFROM/patches/$LISTNAME/assets/BARS_top.png" ] && mount --bind "$RUNNINGFROM/patches/$LISTNAME/assets/BARS_top.png" /opt/capcom/assets/BARS_top.png
    fi

    # Mount list of games for carousel
    mount --bind "$RUNNINGFROM/$LISTNAME.txt" /opt/capcom/assets/games.txt

    # Mount patched 'capcom' if exists
    [ -f "$RUNNINGFROM/patches/$LISTNAME/capcom" ] && mount --bind "$RUNNINGFROM/patches/$LISTNAME/capcom" /opt/capcom/capcom

    # Mount libretro core
    if [ -f "$RUNNINGFROM/patches/$LISTNAME/fba_libretro.so" ]
    then
      mount --bind "$RUNNINGFROM/patches/$LISTNAME/fba_libretro.so" /usr/lib/libretro/fba_libretro.so
    else
      mount --bind "$RUNNINGFROM/patches/fba_libretro.so" /usr/lib/libretro/fba_libretro.so
    fi

    # Mount our ROMs
    mount --bind "$ROMSFOLDER" /usr/share/roms
  fi
else
  echo -e "\nCould not find the folder \"$ROMSFOLDER\"\nThis file should be run with command \"$0\" \"Name of Games List\"";
  COUNTDOWN=10
  while [ $COUNTDOWN -ge 0 ]
  do
    echo -ne "\rGoing back to Choko Menu in $COUNTDOWN seconds... "
    COUNTDOWN=$((COUNTDOWN - 1))
    sleep 1
  done
  echo -e "\r\e[K"
  exit 202
fi

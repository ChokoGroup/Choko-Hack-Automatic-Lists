#! /bin/sh
# For Choko Hack 10.0.0+

LISTNAME=${0##*/};LISTNAME=${LISTNAME%.*}
RUNNINGFROM="$(dirname "$(readlink -f "$0")")"

creategamestxt () {
  FIRSTLINE="Y"
  ICONNUMBER=0
  while read FNAME; do
    eval "FNAME=\"\${FNAME#$RUNNINGFROM/roms/$LISTNAME/}\""
    GAMESTXTLINE="$(grep -m 1 "$FNAME" "$RUNNINGFROM/games_all.txt")"
    FNAME="${FNAME%.zip}"
    [ "$FIRSTLINE" = "N" ] && ( echo -en "\n" >> "$RUNNINGFROM/$LISTNAME.txt" ) || FIRSTLINE="N"
    if [ -n "$GAMESTXTLINE" ]
    then
      echo -n "$GAMESTXTLINE" >> "$RUNNINGFROM/$LISTNAME.txt"
    else
      if [ -f "$RUNNINGFROM/assets/games/$FNAME.png" ]
      then
        echo -n "A 0 B 0000 $FNAME.png $FNAME.zip $FNAME.ogg $FNAME" >> "$RUNNINGFROM/$LISTNAME.txt"
      else
        ICONNUMBER=$((ICONNUMBER + 1))
        [ ${#ICONNUMBER} -eq 1 ] && ( echo -n "A 0 B 0000 game0$ICONNUMBER.png $FNAME.zip $FNAME.ogg $FNAME" >> "$RUNNINGFROM/$LISTNAME.txt" ) || ( echo -n "A 0 B 0000 game$ICONNUMBER.png $FNAME.zip $FNAME.ogg $FNAME" >> "$RUNNINGFROM/$LISTNAME.txt" )
      fi
    fi
  done <<EOF
  $(find "$RUNNINGFROM/roms/$LISTNAME" -mindepth 1 -maxdepth 2 -name *.zip -type f -print 2> /dev/null | sort -f)
EOF
}

# First time running?
if [ ! -f "$RUNNINGFROM/assets/options/slider.png" ]
then
  for f in \
    blank.png \
    clock_reg.png \
    coin_btn_over.png \
    coin_btn_reg.png \
    CP1.png \
    CP2.png \
    difficulty_btn_over.png \
    difficulty_btn_reg.png \
    difficulty_frame_over.png \
    difficulty_frame_reg.png \
    options_btn_over.png \
    options_btn_reg.png \
    options_frame_over.png \
    options_frame_reg.png \
    options_over.png \
    options_reg.png \
    play_btn_over.png \
    play_btn_reg.png \
    slider.png
  do
    cp /opt/capcom/assets/options/$f "$RUNNINGFROM/assets/options"/
  done
fi

# Create games??.txt if it does not exist
[ -f "$RUNNINGFROM/$LISTNAME.txt" ] || creategamestxt

if [ -f "$RUNNINGFROM/$LISTNAME.txt" ]
then
  # Mount assets for games
  # Remember to choose Remix in music settings
  for DIR in \
    assets/games \
    assets/options \
    assets/sounds/music/set2
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
  [ -f "$RUNNINGFROM/patches/$LISTNAME/fba_libretro.so" ] && ( mount --bind "$RUNNINGFROM/patches/$LISTNAME/fba_libretro.so" /usr/lib/libretro/fba_libretro.so ) || ( mount --bind "$RUNNINGFROM/patches/fba_libretro.so" /usr/lib/libretro/fba_libretro.so )

  # Mount our ROMs
  [ "$RUNNINGFROM" = "/.choko" ] && ( mount --bind /usr/share/roms/$LISTNAME /usr/share/roms ) || ( mount --bind "$RUNNINGFROM/roms/$LISTNAME" /usr/share/roms )
fi
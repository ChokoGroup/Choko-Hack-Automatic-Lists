#! /bin/sh
# games1S.sh - Script to install games in CHA
# For Choko Hack 10.0.0+

RUNNINGFROM="$(dirname "$(readlink -f "$0")")"
# Variables to store buttons pressed
CHA1I="0"
CHA1S="0"
CHA2I="0"
CHA2S="0"
CHA1A="0"
CHA1B="0"
CHA1C="0"
CHA1D="0"
CHA1E="0"
CHA1F="0"
CHA2A="0"
CHA2B="0"
CHA2C="0"
CHA2D="0"
CHA2E="0"
CHA2F="0"
# Variables to store menu options
GAMES1A=""
GAMES1B=""
GAMES1C=""
GAMES1D=""
GAMES1E=""
GAMES1F=""
GAMES2A=""
GAMES2B=""
GAMES2C=""
GAMES2D=""
GAMES2E=""
GAMES2F=""

# Look for games installed with older packs
if [ -d /.CAPCOM ] || [ -d /.SNK ] || [ -d /usr/share/roms/CPS1 ] || [ -d /usr/share/roms/CPS2 ] || [ -d /usr/share/roms/CPS3 ] || [ -d /usr/share/roms/NEO-GEO ] || [ -d /usr/share/roms/PRE-CPS ] || [ -d /usr/share/roms/PRE-NEOGEO ] || [ -f /usr/share/roms/sftm.zip ] || [ -d /usr/share/roms/cps1 ] || [ -d /usr/share/roms/cps2 ] || [ -d /usr/share/roms/cps3 ] || [ -d /usr/share/roms/itech32 ] || [ -d /usr/share/roms/megadriv ] || [ -d /usr/share/roms/neogeo ] || [ -d /usr/share/roms/precps ] || [ -d /usr/share/roms/preneogeo ]
then
  echo -en "\n\n\e[1;33mGames from older packs were found!\n\e[1;93mThey are no longer supported, you should delete them.\e[m\nSpace that can be recovered: "
  du -hc /.CAPCOM /.SNK /usr/share/roms/CPS1 /usr/share/roms/CPS2 /usr/share/roms/CPS3 /usr/share/roms/NEO-GEO /usr/share/roms/PRE-CPS /usr/share/roms/PRE-NEOGEO /usr/share/roms/sftm.zip /usr/share/roms/cps1 /usr/share/roms/cps2 /usr/share/roms/cps3 /usr/share/roms/itech32 /usr/share/roms/megadriv /usr/share/roms/neogeo /usr/share/roms/precps /usr/share/roms/preneogeo 2>/dev/null | tail -n 1
  sleep 5
  echo -e "\n\e[m"

  # Wait for buttons to be released before asking to delete
  /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
  CHA2S=$?
  /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
  CHA1A=$?
  until [ "$CHA2S$CHA1A" = "00" ]
  do
    sleep 1
    /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
    CHA2S=$?
    /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
    CHA1A=$?
  done
  echo -e "Press \e[1;94m[P2 START]\e[m to delete or [P1 A] to cancel."
  COUNTDOWN=15
  while [ "$CHA2S$CHA1A" = "00" ] && [ $COUNTDOWN -ge 0 ]
  do
    echo -ne "\rWaiting $COUNTDOWN seconds... "
    COUNTDOWN=$((COUNTDOWN - 1))
    sleep 1
    /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
    CHA2S=$?
    /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
    CHA1A=$?
  done
  echo -e "\n"
  if [ "$CHA2S$CHA1A" = "100" ]
  then
    [ -d /.CAPCOM ] && ( rm -rf /.CAPCOM; echo -e "\e[1;30m/.CAPCOM deleted\e[m" )
    [ -d /.SNK ] && ( rm -rf /.SNK; echo -e "\e[1;30m/.SNK deleted\e[m" )
    [ -d /usr/share/roms/CPS1 ] && ( rm -rf /usr/share/roms/CPS1; echo -e "\e[1;30m/usr/share/roms/CPS1 deleted\e[m" )
    [ -d /usr/share/roms/CPS2 ] && ( rm -rf /usr/share/roms/CPS2; echo -e "\e[1;30m/usr/share/roms/CPS2 deleted\e[m" )
    [ -d /usr/share/roms/CPS3 ] && ( rm -rf /usr/share/roms/CPS3; echo -e "\e[1;30m/usr/share/roms/CPS3 deleted\e[m" )
    [ -d /usr/share/roms/NEO-GEO ] && ( rm -rf /usr/share/roms/NEO-GEO; echo -e "\e[1;30m/usr/share/roms/NEO-GEO deleted\e[m" )
    [ -d /usr/share/roms/PRE-CPS ] && ( rm -rf /usr/share/roms/PRE-CPS; echo -e "\e[1;30m/usr/share/roms/PRE-CPS deleted\e[m" )
    [ -d /usr/share/roms/PRE-NEOGEO ] && ( rm -rf /usr/share/roms/PRE-NEOGEO; echo -e "\e[1;30m/usr/share/roms/PRE-NEOGEO deleted\e[m" )
    [ -f /usr/share/roms/sftm.zip ] && ( rm -f /usr/share/roms/sftm.zip; echo -e "\e[1;30m/usr/share/roms/sftm.zip deleted\e[m" )
    [ -d /usr/share/roms/cps1 ] && ( rm -rf /usr/share/roms/cps1; echo -e "\e[1;30m/usr/share/roms/cps1 deleted\e[m" )
    [ -d /usr/share/roms/cps2 ] && ( rm -rf /usr/share/roms/cps2; echo -e "\e[1;30m/usr/share/roms/cps2 deleted\e[m" )
    [ -d /usr/share/roms/cps3 ] && ( rm -rf /usr/share/roms/cps3; echo -e "\e[1;30m/usr/share/roms/cps3 deleted\e[m" )
    [ -d /usr/share/roms/itech32 ] && ( rm -rf /usr/share/roms/itech32; echo -e "\e[1;30m/usr/share/roms/itech32 deleted\e[m" )
    [ -d /usr/share/roms/megadriv ] && ( rm -rf /usr/share/roms/megadriv; echo -e "\e[1;30m/usr/share/roms/megadriv deleted\e[m" )
    [ -d /usr/share/roms/neogeo ] && ( rm -rf /usr/share/roms/neogeo; echo -e "\e[1;30m/usr/share/roms/neogeo deleted\e[m" )
    [ -d /usr/share/roms/precps ] && ( rm -rf /usr/share/roms/precps; echo -e "\e[1;30m/usr/share/roms/precps deleted\e[m" )
    [ -d /usr/share/roms/preneogeo ] && ( rm -rf /usr/share/roms/preneogeo; echo -e "\e[1;30m/usr/share/roms/preneogeo deleted\e[m" )
  else
    echo "Old games not deleted!"
  fi
fi

for M in "1" "2"
do
  for N in "A" "B" "C" "D" "E" "F"
  do
    if [ -d "/.choko/games$M$N" ]
    then
      WASOK=0
      eval "GAMES$M$N=\$(head -n 1 /.choko/games$M$N.nfo)"
      # Wait for buttons to be released before asking to delete
      /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
      CHA2S=$?
      /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
      CHA1A=$?
      until [ "$CHA2S$CHA1A" = "00" ]
      do
        sleep 1
        /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
        CHA2S=$?
        /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
        CHA1A=$?
      done
      echo -e "\nThis games list from previous pack should still work but is not recommended to mix packs."
      eval "echo -e \"Do you want to \\e[1;93mdelete \\\"\$GAMES$M$N\\\" from the CHA?\\e[m\""
      echo -e "Press \e[1;94m[P2 START]\e[m to delete or [P1 A] to cancel."
      COUNTDOWN=15
      while [ "$CHA2S$CHA1A" = "00" ] && [ $COUNTDOWN -ge 0 ]
      do
        echo -ne "\rWaiting $COUNTDOWN seconds... "
        COUNTDOWN=$((COUNTDOWN - 1))
        sleep 1
        /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
        CHA2S=$?
        /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
        CHA1A=$?
      done
      echo -e "\n"
      if [ "$CHA2S$CHA1A" = "100" ]
      then
        eval "echo \"Deleting \\\"\$GAMES$M$N\\\" from the CHA...\""
        echo -e "\e[1;30mrm -rf /.choko/games$M$N*\e[m"; rm -rf /.choko/games$M$N*; WASOK=$?
        if [ $WASOK -eq 0 ]
        then
          echo -e "\e[1;30mrm -rf /usr/share/roms/games$M$N\e[m"; rm -rf /usr/share/roms/games$M$N; WASOK=$?
        fi
        if [ $WASOK -eq 0 ] && [ $(find /.choko -name 'games??.nfo' -type f -print 2> /dev/null | wc -l) -eq 0 ]
        then
          # If all lists were deleted then also delete menu and libretro cores
          echo -e "\e[1;30mrm /.choko/usb_exec.sh\e[m"; rm /.choko/usb_exec.sh; WASOK=$?
          if [ $WASOK -eq 0 ]
          then
            echo -e "\e[1;30mrm -rf /.choko/usr\e[m"; rm -rf /.choko/usr; WASOK=$?
          fi
        fi
        if [ $WASOK -eq 0 ]
        then
          eval "echo \"\\\"\$GAMES$M$N\\\" deleted from the CHA.\""
        else
          echo -e "\e[1;31mThere was some error.\e[m"; sleep 10; exit 201
        fi
      fi
    fi
  done
done


# Go through available lists to delete or install
for M in "1" "2"
do
  for N in "A" "B" "C" "D" "E" "F"
  do
    if [ -f "/.choko/games$M$N.txt" ] && [ -f "/.choko/games$M$N.nfo" ]
    then
      if [ -f "$RUNNINGFROM/games$M$N.txt" ] && [ -f "$RUNNINGFROM/games$M$N.nfo" ]
      then
        # The list is both in CHA and USB
        WASOK=0
        eval "GAMES$M$N=\$(head -n 1 \"$RUNNINGFROM/games$M$N.nfo\")"
        FREESPACE=$(df -P / | tail -1 | awk '{print $4}')
        USEDSPACECHA=$(du -c "/usr/share/roms/games$M$N" "/.choko/patches/games$M$N" 2>/dev/null | tail -n 1 | awk '{print $1;}')
        USEDSPACEUSB=$(du -c "$RUNNINGFROM/roms/games$M$N" "$RUNNINGFROM/patches/games$M$N" "$RUNNINGFROM/patches/fba_libretro.so" "$RUNNINGFROM/patches/fba_libretro.so" 2>/dev/null | tail -n 1 | awk '{print $1;}')
        if [ $(( USEDSPACEUSB - USEDSPACECHA )) -gt $FREESPACE ]
        then
          eval "echo -e \"\\nNot enought space to copy \\\"\$GAMES$M$N\\\".\""
        else
          # Wait for buttons to be released before asking to delete
          /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
          CHA2S=$?
          /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
          CHA1A=$?
          until [ "$CHA2S$CHA1A" = "00" ]
          do
            sleep 1
            /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
            CHA2S=$?
            /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
            CHA1A=$?
          done
          eval "echo -e \"\nDo you want to copy \\\"\$GAMES$M$N\\\" from USB?\\n\\e[1;93m\\\"\$(head -n 1 /.choko/games$M$N.nfo)\\\" in the CHA will be overwritten!\\e[m\""
          echo -e "Press \e[1;94m[P2 START]\e[m to copy or [P1 A] to cancel."
          COUNTDOWN=15
          while [ "$CHA2S$CHA1A" = "00" ] && [ $COUNTDOWN -ge 0 ]
          do
            echo -ne "\rWaiting $COUNTDOWN seconds... "
            COUNTDOWN=$((COUNTDOWN - 1))
            sleep 1
            /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
            CHA2S=$?
            /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
            CHA1A=$?
          done
          echo -e "\n"
          if [ "$CHA2S$CHA1A" = "100" ]
          then
            eval "echo \"Installing \\\"\$GAMES$M$N\\\" into CHA\"..."
            echo "This can take some time. Please wait."
            echo -e "\e[1;30mDeleting old assets from /.choko/assets/\e[m"
            while read -r FNAME; do
              FNAME=${FNAME##*/}
              if [ "$FNAME" != "neogeo.zip" ]
              then
                FNAME=${FNAME%.zip}
                find "/.choko/assets" -type f -name "$FNAME.*" -exec rm {} +
                WASOK=$?
                [ $WASOK -eq 0 ] || break
              fi
            done <<EOF1
$(find "/usr/share/roms/games$M$N" -mindepth 1 -maxdepth 2 -name '*.zip' -type f -print 2> /dev/null | sort -f)
EOF1

            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mrm -rf /usr/share/roms/games$M$N\e[m"; rm -rf /usr/share/roms/games$M$N; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mrm -rf /.choko/patches/games$M$N\e[m"; rm -rf /.choko/patches/games$M$N; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mrm /.choko/games$M$N*\e[m"; rm /.choko/games$M$N*; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mcp -r \"$RUNNINGFROM/roms/games$M$N\" /usr/share/roms/\e[m"; cp -r "$RUNNINGFROM/roms/games$M$N" /usr/share/roms/; WASOK=$?
            fi
            mkdir -p /.choko/patches
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mcp -u \"$RUNNINGFROM/patches/fba_libretro.so\" /.choko/patches/\e[m"; cp -u "$RUNNINGFROM/patches/fba_libretro.so" /.choko/patches/; WASOK=$?
            fi
            if [ $WASOK -eq 0 ] && [ -d "$RUNNINGFROM/patches/games$M$N" ]
            then
              echo -e "\e[1;30mcp -r \"$RUNNINGFROM/patches/games$M$N\" /.choko/patches/\e[m"; cp -r "$RUNNINGFROM/patches/games$M$N" /.choko/patches/; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mCopying new assets from \"$RUNNINGFROM/assets\"\e[m"
              while read -r LINE || [ -n "$LINE" ]; do
                PNGFILE=${LINE%'.png'*}; PNGFILE=${PNGFILE##*' '}
                ZIPFILE=${LINE%'.zip'*}; ZIPFILE=${ZIPFILE##*' '}
                ASSETSFOLDER="$(dirname "/.choko/assets/games/$PNGFILE.png")"
                mkdir -p "$ASSETSFOLDER"
                cp "$RUNNINGFROM/assets/games/$PNGFILE.png" "$ASSETSFOLDER/"; WASOK=$?
                if [ $WASOK -eq 0 ] && [ -f "$RUNNINGFROM/assets/options/$ZIPFILE.png" ]
                then
                  ASSETSFOLDER="$(dirname "/.choko/assets/options/$ZIPFILE.png")"
                  mkdir -p "$ASSETSFOLDER"
                  cp "$RUNNINGFROM/assets/options/$ZIPFILE.png" "$ASSETSFOLDER/"; WASOK=$?
                fi
                if [ $WASOK -eq 0 ] && [ -f "$RUNNINGFROM/assets/options/large/$ZIPFILE.png" ]
                then
                  ASSETSFOLDER="$(dirname "/.choko/assets/options/large/$ZIPFILE.png")"
                  mkdir -p "$ASSETSFOLDER"
                  cp "$RUNNINGFROM/assets/options/large/$ZIPFILE.png" "$ASSETSFOLDER/"; WASOK=$?
                fi
                if [ $WASOK -eq 0 ] && [ -f "$RUNNINGFROM/assets/sounds/music/set2/$ZIPFILE.ogg" ]
                then
                  ASSETSFOLDER="$(dirname "/.choko/assets/sounds/music/set2/$ZIPFILE.ogg")"
                  mkdir -p "$ASSETSFOLDER"
                  cp "$RUNNINGFROM/assets/sounds/music/set2/$ZIPFILE.ogg" "$ASSETSFOLDER/"; WASOK=$?
                fi
                [ $WASOK -eq 0 ] || break
              done < "$RUNNINGFROM/games$M$N.txt"
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mcp \"$RUNNINGFROM/games$M$N\"* /.choko/\e[m"; cp "$RUNNINGFROM/games$M$N"* /.choko/; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              eval "echo \"\\\"\$GAMES$M$N\\\" installed.\""
            else
              echo -e "\e[1;31mThere was some error.\e[m"; sleep 10; exit 201
            fi
          fi
        fi
      else
        # The list is only in CHA
        WASOK=0
        eval "GAMES$M$N=\$(head -n 1 /.choko/games$M$N.nfo)"
        # Wait for buttons to be released before asking to delete
        /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
        CHA2S=$?
        /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
        CHA1A=$?
        until [ "$CHA2S$CHA1A" = "00" ]
        do
          sleep 1
          /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
          CHA2S=$?
          /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
          CHA1A=$?
        done
        eval "echo -e \"\nDo you want to \\e[1;93mdelete \\\"\$GAMES$M$N\\\" from the CHA?\\e[m\""
        echo -e "Press \e[1;94m[P2 START]\e[m to delete or [P1 A] to cancel."
        COUNTDOWN=15
        while [ "$CHA2S$CHA1A" = "00" ] && [ $COUNTDOWN -ge 0 ]
        do
          echo -ne "\rWaiting $COUNTDOWN seconds... "
          COUNTDOWN=$((COUNTDOWN - 1))
          sleep 1
          /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
          CHA2S=$?
          /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
          CHA1A=$?
        done
        echo -e "\n"
        if [ "$CHA2S$CHA1A" = "100" ]
        then
          eval "echo \"Deleting \\\"\$GAMES$M$N\\\" from the CHA...\""
          echo -e "\e[1;30mDeleting old assets from /.choko/assets/\e[m"
          while read -r FNAME; do
            FNAME=${FNAME##*/}
            if [ "$FNAME" != "neogeo.zip" ]
            then
              FNAME=${FNAME%.zip}
              find "/.choko/assets" -type f -name "$FNAME.*" -exec rm {} +
              WASOK=$?
              [ $WASOK -eq 0 ] || break
            fi
          done <<EOF2
$(find "/usr/share/roms/games$M$N" -mindepth 1 -maxdepth 2 -name '*.zip' -type f -print 2> /dev/null | sort -f)
EOF2

          if [ $WASOK -eq 0 ]
          then
            echo -e "\e[1;30mrm -rf /usr/share/roms/games$M$N\e[m"; rm -rf /usr/share/roms/games$M$N; WASOK=$?
          fi
          if [ $WASOK -eq 0 ]
          then
            echo -e "\e[1;30mrm -rf /.choko/patches/games$M$N\e[m"; rm -rf /.choko/patches/games$M$N; WASOK=$?
          fi
          if [ $WASOK -eq 0 ]
          then
            echo -e "\e[1;30mrm /.choko/games$M$N*\e[m"; rm /.choko/games$M$N*; WASOK=$?
          fi
          if [ $WASOK -eq 0 ] && [ $(find /.choko -name 'games??.nfo' -type f -print 2> /dev/null | wc -l) -eq 0 ] && [ ! -x "/.choko/.FTP/uFTP" ] && [ ! -x "/.choko/.SSH/dropbear" ]
          then
            # If all lists were deleted then also delete menu and libretro cores
            echo -e "\e[1;30mrm /.choko/usb_exec.sh\e[m"; rm /.choko/usb_exec.sh; WASOK=$?
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mrm -rf /.choko/patches\e[m"; rm -rf /.choko/patches; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mrm -rf /.choko/assets\e[m"; rm -rf /.choko/assets; WASOK=$?
            fi
          fi
          if [ $WASOK -eq 0 ]
          then
            eval "echo \"\\\"\$GAMES$M$N\\\" deleted from the CHA.\""
          else
            echo -e "\e[1;31mThere was some error.\e[m"; sleep 10; exit 201
          fi
        fi
      fi
    else
      if [ -f "$RUNNINGFROM/games$M$N.txt" ] && [ -f "$RUNNINGFROM/games$M$N.nfo" ]
      then
        # The list is only in USB
        WASOK=0
        eval "GAMES$M$N=\$(head -n 1 \"$RUNNINGFROM/games$M$N.nfo\")"
        FREESPACE=$(df -P / | tail -1 | awk '{print $4}')
        USEDSPACEUSB=$(du -c "$RUNNINGFROM/roms/games$M$N" "$RUNNINGFROM/patches/games$M$N" "$RUNNINGFROM/patches/fba_libretro.so" "$RUNNINGFROM/patches/fba_libretro.so" 2>/dev/null | tail -n 1 | awk '{print $1;}')
        if [ $USEDSPACEUSB -gt $FREESPACE ]
        then
          eval "echo -e \"\\nNot enought space to copy \\\"\$GAMES$M$N\\\".\""
        else
          # Wait for buttons to be released before asking to delete
          /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
          CHA2S=$?
          /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
          CHA1A=$?
          until [ "$CHA2S$CHA1A" = "00" ]
          do
            sleep 1
            /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
            CHA2S=$?
            /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
            CHA1A=$?
          done
          eval "echo -e \"\nDo you want to copy \\\"\$GAMES$M$N\\\" from USB into the CHA?\""
          echo -e "Press \e[1;94m[P2 START]\e[m to copy or [P1 A] to cancel."
          COUNTDOWN=15
          while [ "$CHA2S$CHA1A" = "00" ] && [ $COUNTDOWN -ge 0 ]
          do
            echo -ne "\rWaiting $COUNTDOWN seconds... "
            COUNTDOWN=$((COUNTDOWN - 1))
            sleep 1
            /usr/sbin/evtest --query /dev/input/event3 EV_KEY BTN_BASE
            CHA2S=$?
            /usr/sbin/evtest --query /dev/input/event2 EV_KEY BTN_TOP
            CHA1A=$?
          done
          echo -e "\n"
          if [ "$CHA2S$CHA1A" = "100" ]
          then
            eval "echo \"Installing \\\"\$GAMES$M$N\\\" into CHA\"..."
            echo "This can take some time. Please wait."
            mkdir -p /.choko/assets
            mkdir -p /.choko/patches
            echo -e "\e[1;30mcp -u \"$RUNNINGFROM/assets/capcom-home-arcade-last.png\" /.choko/assets/\e[m"; cp -u "$RUNNINGFROM/assets/capcom-home-arcade-last.png" /.choko/assets/; WASOK=$?
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mcp -r \"$RUNNINGFROM/roms/games$M$N\" /usr/share/roms/\e[m"; cp -r "$RUNNINGFROM/roms/games$M$N" /usr/share/roms/; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mcp -u \"$RUNNINGFROM/patches/fba_libretro.so\" /.choko/patches/\e[m"; cp -u "$RUNNINGFROM/patches/fba_libretro.so" /.choko/patches/; WASOK=$?
            fi
            if [ $WASOK -eq 0 ] && [ -d "$RUNNINGFROM/patches/games$M$N" ]
            then
              echo -e "\e[1;30mcp -r \"$RUNNINGFROM/patches/games$M$N\" /.choko/patches/\e[m"; cp -r "$RUNNINGFROM/patches/games$M$N" /.choko/patches/; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mCopying new assets from \"$RUNNINGFROM/assets\"\e[m"
              while read -r LINE || [ -n "$LINE" ]; do
                PNGFILE=${LINE%'.png'*}; PNGFILE=${PNGFILE##*' '}
                ZIPFILE=${LINE%'.zip'*}; ZIPFILE=${ZIPFILE##*' '}
                ASSETSFOLDER="$(dirname "/.choko/assets/games/$PNGFILE.png")"
                mkdir -p "$ASSETSFOLDER"
                cp "$RUNNINGFROM/assets/games/$PNGFILE.png" "$ASSETSFOLDER/"; WASOK=$?
                if [ $WASOK -eq 0 ] && [ -f "$RUNNINGFROM/assets/options/$ZIPFILE.png" ]
                then
                  ASSETSFOLDER="$(dirname "/.choko/assets/options/$ZIPFILE.png")"
                  mkdir -p "$ASSETSFOLDER"
                  cp "$RUNNINGFROM/assets/options/$ZIPFILE.png" "$ASSETSFOLDER/"; WASOK=$?
                fi
                if [ $WASOK -eq 0 ] && [ -f "$RUNNINGFROM/assets/options/large/$ZIPFILE.png" ]
                then
                  ASSETSFOLDER="$(dirname "/.choko/assets/options/large/$ZIPFILE.png")"
                  mkdir -p "$ASSETSFOLDER"
                  cp "$RUNNINGFROM/assets/options/large/$ZIPFILE.png" "$ASSETSFOLDER/"; WASOK=$?
                fi
                if [ $WASOK -eq 0 ] && [ -f "$RUNNINGFROM/assets/sounds/music/set2/$ZIPFILE.ogg" ]
                then
                  ASSETSFOLDER="$(dirname "/.choko/assets/sounds/music/set2/$ZIPFILE.ogg")"
                  mkdir -p "$ASSETSFOLDER"
                  cp "$RUNNINGFROM/assets/sounds/music/set2/$ZIPFILE.ogg" "$ASSETSFOLDER/"; WASOK=$?
                fi
                [ $WASOK -eq 0 ] || break
              done < "$RUNNINGFROM/games$M$N.txt"
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mcp \"$RUNNINGFROM/games$M$N\"* /.choko/\e[m"; cp "$RUNNINGFROM/games$M$N"* /.choko/; WASOK=$?
            fi
            if [ $WASOK -eq 0 ] && [ ! -x /.choko/usb_exec.sh ]
            then
              # If this is the first list of games being copied then install the menu
              echo -e "\e[1;30mcp \"$RUNNINGFROM/usb_exec.sh\" /.choko/\e[m"; cp "$RUNNINGFROM/usb_exec.sh" /.choko/; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              eval "echo \"\\\"\$GAMES$M$N\\\" installed.\""
            else
              echo -e "\e[1;31mThere was some error.\e[m"; sleep 10; exit 201
            fi
          fi
        fi
      fi
    fi
  done
done

FREESPACE=$(df -hP / | tail -1 | awk '{print $4}')
echo -e "\n\nThere is nothing else to do here.\nYou still have $FREESPACE free.\n"
COUNTDOWN=5
while [ $COUNTDOWN -ge 0 ]
do
  echo -ne "\rRebooting in $COUNTDOWN seconds... "
  COUNTDOWN=$((COUNTDOWN - 1))
  sleep 1
done
echo -e "\n"
exit 200

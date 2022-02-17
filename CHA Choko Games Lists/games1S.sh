#!/bin/sh
# games1S.sh - Script to install games in CHA
# v12.3.1

# Simple string compare, since until 10.0.0 CHOKOVERSION wasn't set
# Future versions need to keep this in mind
if [ "$CHOKOVERSION" \< "12.0.0" ]
then
  echo -e "\nYou are running an outdated version of Choko Hack.\nYou need v12.0.0 or later.\n";
  COUNTDOWN=5
  while [ $COUNTDOWN -ge 0 ]
  do
    echo -ne "\rRebooting in $COUNTDOWN seconds... "
    COUNTDOWN=$((COUNTDOWN - 1))
    sleep 1
  done
  echo -ne "\r\e[K"
  if [ "$CHOKOVERSION" \< "10.0.0" ]
  then
    reboot -f
  else
    exit 200
  fi
fi

RUNNINGFROM="$(dirname "$(readlink -f "$0")")"

# Make 'for' loops use entire lines
OIFS="$IFS"
IFS=$'\n'

# Look for installed games
echo -e "\n\nLooking for installed games..."
if [ $(find /usr/share/roms -name '*.zip' -mindepth 2 -type f -print 2> /dev/null | wc -l) -gt 0 ]
then
  for ROMSFOLDER in $(find /usr/share/roms -name '*' -mindepth 1 -maxdepth 1 -type d -print 2> /dev/null | sort -f)
  do
    if [ $(find "$ROMSFOLDER" -name '*.zip' -type f -print 2> /dev/null | wc -l) -gt 0 ]
    then
      case "$ROMSFOLDER" in 
        # 'games??' logic from Choko Hack v11
        *games[12][A-F])
          LISTNAME="$(head -n 1 "/.choko/${ROMSFOLDER##*/}.nfo")"
        ;;
        *)
          # ROMS_FOLDER_NAME logic from Choko Hack v12
          LISTNAME="${ROMSFOLDER##*/}"
        ;; 
      esac
      
      # Wait for buttons to be released before asking to delete
      while [ "$(readjoysticks j1 j2 -b)" != "0000000000000000" ]
      do
        sleep 1
      done
      COUNTDOWN=15
      STOPCOUNT="N"
      ANSWER="No"
      echo -ne "\nDo you want to \e[1;31muninstall\e[m \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[1;30mUse joystick to change answer. Waiting $COUNTDOWN seconds...\e[m "

      # Read joystick
      while [ $COUNTDOWN -gt 0 ]
      do
        case "$(readjoysticks j1)" in
          U|D|L|R)
            if [ "$ANSWER" = "No" ]
            then
              ANSWER="Yes"
            else
              ANSWER="No"
            fi
            if [ "$STOPCOUNT" = "N" ]
            then
              STOPCOUNT="Y"
            fi
            echo -ne "\r\e[1ADo you want to \e[1;31muninstall\e[m \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[m\e[K"
          ;;
          0|1|2|3|4|5|6|7)
            COUNTDOWN=0
          ;;
          *)
            if [ "$STOPCOUNT" = "N" ]
            then
              COUNTDOWN=$((COUNTDOWN - 1))
              echo -ne "\r\e[1ADo you want to \e[1;31muninstall\e[m \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[1;30mUse joystick to change answer. Waiting $COUNTDOWN seconds...\e[m "
            fi
          ;;
        esac
      done
      echo -ne "\r\e[1ADo you want to \e[1;31muninstall\e[m \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[m\e[K"
      if [ "$ANSWER" = "Yes" ]
      then
        echo "Uninstalling \"$LISTNAME\"..."
        echo -e "\e[1;30mrm -rf \"$ROMSFOLDER\"\e[m"; rm -rf "$ROMSFOLDER"; WASOK=$?
        if [ -d "/.choko/patches/${ROMSFOLDER##*/}" ] && [ $WASOK -eq 0 ]
        then
          echo -e "\e[1;30mrm -rf \"/.choko/patches/${ROMSFOLDER##*/}\"\e[m"; rm -rf "/.choko/patches/${ROMSFOLDER##*/}"; WASOK=$?
        fi
        if [ $WASOK -eq 0 ]
        then
          if [ $(find /usr/share/roms -name '*.zip' -mindepth 2 -type f -print 2> /dev/null | wc -l) -eq 0 ]
          then
            echo -e "\e[1;30mLast games uninstalled. Deleting all assets and patches left behind.\e[m"
            if [ -d /.choko/patches ]
            then
              echo -e "\e[1;30mrm -rf \"/.choko/patches\"\e[m"; rm -rf /.choko/patches; WASOK=$?
            fi
            if [ $WASOK -eq 0 ] && [ -d /.choko/assets ]
            then
              echo -e "\e[1;30mrm -rf \"/.choko/assets\"\e[m"; rm -rf /.choko/assets; WASOK=$?
            fi
            if [ $WASOK -eq 0 ] && [ -f /.choko/usb_exec.sh ]
            then
              echo -e "\e[1;30mrm \"/.choko/usb_exec.sh\"\e[m"; rm /.choko/usb_exec.sh; WASOK=$?
            fi
          else
            echo -e "\e[1;30mDeleting unneeded assets...\e[m";
            while read -r LINE || [ -n "$LINE" ]; do
              OGGFILE=${LINE%'.ogg'*}; OGGFILE=${OGGFILE##*' '}
              PNGFILE=${LINE%'.png'*}; PNGFILE=${PNGFILE##*' '}
              ZIPFILE=${LINE%'.zip'*}; ZIPFILE=${ZIPFILE##*' '}
              find "/.choko/assets" -type f \( -name "$OGGFILE.*" -or -name "$PNGFILE.*" -or -name "$ZIPFILE.*" \) -exec rm {} +
              WASOK=$?
              [ $WASOK -eq 0 ] || break
            done < "/.choko/${ROMSFOLDER##*/}.txt"
          fi
        fi
        if [ $WASOK -eq 0 ]
        then
          echo -e "\e[1;30mrm -f \"/.choko/${ROMSFOLDER##*/}.\"*\e[m"; rm -f "/.choko/${ROMSFOLDER##*/}."*; WASOK=$?
        fi
        if [ $WASOK -eq 0 ]
        then
          echo -e "\e[1;32m\"$LISTNAME\" was uninstalled.\e[m"
        else
          echo -e "\e[1;31mThere was some error.\e[m"; sleep 10; exit 201
        fi
      else
        echo "\"$LISTNAME\" was NOT uninstalled."
      fi
    fi
  done
else
  echo "Did not found installed games."
fi


# Look for games to install
echo -e "\n\nLooking for games to install..."
if [ $(find "$RUNNINGFROM/roms" -name '*.zip' -mindepth 2 -type f -print 2> /dev/null | wc -l) -gt 0 ]
then
  for ROMSFOLDER in $(find "$RUNNINGFROM/roms" -name '*' -mindepth 1 -maxdepth 1 -type d -print 2> /dev/null | sort -f)
  do
    if [ $(find "$ROMSFOLDER" -name '*.zip' -type f -print 2> /dev/null | wc -l) -gt 0 ]
    then
      LISTNAME="${ROMSFOLDER##*/}"
      FREESPACE=$(df -P / | tail -1 | awk '{print $4}')
      # The size of fba_libretro.so is added twice to give some extra space for assets
      USEDSPACEUSB=$(du -c "$ROMSFOLDER" "$RUNNINGFROM/patches/$LISTNAME" "$RUNNINGFROM/patches/fba_libretro.so" "$RUNNINGFROM/patches/fba_libretro.so" 2>/dev/null | tail -n 1 | awk '{print $1;}')

      if [ -d "/usr/share/roms/$LISTNAME" ]
      then
        USEDSPACECHA=$(du -c "/usr/share/roms/$LISTNAME" "/.choko/patches/$LISTNAME" 2>/dev/null | tail -n 1 | awk '{print $1;}')
        FREESPACE=$((FREESPACE + USEDSPACECHA))
      fi
      if [ $USEDSPACEUSB -gt $FREESPACE ]
      then
        echo -e "\nNot enought space to install \"$LISTNAME\"."
      else

        # Wait for buttons to be released before asking to delete
        while [ "$(readjoysticks j1 j2 -b)" != "0000000000000000" ]
        do
          sleep 1
        done
        COUNTDOWN=15
        STOPCOUNT="N"
        ANSWER="No"
        if [ -d "/usr/share/roms/$LISTNAME" ]
        then
          echo -ne "\n\e[1;93mA list named \"$LISTNAME\" is already installed in CHA and will be replaced if you choose YES!\e[m"
        fi
        echo -ne "\nDo you want to install \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[1;30mUse joystick to change answer. Waiting $COUNTDOWN seconds...\e[m "

        # Read joystick
        while [ $COUNTDOWN -gt 0 ]
        do
          case "$(readjoysticks j1)" in
            U|D|L|R)
              if [ "$ANSWER" = "No" ]
              then
                ANSWER="Yes"
              else
                ANSWER="No"
              fi
              if [ "$STOPCOUNT" = "N" ]
              then
                STOPCOUNT="Y"
              fi
              echo -ne "\r\e[1ADo you want to install \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[m\e[K"
            ;;
            0|1|2|3|4|5|6|7)
              COUNTDOWN=0
            ;;
            *)
              if [ "$STOPCOUNT" = "N" ]
              then
                COUNTDOWN=$((COUNTDOWN - 1))
                echo -ne "\r\e[1ADo you want to install \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[1;30mUse joystick to change answer. Waiting $COUNTDOWN seconds...\e[m "
              fi
            ;;
          esac
        done
        echo -ne "\r\e[1ADo you want to install \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[m\e[K"
        if [ "$ANSWER" = "Yes" ]
        then
          WASOK=0
          if [ -d "/usr/share/roms/$LISTNAME" ]
          then
            echo "Uninstalling old \"$LISTNAME\" from the CHA..."
            if [ -d "/usr/share/roms/$LISTNAME" ]
            then
              echo -e "\e[1;30mrm -rf \"/usr/share/roms/$LISTNAME\"\e[m"; rm -rf "/usr/share/roms/$LISTNAME"; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              if [ $(find /usr/share/roms -name '*.zip' -mindepth 2 -type f -print 2> /dev/null | wc -l) -eq 0 ]
              then
                echo -e "\e[1;30mLast games uninstalled. Deleting all assets and patches left behind.\e[m"
                if [ -d /.choko/patches ]
                then
                  echo -e "\e[1;30mrm -rf \"/.choko/patches\"\e[m"; rm -rf /.choko/patches; WASOK=$?
                fi
                if [ $WASOK -eq 0 ] && [ -d /.choko/assets ]
                then
                  echo -e "\e[1;30mrm -rf \"/.choko/assets\"\e[m"; rm -rf /.choko/assets; WASOK=$?
                fi
                if [ $WASOK -eq 0 ] && [ -f /.choko/usb_exec.sh ]
                then
                  echo -e "\e[1;30mrm \"/.choko/usb_exec.sh\"\e[m"; rm /.choko/usb_exec.sh; WASOK=$?
                fi
              else
                echo -e "\e[1;30mDeleting unneeded assets...\e[m";
                while read -r LINE || [ -n "$LINE" ]; do
                  OGGFILE=${LINE%'.ogg'*}; OGGFILE=${OGGFILE##*' '}
                  PNGFILE=${LINE%'.png'*}; PNGFILE=${PNGFILE##*' '}
                  ZIPFILE=${LINE%'.zip'*}; ZIPFILE=${ZIPFILE##*' '}
                  find "/.choko/assets" -type f \( -name "$OGGFILE.*" -or -name "$PNGFILE.*" -or -name "$ZIPFILE.*" \) -exec rm {} +
                  WASOK=$?
                  [ $WASOK -eq 0 ] || break
                done < "/.choko/${ROMSFOLDER##*/}.txt"
              fi
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mrm -f \"/.choko/$LISTNAME.\"*\e[m"; rm -f "/.choko/$LISTNAME."*; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;32mOld \"$LISTNAME\" was uninstalled from CHA.\e[m"
            else
              echo -e "\e[1;31mThere was some error.\e[m"; sleep 10; exit 201
            fi
          fi
          echo "Installing \"$LISTNAME\"..."
          mkdir -p /.choko/assets
          mkdir -p /.choko/patches
          mkdir -p /.choko/options
          [ -f /.choko/assets/capcom-home-arcade-last.png ] || cp -u "$RUNNINGFROM/assets/capcom-home-arcade-last.png" /.choko/assets/
          echo -ne "\e[1;30mcp -r \"$ROMSFOLDER\" /usr/share/roms/   \e[m\e[5m Please wait... \e[m"; cp -r "$ROMSFOLDER" /usr/share/roms/; WASOK=$?
          if [ $WASOK -eq 0 ]
          then
            echo -e "\r\e[1;30mcp -r \"$ROMSFOLDER\" /usr/share/roms/    (OK)           \e[m"
            echo -ne "\e[1;30mcp -u \"$RUNNINGFROM/patches/fba_libretro.so\" /.choko/patches/   \e[m\e[5m Please wait... \e[m"; cp -u "$RUNNINGFROM/patches/fba_libretro.so" /.choko/patches/; WASOK=$?
          fi
          if [ $WASOK -eq 0 ]
          then
            echo -e "\r\e[1;30mcp -u \"$RUNNINGFROM/patches/fba_libretro.so\" /.choko/patches/    (OK)           \e[m"
            if [ -d "$RUNNINGFROM/patches/$LISTNAME" ]
            then
              echo -ne "\e[1;30mcp -r \"$RUNNINGFROM/patches/$LISTNAME\" /.choko/patches/   \e[m\e[5m Please wait... \e[m"; cp -r "$RUNNINGFROM/patches/$LISTNAME" /.choko/patches/; WASOK=$?
              if [ $WASOK -eq 0 ]
              then
                echo -e "\r\e[1;30mcp -r \"$RUNNINGFROM/patches/$LISTNAME\" /.choko/patches/    (OK)           \e[m"
              fi
            else
              if [ -d "$RUNNINGFROM/patches/default" ]
              then
                echo -ne "\e[1;30mcp -r \"$RUNNINGFROM/patches/default\" /.choko/patches/   \e[m\e[5m Please wait... \e[m"; cp -r "$RUNNINGFROM/patches/default" /.choko/patches/; WASOK=$?
                if [ $WASOK -eq 0 ]
                then
                  echo -e "\r\e[1;30mcp -r \"$RUNNINGFROM/patches/default\" /.choko/patches/    (OK)           \e[m"
                fi
              fi
            fi
          fi
          if [ $WASOK -eq 0 ]
          then
            if [ ! -f "$RUNNINGFROM/$LISTNAME.txt" ]
            then
              echo -n "Creating \"$LISTNAME.txt\""
              FIRSTLINE="Y"
              ICONNUMBER=0
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
              echo -e "\n"
            fi
            echo -ne "\e[1;30mCopying assets from \"$RUNNINGFROM/assets\" into CHA...   \e[m\e[5m Please wait... \e[m"
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
              if [ $WASOK -eq 0 ] && [ -f "$RUNNINGFROM/assets/sounds/$ZIPFILE.ogg" ]
              then
                ASSETSFOLDER="$(dirname "/.choko/assets/sounds/$ZIPFILE.ogg")"
                mkdir -p "$ASSETSFOLDER"
                cp "$RUNNINGFROM/assets/sounds/$ZIPFILE.ogg" "$ASSETSFOLDER/"; WASOK=$?
              fi
              [ $WASOK -eq 0 ] || break
            done < "$RUNNINGFROM/$LISTNAME.txt"
          fi
          if [ $WASOK -eq 0 ]
          then
            echo -e "\r\e[1;30mCopying assets from \"$RUNNINGFROM/assets\" into CHA...    (OK)           \e[m"
            echo -ne "\e[1;30mcp \"$RUNNINGFROM/$LISTNAME.\"* /.choko/   \e[m\e[5m Please wait... \e[m"; cp "$RUNNINGFROM/$LISTNAME."* /.choko/; WASOK=$?
          fi
          if [ $WASOK -eq 0 ]
          then
            echo -e "\r\e[1;30mcp \"$RUNNINGFROM/$LISTNAME.\"* /.choko/    (OK)           \e[m"
            echo -ne "\e[1;30mcp \"$RUNNINGFROM/usb_exec.sh\" /.choko/   \e[m\e[5m Please wait... \e[m"; cp "$RUNNINGFROM/usb_exec.sh" /.choko/; WASOK=$?
          fi
          if [ $WASOK -eq 0 ]
          then
            echo -e "\r\e[1;30mcp \"$RUNNINGFROM/usb_exec.sh\" /.choko/    (OK)           \e[m"
            [ -f "/.choko/assets/sounds/intro.ogg" ] || cp /opt/capcom/assets/sounds/intro.ogg /.choko/assets/sounds/
            [ -f "/.choko/assets/sounds/movement.wav" ] || cp /opt/capcom/assets/sounds/movement.wav /.choko/assets/sounds/
            [ -f "/.choko/assets/sounds/trigger.wav" ] || cp /opt/capcom/assets/sounds/trigger.wav /.choko/assets/sounds/
            [ -f "/.choko/assets/options/blank.png" ] || cp /opt/capcom/assets/options/blank.png /.choko/assets/options/
            [ -f "/.choko/assets/options/clock_reg.png" ] || cp /opt/capcom/assets/options/clock_reg.png /.choko/assets/options/
            [ -f "/.choko/assets/options/coin_btn_over.png" ] || cp /opt/capcom/assets/options/coin_btn_over.png /.choko/assets/options/
            [ -f "/.choko/assets/options/coin_btn_reg.png" ] || cp /opt/capcom/assets/options/coin_btn_reg.png /.choko/assets/options/
            [ -f "/.choko/assets/options/CP1.png" ] || cp /opt/capcom/assets/options/CP1.png /.choko/assets/options/
            [ -f "/.choko/assets/options/CP2.png" ] || cp /opt/capcom/assets/options/CP2.png /.choko/assets/options/
            [ -f "/.choko/assets/options/difficulty_btn_over.png" ] || cp /opt/capcom/assets/options/difficulty_btn_over.png /.choko/assets/options/
            [ -f "/.choko/assets/options/difficulty_btn_reg.png" ] || cp /opt/capcom/assets/options/difficulty_btn_reg.png /.choko/assets/options/
            [ -f "/.choko/assets/options/difficulty_frame_over.png" ] || cp /opt/capcom/assets/options/difficulty_frame_over.png /.choko/assets/options/
            [ -f "/.choko/assets/options/difficulty_frame_reg.png" ] || cp /opt/capcom/assets/options/difficulty_frame_reg.png /.choko/assets/options/
            [ -f "/.choko/assets/options/options_btn_over.png" ] || cp /opt/capcom/assets/options/options_btn_over.png /.choko/assets/options/
            [ -f "/.choko/assets/options/options_btn_reg.png" ] || cp /opt/capcom/assets/options/options_btn_reg.png /.choko/assets/options/
            [ -f "/.choko/assets/options/options_frame_over.png" ] || cp /opt/capcom/assets/options/options_frame_over.png /.choko/assets/options/
            [ -f "/.choko/assets/options/options_frame_reg.png" ] || cp /opt/capcom/assets/options/options_frame_reg.png /.choko/assets/options/
            [ -f "/.choko/assets/options/options_over.png" ] || cp /opt/capcom/assets/options/options_over.png /.choko/assets/options/
            [ -f "/.choko/assets/options/options_reg.png" ] || cp /opt/capcom/assets/options/options_reg.png /.choko/assets/options/
            [ -f "/.choko/assets/options/play_btn_over.png" ] || cp /opt/capcom/assets/options/play_btn_over.png /.choko/assets/options/
            [ -f "/.choko/assets/options/play_btn_reg.png" ] || cp /opt/capcom/assets/options/play_btn_reg.png /.choko/assets/options/
            [ -f "/.choko/assets/options/slider.png" ] || cp /opt/capcom/assets/options/slider.png /.choko/assets/options/
            echo -e "\e[1;32m\"$LISTNAME\" was installed in the CHA.\e[m"
          else
            echo -e "\e[1;31mThere was some error.\e[m"; sleep 10; exit 201
          fi
        else
          echo "Skipping \"$LISTNAME\"."
        fi
      fi
    fi
  done
else
  echo "Did not found games to install."
fi

IFS="$OIFS"
FREESPACE=$(df -hP / | tail -1 | awk '{print $4}')
echo -e "\nThere is nothing else to do here.\nYou have $FREESPACE free in the CHA."
COUNTDOWN=5
while [ $COUNTDOWN -gt 0 ]
do
  echo -ne "\rRebooting in $COUNTDOWN seconds... "
  COUNTDOWN=$((COUNTDOWN - 1))
  sleep 1
done
echo -ne "\r\e[K"
exit 200

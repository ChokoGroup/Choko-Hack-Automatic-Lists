#!/bin/sh
# games1S.sh - Script to install games in CHA
# For Choko Hack 12.0.0+

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

# Look for games installed with older unsupported packs
if [ -d /.CAPCOM ] || [ -d /.SNK ] || [ -d /usr/share/roms/CPS1 ] || [ -d /usr/share/roms/CPS2 ] || [ -d /usr/share/roms/CPS3 ] || [ -d /usr/share/roms/NEO-GEO ] || [ -d /usr/share/roms/PRE-CPS ] || [ -d /usr/share/roms/PRE-NEOGEO ] || [ -f /usr/share/roms/sftm.zip ] || [ -d /usr/share/roms/cps1 ] || [ -d /usr/share/roms/cps2 ] || [ -d /usr/share/roms/cps3 ] || [ -d /usr/share/roms/itech32 ] || [ -d /usr/share/roms/megadriv ] || [ -d /usr/share/roms/neogeo ] || [ -d /usr/share/roms/precps ] || [ -d /usr/share/roms/preneogeo ]
then
  echo -en "\n\n\e[1;33mGames from older packs were found!\n\e[1;93mThey are no longer supported, you should delete them.\e[m\nSpace that can be recovered: "
  du -hc /.CAPCOM /.SNK /usr/share/roms/CPS1 /usr/share/roms/CPS2 /usr/share/roms/CPS3 /usr/share/roms/NEO-GEO /usr/share/roms/PRE-CPS /usr/share/roms/PRE-NEOGEO /usr/share/roms/sftm.zip /usr/share/roms/cps1 /usr/share/roms/cps2 /usr/share/roms/cps3 /usr/share/roms/itech32 /usr/share/roms/megadriv /usr/share/roms/neogeo /usr/share/roms/precps /usr/share/roms/preneogeo 2>/dev/null | tail -n 1
  echo -e "\n\e[m"
  sleep 5

  # Wait for buttons to be released before asking to delete
  while [ "$(readjoysticks j1 j2 -b)" != "0000000000000000" ]
  do
    sleep 1
  done
  COUNTDOWN=15
  STOPCOUNT="N"
  ANSWER="No"
  echo -ne "Do you want to \e[1;31mdelete\e[m them? \e[1;93m$ANSWER \n\e[1;30mUse joystick to change answer. Waiting $COUNTDOWN seconds...\e[m "

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
        echo -ne "\r\e[1ADo you want to \e[1;31mdelete\e[m them? \e[1;93m$ANSWER \n\e[m\e[K"
      ;;
      0|1|2|3|4|5|6|7)
        COUNTDOWN=0
      ;;
      *)
        if [ "$STOPCOUNT" = "N" ]
        then
          COUNTDOWN=$((COUNTDOWN - 1))
          echo -ne "\r\e[1ADo you want to \e[1;31mdelete\e[m them? \e[1;93m$ANSWER \n\e[1;30mUse joystick to change answer. Waiting $COUNTDOWN seconds...\e[m "
        fi
      ;;
    esac
  done
  echo -ne "\r\e[1ADo you want to \e[1;31mdelete\e[m them? \e[1;93m$ANSWER \n\e[m\e[K\r"
  if [ "$ANSWER" = "Yes" ]
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
    echo "Old games not deleted."
  fi
fi

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
        if [ $WASOK -eq 0 ] && [ $(find /usr/share/roms -name '*.zip' -mindepth 2 -type f -print 2> /dev/null | wc -l) -eq 0 ]
        then
          echo -e "\e[1;30mLast games uninstalled. Deleting all assets and patches remaining.\e[m"
          echo -e "\e[1;30mrm -rf \"/.choko/patches\"\e[m"; rm -rf "/.choko/patches"; WASOK=$?
          if [ $WASOK -eq 0 ]
          then
            echo -e "\e[1;30mrm -rf \"/.choko/assets\"\e[m"; rm -rf "/.choko/assets"; WASOK=$?
          fi
          if [ $WASOK -eq 0 ]
          then
            echo -e "\e[1;30mrm \"/.choko/usb_exec.sh\"\e[m"; rm "/.choko/usb_exec.sh"; WASOK=$?
          fi
        else
          if [ -d "/.choko/patches/${ROMSFOLDER##*/}" ] && [ $WASOK -eq 0 ]
          then
            echo -e "\e[1;30mrm -rf \"/.choko/patches/${ROMSFOLDER##*/}\"\e[m"; rm -rf "/.choko/patches/${ROMSFOLDER##*/}"; WASOK=$?
          fi
          if [ $WASOK -eq 0 ]
          then
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
            echo -e "\e[1;30mrm -rf \"/usr/share/roms/$LISTNAME\"\e[m"; rm -rf "/usr/share/roms/$LISTNAME"; WASOK=$?
            if [ $WASOK -eq 0 ] && [ $(find /usr/share/roms -name '*.zip' -mindepth 2 -type f -print 2> /dev/null | wc -l) -eq 0 ]
            then
              echo -e "\e[1;30mLast games uninstalled. Deleting all assets and patches remaining.\e[m"
              echo -e "\e[1;30mrm -rf \"/.choko/patches\"\e[m"; rm -rf "/.choko/patches"; WASOK=$?
              if [ $WASOK -eq 0 ]
              then
                echo -e "\e[1;30mrm -rf \"/.choko/assets\"\e[m"; rm -rf "/.choko/assets"; WASOK=$?
              fi
              if [ $WASOK -eq 0 ]
              then
                echo -e "\e[1;30mrm \"/.choko/usb_exec.sh\"\e[m"; rm "/.choko/usb_exec.sh"; WASOK=$?
              fi
            else
              if [ -d "/.choko/patches/$LISTNAME" ] && [ $WASOK -eq 0 ]
              then
                echo -e "\e[1;30mrm -rf \"/.choko/patches/$LISTNAME\"\e[m"; rm -rf "/.choko/patches/$LISTNAME"; WASOK=$?
              fi
              if [ $WASOK -eq 0 ]
              then
                echo -e "\e[1;30mDeleting unneeded assets...";
                while read -r LINE || [ -n "$LINE" ]; do
                  OGGFILE=${LINE%'.ogg'*}; OGGFILE=${OGGFILE##*' '}
                  PNGFILE=${LINE%'.png'*}; PNGFILE=${PNGFILE##*' '}
                  ZIPFILE=${LINE%'.zip'*}; ZIPFILE=${ZIPFILE##*' '}
                  find "/.choko/assets" -type f \( -name "$OGGFILE.*" -or -name "$PNGFILE.*" -or -name "$ZIPFILE.*" \) -exec rm {} +
                  WASOK=$?
                  [ $WASOK -eq 0 ] || break
                done < "/.choko/$LISTNAME.txt"
              fi
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;30mrm -f \"/.choko/$LISTNAME.\"*\e[m"; rm -f "/.choko/$LISTNAME."*; WASOK=$?
            fi
            if [ $WASOK -eq 0 ]
            then
              echo -e "\e[1;32mOlder \"$LISTNAME\" was uninstalled from CHA.\e[m"
            else
              echo -e "\e[1;31mThere was some error.\e[m"; sleep 10; exit 201
            fi
          fi
          echo "Installing \"$LISTNAME\"..."
          mkdir -p /.choko/assets
          mkdir -p /.choko/patches
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
            fi
          fi
          if [ $WASOK -eq 0 ]
          then
            if [ ! -f "$RUNNINGFROM/$LISTNAME.txt" ]
            then
              echo -e "\e[1;30mBuilding \"$LISTNAME.txt\"...\e[m"
              FIRSTLINE="Y"
              ICONNUMBER=0
              # Go to folder to avoid problems with apostrophes in folders names
              cd "$ROMSFOLDER"
              for FNAME in $(find . -mindepth 1 -maxdepth 2 -name '*.zip' -type f -print 2> /dev/null | sort -f)
              do
                FNAME="${FNAME#./}"; FNAME="${FNAME%.zip}"
                if [ "$FNAME" != "neogeo" ] && [ "$FNAME" != "neocdz" ] && [ "$FNAME" != "decocass" ] && [ "$FNAME" != "isgsm" ] && [ "$FNAME" != "midssio" ] && [ "$FNAME" != "nmk004" ] && [ "$FNAME" != "pgm" ] && [ "$FNAME" != "skns" ] && [ "$FNAME" != "ym2608" ] && [ "$FNAME" != "cchip" ] && [ "$FNAME" != "bubsys" ] && [ "$FNAME" != "namcoc69" ] && [ "$FNAME" != "namcoc70" ] && [ "$FNAME" != "namcoc75" ] && [ "$FNAME" != "coleco" ] && [ "$FNAME" != "fdsbios" ] && [ "$FNAME" != "msx" ] && [ "$FNAME" != "ngp" ] && [ "$FNAME" != "spectrum" ] && [ "$FNAME" != "spec128" ] && [ "$FNAME" != "channelf" ]
                then
                  FPARENT="$FNAME"
                  GAMESTXTLINE="$(grep -m 1 " $FPARENT.zip" "$RUNNINGFROM/games_all.txt")"
                  # Search for parent rom in games_all.txt
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
                    if [ "$FNAME" != "$FPARENT" ]
                    then
                      eval "GAMESTXTLINE=\"\${GAMESTXTLINE// $FPARENT.zip/ $FNAME.zip}\""
                    fi
                    echo -n "$GAMESTXTLINE" >> "$RUNNINGFROM/$LISTNAME.txt"
                  else
                    # Search for parent rom assets
                    FPARENT="$FNAME"
                    while [ ! -f "$RUNNINGFROM/assets/games/$FPARENT.png" ] && [ ${#FPARENT} -gt 1 ]
                    do
                      FPARENT="${FPARENT%?}"
                    done
                    if [ -f "$RUNNINGFROM/assets/games/$FPARENT.png" ]
                    then
                      echo -n "A 0 B 0000 $FPARENT.png $FNAME.zip $FPARENT.ogg $FPARENT" >> "$RUNNINGFROM/$LISTNAME.txt"
                    else
                      ICONNUMBER=$((ICONNUMBER + 1))
                      if [ ${#ICONNUMBER} -eq 1 ]
                      then
                        echo -n "A 0 B 0000 game0$ICONNUMBER.png $FNAME.zip $FNAME.ogg $FNAME" >> "$RUNNINGFROM/$LISTNAME.txt"
                      else
                        echo -n "A 0 B 0000 game$ICONNUMBER.png $FNAME.zip $FNAME.ogg $FNAME" >> "$RUNNINGFROM/$LISTNAME.txt"
                      fi
                    fi
                  fi
                fi
              done
              cd "$RUNNINGFROM"
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
            echo -ne "\e[1;30mcp -u \"$RUNNINGFROM/usb_exec.sh\" /.choko/   \e[m\e[5m Please wait... \e[m"; cp -u "$RUNNINGFROM/usb_exec.sh" /.choko/; WASOK=$?
          fi
          if [ $WASOK -eq 0 ]
          then
            echo -e "\r\e[1;30mcp -u \"$RUNNINGFROM/usb_exec.sh\" /.choko/    (OK)           \e[m"
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

#!/bin/sh
# games1S.sh - Script to install games in CHA
# v13.0.0

# Simple string compare, since until 10.0.0 CHOKOVERSION wasn't set
# Future versions need to keep this in mind
if [ -z "$CHOKOVERSION" ] || [ "$CHOKOVERSION" \< "13.0.0" ]
then
  echo -e "\nYou are running an outdated version of Choko Hack.\nYou need v13.0.0 or later.\n"
  _var_countdown=5
  while [ $_var_countdown -ge 0 ]
  do
    echo -ne "\rRebooting in $_var_countdown seconds... "
    _var_countdown=$((_var_countdown - 1))
    sleep 1
  done
  echo -e "\r                                   "
  if [ -z "$CHOKOVERSION" ] || [ "$CHOKOVERSION" \< "10.0.0" ]
  then
    reboot -f
  else
    exit 200
  fi
fi

_var_running_from_folder="$(dirname "$(readlink -f "$0")")"
echo -e "\n"
if [ -z "$_var_running_after_update" ]
then
  # Wait for buttons to be released
  while [ "$(readjoysticks j1 j2 -b)" != "0000000000000000" ]
  do
    sleep 1
  done
  _var_countdown=10
  _var_stop_countdown="N"
  _var_user_answer="No"
  while [ $_var_countdown -gt 0 ]
  do
    case "$(readjoysticks j1)" in
      U|D|L|R)
        [ "$_var_user_answer" = "No" ] && _var_user_answer="Yes" || _var_user_answer="No"
        [ "$_var_stop_countdown" = "N" ] && _var_stop_countdown="Y"
        echo -ne "\r\e[1ADo you want search for updates now? \e[1;93m$_var_user_answer \n\e[m\e[K"
      ;;
      0|1|2|3|4|5|6|7)
        _var_countdown=0
      ;;
      *)
        if [ "$_var_stop_countdown" = "N" ]
        then
          _var_countdown=$((_var_countdown - 1))
          echo -ne "\r\e[1ADo you want search for updates now? \e[1;93m$_var_user_answer \n\e[1;30mUse joystick to change answer. Waiting $_var_countdown seconds...\e[m "
        fi
      ;;
    esac
  done
  echo -ne "\r\e[1ADo you want search for updates now? \e[1;93m$_var_user_answer \n\e[m\e[K"
  if [ "$_var_user_answer" = "Yes" ]
  then
    echo -e "\nConnecting Wi-Fi..."
    /etc/init.d/S40network restart > /dev/null 2>&1
    _var_release_version="$(/.choko/busybox wget -q -o /dev/null -O - 'https://github.com/ChokoGroup/Choko-Hack-Automatic-Lists/releases/latest' | grep -m 1 'Choko Hack Automatic Listst v')"
    _var_release_version="${_var_release_version#*Choko Hack Automatic Listst v}"; _var_release_version="${_var_release_version:0:6}"
    _var_current_release_version="$(grep -m 1 'new in v' "${_var_running_from_folder}/_readme_.txt")"
    _var_current_release_version="${_var_current_release_version#*new in v}"; _var_current_release_version="${_var_current_release_version:0:6}"
    if [ -z "$_var_release_version" ]
    then
      echo "Could not get latest build version!"
    elif [ -n "$_var_current_release_version" ] && [ "$_var_release_version" \< "$_var_current_release_version" ]
    then
      echo -e "You are running version $_var_current_release_version but the latest version is ${_var_release_version}!?"
    else
      [ -n "$_var_current_release_version" ] && echo "Current version is $_var_current_release_version"
      echo -e "Latest version is $_var_release_version\n"
      # Wait for buttons to be released
      while [ "$(readjoysticks j1 j2 -b)" != "0000000000000000" ]
      do
        sleep 1
      done
      _var_countdown=10
      _var_stop_countdown="N"
      _var_user_answer="No"
      while [ $_var_countdown -gt 0 ]
      do
        case "$(readjoysticks j1)" in
          U|D|L|R)
            [ "$_var_user_answer" = "No" ] && _var_user_answer="Yes" || _var_user_answer="No"
            [ "$_var_stop_countdown" = "N" ] && _var_stop_countdown="Y"
            echo -ne "\r\e[1ADo you want to update Choko Hack Automatic Lists? \e[1;93m$_var_user_answer \n\e[m\e[K"
          ;;
          0|1|2|3|4|5|6|7)
            _var_countdown=0
          ;;
          *)
            if [ "$_var_stop_countdown" = "N" ]
            then
              _var_countdown=$((_var_countdown - 1))
              echo -ne "\r\e[1ADo you want to update Choko Hack Automatic Lists? \e[1;93m$_var_user_answer \n\e[1;30mUse joystick to change answer. Waiting $_var_countdown seconds...\e[m "
            fi
          ;;
        esac
      done
      echo -ne "\r\e[1ADo you want to update Choko Hack Automatic Lists? \e[1;93m$_var_user_answer \n\e[m\e[K"
      if [ "$_var_user_answer" = "Yes" ]
      then
        echo "Downloading update..."
        if /.choko/busybox wget -q -o /dev/null -O "/tmp/CHA.Choko.Games.Lists.${_var_release_version}.Update.zip" "https://github.com/ChokoGroup/Choko-Hack-Automatic-Lists/releases/download/latest/CHA.Choko.Games.Lists.${_var_release_version}.Update.zip"
        then
          echo -en "Extracting files..."
          if unzip -qo "/tmp/CHA.Choko.Games.Lists.${_var_release_version}.Update.zip" -d /tmp
          then
            echo -e " OK"
            mv "/tmp/CHA Choko Games Lists"/* "$_var_running_from_folder"/
            rm -rf /tmp/CHA*
            # Call this script again to do "after update" work...
            _var_running_after_update="yes" exec "$(readlink -f "$0")" "$@"
          else
            echo -e "\n\e[1;31mError extracting CHA.Choko.Games.Lists.${_var_release_version}.Update.zip!\e[m"
            rm -rf /tmp/CHA*
          fi
        else
          echo -e "\e[1;31mError downloading CHA.Choko.Games.Lists.${_var_release_version}.Update.zip!\e[m"
          rm -rf /tmp/CHA*
        fi
      fi
    fi
  fi
else
  # Put here "after update" jobs needed
  echo -e "\e[0;32m\"${_var_running_from_folder##*/}\" is now up-to-date!\e[m"
fi

# Make 'for' loops use entire lines
OIFS="$IFS"
IFS=$'\n'

# Look for installed games
echo -e "\n\nLooking for installed games..."
if [ $(find /usr/share/roms -iname '*.zip' -mindepth 2 -type f -print 2> /dev/null | wc -l) -gt 0 ]
then
  for _var_folder_with_ROMs in $(find /usr/share/roms -iname '*' -mindepth 1 -maxdepth 1 -type d -print 2> /dev/null | sort -f)
  do
    if [ $(find "$_var_folder_with_ROMs" -iname '*.zip' -type f -print 2> /dev/null | wc -l) -gt 0 ]
    then
      case "$_var_folder_with_ROMs" in 
        # 'games??' logic from Choko Hack v11
        *games[12][A-F])
          _var_name_of_list="$(head -n 1 "/.choko/${_var_folder_with_ROMs##*/}.nfo")"
        ;;
        *)
          # ROMS_FOLDER_NAME logic from Choko Hack v12
          _var_name_of_list="${_var_folder_with_ROMs##*/}"
        ;; 
      esac
      
      # Wait for buttons to be released
      while [ "$(readjoysticks j1 j2 -b)" != "0000000000000000" ]
      do
        sleep 1
      done
      _var_countdown=15
      _var_stop_contdown="N"
      _var_user_answer="No"
      echo -ne "\nDo you want to \e[1;31muninstall\e[m \"$_var_name_of_list\"? \e[1;93m$_var_user_answer \n\e[1;30mUse joystick to change answer. Waiting $_var_countdown seconds...\e[m "

      # Read joystick
      while [ $_var_countdown -gt 0 ]
      do
        case "$(readjoysticks j1)" in
          U|D|L|R)
            if [ "$_var_user_answer" = "No" ]
            then
              _var_user_answer="Yes"
            else
              _var_user_answer="No"
            fi
            if [ "$_var_stop_contdown" = "N" ]
            then
              _var_stop_contdown="Y"
            fi
            echo -ne "\r\e[1ADo you want to \e[1;31muninstall\e[m \"$_var_name_of_list\"? \e[1;93m$_var_user_answer \n\e[m\e[K"
          ;;
          0|1|2|3|4|5|6|7)
            _var_countdown=0
          ;;
          *)
            if [ "$_var_stop_contdown" = "N" ]
            then
              _var_countdown=$((_var_countdown - 1))
              echo -ne "\r\e[1ADo you want to \e[1;31muninstall\e[m \"$_var_name_of_list\"? \e[1;93m$_var_user_answer \n\e[1;30mUse joystick to change answer. Waiting $_var_countdown seconds...\e[m "
            fi
          ;;
        esac
      done
      echo -ne "\r\e[1ADo you want to \e[1;31muninstall\e[m \"$_var_name_of_list\"? \e[1;93m$_var_user_answer \n\e[m\e[K"
      if [ "$_var_user_answer" = "Yes" ]
      then
        echo "Uninstalling \"$_var_name_of_list\"..."
        echo -e "\e[1;30mrm -rf \"$_var_folder_with_ROMs\"\e[m"; rm -rf "$_var_folder_with_ROMs"; _var_last_command_exitcode=$?
        if [ -d "/.choko/patches/${_var_folder_with_ROMs##*/}" ] && [ $_var_last_command_exitcode -eq 0 ]
        then
          echo -e "\e[1;30mrm -rf \"/.choko/patches/${_var_folder_with_ROMs##*/}\"\e[m"; rm -rf "/.choko/patches/${_var_folder_with_ROMs##*/}"; _var_last_command_exitcode=$?
        fi
        if [ $_var_last_command_exitcode -eq 0 ]
        then
          if [ $(find /usr/share/roms -iname '*.zip' -mindepth 2 -type f -print 2> /dev/null | wc -l) -eq 0 ]
          then
            echo -e "\e[1;30mLast games uninstalled. Deleting all assets and patches left behind.\e[m"
            if [ -d /.choko/patches ]
            then
              echo -e "\e[1;30mrm -rf \"/.choko/patches\"\e[m"; rm -rf /.choko/patches; _var_last_command_exitcode=$?
            fi
            if [ $_var_last_command_exitcode -eq 0 ] && [ -d /.choko/assets ]
            then
              echo -e "\e[1;30mrm -rf \"/.choko/assets\"\e[m"; rm -rf /.choko/assets; _var_last_command_exitcode=$?
            fi
            if [ $_var_last_command_exitcode -eq 0 ] && [ -f /.choko/usb_exec.sh ]
            then
              echo -e "\e[1;30mrm \"/.choko/usb_exec.sh\"\e[m"; rm /.choko/usb_exec.sh; _var_last_command_exitcode=$?
            fi
          else
            echo -e "\e[1;30mDeleting unneeded assets...\e[m"
            while read -r _var_line_from_games_txt || [ -n "$_var_line_from_games_txt" ]; do
              _var_ogg_file_name=${_var_line_from_games_txt%'.ogg'*}; _var_ogg_file_name=${_var_ogg_file_name##*' '}
              _var_png_file_name=${_var_line_from_games_txt%'.png'*}; _var_png_file_name=${_var_png_file_name##*' '}
              _var_zip_file_name=${_var_line_from_games_txt%'.zip'*}; _var_zip_file_name=${_var_zip_file_name##*' '}
              find "/.choko/assets" -type f \( -iname "${_var_ogg_file_name}.*" -or -iname "${_var_png_file_name}.*" -or -iname "${_var_zip_file_name}.*" \) -exec rm {} +
              _var_last_command_exitcode=$?
              [ $_var_last_command_exitcode -eq 0 ] || break
            done < "/.choko/${_var_folder_with_ROMs##*/}.txt"
          fi
        fi
        if [ $_var_last_command_exitcode -eq 0 ]
        then
          echo -e "\e[1;30mrm -f \"/.choko/${_var_folder_with_ROMs##*/}.\"*\e[m"; rm -f "/.choko/${_var_folder_with_ROMs##*/}."*; _var_last_command_exitcode=$?
        fi
        if [ $_var_last_command_exitcode -eq 0 ]
        then
          echo -e "\e[1;32m\"$_var_name_of_list\" was uninstalled.\e[m"
        else
          echo -e "\e[1;31mThere was some error.\e[m"; sleep 10; exit 201
        fi
      else
        echo "\"$_var_name_of_list\" was NOT uninstalled."
      fi
    fi
  done
else
  echo "Did not found installed games."
fi


# Look for games to install
echo -e "\n\nLooking for games to install..."
if [ $(find "${_var_running_from_folder}/roms" -iname '*.zip' -mindepth 2 -type f -print 2> /dev/null | wc -l) -gt 0 ]
then
  for _var_folder_with_ROMs in $(find "${_var_running_from_folder}/roms" -iname '*' -mindepth 1 -maxdepth 1 -type d -print 2> /dev/null | sort -f)
  do
    if [ $(find "$_var_folder_with_ROMs" -iname '*.zip' -type f -print 2> /dev/null | wc -l) -gt 0 ]
    then
      _var_name_of_list="${_var_folder_with_ROMs##*/}"
      _var_free_space=$(df -P / | tail -1 | awk '{print $4}')
      # The size of fba_libretro.so is added twice to give some extra space for assets
      _var_use_space_on_USB=$(du -c "$_var_folder_with_ROMs" "${_var_running_from_folder}/patches/$_var_name_of_list" "${_var_running_from_folder}/patches/fba_libretro.so" "${_var_running_from_folder}/patches/fba_libretro.so" 2>/dev/null | tail -n 1 | awk '{print $1;}')

      if [ -d "/usr/share/roms/$_var_name_of_list" ]
      then
        _var_use_space_on_CHA=$(du -c "/usr/share/roms/$_var_name_of_list" "/.choko/patches/$_var_name_of_list" 2>/dev/null | tail -n 1 | awk '{print $1;}')
        _var_free_space=$((_var_free_space + _var_use_space_on_CHA))
      fi
      if [ $((_var_use_space_on_USB)) -gt $((_var_free_space)) ]
      then
        echo -e "\nNot enought space to install \"$_var_name_of_list\"."
      else

        # Wait for buttons to be released
        while [ "$(readjoysticks j1 j2 -b)" != "0000000000000000" ]
        do
          sleep 1
        done
        _var_countdown=15
        _var_stop_contdown="N"
        _var_user_answer="No"
        if [ -d "/usr/share/roms/$_var_name_of_list" ]
        then
          echo -ne "\n\e[1;93mA list named \"$_var_name_of_list\" is already installed in CHA and will be replaced if you choose YES!\e[m"
        fi
        echo -ne "\nDo you want to install \"$_var_name_of_list\"? \e[1;93m$_var_user_answer \n\e[1;30mUse joystick to change answer. Waiting $_var_countdown seconds...\e[m "

        # Read joystick
        while [ $_var_countdown -gt 0 ]
        do
          case "$(readjoysticks j1)" in
            U|D|L|R)
              if [ "$_var_user_answer" = "No" ]
              then
                _var_user_answer="Yes"
              else
                _var_user_answer="No"
              fi
              if [ "$_var_stop_contdown" = "N" ]
              then
                _var_stop_contdown="Y"
              fi
              echo -ne "\r\e[1ADo you want to install \"$_var_name_of_list\"? \e[1;93m$_var_user_answer \n\e[m\e[K"
            ;;
            0|1|2|3|4|5|6|7)
              _var_countdown=0
            ;;
            *)
              if [ "$_var_stop_contdown" = "N" ]
              then
                _var_countdown=$((_var_countdown - 1))
                echo -ne "\r\e[1ADo you want to install \"$_var_name_of_list\"? \e[1;93m$_var_user_answer \n\e[1;30mUse joystick to change answer. Waiting $_var_countdown seconds...\e[m "
              fi
            ;;
          esac
        done
        echo -ne "\r\e[1ADo you want to install \"$_var_name_of_list\"? \e[1;93m$_var_user_answer \n\e[m\e[K"
        if [ "$_var_user_answer" = "Yes" ]
        then
          _var_last_command_exitcode=0
          if [ -d "/usr/share/roms/$_var_name_of_list" ]
          then
            echo "Uninstalling old \"$_var_name_of_list\" from the CHA..."
            if [ -d "/usr/share/roms/$_var_name_of_list" ]
            then
              echo -e "\e[1;30mrm -rf \"/usr/share/roms/$_var_name_of_list\"\e[m"; rm -rf "/usr/share/roms/$_var_name_of_list"; _var_last_command_exitcode=$?
            fi
            if [ $_var_last_command_exitcode -eq 0 ]
            then
              if [ $(find /usr/share/roms -iname '*.zip' -mindepth 2 -type f -print 2> /dev/null | wc -l) -eq 0 ]
              then
                echo -e "\e[1;30mLast games uninstalled. Deleting all assets and patches left behind.\e[m"
                if [ -d /.choko/patches ]
                then
                  echo -e "\e[1;30mrm -rf \"/.choko/patches\"\e[m"; rm -rf /.choko/patches; _var_last_command_exitcode=$?
                fi
                if [ $_var_last_command_exitcode -eq 0 ] && [ -d /.choko/assets ]
                then
                  echo -e "\e[1;30mrm -rf \"/.choko/assets\"\e[m"; rm -rf /.choko/assets; _var_last_command_exitcode=$?
                fi
                if [ $_var_last_command_exitcode -eq 0 ] && [ -d /.choko/options ]
                then
                  echo -e "\e[1;30mrm -rf \"/.choko/options\"\e[m"; rm -rf /.choko/options; _var_last_command_exitcode=$?
                fi
                if [ $_var_last_command_exitcode -eq 0 ] && [ -f /.choko/usb_exec.sh ]
                then
                  echo -e "\e[1;30mrm \"/.choko/usb_exec.sh\"\e[m"; rm /.choko/usb_exec.sh; _var_last_command_exitcode=$?
                fi
              else
                echo -e "\e[1;30mDeleting unneeded assets...\e[m"
                while read -r _var_line_from_games_txt || [ -n "$_var_line_from_games_txt" ]; do
                  _var_ogg_file_name=${_var_line_from_games_txt%'.ogg'*}; _var_ogg_file_name=${_var_ogg_file_name##*' '}
                  _var_png_file_name=${_var_line_from_games_txt%'.png'*}; _var_png_file_name=${_var_png_file_name##*' '}
                  _var_zip_file_name=${_var_line_from_games_txt%'.zip'*}; _var_zip_file_name=${_var_zip_file_name##*' '}
                  find "/.choko/assets" -type f \( -iname "${_var_ogg_file_name}.*" -or -iname "${_var_png_file_name}.*" -or -iname "${_var_zip_file_name}.*" \) -exec rm {} +
                  _var_last_command_exitcode=$?
                  [ $_var_last_command_exitcode -eq 0 ] || break
                done < "/.choko/${_var_folder_with_ROMs##*/}.txt"
              fi
            fi
            if [ $_var_last_command_exitcode -eq 0 ]
            then
              echo -e "\e[1;30mrm -f \"/.choko/${_var_name_of_list}.\"*\e[m"; rm -f "/.choko/${_var_name_of_list}."*; _var_last_command_exitcode=$?
            fi
            if [ $_var_last_command_exitcode -eq 0 ]
            then
              echo -e "\e[1;32mOld \"$_var_name_of_list\" was uninstalled from CHA.\e[m"
            else
              echo -e "\e[1;31mThere was some error.\e[m"; sleep 10; exit 201
            fi
          fi
          echo "Installing \"$_var_name_of_list\"..."
          mkdir -p /.choko/assets
          mkdir -p /.choko/patches
          mkdir -p /.choko/options
          [ -f /.choko/assets/capcom-home-arcade-last.png ] || cp "${_var_running_from_folder}/assets/capcom-home-arcade-last.png" /.choko/assets/
          echo -ne "\e[1;30mcp -r \"$_var_folder_with_ROMs\" /usr/share/roms/   \e[m\e[5m Please wait... \e[m"; cp -r "$_var_folder_with_ROMs" /usr/share/roms/; _var_last_command_exitcode=$?
          if [ $_var_last_command_exitcode -eq 0 ]
          then
            echo -e "\r\e[1;30mcp -r \"$_var_folder_with_ROMs\" /usr/share/roms/    (OK)           \e[m"
            if [ -d "${_var_running_from_folder}/patches/$_var_name_of_list" ]
            then
              echo -ne "\e[1;30mcp -r \"${_var_running_from_folder}/patches/$_var_name_of_list\" /.choko/patches/   \e[m\e[5m Please wait... \e[m"; cp -r "${_var_running_from_folder}/patches/$_var_name_of_list" /.choko/patches/; _var_last_command_exitcode=$?
              if [ $_var_last_command_exitcode -eq 0 ]
              then
                echo -e "\r\e[1;30mcp -r \"${_var_running_from_folder}/patches/$_var_name_of_list\" /.choko/patches/    (OK)           \e[m"
              fi
            else
              if [ -d "${_var_running_from_folder}/patches/default" ]
              then
                echo -ne "\e[1;30mcp -r \"${_var_running_from_folder}/patches/default\" /.choko/patches/   \e[m\e[5m Please wait... \e[m"; cp -r "${_var_running_from_folder}/patches/default" /.choko/patches/; _var_last_command_exitcode=$?
                if [ $_var_last_command_exitcode -eq 0 ]
                then
                  echo -e "\r\e[1;30mcp -r \"${_var_running_from_folder}/patches/default\" /.choko/patches/    (OK)           \e[m"
                fi
              fi
            fi
          fi
          if [ $_var_last_command_exitcode -eq 0 ]
          then
            _var_Core_File="$(ls "/.choko/patches/$_var_name_of_list"/*.core.conf)"
            _var_Core_File="${_var_Core_File##*/}"; _var_Core_File="${_var_Core_File%.core.conf}"
            if [ -z "$_var_Core_File" ] || [ ! -f "${_var_running_from_folder}/patches/$_var_Core_File" ]
            then
              _var_Core_File="$(ls "$_var_running_from_folder"/patches/default/*.core.conf)"
              _var_Core_File="${_var_Core_File##*/}"; _var_Core_File="${_var_Core_File%.core.conf}"
            fi
            if [ -n "$_var_Core_File" ] && [ -f "${_var_running_from_folder}/patches/$_var_Core_File" ]
            then
              echo -ne "\e[1;30mcp \"${_var_running_from_folder}/patches/$_var_Core_File\" /.choko/patches/   \e[m\e[5m Please wait... \e[m"; cp "${_var_running_from_folder}/patches/$_var_Core_File" /.choko/patches/; _var_last_command_exitcode=$?
              [ $_var_last_command_exitcode -eq 0 ] && echo -e "\r\e[1;30mcp \"${_var_running_from_folder}/patches/$_var_Core_File\" /.choko/patches/    (OK)           \e[m"
            elif [ ! -f /.choko/patches/fba_libretro.so ]
            then
              echo -ne "\e[1;30mcp \"${_var_running_from_folder}/patches/fba_libretro.so\" /.choko/patches/   \e[m\e[5m Please wait... \e[m"; cp "${_var_running_from_folder}/patches/fba_libretro.so" /.choko/patches/; _var_last_command_exitcode=$?
              [ $_var_last_command_exitcode -eq 0 ] && echo -e "\r\e[1;30mcp \"${_var_running_from_folder}/patches/fba_libretro.so\" /.choko/patches/    (OK)           \e[m"
            fi
          fi
          if [ $_var_last_command_exitcode -eq 0 ]
          then
            if [ ! -f "${_var_running_from_folder}/${_var_name_of_list}.txt" ]
            then
              echo -n "Creating \"${_var_name_of_list}.txt\""
              _var_is_first_line="Y"
              _var_icon_number=0
              # Go to folder to avoid problems with apostrophes in folders names
              cd "$_var_folder_with_ROMs"
              for _var_file_name in $(find . -mindepth 1 -maxdepth 2 -iname '*.zip' -type f -print 2> /dev/null | sort -f)
              do
                _var_file_name="${_var_file_name#./}"; _var_file_name="${_var_file_name%.zip}"
                # Ignore BIOS only zip files
                if [ "$_var_file_name" != "neogeo" ] && [ "$_var_file_name" != "neocdz" ] && [ "$_var_file_name" != "decocass" ] && [ "$_var_file_name" != "isgsm" ] && [ "$_var_file_name" != "midssio" ] && [ "$_var_file_name" != "nmk004" ] && [ "$_var_file_name" != "pgm" ] && [ "$_var_file_name" != "skns" ] && [ "$_var_file_name" != "ym2608" ] && [ "$_var_file_name" != "cchip" ] && [ "$_var_file_name" != "bubsys" ] && [ "$_var_file_name" != "namcoc69" ] && [ "$_var_file_name" != "namcoc70" ] && [ "$_var_file_name" != "namcoc75" ] && [ "$_var_file_name" != "coleco" ] && [ "$_var_file_name" != "fdsbios" ] && [ "$_var_file_name" != "msx" ] && [ "$_var_file_name" != "ngp" ] && [ "$_var_file_name" != "spectrum" ] && [ "$_var_file_name" != "spec128" ] && [ "$_var_file_name" != "channelf" ]
                then
                  _var_parent_file_name="$_var_file_name"
                  _var_line_for_games_txt="$(grep -m 1 " ${_var_parent_file_name}.zip" "${_var_running_from_folder}/games_all.txt")"
                  # Search for parent rom in games_all.txt if exact zip not found n games_all.txt
                  while [ -z "$_var_line_for_games_txt" ] && [ ${#_var_parent_file_name} -gt 1 ]
                  do
                    _var_parent_file_name="${_var_parent_file_name%?}"
                    _var_line_for_games_txt="$(grep -m 1 " ${_var_parent_file_name}.zip" "${_var_running_from_folder}/games_all.txt")"
                  done

                  if [ "$_var_is_first_line" = "N" ]
                  then
                    echo -en "\n" >> "${_var_running_from_folder}/${_var_name_of_list}.txt"
                  else
                    _var_is_first_line="N"
                  fi
                  if [ -n "$_var_line_for_games_txt" ]
                  then
                    # Line found in games_all.txt
                    if [ "$_var_file_name" != "$_var_parent_file_name" ]
                    then
                      _var_temp_file_name="${_var_file_name//\//\\\/}"
                      _var_temp_parent_file_name="${_var_parent_file_name//\//\\\/}"
                      eval "_var_line_for_games_txt=\"\${_var_line_for_games_txt/ ${_var_temp_parent_file_name}.zip/ ${_var_temp_file_name}.zip}\""
                    fi
                    # Check if png exists and look for parent png if not
                    _var_asset_file_name="${_var_line_for_games_txt:11}"; _var_asset_file_name="${_var_asset_file_name%%' '*}"
                    if [ ! -f "${_var_running_from_folder}/assets/games/$_var_asset_file_name" ]
                    then
                      _var_temp_asset_file_name="${_var_asset_file_name//\//\\\/}"
                      _var_parent_file_name="$_var_file_name"
                      while [ ! -f "${_var_running_from_folder}/assets/games/${_var_parent_file_name}.png" ] && [ ${#_var_parent_file_name} -gt 1 ]
                      do
                        _var_parent_file_name="${_var_parent_file_name%?}"
                      done
                      if [ -f "${_var_running_from_folder}/assets/games/${_var_parent_file_name}.png" ]
                      then
                        _var_temp_parent_file_name="${_var_parent_file_name//\//\\\/}"
                        eval "_var_line_for_games_txt=\"\${_var_line_for_games_txt/ $_var_temp_asset_file_name/ ${_var_temp_parent_file_name}.png}\""
                      else
                        _var_icon_number=$((_var_icon_number + 1))
                        if [ ${#_var_icon_number} -eq 1 ]
                        then
                          eval "_var_line_for_games_txt=\"\${_var_line_for_games_txt/ $_var_temp_asset_file_name/ game0${_var_icon_number}.png}\""
                        else
                          eval "_var_line_for_games_txt=\"\${_var_line_for_games_txt/ $_var_temp_asset_file_name/ game${_var_icon_number}.png}\""
                        fi
                      fi
                    fi
                    # Check if ogg exists and look for parent ogg if not
                    _var_asset_file_name="${_var_line_for_games_txt#*'.zip '}"; _var_asset_file_name="${_var_asset_file_name%%' '*}"
                    if [ ! -f "${_var_running_from_folder}/assets/sounds/$_var_asset_file_name" ] && [ ! -f "${_var_running_from_folder}/assets/sounds/music/set2/$_var_asset_file_name" ]
                    then
                      _var_parent_file_name="$_var_file_name"
                      while [ ! -f "${_var_running_from_folder}/assets/sounds/${_var_parent_file_name}.ogg" ] && [ ! -f "${_var_running_from_folder}/assets/sounds/music/set2/${_var_parent_file_name}.ogg" ] && [ ${#_var_parent_file_name} -gt 1 ]
                      do
                        _var_parent_file_name="${_var_parent_file_name%?}"
                      done
                      if [ -f "${_var_running_from_folder}/assets/sounds/${_var_parent_file_name}.ogg" ] || [ -f "${_var_running_from_folder}/assets/sounds/music/set2/${_var_parent_file_name}.ogg" ]
                      then
                        _var_temp_asset_file_name="${_var_asset_file_name//\//\\\/}"
                        _var_temp_parent_file_name="${_var_parent_file_name//\//\\\/}"
                        eval "_var_line_for_games_txt=\"\${_var_line_for_games_txt/ $_var_temp_asset_file_name/ ${_var_temp_parent_file_name}.ogg}\""
                      fi
                    fi
                    echo -n "$_var_line_for_games_txt" >> "${_var_running_from_folder}/${_var_name_of_list}.txt"
                  else
                    # Line not found in games_all.txt
                    # Search for rom assets or parent rom assets
                    _var_parent_file_name="$_var_file_name"
                    while [ ! -f "${_var_running_from_folder}/assets/games/${_var_parent_file_name}.png" ] && [ ${#_var_parent_file_name} -gt 1 ]
                    do
                      _var_parent_file_name="${_var_parent_file_name%?}"
                    done
                    if [ -f "${_var_running_from_folder}/assets/games/${_var_parent_file_name}.png" ]
                    then
                      echo -n "A 0 B 0000 ${_var_parent_file_name}.png ${_var_file_name}.zip ${_var_parent_file_name}.ogg 0 $_var_parent_file_name" >> "${_var_running_from_folder}/${_var_name_of_list}.txt"
                    else
                      _var_icon_number=$((_var_icon_number + 1))
                      if [ ${#_var_icon_number} -eq 1 ]
                      then
                        echo -n "A 0 B 0000 game0${_var_icon_number}.png ${_var_file_name}.zip ${_var_file_name}.ogg 0 $_var_file_name" >> "${_var_running_from_folder}/${_var_name_of_list}.txt"
                      else
                        echo -n "A 0 B 0000 game${_var_icon_number}.png ${_var_file_name}.zip ${_var_file_name}.ogg 0 $_var_file_name" >> "${_var_running_from_folder}/${_var_name_of_list}.txt"
                      fi
                    fi
                  fi
                  echo -n "."
                fi
              done
              cd "$_var_running_from_folder"
              echo -e "\n"
            fi
            echo -ne "\e[1;30mCopying assets from \"${_var_running_from_folder}/assets\" into CHA...   \e[m\e[5m Please wait... \e[m"
            while read -r _var_line_from_games_txt || [ -n "$_var_line_from_games_txt" ]; do
              _var_png_file_name=${_var_line_from_games_txt%'.png'*}; _var_png_file_name=${_var_png_file_name##*' '}
              _var_zip_file_name=${_var_line_from_games_txt%'.zip'*}; _var_zip_file_name=${_var_zip_file_name##*' '}
              _var_assets_folder_name="$(dirname "/.choko/assets/games/${_var_png_file_name}.png")"
              mkdir -p "$_var_assets_folder_name"
              cp "${_var_running_from_folder}/assets/games/${_var_png_file_name}.png" "${_var_assets_folder_name}/"; _var_last_command_exitcode=$?
              if [ $_var_last_command_exitcode -eq 0 ] && [ -f "${_var_running_from_folder}/assets/options/${_var_zip_file_name}.png" ]
              then
                _var_assets_folder_name="$(dirname "/.choko/assets/options/${_var_zip_file_name}.png")"
                mkdir -p "$_var_assets_folder_name"
                cp "${_var_running_from_folder}/assets/options/${_var_zip_file_name}.png" "${_var_assets_folder_name}/"; _var_last_command_exitcode=$?
              fi
              if [ $_var_last_command_exitcode -eq 0 ] && [ -f "${_var_running_from_folder}/assets/options/large/${_var_zip_file_name}.png" ]
              then
                _var_assets_folder_name="$(dirname "/.choko/assets/options/large/${_var_zip_file_name}.png")"
                mkdir -p "$_var_assets_folder_name"
                cp "${_var_running_from_folder}/assets/options/large/${_var_zip_file_name}.png" "${_var_assets_folder_name}/"; _var_last_command_exitcode=$?
              fi
              if [ $_var_last_command_exitcode -eq 0 ] && [ -f "${_var_running_from_folder}/assets/sounds/music/set2/${_var_zip_file_name}.ogg" ]
              then
                _var_assets_folder_name="$(dirname "/.choko/assets/sounds/music/set2/${_var_zip_file_name}.ogg")"
                mkdir -p "$_var_assets_folder_name"
                cp "${_var_running_from_folder}/assets/sounds/music/set2/${_var_zip_file_name}.ogg" "${_var_assets_folder_name}/"; _var_last_command_exitcode=$?
              fi
              if [ $_var_last_command_exitcode -eq 0 ] && [ -f "${_var_running_from_folder}/assets/sounds/${_var_zip_file_name}.ogg" ]
              then
                _var_assets_folder_name="$(dirname "/.choko/assets/sounds/${_var_zip_file_name}.ogg")"
                mkdir -p "$_var_assets_folder_name"
                cp "${_var_running_from_folder}/assets/sounds/${_var_zip_file_name}.ogg" "${_var_assets_folder_name}/"; _var_last_command_exitcode=$?
              fi
              [ $_var_last_command_exitcode -eq 0 ] || break
            done < "${_var_running_from_folder}/${_var_name_of_list}.txt"
          fi
          if [ $_var_last_command_exitcode -eq 0 ]
          then
            echo -e "\r\e[1;30mCopying assets from \"${_var_running_from_folder}/assets\" into CHA...    (OK)           \e[m"
            echo -ne "\e[1;30mcp \"${_var_running_from_folder}/${_var_name_of_list}.\"* /.choko/   \e[m\e[5m Please wait... \e[m"; cp "${_var_running_from_folder}/${_var_name_of_list}."* /.choko/; _var_last_command_exitcode=$?
          fi
          if [ $_var_last_command_exitcode -eq 0 ]
          then
            echo -e "\r\e[1;30mcp \"${_var_running_from_folder}/${_var_name_of_list}.\"* /.choko/    (OK)           \e[m"
            echo -ne "\e[1;30mcp \"${_var_running_from_folder}/usb_exec.sh\" /.choko/   \e[m\e[5m Please wait... \e[m"; cp "${_var_running_from_folder}/usb_exec.sh" /.choko/; _var_last_command_exitcode=$?
          fi
          if [ $_var_last_command_exitcode -eq 0 ]
          then
            echo -e "\r\e[1;30mcp \"${_var_running_from_folder}/usb_exec.sh\" /.choko/    (OK)           \e[m"
            chmod 755 /.choko/usb_exec.sh
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
            echo -e "\e[1;32m\"$_var_name_of_list\" was installed in the CHA.\e[m"
          else
            echo -e "\e[1;31mThere was some error.\e[m"; sleep 10; exit 201
          fi
        else
          echo "Skipping \"$_var_name_of_list\"."
        fi
      fi
    fi
  done
else
  echo "Did not found games to install."
fi

echo -en "Waiting for all files to be written..."
sync
while [ -n "$(pidof sync)" ]
do
  sleep 1
  echo -en "."
done

IFS="$OIFS"
_var_free_space=$(df -hP / | tail -1 | awk '{print $4}')
echo -e "\nNothing else to do here.\nYou have $_var_free_space free in the CHA."

_var_countdown=5
while [ $_var_countdown -gt 0 ]
do
  echo -ne "\rRebooting in $_var_countdown seconds... "
  _var_countdown=$((_var_countdown - 1))
  sleep 1
done
echo -e "\r                                        \r"
exit 200

#!/bin/sh
# games1I.sh - Script to set what core is to be used with each games list
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
  echo -e "\r                                   \r"
  if [ -z "$CHOKOVERSION" ] || [ "$CHOKOVERSION" \< "10.0.0" ]
  then
    reboot -f
  else
    exit 200
  fi
fi

if [ -z "$_var_running_with_bash" ]
then
  if [ -x "/bin/bash" ]
  then
    _var_running_with_bash="yes" exec /bin/bash "$(readlink -f "$0")" "$@"
  else
    echo -e "\n\e[1;31m/bin/bash is missing or not executable!\e[m";
  fi
fi

_var_running_from_folder="$(dirname "$(readlink -f "$0")")"

if [ -f "${_var_running_from_folder}/patches/fba_libretro.so" ]
then
  _var_screen_columns=$(stty -F /dev/tty0 size | cut '-d ' -f2)
  _var_screen_rows=$(stty -F /dev/tty0 size | cut '-d ' -f1)
  _var_max_menu_rows=$((_var_screen_rows - 8))
  _var_menu_USB_number_of_lines=0
  _array_lists_names=()                     # Array of games lists
  _array_patches_folders=()                 # Array of patches folder for each games list
  _array_cores_names_in_menu=()             # Array of Menu Options of available cores
  _array_cores_files=()                     # Array of cores files paths
  _array_cores_in_use_indexes=()            # Array with indexes for cores of each LIST_NAMES
  _array_cores_selected_in_menu_indexes=()  # Array with indexes for cores selected in menu
  _var_lists_names_length=34   # Length of menu title
  _var_cores_names_length=39   # Length of menu title
  _var_selected_option=0

  # Add space for selection mark in menu list + border space + [ ... ]
  fix_menu_width=12
  _var_Menu_Top_Row=$((_var_screen_rows / 2 + 1))
  _var_menu_left_column=1
  _var_total_menu_with=$fix_menu_width

  TopLeftCorner='\e[12mI'
  TopRightCorner=';\e[10m'
  HorizontalBar='M'
  VerticalBar='\e[12m:\e[10m'
  BottomLeftCorner='\e[12mH'
  BottomRighCorner='<\e[10m'

  BorderColor='\e[1;94m'
  OptionColor='\e[1;93m'
  _var_countdownColor='\e[1;95m'

  DownloadCoreMSG="DOWNLOAD LATEST CORE"
  SaveAndExitMSG="SAVE AND EXIT"

  setMenuWidthAndLeftColumn() {
    _var_total_menu_with=$((_var_lists_names_length + _var_cores_names_length + fix_menu_width))
    if [ $_var_total_menu_with -gt $((_var_screen_columns - 2)) ]
    then
      _var_total_menu_with=$((_var_screen_columns - 2))
      _var_menu_left_column=1
    else
      _var_menu_left_column=$(( (_var_screen_columns - _var_lists_names_length - _var_cores_names_length - fix_menu_width ) / 2 ))
    fi
  }

  # Function to download latest core
  downloadLatestCore() {
    DownloadCoreMSG=" CONNECTING WIFI... "
    updateCoreSelectMenu $_var_selected_option
    /etc/init.d/S40network restart > /dev/null 2>&1
    DownloadCoreMSG=" GETTING VERSION... "
    updateCoreSelectMenu $_var_selected_option
    _var_core_date="$(/.choko/busybox wget -q -o /dev/null -O - 'https://github.com/ChokoGroup/FBNeo/releases/tag/libretro-latest' | grep -m 1 'FinalBurn Neo libretro core for CHA (')"
    _var_core_date="${_var_core_date#*FinalBurn Neo libretro core for CHA (}"; _var_core_date="${_var_core_date%%)*}"
    if [ -z "$_var_core_date" ]
    then
      DownloadCoreMSG=" CONNECTION FAILED! "
      updateCoreSelectMenu $_var_selected_option
      sleep 3
    elif [ -f "${_var_running_from_folder}/patches/fbneo_libretro.${_var_core_date}.so" ]
    then
      DownloadCoreMSG=" NO NEW CORE FOUND! "
      updateCoreSelectMenu $_var_selected_option
      sleep 3
      rm -f /tmp/fbneo*
    else
      DownloadCoreMSG="   DOWNLOADING...   "
      updateCoreSelectMenu $_var_selected_option
      if /.choko/busybox wget -q -o /dev/null -O "/tmp/fbneo_libretro.zip" "https://github.com/ChokoGroup/FBNeo/releases/download/libretro-latest/fbneo_libretro.zip"
      then
        DownloadCoreMSG="    EXTRACTING...   "
        updateCoreSelectMenu $_var_selected_option
        if unzip -ojq /tmp/fbneo_libretro.zip *.so -d "${_var_running_from_folder}/patches"
        then
          rm -f /tmp/fbneo*
          DownloadCoreMSG="    INSTALLING...   "
          updateCoreSelectMenu $_var_selected_option
          _array_cores_files+=("${_var_running_from_folder}/patches/fbneo_libretro.${_var_core_date}.so")
          _array_cores_names_in_menu+=("fbneo_libretro.${_var_core_date}")
          _array_cores_selected_in_menu_indexes[${#_array_lists_names[@]} - 1]=$((${#_array_cores_files[@]} - 1))
          if [ ${#_array_cores_names_in_menu[-1]} -gt $_var_cores_names_length ]
          then
            _var_cores_names_length=${#_array_cores_names_in_menu[-1]}
            setMenuWidthAndLeftColumn
            showCoreSelectMenu
          fi
          updateCoreSelectMenu $((${#_array_lists_names[@]} - 1))
          DownloadCoreMSG="    CORE UPDATED    "
          updateCoreSelectMenu $_var_selected_option
          sleep 3
        else
          DownloadCoreMSG="  ERROR EXTRACTING! "
          updateCoreSelectMenu $_var_selected_option
          sleep 3
        fi
      else
        DownloadCoreMSG="  DOWNLOAD FAILED!  "
        updateCoreSelectMenu $_var_selected_option
        sleep 3
      fi
    fi
  }

  # Function to save cores preferences
  saveSelectedCores() {
    SaveAndExitMSG=" PLEASE WAIT "
    updateCoreSelectMenu $_var_selected_option
    i=${#_array_cores_selected_in_menu_indexes[@]}
    while [ $((--i)) -ge 0 ]
    do
      rm -f "${_array_patches_folders[i]}/"*.so "${_array_patches_folders[i]}/"*.core.conf
      if [ ${_array_cores_selected_in_menu_indexes[i]} -eq 0 ]
      then
        # Delete folder if empty
        rmdir "${_array_patches_folders[i]}" > /dev/null 2>&1
        # Make sure default core exist if we are in /.choko
        if [[ "${_array_patches_folders[i]}" == "/.choko/patches"* ]]
        then
          if [ ${_array_cores_selected_in_menu_indexes[-1]} -eq 0 ]
          then
            [ -f /.choko/patches/fba_libretro.so ] || cp "${_var_running_from_folder}/patches/fba_libretro.so" /.choko/patches/
          else
            mkdir -p "${_array_patches_folders[i]}"
            eval "_var_core_file_name_only=\${_array_cores_files[${_array_cores_selected_in_menu_indexes[-1]}]##*/}"
            touch "${_array_patches_folders[i]}/${_var_core_file_name_only}.core.conf"
            [ -f "/.choko/patches/${_var_core_file_name_only}" ] || cp  "${_var_running_from_folder}/patches/${_var_core_file_name_only}" /.choko/patches/
          fi
        fi
      else
        mkdir -p "${_array_patches_folders[i]}"
        eval "_var_core_file_name_only=\${_array_cores_files[${_array_cores_selected_in_menu_indexes[i]}]##*/}"
        touch "${_array_patches_folders[i]}/${_var_core_file_name_only}.core.conf"
        if [[ "${_array_patches_folders[i]}" == "/.choko/patches"* ]]
        then
          [ -f "/.choko/patches/${_var_core_file_name_only}" ] || cp  "${_var_running_from_folder}/patches/${_var_core_file_name_only}" /.choko/patches/
        fi
      fi
    done
    SaveAndExitMSG="    DONE!    "
    updateCoreSelectMenu $_var_selected_option
    sleep 2
  }


  # Function to show the Cores Menu
  showCoreSelectMenu() {
    # Menu title, top line, 1 line space
    printf "%b%*s%b" "\e[${_var_Menu_Top_Row};${_var_menu_left_column}H       LISTS OF GAMES \e[1;30m(up/down to change)" "$((_var_total_menu_with - 63))" "(left/right to change)" "\e[m CORE FILE TO USE\n\e[${_var_menu_left_column}G$BorderColor$TopLeftCorner"
    i=0
    while [ $((i++)) -lt $_var_total_menu_with ]
    do
      echo -en "$HorizontalBar"
    done
    printf "%b%*s%b" "$TopRightCorner\n\e[${_var_menu_left_column}G$VerticalBar" "$_var_total_menu_with" " " "$VerticalBar\n"
    # Menu games lists <> Core files list
    i=0
    while [ $i -lt ${#_array_lists_names[@]} ]
    do
      updateCoreSelectMenu $((i++))
    done
    # 1 line space + bottom line
    printf "%b%*s%b" "\n\e[${_var_menu_left_column}G$BorderColor$VerticalBar" "$_var_total_menu_with" " " "$VerticalBar\n\e[${_var_menu_left_column}G$BottomLeftCorner"
    i=0
    while [ $((i++)) -lt $_var_total_menu_with ]
    do
      echo -en "$HorizontalBar"
    done
    echo -en "$BottomRighCorner\n\e[${_var_menu_left_column}G       \e[1;30m(P1 Coin to reset selected list)\e[m"
    updateCoreSelectMenu ${#_array_lists_names[@]}
    updateCoreSelectMenu $((${#_array_lists_names[@]} + 1))
    updateCoreSelectMenu $((${#_array_lists_names[@]} + 2))
  }

  # Function to update only changed menu lines
  updateCoreSelectMenu() {

    # Menu games lists [ Core files list ]
    if [ $1 -lt ${#_array_lists_names[@]} ]
    then
      _var_temp_list_name="${_array_lists_names[$1]}"
      _var_temp_core_name="${_array_cores_names_in_menu[${_array_cores_selected_in_menu_indexes[$1]}]}"
      _var_menu_line_size=$((${#_var_temp_list_name} + ${#_var_temp_core_name} + 4))
      if [ $_var_menu_line_size -gt $((_var_total_menu_with - fix_menu_width)) ]
      then
        if [ ${#_var_temp_list_name} -gt ${#_var_temp_core_name} ]
        then
          [ ${#_var_temp_core_name} -gt $(( (_var_total_menu_with - fix_menu_width) / 2 )) ] && _var_temp_core_name="$(printf '%.*s' $(( (_var_total_menu_with - fix_menu_width) / 2 - 5)) "$_var_temp_core_name")(...)"
          _var_temp_list_name="$(printf '%.*s' $((_var_total_menu_with - fix_menu_width - fix_menu_width - ${#_var_temp_core_name})) "$_var_temp_list_name")(...)"
        else
          [ ${#_var_temp_list_name} -gt $(( (_var_total_menu_with - fix_menu_width) / 2 )) ] && _var_temp_list_name="$(printf '%.*s' $(( (_var_total_menu_with - fix_menu_width) / 2 - 5)) "$_var_temp_list_name")(...)"
          _var_temp_core_name="$(printf '%.*s' $((_var_total_menu_with - fix_menu_width - fix_menu_width - ${#_var_temp_list_name})) "$_var_temp_core_name")(...)"
        fi
      fi
      if [ $1 -eq $_var_selected_option ]
      then
        printf "%b%*s%b" "\e[$((_var_Menu_Top_Row + $1 + 3));${_var_menu_left_column}H$BorderColor$VerticalBar" "$_var_total_menu_with" " " "$VerticalBar\r\e[${_var_menu_left_column}G$BorderColor$VerticalBar  $_var_countdownColor>>>$BorderColor "
        [ $1 -lt $_var_menu_USB_number_of_lines ] && echo -en "(USB) "
        echo -en "$_var_temp_list_name "
        if [ ${_array_cores_selected_in_menu_indexes[$1]} -eq ${_array_cores_in_use_indexes[$1]} ]
        then
          echo -en "[ $_var_temp_core_name ]\e[m"
        else
          echo -en "\e[m[$BorderColor $_var_temp_core_name \e[m]"
        fi
      else
        printf "%b%*s%b" "\e[$((_var_Menu_Top_Row + $1 + 3));${_var_menu_left_column}H$BorderColor$VerticalBar" "$_var_total_menu_with" " " "$VerticalBar\r\e[${_var_menu_left_column}G$BorderColor$VerticalBar      "
        [ $1 -lt $_var_menu_USB_number_of_lines ] && echo -en "\e[m(USB) "
        echo -en "$OptionColor$_var_temp_list_name "
        if [ ${_array_cores_selected_in_menu_indexes[$1]} -eq ${_array_cores_in_use_indexes[$1]} ]
        then
          echo -en "\e[m[ $_var_temp_core_name ]"
        else
          echo -en "\e[m\e[30m\e[47m[ $_var_temp_core_name ]\e[m"
        fi
      fi
    elif [ $1 -eq ${#_array_lists_names[@]} ]
    then
      echo -ne "\e[$((_var_Menu_Top_Row + $1 + 5));$(( (_var_screen_columns - 28) / 2))H"
      if [ $_var_selected_option -eq $1 ]
      then
        echo -en "${_var_countdownColor}>>>$BorderColor $DownloadCoreMSG ${_var_countdownColor}<<<\e[m"
      else
        echo -en "${OptionColor}    $DownloadCoreMSG    \e[m"
      fi
    elif [ $1 -eq $((${#_array_lists_names[@]} + 1)) ]
    then
      echo -ne "\e[$((_var_Menu_Top_Row + $1 + 5));$(( (_var_screen_columns - 21) / 2))H"
      if [ $_var_selected_option -eq $1 ]
      then
        echo -en "${_var_countdownColor}>>>$BorderColor $SaveAndExitMSG ${_var_countdownColor}<<<\e[m"
      else
        echo -en "${OptionColor}    $SaveAndExitMSG    \e[m"
      fi
    elif [ $1 -gt $((${#_array_lists_names[@]} + 1)) ]
    then
      echo -ne "\e[$((_var_Menu_Top_Row + $1 + 5));$(( (_var_screen_columns - 27) / 2))H"
      if [ $_var_selected_option -eq $1 ]
      then
        echo -en "${_var_countdownColor}>>>$BorderColor EXIT WITHOUT SAVING ${_var_countdownColor}<<<\e[m"
      else
        echo -en "${OptionColor}    EXIT WITHOUT SAVING    \e[m"
      fi
    fi
  }

  findCoreInUse() {
    i=0   # Default core (not set)
    echo -n "."
    if [ -d "${_array_patches_folders[0]}" ]
    then
      _var_Core_File="$(ls "${_array_patches_folders[0]}"/*.core.conf)"   # Empty file to store original name of core file
      _var_Core_File="${_var_Core_File##*/}"; _var_Core_File="${_var_Core_File%.core.conf}"
      if [ -n "$_var_Core_File" ] && [ -f "${_var_running_from_folder}/patches/$_var_Core_File" ]
      then
        # Get core file index in list
        i=${#_array_cores_files[@]}
        while [ $((--i)) -ge 0 ] && [ "${_array_cores_files[i]}" != "${_var_running_from_folder}/patches/$_var_Core_File" ]
        do
          :
        done
        if [ $i -lt 0 ]
        then    # It is an unique core file and we need to save a copy in patches/
          _array_cores_names_in_menu+=("${_var_Core_File%.*}")
          _array_cores_files+=("${_var_running_from_folder}/patches/$_var_Core_File")
          cp "${_array_patches_folders[0]}/fba_libretro.so" "${_array_cores_files[-1]}"
          if [ ${#_array_cores_names_in_menu[-1]} -gt $_var_cores_names_length ]
          then
            _var_cores_names_length=${#_array_cores_names_in_menu[-1]}
          fi
          i=$((${#_array_cores_files[@]} - 1))    
        fi
      elif [ -f "${_array_patches_folders[0]}/fba_libretro.so" ]
      then
        # Slower *.so file compare
        i=${#_array_cores_files[@]}
        while [ $((--i)) -ge 0 ] && [ "$(diff -q "${_array_cores_files[i]}" "${_array_patches_folders[0]}/fba_libretro.so")" ]
        do
          echo -n "."
        done
        if [ $i -lt 0 ]
        then    # It is an unique core file and we need to save a copy in patches/
          _array_cores_names_in_menu+=("fba_libretro - copied from ${_array_lists_names[0]}")
          _array_cores_files+=("${_var_running_from_folder}/patches/${_array_cores_names_in_menu[-1]}.so")
          cp "${_array_patches_folders[0]}/fba_libretro.so" "${_array_cores_files[-1]}"
          if [ ${#_array_cores_names_in_menu[-1]} -gt $_var_cores_names_length ]
          then
            _var_cores_names_length=${#_array_cores_names_in_menu[-1]}
          fi
          i=$((${#_array_cores_files[@]} - 1))    
        fi
      fi
    fi
    _array_cores_in_use_indexes=($i ${_array_cores_in_use_indexes[@]})
    _array_cores_selected_in_menu_indexes=($i ${_array_cores_selected_in_menu_indexes[@]})
  }

  # Function to reset games lists
  deleteTXT() {
    # Wait for buttons to be released before asking to delete
    while [ "$(readjoysticks j1 j2 -b)" != "0000000000000000" ]
    do
      sleep 1
    done
    _var_countdown=15
    _var_stop_contdown="N"
    _var_user_answer="No"
    _var_temp_list_name="${_array_lists_names[$_var_selected_option]}"
    [ $_var_selected_option -lt $_var_menu_USB_number_of_lines ] && _var_temp_list_name="(USB) $_var_temp_list_name"
    [ ${#_var_temp_list_name} -gt $((_var_total_menu_with - 95)) ] && _var_temp_list_name="$(printf '%.*s' $((_var_total_menu_with - 95)) "$_var_temp_list_name")(...)"
    printf "%b%*s%b" "\e[$((_var_Menu_Top_Row + _var_selected_option + 3));${_var_menu_left_column}H$BorderColor$VerticalBar" "$_var_total_menu_with" " " "$VerticalBar\r\e[${_var_menu_left_column}G$BorderColor$VerticalBar  $_var_countdownColor>>> \e[s${BorderColor}Do you want to reset \"$_var_temp_list_name\"? \e[1;93m$_var_user_answer   \e[1;30mUse joystick to change answer. Waiting $_var_countdown seconds...\e[m "

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
          echo -ne "\e[u${BorderColor}Do you want to reset \"$_var_temp_list_name\"? \e[1;93m$_var_user_answer \e[m                                                       "
        ;;
        0|1|2|3|4|5|6|7)
          _var_countdown=0
        ;;
        *)
          if [ "$_var_stop_contdown" = "N" ]
          then
            _var_countdown=$((_var_countdown - 1))
            echo -ne "\e[u${BorderColor}Do you want to reset \"$_var_temp_list_name\"? \e[1;93m$_var_user_answer   \e[1;30mUse joystick to change answer. Waiting $_var_countdown seconds...\e[m "
          fi
        ;;
      esac
    done
    echo -ne "\e[u${BorderColor}Do you want to reset \"$_var_temp_list_name\"? \e[1;93m$_var_user_answer \e[m                                                       "
    if [ "$_var_user_answer" = "Yes" ]
    then
      _var_last_command_exitcode=0
      if [ $_var_selected_option -lt $_var_menu_USB_number_of_lines ] && [ -f "${_var_running_from_folder}/${_array_lists_names[$_var_selected_option]}.txt" ]
      then
        mv "${_var_running_from_folder}/${_array_lists_names[$_var_selected_option]}.txt" "${_var_running_from_folder}/${_array_lists_names[$_var_selected_option]}.old"; _var_last_command_exitcode=$?
      elif [ -f "/.choko/${_array_lists_names[$_var_selected_option]}.txt" ]
      then
        mv "/.choko/${_array_lists_names[$_var_selected_option]}.txt" "/.choko/${_array_lists_names[$_var_selected_option]}.old"; _var_last_command_exitcode=$?
      fi
      [ $_var_last_command_exitcode -eq 0 ] && echo -ne "\e[u${BorderColor}$_var_temp_list_name \e[1;32mwas reset\e[m                                                       " || echo -en "\e[1;31mThere was some error deleting \"${_array_lists_names[$_var_selected_option]}.txt\".\e[m                                                       "
    else
      echo -ne "\e[u${BorderColor}$_var_temp_list_name was NOT reset.                                                       "
    fi
    sleep 3
  }

  upgradeListGamesToV13 () {
    # Wait for buttons to be released
    while [ "$(readjoysticks j1 j2 -b)" != "0000000000000000" ]
    do
      sleep 1
    done
    _var_countdown=15
    _var_stop_contdown="N"
    _var_user_answer="No"
    echo -en "\n\nDo you want to upgrade \"$_var_temp_list_name\" to Choko Hack v13 format? \e[1;93m$_var_user_answer \n\e[1;30mUse joystick to change answer. Waiting $_var_countdown seconds...\e[m  "

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
          echo -ne "\r\e[1ADo you want to upgrade \"$_var_temp_list_name\" to Choko Hack v13 format? \e[1;93m$_var_user_answer \n\e[m\e[K"
        ;;
        0|1|2|3|4|5|6|7)
          _var_countdown=0
        ;;
        *)
          if [ "$_var_stop_contdown" = "N" ]
          then
            _var_countdown=$((_var_countdown - 1))
            echo -ne "\r\e[1ADo you want to upgrade \"$_var_temp_list_name\" to Choko Hack v13 format? \e[1;93m$_var_user_answer \n\e[1;30mUse joystick to change answer. Waiting $_var_countdown seconds...\e[m "
          fi
        ;;
      esac
    done
    echo -ne "\r\e[1ADo you want to upgrade \"$_var_temp_list_name\" to Choko Hack v13 format? \e[1;93m$_var_user_answer \n\e[m\e[K"
    if [ "$_var_user_answer" = "Yes" ]
    then
      _var_last_command_exitcode=0
      if [ "${_var_temp_list_name#(USB) }" != "$_var_folder_with_ROMs" ]
      then
        _var_temp_list_name="${_var_temp_list_name#(USB) }"
      else
        _var_temp_list_name="My custom list $_var_folder_with_ROMs"
      fi
      mv -v "${_var_root_folder_for_roms}/$_var_folder_with_ROMs" "${_var_root_folder_for_roms}/$_var_temp_list_name"
      _var_last_command_exitcode=$?
      if [ $_var_last_command_exitcode -eq 0 ] && [ -d "${_var_root_folder_for_else}/patches/$_var_folder_with_ROMs" ]
      then
        mv -v "${_var_root_folder_for_else}/patches/$_var_folder_with_ROMs" "${_var_root_folder_for_else}/patches/$_var_temp_list_name"
        _var_last_command_exitcode=$?
      fi
      if [ $_var_last_command_exitcode -eq 0 ] && [ -f "${_var_root_folder_for_else}/${_var_folder_with_ROMs}.txt" ]
      then
        mv -v "${_var_root_folder_for_else}/${_var_folder_with_ROMs}.txt" "${_var_root_folder_for_else}/${_var_temp_list_name}.txt"
        _var_last_command_exitcode=$?
      fi
      if [ $_var_last_command_exitcode -eq 0 ]
      then
        rm -vf "${_var_root_folder_for_else}/${_var_folder_with_ROMs}.sh" "${_var_root_folder_for_else}/${_var_folder_with_ROMs}.nfo"
        _var_last_command_exitcode=$?
      fi
      if [ $_var_last_command_exitcode -eq 0 ]
      then
        echo -e "\"$_var_temp_list_name\" \e[1;32mwas upgraded!\e[m"
        # Insert new lists in beggining of array, pushing "Default core" defined by user to the end
        _array_lists_names=("$_var_temp_list_name" "${_array_lists_names[@]}")
        _array_patches_folders=("${_var_root_folder_for_else}/patches/$_var_temp_list_name" "${_array_patches_folders[@]}")
        _var_countdown=3
        while [ $((--_var_countdown)) -gt 0 ]
        do
          echo -ne "\rResuming in $_var_countdown seconds... "
          sleep 1
        done
        echo -ne "\e[m\r\e[K"
        return 0
      else
        echo -e "\e[1;31mThere was some error upgrading \"$_var_temp_list_name\".\e[m"
        _var_countdown=10
        while [ $((--_var_countdown)) -gt 0 ]
        do
          echo -ne "\rResuming in $_var_countdown seconds... "
          sleep 1
        done
        echo -ne "\e[m\r\e[K"
        return 1
      fi
    else
      echo -e "\"$_var_temp_list_name\" was NOT upgraded and will be ignored by Core Manager,\nbut you can still use it with Choko Hack 13."
      _var_countdown=5
      while [ $((--_var_countdown)) -gt 0 ]
      do
        echo -ne "\rResuming in $_var_countdown seconds... "
        sleep 1
      done
      echo -ne "\e[m\r\e[K"
      return 1
    fi
  }

  # Set default core file
  _array_cores_files=("${_var_running_from_folder}/patches/fba_libretro.so")
  _array_cores_names_in_menu=("Default core")
  # _var_cores_names_length=${#_array_cores_names_in_menu[0]}

  # Make 'for' loops use entire lines
  OIFS="$IFS"
  IFS=$'\n'
  echo -n "Loading"

  # Look for patches/*.so other than the default fba_libretro.so
  if [ $(find "${_var_running_from_folder}/patches" -iname '*.so' ! -iname 'fba_libretro.so' -mindepth 1 -maxdepth 1 -type f -print 2> /dev/null | wc -l) -gt 0 ]
  then
    for _var_Core_File in $(find "${_var_running_from_folder}/patches" -iname '*.so' ! -iname 'fba_libretro.so' -mindepth 1 -maxdepth 1 -type f -print 2> /dev/null | sort -f)
    do
      _array_cores_files+=("$_var_Core_File")
      _var_Core_File="${_var_Core_File##*/}"
      _array_cores_names_in_menu+=("${_var_Core_File%.*}")
      if [ ${#_array_cores_names_in_menu[-1]} -gt $_var_cores_names_length ]
      then
        _var_cores_names_length=${#_array_cores_names_in_menu[-1]}
      fi
      echo -n "."
    done
  fi

  # "Default core" defined by user will be pushed to end of menu
  _array_lists_names=("Default core defined by user")
  _array_patches_folders=("${_var_running_from_folder}/patches/default")
  # _var_lists_names_length=${#_array_lists_names[0]}
  findCoreInUse

  # Look for /usr/share/roms/* folders with *.zip
  if [ $(find /usr/share/roms -iname '*' -mindepth 1 -maxdepth 1 -type d -print 2> /dev/null | wc -l) -gt 0 ]
  then
    for _var_folder_with_ROMs in $(find /usr/share/roms -iname '*' -mindepth 1 -maxdepth 1 -type d -print 2> /dev/null | sort -fr)
    do
      if [ $(find "$_var_folder_with_ROMs" -iname '*.zip' -type f -print 2> /dev/null | wc -l) -gt 0 ] && [ ${#_array_lists_names[@]} -le $_var_max_menu_rows ]
      then
        case "${_var_folder_with_ROMs##*/}" in
          # 'games??' logic from Choko Hack v11
          games[12][A-F])
            _var_folder_with_ROMs="${_var_folder_with_ROMs##*/}"
            if [ -f "/.choko/${_var_folder_with_ROMs}.nfo" ]
            then
              _var_temp_list_name="(USB) $(head -n 1 "/.choko/${_var_folder_with_ROMs}.nfo")"
            else
              _var_temp_list_name="(USB) ${_var_folder_with_ROMs}"
            fi
            _var_root_folder_for_roms="/usr/share/roms"
            _var_root_folder_for_else="/.choko"
            if ! upgradeListGamesToV13;
            then
              continue
            fi
          ;;
          *)
            # Insert new lists in beggining of array, pushing "Default core" defined by user to the end
            _array_lists_names=("${_var_folder_with_ROMs##*/}" "${_array_lists_names[@]}")
            _array_patches_folders=("/.choko/patches/${_array_lists_names[0]}" "${_array_patches_folders[@]}")
          ;;
        esac
        if [ ${#_array_lists_names[0]} -gt $_var_lists_names_length ]
        then
          _var_lists_names_length=${#_array_lists_names[0]}
        fi
        findCoreInUse
      fi
    done
  fi

  # Look for roms/* folders with *.zip
  if [ $(find "${_var_running_from_folder}/roms" -iname '*' -mindepth 1 -maxdepth 1 -type d -print 2> /dev/null | wc -l) -gt 0 ]
  then
    for _var_folder_with_ROMs in $(find "${_var_running_from_folder}/roms" -iname '*' -mindepth 1 -maxdepth 1 -type d -print 2> /dev/null | sort -fr)
    do
      if [ $(find "$_var_folder_with_ROMs" -iname '*.zip' -type f -print 2> /dev/null | wc -l) -gt 0 ] && [ ${#_array_lists_names[@]} -le $_var_max_menu_rows ]
      then
        case "${_var_folder_with_ROMs##*/}" in
          # 'games??' logic from Choko Hack v11
          games[12][A-F])
            _var_folder_with_ROMs="${_var_folder_with_ROMs##*/}"
            if [ -f "${_var_running_from_folder}/${_var_folder_with_ROMs}.nfo" ]
            then
              _var_temp_list_name="(USB) $(head -n 1 "${_var_running_from_folder}/${_var_folder_with_ROMs}.nfo")"
            else
              _var_temp_list_name="(USB) ${_var_folder_with_ROMs}"
            fi
            _var_root_folder_for_roms="${_var_running_from_folder}/roms"
            _var_root_folder_for_else="$_var_running_from_folder"
            if ! upgradeListGamesToV13;
            then
              continue
            fi
          ;;
          *)
            # Insert new lists in beggining of array, pushing "Default core" defined by user to the end
            _array_lists_names=("${_var_folder_with_ROMs##*/}" "${_array_lists_names[@]}")
            _array_patches_folders=("${_var_folder_with_ROMs//'/roms/'/'/patches/'}" "${_array_patches_folders[@]}")
          ;;
        esac
        # Count with "(USB) " added in menu listing
        if [ $((${#_array_lists_names[0]} + 6)) -gt $_var_lists_names_length ]
        then
          _var_lists_names_length=$((${#_array_lists_names[0]} + 6))
        fi
        ((++_var_menu_USB_number_of_lines))
        findCoreInUse
      fi
    done
  fi

  if [ ${#_array_lists_names[@]} -gt $_var_max_menu_rows ]
  then
    _array_lists_names+=("*** Too many lines, some games lists were ignored ***")
    _array_patches_folders+=("/dev/null")
    [ ${#_array_lists_names[-1]} -gt $_var_lists_names_length ] && _var_lists_names_length=${#_array_lists_names[-1]}
  fi

  IFS="$OIFS"

  # Check screen size and display menu background for Choko Menu
  _var_Screen_Resolution=$(fbset | sed '2q;d'); _var_Screen_Resolution=${_var_Screen_Resolution#*'"'}; _var_Screen_Resolution=${_var_Screen_Resolution%'-'*}
  echo -ne "\e[1;1H\e[m\ec"
  cat "/.choko/choko-${_var_Screen_Resolution}.rgba" > /dev/fb0

  # Position of top left corner of menu
  [ ${#_array_lists_names[@]} -gt $((_var_Menu_Top_Row - 8)) ] && _var_Menu_Top_Row=$((_var_screen_rows - ${#_array_lists_names[@]} - 8))
  setMenuWidthAndLeftColumn

  # Show menu and read joystick
  showCoreSelectMenu
  while :
  do
    case "$(readjoysticks j1)" in
      U)
        updateCoreSelectMenu $((_var_selected_option--))
        [ $_var_selected_option -lt 0 ] && _var_selected_option=$((${#_array_lists_names[@]} + 2))
        updateCoreSelectMenu $_var_selected_option
      ;;
      D)
        updateCoreSelectMenu $((_var_selected_option++))
        [ $_var_selected_option -gt $((${#_array_lists_names[@]} + 2)) ] && _var_selected_option=0
        updateCoreSelectMenu $_var_selected_option
      ;;
      L)
        if [ $_var_selected_option -lt ${#_array_lists_names[@]} ]
        then
          if [ ${_array_cores_selected_in_menu_indexes[_var_selected_option]} -gt 0 ]
          then
            _array_cores_selected_in_menu_indexes[_var_selected_option]=$((_array_cores_selected_in_menu_indexes[_var_selected_option] - 1))
          else
            _array_cores_selected_in_menu_indexes[_var_selected_option]=$((${#_array_cores_files[@]} - 1))
          fi
          updateCoreSelectMenu $_var_selected_option
        fi
      ;;
      R)
        if [ $_var_selected_option -lt ${#_array_lists_names[@]} ]
        then
         _array_cores_selected_in_menu_indexes[_var_selected_option]=$((_array_cores_selected_in_menu_indexes[_var_selected_option] + 1))
         if [ ${_array_cores_selected_in_menu_indexes[_var_selected_option]} -ge ${#_array_cores_files[@]} ]
          then
            _array_cores_selected_in_menu_indexes[_var_selected_option]=0
          fi
          updateCoreSelectMenu $_var_selected_option
        fi
      ;;
      0|3)
        if [ $_var_selected_option -lt ${#_array_lists_names[@]} ]
        then
          if [ ${_array_cores_selected_in_menu_indexes[_var_selected_option]} -gt 0 ]
          then
            _array_cores_selected_in_menu_indexes[_var_selected_option]=$((_array_cores_selected_in_menu_indexes[_var_selected_option] - 1))
          else
            _array_cores_selected_in_menu_indexes[_var_selected_option]=$((${#_array_cores_files[@]} - 1))
          fi
          updateCoreSelectMenu $_var_selected_option
        fi
        if [ $_var_selected_option -eq ${#_array_lists_names[@]} ]
        then
          downloadLatestCore
          DownloadCoreMSG="DOWNLOAD LATEST CORE"
          updateCoreSelectMenu $_var_selected_option
        fi
        [ $_var_selected_option -eq $((${#_array_lists_names[@]} + 1)) ] && saveSelectedCores && break
        [ $_var_selected_option -gt $((${#_array_lists_names[@]} + 1)) ] && break
      ;;
      1|4)
        if [ $_var_selected_option -lt ${#_array_lists_names[@]} ]
        then
         _array_cores_selected_in_menu_indexes[_var_selected_option]=$((_array_cores_selected_in_menu_indexes[_var_selected_option] + 1))
         if [ ${_array_cores_selected_in_menu_indexes[_var_selected_option]} -ge ${#_array_cores_files[@]} ]
          then
            _array_cores_selected_in_menu_indexes[_var_selected_option]=0
          fi
          updateCoreSelectMenu $_var_selected_option
        fi
        if [ $_var_selected_option -eq ${#_array_lists_names[@]} ]
        then
          downloadLatestCore
          DownloadCoreMSG="DOWNLOAD LATEST CORE"
          updateCoreSelectMenu $_var_selected_option
        fi
        [ $_var_selected_option -eq $((${#_array_lists_names[@]} + 1)) ] && saveSelectedCores && break
        [ $_var_selected_option -gt $((${#_array_lists_names[@]} + 1)) ] && break
      ;;
      7)
        # P1 Coin button: reset list = delete .txt file
        if [ $_var_selected_option -lt ${#_array_lists_names[@]} ]
        then
          deleteTXT
          updateCoreSelectMenu $_var_selected_option
        fi
      ;;
    esac
  done
  sync
  # Wait for buttons to be released
  while [ "$(readjoysticks j1 j2 -b)" != "0000000000000000" ]
  do
    sleep 1
  done
 _var_countdown=0
else
  echo -e "\nThe file \"${_var_running_from_folder}/patches/fba_libretro.so\" is missing!"
  _var_countdown=11
fi

while [ $((--_var_countdown)) -gt 0 ]
do
  echo -ne "\rReturning to Choko Menu in $_var_countdown seconds... "
  sleep 1
done
echo -e "\r                                                 \r"
exit 202

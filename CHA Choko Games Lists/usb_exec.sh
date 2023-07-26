#!/bin/sh
# usb_exec.sh
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

_var_running_from_folder="$(dirname "$(readlink -f "$0")")"
_var_name_of_list="$*"

# Where are the ROMs
if [ "$_var_running_from_folder" = "/.choko" ]
then
  _var_folder_with_ROMs="/usr/share/roms/$_var_name_of_list"
else
  _var_folder_with_ROMs="${_var_running_from_folder}/roms/$_var_name_of_list"
fi


creategamestxt () {
  echo -n "Creating \"${_var_name_of_list}.txt\""
  _var_is_first_line="Y"
  _var_icon_number=0
  # Make 'for' loops use entire lines
  OIFS="$IFS"
  IFS=$'\n'
  # Go to folder to avoid problems with apostrophes in folders names
  cd "$_var_folder_with_ROMs"
  for _var_file_name in $(find . -mindepth 1 -maxdepth 2 -name '*.zip' -type f -print 2> /dev/null | sort -f)
  do
    _var_file_name="${_var_file_name#./}"; _var_file_name="${_var_file_name%.zip}"
    # Ignore BIOS only zip files
    if [ "$_var_file_name" != "neogeo" ] && [ "$_var_file_name" != "neocdz" ] && [ "$_var_file_name" != "decocass" ] && [ "$_var_file_name" != "isgsm" ] && [ "$_var_file_name" != "midssio" ] && [ "$_var_file_name" != "nmk004" ] && [ "$_var_file_name" != "pgm" ] && [ "$_var_file_name" != "skns" ] && [ "$_var_file_name" != "ym2608" ] && [ "$_var_file_name" != "cchip" ] && [ "$_var_file_name" != "bubsys" ] && [ "$_var_file_name" != "namcoc69" ] && [ "$_var_file_name" != "namcoc70" ] && [ "$_var_file_name" != "namcoc75" ] && [ "$_var_file_name" != "coleco" ] && [ "$_var_file_name" != "fdsbios" ] && [ "$_var_file_name" != "msx" ] && [ "$_var_file_name" != "ngp" ] && [ "$_var_file_name" != "spectrum" ] && [ "$_var_file_name" != "spec128" ] && [ "$_var_file_name" != "channelf" ]
    then
      _var_parent_rom_name="$_var_file_name"
      _var_line_for_games_txt="$(grep -m 1 " ${_var_parent_rom_name}.zip" "${_var_running_from_folder}/games_all.txt")"
      # Search for parent rom in games_all.txt if exact zip not found n games_all.txt
      while [ -z "$_var_line_for_games_txt" ] && [ ${#_var_parent_rom_name} -gt 1 ]
      do
        _var_parent_rom_name="${_var_parent_rom_name%?}"
        _var_line_for_games_txt="$(grep -m 1 " ${_var_parent_rom_name}.zip" "${_var_running_from_folder}/games_all.txt")"
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
        if [ "$_var_file_name" != "$_var_parent_rom_name" ]
        then
          _temp_var_file_name="${_var_file_name//\//\\\/}"
          _temp_var_parent_rom_name="${_var_parent_rom_name//\//\\\/}"
          eval "_var_line_for_games_txt=\"\${_var_line_for_games_txt/ ${_temp_var_parent_rom_name}.zip/ ${_temp_var_file_name}.zip}\""
        fi
        # Check if png exists and look for parent png if not
        _var_assets_file_name="${_var_line_for_games_txt:11}"; _var_assets_file_name="${_var_assets_file_name%%' '*}"
        if [ ! -f "${_var_running_from_folder}/assets/games/$_var_assets_file_name" ]
        then
          _temp_var_assets_file_name="${_var_assets_file_name//\//\\\/}"
          _var_parent_rom_name="$_var_file_name"
          while [ ! -f "${_var_running_from_folder}/assets/games/${_var_parent_rom_name}.png" ] && [ ${#_var_parent_rom_name} -gt 1 ]
          do
            _var_parent_rom_name="${_var_parent_rom_name%?}"
          done
          if [ -f "${_var_running_from_folder}/assets/games/${_var_parent_rom_name}.png" ]
          then
            _temp_var_parent_rom_name="${_var_parent_rom_name//\//\\\/}"
            eval "_var_line_for_games_txt=\"\${_var_line_for_games_txt/ ${_temp_var_assets_file_name}/ ${_temp_var_parent_rom_name}.png}\""
          else
            _var_icon_number=$((_var_icon_number + 1))
            if [ ${#_var_icon_number} -eq 1 ]
            then
              eval "_var_line_for_games_txt=\"\${_var_line_for_games_txt/ $_temp_var_assets_file_name/ game0$_var_icon_number.png}\""
            else
              eval "_var_line_for_games_txt=\"\${_var_line_for_games_txt/ $_temp_var_assets_file_name/ game$_var_icon_number.png}\""
            fi
          fi
        fi
        # Check if ogg exists and look for parent ogg if not
        _var_assets_file_name="${_var_line_for_games_txt#*'.zip '}"; _var_assets_file_name="${_var_assets_file_name%%' '*}"
        if [ ! -f "${_var_running_from_folder}/assets/sounds/$_var_assets_file_name" ] && [ ! -f "${_var_running_from_folder}/assets/sounds/music/set2/$_var_assets_file_name" ]
        then
          _var_parent_rom_name="$_var_file_name"
          while [ ! -f "${_var_running_from_folder}/assets/sounds/${_var_parent_rom_name}.ogg" ] && [ ! -f "${_var_running_from_folder}/assets/sounds/music/set2/${_var_parent_rom_name}.ogg" ] && [ ${#_var_parent_rom_name} -gt 1 ]
          do
            _var_parent_rom_name="${_var_parent_rom_name%?}"
          done
          if [ -f "${_var_running_from_folder}/assets/sounds/${_var_parent_rom_name}.ogg" ] || [ -f "${_var_running_from_folder}/assets/sounds/music/set2/${_var_parent_rom_name}.ogg" ]
          then
            _temp_var_assets_file_name="${_var_assets_file_name//\//\\\/}"
            _temp_var_parent_rom_name="${_var_parent_rom_name//\//\\\/}"
            eval "_var_line_for_games_txt=\"\${_var_line_for_games_txt/ ${_temp_var_assets_file_name}/ ${_temp_var_parent_rom_name}.ogg}\""
          fi
        fi
        echo -n "$_var_line_for_games_txt" >> "${_var_running_from_folder}/${_var_name_of_list}.txt"
      else
        # Line not found in games_all.txt
        # Search for rom assets or parent rom assets
        _var_parent_rom_name="$_var_file_name"
        while [ ! -f "${_var_running_from_folder}/assets/games/${_var_parent_rom_name}.png" ] && [ ${#_var_parent_rom_name} -gt 1 ]
        do
          _var_parent_rom_name="${_var_parent_rom_name%?}"
        done
        if [ -f "${_var_running_from_folder}/assets/games/${_var_parent_rom_name}.png" ]
        then
          echo -n "A 0 B 0000 ${_var_parent_rom_name}.png ${_var_file_name}.zip ${_var_parent_rom_name}.ogg 0 $_var_parent_rom_name" >> "${_var_running_from_folder}/${_var_name_of_list}.txt"
        else
          _var_icon_number=$((_var_icon_number + 1))
          if [ ${#_var_icon_number} -eq 1 ]
          then
            echo -n "A 0 B 0000 game0$_var_icon_number.png ${_var_file_name}.zip ${_var_file_name}.ogg 0 $_var_file_name" >> "${_var_running_from_folder}/${_var_name_of_list}.txt"
          else
            echo -n "A 0 B 0000 game$_var_icon_number.png ${_var_file_name}.zip ${_var_file_name}.ogg 0 $_var_file_name" >> "${_var_running_from_folder}/${_var_name_of_list}.txt"
          fi
        fi
      fi
      echo -n "."
    fi
  done
  cd "$_var_running_from_folder"
  IFS="$OIFS"
  echo " Done!"
  sync
  sleep 1
}

if [ -n "$_var_name_of_list" ] && [ -d "$_var_folder_with_ROMs" ]
then

  # Create ${_var_name_of_list}.txt if it does not exist
  [ -f "${_var_running_from_folder}/${_var_name_of_list}.txt" ] || creategamestxt

  if [ -f "${_var_running_from_folder}/${_var_name_of_list}.txt" ]
  then
    # Mount assets for games
    # Remember to choose Remix in music settings
    for _var_file_to_mount in \
      assets/games \
      assets/options \
      assets/sounds
    do
      mount --bind "${_var_running_from_folder}/$_var_file_to_mount" "/opt/capcom/$_var_file_to_mount"
    done

    # Where to look for patches
    if [ -d "${_var_running_from_folder}/patches/$_var_name_of_list" ]
    then
      _var_patch_to_patches_folder="${_var_running_from_folder}/patches/$_var_name_of_list"
    else
      _var_patch_to_patches_folder="${_var_running_from_folder}/patches/default"
    fi

    # Make 'for' loops use entire lines
    OIFS="$IFS"
    IFS=$'\n'
    # Mount assets to change UI if they exist
    for _var_assets_file_name_to_mount in $(find "${_var_patch_to_patches_folder}/assets" -name '*' -type f -print 2> /dev/null)
    do
      mount --bind "$_var_assets_file_name_to_mount" "/opt/capcom/assets/${_var_assets_file_name_to_mount#*'/assets/'}"
    done
    IFS="$OIFS"
    [ -f "${_var_patch_to_patches_folder}/assets/capcom-home-arcade-last.png" ] || mount --bind "${_var_running_from_folder}/assets/capcom-home-arcade-last.png" /opt/capcom/assets/capcom-home-arcade-last.png

    # Don't ruin Easter Egg
    if [ "$LUCKY" = "10" ] && [ -f /opt/capcom/assets/gold/bg.png ]
    then
      for _var_golden_file_to_mount in \
        BARS_top.png \
        bg.png \
        bg_single.png
      do
        [ -f "${_var_patch_to_patches_folder}/assets/gold/$_var_golden_file_to_mount" ] && umount "/opt/capcom/assets/$_var_golden_file_to_mount" 2>/dev/null
        [ -f "${_var_patch_to_patches_folder}/assets/gold/$_var_golden_file_to_mount" ] && mount --bind "${_var_patch_to_patches_folder}/assets/gold/$_var_golden_file_to_mount" "/opt/capcom/assets/$_var_golden_file_to_mount"
      done
    fi

    # Mount list of games for carousel
    mount --bind "${_var_running_from_folder}/${_var_name_of_list}.txt" /opt/capcom/assets/games.txt

    # Mount patched 'capcom' if exists
    [ -f "${_var_patch_to_patches_folder}/capcom" ] && mount --bind "${_var_patch_to_patches_folder}/capcom" /opt/capcom/capcom

    # Mount libretro core
    _var_Core_File="$(ls "$_var_patch_to_patches_folder"/*.core.conf)"   # Empty file to store original name of core file
    _var_Core_File="${_var_Core_File##*/}"; _var_Core_File="${_var_Core_File%.core.conf}"
    if [ -n "$_var_Core_File" ] && [ -f "${_var_running_from_folder}/patches/$_var_Core_File" ]
    then
      mount --bind "${_var_running_from_folder}/patches/$_var_Core_File" /usr/lib/libretro/fba_libretro.so
      echo -e "\e[1;30mEmulating games with: ${_var_running_from_folder}/patches/$_var_Core_File\e[m"
    elif [ -f "${_var_patch_to_patches_folder}/fba_libretro.so" ]
    then
      mount --bind "${_var_patch_to_patches_folder}/fba_libretro.so" /usr/lib/libretro/fba_libretro.so
      echo -e "\e[1;30mEmulating games with: ${_var_patch_to_patches_folder}/fba_libretro.so\e[m"
    elif [ -f "${_var_running_from_folder}/patches/fba_libretro.so" ]
    then
      mount --bind "${_var_running_from_folder}/patches/fba_libretro.so" /usr/lib/libretro/fba_libretro.so
      echo -e "\e[1;30mEmulating games with: ${_var_running_from_folder}/patches/fba_libretro.so\e[m"
    else
      echo -e "\n\e[1;31mThe file \"${_var_running_from_folder}/patches/fba_libretro.so\" is missing!\e[m"
      _var_countdown=10
      while [ $_var_countdown -ge 0 ]
      do
        echo -ne "\rRebooting in $_var_countdown seconds... "
        _var_countdown=$((_var_countdown - 1))
        sleep 1
      done
      echo -e "\r\e[K"
      exit 200
    fi

    # Mount our ROMs
    mount --bind "$_var_folder_with_ROMs" /usr/share/roms
  fi
else
  echo -e "\nCould not find the folder \"$_var_folder_with_ROMs\"\nThis file should be run with command \"$0\" \"Name of Games List\""
  _var_countdown=10
  while [ $_var_countdown -ge 0 ]
  do
    echo -ne "\rGoing back to Choko Menu in $_var_countdown seconds... "
    _var_countdown=$((_var_countdown - 1))
    sleep 1
  done
  echo -e "\r                                                  \r"
  exit 202
fi

#!/bin/sh
# games1I.sh - Script to reset games lists
# v12.6.0

# Simple string compare, since until 10.0.0 CHOKOVERSION wasn't set
# Future versions need to keep this in mind
if [ "$CHOKOVERSION" \< "12.6.0" ]
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

ask2reset() {
  case "${ROMSFOLDER%.txt}" in 
    # 'games??' logic from Choko Hack v11
    *games[12][A-F])
      LISTNAME="$(head -n 1 "${ROMSFOLDER}.nfo")"
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
  echo -ne "\nDo you want to reset \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[1;30mUse joystick to change answer. Waiting $COUNTDOWN seconds...\e[m "

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
        echo -ne "\r\e[1ADo you want to reset \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[m\e[K"
      ;;
      0|1|2|3|4|5|6|7)
        COUNTDOWN=0
      ;;
      *)
        if [ "$STOPCOUNT" = "N" ]
        then
          COUNTDOWN=$((COUNTDOWN - 1))
          echo -ne "\r\e[1ADo you want to reset \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[1;30mUse joystick to change answer. Waiting $COUNTDOWN seconds...\e[m "
        fi
      ;;
    esac
  done
  echo -ne "\r\e[1ADo you want to reset \"$LISTNAME\"? \e[1;93m$ANSWER \n\e[m\e[K"
  if [ "$ANSWER" = "Yes" ]
  then
    rm "$ROMSFOLDER"; WASOK=$?
    [ $WASOK -eq 0 ] && echo "List of games \"$LISTNAME\" \e[1;32mwas reset\e[m (\"$ROMSFOLDER\" was deleted)" || echo -e "\e[1;31mThere was some error deleting \"$ROMSFOLDER\".\e[m \"$LISTNAME\" was NOT reset."
  else
    echo "\"$LISTNAME\" was NOT reset."
  fi
}


# Make 'for' loops use entire lines
OIFS="$IFS"
IFS=$'\n'

# Look for installed games in CHA
echo -e "\n\nLooking for lists of games installed in CHA..."
if [ $(find /.choko -iname '*.txt' -mindepth 1 -maxdepth 1 -type f -print 2> /dev/null | wc -l) -gt 0 ]
then
  for ROMSFOLDER in $(find /.choko -iname '*.txt' -mindepth 1 -maxdepth 1 -type f -print 2> /dev/null | sort -f)
  do
    ask2reset
  done
else
  echo "There are no lists of games available (\"/.choko/*.txt\" files not found)."
fi

# Look for games in USB
echo -e "\n\nLooking for lists of games in \"$RUNNINGFROM\"..."
if [ $(find "$RUNNINGFROM" -iname '*.txt' -mindepth 1 -maxdepth 1 -type f -print 2> /dev/null | wc -l) -gt 0 ]
then
  for ROMSFOLDER in $(find "$RUNNINGFROM" -iname '*.txt' -mindepth 1 -maxdepth 1 -type f -print 2> /dev/null | sort -f)
  do
    ask2reset
  done
else
  echo "There are no lists of games available (\"${RUNNINGFROM}/*.txt\" files not found)."
fi

IFS="$OIFS"

COUNTDOWN=5
while [ $COUNTDOWN -gt 0 ]
do
  echo -ne "\rReturning to Choko Menu in $COUNTDOWN seconds... "
  COUNTDOWN=$((COUNTDOWN - 1))
  sleep 1
done
exit 202

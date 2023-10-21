#!/bin/bash

### Quick and dirty script that disables the meta key if it detects that ArmA 3 is installed
### Wrote this so that the Windows key can be used in game for ACE3 for KDE plasma.
#Tested only on Manjaro
### JJones 2023

# Copyright 2023 JJones

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



LIB="${HOME}/.steam/steam/steamapps/compatdata"
BASH_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ARMA3_ID="107410"
PROTON_VERS=""
# Check if the "compatdata" directory exists
if [ ! -d "$LIB" ]; then
    echo "Directory $LIB does not exist."
    exit 1
fi

function edit_config()
{
    local regex_string="\[ModifierOnlyShortcuts\]\s*Meta="
    local settings_file="${HOME}/.config/kwinrc"

    local text_to_add="[ModifierOnlyShortcuts]
Meta="

    if (pcregrep -Mq "$regex_string" $settings_file) ; then
        echo "Removed"
        # sed -i -E "s/$regex_string||g" "$settings_file"
        sed -i '/\[ModifierOnlyShortcuts\]/d' $settings_file
        sed -i '/Meta=/d' $settings_file
        echo "[INFO] $(date +"%Y-%m-%d %H:%M:%S") - Removed Meta Key blocking config" >> "${BASH_SCRIPT_DIR}"/run_log.txt

    else
        echo -e "$text_to_add" >> "$settings_file"
        echo "[INFO] $(date +"%Y-%m-%d %H:%M:%S") - Appended Meta Key blocking config" >> "${BASH_SCRIPT_DIR}"/run_log.txt
        echo "Appended"
    fi

    qdbus org.kde.KWin /KWin reconfigure 
    echo "[INFO] $timestamp - Reconfigured KDE" >> "${BASH_SCRIPT_DIR}"/run_log.txt
}


for appid in $(ls "${LIB}")
do
    if [ "$appid" == "$ARMA3_ID" ]; then
        PROTON_VERS=$(cat "${LIB}/${appid}/version")
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")

        echo "[INFO] Script found ArmA 3 (Steam ID: $ARMA3_ID) using Proton $PROTON_VERS at $timestamp" >> "${BASH_SCRIPT_DIR}"/run_log.txt
        edit_config
    fi
done

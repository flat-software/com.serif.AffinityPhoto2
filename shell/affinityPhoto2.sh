export WINEPATH="/app/specialwine"
export WINEPREFIX="${XDG_DATA_HOME}/prefix"

export PATH="${WINEPATH}/bin:${PATH}"
export LD_LIBRARY_PATH="${WINEPATH}/lib:${LD_LIBRARY_PATH}"

export WINESERVER="${WINEPATH}/bin/wineserver"
export WINEDLLPATH="${WINEPATH}/lib/wine"
export WINELOADER="${WINEPATH}/bin/wine"
export WINE="${WINELOADER}"
export USER="affinityuser"

export WINETRICKS_LATEST_VERSION_CHECK="disabled"
export WINEDEBUG=-all

AFFINITY_PATH="${WINEPREFIX}/drive_c/Program Files/Affinity"
AFFINITY_PHOTO_PATH="${AFFINITY_PATH}/Photo 2"
AFFINITY_PHOTO_EXE_PATH="${AFFINITY_PHOTO_PATH}/Photo.exe"

if [ ! -L "${AFFINITY_PHOTO_PATH}" ]; then
  PIPE=$(mktemp -u)
  mkfifo "$PIPE"

  setsid bash -c '
    exec > >(tee "'"$PIPE"'")
    exec 2>&1

    # Create the wine prefix.
    rm -rf "${WINEPREFIX}"
    DISPLAY= "${WINEPATH}/bin/wineboot" --init

    echo "10"

    # Symlink the winetricks cache.
    WINETRICKSCACHE_PATH=$XDG_CACHE_HOME/winetricks
    rm -rf $WINETRICKSCACHE_PATH
    ln -s /app/extra $WINETRICKSCACHE_PATH

    # Install dotnet and fonts.
    winetricks --unattended dotnet48
    echo "60"

    winetricks --unattended corefonts

    # Reset Windows version.
    "${WINEPATH}/bin/winecfg" -v win11

    # Symlink the winmd files.
    WINMETADATA_PATH=$WINEPREFIX/drive_c/windows/system32/WinMetadata
    rm -rf $WINMETADATA_PATH
    ln -s /app/extra/WinMetadata $WINMETADATA_PATH

    # Symlink the app settings.
    SETTINGS_PATH="${XDG_DATA_HOME}/settings"
    AFFINITY_SETTINGS_PATH=$WINEPREFIX/drive_c/users/affinityuser/AppData/Roaming/Affinity
    rm -rf $AFFINITY_SETTINGS_PATH
    mkdir -p $SETTINGS_PATH
    ln -s $SETTINGS_PATH $AFFINITY_SETTINGS_PATH

    # Symlink the app.
    rm -rf "'"${AFFINITY_PATH}"'"
    mkdir -p "'"${AFFINITY_PATH}"'"
    ln -s /app/affinityapp "'"${AFFINITY_PHOTO_PATH}"'"

    echo "100"
    echo "Prefix initialized!"
  ' </dev/null &
  TASK_PID=$!
  PGID=$(ps -o pgid= -p "$TASK_PID" | tr -d ' ')

  # Run zenity consuming the pipe.
  zenity --progress \
    --title="Affinity Photo 2" \
    --text="Installing components..." \
    --percentage=0 \
    --auto-close < "$PIPE" &
  ZENITY_PID=$!

  # Wait for zenity to close.
  wait $ZENITY_PID
  ZENITY_STATUS=$?

  # Clean up pipe.
  rm -f "$PIPE"

  if [[ $ZENITY_STATUS -ne 0 ]]; then
    echo "First run cancellation requested."
    kill -KILL -"$PGID" 2>/dev/null
    "${WINEPATH}/bin/wineserver" -k
    exit 1
  fi
fi

# Detect DPI.
DPI_LINE=$(xrdb -query | grep -i 'Xft.dpi')
DPI_VALUE=$(echo "$DPI_LINE" | awk '{print $2}')

if [[ -z "$DPI_VALUE" ]]; then
  DPI_VALUE=96
fi

DPI_INT=$(printf "%.0f" "$DPI_VALUE")
DPI_HEX="0x$(printf "%X" "$DPI_INT")"
wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d "$DPI_HEX" /f
echo "Setting Wine DPI to $DPI_INT $DPI_HEX"

# Run the app.
exec "${WINELOADER}" "${AFFINITY_PHOTO_EXE_PATH}" "$@"

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

first_run() {
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

  # Symlink the app.
  rm -rf "${AFFINITY_PATH}"
  mkdir -p "${AFFINITY_PATH}"
  ln -s /app/affinityapp "${AFFINITY_PHOTO_PATH}"

  echo "100"
  echo "Prefix initialized!"
}

if [ ! -L "${AFFINITY_PHOTO_PATH}" ]; then
  first_run
fi

exec "${WINELOADER}" "${AFFINITY_PHOTO_EXE_PATH}" "$@"

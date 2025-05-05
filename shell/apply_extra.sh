WINE_PREFIX="/app/extra/prefix"
WINE="/app/specialwine/bin/wine"

# Create the Wine prefix.
DISPLAY= /app/specialwine/bin/wineboot --init

# Install dotnet and fonts with winetricks.


# Set the windows version.
"$WINE" winecfg -v win11

# Install windows files.
7z x winmetadata.zip -o winmetadata
install -Dm644 winmetadata/* -t "${WINE_PREFIX}/drive_c/windows/system32/WinMetadata"

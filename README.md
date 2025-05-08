# Flatpak — Affinity Photo 2

This is a work-in-progress of Affinity Photo 2 running on Wine in a Flatpak. While it runs for the most part, it is still quite unstable and relying on it for critical work is not recommended.

## Progress

- ✅ Configure Wine prefix on first run.
- ✅ Display progress dialog on first run.
- ✅ Set DPI automatically.
- 🚫 Run on Wayland.
- 🚫 Enable OpenCL for all GPU vendors.
- 🚫 Fix empty "New" dialog.
- 🚫 Fix settings reset bug.
- 🚫 Fix export as PNG crash.

## How to build

This will build and install the Flatpak to the local machine. Having Flathub as a Flatpak remote is required to fetch dependencies.

1. Run the NodeJS download server.

```sh
cd downloadserver
npm i
npm run start
```

2. Build the flatpak (in another terminal)

```sh
flatpak-builder --user --force-clean --default-branch=stable --install-deps-from=flathub --repo=repo --install build com.serif.AffinityPhoto2.yml
```

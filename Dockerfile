FROM fedora:42

# Install dependencies.
RUN \
  dnf5 install -y alsa-lib-devel audiofile-devel autoconf bison chrpath cups-devel dbus-devel desktop-file-utils flex fontconfig-devel fontforge fontpackages-devel freeglut-devel freetype-devel gcc gettext-devel giflib-devel gnutls-devel gsm-devel gstreamer1-devel gstreamer1-plugins-base-devel icoutils libappstream-glib libgphoto2-devel libieee1284-devel libpcap-devel librsvg2 librsvg2-devel libstdc++-devel libv4l-devel libX11-devel libXcomposite-devel libXcursor-devel libXext-devel libXi-devel libXinerama-devel libXmu-devel libXrandr-devel libXrender-devel libXxf86dga-devel libXxf86vm-devel make mesa-libGL-devel mesa-libGLU-devel mesa-libOSMesa-devel mingw32-FAudio mingw32-gcc mingw32-lcms2 mingw32-libpng mingw32-libtiff mingw32-libxml2 mingw32-libxslt	 mingw32-vkd3d mingw32-vulkan-headers mingw64-FAudio mingw64-gcc mingw64-lcms2 mingw64-libpng mingw64-libtiff mingw64-libxml2 mingw64-libxslt mingw64-vkd3d mingw64-vulkan-headers mingw64-zlib mpg123-devel ocl-icd-devel opencl-headers openldap-devel perl-generators pulseaudio-libs-devel sane-backends-devel SDL2-devel systemd-devel unixODBC-devel vulkan-devel wine-mono libxkbcommon-devel awk git winetricks && \
  dnf5 clean all

# Build custom Wine.
RUN \
  git clone https://gitlab.winehq.org/ElementalWarrior/wine.git wine && \
  cd wine && \
  git switch --detach a0b5474d0e000a5cd7aebb730abebbd142690e39

RUN \
  mkdir winewow64-build && \
  cd winewow64-build && \
  ../wine/configure --prefix="/opt/wines/wine" --enable-archs=i386,x86_64 CFLAGS="-std=gnu18"

RUN cd winewow64-build && make --jobs=16
RUN cd winewow64-build && make install --jobs=16
# RUN ln -s /opt/wines/wine/bin/wine /opt/wines/wine/bin/wine64

# Add RUM.
RUN \
  git clone https://gitlab.com/xkero/rum && \
  cp rum/rum /usr/local/bin/rum && \
  chmod +x /usr/local/bin/rum

ENV XDG_CACHE_HOME=/wineprefix/cache

CMD ["sh"]

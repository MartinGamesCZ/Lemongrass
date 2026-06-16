# syntax=docker/dockerfile:1
FROM fedora:42

ARG W_USERNAME=lemongrass
ARG W_PASSWORD=lemonade

ENV HOME=/home/${W_USERNAME}
ENV DISPLAY=:1
ENV VNC_RESOLUTION=1920x1080
ENV VNC_COL_DEPTH=24
ENV APPIMAGE_EXTRACT_AND_RUN=1

WORKDIR /home/${W_USERNAME}

RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf -y --setopt=keepcache=True update && \
    dnf -y --setopt=keepcache=True install \
        gnome-shell \
        gnome-session \
        #mutter \
        #nautilus \
        gnome-session-xsession \
        gsettings-desktop-schemas \
        dbus-x11 \
        #at-spi2-core \
        mesa-dri-drivers \
        #xdotool \
        #wget \
        #which \
        #python3-gobject \
        tigervnc-server \
        fuse-libs \
        systemd \
        sudo

RUN mkdir -p /etc/systemd && \
    echo -e "[Journal]\nStorage=volatile\nReadKMsg=no" > /etc/systemd/journald.conf

RUN useradd -u 1000 -g 0 -m -d /home/${W_USERNAME} ${W_USERNAME} && \
    usermod -aG wheel ${W_USERNAME} && \
    echo "${W_PASSWORD}" | passwd --stdin ${W_USERNAME}

RUN mkdir -p /etc/systemd/system/dbus-broker.service.d && \
    echo -e "[Service]\nExecStart=\nExecStart=/usr/bin/dbus-broker-launch --scope system" > /etc/systemd/system/dbus-broker.service.d/override.conf

RUN echo ":1=${W_USERNAME}" > /etc/tigervnc/vncserver.users && \
    echo -e "session=gnome\ngeometry=${VNC_RESOLUTION}\nlocalhost=no" > /etc/tigervnc/vncserver-config-defaults

RUN mkdir -p /home/${W_USERNAME}/.vnc && \
    echo "${W_PASSWORD}" | vncpasswd -f > /home/${W_USERNAME}/.vnc/passwd && \
    chmod 700 /home/${W_USERNAME}/.vnc && \
    chmod 600 /home/${W_USERNAME}/.vnc/passwd && \
    chown -R 1000:0 /home/${W_USERNAME}

RUN systemctl enable vncserver@:1.service

COPY wallpaper.jpg /usr/share/backgrounds/wallpaper.jpg

RUN echo -e "[org.gnome.desktop.background]\npicture-uri='file:///usr/share/backgrounds/wallpaper.jpg'\npicture-uri-dark='file:///usr/share/backgrounds/wallpaper.jpg'" > /usr/share/glib-2.0/schemas/10_local-wallpaper.gschema.override && \
    glib-compile-schemas /usr/share/glib-2.0/schemas/

EXPOSE 5901

CMD ["/sbin/init"]
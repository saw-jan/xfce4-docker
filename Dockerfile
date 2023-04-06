FROM fedora:37

RUN yum install -y \
    wget \
    hostname \
    # perl \
    dbus-x11 \
    openssl-devel \
    # xorg-x11-server-Xorg \
    xorg-x11-xauth \
    xorg-x11-xinit \
    # xdg-utils \
    # cleanup
    && yum autoremove -y \
    && yum clean all

RUN yum install -y \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xfce4-terminal \
    xfconf \
    xfdesktop \
    xfwm4 \
    && yum autoremove -y \
    && yum clean all

### Bintray has been deprecated and disabled since 2021-05-01
RUN wget -qO- https://sourceforge.net/projects/tigervnc/files/stable/1.10.1/tigervnc-1.10.1.x86_64.tar.gz/download | tar xz --strip 1 -C /

ENV \
    DISPLAY=:1 \
    HOME=/home/headless \
    STARTUPDIR=/dockerstartup \
    VNC_BLACKLIST_THRESHOLD=20 \
    VNC_BLACKLIST_TIMEOUT=0 \
    VNC_COL_DEPTH=24 \
    VNC_PORT="5901" \
    VNC_PW=secret \
    VNC_RESOLUTION=1360x768 \
    VNC_VIEW_ONLY=false

WORKDIR ${HOME}
SHELL ["/bin/bash", "-c"]

COPY [ "./startup", "${STARTUPDIR}/" ]

RUN chmod 664 /etc/passwd /etc/group \
    && echo "headless:x:1001:0:Default:${HOME}:/bin/bash" >> /etc/passwd \
    && echo "headless:x:1001:" >> /etc/group \
    && echo "headless:${VNC_PW}" | chpasswd \
    && chmod +x \
    "${STARTUPDIR}/vnc_startup.sh" \
    "${STARTUPDIR}/entrypoint.sh"

ENTRYPOINT [ "/dockerstartup/entrypoint.sh" ]
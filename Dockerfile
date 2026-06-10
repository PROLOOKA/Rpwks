FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server \
    novnc websockify \
    sudo xterm \
    systemd snapd \
    vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    software-properties-common

RUN add-apt-repository ppa:mozillateam/ppa -y

RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox

RUN apt update -y && apt install -y \
    firefox \
    xubuntu-icon-theme \
    obs-studio

RUN apt clean && rm -rf /var/lib/apt/lists/*

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD bash -c 'vncserver -localhost no -SecurityTypes None -geometry 1280x720 :1 && \
openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
tail -f /dev/null'

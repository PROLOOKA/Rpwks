FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    software-properties-common \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    firefox \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    xterm \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:obsproject/obs-studio -y && \
    apt-get update && \
    apt-get install -y obs-studio && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd

RUN echo "root:lookmora" | chpasswd

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

RUN mkdir -p /root/.vnc

RUN echo '#!/bin/bash' > /root/.vnc/xstartup && \
    echo 'xrdb $HOME/.Xresources' >> /root/.vnc/xstartup && \
    echo 'startxfce4 &' >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

RUN touch /root/.Xauthority

EXPOSE 22
EXPOSE 5901
EXPOSE 6080

CMD bash -c '\
service ssh start && \
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 && \
websockify --web=/usr/share/novnc/ 6080 localhost:5901 & \
tail -f /dev/null'

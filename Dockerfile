FROM ghcr.io/linuxserver/baseimage-ubuntu:noble
LABEL maintainer="Julio Gutierrez julio.guti+nordvpn@pm.me"

ARG NORDVPN_VERSION=4.1.1
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
  apt-get install -y curl iputils-ping libc6 wireguard && \
  curl https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn-release/nordvpn-release_1.0.0_all.deb --output /tmp/nordrepo.deb && \
  apt-get install -y /tmp/nordrepo.deb && \
  apt-get install -y cron vim gawk socat && \
  apt-get update -y && \
  apt-get install -y nordvpn${NORDVPN_VERSION:+=$NORDVPN_VERSION} && \
  apt-get remove -y nordvpn-release && \
  apt-get autoremove -y && \
  apt-get autoclean -y && \
  rm -rf \
  /tmp/* \
  /var/cache/apt/archives/* \
  /var/lib/apt/lists/* \
  /var/tmp/*

COPY /rootfs /
RUN chmod +x /usr/bin/nord_* || true
RUN chmod +x /root/rotate_ip.sh

ENV S6_CMD_WAIT_FOR_SERVICES=0
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=0

CMD /etc/init.d/nordvpn start && su - root -c "socat -u tcp-l:7777,fork system:/root/rotate_ip.sh" & nord_login && nord_config && nord_connect && nord_migrate && nord_watch

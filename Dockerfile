FROM cm2network/steamcmd:root
LABEL maintainer="thijs@loef.dev"

  # added NFS support 
RUN apt-get update && apt-get install -y --no-install-recommends \
    xdg-user-dirs=0.17-2 \
    procps=2:3.3.17-5 \
    nfs-common \
    wget=1.21-1+deb11u1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget -q https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz -O - | tar -xz && \
    mv rcon-0.10.3-amd64_linux/rcon /usr/bin/rcon-cli && \
    rmdir /tmp/dumps

# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b

RUN wget -q "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

ENV PORT= \
    PUID=1000 \
    PGID=1000 \
    PLAYERS=16 \
    MULTITHREADING=true \
    COMMUNITY=false \
    PUBLIC_IP= \
    PUBLIC_PORT= \
    SERVER_PASSWORD="yourpassword" \
    SERVER_NAME="Your server name"\
    ADMIN_PASSWORD="put a pw here or you can't use admin commands" \
    UPDATE_ON_BOOT=true \
    RCON_ENABLED=true \
    RCON_PORT=25575 \
    QUERY_PORT=27015 \
    TZ=UTC \
    SERVER_DESCRIPTION="All your base are belong to us !" \
    BACKUP_ENABLED=true \
    BACKUP_CRON_EXPRESSION="0 0 * * *"

COPY ./scripts/* /home/steam/server/
RUN chmod +x /home/steam/server/init.sh /home/steam/server/start.sh /home/steam/server/backup.sh && \
    mv /home/steam/server/backup.sh /usr/local/bin/backup

WORKDIR /home/steam/server

HEALTHCHECK --start-period=5m \
    CMD pgrep "PalServer-Linux" > /dev/null || exit 1

EXPOSE ${PORT} ${RCON_PORT}
ENTRYPOINT ["/home/steam/server/init.sh"]

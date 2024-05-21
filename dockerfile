FROM golang:1.22.3-alpine3.19 as build_runner
WORKDIR /build
RUN apk --update add git
RUN git clone https://github.com/itzg/mc-server-runner.git
WORKDIR /build/mc-server-runner
RUN go build


FROM adoptopenjdk/openjdk8:alpine-jre AS build_mc
WORKDIR /build
RUN apk --update add openssl wget unzip
RUN wget http://dist.creeper.host/FTB2/modpacks/Regrowth/1_0_2/RegrowthServer.zip 
RUN unzip RegrowthServer.zip -d app

# Add log4j Fix
RUN wget https://github.com/CreeperHost/Log4jPatcher/releases/download/v1.0.1/Log4jPatcher-1.0.1.jar

# Clean up
WORKDIR /build/app
RUN rm ServerStart.sh
RUN rm ServerStart.bat

# Add FTBUtils
WORKDIR /build/app/mod
RUN wget https://mediafilez.forgecdn.net/files/2291/494/FTBUtilities-1.7.10-1.0.18.3.jar
RUN wget https://mediafilez.forgecdn.net/files/2291/433/FTBLib-1.7.10-1.0.18.3.jar

# Add FastLeafDecay
RUN wget https://mediafilez.forgecdn.net/files/2272/838/FastLeafDecay-1.7.10-1.4.jar

# Add Inventory Tweaks
RUN wget https://mediafilez.forgecdn.net/files/2210/792/InventoryTweaks-1.59-dev-152.jar


FROM adoptopenjdk/openjdk8:alpine-jre
WORKDIR /app

COPY --from=build_mc /build/app /app
COPY --from=build_runner /build/mc-server-runner/mc-server-runner /app/mc-server-runner
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Move all instance specific files to /data
ADD config-files /data/config

RUN mkdir --parents /data/world
RUN mkdir --parents /data/config
RUN mkdir --parents /logs
RUN mkdir /data/backups

RUN mv config /data/config/config

# Symlink everything
RUN ln -sf /data/world /app/world
RUN ln -sf /data/config/config /app/config
RUN ln -sf /logs /app/logs
RUN ln -sf /data/backups backups

RUN ln -sf /data/config/banned-ips.json banned-ips.json
RUN ln -sf /data/config/banned-players.json banned-players.json
RUN ln -sf /data/config/ops.json ops.json
RUN ln -sf /data/config/server.properties server.properties
RUN ln -sf /data/config/whitelist.json whitelist.json

ENV ACCEPT_EULA=false
STOPSIGNAL SIGTERM
CMD ["/app/start.sh"]
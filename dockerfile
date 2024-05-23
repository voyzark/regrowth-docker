FROM golang:1.22.3-alpine3.19 as build_runner
WORKDIR /build
RUN apk --update add git
RUN git clone https://github.com/itzg/mc-server-runner.git
WORKDIR /build/mc-server-runner
RUN go build


FROM adoptopenjdk/openjdk8:alpine-jre AS build_mc
ARG add_custom_mods
WORKDIR /build
RUN apk --update add openssl wget unzip
RUN wget http://dist.creeper.host/FTB2/modpacks/Regrowth/1_0_2/RegrowthServer.zip 
RUN unzip RegrowthServer.zip -d app

# Add log4j Fix
WORKDIR /build/app
RUN wget https://github.com/CreeperHost/Log4jPatcher/releases/download/v1.0.1/Log4jPatcher-1.0.1.jar

# Clean up
RUN rm ServerStart.sh
RUN rm ServerStart.bat

# Add FTBUtils & Dependencies
WORKDIR /build/app/mods
RUN if [[ -n "$add_custom_mods" ]] ; then wget https://mediafilez.forgecdn.net/files/2291/494/FTBUtilities-1.7.10-1.0.18.3.jar ; fi
RUN if [[ -n "$add_custom_mods" ]] ; then wget https://mediafilez.forgecdn.net/files/2291/433/FTBLib-1.7.10-1.0.18.3.jar ; fi

# Add Admin Commands Toolbox
RUN if [[ -n "$add_custom_mods" ]] ; then wget https://mediafilez.forgecdn.net/files/2212/871/AdminCommandsToolbox-0.0.2a_1.7.10.jar ; fi

# Add FastLeafDecay
RUN if [[ -n "$add_custom_mods" ]] ; then wget https://mediafilez.forgecdn.net/files/2272/838/FastLeafDecay-1.7.10-1.4.jar ; fi

# Add Inventory Tweaks ( this should always be added, or client side Inventorytweaks may break as well )
RUN wget https://mediafilez.forgecdn.net/files/2210/792/InventoryTweaks-1.59-dev-152.jar


FROM adoptopenjdk/openjdk8:alpine-jre
WORKDIR /app

COPY --from=build_mc /build/app /app
COPY --from=build_runner /build/mc-server-runner/mc-server-runner /app/mc-server-runner
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Move all instance specific files to /data
ADD data/config-files /data/config
ADD data/ftbu/local /app/local

RUN ln -sf /data/config/banned-ips.json banned-ips.json
RUN ln -sf /data/config/banned-players.json banned-players.json
RUN ln -sf /data/config/ops.json ops.json
RUN ln -sf /data/config/server.properties server.properties
RUN ln -sf /data/config/whitelist.json whitelist.json

ENV ACCEPT_EULA=false
STOPSIGNAL SIGTERM
ENTRYPOINT ["/app/start.sh"]
#!/bin/sh

cat <<EOF > /app/eula.txt
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
#Fri May 10 09:42:09 CEST 2024
eula=$ACCEPT_EULA
EOF
exec ./mc-server-runner java -Xms2048m -Xmx4096m -jar forge-1.7.10-10.13.4.1614-1.7.10-universal.jar -javaagent:Log4jPatcher.jar nogui
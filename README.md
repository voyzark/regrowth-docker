# regrowth-docker
My personal docker image of the minecraft regrowth modpack

# Quickstart
The image I am running on my personal server is built with the following additional mods:
 - FTBUtilities 1.7.10-1.0.18.3
 - FTBLib 1.7.10-1.0.18.3
 - FastLeafDecay 1.7.10-1.4
 - Chunk-Pregenerator 1.7.10-4.4.5

To run it, use the following command:
```bash
docker run \
 -e ACCEPT_EULA=true \
 -it \
 -d \
 -p 25565:25565/tcp \
 -v regrowth_config:/config \
 -v regrowth_world:/app/world \
 --restart=always \
 --name regrowth \
 ghcr.io/voyzark/regrowth:latest-custom
```
Note: By providing the environment argument ACCEPT_EULA=true you are agreeing to the minecraft EULA: https://www.minecraft.net/en-us/eula


There is also a "vanilla" image with the unaltered modlist, that can be run using the tag ghcr.io/voyzark/regrowth:latest e.g.
```bash
docker run \
 -e ACCEPT_EULA=true \
 -it \
 -d \
 -p 25565:25565/tcp \
 -v regrowth_config:/config \
 -v regrowth_world:/app/world \
 --restart=always \
 --name regrowth \
 ghcr.io/voyzark/regrowth:latest
```

Note:
Both images include Log4jPatcher for security reasons: https://github.com/CreeperHost/Log4jPatcher
Both images have added InventoryTweaks to the serverside modlist. This mod is already present on the client side and needs to be included on the server as well or it sometimes won't work properly.
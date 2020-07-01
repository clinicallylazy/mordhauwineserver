# Mordhau-Wine

When hosting a dedicated Linux server with custom created Mordhau maps it is necessary for the creator to "cook" their assets for Linux. This however rarely gets done, resulting in an unplayable map where you can clip through non-native Mordhau object (like the floor in ffa_aoc_siege) when hosting these maps with the official Linux dedicated server. Map makers do however always "cook" their assets for Windows, so the Windows server does not have any problem.

To fix the "cook" issue I created a docker container with a Windows dedicated Mordhau server running with Wine to allow for custom maps to be hosted on the Linux platform.

## Getting started

The image is super easy to use. All you need to do is mount the volume `/config`. Redirect some ports and optionally change the default ports.

**Run-time requirements**
- `docker run -it ...` (or `tty: true` for docker-compose), because the server need an active output or it will hang.
- `docker run --cap-add CAP_NET_ADMIN ...` (or `cap_add: CAP_NET_ADMIN` for docker-compose), or a sub-process will fail.

**Volumes**
- `/mordhau`, this is where the Windows server (and mods) is located, can optionally be mounted if you don't want to re-download the server for each container. Don't change the config in this location. They are not loaded.
- `/config`, `Game.ini` and `Engine.ini` are located here, mount to your favorite place.
- `/home/steam/steamcmd`, this is where steamCMD is located, used to keep the server files up-to date. No need to touch them.

**Ports**
- `7777/udp`, default Mordhau game port
- `27015/udp`, default Mordau query port
- `15000/tcp`, default Mordhau beacon port

**Environments**
- `Port`, change the default game port
- `QueryPort`, change the default query port
- `BeaconPort`, change the default beacon port

## Example

**Docker run**

`docker run -it -v ./my-server-dir:/mordhau:z -v ./my-config-dir:/config:z --name mordhau -p 7777:7777/udp -p 27015:27015/udp -p 15000:15000/udp --cap-add CAP_NET_ADMIN noeel/mordhau-wine`

**Docker Compose**
```
version: '3.7'

services:
  mordhau-wine:
    restart: unless-stopped
    container_name: mordhau
    image: noeel/mordhau-wine
    volumes:
      - ./my-server-dir:/mordhau # optional, but nice
      - ./my-config-dir:/config
    ports:
      - "7777:7777/udp"
      - "27015:27015/udp"
      - "15000:15000/udp"
    tty: true
    environment:
      #- Port=7777
      #- QueryPort=27015
      #- BeaconPort=15000
    cap_add:
      - CAP_NET_ADMIN
```

## Reference
- [Github](https://github.com/NoeelMoeskops/Mordhau-Wine)
- [Dockerhub](https://hub.docker.com/r/noeel/mordhau-wine)

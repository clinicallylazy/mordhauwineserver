# Mordhau-Wine

When hosting a dedicated Linux server with custom created Mordhau maps it is necessary for the creator to "cook" their assets for Linux. This however rarely gets done, resulting in an unplayable map where you can clip through non-native Mordhau object (like the floor in ffa_aoc_siege) when hosting these maps with the official Linux dedicated server. Mapmakers do however always "cook" their assets for Windows, so the Windows server does not have any problem.

To fix the "cook" issue I created a Docker container with a Windows dedicated Mordhau server running with Wine to allow for custom maps to be hosted on the Linux platform.

## Getting started

The image is super easy to use. All you need to do is mount the volume `/config`. Redirect some ports, and give the container some permissions. If you are unfamiliar with Docker, scoll down to the *tutorial* section.
Every time the container starts it checks with steam if the installed Mordhau server is installed, up-to-date and valid. And will automatically download files if necessary. 

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
- `15000/udp`, default Mordhau beacon port

**Environments**
- `Port`, change the default game port
- `QueryPort`, change the default query port
- `BeaconPort`, change the default beacon port

## Example

**Docker run**

`docker run -it -v ./mordhau/server:/mordhau:z -v ./mordhau/config:/config:z --name mordhau -p 7777:7777/udp -p 27015:27015/udp -p 15000:15000/udp --cap-add CAP_NET_ADMIN noeel/mordhau-wine`

**Docker Compose**
```
version: '3.7'

services:
  mordhauwineserver:
    restart: unless-stopped
    container_name: mordhau
    image: clinicallylazy/mordhauwineserver
    volumes:
      - ./mordhau/server:/mordhau # optional, but nice
      - ./mordhau/config:/config
    ports:
      - "7777:7777/udp"
      - "27015:27015/udp"
      - "15000:15000/udp"
    tty: true
    #environment:
      #- Port=7777
      #- QueryPort=27015
      #- BeaconPort=15000
    cap_add:
      - CAP_NET_ADMIN
```

## Tutorial

1. [Download and install Docker for your system](https://docs.docker.com/engine/install/)
2. Make sure you have sufficient permissions to access docker with your account (`sudo usermod -aG docker ${USER}`) and that the daemon is running.
3. [Download and install Docker Compose](https://docs.docker.com/compose/install/)
4. create a `docker-compose.yml` file with the contents from **Example** and adjust to your liking
5. create folder `./mordhau/config` and `./mordhau/server`
6. adjust owner to mordhau-wine owner (default container user is 1000:1000, can be adjusted with `user: x:x` flag) `chown 1000:1000 ./mordhau -R`
7. execute `docker-compose up -d` in the same folder as `docker-compose.yml`, docker will install the image and create the container as specified in `docker-compose.yml`. Everytime you make adjustments to the service in the compose file you need to stop the container (`docker stop mordhau`), delete it (`docker rm mordhau`). And re-run `docker-compose up -d`
8. Wait for steamCMD to download the Mordhau binary's and for the Mordhau server to generate `Game.ini` and `Engine.ini` files. Watch the container using `docker logs -f mordhau` Press Ctrl-C to exit log.
9. adjust `./mordhau/config/Game.ini` and `./mordhau/config/Engine.ini` to your liking and restart the server afterwards with `docker restart mordhau`. The generated files are quite large, the relevant config are at the bottom of `Game.ini`
10. Join your server and enjoy!

## Reference
- [Github](https://github.com/NoeelMoeskops/Mordhau-Wine)
- [Dockerhub](https://hub.docker.com/r/noeel/mordhau-wine)

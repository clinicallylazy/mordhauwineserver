Borrowed heavily from u/noeel and his wine container, after patch 21 his container no longer works (and doesn't have Rcon support) so I've created this updated container to help out.

# Mordhau-Wine

When hosting a dedicated Linux server with custom created Mordhau maps it is necessary for the creator to "cook" their assets for Linux. This however rarely gets done, resulting in an unplayable map where you can clip through non-native Mordhau object (like the floor in ffa_aoc_siege) when hosting these maps with the official Linux dedicated server. Mapmakers do however always "cook" their assets for Windows, so the Windows server does not have any problem.

This Docker container is a bit of a workaround for this issue, with a Windows dedicated Mordhau server running with Wine to allow for custom maps to be hosted on the Linux platform.

## Getting started

The image is super easy to use. For detailed setup instructions view below, it's the method I manage/deploy new servers on my own and has been tested on Ubuntu 18.04. Every time the container starts it checks with steam if the installed Mordhau server is installed, up-to-date and valid. And will automatically download files if necessary. 

**Run-time requirements**
- `docker run -it ...` (or `tty: true` for docker-compose), because the server need an active output or it will hang.
- `docker run --cap-add CAP_NET_ADMIN ...` (or `cap_add: CAP_NET_ADMIN` for docker-compose), or a sub-process will fail.

**Ports**
- `45000/udp`, configured Mordhau game port
- `45001/udp`, configured Mordau rcon/query port
- `45002/udp`, configured Mordhau beacon port

**Environments**
- `Port`, change the default game port
- `RconPort`, change the default Rcon port
- `BeaconPort`, change the default beacon port

## Example

**Docker Compose**
```
version: '3.7'

services:
  mordhauwineserver:
    restart: unless-stopped
    container_name: mordhau-wine
    image: clinicallylazy/mordhauwineserver:latest
    ports:
      - "45000:45000/udp" #default: 7777
      - "45001:45001/udp" #default: 27015
      - "45002:45002/udp" #default: 15000
    tty: true
    environment:
	# ensure that these ports match the ports above
      - Port=45000 #default: 7777
      - RconPort=45001 #default: 27015
      - BeaconPort=45002 #default: 15000
    cap_add:
      - CAP_NET_ADMIN
```

## Tutorial

1. [Download and install Docker for your system](https://docs.docker.com/engine/install/)
2. Make sure you have sufficient permissions to access docker with your account (`sudo usermod -aG docker ${USER}`) and that the daemon is running.
3. [Download and install Docker Compose](https://docs.docker.com/compose/install/)
4. Set up your management folder:
```
sudo su - {docker user}
cd ~
mkdir mordhau-wine
chown steam:steam ./mordhau-wine -R
cd mordhau-wine
```
5. create a `docker-compose.yml` file with the contents from **Example** and adjust to your liking
6. execute `docker-compose up -d` in the same folder as `docker-compose.yml`, docker will install the image and create the container as specified in `docker-compose.yml`. Everytime you make adjustments to the service in the compose file you need to stop the container (`docker stop mordhau-wine`), delete it (`docker rm mordhau-wine`). And re-run `docker-compose up -d`
7. Wait for steamCMD to download the Mordhau binary's and for the Mordhau server to generate `Game.ini` and `Engine.ini` files. Watch the container using `docker logs -f mordhau` Press Ctrl-C to exit log.
8. Stop the docker container, symlink the most useful files into the local directory:
```
container=mordhau-wine; install_path=$(docker inspect $container | grep Merged | awk '{print $2}' | tr -d '",'); ln -s $install_path/home/steam/mordhau/Mordhau/Saved/Config/WindowsServer/Game.ini ./Game.ini
container=mordhau-wine; install_path=$(docker inspect $container | grep Merged | awk '{print $2}' | tr -d '",'); ln -s $install_path/home/steam/mordhau/Mordhau/Saved/Config/WindowsServer/Engine.ini ./Engine.ini
container=mordhau-wine; install_path=$(docker inspect $container | grep Merged | awk '{print $2}' | tr -d '",'); ln -s $install_path/home/steam/mordhau/Mordhau/Saved/Logs/Mordhau.log ./Mordhau.log
```
**Note:** Ensure that the `container=mordhau-wine` section of the above matches the container name if you are renaming the container or deploying multiple instances. You can essentially find/replace everything from the instructions and just replace mordhau-wine with the preferred container name if you wish to do this.
9. Update your Game.ini and Engine.ini files to your preferred settings. An example of an update you may want to do is increase the tick rate of your server in Engine.ini, for example adding these lines to the beginning of the config:
```
[/Script/OnlineSubsystemUtils.IpNetDriver]
NetServerMaxTickRate=120
```
10. Restart the docker container with `docker start mordhau-wine` and monitor the logs via `tail -f Mordhau.log` -- once you see the server up with your updated settings, you're able to join. Enjoy!

## Hosting Multiple Instances On One Server

This is actually pretty easy, as mentioned previously in the instructions you can essentially find/replace everything listed here labeled `mordhau-wine` and replace it with your own container name, and change the ports that are being used as it will not work with duplicated ports. Here's an example of a docker compose file with an updated container name and ports:
```
version: '3.7'

services:
  mordhauwineserver:
    restart: unless-stopped
    container_name: secondmordhauserver
    image: clinicallylazy/mordhauwineserver:latest
    ports:
      - "48123:48123/udp" #default: 7777
      - "48124:48124/udp" #default: 27015
      - "48125:48125/udp" #default: 15000
    tty: true
    environment:
	# ensure that these ports match the ports above
      - Port=48123 #default: 7777
      - RconPort=48124 #default: 27015
      - BeaconPort=48125 #default: 15000
    cap_add:
      - CAP_NET_ADMIN
```

## Reference
- [Github](https://github.com/clinicallylazy/mordhauwineserver)
- [Dockerhub](https://hub.docker.com/r/clinicallylazy/mordhauwineserver)

FROM cm2network/steamcmd

LABEL maintainer="noeelmoeskops@Hotmail.com"
USER root

# add wine repo
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install wget gnupg2 -y
RUN wget -nc https://dl.winehq.org/wine-builds/winehq.key && apt-key add winehq.key
RUN echo "deb https://dl.winehq.org/wine-builds/debian/ buster main" >> /etc/apt/sources.list

# install libfaudio
RUN wget https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/amd64/libfaudio0_20.01-0~buster_amd64.deb && apt-get install ./libfaudio0_20.01-0~buster_amd64.deb -y
RUN wget https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/i386/libfaudio0_20.01-0~buster_i386.deb && apt-get install ./libfaudio0_20.01-0~buster_i386.deb -y

# install wine
RUN apt-get update && apt-get install winehq-devel -y

# install and start mordhau
ENV SteamID 629800
ENV MordhauDIR /mordhau
ENV Port 7777
ENV QueryPort 27015
ENV BeaconPort 15000
ENV ConfigDIR /config

RUN mkdir $MordhauDIR
RUN chown steam:steam $MordhauDIR -R

EXPOSE ${QueryPort}/udp ${BeaconPort}/tcp ${Port}/udp
USER steam

VOLUME $MordhauDIR
VOLUME $ConfigDIR 

ENTRYPOINT ${STEAMCMDDIR}/steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +force_install_dir ${MordhauDIR} +app_update ${SteamID} +quit && wine ${MordhauDIR}/MordhauServer.exe -log -Port=${Port} -QueryPort=${QueryPort} -Beaconport=${BeaconPort} -RconPort=${QueryPort} -GAMEINI=${ConfigDIR}/Game.ini -ENGINEINI=${ConfigDIR}/Engine.ini


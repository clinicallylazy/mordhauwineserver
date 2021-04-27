FROM quay.io/dominator/mordhau-wine

LABEL maintainer="help@mordhau.com"

USER root
ENV SteamID 629800
ENV MordhauDIR /mordhau
ENV Port 7777
ENV RconPort 27015
ENV BeaconPort 15000
ENV ConfigDIR /config

RUN mkdir $MordhauDIR
RUN chown steam:steam $MordhauDIR -R

EXPOSE ${RconPort}/udp
EXPOSE ${BeaconPort}/tcp 
EXPOSE ${Port}/udp
USER steam

VOLUME $MordhauDIR
VOLUME $ConfigDIR 

ENTRYPOINT steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +force_install_dir ${MordhauDIR} +app_update ${SteamID} +quit && WINEDEBUG=-all wine ${MordhauDIR}/MordhauServer.exe -log -Port=${Port} -RconPort=${RconPort} -BeaconPort=${BeaconPort} -GAMEINI=${ConfigDIR}/Game.ini -ENGINEINI=${ConfigDIR}/Engine.ini

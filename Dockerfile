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

EXPOSE ${RconPort}/udp ${BeaconPort}/tcp ${Port}/udp
USER steam

VOLUME $MordhauDIR
VOLUME $ConfigDIR 

ENTRYPOINT steamcmd/steamcmd.sh +login anonymous +@sSteamCmdForcePlatformType windows +force_install_dir ~/mordhau +app_update 629800 validate +quit && WINEDEBUG=-all wine mordhau/MordhauServer.exe -log -Port=${Port} -RconPort=${RconPort} -BeaconPort=${BeaconPort}

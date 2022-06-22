FROM ubuntu:20.04
STOPSIGNAL SIGHUP
VOLUME /spigot-data
EXPOSE 25565
EXPOSE 25575
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y sudo openjdk-17-jre
COPY startup.sh /a/
RUN useradd -m -u 10000 --groups sudo spigot && echo "spigot:foobarrunner" | chpasswd && echo "spigot ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R spigot.spigot /spigot-data
USER spigot
ENTRYPOINT /a/startup.sh


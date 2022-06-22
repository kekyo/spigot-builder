#!/bin/sh

sudo apt-get update
sudo apt-get upgrade -y

sudo chown -R spigot.spigot /spigot-data
cd /spigot-data

if [ ! -f ./spigot-${SPIGOT_VERSION}.jar ]; then
  sudo apt-get install -y curl git openjdk-17-jdk
  rm -rf stage-${SPIGOT_VERSION}
  mkdir stage-${SPIGOT_VERSION}
  cd stage-${SPIGOT_VERSION}
  curl --output BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
  java -jar BuildTools.jar --rev ${SPIGOT_VERSION}
  cd ..
  cp stage-${SPIGOT_VERSION}/spigot-${SPIGOT_VERSION}.jar .
  rm -rf stage-${SPIGOT_VERSION}
fi

if [ ! -d ./run ]; then
  mkdir run
fi

cd run
java -Xms2048M -Xmx8192M -jar ../spigot-${SPIGOT_VERSION}.jar nogui


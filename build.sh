#!/bin/sh

sudo apt install openjdk-17-jdk

rm -rf stage
mkdir stage
cd stage

curl --output BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

java -jar BuildTools.jar --rev 1.18.1

cd ..
cp stage/spigot-*.jar .

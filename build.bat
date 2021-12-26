@echo off

rmdir /s/q stage
mkdir stage
cd stage

curl --output openjdk.zip https://download.java.net/java/GA/jdk17.0.1/2a2082e5a09d4267845be086888add4f/12/GPL/openjdk-17.0.1_windows-x64_bin.zip
curl --output BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

..\unzip openjdk.zip
jdk-17.0.1\bin\java -jar BuildTools.jar --rev 1.18.1

cd ..
copy stage\spigot-*.jar .

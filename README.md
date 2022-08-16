# Automatic minecraft spigot builder and runner on podman (docker).

[docker.io kekyo/spigot_runner](https://hub.docker.com/repository/docker/kekyo/spigot_runner)

[For japanese](README_ja.md)

This is a script to set up a fully automatic spigot server using podman (docker).

* This is a script to set up a spigot server fully automatically using podman (docker).
* [spigot]() is an extension of minecraft server, a so-called "mod". By applying community-developed mods to it, various extensions can be added to the server.
* The spigot itself is made by modifying the stock minecraft server. Therefore, you should not be allowed to distribute spigot binaries as is.
* Therefore, spigot consists of `BuildTools`, which automatically modifies the stock minecraft server.
* With the `BuildTools`, you can generate spigot from the stock minecraft server. However, this process is complicated (though not complicated).
* So, using the scripts in this repository, you can fully automate the creation and execution of spigot using Docker containers.
* This repository assumes that the container system is podman; Docker is of course fine and should work just by changing `podman` to `docker` in the script, but we have not tested it.

----

## How to use

We have only confirmed that it works on Ubuntu 22.04.

Install podman beforehand as follows:

```bash
# Install git and podman
$ sudo apt install git podman
```

If you want to use podman with GUI, you should also install cockpit:

```bash
# install git podman including cockpit
$ sudo apt install git podman cockpit cockpit-podman
```

----

### Create spigot (minecraft) data directory

Next, create a data directory to store the game world data. The location can be anywhere, and you can name it anything you like:

```bash
# create data directory
$ mkdir data

# Check absolute paths
$ echo `pwd`/data
/storage0/data
```

Now you are ready.

----

### Running spigot (first time)

To run the Docker container, you will need the following information:

* The version of spigot (corresponds to the version of minecraft. For example, a number like `1.18.1`)
* The location of the spigot data directory (created above. You need the absolute path)
* The port number that spigot exposes for connection (default is 25565)

Now, run :

```bash
sudo podman run -it -e SPIGOT_VERSION=1.18.1 -e SPIGOT_OPTIONS=-Xms2048M -v /storage0/data:/spigot-data -p 25565:25565 docker.io/kekyo/spigot_runner
```

* `--name` is the name you give to the Docker container. If omitted, a suitable (and rather strange) name is automatically given.
* With `-it`, you can perform console operations.
* `-e SPIGOT_VERSION=<version>` specifies the version of spigot.
* `-v <data directory>:/spigot-data` specifies the location of the data directory. The latter `:/spigot-data` is fixed. Specify as follows.
* `-p <port>:25565` is the port number to be published. The latter half of `:25565` is also fixed. Please specify as shown.
* `-e SPIGOT_OPTIONS=<options>` is a command line option for java. `-Xms2048M` allocates at least 2GB of memory.

For the first run, there are the following points :

* spigot will be built. This takes quite a while, and the work will occur at the level of a few minutes even on a fast machine.
  During this time, you will see incomprehensible logs on the console, but please be patient.
* Once the build is complete, spigot will start, as you may remember if you have ever run minecraft server.
  The first startup will cause modifications to `eula.txt`, so the server will close immediately.
  The `eula.txt` should be created under `run` in the `spigot-data` directory, so please accept the license and modify it.

You are now all set.

----

### Running spigot (production)

Now all you have to do is to run the container as you did before:

```bash
sudo podman run -d -e SPIGOT_VERSION=1.18.1 -e SPIGOT_OPTIONS=-Xms2048M -v /storage0/spigot-data:/spigot-data -p 25565:25565 docker.io/kekyo/spigot_runner
```

* `-d` is specified instead of `-it`. This means that it will run in the background, and no console operation will be performed. For continuous operation, specify this option.

If spigot is generated, spigot will not be built after the second time and spigot will be started directly.

This is podman-specific, but to automatically start the spigot image at system boot time (i.e., fully automated with systemd), run the following command:

```bash
cd /etc/systemd/system
podman generate systemd --name --restart-policy on-failure -f minecraft
systemctl daemon-reload

systemctl enable container-minecraft
```

To do this same thing with Docker instead of podman, search with google for the topic about auto-starting Docker containers. (Probably, the method will vary depending on the environment)

----

### Execute using cockpit

Once the data directory is prepared, the rest can be run from cockpit.
By default, cockpit is located at port number 9090, so you can access it from a browser using `https://localhost:9090/`.

TODO:

Specify port number, data directory path, and spigot version as follows:

![cockpit-podman](images/cockpit2.png)

----

### Backups and version upgrades.

The parts related to the spigot program are completely sealed inside the Docker image and container.
If you usually want to backup your game data, you can do so by backing up everything under the data directory created above. (When backing up, please stop the container once.)

If you want to upgrade the spigot version (of course, backup the data directory beforehand), simply specify the version number in the `SPIGOT_VERSION` field and start it up.
If the specified version of spigot has not yet been generated, it will automatically do so.

Anyway, if you want to know an example of how to make it work, you can prepare the following script and use it at the time of version upgrade to automatically delete the old version of the container image, build the new version of spigot, and register it with systemd again. It will do it automatically.

``upgrade.sh`:

```bash
#! /bin/sh

systemctl stop container-minecraft
systemctl disable container-minecraft

podman rm minecraft

podman run --name minecraft -d -e SPIGOT_VERSION=$1 -e SPIGOT_OPTIONS=-Xms2048M -v /storage0/spigot-data:/spigot-data -p 25565:25565 docker.io/kekyo/spigot_runner

cd /etc/systemd/system
podman generate systemd --name --restart-policy on-failure -f minecraft
systemctl daemon-reload

systemctl enable container-minecraft
```

Usage:

```bash
$ chmod 755 upgrade.sh
$ sudo upgrade.sh 1.19.2 
```

You can customize it based on this script.

----

## License

Under MIT.

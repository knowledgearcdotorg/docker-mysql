# KnowledgeArc.org MySQL Docker Image
KnowledgeArc provides an open source Docker image of the MySQL database server on Ubuntu.

## Getting Started

To launch a MySQL container, run:

```
sudo docker run --name=container-name knowledgearcdotorg/mysql
```

where --name=container-name is a user-friendly reference to the docker container.

For example, to launch a container with the name "mysql" run:

```
docker run --name=mysql knowledgearcdotorg/mysql
```

When your container is first run, some configuration is required to initialize the database and generate a root password. This information is printed to the screen for your convenience. Look out for root:password for your root account's password.

To run the container in detached mode, add the -d option:

```
docker run -d --name=mysql knowledgearcdotorg/mysql
```

You can check the status of the newly created container, as well as view the randomly generated password, by running:

```
docker logs mysql
```

## Using an Existing Volume

By default, the KnowledgeArc.org MySQL image creates a persistent volume for storing the MySQL database files at /var/lib/mysql. However, you may wish to provide your own volume or you may want to connect to an existing MySQL data directory (if, for example, you are launching an upgraded version of MySQL).

If you haven't already done so, you can launch a new volume by running:

```
docker volume create --name=volume-name
```

where volume-name is a user-friendly reference to the newly created volume.

For example, if we wanted to create a new volume for storing our MySQL data files, we could run:

```
docker volume create --name mysql-data
```

To connect to your new mysql-data volume, run:

```
docker run --name=mysql -v mysql-data:/var/lib/mysql knowledgearcdotorg/mysql
```

where the -v or --volume option mounts our mysql-data volume to a directory on our newly launched container.

## Connecting to MySQL over the Network

The --link option is now deprecated and it is now recommended the new Docker networking feature be used instead.

By default, mysql will be added to the default bridge network. Alternatively, you can specify your own network.

To set up a user-defined network, run:

```
docker network create -d bridge local.net
```

where local.net is the name of our local network.

To make the new mysql container accessible to other containers, simply add it to the newly created network:

```
docker network connect local.net mysql
```

Your MySQL container is now accessible from any other container connected to the local.net network.

## Managing the Root Password

The KnowledgeArc.org MySQL container's root user must have a password, and there are two ways that a password is assigned to the root user:

### Generating a Random Password

By default, the KnowledgeArc.org MySQL container will generate a random password and assign it to the root user when the container is first run. This password is printed to the command line or can be accessed via docker logs if the container is run in detached mode.

### Specifying Your Own Password

If you would like to specify a password, you can pass the variable MYSQL_ROOT_PASSWORD when running the container for the first time:

```
docker run -e "MYSQL_ROOT_PASSWORD=myrootpassword" --name=mysql knowledgearcdotorg/mysql
```

where the environment variable MYSQL_ROOT_PASSWORD is specified along with the assigned password value, "myrootpassword".

Alternatively, you may, for security or automation reasons, wish to specify a password from a password file:

```
docker run -e "MYSQL_ROOT_PASSWORD=$(cat mysql.pwd)" --name=mysql knowledgearcdotorg/mysql
```

where mysql.pwd is a file containing the new root password. The cat command is used to output the contents of the file.
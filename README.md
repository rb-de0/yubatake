# note

A simple CMS using Vapor(Server Side Swift Framework)

# Prerequisites

### Swift

- 4.0.2

### OS

- macOS Sierra 10.12.6
- Ubuntu 14.04

# Usage

## Setup Envirionment

#### 1. Install Swift

Please install Swift in your environment. For macOS please download Xcode.
If you are using Ubuntu, it is easy to install using swiftenv.

Example(swiftenv)

```bash
$ swiftenv install 4.0.2
```

#### 2. Install MySQL

note supports MySQL and In Memory Database of SQLite as a database. When using MySQL, installation of MySQL server and client library is required.

For details, refer to the official Vapor 's document.

[https://docs.vapor.codes/2.0/mysql/package/](https://docs.vapor.codes/2.0/mysql/package/)

#### 3. Install Redis

note supports Redis and In Memory Database as session store. If you use Redis, Redis needs to be installed in your environment.

For macOS

```bash
$ brew install redis
```

For ubuntu

```bash
$ sudo apt-get install redis-server
```

#### 4. Install libxml2

note uses libxml2 for HTML parsing. You need to install libxml2 in your environment.

For macOS

```bash
$ brew install libxml2
$ brew link --force libxml2
```

For ubuntu

```bash
$ sudo apt-get install libxml2-dev
```

## Setup Application

#### 1. Clone or download this repository. 

#### 2. Create database

To use MySQL for the database, please enter the following SQL to create the database.


```SQL
mysql> create database note default character set utf8;
```

#### 3. Setup Config

Move to the directory of this repository and Change the Config of the application. 

Application settings are written in JSON files in ```Config``` directory. Although the default setting has already been written, you need to create a custom JSON file according to your environment.

Please create the Config file in ```Config/secrets```. The secrets directory is ignored so it is not affected by note updates.

The way to write Config is described in the Config section.


#### 4. Enter the following command.

```bash
$ swift build
```

※ Depending on the version of MySQL, you may need ```-Xswiftc -DNOJSON``` as argument.

## About Config


Application settings can be changed freely, but your own environment settings should be placed in ```Config/secrets```.

For details, refer to the official Vapor 's document.

[https://docs.vapor.codes/2.0/configs/config/](https://docs.vapor.codes/2.0/configs/config/)

Below are examples of several Config settings.

#### fluent.json

If you want to use In Memory Database of SQLite as the database of your application, please change driver of ```fluent.json``` to ```memory```.

```
{
	"driver": "memory",
	...,
	...
}
```

#### droplet.json

If you want to use In Memory Database as a store of sessions, change middleware of droplet.json from ```redis-sessions``` to ```sessions```.

```JSON
{
	...,
	"middleware": [
		...,
		"sessions",
		...
    ],
    ...
}
```

#### redis.json

Please write down the setting of Redis Server.

```JSON
{
    "hostname": "127.0.0.1",
    "port": 6379
}
```

#### mysql.json

Please write down the setting of MySQL Server.

```JSON
{
    "hostname": "127.0.0.1",
    "user": "root",
    "password": "password",
    "database": "note"
}
```

# Future Improvement

[https://github.com/rb-de0/note/issues](https://github.com/rb-de0/note/issues)


# LICENSE

note is released under the MIT License. See the license file for more info.
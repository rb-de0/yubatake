# yubatake

### Current Version is Beta. The application may be unstable and some data may not be handed over to the next version.

[![Build Status](https://travis-ci.org/rb-de0/yubatake.svg?branch=master)](https://travis-ci.org/rb-de0/yubatake)
[![Coverage Status](https://coveralls.io/repos/github/rb-de0/yubatake/badge.svg?branch=master)](https://coveralls.io/github/rb-de0/yubatake?branch=master)

yubatake is simple blogging engine for Swift.

# Prerequisites

### Swift

- 4.1

### OS

- macOS High Sierra 10.13.4
- Ubuntu 14.04

# Usage

## Setup Envirionment

#### 1. Install Swift

Please install Swift in your environment. For macOS please download Xcode 9.3.
If you are using Ubuntu, it is easy to install using swiftenv.

Example(swiftenv)

```bash
$ swiftenv install 4.1
```

#### 2. Install MySQL

yubatake supports MySQL only.

Please install MySQL Server in your environment.

#### 3. Install Redis

yubatake uses Redis Server as a session store. 

Please install Redis in your environment.

For macOS

```bash
$ brew install redis
```

For ubuntu

```bash
$ sudo apt-get install redis-server
```

## Setup Application

#### 1. Clone or download this repository. 

#### 2. Create database

To use MySQL for the database, please enter the following SQL to create the database.

Please choose the name of a database freely.

```SQL
mysql> create database yubatake default character set utf8;
```

#### 3. Setup Config

Please edit configuration files in `Config` directory according to your environment.

#### app.json

The setting of the whole application.

#### mysql.json

The setting of a mysql server.

#### redis.json

The setting of a redis server.

#### csp.json

The setting of a Content Security Policy.


#### 4. Enter the following command.

```bash
$ swift build -c release
```

※ Depending on the version of MySQL, you may need ```-Xswiftc -DNOJSON``` as argument.


#### 5. Run the app.

```bash
$ swift run Run
```

# Migration

If you are using a version earlier than 3.0, you need to migrate the database.

1. Please update to 2.1.2
2. Run the application to update scheme.
3. Please update to 3.0.0
4. Execute the following command to migrate the database.

```bash
$ swift run Run migrate -i <oldDatabase>
```

# LICENSE

yubatake is released under the MIT License. See the license file for more info.

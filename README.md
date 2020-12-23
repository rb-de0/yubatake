# yubatake

yubatake is simple blogging engine for Swift.

# Prerequisites

### Swift

- 5.3.2

### OS

Tests passed on the following Systems.

- Ubuntu 16.04

# Usage

## Setup Envirionment

#### 1. Install Swift

Please install Swift in your environment. For macOS please download Xcode 12.3.
If you are using Ubuntu, it is easy to install using swiftenv.

Example(swiftenv)

```bash
$ swiftenv install 5.3.2
```

#### 2. Install MySQL

yubatake supports MySQL only.

Please install MySQL Server in your environment.

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

#### csp.json

The setting of a Content Security Policy.

#### 4. Build Application

```bash
$ swift build -c release
```

#### 5. Run Application

```bash
$ swift run Run -e prod
```

**Be sure to set `-e prod` as a option to use production middlewares.**

# LICENSE

yubatake is released under the MIT License. See the license file for more info.

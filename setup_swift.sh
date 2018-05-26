apt-get update
apt-get install -y git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev libncurses5-dev pkg-config curl

# mysql
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get -y install mysql-server
service mysql start

# vapor
eval "$(curl -sL https://apt.vapor.sh)"
apt-get -y install vapor
apt-get -y install cmysql
chmod -R a+rx /usr/

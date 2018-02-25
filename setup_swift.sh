apt-get update
apt-get install -y git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev libncurses5-dev pkg-config curl

HOME=/home/vagrant
export $HOME

# swift
git clone https://github.com/kylef/swiftenv.git $HOME/.swiftenv

echo 'export SWIFTENV_ROOT="$HOME/.swiftenv"' >> $HOME/.bash_profile
echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' >> $HOME/.bash_profile
echo 'eval "$(swiftenv init -)"' >> $HOME/.bash_profile

$HOME/.swiftenv/bin/swiftenv install 4.0.3
chmod 777 $HOME/.swiftenv -R

# mysql
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server
sudo service mysql start

# vapor
eval "$(curl -sL https://apt.vapor.sh)"
sudo apt-get -y install vapor
sudo apt-get -y install cmysql
sudo chmod -R a+rx /usr/

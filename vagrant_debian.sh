#!/usr/bin/env bash

echo "Installing Packages"

#########################################################################
#update package list
#########################################################################
sudo apt-get update

#########################################################################
#install basic packages
#########################################################################
sudo apt-get -y install curl build-essential python-software-properties git git-core openssl libssl-dev python g++ make checkinstall  

#########################################################################
#Time / Date
#########################################################################
sudo cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

#########################################################################
#Install Apache 
#########################################################################
sudo apt-get -y install apache2

#copy custom apache.conf
#sudo cp ./apache2.conf /etc/apache2/apache2.conf

echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
echo "ServerSignature Off" >> /etc/apache2/apache2.conf
echo "HostnameLookups Off >> /etc/apache2/apache2.conf
echo "ServerName localhost" >> /etc/apache2/apache2.conf


#Enable Apache Mods
sudo a2enmod rewrite
sudo a2enmod headers

sudo /etc/init.d/apache2 restart

#########################################################################
#Install MySQL
#########################################################################

#prevent mysql to prompt root password screen
#http://unix.stackexchange.com/questions/147261/installing-mysql-server-in-vagrant-bootstrap-shell-script-how-to-skip-setup
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password MySuperPassword'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password MySuperPassword'

sudo apt-get -y install mysql-server-5.5 mysql-client-5.5 

sudo service mysql stop 
# allow mysql access from network
sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
sudo service mysql start
 
# set mysql privileges to allow root access from all hosts
echo "use mysql;update user set host='%' where user='root' and host='#{$hostname}';flush privileges;" | mysql -uroot -proot
 
######################################################################### 
#Install PHP
#########################################################################
sudo apt-get install php5 libapache2-mod-php5 php5-gd php-pear php5-mysql php5-curl php5-memcache php-apc php5-json php-xml-parser curl php5-mcrypt php5-cli
sudo cp ./php.ini /etc/php5/apache2/php.ini

#########################################################################
#Install PHPMyAdmin
#########################################################################
sudo apt-get install phpmyadmin
sudo /etc/init.d/apache2 restart

#########################################################################
#Install Node.js via nvm
#########################################################################
git clone git://github.com/creationix/nvm.git ~/nvm
source ~/nvm/nvm.sh	
sudo nvm install 0.10.40
sudo nvm use 0.10.40


#########################################################################
#www symlink
#########################################################################
sudo rm -rf /var/www
sudo ln -fs /vagrant/www /var/www

#########################################################################
#Install Mono
#########################################################################
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee "/etc/apt/sources.list.d/mono-xamarin.list"
sudo apt-get update

#sudo apt-get install mono-devel 
#sudo apt-get install mono-complete
#sudo apt-get install referenceassemblies-pcl
sudo apt-get install mono-runtime

#########################################################################
echo "Install done" 
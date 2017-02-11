#!/bin/bash


mysql="mysql-5.1.73"


_chkok() {
        if [ $2 -eq 0 ]; then
                echo -ne "$1 \e[01;34mok\e[0m\n"
        else
                echo -ne "$1 \e[01;31merror\e[0m\n"
                exit -1
        fi
}

_srcdown() {

yum -y install wget

mkdir /root/src
cd /root/src

wget http://download.softagency.net/MySQL/Downloads/MySQL-5.1/mysql-5.1.73.tar.gz
_chkok "200 OK" "$?"

tar xvf mysql-5.1.73.tar.gz
}

_install(){
	cd /root/src/$mysql
	
	./configure \
	--prefix=/home/mysql \
	--with-readline \
	--without-debug \
	--enable-shared \
	--with-charset=euckr \
	--with-extra-charsets=all \
	--with-big-tables \
	--enable-thread-safe-client \
	--with-named-thread-libs=-lpthread \
	--with-plugins=myisam,innobase,archive,csv,partition \
	--with-ssl

        _chkok "Thank you for choosing MySQL" "$?"

	make && make install
        _chkok "Making install in win" "$?"
}

_mysqlconf() {
	
	groupadd mysql
	useradd -g mysql mysql
	
	echo [mysqld] > /etc/my.cnf
	echo init_connect=SET collation_connection=utf8_general_ci >> /etc/my.cnf
	echo init_connect=SET NAMES utf8 >> /etc/my.cnf
	echo character-set-server=utf8 >> /etc/my.cnf
	echo collation-server=utf8_general_ci >> /etc/my.cnf
	echo table_cache=1024 >> /etc/my.cnf
	echo max_connections=2048 >> /etc/my.cnf
	echo max_user_connections=500 >> /etc/my.cnf
	echo max_connect_errors=10000 >> /etc/my.cnf
	echo wait_timeout=300 >> /etc/my.cnf
	echo query_cache_type=1 >> /etc/my.cnf
	echo query_cache_size=128M >> /etc/my.cnf
	echo query_cache_limit=5M >> /etc/my.cnf
	echo slow_query_log >> /etc/my.cnf
	echo long_query_time=3 >> /etc/my.cnf
	echo max_allowed_packet=16M >> /etc/my.cnf
	echo sort_buffer_size=2M >> /etc/my.cnf
	echo skip-innodb >> /etc/my.cnf
	echo skip-name-resolve >> /etc/my.cnf
	echo symbolic-links=0 >> /etc/my.cnf
	echo >> /etc/my.cnf
	echo [mysql] >> /etc/my.cnf
	echo default-character-set=utf8 >> /etc/my.cnf


	chown -R mysql:mysql /home/mysql
	/root/src/$mysql/scripts/mysql_install_db
	chown -R mysql:mysql /home/mysql

	echo "/home/mysql/share/mysql/mysql.server start" >> /etc/rc.local
}

yum -y install gcc* ncurses-devel

_srcdown
_install
_mysqlconf
#!/bin/bash


php="php-5.3.21"


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

wget http://app.nidc.kr/php/php-5.3.21.tar.gz
_chkok "200 OK" "$?"

tar xvf php-5.3.21.tar.gz
}

_install(){
	cd /root/src/$php
	
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

	yum -y install gcc* libxml2-devel libxml2 bzip2-devel curl curl-devel gdbm-devel libXpm libXpm-devel freetype-devel libmcrypt-devel libtool-ltdl-devel

	ln -s /usr/lib64/libfreetype.so /usr/lib/
	ln -s /usr/lib64/libgd.so /usr/lib/
	ln -s /usr/lib64/libjpeg.so /usr/lib/
	ln -s /usr/lib64/libpng.so /usr/lib/libpng.so
	ln -s /usr/lib64/libltdl.so /usr/lib/
	ln -s /usr/lib64/libXpm.so /usr/lib/
	ln -s /usr/lib64/libz.so /usr/lib/

	./configure \
	--with-mysql=/home/mysql \
	--with-mysqli=/home/mysql/bin/mysql_config \
	--with-pdo-mysql=/home/mysql \
	--with-apxs2=/home/apache/bin/apxs \
	--with-gd \
	--with-curl \
	--with-jpeg-dir=/usr \
	--with-freetype-dir=/usr \
	--with-png-dir=/usr \
	--with-xpm-dir=/usr \
	--with-zlib \
	--with-zlib-dir=/usr \
	--with-gdbm \
	--with-gettext \
	--with-iconv \
	--with-openssl \
	--with-libxml-dir=/usr/lib \
	--with-bz2 \
	--with-mcrypt \
	--enable-zip \
	--enable-gd-native-ttf \
	--enable-exif \
	--enable-magic-quotes \
	--enable-sockets \
	--enable-soap \
	--enable-mbstring=all \
	--enable-bcmath \
	--enable-ftp


        _chkok "Thank you for using PHP" "$?"

	make && make install
        _chkok "Build complete" "$?"


}

_phpconf() {
	
cp -f php.ini-production /usr/local/lib/php.ini

perl -i -pe "s/memory_limit = 8M/memory_limit = 128M/g" /usr/local/lib/php.ini
perl -i -pe "s/upload_max_filesize = 2M/upload_max_filesize = 20M/g" /usr/local/lib/php.ini
perl -i -pe "s/allow_url_fopen = On/allow_url_fopen = Off/g" /usr/local/lib/php.ini
perl -i -pe "s/post_max_size = 8M/post_max_size = 20M/g" /usr/local/lib/php.ini
perl -i -pe "s/short_open_tag = Off/short_open_tag = On/g" /usr/local/lib/php.ini
perl -i -pe "s/allow_url_fopen = On/allow_url_fopen = Off/g" /usr/local/lib/php.ini
perl -i -pe "s/;date.timezone =/date.timezone = Asia\/Seoul/g" /usr/local/lib/php.ini
perl -i -pe "s/upload_max_filesize = 2M/upload_max_filesize = 20M/g" /usr/local/lib/php.ini
perl -i -pe "s/post_max_size = 8M/post_max_size = 20M/g" /usr/local/lib/php.ini
perl -i -pe "s/max_file_uploads = 20/max_file_uploads = 30/g" /usr/local/lib/php.ini

}




_srcdown
_install
_phpconf
#!/bin/bash


apr="apr-1.5.2"
apr_util="apr-util-1.5.4"
pcre="pcre-8.33"
httpd="httpd-2.4.23"

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

mkdir /home/src
cd /home/src

wget http://ftp.neowiz.com/apache/httpd/httpd-2.4.23.tar.bz2
_chkok "200 OK" "$?"
wget http://ftp.neowiz.com/apache/apr/apr-1.5.2.tar.bz2
_chkok "200 OK" "$?"
wget http://ftp.neowiz.com/apache/apr/apr-util-1.5.4.tar.bz2
_chkok "200 OK" "$?"
wget http://downloads.sourceforge.net/project/pcre/pcre/8.33/pcre-8.33.tar.bz2
_chkok "200 OK" "$?"

tar xvf apr-1.5.2.tar.bz2
tar xvf apr-util-1.5.4.tar.bz2
tar xvf httpd-2.4.23.tar.bz2
tar xvf pcre-8.33.tar.bz2

#mv apr-1.5.2 /home/src/httpd-2.4.23/srclib/apr
#mv apr-util-1.5.4 /home/src/httpd-2.4.23/srclib/apr-util
}

_install_apr(){
	cd /home/src/$apr

	./configure --prefix=/usr/local/apr
	_chkok "apr configure" "$?"
	make
	_chkok "apr make" "$?"
	make install
	_chkok "apr make install" "$?"
}

_install_apr_util(){
	cd /home/src/$apr_util

        ./configure --with-apr=/usr/local/apr
        _chkok "apr-util configure" "$?"
        make
        _chkok "apr-util make" "$?"
	make install
        _chkok "apr-util make install" "$?"
}

_install_pcre(){
	cd /home/src/$pcre

        ./configure
        _chkok "pcre configure" "$?"
        make
        _chkok "pcre make" "$?"
	make install
        _chkok "pcre make install" "$?"
}

_install(){
	cd /home/src/$httpd

	if [ "$arch" == "x86_64" ]; then
        	echo "Apache architecture x86_64"
               	./configure \
--prefix=/home/apache \
--with-mpm=prefork \
--with-apr=/usr/local/apr \
--with-apr-util=/usr/local/apr \
--enable-mods-shared=most \
--with-ssl --enable-ssl
                _chkok "apache configure" "$?"
     	else
        	echo "Apache architecture i386"
               	./configure \
--prefix=/home/apache \
--with-mpm=prefork \
--with-apr=/usr/local/apr \
--with-apr-util=/usr/local/apr \
--enable-mods-shared=most \
--with-ssl --enable-ssl
                _chkok "apache configure" "$?"
       	fi

	make && make install
        _chkok "apache install" "$?"
}

_apacheconf() {
	cp -avx /home/apache/bin/apachectl /etc/rc.d/init.d/httpd
}

yum -y install libjpeg-devel libpng-devel apr-devel apr-util-devel gcc* pcre-devel.x86_64 zlib-devel openssl-devel


_srcdown
_install_apr
_install_apr_util
_install_pcre
_install
_apacheconf

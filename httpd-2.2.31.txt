#!/bin/bash


apr="apr-1.5.2"
apr_util="apr-util-1.5.4"
httpd="httpd-2.2.31"

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

wget https://archive.apache.org/dist/httpd/httpd-2.2.31.tar.gz
_chkok "200 OK" "$?"
wget https://archive.apache.org/dist/apr/apr-1.5.2.tar.gz
_chkok "200 OK" "$?"
wget https://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz
_chkok "200 OK" "$?"

tar xvf apr-1.5.2.tar.gz
tar xvf apr-util-1.5.4.tar.gz
tar xvf httpd-2.2.31.tar.gz

#mv apr-1.5.2 /home/src/httpd-2.4.23/srclib/apr
#mv apr-util-1.5.4 /home/src/httpd-2.4.23/srclib/apr-util
}

_install_apr(){
	cd /root/src/$apr

	./configure --prefix=/usr/local/apr
	_chkok "apr configure" "$?"
	make
	_chkok "apr make" "$?"
	make install
	_chkok "apr make install" "$?"
}

_install_apr_util(){
	cd /root/src/$apr_util

        ./configure --with-apr=/usr/local/apr
        _chkok "apr-util configure" "$?"
        make
        _chkok "apr-util make" "$?"
	make install
        _chkok "apr-util make install" "$?"
}

_install(){
	cd /root/src/$httpd

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
#	cp -avx /home/apache/bin/apachectl /etc/rc.d/init.d/httpd
	echo "/home/apache/bin/apachectl start" >> /etc/rc.local

	perl -i.bak -pe 's#AddEncoding x-gzip .gz .tgz#AddEncoding x-gzip .gz .tgz\n AddType application/x-httpd-php .php .php3 .php4 .html .htm .inc\n AddType application/x-httpd-php-source .phps#i' /home/apache/conf/httpd.conf
	perl -i -pe "s/index.html/index.html index.php index.htm/" /home/apache/conf/httpd.conf
	perl -i -pe "s/#Include conf\/extra\/httpd-mpm.conf/Include conf\/extra\/httpd-mpm.conf/g" /home/apache/conf/httpd.conf
	perl -i -pe "s/#Include conf\/extra\/httpd-default.conf/Include conf\/extra\/httpd-default.conf/g" /home/apache/conf/httpd.conf
	perl -pi -e 's/Timeout 300/Timeout 30/g' /home/apache/conf/extra/httpd-default.conf
	perl -pi -e 's/ MaxClients 150/ MaxClients 512/g' /home/apache/conf/extra/httpd-mpm.conf


}

rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install libjpeg-devel libpng-devel apr-devel apr-util-devel gcc* pcre-devel.x86_64 zlib-devel openssl-devel pcre pcre-devel

_srcdown
_install_apr
_install_apr_util
_install
_apacheconf
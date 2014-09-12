FROM buildpack-deps

RUN gpg --keyserver pgp.mit.edu --recv-keys 0B96609E270F565C13292B24C13C70B87267B52D 0A95E9A026542D53835E3F3A7DEC4E69FC9C83D7

ENV PHP_VERSION 5.3.29

# php 5.3 needs older autoconf
RUN set -x \
	&& apt-get update && apt-get install -y autoconf2.13 curl && rm -r /var/lib/apt/lists/* \
	&& curl -SLO http://launchpadlibrarian.net/140087283/libbison-dev_2.7.1.dfsg-1_amd64.deb \
	&& curl -SLO http://launchpadlibrarian.net/140087282/bison_2.7.1.dfsg-1_amd64.deb \
	&& dpkg -i libbison-dev_2.7.1.dfsg-1_amd64.deb \
	&& dpkg -i bison_2.7.1.dfsg-1_amd64.deb \
	&& rm *.deb \
	&& curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2/from/this/mirror" -o php.tar.bz2 \
	&& curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2.asc/from/this/mirror" -o php.tar.bz2.asc \
	&& gpg --verify php.tar.bz2.asc \
	&& mkdir -p /usr/src/php \
	&& tar -xvf php.tar.bz2 -C /usr/src/php --strip-components=1 \
	&& rm php.tar.bz2* \
	&& cd /usr/src/php \
	&& ./buildconf --force \
	&& ./configure --disable-cgi \
	&& make -j"$(nproc)" \
	&& make install \
	\
	&& cd / \
	&& gpg --keyserver pgp.mit.edu --recv-keys A93D62ECC3C8EA12DB220EC934EA76E6791485A8 \
	&& apt-get update && apt-get install -y libapr1-dev libaprutil1-dev && rm -r /var/lib/apt/lists/* \
	&& curl -SL "http://apache.osuosl.org/httpd/httpd-2.4.10.tar.bz2" -o httpd.tar.bz2 \
	&& curl -SL "https://www.apache.org/dist/httpd/httpd-2.4.10.tar.bz2.asc" -o httpd.tar.bz2.asc \
	&& gpg --verify httpd.tar.bz2.asc \
	&& mkdir -p /usr/src/httpd \
	&& tar -xvf httpd.tar.bz2 -C /usr/src/httpd --strip-components=1 \
	&& rm httpd.tar.bz2.* \
	&& cd /usr/src/httpd \
	&& ./configure --enable-so \
	&& make -j"$(nproc)" \
	&& make install \
	&& cd / \
	&& rm -r /usr/src/httpd \
	&& mkdir -p /var/www/html \
	&& sed -r ' \
		s/(DirectoryIndex index[.])html/\1php/; \
		s!/usr/local/apache2/htdocs!/var/www/html!g; \
		s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
		s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
		$ a<FilesMatch \\.php$>\n\tSetHandler application/x-httpd-php\n</FilesMatch> \
		' /usr/local/apache2/conf/httpd.conf > /etc/apache2/httpd.conf \
	&& rm /usr/local/apache2/conf/httpd.conf \
	&& ln -s /etc/apache2/httpd.conf /usr/local/apache2/conf/httpd.conf \
	&& echo "<html><head></head><body><?php echo '<h1>Hello, World!</h1>'; ?></body></html>" >> /var/www/html/index.php \
	&& cd /usr/src/php \
	&& make clean \
	&& ./configure --with-apxs2=/usr/local/apache2/bin/apxs --with-mysql --with-mysqli \
	&& make -j"$(nproc)" \
	&& make install \
	&& cp php.ini-development /usr/local/lib/php.ini \
	&& dpkg -r bison libbison-dev \
	&& apt-get purge -y --auto-remove autoconf2.13 curl \
	&& rm -r /usr/src/php

ENV PATH $PATH:/usr/local/apache2/bin

WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80
CMD ["httpd", "-DFOREGROUND"]

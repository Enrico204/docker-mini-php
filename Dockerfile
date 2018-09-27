FROM alpine:latest

RUN apk add --update \
		lighttpd \
		php-fpm \
		runit \
	&& rm -rf /var/cache/apk/*

# set up folders, configure lighttpd and php-fpm
RUN mkdir -p /app/htdocs /app/error /etc/service/lighttpd /etc/service/php-fpm \
	&& sed -i -E \
		-e 's/var\.basedir\s*=\s*".*"/var.basedir = "\/app"/' \
		-e 's/#\s+(include "mod_fastcgi_fpm.conf")/\1/' \
		-e 's/#\s+server.port\s+=\s+81/server.port = 5000/' \
		/etc/lighttpd/lighttpd.conf \
#	&& sed -i -E \
#		-e 's/user\s*=\s*nobody/user = lighttpd/' \
#		/etc/php7/php-fpm.d/www.conf \
	&& mkdir /var/lib/lighttpd/ \
	&& echo -e "#!/bin/sh\nlighttpd -D -f /etc/lighttpd/lighttpd.conf" > /etc/service/lighttpd/run \
	&& echo -e "#!/bin/sh\nphp-fpm7 --nodaemonize" > /etc/service/php-fpm/run \
	&& chmod -R +x /etc/service/*

VOLUME /var/log/
VOLUME /var/lib/lighttpd/

EXPOSE 5000

WORKDIR /app/htdocs

CMD runsvdir -P /etc/service

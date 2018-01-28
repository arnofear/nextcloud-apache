# https://github.com/nextcloud/docker/blob/master/.examples/dockerfiles/full/apache/Dockerfile
FROM nextcloud:12.0.5-apache

ENV DEBIAN_FRONTEND noninteractive

ENV NEXTCLOUD_DIR /usr/src/nextcloud
ENV CRON_MEMORY_LIMIT 1024M

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list \
&& apt-get update \
&& apt-get install --no-install-recommends --no-install-suggests -y \
    libmagickwand-dev \
    libgmp3-dev \
    libc-client-dev libkrb5-dev \
    smbclient libsmbclient-dev \
    locales locales-all \
&& apt-get install --no-install-recommends --no-install-suggests -y -t jessie-backports ffmpeg \
&& ln -s "/usr/include/$(dpkg-architecture --query DEB_BUILD_MULTIARCH)/gmp.h" /usr/include/gmp.h \
&& docker-php-ext-configure imap --with-kerberos --with-imap-ssl >/dev/null \
&& docker-php-ext-install bz2 gmp imap >/dev/null \
&& pecl install imagick smbclient >/dev/null \
&& docker-php-ext-enable imagick smbclient \
&& a2enmod rewrite headers env dir mime \
&& a2dismod status \
&& a2dissite 000-default.conf \
&& sed -i 's/^ServerSignature On/ServerSignature Off/' /etc/apache2/conf-available/security.conf \
&& sed -i 's/^ServerTokens OS/ServerTokens Minimal/' /etc/apache2/conf-available/security.conf \
&& echo 'Europe/Paris' > /etc/timezone \
&& dpkg-reconfigure -f noninteractive tzdata \
&& apt-get clean \
&& dpkg -l | awk '{print $2}' | grep '\-dev' | xargs apt-get remove --purge -y \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/* /usr/share/doc /usr/share/man

ENV TZ=Europe/Paris
ENV LC_ALL fr_FR.UTF-8
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR.UTF-8

COPY run.sh /usr/local/bin/

WORKDIR $NEXTCLOUD_DIR

CMD ["/usr/local/bin/run.sh"]

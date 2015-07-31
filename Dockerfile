FROM derjudge/archlinux
MAINTAINER Marc Richter <mail@marc-richter.info>

RUN yes | pacman -Syy
RUN yes | pacman -S extra/mariadb \
    extra/php-sqlite \
    extra/php-pgsql \
    extra/php-apache \
    extra/php-intl \
    extra/php-mcrypt \
    extra/php-apcu | cat


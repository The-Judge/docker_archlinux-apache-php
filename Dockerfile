FROM derjudge/archlinux
MAINTAINER Marc Richter <mail@marc-richter.info>

RUN yes | pacman -Syy
RUN yes | pacman -S community/owncloud \
    extra/php-apache \
    extra/php-intl \
    extra/php-mcrypt \
    extra/php-apcu | cat


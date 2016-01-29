FROM derjudge/archlinux
MAINTAINER Marc Richter <mail@marc-richter.info>

# Update pacman database and fix possibly incorrect pacman db format after world upgrade
RUN pacman -Syy \
  && pacman-db-upgrade

# Install additional packages
RUN yes | pacman -S \
    core/ed \
    extra/git \
    extra/mariadb \
    extra/php-apache \
    extra/php-apcu \
    extra/php-gd \
    extra/php-intl \
    extra/php-mcrypt \
#    extra/php-pear \
    extra/php-pgsql \
    extra/php-sqlite \
    extra/postfix \
    extra/re2c \
    extra/wget \
    | cat
# base-devel - Ugly workarround needed due to selection dialogue
RUN echo "" > /tmp/input && echo "Y" >> /tmp/input \
  && pacman -S base-devel < /tmp/input \
  && rm -f /tmp/input
## php-xhprof
#RUN git clone https://aur.archlinux.org/php-xhprof.git /usr/src/php-xhprof \
#  && chown nobody -R /usr/src/php-xhprof \
#  && cd /usr/src/php-xhprof \
#  && su -c "makepkg -m" -s /bin/bash nobody \
#  && yes | pacman -U php-xhprof-*.pkg.tar.xz \
#  && cd \
#  && rm -rf /usr/src/php-xhprof
# graphviz
RUN echo "" > /tmp/input && echo "Y" >> /tmp/input \
  && pacman -S graphviz < /tmp/input \
  && rm -f /tmp/input

# Clear pacman caches
RUN yes | pacman -Scc

# Optimize pacman database
RUN pacman-optimize

# Modify php.ini
# Comment out open_basedir
RUN sed -i'' 's#^\(open_basedir.*$\)#;\1#g' /etc/php/php.ini
# Load MySQL modules
RUN sed -i'' 's#^;\(extension=.*pdo.*mysql.*\)#\1#g' /etc/php/php.ini
RUN sed -i'' 's#^;\(extension=.*mysqli.*\)#\1#g' /etc/php/php.ini
# Load SQLite modules
RUN sed -i'' 's#^;\(extension=.*sqlite.*\)#\1#g' /etc/php/php.ini
# Load zip module
RUN sed -i'' 's#^;\(extension=zip.so\)#\1#g' /etc/php/php.ini
# Load gd module
RUN sed -i'' 's#^;\(extension=gd.so\)#\1#g' /etc/php/php.ini
# Load opcache module
RUN sed -i'' 's#^;\(zend_extension=opcache.so\)#\1#g' /etc/php/php.ini
RUN sed -i'' 's#^;\(opcache.enable_cli=\).*$#\11#g' /etc/php/php.ini
# Activate php_error.log
RUN sed -i'' 's#^;\(error_log = \).*\.log$#\1/var/log/php_errors.log#g' /etc/php/php.ini

# Add init script
ADD helpers/init /
RUN chmod +x /init

# Add Apache HTTPd config
RUN rm -rf /etc/httpd/conf/httpd.conf
RUN rm -f  /etc/httpd/conf/extra/httpd-default.conf
ADD templates/httpd/httpd.conf /etc/httpd/conf/httpd.conf
ADD templates/httpd/extra/httpd-default.conf /etc/httpd/conf/extra/httpd-default.conf
ADD templates/httpd/modules.conf /etc/httpd/conf/modules.conf
RUN mkdir /app
RUN touch /var/log/php_errors.log && chmod 777 /var/log/php_errors.log

VOLUME ["/var/log/httpd"]

EXPOSE 80

CMD ["/init"]

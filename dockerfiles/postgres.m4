FROM postgres:9.6

include(`apt-get-install.in')
apt_get_install(`postgresql-9.6-pgtap')


# RUN /docker-entrypoint.sh postgres please_dont_start ; echo ok    








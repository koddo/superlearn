#!/usr/bin/env bash

# if the script inside container is run as root, it creates files owned by root on host system, and we can't access them later
# so we run it as the host user
HOST_UID=$(id -u)
HOST_GID=$(id -g)

if [[ $1 == 'certonly' ]] ; then
    mkdir -p ../superlearn.certbot/etc_letsencrypt \
          ../superlearn.certbot/var_lib_letsencrypt \
          ../superlearn.certbot/var_log_letsencrypt && \
        docker run -it --rm --name certbot \
               --user=$HOST_UID:$HOST_GID \
               -v $(pwd)/../superlearn.certbot/etc_letsencrypt:/etc/letsencrypt \
               -v $(pwd)/../superlearn.certbot/var_lib_letsencrypt:/var/lib/letsencrypt \
               -v $(pwd)/../superlearn.certbot/var_log_letsencrypt:/var/log/letsencrypt \
               -v $(pwd)/../superlearn.secrets/certbot.digitalocean.ini:/superlearn.secrets/certbot.digitalocean.ini:ro \
               certbot/dns-digitalocean certonly \
               --dns-digitalocean \
               --dns-digitalocean-credentials /superlearn.secrets/certbot.digitalocean.ini \
               -d superlearn.it \
               -d www.superlearn.it
elif [[ $1 == 'renew' ]] ; then
    docker run -it --rm --name certbot \
           --user=$HOST_UID:$HOST_GID \
           -v $(pwd)/../superlearn.certbot/etc_letsencrypt:/etc/letsencrypt \
           -v $(pwd)/../superlearn.certbot/var_lib_letsencrypt:/var/lib/letsencrypt \
           -v $(pwd)/../superlearn.certbot/var_log_letsencrypt:/var/log/letsencrypt \
           -v $(pwd)/../superlearn.secrets/certbot.digitalocean.ini:/superlearn.secrets/certbot.digitalocean.ini:ro \
           certbot/dns-digitalocean renew --quiet
    # renew --dry-run
else
    echo "usage: $(basename $0) cetonly | renew"
fi



# --dns-digitalocean-propagation-seconds 60



# https://certbot.eff.org/docs/install.html#running-with-docker
# https://certbot.eff.org/docs/using.html#where-are-my-certificates

# https://certbot.eff.org/lets-encrypt/debianstretch-nginx
# https://www.nginx.com/blog/using-free-ssltls-certificates-from-lets-encrypt-with-nginx/
# https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-14-04



# TODO: crontab
# $ crontab -e
# 0 12 * * * /usr/bin/certbot renew --quiet

# TODO: right user and permissions for the certbot dir
# we now do $ sudo chown -R deploy:deploy superlearn.certbot
# use koddo/certbot-dns-digitalocean

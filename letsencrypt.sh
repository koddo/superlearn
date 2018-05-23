#!/usr/bin/env bash



if [[ $1 == 'certonly' ]] ; then
    mkdir -p ../superlearn.certbot/etc_letsencrypt \
          ../superlearn.certbot/var_lib_letsencrypt \
          ../superlearn.certbot/var_log_letsencrypt && \
        docker run -it --rm --name certbot \
               -v $(pwd)/../superlearn.certbot/etc_letsencrypt:/etc/letsencrypt \
               -v $(pwd)/../superlearn.certbot/var_lib_letsencrypt:/var/lib/letsencrypt \
               -v $(pwd)/../superlearn.certbot/var_log_letsencrypt:/var/log/letsencrypt \
               -v $(pwd)/../superlearn.secrets/certbot.digitalocean.ini:/superlearn.secrets/certbot.digitalocean.ini:ro \
               koddo/certbot-dns-digitalocean certonly \
               --dns-digitalocean \
               --dns-digitalocean-credentials /superlearn.secrets/certbot.digitalocean.ini \
               -d superlearn.org \
               -d www.superlearn.org
elif [[ $1 == 'renew' ]] ; then
        docker run -it --rm --name certbot \
               -v $(pwd)/../superlearn.certbot/etc_letsencrypt:/etc/letsencrypt \
               -v $(pwd)/../superlearn.certbot/var_lib_letsencrypt:/var/lib/letsencrypt \
               -v $(pwd)/../superlearn.certbot/var_log_letsencrypt:/var/log/letsencrypt \
               -v $(pwd)/../superlearn.secrets/certbot.digitalocean.ini:/superlearn.secrets/certbot.digitalocean.ini:ro \
               koddo/certbot-dns-digitalocean renew
        # renew --dry-run
else
    echo "usage: $(basename $0) cetonly|renew"
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
# sudo chown -R deploy:deploy superlearn.certbot



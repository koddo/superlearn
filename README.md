
# run locally checklist

- run superlearn-wiki
- database restore
- docker-compose up -d
- sudo service fail2ban restart



# most interesting parts

<./backend/src/hello_world_app.erl> and handlers
<./client-web/src/cljs/theproject/views.cljs>, etc
database/V*_funcs__*.sql


# security

TODO: SECURITY make sure iframe-resizer is safe, can't be used for xss and csrf
TODO: SECURITY make sure marked.js is safe: <https://ponyfoo.com/articles/fixing-xss-vulnerability-marked>, <https://snyk.io/blog/marked-xss-vulnerability/>
TODO: <https://serverfault.com/questions/627169/how-to-secure-an-open-postgresql-port>

# fsevents

<https://facebook.github.io/watchman/>
<https://geoff.greer.fm/fsevents/>, <https://geoff.greer.fm/2015/12/25/fsevents-tools-watch-a-directory-for-changes/>


# misc

<https://developer.yahoo.com/performance/rules.html>

TODO: <https://docs.docker.com/compose/compose-file/#variable-substitution> in .env for external ports

# sort

<https://www.slideshare.net/stormpath/rest-jsonapis>
<https://www.sitepoint.com/best-practices-rest-api-scratch-introduction/>
<http://www.vinaysahni.com/best-practices-for-a-pragmatic-restful-api>
<https://blog.mwaysolutions.com/2014/06/05/10-best-practices-for-better-restful-api/>

<https://www.reddit.com/r/Anki/comments/7p12ej/experimental_addon_to_adjust_individual_card_ease/>

# SECURITY -- escaping html

We now rely on `sanitaize` option of `marked()` after decoding html entities from user data.

<https://stackoverflow.com/questions/1147359/how-to-decode-html-entities-using-jquery/1395954#1395954>
TODO: use HTML entity encoder/decoder lib instead of relying on textarea: <https://github.com/mathiasbynens/he>


# backup

```
$ docker-compose stop database
$ ./database-backup.sh
$ docker-compose up -d
```

```
$ docker-compose stop database
$ docker rm database
$ docker volume rm database superlearn_pgdata
$ docker volume create --name=superlearn_pgdata
$ ./database-restore.sh superlearn--2018-01-25--13-21-27--pgdata.tgz
$ docker-compose up -d
```

When unable to remove a volume:
```
$ docker volume rm superlearn_pgdata
Error response from daemon: unable to remove volume: remove superlearn_pgdata: volume is in use - [containter_id, another_containter_id]
$ docker rm containter_id
$ docker rm another_containter_id
$ docker volume rm superlearn_pgdata
```

# fail2ban

```
sudo service fail2ban restart
sudo fail2ban-client status basic-auth
sudo iptables --list-rules
sudo tail -f /var/log/fail2ban.log
```

# deploy

- create a vm in digitalocean
- ansible script
- certbot script, add cron job
- create a firewall in digitalocean to only expose ports 22 and 443, this is easier for now than fighting iptables+docker setup

```
SERVER_CRT=../superlearn.certbot/etc_letsencrypt/live/superlearn.it/fullchain.pem \
    SERVER_KEY=../superlearn.certbot/etc_letsencrypt/live/superlearn.it/privkey.pem \
    HTTPS_PORT=443
    docker-compose up -d
```


# communication with hidden iframe

<https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage>

<https://www.dyn-web.com/tutorials/iframes/postmessage/demo.php> -- server was down last time I checked it.



# sort

Motivation text: I forget there's no `s.trim()` in python, it's called `s.strip()`. I forget `s.strip(',')` has slightly different logic than `s.strip()`. Man, I forget all the time `throw` in python is called `raise`.













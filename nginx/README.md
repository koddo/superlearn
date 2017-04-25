
The conf is purely for dev env.

# misc

TODO: run nginx as non-root user

Tcpdump would be useful. Also check out alternatives for http traffic.

```
FROM nginx:stable

RUN apt-get update && apt-get install -y \
            tcpdump && \
    apt-get -y autoclean && apt-get -y autoremove
```

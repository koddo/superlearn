FROM nginx:stable

RUN apt-get update && apt-get install -y \
            tcpdump \
            apache2-utils && \
    apt-get -y autoclean && apt-get -y autoremove

FROM debian:jessie

ENV ERLANG_LINK=https://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_20.1-1~debian~jessie_amd64.deb

# dockerfile best practices recommends to run apt-get update && apt-get install in a single RUN: https://docs.docker.com/articles/dockerfile_best-practices/#the-dockerfile-instructions
# and without ca-certificates it won't install erlang-solutions_1.0_all.deb in debian, but in ubuntu it is not required
RUN apt-get update && apt-get install -y \
            ca-certificates \
            wget \
            curl \
            git \
            build-essential \
            libwxbase3.0-0 \
            libwxgtk3.0-0 \
            libsctp1 \
            && \
    apt-get -y autoclean && apt-get -y autoremove

RUN TEMP_DEB="$(mktemp)" && \     
    wget -O "$TEMP_DEB" "$ERLANG_LINK" && \
    dpkg -i "$TEMP_DEB" && \
    rm -f "$TEMP_DEB" && \
    apt-get -y autoclean && apt-get -y autoremove

    
include(`add_theuser.in')


# install rebar to ~/bin
# my dependencies need it
RUN cd ~ && mkdir -p ~/bin && cd ~/bin && \
    wget https://github.com/rebar/rebar/wiki/rebar && chmod a+x rebar
    ## erlang.mk downloads relx, but I leave this here for a while
    # git clone https://github.com/erlware/relx relx-tmp && cd relx-tmp && make && cd ~/bin && mv relx-tmp/relx . && rm -fr relx-tmp && \   
ENV PATH /home/theuser/bin:$PATH




# ## unused right now, these are set in fig.yml
# # VOLUME ["/data"]  
# # RUN cd ~ && git clone https://github.com/koddo/ryctoicpab && cd ryctoicpab && make 
# # CMD ["/home/theuser/ryctoicpab/_rel/hello_world_example/bin/hello_world_example", "foreground"]
# # ENTRYPOINT ["/home/theuser/ryctoicpab/entrypoint.sh"]
# # EXPOSE 8080


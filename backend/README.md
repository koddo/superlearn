
[![Build Status](https://travis-ci.org/koddo/example-erl-cowboy.svg?branch=master)](https://travis-ci.org/koddo/example-erl-cowboy)

# Run

```
$ docker-compose run --rm backend make
$ docker-compose up -d
$ curl localhost:8080
Hello world!
```

# Test

```
$ docker-compose run --rm backend make check       # or make tests to skip dialyzer
```

TODO: write tests
TODO: turn build-on-push on in travis

# Misc

TODO: prebuilt dialyzer plt files to speed up dialyzer checks locally and in travis-ci  
<https://github.com/esl/erlang-plts>
<https://github.com/danielberkompas/travis_elixir_plts>
plt files have to be built on the spot, so for travis we have to generate them inside the build process




<https://django.readthedocs.io/en/1.6.x/ref/templates/builtins.html#date>
<https://github.com/erlydtl/erlydtl/wiki>


# remote shell


``` Shell
$ docker-compose exec backend bash -c 'TERM=xterm erl -sname remsh_node -setcookie hello_world_example -remsh hello_world_example@$(hostname)'
```

```
c("/home/theuser/theproject/src/fff", [{outdir, "/home/theuser/theproject/ebin/"}, debug_info]).
erlydtl:compile_file("/home/theuser/theproject/erlydtl/fff.dtl", fff_dtl, [{out_dir, false}]).
hello_world_app:router_live_update().
```

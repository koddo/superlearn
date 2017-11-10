
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

Should we use `jsx:decode()` with or without `return_maps`, which is faster in our case? 

<https://ninenines.eu/docs/en/cowboy/2.0/guide/rest_flowcharts/>

# remote shell


``` Shell
$ docker-compose exec backend bash -c 'TERM=xterm erl -sname remsh_node -setcookie hello_world_example -remsh hello_world_example@$(hostname)'
$ echo 'some code' | erl_call -c hello_world_example -name hello_world_example@$(hostname) -e
echo 'code:purge(handler_rest), compile:file("/home/theuser/theproject/src/handler_rest", [{outdir, "/home/theuser/theproject/ebin/"}, debug_info]), code:load_abs("/home/theuser/theproject/ebin/handler_rest").' | erl_call -c hello_world_example -name hello_world_example@$(hostname) -e
```

```
c("/home/theuser/theproject/src/handler_name", [{outdir, "/home/theuser/theproject/ebin/"}, debug_info]).
erlydtl:compile_file("/home/theuser/theproject/erlydtl/fff.dtl", fff_dtl, [{out_dir, false}]).
hello_world_app:router_live_update().
```


``` Erlang
filelib:fold_files("/home/theuser/theproject/src/", "\.erl$", false, fun(File, Acc) -> c(File, [{outdir, "/home/theuser/theproject/ebin/"}, debug_info]), Acc end, []),
filelib:fold_files("/home/theuser/theproject/erlydtl/", "\.dtl$", false, fun(File, Acc) -> DtlModuleName = filename:basename(File, ".dtl") ++ "_dtl", erlydtl:compile_file(File, DtlModuleName, [{out_dir, false}]), Acc end, []),
hello_world_app:router_live_update().
```

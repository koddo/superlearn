
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

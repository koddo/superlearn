%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(hello_world_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

-export([router_live_update/0]).

%% API.

start(_Type, _Args) ->
    error_logger:info_msg("node: ~p~n", [node()]),
    error_logger:info_msg("cookie: ~p~n", [erlang:get_cookie()]),


	Dispatch = dispatch(),
	{ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
                                         env => #{dispatch => Dispatch}
                                        }),
	hello_world_sup:start_link().

stop(_State) ->
	ok.

dispatch() ->
    cowboy_router:compile([
                           {'_', [
                                  %% {"/",             cowboy_static, {priv_file, hello_world, "index.html", [{mimetypes, cow_mimetypes, all}]}},
                                  %% {"/js/[...]",     cowboy_static, {priv_dir,  hello_world, "js",         [{mimetypes, cow_mimetypes, all}]}},
                                  %% {"/css/[...]",    cowboy_static, {priv_dir,  hello_world, "css",        [{mimetypes, cow_mimetypes, all}]}},
                                  %% {"/api/v0/", handler_rest, []},
                                  %% {"/api/v0/:asdf", handler_rest, []},
                                  %% {"/api/v0/:asdf/:fdsa", handler_rest, []},
                                  {"/ht/cards/add", handler_render_dtl, {cards_add_html_dtl, <<"text/html">>, #{}}},
                                  {"/ht/cards/[:card_id]", handler_cards, []},
                                  {"/ht/decks", handler_render_dtl, {decks_html_dtl, <<"text/html">>, #{}}}
                                  %% {"/ht/cards/:card_id", handler_render_dtl, {card_html_dtl, <<"text/html">>, #{front => <<"what">>, back => <<"ever">>, due => {{2017,10,24},{0,0,0}}}}},
                                  %% {"/ht/cards", handler_cards, []}
                                 ]}
                          ]).

%% https://ninenines.eu/docs/en/cowboy/2.0/guide/routing/#live_update
router_live_update() ->
    cowboy:set_env(http, dispatch, dispatch()).

-module(handler_render_dtl).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([render_dtl/2]).
-export([handle_post/2]).

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
	{[<<"HEAD">>, <<"GET">>, <<"POST">>, <<"OPTIONS">>], Req, State}.

content_types_provided(Req, State = {_Module, MediaType, _RenderArgs}) ->
	{[
      {MediaType, render_dtl}
     ], Req, State}.

content_types_accepted(Req, State) ->
	{[{{<<"application">>, <<"x-www-form-urlencoded">>, []}, handle_post}],
     Req, State}.

render_dtl(Req, State = {Module, _MediaType, RenderArgs}) ->
    error_logger:info_msg("--- render_dtl get~n--- Bindings: ~p~n", [cowboy_req:bindings(Req)]),
    {ok, Body} = apply(Module, render, [RenderArgs]),
    {Body, Req, State}.

handle_post(Req, State) ->
	{ok, BodyPost, Req1} = cowboy_req:read_urlencoded_body(Req),
    error_logger:info_msg("--- render_dtl post~n--- Bindings: ~p~n--- BodyPost: ~p~n", [cowboy_req:bindings(Req1), BodyPost]),
    {true, Req1, State}.


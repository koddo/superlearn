-module(handler_render_dtl).

-export([init/2]).
-export([content_types_provided/2]).
-export([render_dtl/2]).

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

content_types_provided(Req, State = {_Module, MediaType, _RenderArgs}) ->
	{[
      {MediaType, render_dtl}
     ], Req, State}.

render_dtl(Req, State = {Module, _MediaType, RenderArgs}) ->
    {ok, Body} = apply(Module, render, [RenderArgs]),
    {Body, Req, State}.

%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(handler_index_html).

-export([init/2]).
-export([add_one/1]).


init(Req, Opts) ->
    {ok, Body} = index_html_dtl:render([]),
	Req_body = cowboy_req:reply(200, #{<<"content-type">> => <<"text/html">>}, Body, Req),
	{ok, Req_body, Opts}.















-spec(add_one(number()) -> number()).  
add_one(X) ->  
    X+1.



-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

simple_test() ->
    ?assert( 1 + 1 =:= 2 ).

another_test() ->
    ?assert( add_one(1) =:= 2 ).


-endif.

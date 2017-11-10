%% @doc Hello world handler.
-module(handler_cards_old).

-export([init/2]).


init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    HasBody = cowboy_req:has_body(Req0),
    ReqN = maybe_ok(Method, HasBody, Req0),
    {ok, ReqN, Opts}.

maybe_ok(<<"GET">>, _, Req) ->
    {ok, _, Rows} = misc:with_connection(fun(C) -> 
                                            epgsql:equery(C, "select tmp_show_all(4);", [])
                                    end),
    error_logger:info_msg("--- Rows: ~p~n", [Rows]),
    {ok, Body} = index_html_dtl:render([{rows, Rows}]),
	Req_body = cowboy_req:reply(200, #{<<"content-type">> => <<"text/html">>}, Body, Req),
    Req_body;
maybe_ok(<<"POST">>, true, Req0) ->
    {ok, PostVals, Req1} = cowboy_req:read_urlencoded_body(Req0),
    error_logger:info_msg("--- PostVals: ~p~n", [PostVals]),
    cowboy_req:reply(200, #{
                       <<"content-type">> => <<"text/plain">>
                      }, <<"Hello world!">>, Req1);
maybe_ok(<<"POST">>, false, Req0) ->
    cowboy_req:reply(400, [], <<"Missing body.">>, Req0);
maybe_ok(_, _, Req0) ->
    cowboy_req:reply(405, Req0).









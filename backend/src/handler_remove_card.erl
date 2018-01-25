-module(handler_remove_card).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
-export([handle_post/2]).

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
	{[<<"HEAD">>, <<"POST">>, <<"OPTIONS">>], Req, State}.

content_types_accepted(Req, State) ->
	{[{{<<"application">>, <<"x-www-form-urlencoded">>, []}, handle_post}],
     Req, State}.

handle_post(Req, State) ->
	{ok, BodyPost, ReqN} = cowboy_req:read_urlencoded_body(Req),
    error_logger:info_msg("--- render_dtl post~n--- Bindings: ~p~n--- BodyPost: ~p~n", [cowboy_req:bindings(ReqN), BodyPost]),
    CardId = cowboy_req:binding(card_id, Req),
    {ok, Columns, Rows} = misc:with_connection(fun(C) -> 
                                                       epgsql:equery(C, "select remove_card_from_orset_decks_contexts(4, $1::uuid)", [CardId])
                                               end),
    error_logger:info_msg("--- Columns: ~p~n", [Columns]),
    error_logger:info_msg("--- Rows: ~p~n", [Rows]),
    Uri = [<<"/ht/cards/">>, CardId],
    {{true, Uri}, ReqN, State}.




%% Body = <<"<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><\head><body>Here goes response to POST request.</body></html>">>,
%% ReqN = cowboy_req:set_resp_body(Body, Req2),





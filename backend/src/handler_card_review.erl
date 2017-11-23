-module(handler_card_review).

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
    Response = cowboy_req:binding(response, Req),
    %% Response = case cowboy_req:binding(response, Req) of
    %%                <<"again">> -> 0;
    %%                <<"normal">> -> 4
    %%            end,
    error_logger:info_msg("--- Response: ~p~n", [Response]),
    {ok, Columns, Rows} = misc:with_connection(fun(C) -> 
                                                       epgsql:equery(C, "select review_card(4, $1::uuid, response_string_to_integer($2))", [CardId, Response])
                                               end),
    error_logger:info_msg("--- Columns: ~p~n", [Columns]),
    error_logger:info_msg("--- Rows: ~p~n", [Rows]),
    Uri = [<<"/ht/cards/">>, CardId],
    {{true, Uri}, ReqN, State}.




%% Body = <<"<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><\head><body>Here goes response to POST request.</body></html>">>,
%% ReqN = cowboy_req:set_resp_body(Body, Req2),





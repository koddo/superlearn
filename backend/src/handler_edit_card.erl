%% @doc Pastebin handler.
-module(handler_edit_card).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([resource_exists/2]).

-export([cards_html/2]).
-export([cards_post/2]).

-include_lib("../deps/epgsql/include/epgsql.hrl").

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
	{[<<"HEAD">>, <<"GET">>, <<"POST">>, <<"OPTIONS">>], Req, State}.

%% --- GET ---

content_types_provided(Req, State) ->
	{[
      {{<<"text">>, <<"html">>, []}, cards_html}
     ], Req, State}.

cards_html(Req, State) ->
    CardId = cowboy_req:binding(card_id, Req),
    error_logger:info_msg("--- CardId: ~p~n", [CardId]),
    
    {ok, Columns, Rows = [CardRow]} = misc:with_connection(fun(C) -> 
                                                       epgsql:equery(C, "select * from show_card(4, $1::uuid);", [CardId])
                                               end),
    error_logger:info_msg("--- Columns: ~p~n", [Columns]),
    error_logger:info_msg("--- Rows: ~p~n", [Rows]),
    Names_of_columns = [C#column.name || C <- Columns],
    Card = handler_rest:map_names_of_columns_to_row_values(Names_of_columns, CardRow),
    error_logger:info_msg("--- Card: ~p~n", [Card]),
    {ok, Body} = cards_edit_html_dtl:render(#{c => Card}),
    {Body, Req, State}.

    

%% --- POST ---

resource_exists(Req, State) ->
    Method = cowboy_req:method(Req),
    if Method =:= <<"GET">>; Method =:= <<"HEAD">> -> {true, Req, State};
       Method =:= <<"POST">> -> {false, Req, State}
    end.

content_types_accepted(Req, State) ->
	{[{{<<"application">>, <<"x-www-form-urlencoded">>, []}, cards_post}],
     Req, State}.


cards_post(Req, State) ->
    CardId = cowboy_req:binding(card_id, Req),
    {ok, BodyPost, Req1} = cowboy_req:read_urlencoded_body(Req),
    error_logger:info_msg("--- BodyPost: ~p~n", [BodyPost]),
    {_, NewFront} = lists:keyfind(<<"front">>, 1, BodyPost),
    {_, NewBack} = lists:keyfind(<<"back">>, 1, BodyPost),
    {ok, Columns, Rows = [CardRow]} = misc:with_connection(fun(C) -> 
                                                                   epgsql:equery(C, "select edit_card_content(4, $1::uuid, $2::text, $3::text);", [CardId, NewFront, NewBack])
                                                           end),
    error_logger:info_msg("--- Columns: ~p~n", [Columns]),
    error_logger:info_msg("--- Rows: ~p~n", [Rows]),
    Names_of_columns = [C#column.name || C <- Columns],
    R = handler_rest:map_names_of_columns_to_row_values(Names_of_columns, CardRow),
    NewCardId = maps:get(<<"edit_card_content">>, R),
    {ok, Body} = card_created_html_dtl:render([{card_id, NewCardId}]),
    ReqN = cowboy_req:set_resp_body(Body, Req1),
    {{true, [<<"/ht/cards/">>, NewCardId]}, ReqN, State}.






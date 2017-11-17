%% @doc Pastebin handler.
-module(handler_cards).

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

resource_exists(Req, State) ->
    Method = cowboy_req:method(Req),
    if Method =:= <<"GET">>; Method =:= <<"HEAD">> -> resource_exists_method_get(Req, State);
       Method =:= <<"POST">> -> resource_exists_method_post(Req, State)
    end.

%% --- GET ---

resource_exists_method_get(Req, _State) ->
    case cowboy_req:binding(card_id, Req) of
        undefined ->
            {true, Req, index};
        CardId ->
            {true, Req, CardId}
    end.

content_types_provided(Req, State) ->
	{[
      {{<<"text">>, <<"html">>, []}, cards_html}
     ], Req, State}.

cards_html(Req, State = index) ->
    {ok, Columns, Rows} = misc:with_connection(fun(C) -> 
                                                        epgsql:equery(C, "select * from show_all(4);", [])
                                                end),
    %% error_logger:info_msg("--- Columns: ~p~n", [Columns]),
    %% error_logger:info_msg("--- Rows: ~p~n", [Rows]),
    Names_of_columns = [C#column.name || C <- Columns],
    Rows2 = [handler_rest:map_names_of_columns_to_row_values(Names_of_columns, R) || R <- Rows],
    error_logger:info_msg("--- Rows2: ~p~n", [Rows2]),
    {ok, Body} = cards_html_dtl:render(#{rows => Rows2}),
    {Body, Req, State};
cards_html(Req, State = CardId) ->
    %% #{show := Show} = cowboy_req:match_qs([show], Req),
    QsVals = cowboy_req:parse_qs(Req),
    ShowTuple = lists:keyfind(<<"show">>, 1, QsVals),
    Show = case ShowTuple of
               {_, S} -> S;
               false -> false
           end,
    error_logger:info_msg("--- CardId: ~p~n", [CardId]),
    {ok, Columns, _Rows = [CardRow]} = misc:with_connection(fun(C) -> 
                                                                    %% epgsql:equery(C, "select *, (unpack_progress_data(s.packed_progress_data)).* from cards as c join cards_orset as s on c.id = s.card_id where c.id = $1::uuid;", [CardId])
                                                                    epgsql:equery(C, "select * from show_card(4, $1::uuid);", [CardId])
                                               end),
    %% error_logger:info_msg("--- Columns: ~p~n", [Columns]),
    %% error_logger:info_msg("--- Rows: ~p~n", [Rows]),
    Names_of_columns = [C#column.name || C <- Columns],
    Card = handler_rest:map_names_of_columns_to_row_values(Names_of_columns, CardRow),
    error_logger:info_msg("--- Card: ~p~n", [Card]),
    {ok, Body} = card_html_dtl:render(#{c => Card, show => Show}),
    {Body, Req, State}.

%% --- POST ---

resource_exists_method_post(Req, _State) ->
    {false, Req, create}.

content_types_accepted(Req, State) ->
	{[{{<<"application">>, <<"x-www-form-urlencoded">>, []}, cards_post}],
     Req, State}.


cards_post(Req, State = create) ->
    {ok, BodyPost, Req1} = cowboy_req:read_urlencoded_body(Req),
    error_logger:info_msg("--- BodyPost: ~p~n", [BodyPost]),
    {_, Front} = lists:keyfind(<<"front">>, 1, BodyPost),
    {_, Back} = lists:keyfind(<<"back">>, 1, BodyPost),
    {_, Deck} = lists:keyfind(<<"deck">>, 1, BodyPost),
    {_, Context} = lists:keyfind(<<"context">>, 1, BodyPost),
    {ok, Columns, Rows = [CardRow]} = misc:with_connection(fun(C) -> 
                                                       epgsql:equery(C, "select create_and_add_card(4, null, $1,  $2, now()::date, pack_progress_data(2.5, 0, 0, 0, false, false, 0), get_or_create_deck_id($3), get_or_create_context_id($4));", [Front, Back, Deck, Context])
                                               end),
    error_logger:info_msg("--- Columns: ~p~n", [Columns]),
    error_logger:info_msg("--- Rows: ~p~n", [Rows]),
    Names_of_columns = [C#column.name || C <- Columns],
    R = handler_rest:map_names_of_columns_to_row_values(Names_of_columns, CardRow),
    {ok, Body} = card_created_html_dtl:render([{card_id, maps:get(<<"create_and_add_card">>, R)}]),
    ReqN = cowboy_req:set_resp_body(Body, Req1),
    {{true, <<"/ht/cards/123">>}, ReqN, State}.




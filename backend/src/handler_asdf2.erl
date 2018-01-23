%% @doc Pastebin handler.
-module(handler_asdf2).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).

-export([cards_html/2]).

-include_lib("../deps/epgsql/include/epgsql.hrl").

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
	{[<<"HEAD">>, <<"GET">>, <<"OPTIONS">>], Req, State}.

%% --- GET ---

content_types_provided(Req, State) ->
	{[
      {{<<"text">>, <<"html">>, []}, cards_html}
     ], Req, State}.

cards_html(Req, State) ->
    #{deckname := DeckName} = cowboy_req:match_qs([{deckname, nonempty}], Req),
    error_logger:info_msg("--- DeckName: ~p~n", [DeckName]),

    {ok, Columns, Rows} = misc:with_connection(fun(C) -> 
                                                       epgsql:equery(C, "select * from decks as d join card_decks_orset as s on d.id = s.deck_id join cards as c on c.id = s.card_id where d.name = $1;", [DeckName])
                                               end),
    error_logger:info_msg("--- Columns: ~p~n", [Columns]),
    error_logger:info_msg("--- Rows: ~p~n", [Rows]),
    Names_of_columns = [C#column.name || C <- Columns],
    Rows2 = [handler_rest:map_names_of_columns_to_row_values(Names_of_columns, R) || R <- Rows],
    %% error_logger:info_msg("--- Rows2: ~p~n", [Rows2]),
    {ok, Body} = asdf_html_dtl:render(#{deckname => DeckName, lst => Rows2}),
    {Body, Req, State}.

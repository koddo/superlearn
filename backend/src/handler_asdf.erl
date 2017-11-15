%% @doc Pastebin handler.
-module(handler_asdf).

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
    %% /?c=... and /?c=...&c=...&c=... => list of card ids
    #{deckname := DeckName, c:= CL} = cowboy_req:match_qs([{deckname, nonempty}, c], Req),
    ListOfCardIDs = if is_list(CL) -> CL;
                       true -> [CL]
                    end,

    error_logger:info_msg("--- ~p ~p~n", [DeckName, ListOfCardIDs]),
    
    %% https://stackoverflow.com/questions/10738446/postgresql-select-rows-where-column-array
    {ok, Columns, Rows} = misc:with_connection(fun(C) -> 
                                                       epgsql:equery(C, "select * from cards as c where c.id = any($1::uuid[]);", [ListOfCardIDs])
                                               end),
    %% error_logger:info_msg("--- Columns: ~p~n", [Columns]),
    %% error_logger:info_msg("--- Rows: ~p~n", [Rows]),
    Names_of_columns = [C#column.name || C <- Columns],
    Rows2 = [handler_rest:map_names_of_columns_to_row_values(Names_of_columns, R) || R <- Rows],
    error_logger:info_msg("--- Rows2: ~p~n", [Rows2]),
    {ok, Body} = asdf_html_dtl:render(#{deckname => DeckName, lst => Rows2}),
    {Body, Req, State}.

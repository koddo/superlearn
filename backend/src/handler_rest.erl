%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(handler_rest).

-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([hello_to_json/2]).
-export([resource_exists/2]).
-export([create_card/2]).

-include_lib("../deps/epgsql/include/epgsql.hrl").

-record(state, {resource_exists = false}).

init(Req, _Opts = []) ->
    State = #state{},
	{cowboy_rest, Req, State}.

%% ---------------------------------------------------------

allowed_methods(Req, State) ->
	{[<<"HEAD">>, <<"GET">>, <<"POST">>], Req, State}.


%% epgsql returns date in this format: {2017,4,20} -> 2033-11-30T21:46:44Z
%% jsx thinks this is a erlang timestamp like, while datetimes should look like {Date = {_, _, _}, Time = {_, _, _}}
coerce_epgsql_row_value(Date = {_, _, _}) ->
    {Date, {0, 0, 0}};
coerce_epgsql_row_value(Everything_else) ->
    Everything_else.
    

map_names_of_columns_to_row_values(Names_of_columns, Row) ->
    List_of_row_values = [ coerce_epgsql_row_value( element(I,Row) )  ||  I <- lists:seq( 1, tuple_size(Row) ) ],
    maps:from_list(
      lists:zip(Names_of_columns, List_of_row_values)
     ).

%% should we use accumulator here and reverse result, would it be faster? See http://stackoverflow.com/questions/1131127/how-can-i-write-erlangs-list-concatenate-without-using-the-lists-module/1131941#1131941
split_list_into_list_of_pairs([X, Y | T]) ->
    [{X, Y}] ++ split_list_into_list_of_pairs(T);
split_list_into_list_of_pairs([]) ->
    [].

get_arg_of_type_from_json_map(Arg, Type, Json) ->
    Value = maps:get(Arg, Json),
    if Type == <<"date">> ->
            %% jsx itself doesn't make any attempts to parse dates in json, so we do this ourselves
            {Date, _} = ec_date:parse(binary_to_list(Value)),
            Date;
       true ->
            %% everything else gets parsed just fine
            Value
    end.


%% epgsql can't do substitute function params, like `select * from a_func($1 => $2, $3 => $4)`, so we put things in the right order ourselves
%% anyway it's either we put function args in the right order or postgres does this for us, and then we still have to validate input
%% transform <<"get_data">> and <<"the_user_id integer, the_data_id uuid">> into "select * from get_data($1::integer, $2::uuid);" and apply with list of params from json in the right order
%% TODO: what's up with utf-8 here? ~s vs ~ts
%% TODO: validate json is object and has exactly the right keys, and values and their types are ok
format_query_with_params_from_json_in_the_right_order(StoredFunction, ArgsWithTypes, Json) ->
    ArgsWithTypesList = binary:split(ArgsWithTypes, [<<" ">>, <<",">>], [global, trim_all]),
    ArgsWithTypesPairs = split_list_into_list_of_pairs(ArgsWithTypesList),
    EnumeratedPairs = lists:zip( lists:seq(1, length(ArgsWithTypesPairs)), ArgsWithTypesPairs ),
    TypedPlaceholders = [ io_lib:format("$~B::~s", [I, binary_to_list(Type)]) || 
                            {I, {_Arg, Type}} <- EnumeratedPairs ],
    Query = io_lib:format("select * from ~s(~s);", [binary_to_list(StoredFunction), string:join(TypedPlaceholders, ", ")]),
    Params = [ get_arg_of_type_from_json_map(Arg, Type, Json) || {Arg, Type} <- ArgsWithTypesPairs ],
    {Query, Params}.

%% TODO: SECURITY CRITICAL move secrets out
%% TODO: split and rename
with_connection(Fun) ->
    {ok, Connection} = epgsql:connect("postgres.dev.dnsdock", 
                                      "administrator", 
                                      no_password, 
                                      [{database, "thedb"}, 
                                       {ssl, true}, 
                                       {cacertfile, "/home/theuser/certs_dev/cacert.pem"},
                                       {certfile,   "/home/theuser/certs_dev/pg-user-administrator.crt"},
                                       {keyfile,    "/home/theuser/certs_dev/pg-user-administrator.nopassword.key"},
                                       {verify, verify_peer},
                                       {fail_if_no_peer_cert, true}   % this is for server-side, not sure if this works for client-side, but won't hurt
                                      ]),
    try
        Fun(Connection)
    after
        ok = epgsql:close(Connection)
    end.

%% TODO: rename
my_apply(StoredFunction, Json) ->
    with_connection(fun(Connection) ->
                            %% TODO: get stored function arguments once, at the first run
                            {ok, _, [{ArgsWithTypes}]} = epgsql:equery(Connection, "select pg_get_function_identity_arguments($1::regproc)", [StoredFunction]),
                            {Query, Params} = format_query_with_params_from_json_in_the_right_order(StoredFunction, ArgsWithTypes, Json),
                            epgsql:equery(Connection, Query, Params)
                    end).

%% --- GET -------------------------------------------------

content_types_provided(Req, State) ->
	{[
      {<<"application/json">>, hello_to_json},
      {<<"text/html">>, hello_to_json}
     ], Req, State}.

hello_to_json(Req, State) ->
    Json = jsx:decode(<<"{\"the_user_id\":4}">>, [return_maps]),
    Binding = cowboy_req:binding(asdf, Req),
    Binding2 = cowboy_req:binding(fdsa, Req),
    error_logger:info_msg("--- Binding, Binding2: ~p ~p~n", [Binding, Binding2]),
    {ok, Columns, Rows} = if Binding == <<"deck">> ->
                                  my_apply(<<"get_cards_in_deck">>, maps:put(<<"the_deck_id">>, Binding2, Json));
                             true ->
                                  my_apply(<<"tmp_show_all">>, Json)
                          end,
    Names_of_columns = [C#column.name || C <- Columns],
    Rows_json = [jsx:encode(
                     map_names_of_columns_to_row_values(Names_of_columns, R)
                    )
                   || R <- Rows],
    {ok, Body} = if Binding == <<"deck">> ->
                         deck_html_dtl:render([{rows, Rows_json}]);
                    true ->
                         list_json_dtl:render([{rows, Rows_json}])
                 end,
    {Body, Req, State}.

%% --- POST ------------------------------------------------

content_types_accepted(Req, State) ->
	{[{<<"application/json">>, create_card}], Req, State}.

resource_exists(Req, State) ->
    %% later check if resource is new, this is a tiny boilerplate
    NewState = State#state{resource_exists=true},    
    {NewState#state.resource_exists, Req, NewState}.

create_card(Req, State) ->
    {ok, BodyPost, Req2} = cowboy_req:read_body(Req),
    error_logger:info_msg("--- body text: ~p~n", [BodyPost]),
    Json = jsx:decode(BodyPost, [return_maps]),
    error_logger:info_msg("--- body decoded: ~p~n", [Json]),

    Binding = cowboy_req:binding(asdf, Req),
    {ok, Columns, Rows} = if Binding == <<"review">> ->
                                  my_apply(<<"review_card">>, Json);
                             Binding == <<"edit_card_content">> ->
                                  my_apply(<<"edit_card_content">>, Json);
                             true ->
                                  my_apply(<<"tmp_create_and_add_card">>, Json)
                          end,

    error_logger:info_msg("--- result: ~p~n", [{ok, Columns, Rows}]),
    {ok, Body} = list_json_dtl:render([{rows, []}]),
    ReqN = cowboy_req:set_resp_body(Body, Req2),
	{{true, <<"/api/v0">>}, ReqN, State}.









%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(handler_rest).

-export([init/2]).
-export([content_types_provided/2]).
-export([hello_to_json/2]).

-include_lib("../deps/epgsql/include/epgsql.hrl").

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
	{[
      {<<"application/json">>, hello_to_json}
     ], Req, State}.

%% TODO: rename the func
%% jsx thinks this tuple returned by epgsql is a timestamp, not a date: {2017,4,20} -> 2033-11-30T21:46:44Z
%% while this is ok: {{2017,4,20},{13,46,27.118726}} -> 2017-04-20T13:46:27.118726Z
quirk(Date = {_, _, _}) ->
    {Date, {0, 0, 0}};
quirk(Everything_else) ->
    Everything_else.
    

map_names_of_columns_to_row_values(Names_of_columns, Row) ->
    List_of_row_values = [quirk(element(I,Row)) || I <- lists:seq(1,tuple_size(Row))],
    maps:from_list(
      lists:zip(Names_of_columns, List_of_row_values)
     ).


hello_to_json(Req, State) ->
    %% TODO: CRITICAL move to secrets
    
    error_logger:info_msg("fuck it~n", []),

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
    {ok, Columns, Rows} = epgsql:equery(Connection, "select * from get_cards(4);"),
    ok = epgsql:close(Connection),
    error_logger:info_msg("--- SQL Rows: ~p~n", [Rows]),



    
    Names_of_columns = [C#column.name || C <- Columns],
    Rows_format = [jsx:encode(
                     map_names_of_columns_to_row_values(Names_of_columns, R)
                    )
                   || R <- Rows],

    


    


    {ok, Body} = list_json_dtl:render([{rows, Rows_format}]),
	Req_body = cowboy_req:reply(200, #{<<"content-type">> => <<"text/html">>}, Body, Req),
	{Body, Req_body, State}.



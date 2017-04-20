%% Feel free to use, reuse and abuse the code in this file.

%% @doc Hello world handler.
-module(handler_rest).

-export([init/2]).
-export([content_types_provided/2]).
-export([hello_to_json/2]).

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
	{[
      {<<"application/json">>, hello_to_json}
     ], Req, State}.

hello_to_json(Req, State) ->
    %% TODO: CRITICAL move to secrets
    R = epgsql:connect("postgres.dev.dnsdock", 
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
    error_logger:info_msg("--- SQL connect: ~p~n", [R]),
    {ok, C} = R,
    {ok, _, Rows} = epgsql:equery(C, "select * from show_all(4);"),
    ok = epgsql:close(C),
    error_logger:info_msg("--- SQL Rows: ~p~n", [Rows]),

    {ok, Body} = list_json_dtl:render([]),
	Req_body = cowboy_req:reply(200, #{<<"content-type">> => <<"text/html">>}, Body, Req),
	{Body, Req_body, State}.



%% @doc Hello world handler.
-module(misc).

-export([with_connection/1]).

with_connection(Fun) ->
    {ok, Connection} = epgsql:connect("database", 
                                      "administrator", 
                                      no_password, 
                                      [{database, "thedb"},
                                       {port, 5432},
                                       {ssl, true},
                                       {ssl_opts, [
                                                   {cacertfile, "/home/theuser/certs_dev/cacert.pem"},
                                                   {certfile,   "/home/theuser/certs_dev/pg-user-administrator.crt"},
                                                   {keyfile,    "/home/theuser/certs_dev/pg-user-administrator.nopassword.key"},
                                                   {verify, verify_peer},
                                                   {fail_if_no_peer_cert, true}   % this is for server-side, not sure if this works for client-side, but won't hurt
                                                  ]}
                                      ]),
    try
        Fun(Connection)
    after
        ok = epgsql:close(Connection)
    end.

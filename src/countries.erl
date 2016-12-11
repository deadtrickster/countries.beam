%%%-------------------------------------------------------------------
%% @doc countries public API
%% @hidden
%%%-------------------------------------------------------------------

-module(countries).

-export([get/1]).
-export([by_capital/1]).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([start/0, stop/0]).
-define(APP, ?MODULE).
-define(SERVER, ?MODULE).

-behaviour(supervisor).

%% Supervisor callbacks
-export([init/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) -> start_link().

%%--------------------------------------------------------------------
stop(_State) -> ok.

start() -> application:start(?APP).

stop() -> application:stop(?APP).

get(Iso) ->
  case ets:lookup(cb_countries_table, Iso) of
    [{_, Country}] ->
      Country;
    [] -> undefined
  end.

by_capital(Capital) ->
  [{_, ISO}] = ets:lookup(cb_index_table, {<<"capital">>, Capital}),
  countries:get(ISO).

%%====================================================================
%% Supervisor
%%====================================================================

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
  {ok, _} = ets:file2tab(code:priv_dir(?APP) ++ "/COUNTRIES.DAT"),
  {ok, _} = ets:file2tab(code:priv_dir(?APP) ++ "/INDEX.DAT"),
  Procs = [],
  {ok, {{one_for_one, 1, 5}, Procs}}.

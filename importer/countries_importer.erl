-module(countries_importer).

-export([main/1]).

main(_Args) ->
  os:cmd("git submodule update --init"),
  {ok, Bin} = file:read_file("vendor/country/resources/data/ru.json"),
  io:format(Bin).




 

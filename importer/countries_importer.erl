-module(countries_importer).

-export([main/1]).

main(_Args) ->
  os:cmd("git submodule update --init"),
  {ok, Bin} = file:read_file("vendor/country/resources/data/longlist.json"),
  Countries = jsx:decode(Bin, []),

  CTable = ets:new(cb_countries_table, [{read_concurrency, true},
                                        set,
                                        named_table,
                                        protected]),

  [insert_country(Country, CTable) || Country <- Countries],

  ets:tab2file(CTable, "priv/COUNTRIES.DAT", [{sync, true},
                                              {extended_info, [object_count,
                                                               md5sum]}]),
  ok.

insert_country(Country, CTable) ->
  ets:insert(CTable, Country).

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

  ITable = ets:new(cb_index_table, [{read_concurrency, true},
                                    bag,
                                    named_table,
                                    protected]),

  [fun() ->
       insert_country(Country, CTable),
       insert_indexes(Country, ITable)
   end() || Country <- Countries],

  ets:tab2file(CTable, "priv/COUNTRIES.DAT", [{sync, true},
                                              {extended_info, [object_count,
                                                               md5sum]}]),

  ets:tab2file(ITable, "priv/INDEX.DAT", [{sync, true},
                                          {extended_info, [object_count,
                                                           md5sum]}]),
  ok.

insert_country(Country, CTable) ->
  ets:insert(CTable, Country).

insert_indexes({Iso, Country}, ITable) ->
  [fun() ->
       [ets:insert(ITable, {Index, Iso}) || Index <- key_indexes(Pair)]
   end() || Pair <- Country],
  ok.

key_indexes({<<"dialling">>, Dialling}) ->
  CCodes = get_list_value(<<"calling_code">>, Dialling),
  CallingCodesI = [{<<"dialling.calling_code">>, CCode} || CCode <- CCodes],

  NationalPrefix = get_list_value(<<"national_prefix">>, Dialling),
  NationalPrefixI = [{<<"dialling.national_prefix">>, NationalPrefix}],

  NNL = get_list_value(<<"national_number_lengths">>, Dialling),
  NNLI = [{<<"dialling.nn_lengths">>, Length} || Length <- NNL],

  NDCL = get_list_value(<<"national_destination_code_lengths">>, Dialling),
  NDCLI = [{<<"dialling.ndc_lengths">>, Length} || Length <- NDCL],

  IntlPrefix = get_list_value(<<"international_prefix">>, Dialling),
  IntlPrefixI = [{<<"dialling.international_prefix">>, IntlPrefix}],

  CallingCodesI ++ NationalPrefixI ++ NNLI ++ NDCLI ++ IntlPrefixI;  
key_indexes({<<"extra">>, Extra}) ->
  Extra;
key_indexes({Name, Value}) when is_list(Value) ->
  [{Name, Variant} || Variant <- Value];
key_indexes({Name, Value}) ->
  [{Name, Value}];
key_indexes(_) ->
  [].

get_list_value(Key, PL) ->
  case proplists:get_value(Key, PL) of
    null ->
      [];
    List ->
      List
  end.

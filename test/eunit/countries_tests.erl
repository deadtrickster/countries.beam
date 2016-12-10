-module(countries_tests).

-include_lib("eunit/include/eunit.hrl").

basic_iso2_lookup_test() ->
  countries:start(),
  ?assertMatch(undefined, countries:get(<<"qwe">>)),
  ?assertMatch(<<"Moscow">>, proplists:get_value(<<"capital">>, countries:get(<<"ru">>))).

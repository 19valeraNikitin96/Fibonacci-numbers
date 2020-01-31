%%%-------------------------------------------------------------------
%%% @author erlang
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Jan 2020 10:05
%%%-------------------------------------------------------------------
-module(fibonacci).
-author("erlang").

%% API
-export([numbers/2, modes/0, test_numbers/1]).
-export([numbers1/1, numbers2/1, numbers3/1, numbers3_child/2]).

test_numbers(Amount)->
  {
    {first, timer:tc(fibonacci, numbers, [Amount, first])},
    {second, timer:tc(fibonacci, numbers, [Amount, second])},
    {third, timer:tc(fibonacci, numbers, [Amount, third])}
  }.

numbers(Count, Variant)
  when is_number(Count),
       is_atom(Variant),
       Count > 1->
  case Variant of
    first -> numbers1(Count);
    second-> numbers2(Count);
    third -> numbers3(Count);
    _     -> undefined
  end.
modes()->[first, second, third].

numbers1(0)->[];
numbers1(Count)->
  numbers1(Count-1, 0, 1,[0]).
numbers1(0, _Prev, _Current, Result)->Result;
numbers1(Count, Prev, Current,Result)->
  numbers1(Count-1, Current, Prev+Current, [Current|Result]).

numbers2(0)->[];
numbers2(Count)->
  numbers2(Count, 0, 1).
numbers2(0, _Prev, _Current)->[];
numbers2(Count, Prev, Current)->
  [Prev | numbers2(Count-1, Current, Prev+Current)].

numbers3(0)->[];
numbers3(Count)->
  PID = spawn(fibonacci, numbers3_child, [self(), []]),
  PID ! {Count, 0, 1},
  receive
    Res -> lists:reverse(Res)
  end.
numbers3_child(Parent_PID, Result)->
  receive
    {0, _Prev, _Current}->Parent_PID ! Result;
    {Count, Prev, Current} ->
      Child_PID = spawn(fibonacci, numbers3_child, [Parent_PID, [Prev | Result]]),
      Child_PID ! {Count-1, Current, Prev+Current}
  end.
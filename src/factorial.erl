%%%-------------------------------------------------------------------
%%% @author erlang
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Jan 2020 11:22
%%%-------------------------------------------------------------------
-module(factorial).
-author("erlang").

%% API
-export([factorial/2, test_factorial/1]).
-export([factorial1/2, factorial3_child/0, factorial3/1, factorial2/1]).

test_factorial(Number)->
  {
    {first, timer:tc(factorial, factorial,[Number, first])},
    {second, timer:tc(factorial, factorial,[Number, second])},
    {third, timer:tc(factorial, factorial,[Number, third])}
  }.

factorial(0, _)->1;
factorial(Number, _)
  when not is_number(Number) orelse
  Number < 0 -> undefined;
factorial(Number, Mode)->
  case Mode of
    first  -> factorial1(Number, 1);
    second -> factorial2(Number);
    third -> factorial3(Number);
    _ -> undefined
  end.

factorial1(1, Acc)->Acc;
factorial1(Number, Acc)->
  factorial1(Number-1, Acc*Number).

factorial2(1)->1;
factorial2(Number)->
  Number*factorial2(Number-1).

factorial3(Number)->
  spawn(factorial, factorial3_child, []) ! {prev, self(), Number},
  receive
    {next, _From, Factorial}->Factorial
  end.
factorial3_child()->
  receive
    {prev, From, 1} -> From ! {next, self(), 1};
    {prev, From, Number} ->
      put(value,Number),
      put(prev,From),
      spawn(factorial, factorial3_child, []) ! {prev, self(), Number-1}, factorial3_child();
    {next, _From, Number} -> get(prev) ! {next, self(), get(value)*Number}
  end.








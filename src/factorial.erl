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
-define(PROC, 4).

%% API
-export([factorial/2, test_factorial/1, factorial5/1, test_factorial_concurrent/1, test_factorial_single_values/1, factorial4/1]).
-export([factorial1/2, factorial3_child/0, factorial3/1, factorial2/1, factorial4_receiver/3, factorial4_worker/3]).

test_factorial(Number)->
  {
    {first, timer:tc(factorial, factorial,[Number, first])},
    {second, timer:tc(factorial, factorial,[Number, second])}
  }.

test_factorial_concurrent(List)->
  {T1, _} = timer:tc(factorial,factorial4,[List]),
  {T2, _} = timer:tc(factorial,factorial5,[List]),
  {
    {fourth, T1}
    ,
    {fifth, T2}
  }.

test_factorial_single_values(Number)->
  {
    {fourth, timer:tc(factorial,factorial2,[Number])},
    {fifth, timer:tc(factorial,fact,[Number])}
  }.


factorial(0, _)->1;
factorial(Number, _)
  when not is_number(Number) orelse
  Number < 0 -> undefined;
factorial(Number, Mode)->
  case Mode of
    first  -> factorial1(Number, 1);
    second -> factorial2(Number);
    third  -> factorial3(Number);
    _ -> undefined
  end.

factorial1(1, Acc)->Acc;
factorial1(Number, Acc)->
  factorial1(Number-1, Acc*Number).



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

%%------------------------------------
factorial5(List)->
  factorial5(List, []).
factorial5([], Result)->Result;
factorial5([H | T], Result)->
  factorial5(T, [factorial2(H) | Result]).

factorial2(1)->1;
factorial2(Number)->
  timer:sleep(5),
  Number*factorial2(Number-1).
%%------------------------------------
factorial4(List)->
  factorial4_receiver(List,length(List), []).

factorial4_receiver([],0,Result)->Result;
factorial4_receiver([],Length,Result) ->
  receive
    Value -> factorial4_receiver([],Length-1,[Value|Result])
  end;
factorial4_receiver([H|T],Length,Result) ->
  spawn(factorial, factorial4_worker,[H,1,self()]),
  receive
    Value -> factorial4_receiver(T,Length-1,[Value|Result])
    after 0 -> factorial4_receiver(T,Length,Result)
  end.
factorial4_worker(1, Acc, R_PID)->R_PID ! Acc;
factorial4_worker(Number, Acc, R_PID)->
  timer:sleep(5),
  factorial4_worker(Number-1, Acc*Number, R_PID).




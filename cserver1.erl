-module(cserver1).
-export([start/0, loop/0,calculate/1, my_spawn/3]).

%start() -> spawn(cserver, loop, []).
 start() -> my_spawn(cserver1, loop, []).	
% start() -> 
% 	register(cserver1, spawn(fun() -> my_spawn(cserver, loop, []) end)).	

calculate(What) ->
%	io:format("calculate's Pid is ~p~n", [Pid]),
	rpc(What).

rpc(Request) ->
	%io:format("rpc's Pid is ~p~n", [Pid]),
	cserver1 ! {self(), Request},
	receive
		{Pid, Response} ->
			io:format("rpc receive's Pid is ~p~n", [Pid]),
			Response;
		Other ->
		 io:format("resceive other ~p", [Other])
    after 1000 ->
    	timeout
	end.

loop() ->
	receive			%接收请求的代码
		{From, {A, '+', B}} ->
			io:format("loop receive's Pid is ~p~n", [From]),
			From ! {self(), A + B},  %向发送请求的进程发送一个响应,self()是客户端进程标识符,客户端加入的服务器可以回复的地址.
			io:format("the add result is ~p~n", [A + B]),
			loop();
		{From, {A, '-', B}} ->
			From ! {self(), A - B},
			io:format("the sub result is ~p~n", [A - B]),
			loop();
		{From, {A, '*', B}} ->
			From ! {self(), A * B},
			io:format("the mul result is ~p~n", [A * B]),
			loop();
		{From, {A, '/', B}} ->
			io:format("loop receive's Pid is ~p~n", [From]),
				try From ! {self(), A div B} of
				 % when	B =:= 0 ->
					% 	From ! {self(),{error, io:format("B can't  be 0!")}},
     %    	 			exit(io:format("now process exit")),
     %    	 			loop(); 
					_ -> 
			 			io:format("the division result is ~p~n", [A div B]),
						loop()
				catch
					%_ : _ -> {_, caught, error, _}

					 throw : X -> io:format("throw the Resson is ~p~n", [X]);   % ; not ,
					 error : X -> io:format("error the Resson is ~p~n", [X]),
					 From ! {self(),{error, io:format("exit!!!")}},
					 	%exit(io:format("exit!!!")),
					 	loop();
 					 exit : X -> io:format("exit the Resson is ~p~n", [X])
 					% From ! {self(), {error, _}},
					 % _ : _ -> 
					 % 	From ! {self(),{error, io:format("exit!!!")}},
					 % 	exit(io:format("exit!!!")),
					 % 	loop()
					% loop();
% 					 exit()  %%%!!!!
				end;   % no . have ;
		% {From, Other} ->
		% 	 From ! {self(),{error, Other}},
		% 	 loop() ;    % .
		%{ok, Message} ->
		{From, Message} ->
		     % try From ! {self(),{error, Message}} of
		     % 	_ ->
		     % 		loop();
		     % 	B =:= 0 ->
		     % 		exit()	

		     % catch
		     % 	pattern when guard ->
		     % 		body
		     % after
		     % 	body
		     % end
			 From ! {self(),{error, Message}},   %%% ! no this case, there will no next shell time, can't put in
             exit(Message),
             loop()

   
%        after 5000 ->
%              io:format("还在运行~n"),
%             loop()      	
										
	end.


% start_link(Args) ->
%     supervisor:start_link({local,?MODULE}, ?MODULE, Args).	


my_spawn(Mod, Func, Args) ->
	Pid = spawn(Mod, Func, Args),
	register(cserver1, Pid),
	spawn(fun() ->
			Ref = monitor(process, Pid),
			io:format("the monitor's Pid is: ~p~n",[Pid]),
			receive
				{'DOWN', Ref, process, Pid, Why} ->
					io:format("the my_spawn receive Pid is: ~p~n",[Pid]),
					%spawn(Mod, Func, Args),
					io:format("died with:~p~n, now restart...",[Why]),
					%spawn_link(Func),				
					%monitor(process, Pid)
					my_spawn(Mod, Func, Args),
					process_flag(trap_exit,true),  %%% no this case,  div 0 will crash and can't creat a new percess
%					start_link(Args),
					io:format("restart complete ~n")
			end
		end),
		Pid.	
		

% on_exit(Pid, Fun) ->  
% 	spawn(fun() ->
% 			Ref = monitor(process, Pid), 
% 			receive     
% 				{'DOWN', Ref, process, Pid, Why} ->
% 				io:format("~p died with: ~p~n", [Pid, Why]),
% 				Fun(Why)
% %				loop()
% 			end
% 		end).		

% keep_alive(Name, Fun) ->
% 		register(Name, Pid = spawn(Fun)),
% 		on_exit(Pid, fun(_Why) -> keep_alive(Name, Fun) end).


%%cserver:on_exit(Pid,fun(Why) -> io:format("~p died with ~n", [Pid, Why]) end).
%%cserver:keep_alive(Pid, fun(Why) -> io:format("~p died with ~n", [Pid,Why]) end).






%% name of module must match file name
-module(mod_http_offline).

-author("Earl The Squirrel").

%% Every ejabberd module implements the gen_mod behavior
%% The gen_mod behavior requires two functions: start/2 and stop/1
-behaviour(gen_mod).

%% public methods for this module
-export([start/2, stop/1, create_message/3]).

%% included for writing to ejabberd log file
-include("ejabberd.hrl").

%% ejabberd functions for JID manipulation called jlib.
-include("jlib.hrl").

start(_Host, _Opt) -> 
		?INFO_MSG("mod_http_offline loading", []),
		inets:start(),
		?INFO_MSG("HTTP client started", []),
		post_offline_message("testFrom", "testTo", "testBody"),
		ejabberd_hooks:add(offline_message_hook, _Host, ?MODULE, create_message, 50).   



stop (_Host) -> 
		?INFO_MSG("stopping mod_http_offline", []),
		ejabberd_hooks:delete(offline_message_hook, _Host, ?MODULE, create_message, 50).



create_message(_From, _To, Packet) ->
		Type = xml:get_tag_attr_s("type", Packet),
		FromS = xml:get_tag_attr_s("from", Packet),
		ToS = xml:get_tag_attr_s("to", Packet),
		Body = xml:get_path_s(Packet, [{elem, "body"}, cdata]),
		if (Type == "chat") ->
			post_offline_message(FromS, ToS, Body)
		end.



post_offline_message(From, To, Body) ->
		?INFO_MSG("Posting From ~p To ~p Body ~p~n",[From, To, Body]),
		 http:request(post, {"http://localhost/OfflineDemoWebhost/Message/Process",[], 
		 "application/x-www-form-urlencoded",
		 lists:concat(["From=", From,"&To=", To,"&Body=", Body])}, [], []),
		?INFO_MSG("post request sent", []).

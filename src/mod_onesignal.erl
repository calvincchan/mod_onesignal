%%%----------------------------------------------------------------------

%%% File    : mod_onesignal.erl
%%% Author  : Philipp Homann <phomann@wwwpage.de>
%%% Purpose : Forward offline messages to push provider OneSignal
%%% Created : 29 Feb 2016 by Philipp Homann <phomann@wwwpage.de>
%%%
%%%
%%% Copyright (C) 2016   Philipp Homann
%%%
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License
%%% along with this program; if not, write to the Free Software
%%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
%%% 02111-1307 USA
%%%
%%%----------------------------------------------------------------------

-module(mod_onesignal).
-author('phomann@wwwpage.de').

-behaviour(gen_mod).

-export([start/2,
	 stop/1,
	 send_notice/3]).

-define(PROCNAME, ?MODULE).

-include("ejabberd.hrl").
-include("jlib.hrl").

start(Host, _Opts) ->
    ?INFO_MSG("Starting mod_onesignal for host \"~s\"", [Host] ),
    inets:start(),
    ssl:start(),
    ejabberd_hooks:add(offline_message_hook, Host, ?MODULE, send_notice, 10),
    ok.

stop(Host) ->
    ?INFO_MSG("Stopping mod_onesignal for host \"~s\"", [Host] ),
    ejabberd_hooks:delete(offline_message_hook, Host,
			  ?MODULE, send_notice, 10),
    ok.

send_notice(From, To, Packet) ->
    Type = xml:get_tag_attr_s("type", Packet),
    Sender = [From#jid.luser],
    Receipient = [To#jid.luser],
    Message = xml:get_path_s(Packet, [{elem, "body"}, cdata]),    
    API_Key = ["Basic ",gen_mod:get_module_opt(To#jid.lserver, ?MODULE, api_key, [] )],
    App_Id = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, app_id, [] ),    
    PostUrl = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, post_url, [] ),

    if (Type == "chat") and (Message /= "") ->
        RequestBody = [
            "{
                \"app_id\": \"",App_Id,"\",
                \"included_segments\": [\"",Receipient,"\"],
                \"contents\": {\"en\": \"",Sender,": ",Message,"\"}
            }"],


        ?INFO_MSG("Sending post request to ~s with body \"~s\"", [PostUrl, RequestBody]),
        httpc:request(post, {PostUrl, [{"Authorization",API_Key}], "application/json", list_to_binary(RequestBody)},[],[]),
        ok;
      true ->
        ok
    end.



defmodule Ejabberd.Module.FOAF do
  @behaviour :gen_mod
  
  require Logger
  require Record
  
  Record.defrecord :jid, Record.extract(:jid, from_lib: "ejabberd/include/jlib.hrl")
  Record.defrecord :roster, Record.extract(:roster, from_lib: "ejabberd/include/mod_roster.hrl")
  
  ##
  ## Module Life-cycle
  ##
  
  def start(host, _opts) do
    Logger.info "Starting module #{__ENV__.module}"
    :gen_iq_handler.add_iq_handler(:ejabberd_sm,
                                   host,
                                   "http://example.com/foaf",
                                   __ENV__.module,
                                   :process_remote_iq,
                                   :parallel)
    :ok
  end
  
  def stop(host) do
    Logger.info "Stopping module #{__ENV__.module}"
    :gen_iq_handler.remove_iq_handler(:ejabberd_sm,
                                      host,
                                      "http://example.com/foaf",
                                      __ENV__.module,
                                      :process_remote_iq,
                                      :parallel)
    :ok
  end
  
  ##
  ## IQ Handling
  ##
  
  def process_remote_iq(from, to, {:iq, id, :get, namespace, lang, _query} = stanza) do
    user = jid(to, :luser)
    host = jid(to, :lserver)    
    friend = {jid(from, :luser), jid(from, :lserver), ""}
    
    friends = get_friends(host, user, friend)
    
    response = Enum.map friends, fn(friend) ->
      {:xmlel, "foaf", [{"jid", :jlib.jid_to_string(friend)}], []}
    end
      
    {:iq, id, :result, namespace, lang, [{:xmlel, "query", [{"xmlns", namespace}], response}]}
  end
  
  def process_remote_iq(_, _, _), do: :ignore
  
  ##
  ## Get List of Friends
  ##
  
  def get_friends(host, user, jid) do
    jid_info = get_roster_jid_info(host, user, jid)
    case jid_info do
      {:both, groups} ->
        roster = get_roster(host, user)
        get_friends_from_roster(roster, groups, [])
      _ -> []
    end
  end
  
  ## Private
  
  defp get_friends_from_roster([], _, friends), do: friends
  
  defp get_friends_from_roster([item | items], groups, friends) do
    new_friends = case roster(item, :subscription) do
      :both ->
        case Enum.any?(roster(item, :groups), fn(group) -> Enum.member?(groups, group) end) do
          true  -> [roster(item, :jid)]
          false -> []
        end
        _ -> []
    end
    get_friends_from_roster(items, groups, friends ++ new_friends)
  end
  
  ##
  ## Accessing the Roster
  ##
  
  defp get_roster_jid_info(host, user, jid) do
    :ejabberd_hooks.run_fold(:roster_get_jid_info,
                             host,
                             {:none, []},
                             [user, host, :jlib.make_jid(jid)])
  end
  
  defp get_roster(host, user) do
	  :ejabberd_hooks.run_fold(:roster_get,
                             host,
                             [],
                             [{user, host}])
  end
  
end

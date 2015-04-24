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
    Logger.info "Starting ejabberd module #{__ENV__.module}"
    :gen_iq_handler.add_iq_handler(:ejabberd_sm,
                                   host,
                                   "http://example.com/foaf",
                                   __ENV__.module,
                                   :process_remote_iq,
                                   :parallel)
    :ok
  end
  
  def stop(host) do
    Logger.info "Stopping ejabberd module #{__ENV__.module}"
    :gen_iq_handler.remove_iq_handler(:ejabberd_sm,
                                      host,
                                      "http://example.com/foaf",
                                      __ENV__.module,
                                      :process_remote_iq, :parallel)
    :ok
  end
  
  ##
  ## IQ Handling
  ##
  
  def process_remote_iq(from, to, {:iq, id, :get, namespace, lang, _query} = stanza) do
    Logger.debug "From: #{inspect from} To: #{inspect to} Stanza: #{inspect stanza}"
    
    user = jid(to, :luser)
    host = jid(to, :lserver)    
    friend = {jid(from, :luser), jid(from, :lserver), ""}

    friends = get_friends(host, user, friend)
    
    Logger.debug "Friends #{user}@#{host} -> #{inspect friend}: #{inspect friends}"
    
    response = Enum.map friends, fn(friend) -> {:xmlel, "foaf", [{"jid", :jlib.jid_to_string(friend)}], []} end    
    {:iq, id, :result, namespace, lang, [{:xmlel, "query", [{"xmlns", namespace}], response}]}
  end
  
  def process_remote_iq(_from, _to, {:iq, id, :set, namespace, lang, _query}) do
    {:iq, id, :error, namespace, lang,
      [{:xmlel, "error", [{"code", "405"},
                          {"type", "cancel"}],
    		                 [{:xmlel, "not-allowed", [{"xmlns", "urn:ietf:params:xml:ns:xmpp-stanzas"}],
                                                  []}]}]}
  end
  
  def process_remote_iq(_from, _to, _stanza), do: :ignore
  
  ##
  ## Get List of Friends
  ##
  
  def get_friends(host, user, friend) do
    
    friend_info = get_roster_jid_info(host, user, friend)
        
    case friend_info do
      {:both, groups} ->
        get_roster(host, user)
        |> get_friends_from_roster groups
      _ -> []
    end
  end
  
  defp get_friends_from_roster(items, groups), do: get_friends_from_roster(items, groups, [])
  
  defp get_friends_from_roster([item | items], groups, friends) do
    case roster(item, :subscription) do
      :both ->
        case Enum.any?(roster(item, :groups), fn(group) -> Enum.member?(groups, group) end) do
          true ->
            get_friends_from_roster(items, groups, friends ++ [roster(item, :jid)])
          false ->
            get_friends_from_roster(items, groups, friends)
        end
        _ -> get_friends_from_roster(items, groups, friends)
    end
  end
  
  defp get_friends_from_roster([], _, friends), do: friends
  
  ##
  ## Accessing the Roster
  ##
  
  defp get_roster_jid_info(host, user, ljid) do
    :ejabberd_hooks.run_fold(:roster_get_jid_info,
                             host,
                             {:none, []},
                             [user, host, :jlib.make_jid(ljid)])
  end
  
  defp get_roster(host, user) do
	  :ejabberd_hooks.run_fold(:roster_get,
                             host,
                             [],
                             [{user, host}])
  end
  
end

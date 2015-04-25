defmodule Ejabberd.Module.FOAFTest do
  use ExUnit.Case
  
  require Logger
  
  setup_all do
    Ejabberd.Hooks.add(:roster_get, "localhost", __ENV__.module, :get_roster, 60)
    Ejabberd.Hooks.add(:roster_get_jid_info, "localhost", __ENV__.module, :get_roster_jid_info, 60)
    on_exit fn ->
      Ejabberd.Hooks.delete(:roster_get, "localhost", __ENV__.module, :get_roster, 60)
      Ejabberd.Hooks.delete(:roster_get_jid_info, "localhost", __ENV__.module, :get_roster_jid_info, 60)
    end
  end
  
  ##
  ## Tests
  ##
  
  test "that the module returns a list of friends" do
    host = "localhost"
    user = "romeo"
    jid = {"juliet", "localhost", ""}
    
    friends = Ejabberd.Module.FOAF.get_friends(host, user, jid)
    assert friends == [
      {"mercutio", "localhost", ""},
      {"tybalt", "localhost", ""},
      {"peter", "localhost", ""},
      {"benvolio", "localhost", ""},
      {"juliet", "localhost", ""}
    ]
  end
  
  ##
  ## Test Helper
  ##
  
  def get_roster(roster, {user, host}) do
    [
      roster_item({user, host}, {"mom", "localhost", ""}, :both, ["Family"]),
      roster_item({user, host}, {"dad", "localhost", ""}, :both, ["Family"]),
      roster_item({user, host}, {"mercutio", "localhost", ""}, :both, ["Friends"]),
      roster_item({user, host}, {"tybalt", "localhost", ""}, :both, ["Friends"]),
      roster_item({user, host}, {"peter", "localhost", ""}, :both, ["Friends"]),
      roster_item({user, host}, {"paul", "localhost", ""}, :from, ["Friends"]),
      roster_item({user, host}, {"benvolio", "localhost", ""}, :both, ["Friends"]),
      roster_item({user, host}, {"juliet", "localhost", ""}, :both, ["Friends", "Lovers"])
    ]
  end
  
  def get_roster_jid_info({_subscription, groups}, "romeo", "localhost", {:jid, "juliet", "localhost", "", "juliet", "localhost", ""}) do
    {:both, ["Friends", "Lovers"]}
  end
  
  def get_roster_jid_info(info, _, _, _), do: info
  
  def roster_item({user, server}, jid, subscription, groups) do
    {:roster, {user, server, jid}, {user, server}, jid, "", subscription, :none, groups, "", []}
  end
  
end

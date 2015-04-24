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
    friend = {"juliet", "localhost", ""}
    
    friends = Ejabberd.Module.FOAF.get_friends(host, user, friend)
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
  
  def get_roster(roster, user) do
    [
      roster_item(user, {"mom", "localhost", ""}, :both, ["Family"]),
      roster_item(user, {"dad", "localhost", ""}, :both, ["Family"]),
      roster_item(user, {"mercutio", "localhost", ""}, :both, ["Friends"]),
      roster_item(user, {"tybalt", "localhost", ""}, :both, ["Friends"]),
      roster_item(user, {"peter", "localhost", ""}, :both, ["Friends"]),
      roster_item(user, {"paul", "localhost", ""}, :from, ["Friends"]),
      roster_item(user, {"benvolio", "localhost", ""}, :both, ["Friends"]),
      roster_item(user, {"juliet", "localhost", ""}, :both, ["Friends", "Lovers"])
    ] ++ roster
  end
  
  def get_roster_jid_info({_subscription, groups}, "romeo", "localhost", {:jid, "juliet", "localhost", "", "juliet", "localhost", ""}) do
    {:both, groups ++ ["Friends", "Lovers"]}
  end
  
  def get_roster_jid_info(info, _, _, _), do: info
  
  def roster_item({user, server}, friend, subscription, groups) do
    {:roster, {user, server, friend}, {user, server}, friend, "", subscription, :none, groups, "", []}
  end
  
end

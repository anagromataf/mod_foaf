use Mix.Config

config :ejabberd,
  file: "config/ejabberd.yml",
  log_path: "var/#{Mix.env}/ejabberd.log"

config :mnesia,
  dir: String.to_char_list("var/#{Mix.env}/db/")

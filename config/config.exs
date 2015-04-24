use Mix.Config

config :logger, :console,
  level: :debug,
  format: "$date $time [$level] $metadata$message\n",
  metadata: [:user_id]

config :ejabberd,
  file: "config/ejabberd.yml",
  log_path: 'var/logs/ejabberd.log'

config :mnesia,
  dir: String.to_char_list("var/db/#{Mix.env}/")

defmodule Ejabberd.Module.FOAF.Mixfile do
  use Mix.Project

  def project do
    [app: :mod_foaf,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :ejabberd]]
  end
  
  defp deps do
    [{:ejabberd, github: "processone/ejabberd", tag: "15.04"}]
  end
end

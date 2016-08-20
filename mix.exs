defmodule Marker.Mixfile do
  use Mix.Project

  @description """
  Marker strives to be the most convenient tool for writing html markup in Elixir.
  It allows writing markup with Elixir syntax, while reaching the performance of precompiled templates.
  """

  @package [
    name: :marker,
    files: ~w(lib test mix.exs README.md LICENSE),
    maintainers: ["Vincent Siliakus"],
    licenses: ["Apache 2.0"],
    links: %{"Github" => "https://github.com/zambal/marker"}
  ]

  def project do
    [app: :marker,
     version: "1.1.1",
     elixir: "~> 1.2",
     source_url: "https://github.com/zambal/marker",
     description: @description,
     package: @package,
     deps: deps()]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end
end

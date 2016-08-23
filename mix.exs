defmodule Marker.Mixfile do
  use Mix.Project

  @description """
  Small and performant library for writing HTML markup in Elixir using templates and components
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
     version: "2.0.2",
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

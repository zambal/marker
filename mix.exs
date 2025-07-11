defmodule Marker.MixProject do
  use Mix.Project

  def project do
    [
      app: :marker,
      version: "2.1.1",
      elixir: "~> 1.2",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Package
      name: "Marker",
      source_url: "https://github.com/zambal/marker",
      description: """
      Small and performant library for writing HTML markup in Elixir using templates and components
      """,
      package: [
        name: :marker,
        files: ~w(lib test mix.exs README.md LICENSE),
        maintainers: ["Vincent Siliakus"],
        licenses: ["Apache-2.0"],
        links: %{"Github" => "https://github.com/zambal/marker"}
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev, runtime: false, warn_if_outdated: true}]
  end
end

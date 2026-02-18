defmodule ReqValhalla.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/alemoreau/req_valhalla"

  def project do
    [
      app: :req_valhalla,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "ReqValhalla",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    A lightweight Elixir client for the Valhalla routing API built on Req.
    Supports routing, isochrones, matrices, optimized routes, and more.
    """
  end

  defp deps do
    [
      {:req, "~> 0.4.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "req_valhalla",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      maintainers: ["Alexandre Moreau"]
    ]
  end

  defp docs do
    [
      main: "ReqValhalla",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      formatters: ["html"]
    ]
  end
end

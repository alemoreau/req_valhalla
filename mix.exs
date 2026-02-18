defmodule ValhallaReqClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :valhalla_req_client,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "An Elixir client for Valhalla routing API using Req",
      package: package(),
      name: "ValhallaReqClient",
      source_url: "https://github.com/alemoreau/valhalla-req-client"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.4.0"},
      {:jason, "~> 1.4"}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alemoreau/valhalla-req-client"}
    ]
  end
end

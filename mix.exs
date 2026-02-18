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
      {:req, github: "wojtekmach/req", tag: "v0.4.14"},
      {:jason, github: "michalmuskala/jason", tag: "v1.4.1", override: true},
      {:mime, github: "elixir-plug/mime", tag: "v2.0.5", override: true},
      {:finch, github: "sneako/finch", tag: "v0.18.0", override: true},
      {:nimble_options, github: "dashbitco/nimble_options", tag: "v1.1.0", override: true},
      {:nimble_pool, github: "dashbitco/nimble_pool", tag: "v1.0.0", override: true},
      {:castore, github: "elixir-mint/castore", tag: "v1.0.5", override: true},
      {:mint, github: "elixir-mint/mint", tag: "v1.5.2", override: true},
      {:hpax, github: "elixir-mint/hpax", tag: "v0.2.0", override: true},
      {:telemetry, github: "beam-telemetry/telemetry", tag: "v1.2.1", override: true},
      {:nimble_ownership, github: "dashbitco/nimble_ownership", tag: "v0.3.0", override: true}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alemoreau/valhalla-req-client"}
    ]
  end
end

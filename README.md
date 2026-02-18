# ReqValhalla

An Elixir client for the [Valhalla](https://github.com/valhalla/valhalla) routing API using [Req](https://github.com/wojtekmach/req).

## Features

- 🗺️ **Routing**: Calculate routes between multiple points with various transportation modes
- 🎯 **Locate**: Find nearest roads to given coordinates
- ⏱️ **Isochrones**: Generate time-distance polygons
- 📊 **Matrix**: Compute time-distance matrices for multiple origin-destination pairs
- 🔄 **Optimized Routes**: Get optimized routes visiting multiple locations
- 📍 **Trace Route**: Match GPS traces to road network
- 📏 **Trace Attributes**: Get road attributes along a path
- ⛰️ **Elevation**: Get elevation data for locations
- ✅ **Status**: Check service availability

## Installation

Add `req_valhalla` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:req_valhalla, "~> 0.1.0"}
  ]
end
```

## Configuration

Configure the base URL for your Valhalla instance in `config/config.exs`:

```elixir
config :req_valhalla,
  base_url: "http://your-valhalla-instance.com"
```

## Usage

### Routing

Calculate a route between two or more points:

```elixir
# Simple route between two points
locations = [
  %{lat: 48.8566, lon: 2.3522},  # Paris
  %{lat: 48.8698, lon: 2.3467}   # Destination
]

{:ok, response} = ReqValhalla.route(locations, costing: "auto")
```

### Isochrones

Generate isochrone polygons (areas reachable within a time limit):

```elixir
location = %{lat: 48.8566, lon: 2.3522}

{:ok, response} = ReqValhalla.isochrone(
  location,
  contours: [%{time: 10}, %{time: 20}, %{time: 30}],
  costing: "pedestrian"
)
```

### Time-Distance Matrix

Compute travel times and distances between multiple points:

```elixir
sources = [%{lat: 48.8566, lon: 2.3522}]
targets = [
  %{lat: 48.8698, lon: 2.3467},
  %{lat: 48.8606, lon: 2.3376}
]

{:ok, response} = ReqValhalla.matrix(sources, targets, costing: "auto")
```

### Optimized Route

Find the optimal order to visit multiple locations:

```elixir
locations = [
  %{lat: 48.8566, lon: 2.3522},
  %{lat: 48.8698, lon: 2.3467},
  %{lat: 48.8606, lon: 2.3376}
]

{:ok, response} = ReqValhalla.optimized_route(locations, costing: "auto")
```

### GPS Trace Matching

Match a GPS trace to the road network:

```elixir
shape = [
  %{lat: 48.8566, lon: 2.3522},
  %{lat: 48.8570, lon: 2.3525},
  %{lat: 48.8580, lon: 2.3530}
]

{:ok, response} = ReqValhalla.trace_route(shape, costing: "auto")
```

### Elevation Data

Get elevation information for points:

```elixir
shape = [
  %{lat: 48.8566, lon: 2.3522},
  %{lat: 48.8698, lon: 2.3467}
]

{:ok, response} = ReqValhalla.height(shape)
```

### Service Status

Check if the Valhalla service is available:

```elixir
{:ok, status} = ReqValhalla.status()
```

## Costing Models

The following costing models (transportation modes) are supported:

- `"auto"` - Car routing
- `"bicycle"` - Bicycle routing
- `"pedestrian"` - Walking routes
- `"truck"` - Truck routing with vehicle restrictions
- `"motorcycle"` - Motorcycle routing
- `"bus"` - Bus routing
- `"motor_scooter"` - Motor scooter routing

## Testing

Run the test suite:

```bash
mix test
```

The tests will attempt to connect to a Valhalla instance. By default, they use the test server at `http://routing-valhalla-borcmc-1f2411-145-223-34-60.traefik.me/`.

You can override the test URL using the `VALHALLA_TEST_URL` environment variable:

```bash
VALHALLA_TEST_URL=http://your-valhalla-server.com mix test
```

### Continuous Integration

This project uses GitHub Actions to run tests across multiple Elixir and OTP versions:
- Elixir 1.14.x - 1.16.x
- OTP 25.x - 26.x

The test URL can be configured in the repository settings as a repository variable named `VALHALLA_TEST_URL`.

## Documentation

For more information about the Valhalla API, see the [official documentation](https://valhalla.github.io/valhalla/api/).

## License

MIT
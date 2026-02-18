defmodule ReqValhalla do
  @moduledoc """
  An Elixir client for the Valhalla routing API using Req.

  This module provides a simple interface to interact with Valhalla's routing services,
  including routing, isochrones, matrices, and more.

  ## Configuration

  You can configure the base URL for the Valhalla service:

      config :req_valhalla,
        base_url: "http://your-valhalla-instance.com"

  ## Examples

      # Create a route between two points
      locations = [%{lat: 48.8566, lon: 2.3522}, %{lat: 48.8698, lon: 2.3467}]
      {:ok, response} = ReqValhalla.route(locations, costing: "auto")

      # Get an isochrone
      location = %{lat: 48.8566, lon: 2.3522}
      {:ok, response} = ReqValhalla.isochrone(
        location,
        contours: [%{time: 10}, %{time: 20}],
        costing: "pedestrian"
      )
  """

  @default_base_url "http://localhost:8002"

  @doc """
  Gets the configured base URL for the Valhalla service.
  """
  def base_url do
    Application.get_env(:req_valhalla, :base_url, @default_base_url)
  end

  @doc """
  Makes a POST request to the Valhalla API.

  ## Parameters
    - `endpoint`: The API endpoint (e.g., "route", "isochrone")
    - `params`: The request parameters as a map

  ## Returns
    - `{:ok, response}` on success
    - `{:error, exception}` on failure
  """
  def post(endpoint, params) do
    url = "#{base_url()}/#{endpoint}"

    case Req.post(url, json: params) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, exception} ->
        {:error, exception}
    end
  end

  @doc """
  Calculates a route between multiple locations.

  ## Parameters
    - `locations`: A list of location maps with `:lat` and `:lon` keys
    - `opts`: Additional options such as `:costing`, `:units`, `:directions_options`, etc.

  ## Options
    - `:costing` - The costing model: "auto", "bicycle", "pedestrian", "truck", etc. (default: "auto")
    - `:units` - Distance units: "kilometers" or "miles" (default: "kilometers")
    - `:language` - Language for instructions (default: "en-US")
    - `:directions_options` - Options for turn-by-turn directions
    - `:exclude_locations` - Locations to exclude from the route
    - `:date_time` - Departure or arrival time information

  ## Examples

      iex> locations = [%{lat: 48.8566, lon: 2.3522}, %{lat: 48.8698, lon: 2.3467}]
      iex> {:ok, response} = ReqValhalla.route(locations, costing: "auto")
      iex> is_map(response)
      true
  """
  def route(locations, opts \\ []) do
    costing = Keyword.get(opts, :costing, "auto")
    units = Keyword.get(opts, :units, "kilometers")

    params =
      %{
        locations: locations,
        costing: costing,
        units: units
      }
      |> maybe_add(:language, Keyword.get(opts, :language))
      |> maybe_add(:directions_options, Keyword.get(opts, :directions_options))
      |> maybe_add(:exclude_locations, Keyword.get(opts, :exclude_locations))
      |> maybe_add(:date_time, Keyword.get(opts, :date_time))
      |> maybe_add(:costing_options, Keyword.get(opts, :costing_options))

    post("route", params)
  end

  @doc """
  Finds the nearest roads to the given location(s).

  ## Parameters
    - `locations`: A single location map or list of location maps with `:lat` and `:lon` keys
    - `opts`: Additional options

  ## Examples

      iex> location = %{lat: 48.8566, lon: 2.3522}
      iex> {:ok, response} = ReqValhalla.locate(location)
      iex> is_list(response) or is_map(response)
      true
  """
  def locate(locations, opts \\ []) when is_map(locations) or is_list(locations) do
    locations = if is_map(locations), do: [locations], else: locations

    params =
      %{locations: locations}
      |> maybe_add(:verbose, Keyword.get(opts, :verbose))

    post("locate", params)
  end

  @doc """
  Generates an isochrone (time-distance polygon) from a location.

  ## Parameters
    - `location`: A location map with `:lat` and `:lon` keys
    - `opts`: Options including `:contours`, `:costing`, etc.

  ## Options
    - `:contours` - List of contour maps with `:time` (in minutes) or `:distance` keys
    - `:costing` - The costing model (default: "auto")
    - `:polygons` - Whether to return polygons (default: true)
    - `:denoise` - Remove small contours (default: 1.0)
    - `:generalize` - Generalize the contours (default: based on meters)

  ## Examples

      iex> location = %{lat: 48.8566, lon: 2.3522}
      iex> {:ok, response} = ReqValhalla.isochrone(
      ...>   location,
      ...>   contours: [%{time: 10}, %{time: 20}, %{time: 30}],
      ...>   costing: "pedestrian"
      ...> )
      iex> is_map(response)
      true
  """
  def isochrone(location, opts \\ []) do
    contours = Keyword.get(opts, :contours, [%{time: 15}])
    costing = Keyword.get(opts, :costing, "auto")

    params =
      %{
        locations: [location],
        contours: contours,
        costing: costing
      }
      |> maybe_add(:polygons, Keyword.get(opts, :polygons))
      |> maybe_add(:denoise, Keyword.get(opts, :denoise))
      |> maybe_add(:generalize, Keyword.get(opts, :generalize))
      |> maybe_add(:costing_options, Keyword.get(opts, :costing_options))

    post("isochrone", params)
  end

  @doc """
  Computes a time-distance matrix for multiple origin and destination pairs.

  ## Parameters
    - `sources`: List of source location maps
    - `targets`: List of target location maps
    - `opts`: Options including `:costing`, `:units`, etc.

  ## Examples

      iex> sources = [%{lat: 48.8566, lon: 2.3522}]
      iex> targets = [%{lat: 48.8698, lon: 2.3467}, %{lat: 48.8606, lon: 2.3376}]
      iex> {:ok, response} = ReqValhalla.matrix(sources, targets, costing: "auto")
      iex> is_map(response)
      true
  """
  def matrix(sources, targets, opts \\ []) do
    costing = Keyword.get(opts, :costing, "auto")
    units = Keyword.get(opts, :units, "kilometers")

    params =
      %{
        sources: sources,
        targets: targets,
        costing: costing,
        units: units
      }
      |> maybe_add(:costing_options, Keyword.get(opts, :costing_options))

    post("sources_to_targets", params)
  end

  @doc """
  Computes an optimized route visiting all locations.

  ## Parameters
    - `locations`: List of location maps to visit
    - `opts`: Options including `:costing`, `:units`, etc.

  ## Examples

      iex> locations = [
      ...>   %{lat: 48.8566, lon: 2.3522},
      ...>   %{lat: 48.8698, lon: 2.3467},
      ...>   %{lat: 48.8606, lon: 2.3376}
      ...> ]
      iex> {:ok, response} = ReqValhalla.optimized_route(locations, costing: "auto")
      iex> is_map(response)
      true
  """
  def optimized_route(locations, opts \\ []) do
    costing = Keyword.get(opts, :costing, "auto")
    units = Keyword.get(opts, :units, "kilometers")

    params =
      %{
        locations: locations,
        costing: costing,
        units: units
      }
      |> maybe_add(:costing_options, Keyword.get(opts, :costing_options))

    post("optimized_route", params)
  end

  @doc """
  Matches a GPS trace to the road network.

  ## Parameters
    - `shape`: List of GPS points with `:lat` and `:lon` keys
    - `opts`: Options including `:costing`, `:shape_match`, etc.

  ## Examples

      iex> shape = [
      ...>   %{lat: 48.8566, lon: 2.3522},
      ...>   %{lat: 48.8570, lon: 2.3525},
      ...>   %{lat: 48.8698, lon: 2.3467}
      ...> ]
      iex> {:ok, response} = ReqValhalla.trace_route(shape, costing: "auto")
      iex> is_map(response)
      true
  """
  def trace_route(shape, opts \\ []) do
    costing = Keyword.get(opts, :costing, "auto")
    shape_match = Keyword.get(opts, :shape_match, "map_snap")

    params =
      %{
        shape: shape,
        costing: costing,
        shape_match: shape_match
      }
      |> maybe_add(:costing_options, Keyword.get(opts, :costing_options))
      |> maybe_add(:begin_time, Keyword.get(opts, :begin_time))

    post("trace_route", params)
  end

  @doc """
  Gets attributes along a path matched to the road network.

  ## Parameters
    - `shape`: List of GPS points with `:lat` and `:lon` keys
    - `opts`: Options including `:costing`, `:filters`, etc.

  ## Examples

      iex> shape = [
      ...>   %{lat: 48.8566, lon: 2.3522},
      ...>   %{lat: 48.8698, lon: 2.3467}
      ...> ]
      iex> {:ok, response} = ReqValhalla.trace_attributes(shape, costing: "auto")
      iex> is_map(response)
      true
  """
  def trace_attributes(shape, opts \\ []) do
    costing = Keyword.get(opts, :costing, "auto")
    shape_match = Keyword.get(opts, :shape_match, "map_snap")

    params =
      %{
        shape: shape,
        costing: costing,
        shape_match: shape_match
      }
      |> maybe_add(:costing_options, Keyword.get(opts, :costing_options))
      |> maybe_add(:filters, Keyword.get(opts, :filters))

    post("trace_attributes", params)
  end

  @doc """
  Gets elevation data for a set of locations or a path.

  ## Parameters
    - `shape`: List of location maps with `:lat` and `:lon` keys
    - `opts`: Additional options

  ## Examples

      iex> shape = [%{lat: 48.8566, lon: 2.3522}, %{lat: 48.8698, lon: 2.3467}]
      iex> {:ok, response} = ReqValhalla.height(shape)
      iex> is_map(response)
      true
  """
  def height(shape, opts \\ []) do
    params =
      %{shape: shape}
      |> maybe_add(:range, Keyword.get(opts, :range))

    post("height", params)
  end

  @doc """
  Checks the status of the Valhalla service.

  ## Examples

      iex> {:ok, status} = ReqValhalla.status()
      iex> is_map(status)
      true
  """
  def status do
    url = "#{base_url()}/status"

    case Req.get(url) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, exception} ->
        {:error, exception}
    end
  end

  # Private helper to conditionally add fields to a map
  defp maybe_add(map, _key, nil), do: map
  defp maybe_add(map, key, value), do: Map.put(map, key, value)
end

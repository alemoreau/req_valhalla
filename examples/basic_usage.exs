# Example usage of ReqValhalla

# Configure your Valhalla server URL
Application.put_env(:req_valhalla, :base_url, "http://your-valhalla-server.com")

# Example 1: Simple routing between two points
IO.puts("Example 1: Simple Routing")
IO.puts("--------------------------")

locations = [
  %{lat: 48.8566, lon: 2.3522},  # Eiffel Tower, Paris
  %{lat: 48.8606, lon: 2.3376}   # Arc de Triomphe, Paris
]

case ReqValhalla.route(locations, costing: "auto") do
  {:ok, response} ->
    trip = response["trip"]
    summary = trip["summary"]
    
    IO.puts("Distance: #{summary["length"]} km")
    IO.puts("Duration: #{summary["time"]} seconds")
    IO.puts("Legs: #{length(trip["legs"])}")
    
  {:error, reason} ->
    IO.puts("Error: #{inspect(reason)}")
end

# Example 2: Pedestrian isochrone
IO.puts("\nExample 2: Pedestrian Isochrone")
IO.puts("--------------------------------")

location = %{lat: 48.8566, lon: 2.3522}

case ReqValhalla.isochrone(
  location,
  contours: [%{time: 5}, %{time: 10}, %{time: 15}],
  costing: "pedestrian"
) do
  {:ok, response} ->
    IO.puts("Isochrone type: #{response["type"]}")
    if features = response["features"] do
      IO.puts("Number of features: #{length(features)}")
    end
    
  {:error, reason} ->
    IO.puts("Error: #{inspect(reason)}")
end

# Example 3: Time-distance matrix
IO.puts("\nExample 3: Time-Distance Matrix")
IO.puts("--------------------------------")

sources = [%{lat: 48.8566, lon: 2.3522}]

targets = [
  %{lat: 48.8698, lon: 2.3467},
  %{lat: 48.8606, lon: 2.3376},
  %{lat: 48.8529, lon: 2.3499}
]

case ReqValhalla.matrix(sources, targets, costing: "bicycle") do
  {:ok, response} ->
    IO.puts("Matrix computed successfully!")
    IO.inspect(response, label: "Matrix response")
    
  {:error, reason} ->
    IO.puts("Error: #{inspect(reason)}")
end

# Example 4: Optimized route (traveling salesman)
IO.puts("\nExample 4: Optimized Route")
IO.puts("--------------------------")

locations = [
  %{lat: 48.8566, lon: 2.3522},  # Start
  %{lat: 48.8698, lon: 2.3467},  # Point 1
  %{lat: 48.8606, lon: 2.3376},  # Point 2
  %{lat: 48.8529, lon: 2.3499}   # Point 3
]

case ReqValhalla.optimized_route(locations, costing: "auto") do
  {:ok, response} ->
    trip = response["trip"]
    summary = trip["summary"]
    
    IO.puts("Optimized distance: #{summary["length"]} km")
    IO.puts("Optimized duration: #{summary["time"]} seconds")
    
  {:error, reason} ->
    IO.puts("Error: #{inspect(reason)}")
end

# Example 5: GPS trace matching
IO.puts("\nExample 5: GPS Trace Matching")
IO.puts("------------------------------")

gps_trace = [
  %{lat: 48.8566, lon: 2.3522},
  %{lat: 48.8570, lon: 2.3525},
  %{lat: 48.8575, lon: 2.3528},
  %{lat: 48.8580, lon: 2.3530}
]

case ReqValhalla.trace_route(gps_trace, costing: "auto") do
  {:ok, response} ->
    IO.puts("GPS trace matched successfully!")
    trip = response["trip"]
    IO.puts("Matched route length: #{trip["summary"]["length"]} km")
    
  {:error, reason} ->
    IO.puts("Error: #{inspect(reason)}")
end

# Example 6: Check service status
IO.puts("\nExample 6: Service Status")
IO.puts("-------------------------")

case ReqValhalla.status() do
  {:ok, status} ->
    IO.puts("Service is available!")
    if version = status["version"] do
      IO.puts("Version: #{version}")
    end
    if actions = status["available_actions"] do
      IO.puts("Available actions: #{inspect(actions)}")
    end
    
  {:error, reason} ->
    IO.puts("Service unavailable: #{inspect(reason)}")
end

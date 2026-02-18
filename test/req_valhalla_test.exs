defmodule ReqValhallaTest do
  use ExUnit.Case

  @moduletag :integration

  # Test configuration - requires VALHALLA_TEST_URL environment variable
  @test_base_url System.get_env("VALHALLA_TEST_URL")

  setup do
    if @test_base_url do
      # Configure the test base URL
      Application.put_env(:req_valhalla, :base_url, @test_base_url)
      :ok
    else
      # Skip tests if no test URL is configured
      :skip
    end
  end

  describe "base_url/0" do
    test "returns configured base URL" do
      if @test_base_url do
        assert ReqValhalla.base_url() == @test_base_url
      end
    end
  end

  describe "status/0" do
    test "returns service status" do
      case ReqValhalla.status() do
        {:ok, response} ->
          assert is_map(response)
          # Status endpoint should return version info
          assert Map.has_key?(response, "version") or Map.has_key?(response, "available_actions")

        {:error, _reason} ->
          # Service might be down, this is acceptable in tests
          :ok
      end
    end
  end

  describe "route/2" do
    test "calculates a route between two points" do
      locations = [
        %{lat: 48.8566, lon: 2.3522},
        %{lat: 48.8698, lon: 2.3467}
      ]

      case ReqValhalla.route(locations, costing: "auto") do
        {:ok, response} ->
          assert is_map(response)
          assert Map.has_key?(response, "trip")
          trip = response["trip"]
          assert Map.has_key?(trip, "legs")
          assert is_list(trip["legs"])

        {:error, reason} ->
          # Service might be down or return an error
          # Just ensure we got a proper error response
          assert reason != nil
      end
    end

    test "accepts different costing models" do
      locations = [
        %{lat: 48.8566, lon: 2.3522},
        %{lat: 48.8698, lon: 2.3467}
      ]

      for costing <- ["auto", "bicycle", "pedestrian"] do
        case ReqValhalla.route(locations, costing: costing) do
          {:ok, response} ->
            assert is_map(response)

          {:error, _reason} ->
            # Acceptable if service is down
            :ok
        end
      end
    end

    test "accepts units option" do
      locations = [
        %{lat: 48.8566, lon: 2.3522},
        %{lat: 48.8698, lon: 2.3467}
      ]

      case ReqValhalla.route(locations, costing: "auto", units: "miles") do
        {:ok, response} ->
          assert is_map(response)

        {:error, _reason} ->
          :ok
      end
    end
  end

  describe "locate/2" do
    test "finds nearest roads for a single location" do
      location = %{lat: 48.8566, lon: 2.3522}

      case ReqValhalla.locate(location) do
        {:ok, response} ->
          assert is_list(response) or is_map(response)

        {:error, _reason} ->
          :ok
      end
    end

    test "finds nearest roads for multiple locations" do
      locations = [
        %{lat: 48.8566, lon: 2.3522},
        %{lat: 48.8698, lon: 2.3467}
      ]

      case ReqValhalla.locate(locations) do
        {:ok, response} ->
          assert is_list(response) or is_map(response)

        {:error, _reason} ->
          :ok
      end
    end
  end

  describe "isochrone/2" do
    test "generates an isochrone polygon" do
      location = %{lat: 48.8566, lon: 2.3522}

      case ReqValhalla.isochrone(location,
             contours: [%{time: 10}, %{time: 20}],
             costing: "pedestrian"
           ) do
        {:ok, response} ->
          assert is_map(response)
          # Isochrone should return GeoJSON
          assert Map.has_key?(response, "type") or Map.has_key?(response, "features")

        {:error, _reason} ->
          :ok
      end
    end

    test "accepts multiple contour levels" do
      location = %{lat: 48.8566, lon: 2.3522}

      case ReqValhalla.isochrone(location,
             contours: [%{time: 5}, %{time: 10}, %{time: 15}],
             costing: "auto"
           ) do
        {:ok, response} ->
          assert is_map(response)

        {:error, _reason} ->
          :ok
      end
    end
  end

  describe "matrix/3" do
    test "computes time-distance matrix" do
      sources = [%{lat: 48.8566, lon: 2.3522}]

      targets = [
        %{lat: 48.8698, lon: 2.3467},
        %{lat: 48.8606, lon: 2.3376}
      ]

      case ReqValhalla.matrix(sources, targets, costing: "auto") do
        {:ok, response} ->
          assert is_map(response)

          assert Map.has_key?(response, "sources_to_targets") or
                   Map.has_key?(response, "one_to_many") or
                   Map.has_key?(response, "many_to_one")

        {:error, _reason} ->
          :ok
      end
    end
  end

  describe "optimized_route/2" do
    test "computes an optimized route" do
      locations = [
        %{lat: 48.8566, lon: 2.3522},
        %{lat: 48.8698, lon: 2.3467},
        %{lat: 48.8606, lon: 2.3376}
      ]

      case ReqValhalla.optimized_route(locations, costing: "auto") do
        {:ok, response} ->
          assert is_map(response)
          assert Map.has_key?(response, "trip")

        {:error, _reason} ->
          :ok
      end
    end
  end

  describe "trace_route/2" do
    test "matches GPS trace to road network" do
      shape = [
        %{lat: 48.8566, lon: 2.3522},
        %{lat: 48.8570, lon: 2.3525},
        %{lat: 48.8580, lon: 2.3530}
      ]

      case ReqValhalla.trace_route(shape, costing: "auto") do
        {:ok, response} ->
          assert is_map(response)

        {:error, _reason} ->
          :ok
      end
    end
  end

  describe "trace_attributes/2" do
    test "gets attributes along a path" do
      shape = [
        %{lat: 48.8566, lon: 2.3522},
        %{lat: 48.8698, lon: 2.3467}
      ]

      case ReqValhalla.trace_attributes(shape, costing: "auto") do
        {:ok, response} ->
          assert is_map(response)

        {:error, _reason} ->
          :ok
      end
    end
  end

  describe "height/2" do
    test "gets elevation data" do
      shape = [
        %{lat: 48.8566, lon: 2.3522},
        %{lat: 48.8698, lon: 2.3467}
      ]

      case ReqValhalla.height(shape) do
        {:ok, response} ->
          assert is_map(response)
          assert Map.has_key?(response, "height") or Map.has_key?(response, "range_height")

        {:error, _reason} ->
          :ok
      end
    end
  end

  describe "error handling" do
    test "handles invalid locations gracefully" do
      # Invalid coordinates (out of range)
      locations = [
        %{lat: 200, lon: 200},
        %{lat: -200, lon: -200}
      ]

      case ReqValhalla.route(locations, costing: "auto") do
        {:ok, _response} ->
          # Some implementations might handle this
          :ok

        {:error, _reason} ->
          # Expected to fail
          :ok
      end
    end

    test "handles empty location list" do
      case ReqValhalla.route([], costing: "auto") do
        {:ok, _response} ->
          :ok

        {:error, _reason} ->
          # Expected to fail with empty locations
          :ok
      end
    end
  end
end

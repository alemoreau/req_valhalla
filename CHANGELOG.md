# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.2.0] - 2026-02-18

### Changed
- Updated `req` dependency from ~> 0.4.0 to ~> 0.5.0

## [0.1.0] - 2024-02-18

### Added
- Initial release of ReqValhalla (formerly valhalla_req_client)
- Support for all major Valhalla API endpoints:
  - Routing with multiple costing models (auto, bicycle, pedestrian, truck, etc.)
  - Location lookup (finding nearest roads)
  - Isochrone generation (time-distance polygons)
  - Time-distance matrix computation
  - Optimized route calculation (traveling salesman)
  - GPS trace matching to road network
  - Road attributes extraction along paths
  - Elevation data queries
  - Service status checking
- Comprehensive test suite with 16 tests
- Complete documentation with usage examples
- Example scripts demonstrating all features
- MIT License
- GitHub Actions CI with Elixir 1.14-1.19 and OTP 25-27 support
- Configurable test URL via environment variable

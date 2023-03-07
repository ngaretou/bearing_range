class Location {
  final String location;
  double? latitude;
  double? longitude;

  Location({
    required this.location,
    this.latitude,
    this.longitude,
  });
}

//Just add more locations here! If you had a list of all CGA bases you could code an import here.
List<Location> locations = [
  Location(
    location: "Enter coordinates",
  ),
  Location(location: "Get current position"),
  Location(location: "CGA Pier", latitude: 41.371601, longitude: -72.095820),
  Location(
      location: "USS Nautilus",
      latitude: 41.38718385948114,
      longitude: -72.08823090359768)
];

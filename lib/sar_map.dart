import 'package:flutter/material.dart';

import 'package:google_static_maps_controller/google_static_maps_controller.dart';
import 'google_api_key.dart';

class SarMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double vesselLatitude;
  final double vesselLongitude;
  final double piwLatitude;
  final double piwLongitude;

  const SarMap({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.vesselLatitude,
    required this.vesselLongitude,
    required this.piwLatitude,
    required this.piwLongitude,
    // required this.piwBearing,
    // required this.piwRange
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // return Placeholder();
    return StaticMap(
        googleApiKey: googleApiKey,
        width: screenWidth > 800 ? 600 : screenWidth,
        height: screenWidth > 800 ? 600 : screenWidth,
        scaleToDevicePixelRatio: true,
        visible: [
          GeocodedLocation.latLng(latitude, longitude),
          GeocodedLocation.latLng(vesselLatitude, vesselLongitude),
          GeocodedLocation.latLng(piwLatitude, piwLongitude)
        ],
        // paths: [],
        markers: [
          Marker(
            locations: [
              Location(latitude, longitude),
            ],
            color: Colors.blue,
            label: "O",
          ),
          Marker(
            locations: [
              Location(vesselLatitude, vesselLongitude),
            ],
            color: Colors.white,
            label: "V",
          ),
          Marker(
            locations: [
              Location(piwLatitude, piwLongitude),
            ],
            color: Colors.red,
            label: "P",
          ),
        ]);
  }
}

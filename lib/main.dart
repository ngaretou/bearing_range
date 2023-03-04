import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math.dart';

import 'locations.dart';
import 'functions.dart';
import 'results.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final globalKey = GlobalKey<_LocationCalculatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CGA SAR Calculator'),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => globalKey.currentState?.calculateSarData(),
            child: const Icon(Icons.calculate)),
        body: LocationCalculator(key: globalKey),
      ),
    );
  }
}

class LocationCalculator extends StatefulWidget {
  const LocationCalculator({Key? key}) : super(key: key);

  @override
  State<LocationCalculator> createState() => _LocationCalculatorState();
}

class _LocationCalculatorState extends State<LocationCalculator> {
  final formKey = GlobalKey<FormState>();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController vesselBearingController = TextEditingController();
  TextEditingController vesselRangeController = TextEditingController();
  TextEditingController piwBearingController = TextEditingController();
  TextEditingController piwRangeController = TextEditingController();

  // Variables to store the input values
  double? latitude;
  double? longitude;

  double? vesselLatitude;
  double? vesselLongitude;

  double? piwLatitude;
  double? piwLongitude;

  // Variable to store the current origin position
  Position? currentPosition;

  // Keeping track of the selected origin in the dropdown
  late int selectedOrigin;

  // Method to get the current position using geolocator package
  void getCurrentPosition() async {
    //This displays an overlay with a spinning progress indicator until device returns location
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder(
              future: determinePosition(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  currentPosition = snapshot.data;
                  Navigator.of(context).pop();
                  return Container(); //this never gets called but avoids an IDE error
                }
              });
        });

    latitudeController.text = currentPosition!.latitude
        .toString(); // Set latitude input value as current latitude
    longitudeController.text = currentPosition!.longitude
        .toString(); // Set longitude input value as current longitude

    setState(() {});
  }

  // Method to calculate the new latitude and longitude using vector math package
  List<double> calculateNewCoordinates(double range, double bearing) {
    // Convert degrees to radians for calculations

    double lat1 = radians(latitude!); // Current latitude in radians

    double lon1 = radians(longitude!); // Current longitude in radians

    double rng = range /
        6371; // Angular distance in radians (assuming Earth radius is 6371 km)

    double brg = radians(bearing); // Bearing in radians

    // Apply formula from https://stackoverflow.com/questions/7222382/get-lat-long-given-current-point-distance-and-bearing

    double lat2 = asin(sin(lat1) * cos(rng) +
        cos(lat1) * sin(rng) * cos(brg)); // New latitude in radians

    double lon2 = lon1 +
        atan2(sin(brg) * sin(rng) * cos(lat1),
            cos(rng) - sin(lat1) * sin(lat2)); // New longitude in radians

    // Convert radians back to degrees for display

    double returnLatitude = degrees(lat2); // New latitude in degrees

    double returnLongitude = degrees(lon2); // New longitude in degrees

    return [returnLatitude, returnLongitude];
  }

  List<double> rangeBearingAToB(
      double latA, double lonA, double latB, double lonB) {
    double distanceInKM =
        (Geolocator.distanceBetween(latA, lonA, latB, lonB)) / 1000;
    double calculatedRotation =
        Geolocator.bearingBetween(latA, lonA, latB, lonB);

    return [distanceInKM, calculatedRotation];
  }

  //First try at range/bearing A to B
  // This function assumes that bearingA, rangeA, bearingB, rangeB are given in degrees and kilometers
  // It returns a list with two elements: [bearingAB, rangeAB]
  // List<double> rangeBearingAToB(
  //     double rangeA, double bearingA, double rangeB, double bearingB) {
  //   // Convert degrees to radians
  //   double rad(double deg) => deg * pi / 180;

  //   // Convert radians to degrees
  //   double deg(double rad) => rad * 180 / pi;

  //   // Calculate latitude and longitude of A using spherical coordinates
  //   double latA = asin(sin(rad(90)) * cos(rad(rangeA) / 6371));
  //   double lonA = rad(bearingA);

  //   // Calculate latitude and longitude of B using spherical coordinates
  //   double latB = asin(sin(rad(90)) * cos(rad(rangeB) / 6371));
  //   double lonB = rad(bearingB);

  //   // Calculate X and Y for finding bearing from A to B
  //   double X = cos(latB) * sin(lonB - lonA);
  //   double Y = cos(latA) * sin(latB) - sin(latA) * cos(latB) * cos(lonB - lonA);

  //   // Calculate bearing from A to B using atan2 function
  //   double bearingAB = deg(atan2(X, Y));

  //   // Adjust bearing to be between 0 and 360 degrees
  //   if (bearingAB < 0) {
  //     bearingAB += 360;
  //   }

  //   // Calculate distance from A to B using haversine formula
  //   double hav(double x) => sin(x / 2) * sin(x / 2);
  //   double distanceAB = (6371 *
  //           2 *
  //           asin(sqrt(
  //               hav(latB - latA) + cos(latA) * cos(latB) * hav(lonB - lonA)))) *
  //       100;

  //   // Return a list with two elements: [bearingAB,distanceAB]
  //   return [distanceAB, bearingAB];
  // }

  // Method to build a text field widget for input values
  TextFormField buildTextField(
    String label,
    String hint,
    TextEditingController? controller,
  ) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter required data';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget sectionHeading(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  @override
  void initState() {
    selectedOrigin = 0;
    super.initState();
  }

  void calculateSarData() {
    if (formKey.currentState!.validate()) {
      //Get the info
      final vesselLocation = calculateNewCoordinates(
        double.parse(vesselRangeController.text),
        double.parse(vesselBearingController.text),
      );
      final piwLocation = calculateNewCoordinates(
        double.parse(piwRangeController.text),
        double.parse(piwBearingController.text),
      );
      final vesselSarData = rangeBearingAToB(
          vesselLocation[0], vesselLocation[1], piwLocation[0], piwLocation[1]
          // double.parse(vesselRangeController.text),
          // double.parse(vesselBearingController.text),
          // double.parse(piwRangeController.text),
          // double.parse(piwBearingController.text),
          );
      //Now push it to results page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultsPage(
              latitude: latitude!,
              longitude: longitude!,
              vesselBearing: double.parse(vesselBearingController.text),
              vesselRange: double.parse(vesselRangeController.text),
              piwBearing: double.parse(piwBearingController.text),
              piwRange: double.parse(piwRangeController.text),
              vesselLatitude: vesselLocation[0],
              vesselLongitude: vesselLocation[1],
              piwLatitude: piwLocation[0],
              piwLongitude: piwLocation[1],
              vesselPiwBearing: vesselSarData[1],
              vesselPiwRange: vesselSarData[0]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> locationList =
        List.generate(locations.length, ((index) {
      return DropdownMenuItem<int>(
        value: index,
        // onTap: () {},
        child: Text(locations[index].location),
      );
    }));

    final screenwidth = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: screenwidth > 800
            ? EdgeInsets.symmetric(
                vertical: 16, horizontal: (screenwidth - 600) / 2)
            : const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: AssetImage("assets/uscga_mono.png"),
                      ),
                    ),
                  ),
                ),
                sectionHeading('Origin'),
                const SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField(
                  value: selectedOrigin,
                  items: locationList,
                  onChanged: (i) {
                    selectedOrigin = i!.toInt();

                    if (locations[i].latitude != null) {
                      latitudeController.text =
                          locations[i].latitude.toString();
                      latitude = locations[i].latitude;
                      longitudeController.text =
                          locations[i].longitude.toString();
                      longitude = locations[i].longitude;
                    } else if (i == 1) {
                      getCurrentPosition();
                    } else if (i == 0) {
                      latitudeController.text = '';
                      longitudeController.text = '';
                    }
                  },
                  decoration: const InputDecoration(
                    filled: false,
                    border: OutlineInputBorder(),
                    labelText: 'Origin point',
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                buildTextField(
                  'Latitude',
                  'Enter current latitude',
                  latitudeController,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  'Longitude',
                  'Enter current longitude',
                  longitudeController,
                ),

                //Vessel
                const SizedBox(
                  height: 16,
                ),
                sectionHeading('Vessel'),
                const SizedBox(
                  height: 16,
                ),
                buildTextField(
                  'Range',
                  'Enter range in km',
                  vesselRangeController,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  'Bearing',
                  'Enter bearing in degrees',
                  vesselBearingController,
                ),

                //PIW
                const SizedBox(
                  height: 16,
                ),
                sectionHeading('PIW'),
                const SizedBox(
                  height: 16,
                ),
                buildTextField(
                    'Range', 'Enter range in km', piwRangeController),
                const SizedBox(height: 16),
                buildTextField('Bearing', 'Enter bearing in degrees',
                    piwBearingController),
                const SizedBox(height: 16),
                // Center(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       calculateSarData();
                //     },
                //     child: const Text('Calculate'),
                //   ),
                // ),
                // const SizedBox(height: 16),
                // if (newLatitude != null)
                //   Text('New Latitude: ${newLatitude ?? ''}'),
                // if (newLongitude != null)
                //   Text('New Longitude: ${newLongitude ?? ''}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

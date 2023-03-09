import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math.dart';

import 'locations.dart';
import 'functions.dart';
import 'results.dart';
import 'drawer.dart';

//This app takes an origin point and a bearing and range to a vessel
//and a person in water and calculates
//bearing and range from vessel to PIW with map

//This is boilerplate/standard code to get a Flutter app going
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //This globalkey is unfortunately a bit of an unusual case.
  //We want to have a parent widget, MyApp, run a method of a child widget,
  // LocationCalculator. Skip this for now if you're just getting started.
  final globalKey = GlobalKey<_LocationCalculatorState>();
  @override
  Widget build(BuildContext context) {
    //Standard Flutter code to get us going
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), //Try replacing dark with light
      //Scaffold gives you a background, app bar, and some other housekeeping things
      home: Scaffold(
        //InfoDrawer is a widget in another file. In an IDE like Microsoft Code, Ctrl/Cmd click to follow the link.
        //Notice this file is imported above : import 'drawer.dart';
        drawer: const InfoDrawer(),
        appBar: AppBar(
          title: const Text('SAR Calculator'),
        ),
        //The 'equals' button lower right.
        floatingActionButton: FloatingActionButton(
            onPressed: () => globalKey.currentState?.calculateSarData(),
            child: const Icon(Icons.arrow_forward)),
        body: LocationCalculator(key: globalKey),
      ),
    );
  }
}

//Here is the main part of the screen you see when you run the app.
//First some code to get the widget going:
class LocationCalculator extends StatefulWidget {
  const LocationCalculator({Key? key}) : super(key: key);

  @override
  State<LocationCalculator> createState() => _LocationCalculatorState();
}

class _LocationCalculatorState extends State<LocationCalculator> {
  //Now here we set up some variables. These controllers are ways of controlling
  //and reading the text boxes below. To refer to the box, you use e.g. latitudeController;
  //to refer to teh contents of the box, e.g. latitudeController.text
  final formKey = GlobalKey<FormState>();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController vesselBearingController = TextEditingController();
  TextEditingController vesselRangeController = TextEditingController();
  TextEditingController piwBearingController = TextEditingController();
  TextEditingController piwRangeController = TextEditingController();

  //Which units
  String units = 'NM';

  // Variables to store the input values
  double? latitude;
  double? longitude;

  double? vesselLatitude;
  double? vesselLongitude;

  double? piwLatitude;
  double? piwLongitude;

  // Variable to store the current origin position
  Position? currentPosition;

  // Keeping track of the selected origin in the dropdown boxx
  late int selectedOrigin;

  // Method to calculate the new latitude and longitude using vector math package.
  //Below we'll send this function a range and bearing and it will send us the new lat and lon.
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

  //This function uses a package to give us the bearin and range from vessel to PIW.
  //To use raw math, comment the first two lines out and do your own calculations.
  //Make sure it returns  distanceInKM and calculatedRotation as the range and bearing.
  List<double> rangeBearingAToB(
      double latA, double lonA, double latB, double lonB) {
    double distanceInKM =
        (Geolocator.distanceBetween(latA, lonA, latB, lonB)) / 1000;
    double calculatedRotation =
        Geolocator.bearingBetween(latA, lonA, latB, lonB);

    return [distanceInKM, calculatedRotation];
  }

  /* Method to build a text field widget for input values
  One way of making things faster is to build a template widget that you can use later. 
  Otherwise if you change - for example the font size - you have to make that change for 
  all the widgets. This way it's like a style in Word - make the change once and it is 
  in effect anywhere you use this widget. For this one, give it a label, a hint, and a controller.*/
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
      style: Theme.of(context).textTheme.headlineSmall,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  //Not a long widget but it helps for styles
  Widget sectionHeading(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  //This kicks off the dropdown as the first option
  @override
  void initState() {
    selectedOrigin = 0;
    super.initState();
  }

  /* This one gives you the info you want and then displays it. This is run 
  from the big calculate button
  */
  void calculateSarData() {
    if (formKey.currentState!.validate()) {
      //Take into account units
      double vesselRange = double.parse(vesselRangeController.text);
      double piwRange = double.parse(piwRangeController.text);
      //do the conversion
      if (units == 'NM') {
        vesselRange = vesselRange * .539957;
        piwRange = piwRange * .539957;
      }

      //Get the info
      final vesselLocation = calculateNewCoordinates(
        vesselRange,
        double.parse(vesselBearingController.text),
      );
      final piwLocation = calculateNewCoordinates(
        piwRange,
        double.parse(piwBearingController.text),
      );
      final vesselSarData = rangeBearingAToB(
          vesselLocation[0], vesselLocation[1], piwLocation[0], piwLocation[1]);

      //Now push it to results page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultsPage(
              units: units,
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
    // Method to get the current position using geolocator package
    void getCurrentPosition() async {
      //This displays an overlay with a spinning progress indicator until device returns location
      showDialog(
          context: context,
          builder: (context) {
            return FutureBuilder(
                //This function is in a separate file for convenience sake
                future: determinePosition(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    Navigator.of(context).pop();
                    currentPosition = snapshot.data;

                    return Container(); //this never gets called but avoids an IDE error
                  }
                });
          }).then((_) {
        latitudeController.text = currentPosition!.latitude
            .toString(); // Set latitude input value as current latitude
        longitudeController.text = currentPosition!.longitude
            .toString(); // Set longitude input value as current longitude
      });
    }

    /*This is pretty cool - just add more locations to the locations.dart and they'll show up in the box!
    List.generate takes a list of things and makes a list of other things. Here we're taking coordinates and
    making a bunch of widgets. */
    List<DropdownMenuItem<int>> locationList =
        List.generate(locations.length, ((index) {
      return DropdownMenuItem<int>(
        value: index,
        // onTap: () {},
        child: Text(
          locations[index].location,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );
    }));

    List<DropdownMenuItem<String>> unitsList = [
      DropdownMenuItem<String>(
        value: 'NM',
        child: Text(
          'NM',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      DropdownMenuItem<String>(
        value: 'km',
        child: Text(
          'km',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ];

    final screenwidth = MediaQuery.of(context).size.width;

    /*Now here is where things start happening. 
    The return statement is where the action starts.*/
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: screenwidth > 800
              ? EdgeInsets.symmetric(
                  vertical: 16, horizontal: (screenwidth - 600) / 2)
              : const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //The app logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 100),
                    const Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 10,
                        )),
                    Center(
                      //Put in default data for testing rather than typing!
                      child: GestureDetector(
                        onDoubleTap: () {
                          latitude = 41.371601;
                          longitude = -72.095820;
                          latitudeController.text = '41.371601';
                          longitudeController.text = '-72.095820';
                          vesselBearingController.text = '90';
                          vesselRangeController.text = '.5';
                          piwBearingController.text = '60';
                          piwRangeController.text = '.6';
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(240, 237, 237, 1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.support,
                            size: 100,
                            color: Color.fromARGB(200, 217, 2, 2),
                          ),
                        ),
                        // child: Container(
                        //   width: 150,
                        //   height: 150,
                        //   decoration: const BoxDecoration(
                        //     image: DecorationImage(
                        //       fit: BoxFit.fitHeight,
                        //       image: AssetImage("assets/uscga_mono.png"),
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                    const Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 10,
                        )),
                    // ignore: sized_box_for_whitespace
                    Container(
                      width: 100,
                      // height: 60,
                      child: DropdownButtonFormField(
                        value: units,
                        items: unitsList,
                        onChanged: (i) {
                          setState(() {
                            units = i!;
                          });
                        },
                        decoration: const InputDecoration(
                          filled: false,
                          border: OutlineInputBorder(),
                          labelText: 'Units',
                        ),
                      ),
                    ),
                  ],
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
                  'Enter range in $units',
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
                    'Range', 'Enter range in $units', piwRangeController),
                const SizedBox(height: 16),
                buildTextField('Bearing', 'Enter bearing in degrees',
                    piwBearingController),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

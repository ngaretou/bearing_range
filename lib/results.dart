import 'package:flutter/material.dart';
import 'sar_map.dart';
import 'package:share_plus/share_plus.dart';

class ResultsPage extends StatelessWidget {
  //Givens
  //origin location
  final double latitude;
  final double longitude;

  //origin to vessel b&r: given
  final double vesselBearing;
  final double vesselRange;

  //origin to PIW r&b: given
  final double piwRange;
  final double piwBearing;

  //Results
  //Vessel location
  final double vesselLatitude;
  final double vesselLongitude;

  //PIW location
  final double piwLatitude;
  final double piwLongitude;

  //vessel to PIW
  final double vesselPiwBearing;
  final double vesselPiwRange;

  const ResultsPage(
      {Key? key,
      required this.latitude,
      required this.longitude,
      required this.vesselBearing,
      required this.vesselRange,
      required this.vesselPiwBearing,
      required this.vesselPiwRange,
      required this.vesselLatitude,
      required this.vesselLongitude,
      required this.piwLatitude,
      required this.piwLongitude,
      required this.piwBearing,
      required this.piwRange})
      : super(key: key);

  Widget result(List<String> labels, List<String> data, BuildContext context) {
    List<Widget> listOfRows = [];

    final labelWidgets = List.generate(labels.length, (index) {
      return SelectableText(
        labels[index],
        style: Theme.of(context).textTheme.headlineSmall,
      );
    });

    final dataWidgets = List.generate(data.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(left: 40.0),
        child: SelectableText(
          data[index],
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );
    });

    for (var i = 0; i < data.length; i++) {
      listOfRows.add(labelWidgets[i]);
      listOfRows.add(dataWidgets[i]);
      listOfRows.add(const Divider(
        height: 16,
        thickness: 2,
        // color: Colors.red,
      ));
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: listOfRows);
  }

  //  Widget result(List<String> labels, List<String> data, BuildContext context) {
  //   final labelWidgets = List.generate(labels.length, (index) {
  //     return SelectableText(
  //       labels[index],
  //       style: Theme.of(context).textTheme.titleMedium,
  //     );
  //   });

  //   final dataWidgets = List.generate(data.length, (index) {
  //     return SelectableText(
  //       data[index],
  //       style: Theme.of(context)
  //           .textTheme
  //           .titleMedium!
  //           .copyWith(overflow: TextOverflow.ellipsis),
  //     );
  //   });

  //   return Row(
  //     children: [
  //       Expanded(
  //         flex: 1,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: labelWidgets,
  //         ),
  //       ),
  //       const SizedBox(width: 20),
  //       Expanded(
  //         flex: 1,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: dataWidgets,
  //         ),
  //       )
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Widget sectionHeading(String text) {
      return SelectableText(
        text,
        style: Theme.of(context).textTheme.headlineMedium,
      );
    }

    final screensize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(title: const Text('SAR Data')),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Share.share(
                "Coordinates to share",
                sharePositionOrigin: Rect.fromLTWH(
                    0, 0, screensize.width, screensize.height / 2),
              );
            },
            child: const Icon(Icons.share)),
        body: Padding(
          padding: screensize.width > 800
              ? EdgeInsets.symmetric(
                  vertical: 16, horizontal: (screensize.width - 600) / 2)
              : const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeading('SAR DATA'),
              const SizedBox(height: 16),
              result([
                'Vessel to PIW bearing',
                'Vessel to PIW range',
              ], [
                vesselPiwBearing.toString(),
                vesselPiwRange.toString(),
              ], context),
              const SizedBox(height: 16),
              Center(
                child: SarMap(
                  latitude: latitude,
                  longitude: longitude,
                  vesselLatitude: vesselLatitude,
                  vesselLongitude: vesselLongitude,
                  piwLatitude: piwLatitude,
                  piwLongitude: piwLongitude,
                ),
              ),
              const SizedBox(height: 16),
              sectionHeading('Vessel'),
              const SizedBox(height: 16),
              result([
                'Latitude',
                'Longitude',
              ], [
                vesselLatitude.toString(),
                vesselLongitude.toString(),
              ], context),
              const SizedBox(height: 16),
              sectionHeading('PIW'),
              const SizedBox(height: 16),
              result([
                'Latitude',
                'Longitude',
              ], [
                piwLatitude.toString(),
                piwLongitude.toString(),
              ], context),
              const SizedBox(height: 16),
              sectionHeading('Origin'),
              const SizedBox(height: 16),
              result([
                'Latitude',
                'Longitude',
                'Origin to Vessel Bearing',
                'Origin to Vessel Range',
                'Origin to PIW Bearing',
                'Origin to PIW Range'
              ], [
                latitude.toString(),
                longitude.toString(),
                vesselBearing.toString(),
                vesselRange.toString(),
                piwBearing.toString(),
                piwRange.toString(),
              ], context),
              const SizedBox(height: 16),
            ],
          )),
        ));
  }
}

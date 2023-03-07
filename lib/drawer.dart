import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoDrawer extends StatelessWidget {
  const InfoDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 30, bottom: 20, left: 20, right: 20),
              child: Row(
                children: [
                  const Icon(Icons.support),
                  const SizedBox(width: 25),
                  Text("CGA SAR calculator",
                      style: Theme.of(context).textTheme.titleMedium)
                ],
              ),
            ),
            const Divider(
              thickness: 3,
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Source Code'),
              onTap: () async {
                Navigator.of(context).pop();

                const url = "https://github.com/ngaretou/bearing_range";

                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Licenses'),
              onTap: () {
                void showLicensePage({
                  required BuildContext context,
                  String? applicationName,
                  String? applicationVersion,
                  Widget? applicationIcon,
                  String? applicationLegalese,
                  bool useRootNavigator = false,
                }) {
                  // assert(context != null);
                  // assert(useRootNavigator != null);
                  Navigator.of(context, rootNavigator: useRootNavigator)
                      .push(MaterialPageRoute<void>(
                    builder: (BuildContext context) => LicensePage(
                      applicationName: applicationName,
                      applicationVersion: applicationVersion,
                      applicationIcon: applicationIcon,
                      applicationLegalese: applicationLegalese,
                    ),
                  ));
                }

                showLicensePage(
                    context: context,
                    applicationName: 'CGA SAR Calculator',
                    useRootNavigator: true);
              },
            ),
            const Expanded(
                flex: 1,
                child: SizedBox(
                  height: 10,
                )),
            const Divider(
              thickness: 3,
            ),
            ListTile(
              title: const Text('© 2023 Corey Garrett & Molly Garrett'),
              subtitle:
                  const Text('Open source MIT License\nMade with Flutter'),
              onTap: () async {
                Navigator.of(context).pop();

                const url =
                    "https://github.com/ngaretou/bearing_range/blob/main/LICENSE";

                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

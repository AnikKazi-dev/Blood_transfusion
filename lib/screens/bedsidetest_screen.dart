import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secureblood/providers/collected_data_provider.dart';
import 'package:secureblood/theme/secureblood_theme.dart';
import 'package:secureblood/utils/data_missmatch_alert_dialog.dart';

class BedsidetestScreen extends StatefulWidget {
  const BedsidetestScreen({super.key});

  @override
  State<BedsidetestScreen> createState() => _BedsidetestScreenState();
}

class _BedsidetestScreenState extends State<BedsidetestScreen> {
  String selectedBloodGroup = "";
  List<String> bloodgroups = ["A", "B", "AB", "0"];
  String savedBloodGroup = "";

  submitResult() {
    CollectedDataProvider provider =
        Provider.of<CollectedDataProvider>(context, listen: false);

    if (provider.begleitscheinRecieverBloodType != selectedBloodGroup &&
        selectedBloodGroup.isNotEmpty) {
      showDataMissmatchAlertDialog(context,
              begleitscheinValue: provider.begleitscheinRecieverBloodType!,
              scannedValue: selectedBloodGroup,
              scanSource: "Bedside Test",
              label: "Blutgruppe")
          .then((scanAgain) => {
                if (scanAgain == true)
                  {loadValues()}
                else if (scanAgain == false)
                  {if (mounted) Navigator.of(context).pop()}
                // ignore warning and continue
                else
                  {
                    provider.setBedsideTestResult(selectedBloodGroup),
                    if (mounted) Navigator.of(context).pop()
                  }
              });
    } else {
      provider.setBedsideTestResult(selectedBloodGroup);
      Navigator.of(context).pop();
    }
  }

  loadValues() {
    CollectedDataProvider collectedData =
        Provider.of<CollectedDataProvider>(context, listen: false);
    savedBloodGroup = collectedData.bedsideTestResult ?? "";
    setState(() {
      selectedBloodGroup = savedBloodGroup;
    });
  }

  @override
  void initState() {
    super.initState();
    loadValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Bedside Test'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Blutgruppe",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text(
                        "Bitte geben Sie das Ergebnis des Bedside Testes ein, den Sie selbst am Patientenbett durchgeführt haben."),
                    const SizedBox(
                      height: 20,
                    ),
                    for (var bloodGroup in bloodgroups) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(15),
                                textStyle: const TextStyle(fontSize: 25),
                                foregroundColor:
                                    selectedBloodGroup == bloodGroup
                                        ? primaryDarkBlueColor
                                        : Colors.black,
                                side: BorderSide(
                                    color: selectedBloodGroup == bloodGroup
                                        ? primaryDarkBlueColor
                                        : primaryBlueColor,
                                    width: 1),
                                backgroundColor:
                                    selectedBloodGroup == bloodGroup
                                        ? primaryBlueColor
                                        : Colors.white),
                            onPressed: () {
                              setState(() {
                                selectedBloodGroup =
                                    selectedBloodGroup == bloodGroup
                                        ? ""
                                        : bloodGroup;
                              });
                            },
                            child: Text(bloodGroup),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                ElevatedButton(
                  onPressed: selectedBloodGroup != savedBloodGroup
                      ? submitResult
                      : null,
                  child: const Text("Bestätigen"),
                )
              ],
            ),
          ),
        ));
  }
}

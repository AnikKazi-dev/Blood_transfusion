import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:secureblood/db/history_class.dart';
import 'package:secureblood/utils/blood_product_enum.dart';
import 'package:secureblood/widgets/bloodtype_compatibility_widget.dart';

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({required this.historyEntry, super.key});
  final HistoryEntry historyEntry;

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat("dd. MMMM");
    DateFormat fullDateFormat = DateFormat("EEEE, dd.MM.yy, hh:mm");

    bool wristBandFallnummerMatches =
        historyEntry.patientWristBandFallnummer.isNotEmpty &&
            historyEntry.patientWristBandFallnummer ==
                historyEntry.begleitscheinFallnummer;

    return Scaffold(
      appBar: AppBar(
        title:
            Text("Protokoll vom ${dateFormat.format(historyEntry.createdAt!)}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      const Icon(Icons.calendar_month),
                      const SizedBox(width: 7),
                      Text(
                          "${fullDateFormat.format(historyEntry.createdAt!)} Uhr"),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Begleitschein",
                              style: Theme.of(context).textTheme.labelLarge),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Empfänger",
                              ),
                              Text(historyEntry.begleitscheinPatientName)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Geburtsdatum",
                              ),
                              Text(historyEntry.begleitscheinBirthDate)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Fall Nr.",
                              ),
                              Text(historyEntry.begleitscheinFallnummer)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Blutgruppe Patient",
                              ),
                              Text(historyEntry.begleitscheinRecieverBloodType)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Präparat Nr.",
                              ),
                              Text(
                                  historyEntry.begleitscheinBlutkonservenNummer)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Blutgruppe Blutkonserve",
                              ),
                              Text(historyEntry
                                  .begleitscheinBlutkonserveBloodType)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Blutkonserve",
                              style: Theme.of(context).textTheme.labelLarge),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Präparat Nr.",
                              ),
                              Text(
                                historyEntry.blutKonservenNummer,
                                style: TextStyle(
                                  color: historyEntry.blutKonservenNummer !=
                                          historyEntry
                                              .begleitscheinBlutkonservenNummer
                                      ? Colors.red
                                      : null,
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Produkttyp",
                              ),
                              Text(
                                historyEntry.blutkonservenProductType.isNotEmpty
                                    ? "${BloodProductTypes.fromValue(int.parse(historyEntry.blutkonservenProductType))?.label ?? ""} (${historyEntry.blutkonservenProductType})"
                                    : "",
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Blutgruppe",
                              ),
                              Text(
                                historyEntry.blutkonservenBloodType,
                                style: TextStyle(
                                  color: historyEntry.blutkonservenBloodType !=
                                          historyEntry
                                              .begleitscheinBlutkonserveBloodType
                                      ? Colors.red
                                      : null,
                                ),
                              )
                            ],
                          ),
                          if (historyEntry.blutkonservenProductType == "5") ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Austauschtransfusion",
                                ),
                                Text(
                                  historyEntry.isFullTransfusion == true
                                      ? "Ja"
                                      : "Nein",
                                  style: TextStyle(
                                    color: historyEntry
                                                .blutkonservenBloodType !=
                                            historyEntry
                                                .begleitscheinBlutkonserveBloodType
                                        ? Colors.red
                                        : null,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Armband",
                              style: Theme.of(context).textTheme.labelLarge),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Fall Nr.",
                              ),
                              Text(
                                historyEntry.patientWristBandFallnummer,
                                style: TextStyle(
                                  color: !wristBandFallnummerMatches
                                      ? Colors.red
                                      : null,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Bedside Test",
                              style: Theme.of(context).textTheme.labelLarge),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Blutgruppe Patient",
                              ),
                              Text(
                                historyEntry.bedsideTestResult.isEmpty
                                    ? "-"
                                    : historyEntry.bedsideTestResult,
                                style: TextStyle(
                                  color: historyEntry.bedsideTestResult !=
                                          historyEntry
                                              .begleitscheinBlutkonserveBloodType
                                      ? Colors.red
                                      : null,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (historyEntry.begleitscheinRecieverBloodType.isNotEmpty &&
                      historyEntry.blutkonservenBloodType.isNotEmpty &&
                      historyEntry.blutkonservenProductType.isNotEmpty) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    BloodTypeCompatibilityWidget(
                        recieverBloodType:
                            historyEntry.begleitscheinRecieverBloodType,
                        bloodPackBloodType: historyEntry.blutkonservenBloodType,
                        productType: historyEntry.blutkonservenProductType),
                  ],
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: historyEntry.scanSuccess == 1
                        ? const Icon(
                            Icons.check_circle_outline_outlined,
                            size: 50,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red,
                          ),
                  ),
                  Center(
                    child: Text(
                      "Abgleich ${historyEntry.scanSuccess == 1 ? "erfolgreich" : "fehlgeschlagen"}",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

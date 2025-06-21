import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secureblood/main.dart';
import 'package:secureblood/widgets/bloodtype_compatibility_widget.dart';

import '../../providers/collected_data_provider.dart';

class ScanCompleteScreen extends StatefulWidget {
  const ScanCompleteScreen({super.key});

  @override
  State<ScanCompleteScreen> createState() => _ScanCompleteScreenState();
}

class _ScanCompleteScreenState extends State<ScanCompleteScreen> {
  bool termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    final collectedData =
        Provider.of<CollectedDataProvider>(context, listen: false);

    void saveDataToDB() async {
      await collectedData.saveDataToDB().then((_) {
        context.mounted
            ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  "Erfasste Daten wurden in das Protkoll übertragen.",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
              ))
            : null;

        context.mounted
            ? Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) {
                return false;
              })
            : null;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Icon(
                  Icons.check_box_rounded,
                  size: 120,
                  color: Colors.teal[200],
                ),
              ),
              Text("Datenvergleich abgeschlossen",
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(
                height: 10,
              ),
              BloodTypeCompatibilityWidget(
                recieverBloodType:
                    collectedData.begleitscheinRecieverBloodType!,
                bloodPackBloodType: collectedData.blutkonservenBloodType!,
                productType: collectedData.blutkonservenProductType!,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Achtung – bitte beachten und bestätigen:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                          "Die Verantwortung für die korrekte Durchführung des Datenvergleiches und der Identitätsüberprüfung liegt immer beim transfundierenden Arzt. Die Anwendung Secureblood dient als zusätzliche Hilfe, um Fehler zu erkennen und den Vorgang zu dokumentieren."),
                    ]),
              ),
              CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: termsAccepted,
                  title: const Text("Hinweise gelesen und bestätigt."),
                  onChanged: (value) {
                    setState(() {
                      termsAccepted = value!;
                    });
                  }),
              const Expanded(
                child: SizedBox(),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(123, 235, 217, 1)),
                  onPressed: termsAccepted ? saveDataToDB : null,
                  child: const Text("Vorgang beenden"),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Zurück"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

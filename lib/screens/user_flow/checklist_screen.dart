import 'package:flutter/material.dart';
import 'package:secureblood/screens/scan/begleitschein_scan_screen.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkliste'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Column(
            children: [
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                          "Liegen folgende vier Informationen vor? Starten Sie erst dann mit dem ersten Scan."),
                      SizedBox(height: 20),
                      ChecklistRow(
                          title: "Begleitdokument",
                          description:
                              "Der Blutkonserven-Begleitschein mit Fallnummer, Blutgruppen und Blutkonservennummer."),
                      ChecklistRow(
                          title: "Patientenarmband",
                          description:
                              "Das Armband des Patienten mit der Fallnummer."),
                      ChecklistRow(
                          title: "Blutkonserve",
                          description:
                              "Auf der Blutkonserve sind die Blutgruppe und die Blutkonservennummer aufgedruckt."),
                      ChecklistRow(
                        title: "Bedside-Test Ergebnis",
                        description:
                            "Das Testergebnis eines ausgeführten Bedside-Tests.",
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text("Begleitdokument scannen"),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const BegleitscheinErfassenScreen()),
                            (route) => false);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChecklistRow extends StatelessWidget {
  const ChecklistRow({
    required this.title,
    required this.description,
    super.key,
  });
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.help_outline_outlined,
          color: Colors.blue,
        ),
      ),
      tilePadding: EdgeInsetsDirectional.zero,
      title: Text(title),
      expandedAlignment: Alignment.topLeft,
      childrenPadding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        Text(description),
      ],
    );
  }
}

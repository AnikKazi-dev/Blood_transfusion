import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:secureblood/db/history_class.dart';
import 'package:secureblood/db/history_db.dart';

import '../../providers/collected_data_provider.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<HistoryEntry>> historyEntries;
  late CollectedDataProvider provider;

  Future<List<HistoryEntry>> getHistoryEntries() async {
    final db = HistoryDB();
    return await db.getAllCollectedData();
  }

  @override
  void initState() {
    super.initState();

    historyEntries = getHistoryEntries();

    provider = Provider.of<CollectedDataProvider>(context, listen: false);
    provider.addListener(() => updateOnProviderChange());
  }

  updateOnProviderChange() {
    if (mounted) {
      setState(() {
        historyEntries = getHistoryEntries();
      });
    }
  }

  @override
  void dispose() {
    provider.removeListener(updateOnProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    csvexport() async {
      final db = HistoryDB();
      await db.exportToCSV();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Protokolle"),
        actions: [
          IconButton(
            onPressed: csvexport,
            icon: const Icon(Icons.download),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            historyEntries = getHistoryEntries();
          });
        },
        child: Scrollbar(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final db = HistoryDB();
                  //     var x = await db.insertCollectedData(HistoryEntry(
                  //       begleitscheinFallnummer: "123456",
                  //       createdAt: DateTime.now(),
                  //       begleitscheinRecieverBloodType: "A",
                  //       begleitscheinBlutkonserveBloodType: "A",
                  //       begleitscheinBlutkonservenNummer: "1232",
                  //       blutKonservenNummer: "asdfg",
                  //       blutkonservenProductType: "asdfg",
                  //       blutkonservenBloodType: "asdfg",
                  //       patientWristBandFallnummer: "2332",
                  //       bedsideTestResult: "A",
                  //       scanSuccess: 1,
                  //     ));
                  //     print("saved");
                  //     print(x);
                  //   },
                  //   child: const Text("save random data"),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final db = HistoryDB();
                  //     var x = await db.wipeAllData();

                  //     print("WIPED");
                  //     print(x);
                  //   },
                  //   child: const Text("WIPE ALL DATA"),
                  // ),
                  FutureBuilder(
                    future: historyEntries,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data != null && snapshot.data!.isEmpty
                            ? Center(
                                child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(top: 30),
                                    child: Text(
                                      "Noch keine Protokolle vorhanden",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                      textAlign: TextAlign.center,
                                    )),
                              )
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: HistoryListTile(
                                        historyEntry: snapshot.data![index]),
                                  );
                                },
                              );
                      } else {
                        return snapshot.hasError
                            ? const Text(
                                "Protokolle konnten nicht geladen werden")
                            : const CircularProgressIndicator();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryListTile extends StatelessWidget {
  const HistoryListTile({
    super.key,
    required this.historyEntry,
  });

  final HistoryEntry historyEntry;

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat("dd.MM.yyyy, HH:mm");

    return ListTile(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HistoryDetailScreen(
                    historyEntry: historyEntry,
                  ))),
      tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: historyEntry.scanSuccess == 1
          ? const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            )
          : const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
      title: Text(historyEntry.begleitscheinPatientName.isNotEmpty
          ? (historyEntry.begleitscheinPatientName)
          : historyEntry.begleitscheinFallnummer),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      subtitle: Text("${dateFormat.format(historyEntry.createdAt!)} Uhr"),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
      ),
    );
  }
}

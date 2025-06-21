import 'package:flutter/material.dart';

Text _showMismatchHighlight(BuildContext context,
    {required String scannedValue, required String correctValue}) {
  return Text.rich(
    TextSpan(
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
      children: List.generate(scannedValue.length, (i) {
        final isMismatch =
            i >= correctValue.length || scannedValue[i] != correctValue[i];

        var whiteSpaces = correctValue.length > scannedValue.length
            ? correctValue.length - scannedValue.length
            : 0;
        return TextSpan(
          text: scannedValue[i],
          style: isMismatch ? const TextStyle(color: Colors.red) : null,
          children: i == scannedValue.length - 1
              ? List.generate(whiteSpaces, (index) {
                  return const TextSpan(
                      text: "_ ", style: TextStyle(color: Colors.red));
                })
              : null,
        );
      }),
    ),
  );
}

Future showDataMissmatchAlertDialog(BuildContext context,
    {required String begleitscheinValue,
    required String scannedValue,
    required String scanSource,
    required String label}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Column(
          children: [
            Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.red,
                )),
            const Text(
              "Fehler im Datenabgleich",
              style: TextStyle(color: Colors.red),
            )
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Daten stimmen nicht überein"),
            const SizedBox(
              height: 10,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10)),
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    begleitscheinValue,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text("Begleitschein",
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10)),
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _showMismatchHighlight(context,
                      scannedValue: scannedValue,
                      correctValue: begleitscheinValue),
                  Text(scanSource,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Warnung ignorieren"),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Vorgang abbrechen"),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Vorgang wiederholen")),
          ),
        ],
      );
    },
  );
}

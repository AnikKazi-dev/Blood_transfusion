import 'package:flutter/material.dart';

Future showPlasmaTransfusionDialog(context) {
  return showDialog(
      context: context,
      // useRootNavigator: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Plasmatransfusion"),
          content: const Text(
              "Soll eine Austrauschtransfusion durchgeführt werden?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Add your logic for proceeding with the plasma transfusion here
                Navigator.of(context).pop(true); // Close the dialog
              },
              child: const Text("Ja"),
            ),
            ElevatedButton(
              onPressed: () {
                // Add your logic for proceeding with the plasma transfusion here
                Navigator.of(context).pop(false); // Close the dialog
              },
              child: const Text("Nein"),
            ),
          ],
        );
      });
}

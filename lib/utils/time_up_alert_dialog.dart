import 'package:flutter/material.dart';
import 'package:secureblood/main.dart';

void showTimeIsOverAlert(context) {
  showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Zeit abgelaufen"),
        content: const Text(
            "Die Zeit für die Eingabe der Daten ist abgelaufen. Vorhandene Daten wurden in das Protokoll übertragen. Bitte Starten sie die Erfassung erneut."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text("Zurück zum Start"),
          ),
        ],
      );
    },
  );
}

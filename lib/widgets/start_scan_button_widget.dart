import 'package:flutter/material.dart';

class StartScanButton extends StatelessWidget {
  final Widget icon;
  final String headline;
  final String description;
  final Function? action;
  const StartScanButton(
      {required this.icon,
      required this.headline,
      required this.description,
      this.action,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10.0)),
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 20),
          Text(headline, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: action != null ? () => action!() : null,
              child: const Text("Jetzt starten"))
        ],
      ),
    );
  }
}

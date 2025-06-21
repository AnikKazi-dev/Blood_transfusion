import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SquareScanStartButton extends StatelessWidget {
  final String title;
  final Function action;
  final bool? isCorrect;
  final bool isBegleitschein;
  final IconData? customIcon;
  final String? label;
  final bool? inactive;

  const SquareScanStartButton({
    required this.title,
    required this.action,
    this.isCorrect,
    this.isBegleitschein = false,
    this.customIcon,
    this.inactive = false,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: inactive == true ? 0.8 : 1,
      child: InkWell(
        onTap: () => action(),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10.0),
            border: isCorrect == null
                ? null
                : Border.all(
                    color: isCorrect! ? Colors.green : Colors.red, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: isCorrect == null
                    ? Icon(
                        customIcon ?? CupertinoIcons.barcode,
                        size: 30,
                        color: inactive == false ? Colors.blue : Colors.grey,
                      )
                    : isCorrect == true
                        ? Icon(
                            isBegleitschein
                                ? Icons.document_scanner_outlined
                                : Icons.check_circle_outline,
                            size: 30,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.error_outline,
                            size: 30,
                            color: Colors.red,
                          ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                isBegleitschein
                    ? "Erfasst"
                    : isCorrect == null
                        ? label ?? "Scannen"
                        : isCorrect!
                            ? "Daten stimmen überein"
                            : "Daten stimmen nicht überein",
                style: TextStyle(
                    color: isCorrect == null
                        ? null
                        : isCorrect!
                            ? Colors.green
                            : Colors.red),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}

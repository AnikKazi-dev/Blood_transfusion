import 'package:flutter/material.dart';

Color primaryBlueColor = const Color.fromRGBO(174, 207, 249, 1);
Color primaryDarkBlueColor = const Color.fromRGBO(43, 87, 145, 1);

final ColorScheme colorScheme = ColorScheme.fromSeed(
  seedColor: primaryBlueColor,
  brightness: Brightness.light,
);

final elevatedButtonTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    elevation: const WidgetStatePropertyAll<double>(0),
    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.shade400; // Background color when disabled
        }
        return primaryBlueColor; // Normal background color
      },
    ),
    foregroundColor: const WidgetStatePropertyAll<Color>(Colors.black),
    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
);

final outlineButtonStyle = OutlinedButtonThemeData(
  style: ButtonStyle(
    elevation: const WidgetStatePropertyAll<double>(0),
    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.shade400; // Background color when disabled
        }
        return Colors.white; // Normal background color
      },
    ),
    foregroundColor: WidgetStatePropertyAll<Color>(primaryDarkBlueColor),
    side: WidgetStatePropertyAll<BorderSide>(
      BorderSide(
        color: primaryBlueColor,
        width: 2,
      ),
    ),
    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
);

final inputDecorationTHeme = InputDecorationTheme(
  fillColor: colorScheme.surfaceContainerLow,
  filled: true,
  border: InputBorder.none,
);

final ThemeData secureBloodThemeData = ThemeData(
    colorScheme: colorScheme,
    inputDecorationTheme: inputDecorationTHeme,
    elevatedButtonTheme: elevatedButtonTheme,
    outlinedButtonTheme: outlineButtonStyle);

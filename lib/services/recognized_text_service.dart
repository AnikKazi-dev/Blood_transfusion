// ignore_for_file: avoid_print

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

String getRecieverTypeFromRecognizedText(RecognizedText text) {
  var result = "";
  try {
    final recieverType =
        text.blocks.firstWhere((v) => v.text.toLowerCase().contains("blutgr."));

    result = recieverType.lines
        .firstWhere((v) => v.text.toLowerCase().contains("blutgr."))
        .text
        .toLowerCase()
        .replaceAll("blutgr.", "")
        .trim();

    result = result.toLowerCase().split("rhd")[0].trim().toUpperCase();
    if (result.toLowerCase() == "o") {
      result = "0";
    }
  } catch (e) {
    print("could not find reciever type");
    print(e);
  }
  return _isValidBloodType(result) ? result : "";
}

String getBloodPackTypeFromRecognizedText(RecognizedText text) {
  var bloodGroupBloodpack = "";

  // find bloodtype text blocks by searching for "rhd"
  var textBlocksWithRhd =
      text.blocks.where((v) => v.text.toLowerCase().contains("rhd")).toList();
  if (textBlocksWithRhd.isEmpty) {
    return "";
  }
  // length should be 2, exclude the one with "blutgr" (this is for reciever)
  if (textBlocksWithRhd.length <= 2) {
    textBlocksWithRhd
        .removeWhere((v) => v.text.toLowerCase().contains("blutgr."));
    String lineWithType = textBlocksWithRhd.first.lines
        .firstWhere((l) => l.text.toLowerCase().contains("rhd"))
        .text;
    // if line contains last word "sag-m" then split it and get the last word (bloodtype is always the last and after sag-m)
    if (lineWithType.toLowerCase().contains("sag-m")) {
      var splitted = lineWithType.toLowerCase().split("sag-m");
      bloodGroupBloodpack = splitted.last;
    } else {
      bloodGroupBloodpack = lineWithType;
    }
  }

  var result = bloodGroupBloodpack.toLowerCase().split("rhd")[0].trim();
  if (result == "o") {
    result = "0";
  }
  return _isValidBloodType(result.toUpperCase()) ? result.toUpperCase() : "";
}

String getCaseNumberFromRecognizedText(RecognizedText text) {
  final allLines = text.blocks.map((b) => b.lines).expand((el) => el);

// regex test
  String? regexMatch = "";
  final regex = RegExp(r"\d{10}\s[A-Za-z].*");

  for (var line in allLines) {
    if (regex.hasMatch(line.text)) {
      regexMatch = regex.firstMatch(line.text)?[0];
      print("regex match");
      print(regexMatch);
      regexMatch = regexMatch?.split(" ")[0];
    }
  }

  return regexMatch!;
}

String getBloodPackNumberFromRecognizedText(RecognizedText text) {
  final indexOfBloodPackNumber =
      text.blocks.indexWhere((v) => v.text.startsWith("276"));
  var bloodPackNumber = indexOfBloodPackNumber != -1
      ? text.blocks[indexOfBloodPackNumber].lines[0].text
      : "";
  return bloodPackNumber;
}

bool _isValidBloodType(String bloodType) {
  return ["0", "A", "B", "AB"].contains(bloodType);
}

String getNameFromRecognizedText(RecognizedText text) {
  try {
    final nameBlockText = text.blocks
        .firstWhere((v) => v.text.toLowerCase().contains("empfänger:"));

    final lineText = nameBlockText.lines
        .firstWhere((l) => l.text.toLowerCase().contains("empfänger:"))
        .text;

    final withoutLabel = lineText.split("Empfänger:")[1];

    if (withoutLabel.contains("Blutgr")) {
      return withoutLabel.split("Blutgr").first.trim();
    } else {
      return withoutLabel.trim();
    }
  } catch (e) {
    print("could not find name");
    return "";
  }
}

String getBirthDateFromRecognizedText(RecognizedText text) {
  String? regexMatch = "";
  final regex = RegExp(r"\d{2}\.\d{2}\.\d{4} [MF]");

  for (var block in text.blocks) {
    if (regex.hasMatch(block.text)) {
      regexMatch = regex.firstMatch(block.text)?[0];
      regexMatch = regexMatch?.trim().split(" ")[0];
    }
  }
  return regexMatch!;
}

class HistoryEntry {
  final String begleitscheinRecieverBloodType;
  final String begleitscheinBlutkonserveBloodType;
  final String begleitscheinFallnummer;
  final String begleitscheinBlutkonservenNummer;
  final String begleitscheinPatientName;
  final String begleitscheinBirthDate;
  final String blutKonservenNummer;
  final String blutkonservenBloodType;
  final String blutkonservenProductType;
  final String patientWristBandFallnummer;
  final String bedsideTestResult;
  final int scanSuccess;
  final DateTime? createdAt;
  final bool? isFullTransfusion;

  HistoryEntry({
    required this.begleitscheinRecieverBloodType,
    required this.begleitscheinBlutkonserveBloodType,
    required this.begleitscheinFallnummer,
    required this.begleitscheinBlutkonservenNummer,
    required this.begleitscheinPatientName,
    required this.begleitscheinBirthDate,
    required this.blutKonservenNummer,
    required this.blutkonservenBloodType,
    required this.blutkonservenProductType,
    required this.patientWristBandFallnummer,
    required this.bedsideTestResult,
    required this.scanSuccess,
    this.createdAt,
    this.isFullTransfusion,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      begleitscheinRecieverBloodType:
          json['begleitscheinRecieverBloodType'] ?? "",
      begleitscheinBlutkonserveBloodType:
          json['begleitscheinBlutkonserveBloodType'] ?? "",
      begleitscheinFallnummer: json['begleitscheinFallnummer'] ?? "",
      begleitscheinBlutkonservenNummer:
          json['begleitscheinBlutkonservenNummer'] ?? "",
      begleitscheinPatientName: json['begleitscheinPatientName'] ?? "",
      begleitscheinBirthDate: json['begleitscheinBirthDate'] ?? "",
      blutKonservenNummer: json['blutKonservenNummer'] ?? "",
      blutkonservenBloodType: json['blutkonservenBloodType'] ?? "",
      blutkonservenProductType: json['blutkonservenProductType'] ?? "",
      patientWristBandFallnummer: json['patientWristBandFallnummer'] ?? "",
      bedsideTestResult: json['bedsideTestResult'] ?? "",
      scanSuccess: json['scanSuccess'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      isFullTransfusion: json['isFullTransfusion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'begleitscheinRecieverBloodType': begleitscheinRecieverBloodType,
      'begleitscheinBlutkonserveBloodType': begleitscheinBlutkonserveBloodType,
      'begleitscheinFallnummer': begleitscheinFallnummer,
      'begleitscheinBlutkonservenNummer': begleitscheinBlutkonservenNummer,
      'begleitscheinPatientName': begleitscheinPatientName,
      'begleitscheinBirthDate': begleitscheinBirthDate,
      'blutKonservenNummer': blutKonservenNummer,
      'blutkonservenBloodType': blutkonservenBloodType,
      'blutkonservenProductType': blutkonservenProductType,
      'patientWristBandFallnummer': patientWristBandFallnummer,
      'bedsideTestResult': bedsideTestResult,
      'scanSuccess': scanSuccess,
      'isFullTransfusion': isFullTransfusion,
    };
  }
}

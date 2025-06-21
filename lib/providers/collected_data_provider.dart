import 'package:flutter/foundation.dart';
import 'package:secureblood/db/history_class.dart';
import 'package:secureblood/db/history_db.dart';

class CollectedDataProvider with ChangeNotifier {
  // Begleitschein
  String? _begleitscheinRecieverBloodType;
  String? _begleitscheinBlutkonserveBloodType;
  String? _begleitscheinFallnummer;
  String? _begleitscheinBlutkonservenNummer;
  String? _begleitscheinPatientName;
  String? _begleitscheinBirthDate;

  // Blutpaket
  String? _blutKonservenNummer;
  String? _blutkonservenBloodType;
  String? _blutkonservenProductType;
  String? _isFullTransfusion;
  // --- NEW PROPERTIES TO STORE EXPIRATION STATE ---
  String? _verfallsdatum;
  bool _isBloodPackExpired = false;

  // Patientenarmband
  String? _patientWristBandFallnummer;
  // Bedsidetest
  String? _bedsideTestResult;

  String? get begleitscheinRecieverBloodType => _begleitscheinRecieverBloodType;
  String? get begleitscheinBlutkonserveBloodType =>
      _begleitscheinBlutkonserveBloodType;
  String? get begleitscheinFallnummer => _begleitscheinFallnummer;
  String? get begleitscheinBlutkonservenNummer =>
      _begleitscheinBlutkonservenNummer;
  String? get blutKonservenNummer => _blutKonservenNummer;
  String? get blutkonservenBloodType => _blutkonservenBloodType;
  String? get blutkonservenProductType => _blutkonservenProductType;
  String? get isFullTransfusion => _isFullTransfusion;
  // --- GETTERS FOR NEW PROPERTIES ---
  String? get verfallsdatum => _verfallsdatum;
  bool get isBloodPackExpired => _isBloodPackExpired;

  String? get patientWristBandFallnummer => _patientWristBandFallnummer;
  String? get bedsideTestResult => _bedsideTestResult;
  String? get begleitscheinPatientName => _begleitscheinPatientName;
  String? get begleitscheinBirthDate => _begleitscheinBirthDate;

  void setBegleitschein(
      {required String recieverType,
      required String bloodPackType,
      required caseNumber,
      required String bloodPackNumber,
      required String patientName,
      required String birthDate}) {
    _begleitscheinRecieverBloodType = recieverType.trim();
    _begleitscheinBlutkonserveBloodType = bloodPackType.trim();
    _begleitscheinFallnummer = caseNumber.trim();
    _begleitscheinBlutkonservenNummer = bloodPackNumber.replaceAll(' ', '');
    _begleitscheinPatientName = patientName.trim();
    _begleitscheinBirthDate = birthDate.trim();
    notifyListeners();
  }

  // --- UPDATED METHOD TO ACCEPT EXPIRATION DATA ---
  void setBloodPackData(
    String bloodPackCaseBarcode,
    String bloodPackBloodTypeBarCode,
    String bloodPackProductType,
    String? isFullTransfusion, {
    String? verfallsdatum,
    bool isExpired = false,
  }) {
    _blutKonservenNummer = bloodPackCaseBarcode.replaceAll(' ', '');
    _blutkonservenBloodType = bloodPackBloodTypeBarCode.trim();
    _blutkonservenProductType = bloodPackProductType.trim();
    _isFullTransfusion = isFullTransfusion;
    _verfallsdatum = verfallsdatum; // Set the date string
    _isBloodPackExpired = isExpired; // Set the expired status
    notifyListeners();
  }

  void setRecieverType(String value) {
    _begleitscheinRecieverBloodType = value;
    notifyListeners();
  }

  void setBloodPackType(String value) {
    _begleitscheinBlutkonserveBloodType = value;
    notifyListeners();
  }

  void setCaseNumber(String value) {
    _begleitscheinFallnummer = value;
    notifyListeners();
  }

  void setBloodPackNumber(String value) {
    _begleitscheinBlutkonservenNummer = value;
    notifyListeners();
  }

  void setBloodPackCaseBarcode(String value) {
    _blutKonservenNummer = value;
    notifyListeners();
  }

  void setBloodPackBloodTypeBarCode(String value) {
    _blutkonservenBloodType = value;
    notifyListeners();
  }

  void setBloodPackProductType(String value) {
    _blutkonservenProductType = value;
    notifyListeners();
  }

  void setPatientBraceletBarcode(String value) {
    _patientWristBandFallnummer = value;
    notifyListeners();
  }

  void setBedsideTestResult(String value) {
    _bedsideTestResult = value.isEmpty ? null : value;
    notifyListeners();
  }

  bool getBlutpaketIsDefined() {
    if (_blutKonservenNummer != null &&
        _blutkonservenBloodType != null &&
        _blutkonservenProductType != null) {
      return true;
    }
    return false;
  }

  bool getBegleitscheinIsDefined() {
    if (_begleitscheinRecieverBloodType != null &&
        _begleitscheinBlutkonserveBloodType != null &&
        _begleitscheinFallnummer != null &&
        _begleitscheinBlutkonservenNummer != null &&
        _begleitscheinPatientName != null &&
        _begleitscheinBirthDate != null) {
      return true;
    }
    return false;
  }

  bool verifyBlutPaket() {
    return _blutKonservenNummer != null &&
        _begleitscheinBlutkonservenNummer != null &&
        _blutkonservenBloodType != null &&
        _begleitscheinBlutkonserveBloodType != null &&
        _blutKonservenNummer == _begleitscheinBlutkonservenNummer &&
        _blutkonservenBloodType == _begleitscheinBlutkonserveBloodType &&
        _blutkonservenProductType != null;
  }

  bool verifyWristBand() {
    return _patientWristBandFallnummer != null &&
        _begleitscheinFallnummer != null &&
        _patientWristBandFallnummer == _begleitscheinFallnummer;
  }

  bool verifyBedsideTest() {
    // is true when full transfusion and no data is entered
    if (_isFullTransfusion == "0" && _bedsideTestResult == null) {
      return true;
    } else {
      return _bedsideTestResult != null &&
          _begleitscheinRecieverBloodType != null &&
          _bedsideTestResult == _begleitscheinRecieverBloodType;
    }
  }

  bool verifyAllData() {
    // A full verification is only successful if the pack is also NOT expired.
    return getBegleitscheinIsDefined() &&
        verifyBlutPaket() &&
        verifyWristBand() &&
        verifyBedsideTest() &&
        !_isBloodPackExpired;
  }

  void resetData() {
    _begleitscheinRecieverBloodType = null;
    _begleitscheinBlutkonserveBloodType = null;
    _begleitscheinFallnummer = null;
    _begleitscheinBlutkonservenNummer = null;
    _begleitscheinPatientName = null;
    _begleitscheinBirthDate = null;
    _blutKonservenNummer = null;
    _blutkonservenBloodType = null;
    _blutkonservenProductType = null;
    _patientWristBandFallnummer = null;
    _bedsideTestResult = null;
    // --- RESET NEW PROPERTIES ---
    _verfallsdatum = null;
    _isBloodPackExpired = false;
    notifyListeners();
  }

  Future<int> saveDataToDB() async {
    // Save data to DB
    final db = HistoryDB();

    var response = await db.insertCollectedData(
      HistoryEntry(
        begleitscheinRecieverBloodType: _begleitscheinRecieverBloodType ?? "",
        begleitscheinBlutkonserveBloodType:
            _begleitscheinBlutkonserveBloodType ?? "",
        begleitscheinFallnummer: _begleitscheinFallnummer ?? "",
        begleitscheinBlutkonservenNummer:
            _begleitscheinBlutkonservenNummer ?? "",
        begleitscheinPatientName: _begleitscheinPatientName ?? "",
        begleitscheinBirthDate: _begleitscheinBirthDate ?? "",
        blutKonservenNummer: _blutKonservenNummer ?? "",
        blutkonservenBloodType: _blutkonservenBloodType ?? "",
        blutkonservenProductType: _blutkonservenProductType ?? "",
        patientWristBandFallnummer: _patientWristBandFallnummer ?? "",
        bedsideTestResult: _bedsideTestResult ?? "",
        scanSuccess: verifyAllData() ? 1 : 0,
      ),
    );
    if (response != 0) {
      resetData();
    }
    return response;
  }
}

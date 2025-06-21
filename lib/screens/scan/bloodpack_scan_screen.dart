import 'dart:io';

import 'package:flutter/material.dart';
// --- PLUGIN CHANGE: CORRECTED the import path based on the official example ---
import 'package:dynamsoft_capture_vision_flutter/dynamsoft_capture_vision_flutter.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart'; // Needed for InputImage
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:secureblood/providers/collected_data_provider.dart';
import 'package:flutter/services.dart';
import 'package:secureblood/utils/data_missmatch_alert_dialog.dart';
import 'package:secureblood/utils/blood_product_enum.dart';
import 'package:secureblood/utils/plasma_transfusion_dialog.dart';
import 'package:intl/intl.dart';

// Enum to manage the scan status of each individual item
enum ScanStatus { pending, success, mismatch }

class BloodPackScanScreen extends StatefulWidget {
  const BloodPackScanScreen({super.key});

  @override
  State<BloodPackScanScreen> createState() => _BloodPackScanScreenState();
}

class _BloodPackScanScreenState extends State<BloodPackScanScreen> with WidgetsBindingObserver {
  final player = AudioPlayer();
  late Duration playerDuration;
  
  // --- SDK INSTANCES ---
  late final DCVBarcodeReader _barcodeReader;
  late final DCVCameraEnhancer _cameraEnhancer;
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  final DCVCameraView _cameraView = DCVCameraView();

  bool _isProcessing = false;
  bool _isSDKInitialized = false;

  // --- State variables ---
  String _bloodPackNumber = "";
  String _bloodPackType = "";
  String _bloodProductType = "";
  String _verfallsdatum = "";
  bool _isExpired = false;
  String? _isFullTransfusion;

  // Status variables for UI feedback
  ScanStatus _numberStatus = ScanStatus.pending;
  ScanStatus _productStatus = ScanStatus.pending;
  ScanStatus _bloodTypeStatus = ScanStatus.pending;
  ScanStatus _expiryStatus = ScanStatus.pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSDKs();
    loadBlutKonservenData();
    _initAudio();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraEnhancer.close();
    _barcodeReader.stopScanning();
    _textRecognizer.close();
    player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isSDKInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _cameraEnhancer.open();
        _barcodeReader.startScanning();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _cameraEnhancer.close();
        _barcodeReader.stopScanning();
        break;
    }
  }

  // --- Initialize both Dynamsoft and Google ML Kit SDKs ---
  Future<void> _initSDKs() async {
    try {
      // 1. Initialize Dynamsoft License
      await DCVBarcodeReader.initLicense('t0088pwAAAEaNEW1MT8a+e1yOQ2Rk2KacBHKPIIYjqBNRka/krg6crkgDEFIjYUBICPZS2XknST15RQF2LAAzUF5R0sleoZo/6JHtjfl80c7GXxWqovQCGBEhjA==;t0089pwAAADBN5hkLkxI1EnWYs7kqdhfTWAlIKgJrkZ/je8NXG1r5nm5xsRUUQd8JTbBaWoAkOJbqN3fjqdODQLdkL3NiJoJbDPuiUw81jhfa/PFXhrIonSxtIa8=;t0088pwAAAD1Wfen8lyAawheMaa23AEKiRTwAI6/3QlPhizrHzeDqynGNlQH6qns6bGt66rvXWwaFy1puwPo5+YvE5OYRfPz7Rhfs2ZjlQlsbf2Qoi9IJMvUhug==');

      // 2. Create SDK instances
      _barcodeReader = await DCVBarcodeReader.createInstance();
      _cameraEnhancer = await DCVCameraEnhancer.createInstance();

      // 3. Configure Barcode Reader Settings
      DBRRuntimeSettings currentSettings =
          await _barcodeReader.getRuntimeSettings();
      currentSettings.barcodeFormatIds = EnumBarcodeFormat.BF_CODE_128;
      // Optimize for finding multiple barcodes
      currentSettings.expectedBarcodeCount = 3; 
      await _barcodeReader.updateRuntimeSettings(currentSettings);

      // 4. Set up the camera view and result listener
      _cameraEnhancer.setScanRegion(Region(
        regionTop: 20, regionLeft: 5, regionBottom: 60, regionRight: 95, regionMeasuredByPercentage: 1
      ));
      _cameraView.overlayVisible = true;

      // Listen to the barcode result stream
      _barcodeReader.receiveResultStream().listen(_processBarcodeStream);

      // 5. Open the camera to start the live feed
      await _cameraEnhancer.open();
      _barcodeReader.startScanning();

      setState(() {
        _isSDKInitialized = true;
      });
    } catch (e) {
      print('Error initializing SDKs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scanner konnte nicht initialisiert werden: $e')));
      }
    }
  }
  
  /// Processes results from the LIVE barcode stream.
  void _processBarcodeStream(List<BarcodeResult>? results) {
    if (results == null || results.isEmpty || _isProcessing) return;
    
    // Use a temporary set to avoid processing the same barcode multiple times
    final Set<String> processedValues = {};

    for (final barcode in results) {
      final String? value = barcode.barcodeText;
      if (value == null || processedValues.contains(value)) continue;

      _parseBarcode(value);
      processedValues.add(value);
    }
    
    // Check if all barcodes have been found
    if (_bloodPackNumber.isNotEmpty && _bloodProductType.isNotEmpty && _bloodPackType.isNotEmpty) {
      // If so, stop scanning and capture an image for OCR
      if (!_isProcessing) { // Ensure we only trigger this once
        _isProcessing = true;
        _barcodeReader.stopScanning();
        _captureImageForOCR();
      }
    }

    // Update the UI with found barcodes
    if(mounted) {
      setState(() {
        compareAllData();
      });
    }
  }

  /// Captures a single frame for text recognition once all barcodes are found.
  Future<void> _captureImageForOCR() async {
    try {
      // **FIX: Changed DCVImageResult to DCVCameraImage**
      final DCVCameraImage? imageResult = await _cameraEnhancer.takePicture(); 
      if (imageResult == null) {
        setState(() { _isProcessing = false; });
        return;
      }
      
      final InputImage inputImage = InputImage.fromBytes(bytes: imageResult.bytes, metadata: InputImageMetadata(
        size: Size(imageResult.width.toDouble(), imageResult.height.toDouble()),
        rotation: InputImageRotation.rotation0deg, // Rotation is handled by DCV
        format: InputImageFormat.bgra8888,
        bytesPerRow: imageResult.stride,
      ));

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      _processRecognizedText(recognizedText);

    } catch (e) {
      print("Error during OCR capture: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          compareAllData();
        });
      }
    }
  }

  /// Extracts barcode information from the list of detected barcodes.
  void _parseBarcode(String value) {
      if (value.startsWith("!276") && _numberStatus == ScanStatus.pending) {
        _bloodPackNumber = value.replaceAll("!", "");
        showFeedbackForValidBarcode();
      } else if (value.startsWith("!P") && _productStatus == ScanStatus.pending) {
        String extractedProductType = value.substring(2, 3);
        if (extractedProductType == "5") {
          showPlasmaTransfusionDialog(context).then((isFullTransfusion) {
            if (mounted) {
              setState(() {
                _isFullTransfusion = isFullTransfusion ? "1" : "0";
              });
            }
          });
        }
        _bloodProductType = extractedProductType;
        showFeedbackForValidBarcode();
      } else if (value.startsWith("!R") && _bloodTypeStatus == ScanStatus.pending) {
        String extractedBloodType = value.substring(2, 3);
        List<String> bloodTypes = ["A", "B", "AB", "0"];
        _bloodPackType = bloodTypes[int.parse(extractedBloodType) - 1];
        showFeedbackForValidBarcode();
      }
  }

  /// Extracts the expiration date from the recognized text.
  void _processRecognizedText(RecognizedText recognizedText) {
    if (_expiryStatus != ScanStatus.pending) return;

    final dateRegex = RegExp(r'(\d{2})\.(\d{2})\.(\d{4})');

    for (final block in recognizedText.blocks) {
      if (block.text.toLowerCase().contains("verwendbar bis")) {
        final match = dateRegex.firstMatch(block.text);
        if (match != null) {
          _parseAndSetExpiryDate(match.group(0)!);
          showFeedbackForValidBarcode();
          return;
        }
      }
    }
  }

  void _parseAndSetExpiryDate(String dateStr) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    try {
      final expiryDate = dateFormat.parse(dateStr);
      final today = DateTime.now();
      final todayDateOnly = DateTime(today.year, today.month, today.day);

      _isExpired = expiryDate.isBefore(todayDateOnly);
      _verfallsdatum = dateFormat.format(expiryDate);

      if (_isExpired) {
        _showExpiredWarningDialog(expiryDate);
      }
    } catch (e) {
      print("Error parsing date: $e");
    }
  }

  /// Compares all extracted data and updates their UI status.
  void compareAllData() {
    final collectedData =
        Provider.of<CollectedDataProvider>(context, listen: false);

    _numberStatus = _bloodPackNumber.isNotEmpty
        ? (_bloodPackNumber == collectedData.begleitscheinBlutkonservenNummer
            ? ScanStatus.success
            : ScanStatus.mismatch)
        : ScanStatus.pending;

    _productStatus =
        _bloodProductType.isNotEmpty ? ScanStatus.success : ScanStatus.pending;

    _bloodTypeStatus = _bloodPackType.isNotEmpty
        ? (_bloodPackType == collectedData.begleitscheinBlutkonserveBloodType
            ? ScanStatus.success
            : ScanStatus.mismatch)
        : ScanStatus.pending;

    _expiryStatus = _verfallsdatum.isNotEmpty
        ? (_isExpired ? ScanStatus.mismatch : ScanStatus.success)
        : ScanStatus.pending;
  }

  Future<void> _showExpiredWarningDialog(DateTime expiryDate) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text('Produkt abgelaufen'),
            ],
          ),
          content: Text(
              'Dieses Blutprodukt ist seit dem ${DateFormat('dd.MM.yyyy').format(expiryDate)} abgelaufen und darf nicht verwendet werden.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Verstanden'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _initAudio() async {
    playerDuration = (await player.setAsset('assets/scan_success.mp3'))!;
  }

  void _playAudio() async {
    await player.seek(Duration.zero);
    await player.play();
  }

  void showFeedbackForValidBarcode() {
    HapticFeedback.heavyImpact();
    _playAudio();
  }

  void clearValues() {
    setState(() {
      _bloodPackNumber = "";
      _bloodPackType = "";
      _bloodProductType = "";
      _verfallsdatum = "";
      _isExpired = false;
      _isFullTransfusion = null;
      _numberStatus = ScanStatus.pending;
      _productStatus = ScanStatus.pending;
      _bloodTypeStatus = ScanStatus.pending;
      _expiryStatus = ScanStatus.pending;
      if (_isSDKInitialized) {
        _barcodeReader.startScanning();
      }
    });
  }

  void saveAndContinue() {
    CollectedDataProvider collectedData =
        Provider.of<CollectedDataProvider>(context, listen: false);
    collectedData.setBloodPackData(
      _bloodPackNumber,
      _bloodPackType,
      _bloodProductType,
      _isFullTransfusion,
      verfallsdatum: _verfallsdatum,
      isExpired: _isExpired,
    );
    Navigator.pop(context);
  }

  loadBlutKonservenData() {
    CollectedDataProvider collectedData =
        Provider.of<CollectedDataProvider>(context, listen: false);
    setState(() {
      _bloodPackNumber = collectedData.blutKonservenNummer ?? "";
      _bloodPackType = collectedData.blutkonservenBloodType ?? "";
      _bloodProductType = collectedData.blutkonservenProductType ?? "";
      _verfallsdatum = collectedData.verfallsdatum ?? "";
      _isExpired = collectedData.isBloodPackExpired;

      if (_bloodPackNumber.isNotEmpty ||
          _bloodPackType.isNotEmpty ||
          _bloodProductType.isNotEmpty) {
        compareAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool allScanned = _numberStatus != ScanStatus.pending &&
        _productStatus != ScanStatus.pending &&
        _bloodTypeStatus != ScanStatus.pending &&
        _expiryStatus != ScanStatus.pending;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Blutkonserve erfassen"),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: _isSDKInitialized
                      ? _cameraView
                      : const Center(child: CircularProgressIndicator()),
                ),
                const SizedBox(height: 20),
                StatusInfoCard(
                  label: "Blutkonservennummer",
                  value: _bloodPackNumber,
                  status: _numberStatus,
                ),
                StatusInfoCard(
                  label: "Blutprodukttyp",
                  value: _bloodProductType.isEmpty
                      ? "-"
                      : BloodProductTypes.fromValue(
                                  int.parse(_bloodProductType))
                              ?.label ??
                          "-",
                  status: _productStatus,
                ),
                StatusInfoCard(
                  label: "Verfallsdatum",
                  value: _verfallsdatum,
                  status: _expiryStatus,
                ),
                StatusInfoCard(
                  label: "Blutgruppe",
                  value: _bloodPackType,
                  status: _bloodTypeStatus,
                ),
                const SizedBox(height: 20),
                if (allScanned)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Alle Daten erfasst!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                TextButton.icon(
                    onPressed: clearValues,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Scan zurücksetzen")),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: allScanned ? saveAndContinue : null,
                  child: const Text("Speichern und forfahren"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A dedicated widget to show the status of each scanned piece of information.
class StatusInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final ScanStatus status;

  const StatusInfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.status,
  });

  IconData get _icon {
    switch (status) {
      case ScanStatus.pending:
        return Icons.hourglass_empty;
      case ScanStatus.success:
        return Icons.check_circle;
      case ScanStatus.mismatch:
        return Icons.error;
    }
  }

  Color get _color {
    switch (status) {
      case ScanStatus.pending:
        return Colors.grey;
      case ScanStatus.success:
        return Colors.green;
      case ScanStatus.mismatch:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(_icon, color: _color, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isEmpty ? "-" : value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color:
                            status == ScanStatus.mismatch ? Colors.red : null),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

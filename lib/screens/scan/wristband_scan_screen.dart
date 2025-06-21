import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:secureblood/providers/collected_data_provider.dart';
import 'package:flutter/services.dart';

import '../../utils/data_missmatch_alert_dialog.dart';
import '../../widgets/countdown_widget.dart';

class WristbandScanScreen extends StatefulWidget {
  const WristbandScanScreen({super.key});

  @override
  State<WristbandScanScreen> createState() => _WristbandScanScreenState();
}

class _WristbandScanScreenState extends State<WristbandScanScreen> {
  bool _scanProgressStarted = false;
  Duration? _scanCountdownDuration;
  final player = AudioPlayer();
  late Duration playerDuration;

  String _caseNumber = "";
  Color _scanColor = Colors.white;

  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.all],
  );

  void _handleBarcode(BarcodeCapture barcodes) {
    if (!_scanProgressStarted) return;
    if (mounted) {
      final currentBarcode = barcodes.barcodes.firstOrNull;
      if (currentBarcode != null && mounted) {
        verifyBarcode(currentBarcode);
      }
    }
  }

  void _initAudio() async {
    playerDuration = (await player.setAsset('assets/scan_success.mp3'))!;
  }

  void _playAudio() async {
    await player.seek(Duration.zero);
    await player.play();
  }

  void verifyBarcode(
    Barcode barcode,
  ) {
    if (barcode.displayValue == null || (_caseNumber.isNotEmpty)) {
      return;
    }
    String barcodeValue = barcode.displayValue!;

    showFeedbackForValidBarcode();

    setState(() {
      _caseNumber = barcodeValue;
    });
    compareWristbandWithBegleitschein();
  }

  void showFeedbackForValidBarcode() async {
    HapticFeedback.heavyImpact();
    _playAudio();
    setState(() {
      _scanColor = Colors.green;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _scanColor = Colors.white;
      });
    });
  }

  void compareWristbandWithBegleitschein() {
    CollectedDataProvider collectedData =
        Provider.of<CollectedDataProvider>(context, listen: false);
    if (collectedData.begleitscheinFallnummer != _caseNumber) {
      showDataMissmatchAlertDialog(context,
              begleitscheinValue: collectedData.begleitscheinFallnummer!,
              scannedValue: _caseNumber,
              scanSource: "Patientenarmband",
              label: "Fallnummer")
          .then((scanAgain) => scanAgain == null
              ? null
              : scanAgain
                  ? clearValues()
                  : mounted
                      ? Navigator.pop(context)
                      : null);
    }
  }

  clearValues() {
    setState(() {
      _caseNumber = "";
      _scanProgressStarted = false;
    });
  }

  void saveAndContinue() {
    CollectedDataProvider collectedData =
        Provider.of<CollectedDataProvider>(context, listen: false);
    collectedData.setPatientBraceletBarcode(_caseNumber);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    loadArmbandData();
    _initAudio();
  }

  loadArmbandData() {
    final collectedDataProvider =
        Provider.of<CollectedDataProvider>(context, listen: false);
    setState(() {
      _caseNumber = collectedDataProvider.patientWristBandFallnummer ?? "";
      _caseNumber.isNotEmpty
          ? _scanProgressStarted = true
          : _scanProgressStarted = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: Offset(MediaQuery.sizeOf(context).width / 2, 150),
      width: MediaQuery.sizeOf(context).width * 0.9,
      height: 100,
    );
    final MobileScannerController controller = MobileScannerController(
      formats: const [BarcodeFormat.all],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patientenarmband scannen"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 300,
              child: Stack(
                children: [
                  Container(color: Colors.black),
                  MobileScanner(
                    onDetect: _handleBarcode,
                    scanWindow: scanWindow,
                    controller: controller,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.9,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: _scanColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                            _scanCountdownDuration != null
                                ? _scanCountdownDuration!.inSeconds.toString()
                                : "",
                            style: TextStyle(shadows: [
                              Shadow(
                                blurRadius: 20.0,
                                color: Colors.black.withOpacity(
                                    0.5), // shadow color with opacity
                              ),
                            ], color: Colors.white, fontSize: 40)),
                      ),
                    ),
                  )
                ],
              ),
            ),
            !_scanProgressStarted
                ? Center(
                    child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text("Scan vorbereiten",
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Bringen Sie das Patientenarmband\n"
                        "in den Scanbereich und drücken Sie auf\n"
                        "Scan starten.",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      CountdownWidget(
                          duration: const Duration(seconds: 3),
                          onTick: (remainingTime) => setState(() {
                                _scanCountdownDuration = remainingTime;
                              }),
                          label: "Scan starten",
                          onDone: () => setState(() {
                                _scanProgressStarted = true;
                              })),
                    ],
                  ))
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: _caseNumber.isEmpty
                                ? Colors.blue
                                : Colors.green,
                          ),
                          child: Row(
                            children: [
                              _caseNumber.isNotEmpty
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.white)
                                  : const Icon(Icons.info, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                _caseNumber.isEmpty
                                    ? "Scanne den Barcode mit \nFallnummer auf dem Armband"
                                    : "Armband erfolgreich gescannt",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "Fallnummer",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    Text(
                                      _caseNumber.isEmpty ? "-" : _caseNumber,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                            onPressed: () {
                              clearValues();
                            },
                            child: const Text("Barcode erneut scannen")),
                        ElevatedButton(
                          onPressed:
                              _caseNumber.isNotEmpty ? saveAndContinue : null,
                          child: const Text("Speichern und fortfahren"),
                        ),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     verifyBarcode(Barcode(displayValue: "01234567"));
                        //   },
                        //   child: const Text("set dummy barcode"),
                        // ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

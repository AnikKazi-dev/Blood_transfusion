import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:secureblood/main.dart';
import 'package:secureblood/providers/collected_data_provider.dart';
import 'package:secureblood/screens/scan/scan_overview_screen.dart';

import '../../providers/timer_provider.dart';
import '../../widgets/camera_widget.dart';
import '../../services/recognized_text_service.dart';

class BegleitscheinErfassenScreen extends StatefulWidget {
  const BegleitscheinErfassenScreen({super.key});

  @override
  State<BegleitscheinErfassenScreen> createState() =>
      _BegleitscheinErfassenScreenState();
}

class _BegleitscheinErfassenScreenState
    extends State<BegleitscheinErfassenScreen> {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final GlobalKey<CameraWidgetState> _cameraWidgetKey =
      GlobalKey<CameraWidgetState>();

  String patientName = "";
  String birthDate = "";
  String recieverBloodType = "";
  String blutkonserveBloodType = "";
  String fallnummer = "";
  String blutkonservennummer = "";

  RecognizedText? recognizedText;

  bool _canProcess = true;
  bool _isBusy = false;

  @override
  void dispose() {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadBegleitscheinData();
  }

  void _loadBegleitscheinData() {
    final begleitscheinProvider =
        Provider.of<CollectedDataProvider>(context, listen: false);

    if (begleitscheinProvider.getBegleitscheinIsDefined()) {
      setState(() {
        recieverBloodType =
            begleitscheinProvider.begleitscheinRecieverBloodType ?? "";
        blutkonserveBloodType =
            begleitscheinProvider.begleitscheinBlutkonserveBloodType ?? "";
        fallnummer = begleitscheinProvider.begleitscheinFallnummer ?? "";
        blutkonservennummer =
            begleitscheinProvider.begleitscheinBlutkonservenNummer ?? "";
        patientName = begleitscheinProvider.begleitscheinPatientName ?? "";
        birthDate = begleitscheinProvider.begleitscheinBirthDate ?? "";
      });
    } else {
      // Delay so camerawidget is initialized
      Future.delayed(Duration.zero, () {
        _cameraWidgetKey.currentState?.getImage(ImageSource.camera);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final begleitscheinProvider =
        Provider.of<CollectedDataProvider>(context, listen: false);

    saveAndContinue() {
      begleitscheinProvider.setBegleitschein(
        recieverType: recieverBloodType,
        caseNumber: fallnummer,
        bloodPackNumber: blutkonservennummer,
        bloodPackType: blutkonserveBloodType,
        patientName: patientName,
        birthDate: birthDate,
      );

      // set timer for countdown
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      timerProvider.setStartTime(DateTime.now());

      // navigate to scan screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const ScanOverviewScreen(),
        ),
        (route) => false,
      );
    }

    Future<void> processImage(InputImage inputImage) async {
      if (!_canProcess) return;
      if (_isBusy) return;
      _isBusy = true;

      recognizedText = await _textRecognizer.processImage(inputImage);
      // for (var block in recognizedText!.blocks) {
      //   print("--------BLOCK---------");
      //   for (var line in block.lines) {
      //     print("--------LINE---------");
      //     print(line.text);
      //   }
      // }

      setState(() {
        recognizedText = recognizedText;
        patientName = getNameFromRecognizedText(recognizedText!);
        birthDate = getBirthDateFromRecognizedText(recognizedText!);
        recieverBloodType = getRecieverTypeFromRecognizedText(recognizedText!);
        blutkonserveBloodType =
            getBloodPackTypeFromRecognizedText(recognizedText!);
        fallnummer = getCaseNumberFromRecognizedText(recognizedText!);
        blutkonservennummer =
            getBloodPackNumberFromRecognizedText(recognizedText!);
      });

      //haptic feedback when all fields are filled
      if (recieverBloodType.isNotEmpty &&
          blutkonserveBloodType.isNotEmpty &&
          fallnummer.isNotEmpty &&
          blutkonservennummer.isNotEmpty) {
        HapticFeedback.heavyImpact();
      }

      _isBusy = false;
      if (mounted) {
        setState(() {});
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Begleitschein erfassen'),
        leading: !begleitscheinProvider.getBegleitscheinIsDefined()
            ? IconButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.close),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      LabelCard(
                        label: "Name",
                        value: patientName,
                        context: context,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      LabelCard(
                        label: "Geburtsdatum",
                        value: birthDate,
                        context: context,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      LabelCard(
                        label: "Fall Nr.",
                        value: fallnummer,
                        context: context,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      LabelCard(
                        label: "Blutgruppe Patient",
                        value: recieverBloodType,
                        context: context,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      LabelCard(
                          label: "Präparat Nr. ",
                          value: blutkonservennummer,
                          context: context),
                      const SizedBox(
                        height: 10,
                      ),
                      LabelCard(
                          label: "Blutgruppe Blutkonserve",
                          value: blutkonserveBloodType,
                          context: context),
                      const SizedBox(
                        height: 10,
                      ),
                      CameraWidget(
                        onImage: processImage,
                        key: _cameraWidgetKey,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: fallnummer.isNotEmpty &&
                            recieverBloodType.isNotEmpty &&
                            blutkonservennummer.isNotEmpty &&
                            blutkonserveBloodType.isNotEmpty
                        ? saveAndContinue
                        : null,
                    child: const Text("Speichern und forfahren"),
                  ),
                  // ElevatedButton(
                  //     onPressed: () {
                  //       begleitscheinProvider.setBegleitschein(
                  //           bloodPackNumber: "276 123456",
                  //           bloodPackType: "Y",
                  //           caseNumber: "0123456789",
                  //           recieverType: "Y");
                  //       _loadBegleitscheinData();
                  //     },
                  //     child: const Text("save dummy data")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LabelCard extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;
  const LabelCard(
      {required this.label,
      this.value = "-",
      required this.context,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

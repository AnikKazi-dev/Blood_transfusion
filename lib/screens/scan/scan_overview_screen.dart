import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secureblood/main.dart';
import 'package:secureblood/providers/collected_data_provider.dart';
import 'package:secureblood/screens/bedsidetest_screen.dart';

import 'package:secureblood/screens/scan/begleitschein_scan_screen.dart';
import 'package:secureblood/screens/scan/bloodpack_scan_screen.dart';
import 'package:secureblood/screens/user_flow/scan_complete_screen.dart';
import 'package:secureblood/screens/scan/wristband_scan_screen.dart';
import 'package:secureblood/widgets/timer_widget.dart';

import '../../providers/timer_provider.dart';
import '../../utils/time_up_alert_dialog.dart';
import '../../widgets/bloodtype_compatibility_widget.dart';
import '../../widgets/square_scanstart_button_widget.dart';

class ScanOverviewScreen extends StatefulWidget {
  const ScanOverviewScreen({super.key});

  @override
  State<ScanOverviewScreen> createState() => _ScanOverviewScreenState();
}

class _ScanOverviewScreenState extends State<ScanOverviewScreen> {
  Duration _remainingTime = const Duration(minutes: 15);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initTimer();
  }

  void initTimer() {
    TimerProvider timerProvider =
        Provider.of<TimerProvider>(context, listen: false);
    if (timerProvider.startTime == null) {
      return;
    }
    _timer?.cancel();

    _remainingTime = timerProvider.startTime!
        .add(const Duration(minutes: 15))
        .difference(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > Duration.zero) {
        if (mounted) {
          setState(() {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          });
        }
      } else {
        _timer?.cancel();
        if (mounted) {
          final collectedData =
              Provider.of<CollectedDataProvider>(context, listen: false);
          collectedData.saveDataToDB().then((_) {
            mounted ? showTimeIsOverAlert(context) : null;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final collectedData =
        Provider.of<CollectedDataProvider>(context, listen: true);

    void saveDataToDB() async {
      await collectedData.saveDataToDB().then((_) {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Erfasste Daten wurden in das Protkoll übertragen.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ));
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) {
            return false;
          });
        }
      });
    }

    List<Widget> squareButtonList = [
      SquareScanStartButton(
        isBegleitschein: true,
        title: "Begleitschein",
        isCorrect: collectedData.getBegleitscheinIsDefined() ? true : null,
        action: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BegleitscheinErfassenScreen()));
        },
      ),
      SquareScanStartButton(
        title: "Blutkonserve",
        // --- MODIFIED LOGIC ---
        // The button is only "correct" if the data matches AND the product is not expired.
        isCorrect: !collectedData.getBlutpaketIsDefined()
            ? null
            : (collectedData.verifyBlutPaket() &&
                !collectedData.isBloodPackExpired),
        action: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BloodPackScanScreen()));
        },
      ),
      SquareScanStartButton(
        title: "Patientenarmband",
        isCorrect: collectedData.patientWristBandFallnummer == null
            ? null
            : collectedData.verifyWristBand(),
        action: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const WristbandScanScreen()));
        },
      ),
      SquareScanStartButton(
          title: "Bedside Test",
          label: "Eingeben",
          customIcon: Icons.bloodtype,
          inactive: collectedData.isFullTransfusion == "1",
          isCorrect: collectedData.bedsideTestResult == null
              ? null
              : collectedData.verifyBedsideTest(),
          action: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BedsidetestScreen()));
          }),
    ];

    return Scaffold(
        appBar: AppBar(
          title: const Text('xxx Dokumente erfassen'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        const TimerWidget(),
                        const SizedBox(
                          height: 10,
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            var width = constraints.maxWidth / 2 - 5;
                            //shrink height on smaller screens to fit height of the screen
                            var height =
                                constraints.maxWidth < 360 ? 130.0 : width;
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: width,
                                      height: height,
                                      child: squareButtonList[0],
                                    ),
                                    SizedBox(
                                      width: width,
                                      height: height,
                                      child: squareButtonList[1],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: width,
                                      height: height,
                                      child: squareButtonList[2],
                                    ),
                                    SizedBox(
                                      width: width,
                                      height: height,
                                      child: squareButtonList[3],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            );
                          },
                        ),

                        if (collectedData.begleitscheinRecieverBloodType !=
                                null &&
                            collectedData.blutkonservenBloodType != null)
                          BloodTypeCompatibilityWidget(
                            recieverBloodType:
                                collectedData.begleitscheinRecieverBloodType!,
                            bloodPackBloodType:
                                collectedData.blutkonservenBloodType!,
                            productType:
                                collectedData.blutkonservenProductType!,
                          ),

                        const SizedBox(height: 10),
                        // ElevatedButton(
                        //     onPressed: saveDataToDB, child: const Text("save db")),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                    width: double.infinity,
                    child: collectedData.verifyAllData()
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_outlined,
                                size: 50,
                                color: Colors.green,
                              ),
                              const Text("Alle Daten stimmen überein"),
                              ElevatedButton(
                                  onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ScanCompleteScreen()),
                                      ),
                                  child: const Text("Scan abschließen"))
                            ],
                          )
                        : collectedData.getBegleitscheinIsDefined() &&
                                collectedData.getBlutpaketIsDefined() &&
                                collectedData.patientWristBandFallnummer !=
                                    null &&
                                (collectedData.bedsideTestResult != null ||
                                    collectedData.isFullTransfusion == "0")
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 50,
                                      color: Colors.red,
                                    ),
                                    const Text("Daten stimmen nicht überein"),
                                    ElevatedButton(
                                        onPressed: saveDataToDB,
                                        child: const Text(
                                            "Ignorieren und Scan beenden"))
                                  ])
                            : collectedData.getBegleitscheinIsDefined()
                                ? Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        const Icon(
                                          Icons.info_outline_rounded,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        const Text("Daten nicht vollständig."),
                                        ElevatedButton(
                                            onPressed: saveDataToDB,
                                            child: const Text(
                                                "Ignorieren und Scan beenden"))
                                      ])
                                : null)
              ],
            ),
          ),
        ));
  }
}

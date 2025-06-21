import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:secureblood/providers/collected_data_provider.dart';
import 'package:secureblood/providers/timer_provider.dart';
import 'package:secureblood/screens/history/history_screen.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:secureblood/screens/user_flow/checklist_screen.dart';
import 'package:secureblood/theme/secureblood_theme.dart';
import 'widgets/start_scan_button_widget.dart';

void main() async {
  Intl.defaultLocale = 'de_DE';
  initializeDateFormatting().then((_) => runApp(const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CollectedDataProvider>(
            create: (_) => CollectedDataProvider()),
        ChangeNotifierProvider<TimerProvider>(create: (_) => TimerProvider()),
      ],
      builder: (context, child) => MaterialApp(
        theme: secureBloodThemeData,
        home: const HomeScreen(),
        locale: const Locale("de", "DE"),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20.0,
            )
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.crop_free_sharp), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined), label: 'Historie'),
          ],
        ),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          _buildNavigator(0, const HomeWidget()),
          _buildNavigator(1, const HistoryScreen()),
        ],
      ),
    );
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => child,
        );
      },
    );
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SecureBlood"),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StartScanButton(
                icon: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade50,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(
                    Icons.bloodtype_outlined,
                    size: 30,
                    color: Colors.blue,
                  ),
                ),
                headline: "Regulär",
                description: "Begleitdokument und\nPatientenarmband vorhanden",
                action: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).push(MaterialPageRoute(
                      builder: (context) => const ChecklistScreen(),
                      fullscreenDialog: true));
                },
              ),
              const SizedBox(height: 20),
              StartScanButton(
                icon: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(
                    Icons.warning_amber,
                    size: 30,
                    color: Colors.red,
                  ),
                ),
                headline: "Notfall",
                description:
                    "Vitalbedrohliche Notfallsituation, Begleitdokument und Patientenarmband nicht vorhanden",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

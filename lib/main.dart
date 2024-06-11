import 'package:flutter/material.dart';
import 'package:flutter_focal/history.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_focal/bottom_nav_bar.dart';
import 'package:flutter_focal/app_bar.dart';
import 'package:flutter_focal/timer_display.dart';
import 'package:flutter_focal/profile_display.dart';

void main() async {
  await Hive.initFlutter(); // initialize Hive and create/open boxes
  Hive.registerAdapter(HistoryAdapter());
  await Hive.openBox("TimeMeditatedBox"); // timeMeditatedSeconds
  await Hive.openBox("StreakBox"); // streakCount
  await Hive.openBox("SessionBox"); // sessionCount
  await Hive.openBox<History>("HistoryBox"); // history data
  await Hive.openBox("ColorBox"); // selected tertiary color
  await Hive.openBox(
      "ShowOpeningDialogBox"); // whether or not to show onboarding or update info
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var _mainColorBox = Hive.box("ColorBox");

    int tertiaryColor =
        _mainColorBox.get('tertiaryColor', defaultValue: 0xFF9B9B9B);

    _mainColorBox.watch().listen(
      (event) {
        tertiaryColor =
            _mainColorBox.get('tertiaryColor', defaultValue: 0xFF9B9B9B);
        print("set new color to $tertiaryColor");
      },
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: const Color.fromARGB(255, 68, 68, 68), //main color
          onPrimary:
              const Color.fromARGB(255, 238, 238, 238), //for text, contrast
          tertiary: Color(tertiaryColor),
          /*Color(
              0xFF9B9B9B),*/ //used in heatmap shade, customizable in profile settings
          background: const Color.fromARGB(255, 26, 26, 26),
          onBackground: const Color.fromARGB(
              255, 238, 238, 238), //buttons, displays on background
          error: Colors.red,
          onError: Colors.black,

          //not in use but are required arguments
          secondary: Colors.red,
          onSecondary: Colors.red,
          onSurface: Colors.white, //flutter wants to use this for text items
          surface: Colors.white, //maybe will use this for navbar
        ),
        fontFamily: 'InriaSans',
      ),
      home: const Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedPageIndex = 0;

  final List<Widget> _pages = [
    TimerPage(),
    ProfilePage(),
  ];

  void _handleSelectedPageIndex(int newIndex) {
    setState(() => _selectedPageIndex = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _selectedPageIndex == 0
          ? null
          : AppBarClass(currentAppBarIndex: _selectedPageIndex),
      body: SafeArea(
        child: Container(
          child: IndexedStack(
            index: _selectedPageIndex,
            children: _pages,
          ),
        ),
      ),
      bottomNavigationBar:
          BottomNavBar(onIndexChanged: _handleSelectedPageIndex),
    );
  }
}

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TimerDisplay(key: timerDisplayStateKey),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProfileDisplay(),
        ],
      ),
    );
  }
}

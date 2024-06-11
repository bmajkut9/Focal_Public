import 'package:flutter/material.dart';
import 'package:flutter_focal/history.dart';
import 'package:flutter_focal/timer_display.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_focal/settings_display.dart';

class MinutesDataHandlerAndDisplay extends StatefulWidget {
  const MinutesDataHandlerAndDisplay({super.key});

  @override
  State<MinutesDataHandlerAndDisplay> createState() =>
      MinutesDataHandlerAndDisplayState();
}

//void callback approach
class MinutesDataHandlerAndDisplayState
    extends State<MinutesDataHandlerAndDisplay> {
  final _timeBox = Hive.box("TimeMeditatedBox");
  late int totalTimeSec; //defined in initializeData()?

  @override
  void initState() {
    super.initState();
    initializeData();
    setupCallback();
    print("MM increment callback initialized");
    sendClearMinsMeditatedCallback();
    print("MM delete callback init");
  }

  void initializeData() {
    int pastTimeMeditatedSec = _timeBox.get("seconds", defaultValue: 0);
    print("initialized pastTimeMeditatedSec: $pastTimeMeditatedSec");
    //set sessionTimeSec to value in timer_display (I wonder if we can just increment totalTimeSec
    //and make a callback from timer_display)
    totalTimeSec = pastTimeMeditatedSec;
  }

  //callback from timer_display
  void writeData() {
    print("writeData called by voidCallback");
    totalTimeSec += 1;
    _timeBox.put("seconds", totalTimeSec);

    //tests, should update every timer second
    print(_timeBox.keys);
    print(_timeBox.values);

    setState(() {
      //update text widget
      totalTimeSec;
    });
  }

  void setupCallback() {
    timerDisplayStateKey.currentState?.registerCallback(writeData);
    print("callback setup in instance ${this.hashCode}");
  }

  Future<void> clearMinsMeditated() async {
    await _timeBox.clear();
    print("Deleted MM");
    return setState(() {
      totalTimeSec = 0;
    });
  }

  void sendClearMinsMeditatedCallback() {
    RecieveMinutesDeleteCallback.instance
        .registerMinutesDeleteCallback(clearMinsMeditated);
    print("sent MM callback");
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${totalTimeSec ~/ 60}",
      style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500),
    );
  }
}

//static method ValueNotifier approach
class SessionsDataHandling {
  static var _sessionBox = Hive.box("SessionBox");
  static int totalSessionCount =
      0; //used to write to hive box from ValueNotifier
  static final ValueNotifier<int> totalSessionCountNotifier = ValueNotifier(0);

  static Future<void> initializeSessionData() async {
    await getSessionData();
  }

  static Future<void> getSessionData() async {
    totalSessionCountNotifier.value =
        await _sessionBox.get("sessions", defaultValue: 0);
    print("got session data, 'session': ${totalSessionCountNotifier.value}");
  }

  static void writeSessionData(sessionSecsMeditated) async {
    totalSessionCountNotifier.value++; // add another session to session box
    totalSessionCount = totalSessionCountNotifier.value;
    await _sessionBox.put("sessions", totalSessionCount);
    print("Session box key: ${_sessionBox.keys}");
    print("Session box value: ${_sessionBox.values}");

    Box historyBox = Hive.box<History>("HistoryBox");

    DateTime dateEntry = DateTime.now();
    DateTime calendarEntry =
        DateTime(dateEntry.year, dateEntry.month, dateEntry.day);
    int heatMapShadeValue;

    switch (sessionSecsMeditated ~/ 60) {
      case <= 5:
        heatMapShadeValue = 1;
      case <= 10:
        heatMapShadeValue = 2;
      case <= 15:
        heatMapShadeValue = 3;
      case <= 20:
        heatMapShadeValue = 4;
      case <= 25:
        heatMapShadeValue = 5;
      case <= 30:
        heatMapShadeValue = 6;
      default:
        heatMapShadeValue = 6;
    }

    // logic for heat map shade if two sessions happen on the same day
    if (historyBox.isNotEmpty) {
      History lastEntry = historyBox.values.last;
      DateTime lastCalendarEntry = lastEntry.date;
      if (lastCalendarEntry == calendarEntry) {
        heatMapShadeValue += lastEntry.heatMapShadeVal;
      }
    }
    historyBox.put(
      dateEntry.millisecondsSinceEpoch ~/
          1000, // milliseconds overflows 32-bit int processing
      History(
        date: calendarEntry,
        sessionSecsMeditated: sessionSecsMeditated,
        heatMapShadeVal: heatMapShadeValue,
      ),
    );

    print(
        "History box key is ${dateEntry.millisecondsSinceEpoch ~/ 1000} and date is $calendarEntry");
    print("heatmapshade is $heatMapShadeValue");
  }

  static Future<void> clearSessions() async {
    await _sessionBox
        .clear(); // SessionsTextDisplay is listening to the box so text widget will update automatically
    getSessionData();
  }
}

class SessionsTextDisplay extends StatefulWidget {
  const SessionsTextDisplay({super.key});

  @override
  State<SessionsTextDisplay> createState() => _SessionsTextDisplayState();
}

class _SessionsTextDisplayState extends State<SessionsTextDisplay> {
  @override
  void initState() {
    super.initState();
    SessionsDataHandling.initializeSessionData().then((_) {
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: SessionsDataHandling.totalSessionCountNotifier,
        builder: (context, value, child) {
          return Text(
            "$value",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500),
          );
        });
  }
}

// using static method ValueNotifier approach as well

class StreakDataHandling {
  static var _streakBox = Hive.box("StreakBox");
  static late int streakCount;

  static final ValueNotifier<int> streakCountNotifier = ValueNotifier(0);
  static var nextDay =
      _streakBox.get("nextDay", defaultValue: DateTime(1970, 1, 1));
  static var streakExpirationDay =
      _streakBox.get("streakExpirationDay", defaultValue: DateTime(3000, 1, 1));

  static Future<void> initializeStreakData() async {
    await getStreakData();
  }

  static Future<void> getStreakData() async {
    var openedDate = DateTime.now();

    if (openedDate.isAfter(streakExpirationDay)) {
      //reset streak if opened after expiration
      await _streakBox.put("streakCount", 0);
      await _streakBox.put("nextDay", DateTime(1970, 1, 1));
      await _streakBox.put("streakExpirationDay", DateTime(3000, 1, 1));

      nextDay = _streakBox.get("nextDay");
      streakExpirationDay = _streakBox.get("streakExpirationDay");

      print("streak expired and box values reset to default");
    }

    streakCountNotifier.value =
        await _streakBox.get("streakCount", defaultValue: 0);
    print("got streak. current streak: ${streakCountNotifier.value}");
  }

  static void writeStreakData() async {
    // handle shade on heat map with sessionSecsMeditated
    final activityEntry = DateTime.now();

    //nextDay = _streakBox.get("nextDay", defaultValue: DateTime(1970, 1, 1));
    //streakExpirationDay = _streakBox.get("streakExpirationDay", defaultValue: DateTime(3000, 1, 1));

    if (activityEntry.isAfter(nextDay) &&
        activityEntry.isBefore(streakExpirationDay)) {
      streakCountNotifier.value++;
      streakCount = streakCountNotifier.value;
      nextDay = DateTime(
              activityEntry.year, activityEntry.month, activityEntry.day)
          .add(Duration(
              days: 1)); //streak can be continued as soon as next day starts
      streakExpirationDay =
          DateTime(activityEntry.year, activityEntry.month, activityEntry.day)
              .add(Duration(days: 2));

      await _streakBox.put(
        "streakCount",
        streakCountNotifier.value,
      );
      await _streakBox.put(
        "nextDay",
        nextDay,
      );
      await _streakBox.put(
        "streakExpirationDay",
        streakExpirationDay,
      );

      print("streakCountNotifier = ${streakCountNotifier.value}");
      print("streak is now ${_streakBox.get("streakCount")}");
      print("To continue must meditate after ${_streakBox.get("nextDay")}");
      print("Streak expires on ${_streakBox.get("streakExpirationDay")}");
    } else if (activityEntry.isAfter(streakExpirationDay)) {
      //for if the streak expires but the app isn't restarted
      await getStreakData();
      print("STREAK EXPIRED AND RESET");
      print("streakCountNotifier = ${streakCountNotifier.value}");
      print("streak is now ${_streakBox.get("streakCount")}");
      print("To continue must meditate after ${_streakBox.get("nextDay")}");
      print("Streak expires on ${_streakBox.get("streakExpirationDay")}");
    } else {
      print("else activated");
      print("streakCountNotifier = ${streakCountNotifier.value}");
      print("streak is now ${_streakBox.get("streakCount")}");
      print("To continue must meditate after ${_streakBox.get("nextDay")}");
      print("Streak expires on ${_streakBox.get("streakExpirationDay")}");
    }

    print("writeStreakData completed");
  }

  Future<void> clearStreak() async {
    await _streakBox.clear();
    await initializeStreakData();
  }
}

class StreakTextDisplay extends StatefulWidget {
  const StreakTextDisplay({super.key});

  @override
  State<StreakTextDisplay> createState() => _StreakTextDisplayState();
}

class _StreakTextDisplayState extends State<StreakTextDisplay> {
  @override
  void initState() {
    super.initState();
    StreakDataHandling.initializeStreakData().then((_) {
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: StreakDataHandling.streakCountNotifier,
        builder: (context, value, child) {
          return Text(
            "$value",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500),
          );
        });
  }
}

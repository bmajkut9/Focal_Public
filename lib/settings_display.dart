import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focal/history.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_focal/app_bar.dart';
import 'package:flutter_focal/use_stats.dart';

class RecieveMinutesDeleteCallback {
  RecieveMinutesDeleteCallback._privateConstructor();

  static final RecieveMinutesDeleteCallback _instance =
      RecieveMinutesDeleteCallback._privateConstructor();

  static RecieveMinutesDeleteCallback get instance => _instance;
  VoidCallback? minutesDeleteCallback;

  void registerMinutesDeleteCallback(callback) {
    minutesDeleteCallback = callback;
    print("Callback registered in instance: ${hashCode}");
    print(callback != null ? "callbackMinsDel not null" : "callback is null");
  }
}

class SettingsDisplay extends StatelessWidget {
  const SettingsDisplay({super.key});

  void showCorrespondingDialog(BuildContext context,
      {required int showDialogIndex}) {
    // index will be 0-3 corresponding to each deletion button
    if (Platform.isIOS) {
      showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return PlatformAlertDialog(
            clearMinutesFunction: () =>
                RecieveMinutesDeleteCallback.instance.minutesDeleteCallback!(),
            optionIndex: showDialogIndex,
          );
        },
      );
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return PlatformAlertDialog(
              clearMinutesFunction: () => RecieveMinutesDeleteCallback
                  .instance.minutesDeleteCallback!(),
              optionIndex: showDialogIndex,
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarClass(currentAppBarIndex: 2),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Calendar Color",
                            style: TextStyle(fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 275,
                          width: 275,
                          child: const ColorSelection(),
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 35),
                      SizedBox(width: 10),
                      Text(
                        "Reset History",
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    MaterialButton(
                      height: 48,
                      minWidth: 255,
                      elevation: 0,
                      onPressed: () {
                        showCorrespondingDialog(context, showDialogIndex: 0);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Theme.of(context).colorScheme.primary,
                      child: const Text(
                        "Reset Streak",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      height: 48,
                      minWidth: 255,
                      elevation: 0,
                      onPressed: () {
                        showCorrespondingDialog(context, showDialogIndex: 1);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Theme.of(context).colorScheme.primary,
                      child: const Text(
                        "Reset Minutes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      height: 48,
                      minWidth: 255,
                      elevation: 0,
                      onPressed: () {
                        showCorrespondingDialog(context, showDialogIndex: 2);
                        print("cleared sessions");
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Theme.of(context).colorScheme.primary,
                      child: const Text(
                        "Reset Sessions",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showCorrespondingDialog(context, showDialogIndex: 3);
                      },
                      child: Text(
                        "Reset Calendar",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlatformAlertDialog extends StatelessWidget {
  const PlatformAlertDialog({
    required this.clearMinutesFunction,
    required this.optionIndex,
    super.key,
  });

  final int optionIndex;
  final VoidCallback clearMinutesFunction;

  static const List<String> textOptions = [
    "streak",
    "minutes",
    "session",
    "calendar",
  ];

  @override
  Widget build(BuildContext context) {
    final clearStreak = StreakDataHandling().clearStreak;

    Future<void> clearMinsMeditated() async {
      clearMinutesFunction();
    }

    const clearSessions = SessionsDataHandling.clearSessions;

    return Platform.isIOS == true
        // todo adjust text fontsize for cupertino alert dialog
        ? CupertinoAlertDialog(
            title: Text("Reset ${textOptions[optionIndex]}"),
            content: Text(
              "Warning: Continuing will reset all ${textOptions[optionIndex]} data. Do you wish to proceed? ",
            ),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: false,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("cancel"),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () async {
                  switch (optionIndex) {
                    case 0:
                      // todo wrap in try catch

                      await clearStreak();
                    case 1:
                      await clearMinsMeditated();
                    case 2:
                      // todo wrap in TRY CATCH
                      await clearSessions();
                    case 3:
                      await Hive.box<History>("HistoryBox").clear();
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("reset"),
              )
            ],
          )
        : AlertDialog(
            title: Text("Reset ${textOptions[optionIndex]}"),
            content: Text(
              "Warning: Continuing will reset all ${textOptions[optionIndex]} data. Do you wish to proceed?",
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "cancel",
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () async {
                  switch (optionIndex) {
                    case 0:
                      // todo wrap in try catch for all
                      await clearStreak();
                      print("cleared streak");
                    case 1:
                      await clearMinsMeditated();
                    case 2:
                      await clearSessions();
                      print("cleared sessions");
                    case 3:
                      await Hive.box<History>("HistoryBox").clear();
                  }
                  Navigator.of(context).pop(); // todo mount with guarded check
                },
                child: Text(
                  "Reset",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error, fontSize: 18),
                ),
              ),
            ],
          );
  }
}

class ColorSelection extends StatefulWidget {
  const ColorSelection({super.key});

  @override
  State<ColorSelection> createState() => _ColorSelectionState();
}

class _ColorSelectionState extends State<ColorSelection> {
  final _colorBox = Hive.box("ColorBox");

  List<Color> colorList = [
    const Color(0xFF9B9B9B),
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    int selectedColorValue =
        Color(_colorBox.get("tertiaryColor", defaultValue: 0xFF9B9B9B)).value;

    int selectedIndex =
        colorList.indexWhere((color) => color.value == selectedColorValue);

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: List.generate(
        9,
        (index) => Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () async {
              print("Selected $index");
              await _colorBox.put(
                  "tertiaryColor",
                  colorList[index]
                      .value); // stores an int value of the color since hive only does native data types
              setState(
                () {
                  selectedIndex = index;
                  print("set selectedIndex to $selectedIndex");
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                  border: selectedIndex == index
                      ? Border.all(
                          color: index != 1
                              ? Colors.white
                              : Colors
                                  .grey, // ternary operator inside ternary operator
                          width: 5,
                          strokeAlign: 0.5)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  color: colorList[index]),
            ),
          ),
        ),
      ),
    );
  }
}

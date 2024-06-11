import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:flutter_focal/history.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class HistoryHeatMapCalendar extends StatefulWidget {
  const HistoryHeatMapCalendar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HistoryHeatMapCalendar();
}

class _HistoryHeatMapCalendar extends State<HistoryHeatMapCalendar> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController heatLevelController = TextEditingController();

  Box historyBox = Hive.box<History>("HistoryBox");
  final _calendarColorBox = Hive.box("ColorBox");

  Map<DateTime, int> heatMapDatasets = {};

  void generateData() {
    print("generateData activated");

    setState(
      () {
        heatMapDatasets = {};
      },
    );

    for (var i = 0; i < historyBox.length; i++) {
      History currentItem = historyBox.getAt(i);
      DateTime blockDate = currentItem.date;
      int blockShade = currentItem.heatMapShadeVal;

      setState(
        () {
          // if calendar contains values that aren't in the box (after deletion) calendar adjusts
          heatMapDatasets[blockDate] = blockShade;
        },
      );
    }
  }

  Color blockColor = Colors.transparent; //set in initState
  Color textColor = const Color.fromARGB(255, 238, 238,
      238); // cannot set this in initState because it is a context dependent value on an inherited widget (Theme)

  void updateBlockColor() {
    setState(() {
      blockColor = Color(
          _calendarColorBox.get("tertiaryColor", defaultValue: 0xFF9B9B9B));
      if (blockColor.value == Colors.white.value ||
          blockColor.value == Colors.yellow.value) {
        textColor = Colors.grey.shade700;
      } else {
        textColor = Theme.of(context).colorScheme.onPrimary;
      }
      print("updated block color");
    });
  }

  @override
  void initState() {
    super.initState();
    blockColor =
        Color(_calendarColorBox.get("tertiaryColor", defaultValue: 0xFF9B9B9B));
    generateData();
    historyBox.watch().listen((event) {
      generateData();
    });
    _calendarColorBox.watch().listen((event) async {
      updateBlockColor();
    });
  }

  @override
  void dispose() {
    dateController.dispose();
    heatLevelController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          // HeatMapCalendar,
          child: HeatMapCalendar(
            onClick: (blockDateTime) {
              print("Pressed $blockDateTime");

              // get entries for specific date
              List<List<String>> dateEntries =
                  []; // each index contains [minutes, seconds] in format usable by text
              List<String> formattedTimeOfEntryList = []; // AM/PM format

              for (var i = 0; i < historyBox.length; i++) {
                History currentItem = historyBox.getAt(i);

                print(blockDateTime);
                print(currentItem.date);
                print(currentItem.heatMapShadeVal);
                print(currentItem.sessionSecsMeditated);

                DateTime blockDate = blockDateTime;
                if (blockDate == currentItem.date) {
                  int currentItemTime =
                      historyBox.keyAt(i); // key is seconds since epoch
                  DateTime dateOfKey = DateTime.fromMillisecondsSinceEpoch(
                      currentItemTime * 1000);
                  DateFormat dateFormat = DateFormat('h:mm a');

                  formattedTimeOfEntryList
                      .add((dateFormat.format(dateOfKey)).toString());

                  dateEntries.add([
                    (currentItem.sessionSecsMeditated ~/ 60).toString(),
                    (currentItem.sessionSecsMeditated % 60).toString(),
                  ]);

                  print(currentItem.sessionSecsMeditated);
                  print(dateEntries[dateEntries.length - 1]);
                }
              }

              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    contentPadding: EdgeInsets.only(top: 12, bottom: 0),
                    title: Text(
                        "Entries ${blockDateTime.month}/${blockDateTime.day}/${blockDateTime.year}"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 315),
                        child: Scrollbar(
                          controller: PrimaryScrollController.of(context),
                          thumbVisibility: true,
                          radius: Radius.circular(50),
                          child: SingleChildScrollView(
                            //controller: PrimaryScrollController.of(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //SizedBox(width: 26),
                                IntrinsicWidth(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...formattedTimeOfEntryList
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        // item == [minutes, seconds] for a single session entry
                                        int index = entry.key;
                                        String timeOfEntry = entry.value;
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Text(timeOfEntry,
                                                  style: TextStyle(
                                                      fontSize: 19,
                                                      letterSpacing:
                                                          0.5) // default padding comes from the scale of fontSize
                                                  ),
                                            ),
                                            if (index !=
                                                formattedTimeOfEntryList
                                                        .length -
                                                    1)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 1),
                                                child: Divider(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  height: 1,
                                                  thickness: 1,
                                                ),
                                              ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),

                                IntrinsicWidth(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...dateEntries
                                          .asMap()
                                          .entries
                                          .map<Widget>((itemEntries) {
                                        // item == [minutes, seconds] for a single session entry
                                        int index = itemEntries.key;
                                        String mins = itemEntries.value[0];
                                        String secs = itemEntries.value[1];
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 25, right: 15), //25
                                              child: Text(
                                                "$mins mins $secs secs",
                                                style: const TextStyle(
                                                    fontSize: 19),
                                              ),
                                            ),
                                            if (index !=
                                                dateEntries.length -
                                                    1) // keep symmetry by not making last divider
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 1),
                                                child: Divider(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  height: 1,
                                                  thickness: 1,
                                                ),
                                              ),
                                          ],
                                        );
                                      })
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            width: 150,
                            height: 45,
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                minimumSize: Size(150, 45),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "OK",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );

              // if there is an entry value in historybox matching blockDateTime
            },
            colorTipCount: 6,
            textColor: textColor,
            monthFontSize: 25,
            showColorTip: false, // will put the color tips in documentation,
            //                      also it will help to make the days tapable to display the minutes on that day
            defaultColor: Colors.transparent,
            borderRadius: 100,
            flexible: true,
            datasets: heatMapDatasets,
            colorMode: ColorMode.color,
            colorsets: {
              1: blockColor.withOpacity(1 / 6),
              2: blockColor.withOpacity(2 / 6),
              3: blockColor.withOpacity(3 / 6),
              4: blockColor.withOpacity(4 / 6),
              5: blockColor.withOpacity(5 / 6),
              6: blockColor.withOpacity(6 / 6),
            },
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';

import 'package:flutter_focal/use_stats.dart';
import 'package:flutter_focal/heatmap_calendar.dart';

class ProfileDisplay extends StatefulWidget {
  const ProfileDisplay({super.key});

  @override
  State<ProfileDisplay> createState() => _ProfileDisplayState();
}

class _ProfileDisplayState extends State<ProfileDisplay> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              borderRadius: BorderRadius.circular(40),
              child: Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 215,
                  width: 335,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(flex: 1),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              alignment: Alignment.center,
                              child: const Icon(
                                  Icons.local_fire_department_outlined,
                                  size: 48),
                            ),
                            const Text(
                              "Streak",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 0.6),
                              child: StreakTextDisplay(),
                            ),
                          ],
                        ),
                        Spacer(flex: 1),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: 55,
                                width: 55,
                                alignment: Alignment.center,
                                child: Icon(Icons.schedule_rounded, size: 44)),
                            const Text(
                              "Minutes",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            const MinutesDataHandlerAndDisplay(),
                          ],
                        ),
                        Spacer(flex: 1),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 55,
                                height: 55,
                                alignment: Alignment.center,
                                child: Icon(Icons.check_rounded, size: 50)),
                            const Text(
                              "Sessions",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            const SessionsTextDisplay(),
                          ],
                        ),
                        Spacer(flex: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            HistoryHeatMapCalendar(),
          ],
        ),
      ),
    );
  }
}

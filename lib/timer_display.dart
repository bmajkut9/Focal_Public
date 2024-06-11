import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_focal/timer_selection.dart';
import 'package:flutter_focal/app_bar.dart';
import 'package:flutter_focal/audioplayer.dart';
import 'package:flutter_focal/active_timer.dart';
import 'package:flutter_focal/onboarding.dart';

GlobalKey<TimerDisplayState> timerDisplayStateKey =
    GlobalKey<TimerDisplayState>();

class TimerDisplay extends StatefulWidget {
  const TimerDisplay({super.key});

  @override
  State<StatefulWidget> createState() => TimerDisplayState();
}

class TimerDisplayState extends State<TimerDisplay> {
  //will eventually be the length of the session the user sets
  Duration countdownDuration =
      Duration(); // note: this value is used as parameter in streakdata
  //initializes duration for duration.inMinutes and duration.inSeconds
  Duration duration = Duration();
  Duration countdownInterval = Duration();
  Duration interval = Duration();
  Timer? timer;

  bool isCountdown = true; // will set this to an icon button in an update
  var showOpeningDialogBox = Hive.box("ShowOpeningDialogBox");

  @override
  void initState() {
    super.initState();
    //reset();
    print("timer display state created at ${this.hashCode}");
    ImageCache imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = 100;
    imageCache.maximumSizeBytes = 1000 << 20;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        precacheImage(const AssetImage("assets/images/0.jpg"), context);
        precacheImage(const AssetImage("assets/images/3.jpg"), context);
        precacheImage(const AssetImage("assets/images/4.jpg"), context);
        precacheImage(const AssetImage("assets/images/5.jpg"), context);
        precacheImage(const AssetImage("assets/images/1.jpg"), context);
        precacheImage(const AssetImage("assets/images/2.jpg"), context);

        if (showOpeningDialogBox.get("showOnboarding", defaultValue: true) ==
            true) {
          showDialog(
            context: context,
            builder: (context) {
              return const OnboardingDialog();
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    playerInstance.dispose(); // remove audio player instances
  }

  late VoidCallback passedCallback;
  void registerCallback(callbackFromUseStats) {
    passedCallback = callbackFromUseStats;
    print("Callback registered in instance: ${this.hashCode}");
  }

  int selectedIndexRow1 = -1;
  int selectedIndexRow2 = -1;
  String selectorValue = "Duration"; // for animatedtoggleswitch default value

  final playerInstance = AudioPlayerHandler();

  @override
  Widget build(BuildContext context) {
    const List<String> backgroundMusicAssets = [
      'assets/sounds/beach_sound.mp3',
      'assets/sounds/jungle_sound.mp3',
      'assets/sounds/synth_sound.mp3',
    ];

    const List<String> selectedBackgroundMusicName = [
      'beach_sound',
      'jungle_sound',
      'synth_sound',
    ];

    const List<String> soundEffectAssets = [
      'assets/sounds/bell_chime.mp3',
      'assets/sounds/windchimes_chime.mp3',
      'assets/sounds/chirp_chime.mp3',
    ];

    const List<String> selectedSoundName = [
      'bell_chime',
      "windchimes",
      "chirp_chime"
    ];

    return Expanded(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                buildCustomMinutesSelector(),
                buildCustomSecondsSelector(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildDuration(),
                    buildInterval(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            ClipRRect(
              child: AnimatedToggleSwitch.size(
                // may build AnimatedToggleSwitch.dual for next update
                current: selectorValue,
                values: const ["Duration", "Interval"],
                iconBuilder: (value) {
                  // value is of type "Object"
                  print("value is $value");
                  return Text(
                    value,
                    style: TextStyle(
                        letterSpacing: -0.25,
                        color: value == "Interval" ? Colors.grey[500] : null),
                  );
                },
                borderWidth: 5,
                iconOpacity: 1,
                indicatorSize: Size.fromWidth(120),
                style: ToggleStyle(
                  borderColor: Theme.of(context).colorScheme.primary,
                  indicatorColor: Colors.grey[600],
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onChanged: (i) {
                  setState(
                    () {
                      selectorValue = i;
                      setSecondsInitialValue = 0;
                      setMinutesInitialValue = 0;
                      print("changed value to $selectorValue");
                      selectorValue == "Duration"
                          ? sliderSelectDuration = true
                          : sliderSelectDuration = false;
                      print(
                          "Set sliderSelectDuration to $sliderSelectDuration");
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text("Signal Chime",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    maintainState: true,
                    tilePadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    leading: Icon(
                      Icons.notifications_outlined,
                      size: 26,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 24),
                    iconColor: Theme.of(context).colorScheme.onPrimary,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) {
                            return SelectableContainer(
                              assetPath: "assets/images/$index.jpg",
                              isSelected: selectedIndexRow1 == index,
                              onSelect: () async {
                                setState(
                                  () {
                                    if (selectedIndexRow1 == index) {
                                      selectedIndexRow1 = -1;
                                    } else {
                                      selectedIndexRow1 = index;
                                    }
                                  },
                                );
                                selectedIndexRow1 == -1
                                    ? await playerInstance.stopSound()
                                    : await playerInstance.playSoundEffect(
                                        asset: soundEffectAssets[index],
                                        selectedSound: selectedSoundName[index],
                                        isSample: true,
                                      );
                                print("got await");
                                print(
                                    "Selected Index (Row 1): $selectedIndexRow1");
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.background,
              height: 1.5,
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              child: Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text("Soundscape",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    maintainState: true,
                    tilePadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    leading: Icon(
                      Icons.my_library_music_outlined,
                      size: 26,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 24),
                    iconColor: Theme.of(context).colorScheme.onPrimary,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) {
                            return SelectableContainer(
                              assetPath: "assets/images/${index + 3}.jpg",
                              isSelected: selectedIndexRow2 == index,
                              onSelect: () async {
                                setState(
                                  () {
                                    if (selectedIndexRow2 == index) {
                                      selectedIndexRow2 = -1;
                                    } else {
                                      selectedIndexRow2 = index;
                                    }
                                    print(
                                        "Selected Index (Row 2): $selectedIndexRow2");
                                  },
                                );
                                selectedIndexRow2 == -1
                                    ? await playerInstance.stopBackground()
                                    : await playerInstance.playBackgroundMusic(
                                        asset: backgroundMusicAssets[index],
                                        selectedSound:
                                            selectedBackgroundMusicName[index],
                                        isSample: true,
                                      );
                                print("finished await back");
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary),
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () async {
                      await playerInstance.stopBackground();
                      await playerInstance.stopSound();

                      if (duration > interval) {
                        // accounts for case where duration is unset
                        // interval cannot be more than duration
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActiveTimer(
                              minutesMeditatedCallback: passedCallback,
                              setDuration: duration,
                              setInterval: interval,
                              playBackground:
                                  selectedIndexRow2 > -1 ? true : false,
                              playSound: selectedIndexRow1 > -1 ? true : false,
                              playInterval: interval > Duration(seconds: 0) &&
                                      selectedIndexRow1 > -1
                                  ? true
                                  : false,
                            ),
                          ),
                        );
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: TextButton(
                                child: Text(
                                  duration == const Duration(seconds: 0)
                                      ? "Must set a duration\nTap text for help"
                                      : "Interval must be less than duration\nTap text for help",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HelpPage(),
                                    ),
                                  );
                                }),
                            closeIconColor: Colors.black,
                            duration: const Duration(seconds: 3),
                            showCloseIcon: true,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                          ));
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      size: 65,
                    ),
                  ),
                ),
                const Text("Start"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // adjusted by custom slider, used as global values for timer mins & secs
  int sliderSetDurationMins = 0;
  int sliderSetDurationSecs = 0;

  int sliderSetIntervalMins = 0;
  int sliderSetIntervalSecs = 0;

  Widget select() {
    return CupertinoTimerPicker(
      mode: CupertinoTimerPickerMode.ms,
      initialTimerDuration: selectorValue == "Duration"
          ? Duration(
              minutes: sliderSetDurationMins, seconds: sliderSetDurationSecs)
          : Duration(
              minutes: sliderSetIntervalMins, seconds: sliderSetIntervalSecs),
      backgroundColor: Theme.of(context).colorScheme.background,
      onTimerDurationChanged: (selectedTime) {
        setState(
          () {
            if (selectorValue == "Duration") {
              // "Duration" is selected
              sliderSetDurationMins = selectedTime.inMinutes.toInt();
              sliderSetDurationSecs = selectedTime.inSeconds.toInt() % 60;
              countdownDuration = selectedTime;
              duration = countdownDuration;
            } else {
              // "Interval" is selected
              sliderSetIntervalMins = selectedTime.inMinutes.toInt();
              sliderSetIntervalSecs = selectedTime.inSeconds.toInt() % 60;
              countdownInterval = selectedTime;
              interval = countdownInterval;
            }
          },
        );
      },
    );
  }

  Widget buildDuration() {
    //creates parameter c that allows duration to be convered to string in final minutes and seconds
    String twoDigits(int c) => c.toString().padLeft(2, "0");
    String oneDigit(int d) => d.toString().padLeft(1, "0");
    //duration is updated in "addTime" function
    //remainder is used so that when hitting 60 the timer resets again to 00
    final minutes = oneDigit(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            backgroundColor: Theme.of(context).colorScheme.background,
            context: context,
            builder: (BuildContext builder) {
              return select();
            });
      },
      child: SizedBox(
        child: Text(
          '$minutes:$seconds',
          style: TextStyle(
            height: 1.1,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget buildInterval() {
    //creates parameter c that allows duration to be convered to string in final minutes and seconds
    String oneDigit(int c) => c.toString().padLeft(1, "0");
    String twoDigits(int d) => d.toString().padLeft(2, "0");
    //duration is updated in "addTime" method
    //remainder is used so that when hitting 60 the timer resets again to 00
    final intervalMinutes = oneDigit(interval.inMinutes.remainder(60));
    final intervalSeconds = twoDigits(interval.inSeconds.remainder(60));

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            backgroundColor: Theme.of(context).colorScheme.background,
            context: context,
            builder: (BuildContext builder) {
              return select();
            });
      },
      child: SizedBox(
        child: Text(
          '$intervalMinutes:$intervalSeconds',
          style: const TextStyle(
            height: 1.1,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9B9B9B),
          ),
        ),
      ),
    );
  }

  bool sliderSelectDuration = true;
  double setSecondsInitialValue = 0;
  double setMinutesInitialValue = 0;

  Widget buildCustomMinutesSelector() {
    return SleekCircularSlider(
      innerWidget: (percentage) => Container(color: Colors.transparent),
      appearance: CircularSliderAppearance(
        animationEnabled: true,
        size: 315,
        customWidths: CustomSliderWidths(
          shadowWidth: 0,
          trackWidth: 20,
          handlerSize: 0,
          progressBarWidth: 18,
        ),
        angleRange: 360,
        startAngle: 270,
        customColors: CustomSliderColors(
          shadowColor: Colors.transparent,
          dynamicGradient: false,
          trackColor: Theme.of(context).colorScheme.primary,
          progressBarColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      min: 0.00,
      max: 1,
      initialValue: setMinutesInitialValue,
      onChange: (value) {
        if (sliderSelectDuration == true) {
          Duration selectedCountdownDuration = Duration(
              minutes: (value * 60).toInt(), seconds: sliderSetDurationSecs);
          setState(
            () {
              setMinutesInitialValue = value;
              countdownDuration = selectedCountdownDuration;
              sliderSetDurationMins = (value * 60).toInt();
              print("sliderSetDurationMins = $sliderSetDurationMins");
              duration = countdownDuration;
            },
          );
        } else {
          Duration selectedCountdownInterval = Duration(
              minutes: (value * 60).toInt(), seconds: sliderSetIntervalSecs);
          setState(
            () {
              setMinutesInitialValue = value;
              countdownInterval = selectedCountdownInterval;
              sliderSetIntervalMins = (value * 60).toInt();
              print("sliderSetInvervalMins = $sliderSetIntervalMins");
              interval = countdownInterval;
            },
          );
        }
      },
    );
  }

  Widget buildCustomSecondsSelector() {
    return SleekCircularSlider(
      innerWidget: (percentage) => Container(
        color: Colors.transparent,
      ),
      appearance: CircularSliderAppearance(
        animationEnabled: true,
        size: 250,
        customWidths: CustomSliderWidths(
          shadowWidth: 0,
          trackWidth: 4.5,
          handlerSize: 0,
          progressBarWidth: 4.5,
        ),
        angleRange: 360,
        startAngle: 270,
        customColors: CustomSliderColors(
          shadowColor: Colors.transparent,
          dynamicGradient: false,
          trackColor: Theme.of(context).colorScheme.primary,
          progressBarColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      min: 0.00,
      max: 1,
      initialValue: setSecondsInitialValue,
      onChange: (value) {
        if (sliderSelectDuration == true) {
          Duration selectedCountdownDuration = Duration(
              minutes: sliderSetDurationMins, seconds: (value * 60).toInt());
          setState(
            () {
              setSecondsInitialValue = value;
              countdownDuration = selectedCountdownDuration;
              sliderSetDurationSecs = (value * 60).toInt();
              print("sliderSetDurationSecs = $sliderSetDurationSecs");
              duration = countdownDuration;
            },
          );
        } else {
          Duration selectedCountdownInterval = Duration(
              minutes: sliderSetIntervalMins, seconds: (value * 60).toInt());
          setState(
            () {
              setSecondsInitialValue = value;
              countdownInterval = selectedCountdownInterval;
              sliderSetIntervalSecs = (value * 60).toInt();
              interval = countdownInterval;
              print("sliderSetIntervalSecs = $sliderSetIntervalSecs");
            },
          );
        }
      },
    );
  }
}

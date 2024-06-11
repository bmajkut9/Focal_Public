import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:interactive_slider/interactive_slider.dart';

import 'package:flutter_focal/use_stats.dart';
import 'package:flutter_focal/audioplayer.dart';
import 'package:just_audio/just_audio.dart';

final instancePlayer = AudioPlayerHandler();

class ActiveTimer extends StatefulWidget {
  final VoidCallback minutesMeditatedCallback;
  final bool playBackground;
  final bool playSound;
  final bool playInterval;
  final Duration setDuration;
  final Duration setInterval;

  const ActiveTimer(
      {required this.minutesMeditatedCallback,
      required this.playBackground,
      required this.playSound,
      required this.playInterval,
      required this.setDuration,
      required this.setInterval,
      super.key});

  @override
  State<ActiveTimer> createState() => ActiveTimerState();
}

class ActiveTimerState extends State<ActiveTimer>
    with TickerProviderStateMixin {
  // the duration and interval values are incremented in addTime() and are displayed in text on the timer
  Duration duration = const Duration();
  Duration interval = const Duration();

  // the countdown duration and countdown interval values are the total selected length, so they are used for reset() and calculating elapsed time
  Duration countdownDuration =
      const Duration(); // note: this value is used as parameter in streakdata
  Duration countdownInterval = const Duration();

  Timer? timer;

  bool isCountdown = true;
  late AnimationController _durationController;
  late AnimationController _intervalController;

  @override
  void initState() {
    super.initState();

    //playBackgroundInit();

    countdownDuration = widget.setDuration;
    duration = widget.setDuration;
    // interval will be passed regardless of it's length, so only use it if the user set one
    // the user may want to set an interval at the very beginning without thinking of setting it to 1 second, but I do not think this will be a problem
    if (widget.setInterval > const Duration(seconds: 0)) {
      countdownInterval = widget.setInterval;
      interval = widget.setInterval;
    }

    _durationController = AnimationController(vsync: this, duration: duration);
    _intervalController = AnimationController(vsync: this, duration: interval);

    startTimer();

    _durationController.forward(from: _durationController.value);
    _intervalController.forward(from: _intervalController.value);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void reset() {
    if (isCountdown) {
      instancePlayer.stopSound();
      instancePlayer.stopBackground();

      _durationController.reset();
      _intervalController.reset();

      setState(
        () {
          duration = countdownDuration;
          interval = countdownInterval;
        },
      );
    } else {
      setState(
        () {
          duration = const Duration();
          interval = const Duration();
        },
      );
    }
  }

  int elapsedDurationSeconds = 0;
  int elapsedIntervalSeconds = 0;

  void callbackActivate() {
    final VoidCallback _callback = widget.minutesMeditatedCallback;
    _callback();
  }

  //incremements the countdown and stops the timer, as well as timer/hive communication
  void addTime() {
    final secondsIncrement = isCountdown ? -1 : 1;

    //could use a second box and add elapsedTime to total time for each increment
    //await timeBox.put("Time", elapsedTimeSeconds);

    callbackActivate(); // ? minutes stat callback??
    print("tried to activate callback in instance ${this.hashCode}");

    setState(
      () {
        //handles minutes meditated stat with Hive
        elapsedDurationSeconds =
            countdownDuration.inSeconds - duration.inSeconds;
        elapsedIntervalSeconds =
            countdownInterval.inSeconds - interval.inSeconds;
        print("Elapsed Duration Seconds $elapsedDurationSeconds");
        print("Elapsed Interval Seconds $elapsedIntervalSeconds");

        final durationSecondsLeft = duration.inSeconds + secondsIncrement;
        final intervalSecondsLeft = interval.inSeconds + secondsIncrement;

        print("SecondsLeft = $durationSecondsLeft");
        print("Interval seconds left = $intervalSecondsLeft");

        if (durationSecondsLeft == 0) {
          duration = Duration(seconds: durationSecondsLeft);
          print("FINISHED DURATION");
          timer?.cancel();
          if (widget.playSound) {
          instancePlayer.playActiveSound();

          }
          print("played ending chime");

          SessionsDataHandling.writeSessionData(countdownDuration
              .inSeconds); // total time in the session is used for heat map shading
          StreakDataHandling.writeStreakData();

          // todo open completed
          showCompletedDialog(context);
        } else if (durationSecondsLeft > 0) {
          //updates the duration
          //the timer keeps track of everything in seconds
          duration = Duration(seconds: durationSecondsLeft);
        }

        if (intervalSecondsLeft == 0 &&
            widget.setInterval > const Duration(seconds: 0)) {
          interval = Duration(seconds: intervalSecondsLeft);
          print("FINISHED INTERVAL");
          instancePlayer.playActiveIntervalSound();
        } else if (intervalSecondsLeft > 0) {
          interval = Duration(seconds: intervalSecondsLeft);
        }
      },
    );
  }

  Future<void> startTimer({bool pause = false}) async {
    if (timer != null) timer!.cancel(); // cancel previous timer instance

    if (pause) {
      pauseTimer();
    } else {
      _durationController.forward(from: _durationController.value);
      _intervalController.forward(from: _intervalController.value);
      //makes the timer values change every 1 seconds
      
      if(widget.playBackground == true && !instancePlayer.backgroundMusicPlayer.playing) {
        instancePlayer.playBackground(); // adding await breaks playing
      }
      // check if there is a signal chime for duration or interval, resume it if it is paused
      if ((widget.playSound || widget.playInterval) && !instancePlayer.soundEffectsPlayer.playing && instancePlayer.soundEffectsPlayer.processingState == ProcessingState.ready) {
        instancePlayer.playSound(); // adding await breaks playing
      }

      timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => addTime(),
      );

      setState(() {}); // makes sure play button immediatly switches to pause
    }

    return Future.value();
  }

  Future<void> pauseTimer() {
    if (instancePlayer.backgroundMusicPlayer.playing) {
      instancePlayer.pauseBackground(); // await doesn't work
    }

    if (instancePlayer.soundEffectsPlayer.playing) {
      instancePlayer.pauseSound(); // await doesn't work
    }

    _durationController.stop();
    _intervalController.stop();
    setState(() => timer?.cancel());
    return Future.value();
  }

  double calculateDurationProgress() {
    final totalSeconds = countdownDuration.inSeconds.toDouble();
    final progressSecondsLeft = duration.inSeconds.toDouble();

    // Avoid division by zero and ensure the value is within range
    if (totalSeconds == 0 || progressSecondsLeft > totalSeconds) {
      //int returns error for calculate progress
      return 0.0;
    }
    print("progressSecondsLeft = $progressSecondsLeft");
    print("totalSeconds = $totalSeconds");
    print(
        "Calculate duration progress is ${1.0 - (progressSecondsLeft / totalSeconds)}");
    return 1.0 - (progressSecondsLeft / totalSeconds);
  }

  double calculateIntervalProgress() {
    final totalIntervalSeconds = countdownInterval.inSeconds.toDouble();
    final progressIntervalSecondsLeft = interval.inSeconds.toDouble();

    // Avoid division by zero and ensure the value is within range
    if (totalIntervalSeconds == 0 ||
        progressIntervalSecondsLeft > totalIntervalSeconds) {
      //int returns error for calculate progress
      return 0.0;
    }
    print("progressIntervalSecondsLeft = $progressIntervalSecondsLeft");
    print("totalIntervalSeconds = $totalIntervalSeconds");
    print(
        "Calculate interval progress is ${1.0 - (progressIntervalSecondsLeft / totalIntervalSeconds)}");
    return 1.0 - (progressIntervalSecondsLeft / totalIntervalSeconds);
  }

  Widget buildDurationProgressIndicator({required value}) {
    return SizedBox(
      width: 315,
      height: 315,
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.onPrimary,
        value: value, // calculateDurationProgress,
        strokeWidth: 20,
        strokeAlign: -1,
        strokeCap: StrokeCap.round,
      ),
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

    return SizedBox(
      child: Text(
        '$minutes:$seconds',
        style: TextStyle(
          height: 1.1,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget buildIntervalProgressIndicator({required value}) {
    return SizedBox(
      width: 250,
      height: 250,
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.onPrimary,
        value: value, //calculateIntervalProgress(),
        strokeWidth: 4.5,
        strokeAlign: -1,
        strokeCap: StrokeCap.round,
      ),
    );
  }

  Widget buildButtons() {
    final isRunning = timer == null ? false : timer!.isActive;
    final soundRunning = (instancePlayer.backgroundMusicPlayer.playing || instancePlayer.soundEffectsPlayer.playing) ? true : false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //reset
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle),
          height: 80,
          width: 80,
          child: IconButton(
            style: ButtonStyle(splashFactory: NoSplash.splashFactory),
            alignment: Alignment.center,
            iconSize: 50,
            onPressed: () {
              reset();
              timer?.cancel();
            },
            icon: Icon(
              Icons.restart_alt_rounded,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ),
        Container(
          width: 40,
        ),
        // play and pause
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle),
          height: 80,
          width: 80,
          child: IconButton(
            style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
            ),
            alignment: Alignment.center,
            iconSize: 60,
            onPressed: () async {
              if (isRunning) {
                await startTimer(pause: true); // pause: true makes it reset
              } else {
                await startTimer(pause: false);
              }
            },
            icon: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Icon(
                isRunning || soundRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
        ),
      ],
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

    return SizedBox(
      child: Text(
        '$intervalMinutes:$intervalSeconds',
        style: TextStyle(
            height: 1.1,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9B9B9B)),
      ),
    );
  }

  void showCompletedDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            contentPadding:
                EdgeInsets.only(left: 35, right: 35, bottom: 20, top: 15),
            alignment: Alignment.center,
            //title:
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Session Completed",
                    style: TextStyle(fontSize: 24),
                  )),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                    width: 6.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: TextButton(
                    onPressed: () {
                      instancePlayer.stopBackground();
                      instancePlayer.stopSound();
                      Navigator.pop(context);
                      Navigator.pop(
                          context); // pop twice to get back to timer_display
                    },
                    child: Text(
                      "Finished",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.tertiary),
                    )),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leadingWidth: 100,
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: CustomPopupMenu(
            pressType: PressType.singleClick,
            child: Icon(
              Icons.tune_rounded,
              size: 36,
            ),
            menuBuilder: () => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 300,
                color: Theme.of(context).colorScheme.primary,
                child: CustomVolumeController(),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            //color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: IconButton(
                alignment: Alignment.center,
                // close button
                onPressed: () {
                  instancePlayer.stopBackground();
                  instancePlayer.stopSound();
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close_rounded,
                  size: 40,
                ),
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _durationController,
                  builder: (context, child) {
                    return buildDurationProgressIndicator(
                        value: _durationController.value);
                  },
                ),
                Visibility(
                  visible: countdownInterval > Duration.zero,
                  child: AnimatedBuilder(
                    animation: _intervalController,
                    builder: (context, child) {
                      return buildIntervalProgressIndicator(
                          value: _intervalController.value);
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildDuration(),
                    interval > Duration(seconds: 1)
                        ? buildInterval()
                        : SizedBox(),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4),
            const Spacer(),
            buildButtons(),
            SizedBox(height: 16)
          ],
        ),
      ),
    );
  }
}

class CustomVolumeController extends StatefulWidget {
  const CustomVolumeController({super.key});

  @override
  State<CustomVolumeController> createState() => _CustomVolumeControllerState();
}

class _CustomVolumeControllerState extends State<CustomVolumeController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 15),
        Text("Signal Chime"),
        InteractiveSlider(
          min: 0,
          max: 1,
          initialProgress: instancePlayer.soundEffectsPlayer.volume,
          onChanged: (double volume) =>
              instancePlayer.adjustSoundEffectsVolume(volume),
          startIcon: Icon(Icons.volume_down_rounded),
          endIcon: Icon(Icons.volume_up_rounded),
        ),
        Text("Soundscape"),
        InteractiveSlider(
          min: 0,
          max: 1,
          initialProgress: instancePlayer.backgroundMusicPlayer.volume,
          onChanged: (double volume) =>
              instancePlayer.adjustBackgroundVolume(volume),
          //onProgressUpdated:
          startIcon: Icon(Icons.volume_down_rounded),
          endIcon: Icon(Icons.volume_up_rounded),
        ),
      ],
    );
  }
}

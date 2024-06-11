import 'package:flutter/material.dart';

import 'package:flutter_focal/settings_display.dart';

class AppBarClass extends StatefulWidget implements PreferredSizeWidget {
  final int currentAppBarIndex;

  const AppBarClass({Key? key, required this.currentAppBarIndex})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  State<AppBarClass> createState() => _AppBarClassState();
}

class _AppBarClassState extends State<AppBarClass> {
  final List<String> titleText = [
    "",
    "Profile",
    "Settings",
    "Help"
  ]; // "" is here for active_timer

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      title: Text(titleText[widget.currentAppBarIndex]),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 29,
        fontWeight: FontWeight.w400,
      ),
      centerTitle: true,
      leading: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Container(
            alignment: Alignment.center,
            child: widget.currentAppBarIndex ==
                    1 // if we are at home page we display settings, if not we have a back button
                ? IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsDisplay()));
                    },
                    icon: Container(
                      child: Icon(
                        Icons.settings,
                        size: 30,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
          ),
        ),
      ),
      actions: widget.currentAppBarIndex != 1
          ? null
          : [
              // displays help action when on profile, convert to list format if there are more actions later
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HelpPage()));
                      },
                      icon: Icon(
                        Icons.help_rounded,
                        size: 28,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                ),
              ),
            ],
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarClass(currentAppBarIndex: 3),
      body: Scrollbar(
        controller: PrimaryScrollController.of(context),
        radius: const Radius.circular(50),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: RichText(
                  text: const TextSpan(
                    // default text
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    children: [
                      /*TextSpan( // todo firstOpenFlag and display dialog of this "If you want to learn more about all of the different features Focal offers, simply tap the (i icon) in Profile"
                    text: "Welcome to Focal",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: "\nOur sleek and innovative focus timer \nTo get started..."),*/

                      TextSpan(
                        text: "Contents\n",
                        style: TextStyle(fontSize: 22),
                      ),
                      WidgetSpan(
                        // widgetspan for padding
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Text(
                            "1. Making a session \n2. Active sessions \n3. Stats tracker \n4. Habit calendar \n5. Contact us!",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      TextSpan(
                        text: "\n\n\n1. Making a session",
                        style: TextStyle(fontSize: 20),
                      ),
                      TextSpan(
                        text:
                            "\n\nSet duration and interval: You can customize the length of a session (duration) and add one time inside of the duration that can play a signal chime (interval). The duration time is displayed in the large white text, while the interval time is displayed below it in the small gray text. Select whether to customize the duration or interval by selecting it in the switch below the thick and thin circles, and then set a time for it by moving the thick slider (minutes) and thin slider (seconds). Time can also be set by tapping the time text, which will open a menu with minutes and seconds",
                      ),
                      TextSpan(
                        text:
                            "\n\nSet sounds: The signal chime plays once the timer reaches the duration and interval limits. Set a signal chime by tapping “Signal Chime”, which will open a menu of different sounds. Tap each one to get a 5 second preview, keep it selected to have it in your session, and unselect it to remove it. The same goes for the soundscape, which plays as background noise throughout the whole session. Once you have customized the session to your liking, press the play button labeled “start” at the bottom to begin the session",
                      ),
                      TextSpan(
                        text: "\n\n\n2. Active Sessions",
                        style: TextStyle(fontSize: 20),
                      ),
                      TextSpan(
                        text:
                            "\n\nSet active session volume: Tapping the customization icon at the top left of an active session opens a menu with the current signal chime and soundscape volume. At max the sound volume will be your current phone volume, and at min then will be mute",
                      ),
                      TextSpan(
                        text:
                            "\n\nReset, play, pause, and leave a session: Pressing the reset icon at the bottom will set the interval and duration value back to its original setting. To the right of reset, press pause on a running session to temporarily stop it, and resume it with play. Once you are done, leave the session by pressing the X at the top right of the screen. Or, wait until the timer duration finishes and press “Finished”",
                      ),
                      TextSpan(
                        text: "\n\n\n3. Stats tracker",
                        style: TextStyle(fontSize: 20),
                      ),
                      TextSpan(
                        text:
                            "\n\nUnderstanding stats: The stats tracker shows a streak, minutes, and sessions value. The streak is how many consecutive days you have completed a session. The streak counts on a once per day basis and resets back to zero once the next day has passed with no completed sessions. “Minutes” counts your total minutes meditated. It goes up by one for each 60 seconds in the active timer. It will remember any additional seconds, so two 30 second sessions will add one to “Minutes”. “Sessions” counts how many times you have entered into an active session",
                      ),
                      TextSpan(
                        text:
                            "\n\nReset stats: To reset a certain stat, go to profile and press the gear icon at the top left. This will take you into settings. At the bottom you will see “Reset History” press the button that corresponds to the stat you want to reset. A warning message will pop up. Press “Reset” to clear all data for that stat and the corresponding value in the stat display to be set to 0",
                      ),
                      TextSpan(
                        text: "\n\n\n4. Habit calendar",
                        style: TextStyle(fontSize: 20),
                      ),
                      TextSpan(
                        text:
                            "\n\nUnderstanding habit calendar: The habit calendar keeps track of your sessions and time meditated on a given day. The shade on the current day will get more defined as you meditate for more time or more sessions. There are 5 shades, which will go up either for every 5 minutes meditated or for every session on that day. The max shade is unlocked either for meditating for 30 minutes or for meditating for 5 sessions on a single day",
                      ),
                      TextSpan(
                        text:
                            "\n\nAccessing history: After a session, whether the full length was reached or not, it will show up on the habit calendar. Tap the shaded day to open that day’s history entries. The date will be displayed at the top, the time of the entry will be on the left, and the length of the session will be at the right. Press the “OK” button at the bottom to exit",
                      ),
                      TextSpan(
                        text:
                            "\n\nCustomizing habit calendar shade color: You can customize the calendar color’s shade by going to settings (the gear on the top left of profile) and selecting your preferred color in the “Calendar Color” menu",
                      ),
                      TextSpan(
                        text: "\n\n\n5. Contact us",
                        style: TextStyle(fontSize: 20),
                      ),
                      TextSpan(
                        text:
                            "\n\nThank you for using Focal! Send any feedback or questions to bmajkut9@gmail.com",
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

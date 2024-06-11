import 'package:flutter/material.dart';
import 'package:flutter_focal/app_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnboardingDialog extends StatelessWidget {
  const OnboardingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingBox = Hive.box("ShowOpeningDialogBox");

    return SimpleDialog(
      contentPadding:
          const EdgeInsets.only(top: 12, bottom: 12, left: 15, right: 15),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 320,
          ),
          child: Scrollbar(
            controller: PrimaryScrollController.of(context),
            radius: const Radius.circular(50),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      // default text
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      children: [
                        const TextSpan(
                          text: "Welcome to Focal!",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: "\n\nGet Started",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(
                          text:
                              "\nTo make a session, set your desired length and sounds, then press play and enjoy your session!",
                        ),
                        const TextSpan(
                          text: "\n\nLearn More",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(
                          text:
                              "\nIf you want to learn to meditate, or wish to learn about all of Focal's features, tap ",
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          baseline: TextBaseline.alphabetic,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HelpPage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, // Remove padding
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize
                                  .shrinkWrap, // Minimize tap target size // Remove minimum size constraints
                            ),
                            child: const Text(
                              'here',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                            text:
                                ".  Or, go to the help screen by going to Profile and tapping the i icon on the top right"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 1),
            MaterialButton(
              onPressed: () {
                onboardingBox.put("showOnboarding", false);
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: const Text(
                "Don't show again",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(flex: 1),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              color: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                "OK",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(flex: 1),
          ],
        )
      ],
    );
  }
}

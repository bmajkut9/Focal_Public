import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class TimerSelector extends StatefulWidget {
  const TimerSelector({super.key});

  @override
  TimerSelectorState createState() => TimerSelectorState();
}

class TimerSelectorState extends State<TimerSelector> {
  int selectedIndexRow1 = -1;
  int selectedIndexRow2 = -1;

  String? selectedAudioPath;

  @override
  Widget build(BuildContext context) {
    return buildTimerSelection();
  }

  void openSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: const Text(
                      "Session",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 30, top: 20, bottom: 6),
                          child: Text(
                            "End Chime",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) {
                              return SelectableContainer(
                                assetPath: "assets/images/$index.jpg",
                                isSelected: selectedIndexRow1 == index,
                                onSelect: () {
                                  setState(() {
                                    if (selectedIndexRow1 == index) {
                                      selectedIndexRow1 = -1;
                                      selectedAudioPath = null;
                                    } else {
                                      selectedIndexRow1 = index;
                                      selectedAudioPath =
                                          "assets/sounds/jungle_sound.mp3";
                                    }
                                    print(
                                        "Selected Index (Row 1): $selectedIndexRow1");

                                    /*print("Tapped:" + index.toString());
                                      onSelectedContainer(index);*/
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 30, top: 20, bottom: 6),
                          child: Text(
                            "Soundscapes",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) {
                              return SelectableContainer(
                                assetPath: "assets/images/${index + 3}.jpg",
                                isSelected: selectedIndexRow2 == index,
                                onSelect: () {
                                  setState(() {
                                    if (selectedIndexRow2 == index) {
                                      selectedIndexRow2 = -1;
                                    } else {
                                      selectedIndexRow2 = index;
                                    }
                                    print(
                                        "Selected Index (Row 2): $selectedIndexRow2");
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ]),
                ]);
          });
        });
  }

  Widget buildTimerSelection() {
    return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue[400],
            gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue.shade200])),
        alignment: Alignment.center,
        child: IconButton(
          onPressed: openSheet,
          icon: Icon(
            Icons.multitrack_audio_rounded,
            color: Colors.white,
            size: 40,
          ),
          //IconButton(
          //icon: Icons.expand_more_rounded,
          //onPressed: () =>
        ));
  }
}

class SelectableContainer extends StatefulWidget {
  final String assetPath;
  final bool isSelected;
  final VoidCallback onSelect;

  const SelectableContainer(
      {required this.assetPath,
      required this.isSelected,
      required this.onSelect,
      super.key});

  @override
  _SelectableContainerState createState() => _SelectableContainerState();
}

class _SelectableContainerState extends State<SelectableContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelect,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SleekCircularSlider(
            appearance: CircularSliderAppearance(
                spinnerMode: true,
                size: 40,
                customColors: CustomSliderColors(
                  shadowColor: Colors.transparent,
                  dotColor: Colors.transparent,
                  dynamicGradient: false,
                  trackColor: Colors.transparent,
                  progressBarColor: Theme.of(context).colorScheme.onPrimary,
                )),
          ),
          Container(
            width: 80,
            height: 80,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage(widget.assetPath),
                fit: BoxFit.cover,
              ),
            ),
            child: widget.isSelected ? null : _buildDimOverlay(),
          ),
        ],
      ),
    );
  }

  Widget _buildDimOverlay() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.65),
      ),
    );
  }
}

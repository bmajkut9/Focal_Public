import 'package:just_audio/just_audio.dart';
import 'dart:async';

class AudioPlayerHandler {
  // singleton pattern, consider InheritedWidget or global key  in the future
  AudioPlayerHandler._privateConstructor();

  static final AudioPlayerHandler _instance =
      AudioPlayerHandler._privateConstructor();

  factory AudioPlayerHandler() {
    return _instance;
  }

  // cleanup method
  void dispose() {
    backgroundMusicPlayer.dispose();
    soundEffectsPlayer.dispose();
  }

  final AudioPlayer backgroundMusicPlayer = AudioPlayer();
  final AudioPlayer soundEffectsPlayer = AudioPlayer();

  // Method to play background music
  Future<void> playBackgroundMusic(
      {required String asset,
      required String selectedSound,
      required bool isSample}) async {
    await stopBackground();

    backgroundMusicPlayer.setAsset(asset);

    await backgroundMusicPlayer.setLoopMode(LoopMode.off);
    // menu timer playing
    switch (selectedSound) {
      // for when selecting an audio source in the selection menu
      case "beach_sound":
        await backgroundMusicPlayer.setClip(
            start: Duration(seconds: 3), end: Duration(seconds: 8));
      case "jungle_sound":
        await backgroundMusicPlayer.setClip(
            start: Duration(seconds: 10), end: Duration(seconds: 15));
      case "synth_sound":
        await backgroundMusicPlayer.setClip(
            start: Duration(seconds: 0), end: Duration(seconds: 5));
    }

    playBackground();
  }

  // Method to play a sound effect
  Future<void> playSoundEffect(
      {required String asset,
      required String selectedSound,
      required bool isSample}) async {
    await stopSound();

    soundEffectsPlayer
        .setAsset(asset); // set audio asset to menu selection

    switch (selectedSound) {
      // for when selecting an audio source in the selection menu
      case "bell_chime":
        await soundEffectsPlayer.setClip(
            start: Duration(seconds: 0), end: Duration(seconds: 5));
      case "windchimes":
        await soundEffectsPlayer.setClip(
            start: Duration(seconds: 10), end: Duration(seconds: 15));
      case "chirp_chime":
        await soundEffectsPlayer.setClip(
            start: Duration(seconds: 10), end: Duration(seconds: 15));
    }

    playSound();
  }

  // background controls
  Future<void> adjustBackgroundVolume(val) =>
      backgroundMusicPlayer.setVolume(val);
  Future<void> playBackground() => backgroundMusicPlayer.play();
  Future<void> pauseBackground() => backgroundMusicPlayer.pause();
  Future<void> stopBackground() => backgroundMusicPlayer.stop();
  Future<void> playActiveBackground() async {
    //await backgroundMusicPlayer.setClip(start: Duration(seconds: 0), end: null);
    await backgroundMusicPlayer.setLoopMode(LoopMode.one);
    playBackground();
  }

  // ending chime controls (used with interval for now)
  Future<void> adjustSoundEffectsVolume(val) =>
      soundEffectsPlayer.setVolume(val);
  Future<void> playSound() => soundEffectsPlayer.play();
  Future<void> pauseSound() => soundEffectsPlayer.pause();
  Future<void> stopSound() => soundEffectsPlayer.stop();

  Future<void> playActiveIntervalSound() async {
    await soundEffectsPlayer.setClip(
      start: const Duration(seconds: 0),
      end: Duration(seconds: 5),);
    //await stopSound();
    playSound(); // keep same clip
  }

  Future<void> playActiveSound() async {
    await stopSound();
    /*await soundEffectsPlayer.setClip(
      start: const Duration(seconds: 0),
      end: null,
    );*/
    soundEffectsPlayer.seek(Duration.zero);
    playSound();
  }
}

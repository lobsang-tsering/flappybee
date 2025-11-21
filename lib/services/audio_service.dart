import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // A dedicated player for each sound effect to prevent them from cutting each other off.
  static final AudioPlayer _playerScore = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _playerHit = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _playerDie = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _playerSwoosh = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static bool _initialized = false;
  static bool _isMuted = false;

  // Asset sources pointing to the correct .ogg files.
  static final AssetSource _jumpSource = AssetSource('audio/wing.ogg');
  static final AssetSource _scoreSource = AssetSource('audio/point.ogg');
  static final AssetSource _hitSource = AssetSource('audio/hit.ogg'); // The impact sound
  static final AssetSource _dieSource = AssetSource('audio/die.ogg'); // The fall/end sound
  static final AssetSource _swooshSource = AssetSource('audio/swoosh.ogg');

  static Future<void> init() async {
    if (_initialized) return;
    debugPrint("AudioService: Initialized for asset playback.");
    _initialized = true;
  }

  /// For short, overlapping sounds like jumping, we create a new player instance each time.
  /// This allows multiple sounds to play simultaneously.
  static void playJump() {
    if (_isMuted) return;
    // Create a new player instance that will be disposed of automatically after playing.
    final player = AudioPlayer()..setReleaseMode(ReleaseMode.release);
    player.play(_jumpSource);
  }

  static void playScore() => _play(_playerScore, _scoreSource);
  static void playCoin() => playScore();
  static void playSwoosh() => _play(_playerSwoosh, _swooshSource);
  static void playHit() => _play(_playerHit, _hitSource);
  static void playCrash() => _play(_playerDie, _dieSource);

  static void _play(AudioPlayer player, AssetSource source) {
    if (!_initialized || _isMuted) return;
    // We don't need to stop the player before playing a new sound
    // because each of these sounds has its own dedicated player.
    // This is good for distinct sounds, but not for rapid-fire sounds
    // that should overlap, like the jump sound.
    player.play(source);
  }

  // --- Mute / Dispose ---

  static void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _playerScore.stop();
      _playerHit.stop();
      _playerDie.stop();
      _playerSwoosh.stop();
    }
  }

  static bool isMuted() => _isMuted;
  static void setMuted(bool muted) => _isMuted = muted;

  static Future<void> dispose() async {
    await _playerScore.dispose();
    await _playerHit.dispose();
    await _playerDie.dispose();
    await _playerSwoosh.dispose();
    _initialized = false;
  }
}

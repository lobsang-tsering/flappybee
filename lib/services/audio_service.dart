import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  // Independent players
  static final AudioPlayer _playerJump = AudioPlayer();
  static final AudioPlayer _playerScore = AudioPlayer();
  static final AudioPlayer _playerCrash = AudioPlayer();

  static bool _initialized = false;
  static bool _isMuted = false;

  // Audio Data
  static Uint8List? _jumpBytes;
  static Uint8List? _scoreBytes;
  static Uint8List? _crashBytes;
  static Uint8List? _swooshBytes;

  static Future<void> init() async {
    if (_initialized) return;

    debugPrint("AudioService: Generating 8-bit sounds...");

    // 1. Synthesize Sounds
    // Jump: Square wave slide (Mario jump style)
    _jumpBytes = _generateWav(
      type: 'square',
      startFreq: 150,
      endFreq: 300,
      duration: 0.1,
      volume: 0.3,
    );

    // Score: CUSTOM COIN SOUND (B5 -> E6 Arpeggio)
    _scoreBytes = _generateCoinWav();

    // Crash: Low pitch noise/sawtooth
    _crashBytes = _generateWav(
      type: 'sawtooth',
      startFreq: 150,
      endFreq: 50,
      duration: 0.3,
      volume: 0.4,
    );

    // Swoosh: High pitch slide
    _swooshBytes = _generateWav(
      type: 'square',
      startFreq: 600,
      endFreq: 1200,
      duration: 0.2,
      volume: 0.2,
    );

    // 2. Prepare Players
    try {
      await _playerJump.setSource(BytesSource(_jumpBytes!));
      await _playerJump.setReleaseMode(ReleaseMode.stop);

      await _playerScore.setSource(BytesSource(_scoreBytes!));
      await _playerScore.setReleaseMode(ReleaseMode.stop);

      await _playerCrash.setSource(BytesSource(_crashBytes!));
      await _playerCrash.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint("AudioService init error: $e");
    }

    _initialized = true;
  }

  // --- Playback Methods ---

  static void playJump() {
    if (!_initialized || _isMuted) return;
    _safePlay(_playerJump, _jumpBytes!);
  }

  static void playScore() {
    if (!_initialized || _isMuted) return;
    _safePlay(_playerScore, _scoreBytes!);
  }

  static void playCoin() => playScore();

  static void playCrash() {
    if (!_initialized || _isMuted) return;
    _safePlay(_playerCrash, _crashBytes!);
  }

  static void playHit() => playCrash();

  static void playCelebration() {
    if (!_initialized || _isMuted) return;
    _playerScore.play(BytesSource(_swooshBytes!));
  }

  static void _safePlay(AudioPlayer player, Uint8List bytes) {
    try {
      if (player.state == PlayerState.playing) {
        player.stop();
      }
      player.play(BytesSource(bytes));
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  // --- Mute / Dispose ---

  static void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _playerJump.stop();
      _playerScore.stop();
      _playerCrash.stop();
    }
  }

  static bool isMuted() => _isMuted;
  static void setMuted(bool muted) => _isMuted = muted;

  static Future<void> dispose() async {
    await _playerJump.dispose();
    await _playerScore.dispose();
    await _playerCrash.dispose();
    _initialized = false;
  }

  // --- SPECIAL COIN GENERATOR ---
  // Generates a two-tone "Bling" sound (B5 -> E6)
  static Uint8List _generateCoinWav() {
    const int sampleRate = 44100;
    final List<int> pcmData = [];

    // Tone 1: B5 (987.77 Hz) for 0.06 seconds
    _addTone(pcmData, sampleRate, 988.0, 0.06, 0.4);

    // Tone 2: E6 (1318.51 Hz) for 0.30 seconds (Decaying)
    _addTone(pcmData, sampleRate, 1319.0, 0.30, 0.4, decay: true);

    return _finalizeWav(pcmData, sampleRate);
  }

  // Helper to add a specific frequency to the PCM buffer
  static void _addTone(
    List<int> buffer,
    int sampleRate,
    double freq,
    double duration,
    double volume, {
    bool decay = false,
  }) {
    final int numSamples = (duration * sampleRate).toInt();
    for (int i = 0; i < numSamples; i++) {
      final double t = i / numSamples;
      final double cycle = sampleRate / freq;
      final double val = 2 * pi * (i / cycle);

      // Square Wave (Classic 8-bit sound)
      double sample = sin(val) > 0 ? 1.0 : -1.0;

      // Apply Volume
      double amp = volume;

      // Apply Decay (fade out) if requested
      if (decay) {
        amp *= (1.0 - t);
      }

      int intSample = ((sample * amp + 1.0) * 127.5).toInt();
      buffer.add(intSample.clamp(0, 255));
    }
  }

  // --- GENERIC GENERATOR (Jump/Crash) ---
  static Uint8List _generateWav({
    required String type,
    required double startFreq,
    required double endFreq,
    required double duration,
    required double volume,
  }) {
    const int sampleRate = 44100;
    final List<int> pcmData = [];
    final int numSamples = (duration * sampleRate).toInt();

    for (int i = 0; i < numSamples; i++) {
      final double t = i / numSamples;
      final double currentFreq = startFreq + (endFreq - startFreq) * t;

      double amp = volume;
      if (t < 0.1) amp *= (t / 0.1); // Attack
      if (t > 0.8) amp *= ((1.0 - t) / 0.2); // Release

      final double cycle = sampleRate / currentFreq;
      final double val = 2 * pi * (i / cycle);

      double sample = 0;
      if (type == 'sine')
        sample = sin(val);
      else if (type == 'square')
        sample = sin(val) > 0 ? 1.0 : -1.0;
      else if (type == 'sawtooth')
        sample = 2 * ((i / cycle) - (i / cycle).floor() - 0.5);

      int intSample = ((sample * amp + 1.0) * 127.5).toInt();
      pcmData.add(intSample.clamp(0, 255));
    }

    return _finalizeWav(pcmData, sampleRate);
  }

  // Adds the WAV Header to raw PCM data
  static Uint8List _finalizeWav(List<int> pcmData, int sampleRate) {
    final int fileSize = 36 + pcmData.length;
    final ByteData header = ByteData(44);

    header.setUint8(0, 0x52);
    header.setUint8(1, 0x49);
    header.setUint8(2, 0x46);
    header.setUint8(3, 0x46); // RIFF
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57);
    header.setUint8(9, 0x41);
    header.setUint8(10, 0x56);
    header.setUint8(11, 0x45); // WAVE
    header.setUint8(12, 0x66);
    header.setUint8(13, 0x6D);
    header.setUint8(14, 0x74);
    header.setUint8(15, 0x20); // fmt
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate, Endian.little);
    header.setUint16(32, 1, Endian.little);
    header.setUint16(34, 8, Endian.little);
    header.setUint8(36, 0x64);
    header.setUint8(37, 0x61);
    header.setUint8(38, 0x74);
    header.setUint8(39, 0x61); // data
    header.setUint32(40, pcmData.length, Endian.little);

    return Uint8List.fromList(header.buffer.asUint8List() + pcmData);
  }
}

import 'package:flutter/material.dart';

// Physics & Game Settings
const double kGameSpeed = 3.5;
const double kGravity = 0.4;
const double kJumpStrength = -7.5;
const int kPipeSpawnRate = 180; // Frames
const double kPipeWidth = 70.0;
const double kBirdSize = 38.0;
const double kGapSize = 150.0;
const double kBlockSize = 60.0;
const int kQuestionDelayFrames =
    120; // Frames to wait before pipe appears (2 sec at 60fps)

// Colors
const Color kSkyColor = Color(0xFF70C5CE);
const Color kPipeGreen = Color(0xFF73BF2E);
const Color kPipeBorder = Color(0xFF538D22);
const Color kDarkBorder = Colors.black;

// Dimensions (Initial assumptions, responsive in app)
const double kMaxGameWidth = 600.0;
const double pi = 3.14;
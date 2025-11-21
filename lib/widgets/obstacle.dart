import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../types.dart';

class ObstacleWidget extends StatelessWidget {
  final PipeData data;

  const ObstacleWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final problem = data.problem;
    String topLabel = "", bottomLabel = "";

    if (problem is MathProblem) {
      topLabel = data.correctIsTop
          ? problem.correctAnswer
          : problem.wrongAnswer;
      bottomLabel = data.correctIsTop
          ? problem.wrongAnswer
          : problem.correctAnswer;
    } else if (problem is SpellingProblem) {
      topLabel = data.correctIsTop
          ? problem.correctAnswer
          : problem.wrongAnswer;
      bottomLabel = data.correctIsTop
          ? problem.wrongAnswer
          : problem.correctAnswer;
    }

    // Don't render if still in visibility delay
    if (data.visibilityDelay > 0) {
      return const SizedBox.shrink();
    }

    final halfGap = kGapSize / 2;
    final block1Height = data.gapTop - halfGap;
    final block2Top = data.gapTop + halfGap;
    final block2Height = (data.gapBottom - halfGap) - block2Top;
    final block3Top = data.gapBottom + halfGap;

    return Positioned(
      left: data.x,
      top: 0,
      bottom: 0,
      width: kPipeWidth,
      child: Stack(
        children: [
          // Top Pipe
          Positioned(
            top: 0,
            height: block1Height,
            left: 0,
            right: 0,
            child: _buildPipe(isTop: true),
          ),
          // Middle Pipe
          Positioned(
            top: block2Top,
            height: block2Height,
            left: 0,
            right: 0,
            child: _buildPipe(isCenter: true),
          ),
          // Bottom Pipe
          Positioned(
            top: block3Top,
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildPipe(isBottom: true),
          ),

          // Labels
          Positioned(
            top: data.gapTop - 40,
            height: 80,
            left: -20,
            right: -20,
            child: Center(child: _buildLabel(topLabel)),
          ),
          Positioned(
            top: data.gapBottom - 40,
            height: 80,
            left: -20,
            right: -20,
            child: Center(child: _buildLabel(bottomLabel)),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.vt323(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [const Shadow(offset: Offset(3, 3), color: Colors.black)],
      ),
    );
  }

  Widget _buildPipe({
    bool isTop = false,
    bool isBottom = false,
    bool isCenter = false,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF549624),
                Color(0xFF73BF2E),
                Color(0xFF73BF2E),
                Color(0xFF549624),
              ],
              stops: [0.0, 0.1, 0.6, 1.0],
            ),
            border: const Border(
              left: BorderSide(width: 3),
              right: BorderSide(width: 3),
            ),
          ),
        ),
        if (isTop)
          Positioned(
            bottom: 0,
            left: -2,
            right: -2,
            height: 30,
            child: _buildCap(),
          ),
        if (isBottom)
          Positioned(
            top: 0,
            left: -2,
            right: -2,
            height: 30,
            child: _buildCap(),
          ),
        if (isCenter) ...[
          Container(decoration: BoxDecoration(border: Border.all(width: 3))),
          Center(
            child: Container(width: 20, height: 20, color: Colors.black12),
          ),
        ],
      ],
    );
  }

  Widget _buildCap() {
    return Container(
      decoration: BoxDecoration(
        color: kPipeGreen,
        border: Border.all(width: 4, color: Colors.black),
      ),
    );
  }
}
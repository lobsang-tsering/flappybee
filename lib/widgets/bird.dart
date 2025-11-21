import 'package:flutter/material.dart';
import '../constants.dart';
import '../types.dart';

class BirdWidget extends StatelessWidget {
  final double rotation;
  final CharacterType type;

  const BirdWidget({super.key, required this.rotation, required this.type});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * (pi / 180),
      child: SizedBox(
        width: kBirdSize,
        height: kBirdSize * 0.75,
        child: _buildSkin(),
      ),
    );
  }

  Widget _buildSkin() {
    switch (type) {
      case CharacterType.bee:
        return Stack(
          children: [
            // Body
            Container(
              decoration: BoxDecoration(
                color: Colors.yellow[400],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 2, color: Colors.black),
              ),
            ),
            // Stripes
            Positioned(
              left: 12,
              width: 8,
              top: 0,
              bottom: 0,
              child: Container(color: Colors.black),
            ),
            Positioned(
              left: 24,
              width: 8,
              top: 0,
              bottom: 0,
              child: Container(color: Colors.black),
            ),
            // Eye
            Positioned(
              right: 6,
              top: 2,
              width: 10,
              height: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(width: 2),
                ),
                child: Center(
                  child: Container(width: 3, height: 3, color: Colors.black),
                ),
              ),
            ),
            // Wing
            Positioned(
              top: -8,
              left: 10,
              width: 12,
              height: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(width: 2),
                ),
              ),
            ),
            // Stinger
            Positioned(
              bottom: 10,
              left: -4,
              width: 6,
              height: 6,
              child: Transform.rotate(
                angle: pi / 4,
                child: Container(color: Colors.black),
              ),
            ),
          ],
        );
      case CharacterType.rocket:
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 4, right: 4),
              decoration: BoxDecoration(
                color: Colors.blueGrey[200],
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(20),
                ),
                border: Border.all(width: 2),
              ),
            ),
            // Window
            Positioned(
              right: 12,
              top: 8,
              width: 10,
              height: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.cyan[200],
                  shape: BoxShape.circle,
                  border: Border.all(width: 2),
                ),
              ),
            ),
            // Fins
            Positioned(
              top: 0,
              left: 0,
              width: 10,
              height: 10,
              child: Container(
                color: Colors.red,
                transform: Matrix4.skewX(-0.2),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              width: 10,
              height: 10,
              child: Container(
                color: Colors.red,
                transform: Matrix4.skewX(0.2),
              ),
            ),
            // Flame
            Positioned(
              top: 12,
              left: -8,
              width: 10,
              height: 10,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        );
      case CharacterType.bird:
      default:
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.yellow[400],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(width: 2, color: Colors.black),
              ),
            ),
            Positioned(
              top: -4,
              right: 4,
              width: 14,
              height: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(width: 2),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.all(2),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: -4,
              width: 20,
              height: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2),
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -6,
              width: 12,
              height: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  border: Border.all(width: 2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        );
    }
  }
}
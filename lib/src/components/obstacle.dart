import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import 'ball.dart'; // Assuming there's a Ball class

class Obstacle extends PositionComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Obstacle({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
          children: [RectangleHitbox()],
        );

  final Radius cornerRadius;

  final _paint = Paint()
    ..color = const Color(0xff0a0a0a)
    ..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size.toSize(),
          cornerRadius,
        ),
        _paint);
  }

  void moveBy(double dx) {
    add(MoveToEffect(
      Vector2((position.x + dx).clamp(0, game.width), position.y),
      EffectController(duration: 0.1),
    ));
  }

  @override
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollision(intersectionPoints, other);

    if (other is Ball) {
      // Reverse the ball's y-velocity to bounce it back
      other.velocity.y = -other.velocity.y;

      // Adjust ball position slightly to avoid overlapping
      if (intersectionPoints.isNotEmpty) {
        other.position += Vector2(0, other.velocity.y.sign * 1);
      }

      // Debugging logs
      print('Ball velocity: ${other.velocity}');
      print('Ball position: ${other.position}');
    }
  }
}

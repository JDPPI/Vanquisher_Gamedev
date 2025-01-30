import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import 'ball.dart';
import 'bat.dart';
import 'fireball.dart';

enum PowerUpType { enlargeBat, shrinkBat, slowBall, multiplyBalls, fireball }

class PowerUp extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  PowerUp({
    required this.type,
    required super.position,
    required double radius,
  }) : super(
          radius: radius,
          anchor: Anchor.center,
          paint: Paint()
            ..color = _getPowerUpColor(type)
            ..style = PaintingStyle.fill,
          children: [CircleHitbox()],
        );

  final PowerUpType type;

  @override
  void update(double dt) {
    super.update(dt);
    position.y += 200 * dt; // Power-ups fall down at a constant speed.

    if (position.y > game.size.y) {
      removeFromParent(); // Remove if it goes off-screen.
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bat) {
      applyEffect();
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  void applyEffect() {
    switch (type) {
      case PowerUpType.enlargeBat:
        _applyBatEffect(1.5, duration: 5);
        break;
      case PowerUpType.shrinkBat:
        _applyBatEffect(0.5, duration: 5);
        break;
      case PowerUpType.slowBall:
        _applySlowBall();
        break;
      case PowerUpType.multiplyBalls:
        _multiplyBalls(3);
        break;
      case PowerUpType.fireball:
        _activateFireball();
        break;
    }
  }

  void _applyBatEffect(double scaleFactor, {required int duration}) {
    final bat = game.world.children.query<Bat>().first;
    final originalWidth = bat.size.x;
    bat.size.x *= scaleFactor;

    Future.delayed(Duration(seconds: duration), () {
      if (bat.isMounted) bat.size.x = originalWidth;
    });
  }

  void _applySlowBall() {
    final ball = game.world.children.query<Ball>().first;
    ball.velocity.scale(0.5);
    Future.delayed(const Duration(seconds: 5), () {
      ball.velocity.scale(2.0); // Reset the ball speed.
    });
  }

  void _multiplyBalls(int factor) {
    final existingBalls = game.world.children.query<Ball>();
    for (final ball in existingBalls) {
      for (int i = 0; i < factor - 1; i++) {
        final newBall = Ball(
          velocity: ball.velocity.clone()..scale(1 + 0.2 * i),
          position: ball.position.clone(),
          radius: ball.radius,
          difficultyModifier: ball.difficultyModifier,
        );
        game.world.add(newBall);
      }
    }
  }

  void _activateFireball() {
    final fireball = Fireball(
      position: game.world.children.query<Bat>().first.position.clone(),
      radius: 30.0,
      velocity: Vector2(0, -500), // Initial upward direction
    );
    game.world.add(fireball);
  }

  static Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.enlargeBat:
        return Colors.greenAccent;
      case PowerUpType.shrinkBat:
        return Colors.redAccent;
      case PowerUpType.slowBall:
        return Colors.blueAccent;
      case PowerUpType.multiplyBalls:
        return Colors.orangeAccent;
      case PowerUpType.fireball:
        return Color(0xff000000);
      default:
        return Colors.purple;
    }
  }
}

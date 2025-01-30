import 'package:brick_breaker/src/components/obstacle.dart';
import 'package:brick_breaker/src/components/power_up.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'ball.dart';
import 'bat.dart';

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Brick({required super.position, required Color color})
      : super(
          size: Vector2(brickWidth, brickHeight),
          anchor: Anchor.center,
          paint: Paint()
            ..color = color
            ..style = PaintingStyle.fill,
          children: [RectangleHitbox()],
        );

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    removeFromParent();
    game.score.value++;

    // Chance to spawn a power-up
    if (game.rand.nextDouble() < 0.3) {
      // 30% chance
      final powerUp = PowerUp(
        type: PowerUpType.values[game.rand.nextInt(PowerUpType.values.length)],
        position: position,
        radius: game.size.x * 0.03,
      );
      game.world.add(powerUp);
    }

    if (game.world.children.query<Brick>().length == 1) {
      game.playState = PlayState.won;
      game.world.removeAll(game.world.children.query<Ball>());
      game.world.removeAll(game.world.children.query<Bat>());
      game.world.removeAll(game.world.children.query<Obstacle>());
    }
  }
}

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../brick_breaker.dart';
import 'brick.dart';

class Fireball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Fireball({
    required super.position,
    required double radius,
    required this.velocity,
  }) : super(
          radius: radius,
          anchor: Anchor.center,
          paint: _createFireballPaint(),
          children: [
            CircleHitbox(),
          ],
        ) {
    _addFireTrail();
    _addFlickerEffect();
    _addRotationEffect();
    _addSizePulseEffect();
    _addColorShiftEffect();
  }

  Vector2 velocity;

  static Paint _createFireballPaint() {
    return Paint()
      ..shader = RadialGradient(
        colors: [Colors.yellow, Colors.orange, Colors.red],
        stops: [0.0, 0.5, 1.0],
        center: Alignment.center,
        radius: 0.5,
      ).createShader(Rect.fromCircle(center: Offset(0, 0), radius: 50.0))
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7.0); // Stronger glow
  }

  /// 🔥 Adds a fire trail that fades out
  void _addFireTrail() {
    add(
      ParticleSystemComponent(
        position: Vector2.zero(),
        particle: Particle.generate(
          lifespan: 0.3,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 20),
            child: CircleParticle(
              radius: Random().nextDouble() * 3 + 2,
              paint: Paint()..color = Colors.orange.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 Adds a flickering effect to simulate a fire's movement
  void _addFlickerEffect() {
    add(
      OpacityEffect.to(
        0.5,
        EffectController(
          duration: 0.1,
          reverseDuration: 0.1,
          infinite: true,
        ),
      ),
    );
  }

  /// 🔄 Makes the fireball rotate slightly to simulate swirling flames
  void _addRotationEffect() {
    add(
      RotateEffect.by(
        pi * 0.1,
        EffectController(
          duration: 0.2,
          reverseDuration: 0.2,
          infinite: true,
          alternate: true,
        ),
      ),
    );
  }

  /// 🔥 Expands and contracts slightly to simulate breathing fire
  void _addSizePulseEffect() {
    add(
      SizeEffect.to(
        Vector2.all(radius * 1.2),
        EffectController(
          duration: 0.2,
          reverseDuration: 0.2,
          infinite: true,
          alternate: true,
        ),
      ),
    );
  }

  /// 🎨 Cycles through red, orange, and yellow for a dynamic fire effect
  void _addColorShiftEffect() {
    add(
      ColorEffect(
        Colors.red,
        EffectController(duration: 0.3, infinite: true, alternate: true),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    if (position.y < 0 || position.y > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Brick) {
      other.removeFromParent();

      // 💥 Shockwave Effect on collision
      game.add(
        CircleComponent(
          position: position.clone(),
          radius: 5,
          paint: Paint()..color = Colors.orange.withOpacity(0.7),
        )..add(
            SizeEffect.to(
              Vector2.all(50),
              EffectController(duration: 0.2),
            ),
          ),
      );

      // 🔥 Fireball explosion effect
      game.add(
        ParticleSystemComponent(
          position: position.clone(),
          particle: Particle.generate(
            lifespan: 0.3,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(0, 50),
              child: CircleParticle(
                radius: Random().nextDouble() * 6 + 3,
                paint: Paint()..color = Colors.red.withOpacity(0.8),
              ),
            ),
          ),
        ),
      );
    }
    super.onCollision(intersectionPoints, other);
  }
}

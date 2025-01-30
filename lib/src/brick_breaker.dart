import 'dart:async';
import 'dart:math' as math;

import 'package:brick_breaker/src/components/power_up.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/components.dart';
import 'components/obstacle.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won }

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  BrickBreaker()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  final ValueNotifier<int> score = ValueNotifier(0);
  final rand = math.Random();

  double get width => size.x;
  double get height => size.y;

  late PlayState _playState;
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
        overlays.add(playState.name);
        break;
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
        break;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;
    world.add(PlayArea());

    playState = PlayState.welcome;
  }

  void startGame() {
    if (playState == PlayState.playing) return;

    // Clear previous game components
    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Obstacle>());
    world.removeAll(world.children.query<PowerUp>());
    world.removeAll(world.children.query<Brick>());

    playState = PlayState.playing;
    score.value = 0;

    // Add game components
    world.add(Ball(
      difficultyModifier: difficultyModifier,
      radius: ballRadius,
      position: size / 2,
      velocity:
          Vector2((rand.nextDouble() - 0.5) * width, height * 0.2).normalized()
            ..scale(height / 2),
    ));

    world.add(Bat(
      size: Vector2(batWidth, batHeight),
      cornerRadius: const Radius.circular(ballRadius / 2),
      position: Vector2(width / 2, height * 0.90),
    ));

    // Add central and side obstacles
    final obstacleMargin = 20.0; // Distance from the play area edges
    world.addAll([
      Obstacle(
        size: Vector2(batWidth, batHeight),
        cornerRadius: const Radius.circular(ballRadius / 2),
        position: Vector2(width / 2, height * 0.35),
      ),
      Obstacle(
        size: Vector2(batWidth, batHeight),
        cornerRadius: const Radius.circular(ballRadius / 2),
        position: Vector2(obstacleMargin + batWidth / 2, height * 0.45),
      ),
      Obstacle(
        size: Vector2(batWidth, batHeight),
        cornerRadius: const Radius.circular(ballRadius / 2),
        position:
            Vector2(width - (obstacleMargin + batWidth / 2), height * 0.45),
      ),
    ]);

    // Add bricks
    world.addAll([
      for (var i = 0; i < brickColors.length; i++)
        for (var j = 1; j <= 5; j++)
          Brick(
            position: Vector2(
              (i + 0.5) * brickWidth + (i + 1) * brickGutter,
              (j + 2.0) * brickHeight + j * brickGutter,
            ),
            color: brickColors[i],
          ),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check for winning condition
    if (world.children.query<Brick>().isEmpty &&
        playState == PlayState.playing) {
      playState = PlayState.won;
      overlays.add(PlayState.won.name);
    }

    // Check for game over
    if (world.children.query<Ball>().isEmpty &&
        playState == PlayState.playing) {
      playState = PlayState.gameOver;
      overlays.add(PlayState.gameOver.name);
    }
  }

  @override
  void onTap() {
    super.onTap();
    startGame();
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-batStep);
        break;
      case LogicalKeyboardKey.arrowRight:
        world.children.query<Bat>().first.moveBy(batStep);
        break;
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        startGame();
        break;
    }
    return KeyEventResult.handled;
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}

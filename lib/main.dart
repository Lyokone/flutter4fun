import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction { forward, reverse }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Direction direction = Direction.forward;
  int randomRotation = Random().nextInt(50) - 25;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 4),
    reverseDuration: const Duration(seconds: 8),
    animationBehavior: AnimationBehavior.preserve,
    vsync: this,
  )
    ..forward()
    ..addListener(() async {
      if (_controller.isCompleted && direction == Direction.forward) {
        setState(() {
          direction = Direction.reverse;
        });
        await Future.delayed(Duration(seconds: 7));
        _controller.reverse();
      } else if (_controller.isDismissed && direction == Direction.reverse) {
        _controller.forward();
        direction = Direction.forward;
        randomRotation = Random().nextInt(50) - 25;
      }
      setState(() {});
    });

  late final scaleAnimation = Tween(
    begin: 0.0,
    end: 500.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff9cc4cd),
      body: Center(
        child: RotationTransition(
            turns: new AlwaysStoppedAnimation(randomRotation / 360),
            child: UnconstrainedBox(
              child: AnimatedCrossFade(
                duration: Duration(seconds: 7),
                reverseDuration: Duration(seconds: 0),
                firstChild:
                    TextWidget(text: 'Inspire', scale: scaleAnimation.value),
                secondChild:
                    TextWidget(text: 'Expire', scale: scaleAnimation.value),
                crossFadeState: direction == Direction.forward
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),
            )),
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget({
    Key? key,
    required this.text,
    required this.scale,
  }) : super(key: key);

  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      clipBehavior: Clip.none,
      child: Center(
        child: Text(
          text,
          overflow: TextOverflow.visible,
          style: TextStyle(
              fontFamily: 'Alphasmoke', color: Colors.white, fontSize: scale),
        ),
      ),
    );
  }
}

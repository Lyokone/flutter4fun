import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_animations/simple_animations.dart';

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
      title: 'Zen Breath',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  String text = 'Inspire';
  bool hold = false;

  int randomRotation = Random().nextInt(50) - 25;

  late final AnimationController _pulseController = AnimationController(
    duration: const Duration(seconds: 2),
    animationBehavior: AnimationBehavior.preserve,
    vsync: this,
  )
    ..repeat(reverse: true)
    ..addListener(() {
      setState(() {});
    });

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 4),
    reverseDuration: const Duration(seconds: 8),
    animationBehavior: AnimationBehavior.preserve,
    vsync: this,
  )
    ..forward()
    ..addListener(() async {
      if (_controller.isCompleted) {
        setState(() {
          hold = true;
        });
        await Future.delayed(Duration(seconds: 7));
        setState(() {
          text = 'Expire';
          hold = false;
        });

        _controller.reverse();
      } else if (_controller.isDismissed) {
        setState(() {
          text = 'Inspire';
        });
        _controller.forward();
        randomRotation = Random().nextInt(50) - 25;
      }
      setState(() {});
    });

  late final scaleAnimation = Tween(
    begin: -10.0,
    end: 250.0,
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                tileMode: TileMode.mirror,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff95c1da),
                  Color(0xff37a6ff),
                ],
                stops: [
                  0,
                  1,
                ],
              ),
              backgroundBlendMode: BlendMode.srcOver,
            ),
            child: PlasmaRenderer(
              type: PlasmaType.infinity,
              particles: 13,
              color: Color(0x174396e9),
              blur: 0.43,
              size: 0.5,
              speed: 0.2,
              offset: 0,
              blendMode: BlendMode.plus,
              particleType: ParticleType.circle,
              variation1: 0,
              variation2: 0,
              variation3: 0,
              rotation: -3.14,
            ),
          ),
          Center(
            child: RotationTransition(
                turns: new AlwaysStoppedAnimation(randomRotation / 360),
                child: UnconstrainedBox(
                  child: AnimatedCrossFade(
                    alignment: Alignment.center,
                    duration: Duration(seconds: 2),
                    firstChild: TextWidget(
                        text: text,
                        scale:
                            scaleAnimation.value + 10 * _pulseController.value),
                    secondChild: SizedBox(
                      width: 1000,
                      child: TextWidget(
                          text: 'Hold',
                          scale: scaleAnimation.value +
                              10 * _pulseController.value),
                    ),
                    crossFadeState: !hold
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                  ),
                )),
          ),
        ],
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
    return SizedBox(
      height: max(0, scale),
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: Text(
          text,
          overflow: TextOverflow.visible,
          style: TextStyle(fontFamily: 'Alphasmoke', color: Colors.white),
        ),
      ),
    );
  }
}

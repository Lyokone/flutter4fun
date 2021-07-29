import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    begin: 0.0,
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
      body: Center(
        child: RotationTransition(
            turns: new AlwaysStoppedAnimation(randomRotation / 360),
            child: UnconstrainedBox(
              child: AnimatedCrossFade(
                duration: Duration(seconds: 2),
                firstChild: TextWidget(text: text, scale: scaleAnimation.value),
                secondChild: TextWidget(
                    text: 'Hold',
                    scale: scaleAnimation.value + 10 * _pulseController.value),
                crossFadeState: !hold
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
        child: SizedBox(
          height: scale,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              text,
              overflow: TextOverflow.visible,
              style: TextStyle(fontFamily: 'Alphasmoke', color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui' as ui;

import 'package:dla_clock/dla_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

const _fast = 5e5;
const _slow = 2e7;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final ui.FragmentProgram _fp;
  late final ui.FragmentShader _fs;
  Rect? rect;
  bool _ready = false;
  double _t = 1;
  DateTime _start = DateTime.now();
  double _speed = _fast;

  @override
  void initState() {
    _initialise();
    _ticker = createTicker(_onTick);
    super.initState();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Container();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('DLA Clock'),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              if (_speed == _fast) {
                _speed = _slow;
              } else {
                _speed = _fast;
              }
              _t = -0.3;
              _start = DateTime.now();
              _ticker.start();
            }),
            icon: const Icon(Icons.start),
          )
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(builder: (_, constraints) {
            _widgetSize = constraints.biggest;
            return CustomPaint(
              painter: DlaPainter(
                shader: _fs,
                angle: _t * 2 - 1.7,
                scale: 0.75 + (1.3 - _t) * 5,
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _initialise() async {
    _fp = await ui.FragmentProgram.fromAsset('shaders/shader.frag');
    _fs = _fp.fragmentShader();
    _widgetSize = const Size(1, 1);
    _radius = 1;
    _updateTime();
    _updateDayOrNight();
    final imageBytes = await rootBundle.load('assets/texture.png');
    ui.decodeImageFromList(imageBytes.buffer.asUint8List(), (result) {
      _fs.setImageSampler(0, result);
      _ready = true;
      setState(() {});
    });
  }

  set _widgetSize(Size size) {
    _fs.setFloat(0, size.width);
    _fs.setFloat(1, size.height);
  }

  // Radius is in [0..1], the visible portion of the clock face.
  set _radius(double r) => _fs.setFloat(2, r);

  void _updateTime() {
    final now = DateTime.now();
    final nowSeconds = (now.hour % 12) * 3600 + now.minute * 60 + now.second;
    final s = nowSeconds * 864 / 1024 / 43200 + 80.5 / 1024;
    _fs.setFloat(3, s);
  }

  void _updateDayOrNight() {
    if (DateTime.now().hour > 11) {
      _fs.setFloat(4, 1);
      return;
    }
    _fs.setFloat(4, 0);
  }

  void _onTick(Duration d) {
    _t =
        (DateTime.now().difference(_start).inMicroseconds / _speed) * 1.3 - 0.3;
    if (_t > 1) {
      _t = 1;
      _ticker.stop();
    }
    setState(() {
      _radius = _t;
    });
  }
}

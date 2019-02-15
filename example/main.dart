/*
 * Copyright (c) 2019 Tyler Filla
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would
 *    be appreciated but is not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not
 *    be misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source
 *    distribution.
 */

import 'package:fancy_button/fancy_button.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(Example());
}

class Example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fancy_button',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        accentColor: Colors.amberAccent,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final _key = GlobalKey<FancyButtonState>();

  @override
  void initState() {
    super.initState();

    // Start the animation sequence
    animate();
  }

  void animate() async {
    final pause = const Duration(seconds: 1, milliseconds: 200);

    await Future.delayed(pause);
    _key.currentState.pose = FancyButtonPose.shown_icon;
    await Future.delayed(pause);
    _key.currentState.pose = FancyButtonPose.shown_label;

    // Tail call, please?
    // Is that a thing with asyncs?
    return animate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('fancy_button')),
      floatingActionButton: FancyButton(
        key: _key,
        icon: const Icon(Icons.cake),
        initialPose: FancyButtonPose.shown_label,
        label: const Text('THE CAKE IS A LIE'),
        onPressed: () => print('on pressed'),
        onTouchDown: () => print('on touch down'),
        onTouchUp: () => print('on touch up'),
      ),
    );
  }
}

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

import 'dart:convert' as convert;
import 'dart:ui' as ui;

import 'package:fancy_button/fancy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('create with just icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          icon: const Icon(Icons.cake),
        ),
      ),
    );
  });

  testWidgets('create with just label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          label: const Text('LIE'),
        ),
      ),
    );
  });

  testWidgets('create with both icon and label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          icon: const Icon(Icons.cake),
          label: const Text('LIE'),
        ),
      ),
    );
  });

  testWidgets('create requires one of icon or label to be non-null', (tester) async {
    final confirm = expectAsync0(() {}, reason: 'confirmation of proper throw');

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: FancyButton(),
        ),
      );
    } catch (e) {
      if (e is AssertionError && e.message == 'one of icon and label must be non-null') {
        confirm();
      }
    }
  });

  testWidgets('look up state by global key', (tester) async {
    final key = GlobalKey<FancyButtonState>();

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          key: key,
          icon: const Icon(Icons.cake),
        ),
      ),
    );

    expect(key.currentState, isNotNull);
  });

  testWidgets('pressed event callback', (tester) async {
    final onPressed = expectAsync0(() {}, id: 'onPressed', reason: 'explicit pressed event callback');

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          icon: const Icon(Icons.cake),
          onPressed: onPressed,
        ),
      ),
    );

    await tester.tap(find.byType(FancyButton));
  });

  testWidgets('touch-down event callback', (tester) async {
    final onTouchDown = expectAsync0(() {}, id: 'onTouchDown', reason: 'explicit touch-down event callback');

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          icon: const Icon(Icons.cake),
          onTouchDown: onTouchDown,
        ),
      ),
    );

    // Just test the press (not the whole tap)
    await tester.press(find.byType(FancyButton));
  });

  testWidgets('touch-up event callback', (tester) async {
    final onTouchUp = expectAsync0(() {}, id: 'onTouchUp', reason: 'explicit touch-up event callback');

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          icon: const Icon(Icons.cake),
          onTouchUp: onTouchUp,
        ),
      ),
    );

    await tester.tap(find.byType(FancyButton));
  });

  testWidgets('create with theme colors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          accentColor: Colors.amberAccent,
          accentIconTheme: IconThemeData(
            color: Colors.red,
          ),
        ),
        home: Scaffold(
          floatingActionButton: RepaintBoundary(
            child: FancyButton(
              icon: const Icon(Icons.cake),
            ),
          ),
        ),
      ),
    );

    // Look up element for button
    final element = tester.element(find.byType(FancyButton));

    // Look up nearest repaint boundary
    var ro = element.renderObject;
    while (!ro.isRepaintBoundary) {
      ro = ro.parent;
    }

    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.runAsync(
      () async {
        // Capture image of button
        var image = await ro.layer.toImage(ro.paintBounds);

        // Dump a Base64-encoded PNG of the image to the console
        print('data:image/png;base64,' +
            convert.base64.encode(
                (await image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List().toList(growable: false)));

        // Get image data for testing pixels
        var imageData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

        // View image pixels as list
        var imagePixels = imageData.buffer.asUint32List();

        // Count amberAccent-colored pixels
        var amberAccentPixels = imagePixels.toList()
          ..retainWhere((p) {
            return p ==
                Colors.amberAccent.alpha << 24 |
                    Colors.amberAccent.blue << 16 |
                    Colors.amberAccent.green << 8 |
                    Colors.amberAccent.red;
          });

        // Count red-colored pixels
        var redPixels = imagePixels.toList()
          ..retainWhere((p) {
            return p == Colors.red.alpha << 24 | Colors.red.blue << 16 | Colors.red.green << 8 | Colors.red.red;
          });

        // Expect sufficient amounts of the desired colors
        print('amberAccent: ' + amberAccentPixels.length.toString() + ' (want at least 2100)');
        expect(amberAccentPixels.length, greaterThanOrEqualTo(1500)); // 1512 on Win10 Flutter 1.1.8 beta
        print('red: ' + redPixels.length.toString() + ' (want at least 100)');
        expect(redPixels.length, greaterThanOrEqualTo(100)); // 174 on Win10 Flutter 1.1.8 beta
      },
    );
  });

  testWidgets('create with overridden colors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          // These colors SHOULD NOT influence the button
          accentColor: Colors.amberAccent,
          accentIconTheme: IconThemeData(
            color: Colors.red,
          ),
        ),
        home: Scaffold(
          floatingActionButton: RepaintBoundary(
            child: FancyButton(
              // These colors SHOULD influence the button (unfortunately...they're hideous)
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.yellowAccent,
              icon: const Icon(Icons.cake),
            ),
          ),
        ),
      ),
    );

    // Look up element for button
    final element = tester.element(find.byType(FancyButton));

    // Look up nearest repaint boundary
    var ro = element.renderObject;
    while (!ro.isRepaintBoundary) {
      ro = ro.parent;
    }

    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.runAsync(() async {
      // Capture image of button
      var image = await ro.layer.toImage(ro.paintBounds);

      // Dump a Base64-encoded PNG of the image to the console
      print('data:image/png;base64,' +
          convert.base64.encode(
              (await image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List().toList(growable: false)));

      // Get image data for testing pixels
      var imageData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

      // View image pixels as list
      var imagePixels = imageData.buffer.asUint32List();

      // Count amberAccent-colored pixels
      var amberAccentPixels = imagePixels.toList()
        ..retainWhere((p) {
          return p ==
              Colors.amberAccent.alpha << 24 |
                  Colors.amberAccent.blue << 16 |
                  Colors.amberAccent.green << 8 |
                  Colors.amberAccent.red;
        });

      // Count red-colored pixels
      var redPixels = imagePixels.toList()
        ..retainWhere((p) {
          return p == Colors.red.alpha << 24 | Colors.red.blue << 16 | Colors.red.green << 8 | Colors.red.red;
        });

      // Expect NONE of the theme colors
      print('amberAccent: ' + amberAccentPixels.length.toString() + ' (want absolutely zero)');
      expect(amberAccentPixels.length, isZero,
          reason: 'There were amber pixels. The background override did not work.');
      print('red: ' + redPixels.length.toString() + ' (want absolutely zero)');
      expect(redPixels.length, isZero, reason: 'There were red pixels. The foreground override did not work.');

      // Count purpleAccent-colored pixels
      var purpleAccentPixels = imagePixels.toList()
        ..retainWhere((p) {
          return p ==
              Colors.purpleAccent.alpha << 24 |
                  Colors.purpleAccent.blue << 16 |
                  Colors.purpleAccent.green << 8 |
                  Colors.purpleAccent.red;
        });

      // Count yellowAccent-colored pixels
      var yellowAccentPixels = imagePixels.toList()
        ..retainWhere((p) {
          return p ==
              Colors.yellowAccent.alpha << 24 |
                  Colors.yellowAccent.blue << 16 |
                  Colors.yellowAccent.green << 8 |
                  Colors.yellowAccent.red;
        });

      // Expect sufficient amounts of the desired colors
      print('purpleAccent: ' + purpleAccentPixels.length.toString() + ' (want at least 2100)');
      expect(purpleAccentPixels.length, greaterThanOrEqualTo(1500),
          reason: 'Not enough purple pixels. Background override did not work.'); // 1512 on Win10 Flutter 1.1.8 beta
      print('yellowAccent: ' + yellowAccentPixels.length.toString() + ' (want at least 100)');
      expect(yellowAccentPixels.length, greaterThanOrEqualTo(100),
          reason: 'Not enough yellow pixels. Foreground override did not work.'); // 174 on Win10 Flutter 1.1.8 beta
    });
  });

  testWidgets('default elevation propagation', (tester) async {
    final key = GlobalKey<FancyButtonState>();

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          key: key,
          icon: const Icon(Icons.cake),
        ),
      ),
    );

    expect(key.currentState.elevation, equals(6.0));
  });

  testWidgets('initial elevation propagation', (tester) async {
    final key = GlobalKey<FancyButtonState>();

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          key: key,
          icon: const Icon(Icons.cake),
          initialElevation: 42.0,
        ),
      ),
    );

    expect(key.currentState.elevation, equals(42.0));
  });

  testWidgets('updated elevation propagation (roundtrip)', (tester) async {
    final key = GlobalKey<FancyButtonState>();

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          key: key,
          icon: const Icon(Icons.cake),
        ),
      ),
    );

    key.currentState.elevation = -1234.5;

    expect(key.currentState.elevation, equals(-1234.5));
  });

  testWidgets('default pose propagation', (tester) async {
    final key = GlobalKey<FancyButtonState>();

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          key: key,
          icon: const Icon(Icons.cake),
        ),
      ),
    );

    expect(key.currentState.pose, equals(FancyButtonPose.shownIcon));
  });

  testWidgets('initial pose propagation', (tester) async {
    final key = GlobalKey<FancyButtonState>();

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          key: key,
          icon: const Icon(Icons.cake),
          initialPose: FancyButtonPose.shownIconAndLabel,
        ),
      ),
    );

    expect(key.currentState.pose, equals(FancyButtonPose.shownIconAndLabel));
  });

  testWidgets('updated pose propagation (roundtrip)', (tester) async {
    final key = GlobalKey<FancyButtonState>();

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          key: key,
          icon: const Icon(Icons.cake),
        ),
      ),
    );

    key.currentState.pose = FancyButtonPose.shownLabel;

    expect(key.currentState.pose, equals(FancyButtonPose.shownLabel));
  });
}

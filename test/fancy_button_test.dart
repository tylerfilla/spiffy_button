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
    expect(
      () async {
        await tester.pumpWidget(
          MaterialApp(
            home: FancyButton(),
          ),
        );
      },
      // TODO: Any way to expect the message on the exception?
      throwsAssertionError,
    );
  });

  testWidgets('look up state by global key', (tester) async {
    final key = GlobalKey();

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
    final key = UniqueKey();
    final onPressed = expectAsync0(() {}, id: 'onPressed', reason: 'explicit pressed event callback');

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          key: key,
          icon: const Icon(Icons.cake),
          onPressed: onPressed,
        ),
      ),
    );

    await tester.tap(find.byKey(key));
  });

  testWidgets('touch-down event callback', (tester) async {
    final key = UniqueKey();
    final onTouchDown = expectAsync0(() {}, id: 'onTouchDown', reason: 'explicit touch-down event callback');

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          key: key,
          icon: const Icon(Icons.cake),
          onTouchDown: onTouchDown,
        ),
      ),
    );

    // Just test the press (not the whole tap)
    await tester.press(find.byKey(key));
  });

  testWidgets('touch-up event callback', (tester) async {
    final key = UniqueKey();
    final onTouchUp = expectAsync0(() {}, id: 'onTouchUp', reason: 'explicit touch-up event callback');

    await tester.pumpWidget(
      MaterialApp(
        home: FancyButton(
          key: key,
          icon: const Icon(Icons.cake),
          onTouchUp: onTouchUp,
        ),
      ),
    );

    await tester.tap(find.byKey(key));
  });
}

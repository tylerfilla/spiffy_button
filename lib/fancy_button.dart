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

library fancy_button;

import 'package:flutter/material.dart';

/// The pose of a fancy button.
enum FancyButtonPose {
  /// The button is hidden from view.
  hidden,

  /// The button is shown, and only its icon is visible.
  shown_icon,

  /// The button is shown, and only its text label is visible.
  shown_label,

  /// The button is shown, and its icon and text label are visible.
  shown_icon_and_label,
}

/// A fancy button :)
///
/// This is a custom implementation of Material Design's floating action button
/// (FAB) with better support for its fancy animations between states than the
/// built-in [FloatingActionButton] implementation.
class FancyButton extends StatefulWidget {
  /// The background color. This is used for the button surface.
  ///
  /// By default, the inherited theme's accent color is used.
  final Color backgroundColor;

  /// The foreground color. This is used for the icon and text label.
  ///
  /// By default, the inherited theme's accent icon color is used.
  final Color foregroundColor;

  /// The child icon widget.
  ///
  /// At least one of [icon] and [label] must be non-null.
  final Widget icon;

  /// The child label widget.
  ///
  /// At least one of [icon] and [label] must be non-null.
  final Widget label;

  /// The button pressed callback.
  ///
  /// This is triggered after a full touch-down/touch-up cycle. See the
  /// [onTouchDown] and [onTouchUp] callbacks for specifics on those events.
  final VoidCallback onPressed;

  /// The button touch down callback.
  ///
  /// This is triggered when the user places their finger on the button.
  final VoidCallback onTouchDown;

  /// The button touch up callback.
  ///
  /// This is triggered when the user releases their finger from the button.
  final VoidCallback onTouchUp;

  FancyButton({
    Key key,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.label,
    this.onPressed,
    this.onTouchDown,
    this.onTouchUp,
  })  : assert((icon ?? label) != null, 'one of icon and label must be non-null'),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FancyButtonState();
  }
}

/// State for a fancy button.
class _FancyButtonState extends State<FancyButton> {
  /// Called when the highlight state of the button ink well changes. This is
  /// used to drive the touch-down and touch-up events of the fancy button.
  void _onInkWellHighlightChanged(bool value) {
    if (value) {
      if (widget.onTouchDown != null) {
        widget.onTouchDown();
      }
    } else {
      if (widget.onTouchUp != null) {
        widget.onTouchUp();
      }
    }
  }

  /// Called when the button ink well is tapped. This is used to drive the
  /// pressed event of the fancy button. Also, by supplying an internal callback
  /// for the ink well's tap event, the ink well is permanently enabled
  /// regardless of the user's choice to supply a pressed callback to the fancy
  /// button.
  void _onInkWellTap() {
    if (widget.onPressed != null) {
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = widget.backgroundColor ?? theme.accentColor;
    final fg = widget.foregroundColor ?? theme.accentIconTheme.color;

    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 56.0, height: 56.0),
      child: Material(
        color: bg,
        elevation: 6.0,
        shape: const CircleBorder(),
        type: MaterialType.button,
        textStyle: theme.accentTextTheme.button.copyWith(
          color: fg,
          letterSpacing: 1.2,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onHighlightChanged: _onInkWellHighlightChanged,
          onTap: _onInkWellTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconTheme.merge(
                data: theme.accentIconTheme.copyWith(color: fg),
                child: Container(child: widget.icon),
              ),
              Container(child: widget.label),
            ],
          ),
        ),
      ),
    );
  }
}

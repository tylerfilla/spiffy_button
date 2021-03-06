/*
 * Spiffy Button
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

library spiffy_button;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// The pose of a spiffy button.
enum SpiffyButtonPose {
  /// The button is shown, and only its icon is visible.
  shownIcon,

  /// The button is shown in mini size, and only its icon is visible.
  shownIconMini,

  /// The button is shown, and only its text label is visible.
  shownLabel,

  /// The button is shown, and its icon and text label are visible.
  shownIconAndLabel,
}

/// A spiffy button :)
///
/// This is a custom implementation of Material Design's floating action button
/// (FAB) with better support for its spiffy animations between states than the
/// built-in [FloatingActionButton] implementation.
class SpiffyButton extends StatefulWidget {
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

  /// The initial elevation.
  ///
  /// By default, this is 6.0.
  final double initialElevation;

  /// The raised elevation.
  ///
  /// By default, this is 12.0.
  final double raisedElevation;

  /// Whether to raise the button on touch.
  ///
  /// By default, this is true.
  final bool raiseOnTouch;

  /// The initial pose.
  ///
  /// By default, this is [SpiffyButtonPose.shownIcon].
  final SpiffyButtonPose initialPose;

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

  /// The button animation curve.
  ///
  /// This is used to animate between poses. By default, this is [Curves.fastOutSlowIn]
  final Curve curve;

  SpiffyButton({
    Key key,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.label,
    this.initialElevation = 6.0,
    this.raisedElevation = 12.0,
    this.raiseOnTouch = true,
    this.initialPose = SpiffyButtonPose.shownIcon,
    this.onPressed,
    this.onTouchDown,
    this.onTouchUp,
    this.curve = Curves.fastOutSlowIn,
  })  : assert((icon ?? label) != null, 'one of icon and label must be non-null'),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SpiffyButtonState();
  }
}

/// State and control for a spiffy button.
class SpiffyButtonState extends State<SpiffyButton> with TickerProviderStateMixin {
  /// The elevation animation controller.
  AnimationController _elevationAnimation;

  /// The current elevation
  double _elevationCurrent;

  /// The previous elevation.
  double _elevationPrevious;

  /// The pose animation controller.
  AnimationController _poseAnimation;

  /// The current pose.
  SpiffyButtonPose _poseCurrent;

  /// The previous pose.
  SpiffyButtonPose _posePrevious;

  @override
  void initState() {
    super.initState();

    // Initialize elevation animation
    _elevationAnimation = AnimationController(
      vsync: this,
      // TODO: Break this out
      duration: kThemeChangeDuration,
    )..addListener(() => setState(() {}));

    // Initialize elevation
    // Fake a completed elevation animation
    setState(() {
      _elevationAnimation.value = 1;
      _elevationCurrent = widget.initialElevation;
      _elevationPrevious = 0;
    });

    // Initialize pose animation
    _poseAnimation = AnimationController(
      vsync: this,
      // TODO: Eventually, we might want to break this out
      duration: kThemeChangeDuration,
    )..addListener(() => setState(() {}));

    // Fudge a completed transition to the initial pose
    setState(() {
      _poseAnimation.value = 1;
      _poseCurrent = widget.initialPose;
      _posePrevious = SpiffyButtonPose.shownIconAndLabel;
    });
  }

  @override
  void dispose() {
    _elevationAnimation.dispose();
    _poseAnimation.dispose();

    super.dispose();
  }

  /// Get the current elevation.
  get elevation => _elevationCurrent;

  /// Set the current elevation.
  set elevation(double elevation) {
    // If this elevation is already current, do nothing
    if (elevation == _elevationCurrent) return;

    // Update elevation state
    setState(() {
      _elevationPrevious = _elevationCurrent;
      _elevationCurrent = elevation;
    });

    // Start the elevation animation
    _elevationAnimation.forward(from: 0);
  }

  /// Get the current pose.
  get pose => _poseCurrent;

  /// Set the current pose.
  set pose(SpiffyButtonPose pose) {
    // If this pose is already current, do nothing
    if (pose == _poseCurrent) return;

    // Update pose state
    setState(() {
      _posePrevious = _poseCurrent;
      _poseCurrent = pose;
    });

    // Start the transition animation
    _poseAnimation.forward(from: 0);
  }

  /// Called when the highlight state of the button ink well changes. This is
  /// used to drive the touch-down and touch-up events of the spiffy button.
  void _onInkWellHighlightChanged(bool value) {
    if (value) {
      // Raise the button on touch (if desired)
      if (widget.raiseOnTouch) {
        elevation = widget.raisedElevation;
      }

      // Fire off user touch down callback
      if (widget.onTouchDown != null) {
        widget.onTouchDown();
      }
    } else {
      // Lower the button back down (if desired)
      if (widget.raiseOnTouch) {
        elevation = widget.initialElevation;
      }

      // Fire off user touch up callback
      if (widget.onTouchUp != null) {
        widget.onTouchUp();
      }
    }
  }

  /// Called when the button ink well is tapped. This is used to drive the
  /// pressed event of the spiffy button. Also, by supplying an internal
  /// callback for the ink well's tap event, the ink well is permanently enabled
  /// regardless of the user's choice to supply a pressed callback to the spiffy
  /// button.
  void _onInkWellTap() {
    if (widget.onPressed != null) {
      widget.onPressed();
    }
  }

  /// Tween over the given range for the current pose animation value.
  double _tweenPose(double begin, double end) {
    return (end - begin) * widget.curve.transform(_poseAnimation.value) + begin;
  }

  /// Compute the minimum width constraint.
  double _computeMinWidth() {
    switch (_posePrevious) {
      case SpiffyButtonPose.shownIcon:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: No change in pose
            return 56.0;
          case SpiffyButtonPose.shownIconMini:
            // Tween from 56.0 to 40.0
            return _tweenPose(56.0, 40.0);
          case SpiffyButtonPose.shownLabel:
            // Tween from 56.0 to 48.0
            return _tweenPose(56.0, 48.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 56.0 to 48.0
            return _tweenPose(56.0, 48.0);
        }
        break;
      case SpiffyButtonPose.shownIconMini:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 40.0 to 56.0
            return _tweenPose(40.0, 56.0);
          case SpiffyButtonPose.shownIconMini:
            // Invariant: No change in pose
            return 40.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 40.0 to 48.0
            return _tweenPose(40.0, 48.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 40.0 to 48.0
            return _tweenPose(40.0, 48.0);
        }
        break;
      case SpiffyButtonPose.shownLabel:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 48.0 to 56.0
            return _tweenPose(48.0, 56.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 48.0 to 40.0
            return _tweenPose(48.0, 40.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: No change in pose
            return 48.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: The minimum width remains constant
            return 48.0;
        }
        break;
      case SpiffyButtonPose.shownIconAndLabel:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 48.0 to 56.0
            return _tweenPose(48.0, 56.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 48.0 to 40.0
            return _tweenPose(48.0, 40.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: The minimum width remains constant
            return 48.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: No change in pose
            return 48.0;
        }
    }

    return 0;
  }

  /// Compute the maximum width constraint.
  double _computeMaxWidth() {
    // Invariant: The max width remains unconstrained
    return double.infinity;
  }

  /// Compute the minimum height constraint.
  double _computeMinHeight() {
    switch (_posePrevious) {
      case SpiffyButtonPose.shownIcon:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: No change in pose
            return 56.0;
          case SpiffyButtonPose.shownIconMini:
            // Tween from 56.0 to 40.0
            return _tweenPose(56.0, 40.0);
          case SpiffyButtonPose.shownLabel:
            // Tween from 56.0 to 48.0
            return _tweenPose(56.0, 48.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 56.0 to 48.0
            return _tweenPose(56.0, 48.0);
        }
        break;
      case SpiffyButtonPose.shownIconMini:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 40.0 to 56.0
            return _tweenPose(40.0, 56.0);
          case SpiffyButtonPose.shownIconMini:
            // Invariant: No change in pose
            return 40.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 40.0 to 48.0
            return _tweenPose(40.0, 48.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 40.0 to 48.0
            return _tweenPose(40.0, 48.0);
        }
        break;
      case SpiffyButtonPose.shownLabel:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 48.0 to 56.0
            return _tweenPose(48.0, 56.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 48.0 to 40.0
            return _tweenPose(48.0, 40.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: No change in pose
            return 48.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: The minimum height remains constant
            return 48.0;
        }
        break;
      case SpiffyButtonPose.shownIconAndLabel:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 48.0 to 56.0
            return _tweenPose(48.0, 56.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 48.0 to 40.0
            return _tweenPose(48.0, 40.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: The minimum height remains constant
            return 48.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: No change in pose
            return 48.0;
        }
    }

    return 0;
  }

  /// Compute the maximum height constraint.
  double _computeMaxHeight() {
    switch (_posePrevious) {
      case SpiffyButtonPose.shownIcon:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: No change in pose
            return 56.0;
          case SpiffyButtonPose.shownIconMini:
            // Tween from 56.0 to 40.0
            return _tweenPose(56.0, 40.0);
          case SpiffyButtonPose.shownLabel:
            // Tween from 56.0 to 48.0
            return _tweenPose(56.0, 48.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 56.0 to 48.0
            return _tweenPose(56.0, 48.0);
        }
        break;
      case SpiffyButtonPose.shownIconMini:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 40.0 to 56.0
            return _tweenPose(40.0, 56.0);
          case SpiffyButtonPose.shownIconMini:
            // Invariant: No change in pose
            return 40.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 40.0 to 48.0
            return _tweenPose(40.0, 48.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 40.0 to 48.0
            return _tweenPose(40.0, 48.0);
        }
        break;
      case SpiffyButtonPose.shownLabel:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 48.0 to 56.0
            return _tweenPose(48.0, 56.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 48.0 to 40.0
            return _tweenPose(48.0, 40.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: No change in pose
            return 48.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: The maximum height remains constant
            return 48.0;
        }
        break;
      case SpiffyButtonPose.shownIconAndLabel:
        switch (_poseCurrent) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 48.0 to 56.0
            return _tweenPose(48.0, 56.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 48.0 to 40.0
            return _tweenPose(48.0, 40.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: The maximum height remains constant
            return 48.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: No change in pose
            return 48.0;
        }
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = widget.backgroundColor ?? theme.accentColor;
    final fg = widget.foregroundColor ?? theme.accentIconTheme.color;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: _computeMinWidth(),
        maxWidth: _computeMaxWidth(),
        minHeight: _computeMinHeight(),
        maxHeight: _computeMaxHeight(),
      ),
      child: Material(
        color: bg,
        animationDuration: Duration.zero,
        elevation: Tween(begin: _elevationPrevious, end: _elevationCurrent)
            .transform(widget.curve.transform(_elevationAnimation.value)),
        shape: const StadiumBorder(),
        type: MaterialType.button,
        textStyle: theme.accentTextTheme.button.copyWith(
          color: fg,
          // TODO: Break out
          letterSpacing: 1.2,
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onHighlightChanged: _onInkWellHighlightChanged,
          onTap: _onInkWellTap,
          child: ClipPath(
            clipper: const ShapeBorderClipper(shape: StadiumBorder()),
            child: SpiffyButtonCore(
              icon: widget.icon == null
                  ? null
                  : IconTheme.merge(
                      data: theme.accentIconTheme.copyWith(color: fg),
                      child: widget.icon,
                    ),
              label: widget.label,
              toPose: _poseCurrent,
              fromPose: _posePrevious,
              progress: _poseAnimation.value,
              curve: widget.curve,
            ),
          ),
        ),
      ),
    );
  }
}

/// The core of a spiffy button.
///
/// This widget combines the icon and label of a Material Design-style floating
/// action button (FAB) into a single "core" evaluated at an instant in time.
/// Transitions involving complex icon-label interactions for different combos
/// of leading/lagging poses are processed by this widget using a collection of
/// independent tweens solved at a single, given progress value.
///
/// When creating this widget, pass in the from (lagging) and to (leading) poses
/// in the current transition, if applicable, as well as the progress (from zero
/// to one, inclusive) of the transition. If no transition is in progress, pass
/// in a progress of zero and ignore the from (lagging) pose. Consequently, the
/// from (lagging) pose is optional. The core widget will solve for the given
/// progress between the two given poses (or, degenerately, the one given pose).
///
/// The core has two user-facing children:
///   - Icon widget
///   - Label widget
///
/// These are both widgets supplied to the core constructor.
///
/// The core layout thus has five abstract regions that influence its visuals:
///   - Padding
///   - Icon widget
///   - Padding
///   - Label widget
///   - Padding
///
/// These three regions of padding are not represented by physical widgets, but
/// they are animated during pose transitions all the same.
///
/// For implementation's sake, the center padding is split into six concrete
/// elements yielding the following layout:
///   - Padding A
///   - Icon widget
///   - Padding B
///   - Padding C
///   - Label widget
///   - Padding D
///
/// This differentiation between paddings B and C is hopefully not perceptible
/// for the end user (although, with a nonlinear motion curve, there *is* a
/// difference...but it's small :). Anyway, it helps us make another logical
/// leap to further divide and conquer the animation problem...
///
/// These six concrete elements of the layout are then split into two groups:
///   - Group 1
///     - Padding A
///     - Icon widget
///     - Padding B
///   - Group 2
///     - Padding C
///     - Label widget
///     - Padding D
///
/// This split establishes a semantic boundary between the icon, its padding,
/// the label, and the label's padding. This makes animating in/out either the
/// icon or the widget, with its respective padding, pretty easy.
class SpiffyButtonCore extends StatelessWidget {
  /// The button icon.
  ///
  /// At least one of [icon] and [label] must be non-null.
  final Widget icon;

  /// The button label.
  ///
  /// At least one of [icon] and [label] must be non-null.
  final Widget label;

  /// The leading pose in the current transition.
  final SpiffyButtonPose toPose;

  /// The lagging pose in the current transition.
  ///
  /// This is ignored if, and only if, progress is zero.
  final SpiffyButtonPose fromPose;

  /// The progress of the current transition.
  final double progress;

  /// The animation curve for the current transition.
  final Curve curve;

  SpiffyButtonCore({
    Key key,
    this.icon,
    this.label,
    @required this.toPose,
    this.fromPose,
    @required this.progress,
    @required this.curve,
  })  : // Assert one of icon and/or label non-null
        assert((icon ?? label) != null),
        // Assert fromPose non-null when progress > 0
        assert((progress == 0 ? progress : fromPose) != null),
        super(key: key);

  /// Tween over the given range for the current progress.
  double _tweenProgress(double begin, double end) {
    return (end - begin) * curve.transform(progress) + begin;
  }

  /// Compute the width factor of group 1.
  double _computeWidthFactor1() {
    switch (fromPose) {
      case SpiffyButtonPose.shownIcon:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: No change in pose
            return 1.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: The icon remains visible
            return 1.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: The icon remains visible
            return 1.0;
        }
        break;
      case SpiffyButtonPose.shownIconMini:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: The icon remains visible
            return 1.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: No change in pose
            return 1.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: The icon remains visible
            return 1.0;
        }
        break;
      case SpiffyButtonPose.shownLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
        }
        break;
      case SpiffyButtonPose.shownIconAndLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: The icon remains visible
            return 1.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: The icon remains visible
            return 1.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: No change in pose
            return 1.0;
        }
    }

    return 0;
  }

  /// Compute the width factor of group 2.
  double _computeWidthFactor2() {
    switch (fromPose) {
      case SpiffyButtonPose.shownIcon:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: The label remains invisible
            return 0.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
        }
        break;
      case SpiffyButtonPose.shownIconMini:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: The label remains invisible
            return 0.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
        }
        break;
      case SpiffyButtonPose.shownLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: No change in pose
            return 1.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: The label remains visible
            return 1.0;
        }
        break;
      case SpiffyButtonPose.shownIconAndLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: The label remains visible
            return 1.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: No change in pose
            return 1.0;
        }
    }

    return 0;
  }

  /// Compute the opacity of group 1.
  double _computeOpacity1() {
    switch (fromPose) {
      case SpiffyButtonPose.shownIcon:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: No change in pose
            return 1.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: The icon remains visible
            return 1.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: The icon remains visible
            return 1.0;
        }
        break;
      case SpiffyButtonPose.shownIconMini:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: The icon remains visible
            return 1.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: No change in pose
            return 1.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: The icon remains visible
            return 1.0;
        }
        break;
      case SpiffyButtonPose.shownLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
        }
        break;
      case SpiffyButtonPose.shownIconAndLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: The icon remains visible
            return 1.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: The icon remains visible
            return 1.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: No change in pose
            return 1.0;
        }
    }

    return 0;
  }

  /// Compute the opacity of group 2.
  double _computeOpacity2() {
    switch (fromPose) {
      case SpiffyButtonPose.shownIcon:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: The label remains invisible
            return 0.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
        }
        break;
      case SpiffyButtonPose.shownIconMini:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: The label remains invisible
            return 0.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 1.0
            return _tweenProgress(0.0, 1.0);
        }
        break;
      case SpiffyButtonPose.shownLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: No change in pose
            return 1.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: The label remains visible
            return 1.0;
        }
        break;
      case SpiffyButtonPose.shownIconAndLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 1.0 to 0.0
            return _tweenProgress(1.0, 0.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: The label remains visible
            return 1.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: No change in pose
            return 1.0;
        }
    }

    return 0;
  }

  /// Compute padding A.
  double _computePaddingA() {
    switch (fromPose) {
      case SpiffyButtonPose.shownIcon:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: No change in pose
            return 16.0;
          case SpiffyButtonPose.shownIconMini:
            // Tween from 16.0 to 8.0
            return _tweenProgress(16.0, 8.0);
          case SpiffyButtonPose.shownLabel:
            // Tween from 16.0 to 0.0
            return _tweenProgress(16.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 16.0 to 12.0
            return _tweenProgress(16.0, 12.0);
        }
        break;
      case SpiffyButtonPose.shownIconMini:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 8.0 to 16.0
            return _tweenProgress(8.0, 16.0);
          case SpiffyButtonPose.shownIconMini:
            // Invariant: No change in pose
            return 8.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 8.0 to 0.0
            return _tweenProgress(8.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 8.0 to 12.0
            return _tweenProgress(8.0, 12.0);
        }
        break;
      case SpiffyButtonPose.shownLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 0.0 to 16.0
            return _tweenProgress(0.0, 16.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 0.0 to 8.0
            return _tweenProgress(0.0, 8.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 12.0
            return _tweenProgress(0.0, 12.0);
        }
        break;
      case SpiffyButtonPose.shownIconAndLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 12.0 to 16.0
            return _tweenProgress(12.0, 16.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 12.0 to 8.0
            return _tweenProgress(12.0, 8.0);
          case SpiffyButtonPose.shownLabel:
            // Tween from 12.0 to 0.0
            return _tweenProgress(12.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: No change in pose
            return 12.0;
        }
    }

    return 0;
  }

  /// Compute padding B.
  double _computePaddingB() {
    switch (fromPose) {
      case SpiffyButtonPose.shownIcon:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: No change in pose
            return 16.0;
          case SpiffyButtonPose.shownIconMini:
            // Tween from 16.0 to 8.0
            return _tweenProgress(16.0, 8.0);
          case SpiffyButtonPose.shownLabel:
            // Tween from 16.0 to 0.0
            return _tweenProgress(16.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 16.0 to 6.0
            return _tweenProgress(16.0, 6.0);
        }
        break;
      case SpiffyButtonPose.shownIconMini:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 8.0 to 16.0
            return _tweenProgress(8.0, 16.0);
          case SpiffyButtonPose.shownIconMini:
            // Invariant: No change in pose
            return 8.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 8.0 to 0.0
            return _tweenProgress(8.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 8.0 to 6.0
            return _tweenProgress(8.0, 6.0);
        }
        break;
      case SpiffyButtonPose.shownLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 0.0 to 16.0
            return _tweenProgress(0.0, 16.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 0.0 to 8.0
            return _tweenProgress(0.0, 8.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 6.0
            return _tweenProgress(0.0, 6.0);
        }
        break;
      case SpiffyButtonPose.shownIconAndLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 6.0 to 16.0
            return _tweenProgress(6.0, 16.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 6.0 to 8.0
            return _tweenProgress(6.0, 8.0);
          case SpiffyButtonPose.shownLabel:
            // Tween from 6.0 to 0.0
            return _tweenProgress(6.0, 0.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: No change in pose
            return 6.0;
        }
    }

    return 0;
  }

  /// Compute padding C.
  double _computePaddingC() {
    switch (fromPose) {
      case SpiffyButtonPose.shownIcon:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: Padding C remains constant
            return 0.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 0.0 to 20.0
            return _tweenProgress(0.0, 20.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 6.0
            return _tweenProgress(0.0, 6.0);
        }
        break;
      case SpiffyButtonPose.shownIconMini:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: Padding C remains constant
            return 0.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 0.0 to 20.0
            return _tweenProgress(0.0, 20.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 6.0
            return _tweenProgress(0.0, 6.0);
        }
        break;
      case SpiffyButtonPose.shownLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 20.0 to 0.0
            return _tweenProgress(20.0, 0.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 20.0 to 0.0
            return _tweenProgress(20.0, 0.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: No change in pose
            return 20.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 20.0 to 6.0
            return _tweenProgress(20.0, 6.0);
        }
        break;
      case SpiffyButtonPose.shownIconAndLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 6.0 to 0.0
            return _tweenProgress(6.0, 0.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 6.0 to 0.0
            return _tweenProgress(6.0, 0.0);
          case SpiffyButtonPose.shownLabel:
            // Tween from 6.0 to 20.0
            return _tweenProgress(6.0, 20.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: No change in pose
            return 6.0;
        }
    }

    return 0;
  }

  /// Compute padding D.
  double _computePaddingD() {
    switch (fromPose) {
      case SpiffyButtonPose.shownIcon:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: Padding D remains constant
            return 0.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 0.0 to 20.0
            return _tweenProgress(0.0, 20.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 20.0
            return _tweenProgress(0.0, 20.0);
        }
        break;
      case SpiffyButtonPose.shownIconMini:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Invariant: Padding D remains constant
            return 0.0;
          case SpiffyButtonPose.shownIconMini:
            // Invariant: No change in pose
            return 0.0;
          case SpiffyButtonPose.shownLabel:
            // Tween from 0.0 to 20.0
            return _tweenProgress(0.0, 20.0);
          case SpiffyButtonPose.shownIconAndLabel:
            // Tween from 0.0 to 20.0
            return _tweenProgress(0.0, 20.0);
        }
        break;
      case SpiffyButtonPose.shownLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 20.0 to 0.0
            return _tweenProgress(20.0, 0.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 20.0 to 0.0
            return _tweenProgress(20.0, 0.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: No change in pose
            return 20.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: Padding D remains constant
            return 20.0;
        }
        break;
      case SpiffyButtonPose.shownIconAndLabel:
        switch (toPose) {
          case SpiffyButtonPose.shownIcon:
            // Tween from 20.0 to 0.0
            return _tweenProgress(20.0, 0.0);
          case SpiffyButtonPose.shownIconMini:
            // Tween from 20.0 to 0.0
            return _tweenProgress(20.0, 0.0);
          case SpiffyButtonPose.shownLabel:
            // Invariant: Padding D remains constant
            return 20.0;
          case SpiffyButtonPose.shownIconAndLabel:
            // Invariant: No change in pose
            return 20.0;
        }
    }

    return 0;
  }

  /// Build the group 1 widget.
  Widget _buildGroup1() {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      widthFactor: _computeWidthFactor1(),
      child: Container(
        padding: EdgeInsets.only(
          left: _computePaddingA(),
          right: _computePaddingB(),
        ),
        child: _Opacity(
          opacity: _computeOpacity1(),
          child: icon,
        ),
      ),
    );
  }

  /// Build the group 2 widget.
  Widget _buildGroup2() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: _computeWidthFactor2(),
      child: Container(
        padding: EdgeInsets.only(
          left: _computePaddingC(),
          right: _computePaddingD(),
        ),
        child: _Opacity(
          opacity: _computeOpacity2(),
          child: label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildGroup1(),
        _buildGroup2(),
      ],
    );
  }
}

/// A spiffy button menu.
///
/// This attempts to implement the "related actions" popup menu concept for
/// Material Design floating action buttons (FABs). To use this, make one and
/// push it onto your [Navigator].
///
/// An instance of this route needs to take a reference to your spiffy button's
/// state in order to communicate with it. For now, this can be obtained via a
/// [GlobalKey] passed to the spiffy button's "key" parameter.
///
/// TODO: Test the constructor parameters and some pixel colors
class SpiffyButtonMenuRoute extends PopupRoute {
  /// The spiffy button state. This is required for communication with the
  /// spiffy button to coordinate animations and poses. For now, this can be
  /// obtained via a [GlobalKey] passed to the spiffy button's "key" parameter.
  /// They say global keys are relatively heavy, but then again FABs should be
  /// used sparingly to begin with.
  final SpiffyButtonState buttonState;

  /// The color of the scrim.
  ///
  /// By default, this is [Colors.black45]
  final Color scrimColor;

  /// Whether or not the scrim is dismissable.
  ///
  /// By default, this is true.
  final bool scrimDismissable;

  /// The accessibility description for the scrim. This may be read aloud by
  /// text-to-speech software to tell the user they must first dismiss the scrim
  /// to interact with other app widgets.
  ///
  /// By default, this is the English text "Close the menu."
  final String scrimContentDescription;

  /// Duration of the popup transition.
  ///
  /// By default, this is [kThemeChangeDuration].
  final Duration popupDuration;

  SpiffyButtonMenuRoute({
    @required this.buttonState,
    this.scrimColor = Colors.black45,
    this.scrimDismissable = true,
    this.scrimContentDescription = 'Close the menu.',
    this.popupDuration = kThemeChangeDuration,
  }) : assert(buttonState != null);

  @override
  get barrierColor => scrimColor;

  @override
  get barrierDismissible => scrimDismissable;

  @override
  get barrierLabel => scrimContentDescription;

  @override
  get transitionDuration => popupDuration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Container();
  }
}

/// An opacity widget that doesn't take shortcuts.
class _Opacity extends SingleChildRenderObjectWidget {
  /// The desired opacity value.
  final double opacity;

  _Opacity({
    Key key,
    @required this.opacity,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderOpacity(opacity: opacity);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderOpacity renderObject) {
    renderObject.opacity = opacity;
  }
}

/// An always-compositing opacity render object.
class _RenderOpacity extends RenderProxyBox {
  /// The desired opacity value.
  double _opacity;

  _RenderOpacity({
    double opacity = 1.0,
  }) : _opacity = opacity;

  /// Get the desired opacity value.
  get opacity => _opacity;

  /// Set the desired opacity value.
  set opacity(double opacity) {
    if (opacity == _opacity) return;

    _opacity = opacity;
    markNeedsPaint();
  }

  @override
  get alwaysNeedsCompositing => child != null;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.pushOpacity(offset, (_opacity * 255.0).round(), super.paint);
    }
  }
}

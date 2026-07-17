import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_constants.dart';

/// Shared full-section loading state, used wherever an [AsyncValue.when]
/// (or similar async gate) needs a `loading:` widget for an entire screen
/// or a screen section — e.g. `loading: () => const AppLoadingIndicator()`.
///
/// Renders the brand loading Lottie ([AssetPaths.loadingAnimation]) rather
/// than the default Material [CircularProgressIndicator], so waiting states
/// carry the same minimal, brand-blue motion language as the rest of the
/// app. Not intended for inline/button loading spinners — those stay on
/// [CircularProgressIndicator] (see [AppButton]) since they're small,
/// colored to sit on a filled background, and don't want a Lottie's fixed
/// aspect ratio.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.size = 72});

  /// Side length of the animation's bounding box.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          AssetPaths.loadingAnimation,
          repeat: true,
        ),
      ),
    );
  }
}

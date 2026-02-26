
import 'package:flutter/cupertino.dart';

extension PaddingExtension on Widget {
  Widget withPadding([EdgeInsetsGeometry padding = const EdgeInsets.all(16)]) {
    return Padding(
      padding: padding,
      child: this,
    );
  }
}

extension VisibleIf on Widget {
  Widget visibleIf(bool isVisible) {
    return isVisible ? this : const SizedBox.shrink();
  }
}

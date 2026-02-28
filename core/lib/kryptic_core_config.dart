import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KrypticCore extends InheritedWidget {
  final List<(Locale, String)> localeOptions;
  final ProviderListenable<Locale?> localeProvider;
  final void Function(Locale?) setLocale;

  const KrypticCore({
    super.key,
    required this.localeOptions,
    required this.localeProvider,
    required this.setLocale,
    required super.child,
  });

  static KrypticCore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<KrypticCore>();
    assert(scope != null, 'KrypticCore not found in widget tree. Wrap your app with KrypticCore.');
    return scope!;
  }

  @override
  bool updateShouldNotify(KrypticCore old) => false;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/kryptic_api_config.dart';
import '../../api/kryptic_auth_api.dart';
import '../../gen_l10n/core_localizations.dart';
import '../theme/KrypticColors.dart';
import '../layouts/KrypticBaseScreen.dart';
import '../widgets/KrypticToolbar.dart';
import '../UiExtensions.dart';

const double _authContentWidth = 400;

class ServerScreen extends ConsumerStatefulWidget {
  final String initialUrl;
  final KrypticApiConfig apiConfig;

  const ServerScreen({
    super.key,
    required this.initialUrl,
    required this.apiConfig,
  });

  @override
  ConsumerState<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends ConsumerState<ServerScreen> {
  late TextEditingController serverController;

  String lastServer = '';
  double? serverVersion;
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    serverController = TextEditingController();
    serverController.text = widget.initialUrl;
    serverController.addListener(() {
      if (serverController.text != lastServer) {
        lastServer = serverController.text;
        setState(() {
          serverVersion = null;
        });
      }
    });
  }

  String _normalizeUrl(String url) {
    url = url.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    if (!url.endsWith('/')) {
      url = '$url/';
    }
    return url;
  }

  _checkServer() {
    serverController.text = _normalizeUrl(serverController.text);
    setState(() {
      isChecking = true;
    });
    KrypticAuthApi(serverController.text, widget.apiConfig).getVersion().then((version) {
      setState(() {
        serverVersion = version;
        isChecking = false;
      });
    });
  }

  _continue() {
    Navigator.pop(context, serverController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l = CoreLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final serverOk = serverVersion != null && serverVersion != 0;

    return KrypticBaseScreen(
      toolbar: KrypticToolbar(
        leftButton: ToolbarButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
          tooltip: l.back,
        ),
        title: l.serverLabel,
      ),
      content: Center(
        child: SizedBox(
          width: _authContentWidth,
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 140),
          TextField(
            controller: serverController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: l.serverLabel,
              hintText: l.serverLabel,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                serverVersion == 0
                    ? l.serverNotFound
                    : l.serverVersionLabel(serverVersion.toString()),
              ),
              const SizedBox(width: 8),
              Icon(
                serverVersion == 0 ? Icons.error : Icons.check,
                color: serverVersion == 0
                    ? KrypticColors(isDark).errorColor
                    : KrypticColors(isDark).successColor,
              ),
            ],
          ).visibleIf(serverVersion != null),
          SizedBox(height: 8).visibleIf(serverVersion != null),
          if (isChecking)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ElevatedButton(
            onPressed: isChecking ? null : () => _checkServer(),
            child: Text(l.checkServer),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: serverOk ? () => _continue() : null,
            child: Text(l.continueButton),
          ),
        ],
      ),
      ),
      ),
    );
  }
}

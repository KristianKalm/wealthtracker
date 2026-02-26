import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:kryptic_core/kryptic_core.dart';
import '../../core/api_config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/prefs/WealthtrackerPrefs.dart';
import '../Providers.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  final TextEditingController _endpointController = TextEditingController();
  String _response = '';
  bool _isLoading = false;
  String? _serverUrl;
  String? _username;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final server = await wealthtrackerPrefs.get(PREFS_SERVER);
    final user = await wealthtrackerPrefs.get(PREFS_USER);
    final token = await wealthtrackerPrefs.get(PREFS_TOKEN);

    setState(() {
      _serverUrl = server;
      _username = user;
      _token = token;
    });
  }

  Future<void> _testEndpoint() async {
    if (_serverUrl == null || _username == null || _token == null) {
      setState(() {
        _response = 'Error: Not logged in. Please login first in Sync settings.';
      });
      return;
    }

    String endpoint = _endpointController.text.trim();
    if (endpoint.isEmpty) {
      setState(() {
        _response = 'Error: Please enter an endpoint';
      });
      return;
    }

    // Remove leading slash if present
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }

    setState(() {
      _isLoading = true;
      _response = 'Loading...';
    });

    try {
      final url = Uri.parse('$_serverUrl$endpoint');
      final response = await http.get(
        url,
        headers: authHeaders(wealthtrackerApiConfig, _username!, _token!),
      );

      String formattedResponse = '';
      formattedResponse += 'Status Code: ${response.statusCode}\n\n';
      formattedResponse += 'Headers:\n';
      response.headers.forEach((key, value) {
        formattedResponse += '  $key: $value\n';
      });
      formattedResponse += '\nBody:\n';

      try {
        // Try to pretty print JSON
        final jsonBody = json.decode(response.body);
        const encoder = JsonEncoder.withIndent('  ');
        formattedResponse += encoder.convert(jsonBody);
      } catch (e) {
        // If not JSON, just show the raw body
        formattedResponse += response.body;
      }

      setState(() {
        _response = formattedResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _endpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KrypticBaseScreen(
      toolbar: KrypticToolbar(
        leftButton: ToolbarButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: 'Debug API Tester',
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_serverUrl != null) ...[
            Text(
              'Server: $_serverUrl',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final docsUrl = Uri.parse('${_serverUrl}docs');
                if (await canLaunchUrl(docsUrl)) {
                  await launchUrl(docsUrl, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                'Docs: ${_serverUrl}docs',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (_username != null) ...[
            Text(
              'User: $_username',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _endpointController,
            decoration: const InputDecoration(
              labelText: 'Endpoint',
              hintText: '/usage or usage',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            onSubmitted: (_) => _testEndpoint(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _testEndpoint,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_isLoading ? 'Testing...' : 'Test Endpoint'),
          ),
          const SizedBox(height: 24),
          Text(
            'Response:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _response.isEmpty ? 'No response yet' : _response,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: _response.isEmpty
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

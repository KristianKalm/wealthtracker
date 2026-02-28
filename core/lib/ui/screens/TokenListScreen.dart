import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/token.dart';
import '../../api/kryptic_session_api.dart';
import '../../gen_l10n/core_localizations.dart';
import '../../prefs/kryptic_prefs.dart';
import '../../crypto/pgp_encryption.dart';
import '../layouts/KrypticBaseScreen.dart';
import '../widgets/KrypticToolbar.dart';
import '../views/KrypticSnackbar.dart';

class TokenListScreen extends ConsumerStatefulWidget {
  final ProviderListenable<Future<KrypticSessionApi?>> sessionApiProvider;
  final ProviderListenable<KrypticPrefs> prefsProvider;
  final ProviderListenable<Future<KrypticPgpEncryption>>? pgpProvider;

  const TokenListScreen({
    super.key,
    required this.sessionApiProvider,
    required this.prefsProvider,
    this.pgpProvider,
  });

  @override
  ConsumerState<TokenListScreen> createState() => _TokenListScreenState();
}

class _TokenListScreenState extends ConsumerState<TokenListScreen> {
  List<Token> tokens = [];
  bool isLoading = true;
  String? error;
  String? currentTokenId;

  CoreLocalizations get _l => CoreLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    fetchTokens();
  }

  Future<void> fetchTokens() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prefs = ref.read(widget.prefsProvider);
      final tokenId = await prefs.get(PREFS_TOKEN_ID);
      final api = await ref.read(widget.sessionApiProvider);
      if (api == null) return;
      final response = await api.getTokens();

      if (response.isEmpty) {
        if (mounted) {
          setState(() {
            error = _l.failedToFetchTokens;
            isLoading = false;
          });
        }
        return;
      }

      final tokensResponse = TokensResponse.fromJson(response);
      if (widget.pgpProvider != null) {
        final pgp = await ref.read(widget.pgpProvider!);
        for (final token in tokensResponse.tokens) {
          if (token.name != null && token.name!.isNotEmpty) {
            try {
              token.name = await pgp.decrypt(token.name!);
            } catch (_) {}
          }
        }
      }

      setState(() {
        tokens = tokensResponse.tokens;
        currentTokenId = tokenId;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          error = _l.anErrorOccurred(e.toString());
          isLoading = false;
        });
      }
    }
  }

  String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('MMM d, y h:mm a').format(date);
  }

  Future<void> deleteToken(String tokenId) async {
    try {
      final api = await ref.read(widget.sessionApiProvider);
      if (api == null) return;
      final success = await api.deleteToken(tokenId);

      if (success) {
        if (mounted) {
          KrypticSnackbar.showSuccess(context, _l.tokenDeletedSuccessfully);
        }
        fetchTokens();
      } else {
        if (mounted) {
          KrypticSnackbar.showError(context, _l.failedToDeleteToken);
        }
      }
    } catch (e) {
      if (mounted) {
        KrypticSnackbar.showError(context, _l.anErrorOccurred(e.toString()));
      }
    }
  }

  Future<void> confirmDeleteToken(String tokenId, String? tokenName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l.deleteTokenTitle),
        content: Text(
          _l.deleteTokenConfirm(tokenName ?? _l.thisToken),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(_l.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      deleteToken(tokenId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KrypticBaseScreen(
      toolbar: KrypticToolbar(
        leftButton: ToolbarButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
          tooltip: _l.back,
        ),
        title: _l.tokens,
      ),
      content: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchTokens,
                        child: Text(_l.retry),
                      ),
                    ],
                  ),
                )
              : tokens.isEmpty
                  ? Center(
                      child: Text(
                        _l.noTokensFound,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: tokens.length,
                      itemBuilder: (context, index) {
                        final token = tokens[index];
                        final isCurrent = currentTokenId != null && token.id == currentTokenId;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  token.name ?? _l.unnamedToken,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (isCurrent) ...[
                                  SizedBox(width: 8),
                                  Text(
                                    _l.currentToken,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  _l.tokenCreatedAt(formatTimestamp(token.createdAt)),
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  _l.tokenLastUsedAt(formatTimestamp(token.lastUsedAt)),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            leading: Icon(Icons.key),
                            trailing: isCurrent
                                ? null
                                : IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => confirmDeleteToken(token.id, token.name),
                                    tooltip: _l.delete,
                                  ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
    );
  }
}

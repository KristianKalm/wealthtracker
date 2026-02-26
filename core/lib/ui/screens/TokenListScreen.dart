import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/token.dart';
import '../../api/kryptic_session_api.dart';
import '../../prefs/kryptic_prefs.dart';
import '../../crypto/pgp_encryption.dart';
import '../layouts/KrypticBaseScreen.dart';
import '../widgets/KrypticToolbar.dart';
import '../views/KrypticSnackbar.dart';

class TokenListStrings {
  final String title;
  final String back;
  final String failedToFetchTokens;
  final String Function(String error) anErrorOccurred;
  final String retry;
  final String noTokensFound;
  final String unnamedToken;
  final String currentToken;
  final String Function(String date) tokenCreatedAt;
  final String Function(String date) tokenLastUsedAt;
  final String deleteTokenTitle;
  final String Function(String name) deleteTokenConfirm;
  final String thisToken;
  final String cancel;
  final String delete;
  final String tokenDeletedSuccessfully;
  final String failedToDeleteToken;

  const TokenListStrings({
    required this.title,
    required this.back,
    required this.failedToFetchTokens,
    required this.anErrorOccurred,
    required this.retry,
    required this.noTokensFound,
    required this.unnamedToken,
    required this.currentToken,
    required this.tokenCreatedAt,
    required this.tokenLastUsedAt,
    required this.deleteTokenTitle,
    required this.deleteTokenConfirm,
    required this.thisToken,
    required this.cancel,
    required this.delete,
    required this.tokenDeletedSuccessfully,
    required this.failedToDeleteToken,
  });
}

class TokenListScreen extends ConsumerStatefulWidget {
  final ProviderListenable<Future<KrypticSessionApi?>> sessionApiProvider;
  final ProviderListenable<KrypticPrefs> prefsProvider;
  final ProviderListenable<Future<KrypticPgpEncryption>>? pgpProvider;
  final TokenListStrings strings;

  const TokenListScreen({
    super.key,
    required this.sessionApiProvider,
    required this.prefsProvider,
    this.pgpProvider,
    required this.strings,
  });

  @override
  ConsumerState<TokenListScreen> createState() => _TokenListScreenState();
}

class _TokenListScreenState extends ConsumerState<TokenListScreen> {
  List<Token> tokens = [];
  bool isLoading = true;
  String? error;
  String? currentTokenId;

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
            error = widget.strings.failedToFetchTokens;
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
          error = widget.strings.anErrorOccurred(e.toString());
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
          KrypticSnackbar.showSuccess(context, widget.strings.tokenDeletedSuccessfully);
        }
        fetchTokens();
      } else {
        if (mounted) {
          KrypticSnackbar.showError(context, widget.strings.failedToDeleteToken);
        }
      }
    } catch (e) {
      if (mounted) {
        KrypticSnackbar.showError(context, widget.strings.anErrorOccurred(e.toString()));
      }
    }
  }

  Future<void> confirmDeleteToken(String tokenId, String? tokenName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.strings.deleteTokenTitle),
        content: Text(
          widget.strings.deleteTokenConfirm(tokenName ?? widget.strings.thisToken),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(widget.strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(widget.strings.delete),
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
          tooltip: widget.strings.back,
        ),
        title: widget.strings.title,
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
                        child: Text(widget.strings.retry),
                      ),
                    ],
                  ),
                )
              : tokens.isEmpty
                  ? Center(
                      child: Text(
                        widget.strings.noTokensFound,
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
                                  token.name ?? widget.strings.unnamedToken,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (isCurrent) ...[
                                  SizedBox(width: 8),
                                  Text(
                                    widget.strings.currentToken,
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
                                  widget.strings.tokenCreatedAt(formatTimestamp(token.createdAt)),
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  widget.strings.tokenLastUsedAt(formatTimestamp(token.lastUsedAt)),
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
                                    tooltip: widget.strings.delete,
                                  ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
    );
  }
}

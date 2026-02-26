import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kryptic_core/kryptic_core.dart';
import '../../core/prefs/WealthtrackerPrefs.dart';
import 'package:kryptic_ui/kryptic_ui.dart';
import '../../l10n/l10n.dart';
import '../Providers.dart';

class TokenListScreen extends ConsumerStatefulWidget {
  const TokenListScreen({super.key});

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
      final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
      final tokenId = await wealthtrackerPrefs.get(PREFS_TOKEN_ID);
      final api = await ref.read(wealthtrackerSessionApiProvider.future);
      if (api == null) return;
      final response = await api.getTokens();

      if (response.isEmpty) {
        if (mounted) {
          setState(() {
            error = context.l10n.failedToFetchTokens;
            isLoading = false;
          });
        }
        return;
      }

      final tokensResponse = TokensResponse.fromJson(response);
      final pgp = await ref.read(pgpProvider.future);
      for (final token in tokensResponse.tokens) {
        if (token.name != null && token.name!.isNotEmpty) {
          try {
            token.name = await pgp.decrypt(token.name!);
          } catch (_) {}
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
          error = context.l10n.anErrorOccurred(e.toString());
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
      final api = await ref.read(wealthtrackerSessionApiProvider.future);
      if (api == null) return;
      final success = await api.deleteToken(tokenId);

      if (success) {
        if (mounted) {
          KrypticSnackbar.showSuccess(context, context.l10n.tokenDeletedSuccessfully);
        }
        fetchTokens();
      } else {
        if (mounted) {
          KrypticSnackbar.showError(context, context.l10n.failedToDeleteToken);
        }
      }
    } catch (e) {
      if (mounted) {
        KrypticSnackbar.showError(context, context.l10n.anErrorOccurred(e.toString()));
      }
    }
  }

  Future<void> confirmDeleteToken(String tokenId, String? tokenName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteTokenTitle),
        content: Text(
          context.l10n.deleteTokenConfirm(tokenName ?? context.l10n.thisToken),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(context.l10n.delete),
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
          tooltip: context.l10n.back,
        ),
        title: context.l10n.tokens,
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
                        child: Text(context.l10n.retry),
                      ),
                    ],
                  ),
                )
              : tokens.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.noTokensFound,
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
                            margin: EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text(
                                    token.name ?? context.l10n.unnamedToken,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    SizedBox(width: 8),
                                    Text(
                                      context.l10n.currentToken,
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
                                    context.l10n.tokenCreatedAt(formatTimestamp(token.createdAt)),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    context.l10n.tokenLastUsedAt(formatTimestamp(token.lastUsedAt)),
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
                                      tooltip: context.l10n.delete,
                                    ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
    );
  }
}

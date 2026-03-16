import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../util/logger.dart';
import '../UiConf.dart';
import '../widgets/KrypticToolbar.dart';

class LoggerScreen extends StatefulWidget {
  const LoggerScreen({super.key});

  @override
  State<LoggerScreen> createState() => _LoggerScreenState();
}

class _LoggerScreenState extends State<LoggerScreen> {
  final ScrollController _scrollController = ScrollController();
  List<LogEntry> _entries = [];
  LogLevel? _filterLevel;

  @override
  void initState() {
    super.initState();
    _entries = Logger.entries.toList();
    Logger.addListener(_onNewLog);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    Logger.removeListener(_onNewLog);
    _scrollController.dispose();
    super.dispose();
  }

  void _onNewLog() {
    if (!mounted) return;
    setState(() {
      _entries = Logger.entries.toList();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  List<LogEntry> get _filteredEntries {
    if (_filterLevel == null) return _entries;
    return _entries.where((e) => e.level == _filterLevel).toList();
  }

  Color _levelColor(LogLevel level, bool isDark) {
    switch (level) {
      case LogLevel.debug:
        return isDark ? Colors.grey[400]! : Colors.grey[600]!;
      case LogLevel.info:
        return isDark ? Colors.blue[300]! : Colors.blue[700]!;
      case LogLevel.warn:
        return isDark ? Colors.orange[300]! : Colors.orange[700]!;
      case LogLevel.error:
        return isDark ? Colors.red[300]! : Colors.red[700]!;
    }
  }

  void _copyAll() {
    final text = Logger.exportAll();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }

  void _clearLogs() {
    Logger.clear();
    setState(() => _entries = []);
  }

  Widget _buildFilterChip(String label, LogLevel? level, bool isDark) {
    final selected = _filterLevel == level;
    final chipColor = level == null ? Colors.blueGrey : _levelColor(level, isDark);
    return GestureDetector(
      onTap: () => setState(() => _filterLevel = level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? chipColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? chipColor : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? chipColor : (isDark ? Colors.grey[400]! : Colors.grey[600]!),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredEntries;
    final bgColor = isDark ? Colors.grey[900]! : Colors.grey[50]!;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 76),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Filter chips
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildFilterChip('All', null, isDark),
                            const SizedBox(width: 6),
                            _buildFilterChip('Debug', LogLevel.debug, isDark),
                            const SizedBox(width: 6),
                            _buildFilterChip('Info', LogLevel.info, isDark),
                            const SizedBox(width: 6),
                            _buildFilterChip('Warn', LogLevel.warn, isDark),
                            const SizedBox(width: 6),
                            _buildFilterChip('Error', LogLevel.error, isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${filtered.length} entries${_filterLevel != null ? ' (filtered)' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Log list
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: filtered.isEmpty
                              ? Center(
                                  child: Text(
                                    'No log entries',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final entry = filtered[index];
                                    final color = _levelColor(entry.level, isDark);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.formattedTime,
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 10,
                                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          SizedBox(
                                            width: 14,
                                            child: Text(
                                              entry.levelLabel,
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: color,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: SelectableText(
                                              '${entry.topic}: ${entry.message}',
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 11,
                                                color: isDark
                                                    ? (entry.level == LogLevel.debug
                                                        ? Colors.grey[500]
                                                        : Colors.grey[200])
                                                    : (entry.level == LogLevel.debug
                                                        ? Colors.grey[500]
                                                        : Colors.grey[900]),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          KrypticToolbar(
            leftButton: ToolbarButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
            title: 'Logger',
            rightButtons: [
              ToolbarButton(
                icon: Icons.copy,
                onPressed: _copyAll,
                tooltip: 'Copy all',
              ),
              ToolbarButton(
                icon: Icons.delete_outline,
                onPressed: _clearLogs,
                tooltip: 'Clear',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/logger.dart';

class LogViewerSheet extends StatelessWidget {
  const LogViewerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.terminal_rounded, color: AppTheme.primary),
                const SizedBox(width: 12),
                const Text(
                  'Performance & Debug Logs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Log List
          Expanded(
            child: Obx(() {
              final logs = AppLogger.logs;
              if (logs.isEmpty) {
                return const Center(child: Text('No logs yet.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _LogItem(log: log);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final LogEntry log;
  const _LogItem({required this.log});

  Color _getColor() {
    switch (log.type) {
      case 'ERROR':
        return Colors.red.shade700;
      case 'PERF':
        return Colors.blue.shade700;
      case 'REQUEST':
        return Colors.purple.shade700;
      case 'CACHE':
        return Colors.orange.shade700;
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColor().withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getColor(),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${log.timestamp.hour}:${log.timestamp.minute}:${log.timestamp.second}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            log.message,
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
          ),
          if (log.error != null) ...[
            const SizedBox(height: 4),
            Text(
              'Error: ${log.error}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

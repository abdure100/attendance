import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/offline_sync_service.dart';

/// Banner widget showing sync status and pending items
class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineSyncService>(
      builder: (context, syncService, child) {
        // Set context for accessing FileMakerService
        syncService.setContext(context);
        
        return FutureBuilder<int>(
          future: syncService.getPendingCount(),
          builder: (context, snapshot) {
            final pendingCount = snapshot.data ?? 0;
            
            if (pendingCount == 0) {
              return const SizedBox.shrink();
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.orange.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$pendingCount item${pendingCount != 1 ? 's' : ''} pending sync',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Ensure context is set before syncing
                      syncService.setContext(context);
                      final result = await syncService.syncAll();
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.success
                                  ? 'Synced ${result.successCount} items'
                                  : 'Sync failed: ${result.error ?? "Unknown error"}',
                            ),
                            backgroundColor: result.success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Sync Now',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


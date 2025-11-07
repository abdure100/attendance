import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/stop.dart' as models;
import '../models/client.dart';
import '../services/trip_service.dart';
import '../services/filemaker_service.dart';

/// Stop Sheet screen showing chronological log of all pickups/dropoffs
class StopSheetPage extends StatefulWidget {
  final String tripId;
  
  const StopSheetPage({super.key, required this.tripId});

  @override
  State<StopSheetPage> createState() => _StopSheetPageState();
}

class _StopSheetPageState extends State<StopSheetPage> {
  List<models.Stop> _stops = [];
  final Map<String, Client> _clients = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStops();
  }

  Future<void> _loadStops() async {
    setState(() => _isLoading = true);
    
    try {
      final tripService = Provider.of<TripService>(context, listen: false);
      final fileMakerService = Provider.of<FileMakerService>(context, listen: false);
      
      _stops = await tripService.getTripStops(widget.tripId);
      
      // Load client info for all stops
      final clientIds = _stops.map((s) => s.clientId).toSet();
      for (final clientId in clientIds) {
        try {
          final client = await fileMakerService.getClientById(clientId);
          if (client != null) {
            _clients[clientId] = client;
          }
        } catch (e) {
          print('Error loading client $clientId: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading stops: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Sheet'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stops.isEmpty
              ? Center(
                  child: Text(
                    'No stops recorded',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStops,
                  child: ListView.builder(
                    itemCount: _stops.length,
                    itemBuilder: (context, index) {
                      final stop = _stops[index];
                      final client = _clients[stop.clientId];
                      final clientName = client?.name ?? 'Unknown Client';
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: stop.kind == 'pickup' ? Colors.blue : Colors.green,
                            child: Icon(
                              stop.kind == 'pickup' ? Icons.arrow_upward : Icons.arrow_downward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(clientName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stop.kind == 'pickup' ? 'Pick Up' : 'Drop Off',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (stop.timestamp != null)
                                Text(
                                  DateFormat('MMM dd, yyyy HH:mm').format(stop.timestamp!),
                                ),
                              if (stop.actualAddress != null)
                                Text(
                                  stop.actualAddress!,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              if (stop.accuracy != null)
                                Text(
                                  'Accuracy: ${stop.accuracy!.toStringAsFixed(1)}m',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              if (stop.note != null && stop.note!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Note: ${stop.note}',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditStopDialog(stop),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => _showDeleteStopDialog(stop),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Future<void> _showEditStopDialog(models.Stop stop) async {
    final noteController = TextEditingController(text: stop.note ?? '');
    DateTime? selectedTime = stop.timestamp;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${stop.kind == 'pickup' ? 'Pickup' : 'Dropoff'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Time'),
                subtitle: Text(selectedTime != null 
                    ? DateFormat('MMM dd, yyyy HH:mm').format(selectedTime!)
                    : 'Not set'),
                trailing: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime != null
                          ? TimeOfDay.fromDateTime(selectedTime!)
                          : TimeOfDay.now(),
                    );
                    if (time != null && mounted) {
                      final date = selectedTime ?? DateTime.now();
                      selectedTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      Navigator.pop(context);
                      _showEditStopDialog(stop);
                    }
                  },
                ),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final tripService = Provider.of<TripService>(context, listen: false);
        await tripService.updateStop(
          stopId: stop.id!,
          note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
          timestamp: selectedTime,
        );
        await _loadStops();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stop updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteStopDialog(models.Stop stop) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Stop'),
        content: Text('Are you sure you want to delete this ${stop.kind}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final tripService = Provider.of<TripService>(context, listen: false);
        await tripService.deleteStop(stop.id!);
        await _loadStops();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stop deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}


import 'package:flutter/material.dart';
import '../utils/debug_logger.dart';

class DebugMenu extends StatefulWidget {
  const DebugMenu({super.key});

  @override
  State<DebugMenu> createState() => _DebugMenuState();
}

class _DebugMenuState extends State<DebugMenu> {
  bool _isVisible = false;

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Debug Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleVisibility,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildButton('Delete all local data', () {
                // Implementation would go here
                DebugLogger.info('Delete all local data action triggered');
              }),
              _buildButton('Reset app state', () {
                // Implementation would go here
                DebugLogger.info('Reset app state action triggered');
              }),
              _buildButton('Clear cache', () {
                // Implementation would go here
                DebugLogger.info('Clear cache action triggered');
              }),
              _buildButton('Reload data', () {
                // Implementation would go here
                DebugLogger.info('Reload data action triggered');
              }),
              _buildButton('Toggle debug mode', () {
                // Implementation would go here
                DebugLogger.info('Toggle debug mode action triggered');
              }),
              _buildButton('Show logs', () {
                // Implementation would go here
                DebugLogger.info('Show logs action triggered');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
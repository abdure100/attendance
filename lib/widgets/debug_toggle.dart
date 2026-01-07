import 'package:flutter/material.dart';

class DebugToggle extends StatefulWidget {
  const DebugToggle({super.key});

  @override
  State<DebugToggle> createState() => _DebugToggleState();
}

class _DebugToggleState extends State<DebugToggle> {
  bool _showDebugMenu = false;
  int _tapCount = 0;

  void _handleTap() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 10) {
        _showDebugMenu = true;
        _tapCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showDebugMenu) {
      return const SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Debug Mode Active',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.bug_report,
          size: 24,
          color: Colors.grey,
        ),
      ),
    );
  }
}
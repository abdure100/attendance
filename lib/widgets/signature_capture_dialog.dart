import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

/// Result from signature capture containing Base64 data
class SignatureResult {
  final String base64Data;
  final Uint8List pngBytes;
  
  const SignatureResult({
    required this.base64Data,
    required this.pngBytes,
  });
}

/// Dialog for capturing a signature
/// Returns Base64 encoded PNG signature data, or null if cancelled
class SignatureCaptureDialog extends StatefulWidget {
  final String clientName;
  final String title;
  
  const SignatureCaptureDialog({
    super.key,
    required this.clientName,
    this.title = 'Signature Required',
  });

  @override
  State<SignatureCaptureDialog> createState() => _SignatureCaptureDialogState();
  
  /// Show the signature capture dialog and return Base64 signature data
  static Future<SignatureResult?> show(BuildContext context, {
    required String clientName,
    String title = 'Signature Required',
  }) async {
    return showDialog<SignatureResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SignatureCaptureDialog(
        clientName: clientName,
        title: title,
      ),
    );
  }
}

class _SignatureCaptureDialogState extends State<SignatureCaptureDialog> {
  late SignatureController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<SignatureResult?> _getSignatureBase64() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a signature'),
          backgroundColor: Colors.orange,
        ),
      );
      return null;
    }

    setState(() => _isSaving = true);

    try {
      // Export signature as PNG bytes
      final Uint8List? pngBytes = await _controller.toPngBytes();
      if (pngBytes == null) {
        throw Exception('Failed to export signature');
      }

      // Convert to Base64
      final base64Data = base64Encode(pngBytes);
      
      return SignatureResult(
        base64Data: base64Data,
        pngBytes: pngBytes,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing signature: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client: ${widget.clientName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please sign below to confirm:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _controller.clear(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Clear'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  final result = await _getSignatureBase64();
                  if (result != null && mounted) {
                    Navigator.pop(context, result);
                  }
                },
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirm'),
        ),
      ],
    );
  }
}

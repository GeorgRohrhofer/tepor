import 'package:flutter/material.dart';

class ImportWorldOverlay extends StatelessWidget {
  final VoidCallback onCancel;
  final Future<void> Function() onPick;

  const ImportWorldOverlay({super.key, required this.onCancel, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Import World', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Select a .zip file that contains the Minecraft world folder.'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: onCancel, child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await onPick();
                      },
                      child: const Text('Select ZIP File'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/world.dart';

class EditWorldOverlay extends StatefulWidget {
  final World world;
  final VoidCallback onCancel;
  final void Function(String id, String name, String creator) onSave;

  const EditWorldOverlay({super.key, required this.world, required this.onCancel, required this.onSave});

  @override
  State<EditWorldOverlay> createState() => _EditWorldOverlayState();
}

class _EditWorldOverlayState extends State<EditWorldOverlay> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtl;
  late TextEditingController _creatorCtl;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.world.worldname);
    _creatorCtl = TextEditingController(text: widget.world.creatorname);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _creatorCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Edit World: ${widget.world.worldname}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameCtl,
                          decoration: const InputDecoration(labelText: 'World Name'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Enter a world name' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _creatorCtl,
                          decoration: const InputDecoration(labelText: 'Creator Name'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Enter a creator name' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            widget.onSave(widget.world.id, _nameCtl.text.trim(), _creatorCtl.text.trim());
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

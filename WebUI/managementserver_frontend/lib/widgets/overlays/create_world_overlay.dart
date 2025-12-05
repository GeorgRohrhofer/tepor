import 'package:flutter/material.dart';

class CreateWorldOverlay extends StatefulWidget {
  final VoidCallback onDiscard;
  final void Function(String worldName, String seed, String gamemode) onCreate;

  const CreateWorldOverlay({
    Key? key,
    required this.onDiscard,
    required this.onCreate,
  }) : super(key: key);

  @override
  State<CreateWorldOverlay> createState() => _CreateWorldOverlayState();
}

class _CreateWorldOverlayState extends State<CreateWorldOverlay> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _worldNameController = TextEditingController();
  final TextEditingController _seedController = TextEditingController();
  String _selectedGamemode = 'Survival';

  final List<String> _gamemodes = ['Creative', 'Adventure', 'Spectator', 'Survival'];

  @override
  void dispose() {
    _worldNameController.dispose();
    _seedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar: Logo + title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.grid_on),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Create new World',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // World Name
              TextFormField(
                controller: _worldNameController,
                decoration: const InputDecoration(
                  labelText: 'World Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter a world name' : null,
              ),
              const SizedBox(height: 16),

              // Seed
              TextFormField(
                controller: _seedController,
                decoration: const InputDecoration(
                  labelText: 'Seed',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Gamemode Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGamemode,
                items: _gamemodes
                    .map((mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(mode),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGamemode = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Gamemode',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: widget.onDiscard,
                    icon: const Icon(Icons.close),
                    label: const Text('Discard'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onCreate(
                          _worldNameController.text.trim(),
                          _seedController.text.trim(),
                          _selectedGamemode,
                        );
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModels/settings_viewmodel.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _init = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) {
      context.read<DiscordSettingsViewModel>().load();
      _init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiscordSettingsViewModel>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 40),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 50, top: 100, right: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Discord Chat ID",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 150,
              child: TextFormField(
                controller: vm.discordController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Eine oder mehrere Discord Chat IDs …',
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: vm.isSaving ? null : vm.save,
              icon: vm.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text("Speichern"),
            ),
          ],
        ),
      ),
    );
  }
}

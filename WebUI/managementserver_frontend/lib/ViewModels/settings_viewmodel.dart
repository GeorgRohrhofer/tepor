import 'package:flutter/material.dart';
import '../API/API_UIData.dart';

class DiscordSettingsViewModel extends ChangeNotifier {
  final UiApiService apiService;

  DiscordSettingsViewModel({required this.apiService});

  final TextEditingController discordController = TextEditingController();

  bool isLoading = false;
  bool isSaving = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    final value = await apiService.getDiscordChatId();
    discordController.text = value ?? '';

    isLoading = false;
    notifyListeners();
  }

  Future<void> save() async {
    isSaving = true;
    notifyListeners();

    // Convert textarea content to a List<String>
    final raw = discordController.text.trim();
    final ids = raw
        .split(RegExp(r'[\n,;]+')) // split by newline, comma, or semicolon
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    await apiService.setDiscordIds(ids);

    isSaving = false;
    notifyListeners();
  }

  @override
  void dispose() {
    discordController.dispose();
    super.dispose();
  }
}

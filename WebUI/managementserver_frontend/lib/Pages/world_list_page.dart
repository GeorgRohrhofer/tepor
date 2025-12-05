import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../viewmodels/world_list_viewmodel.dart';

import '../widgets/overlays/create_world_overlay.dart';
import '../widgets/overlays/edit_world_overlay.dart';
import '../widgets/overlays/delete_world_overlay.dart';
import '../widgets/overlays/import_world_overlay.dart';

class WorldListPage extends StatelessWidget {
  const WorldListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorldListViewModel>();
    final user = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome ${user.username}!",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Role: ${user.role}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => vm.showOverlay(WorldOverlay.create),
                      child: const Text("Create New World"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => vm.showOverlay(WorldOverlay.import),
                      child: const Text("Import World"),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          Colors.grey[300],
                        ),
                        columns: const [
                          DataColumn(label: Text("ID")),
                          DataColumn(label: Text("World Name")),
                          DataColumn(label: Text("Creator")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: vm.worlds.map((world) {
                          return DataRow(
                            cells: [
                              DataCell(Text(world.id)),
                              DataCell(Text(world.worldname)),
                              DataCell(Text(world.creatorname)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () =>
                                          vm.showOverlay(WorldOverlay.edit, world),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          vm.showOverlay(WorldOverlay.delete, world),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -----------------------------
          // OVERLAYS
          // -----------------------------
          if (vm.activeOverlay == WorldOverlay.create)
            CreateWorldOverlay(
              onDiscard: vm.closeOverlay,
              onCreate: (name, creator, mode) {
                vm.createWorld(
                  worldname: name,
                  creatorname: creator,
                  worldMode: mode,
                );
                vm.closeOverlay();
              },
            ),

          if (vm.activeOverlay == WorldOverlay.edit && vm.selectedWorld != null)
            EditWorldOverlay(
              world: vm.selectedWorld!,
              onCancel: vm.closeOverlay,
              onSave: (id, name, creator) {
                vm.updateWorld(
                  id: id,
                  worldname: name,
                  creatorname: creator,
                );
                vm.closeOverlay();
              },
            ),

          if (vm.activeOverlay == WorldOverlay.delete && vm.selectedWorld != null)
            DeleteWorldOverlay(
              world: vm.selectedWorld!,
              onCancel: vm.closeOverlay,
              onConfirm: (id) {
                vm.deleteWorld(id);
                vm.closeOverlay();
              },
            ),

          if (vm.activeOverlay == WorldOverlay.import)
            ImportWorldOverlay(
              onCancel: vm.closeOverlay,
              onPick: () async {
                await vm.importWorld();
                vm.closeOverlay();
              },
            ),
        ],
      ),
    );
  }
}

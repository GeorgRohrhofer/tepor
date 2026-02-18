import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ViewModels/world_list_viewmodel.dart';
import '../provider/user_provider.dart';
import '../widgets/overlays/create_world_overlay.dart';
import '../widgets/overlays/delete_world_overlay.dart';

class WorldListPage extends StatelessWidget {
  const WorldListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorldListViewModel>();
    final user = context.watch<UserProvider>();
    final colors = Theme.of(context).colorScheme;

    // Load once after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!vm.isLoading && !vm.worldsSet) {
        vm.loadWorlds();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome ${user.username}!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            Text(
              'Role: ${user.role}',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─────────── ACTION BAR ───────────
                Row(
                  children: [
                    FilledButton(
                      onPressed: () =>
                          vm.showOverlay(WorldOverlay.create),
                      child: const Text('Create New World'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ─────────── CONTENT ───────────
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : vm.worlds.isEmpty
                          ? const Center(
                              child: Text('No worlds available'),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: colors.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    headingRowColor:
                                        WidgetStatePropertyAll(
                                      colors.surfaceContainerHigh,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text('ID')),
                                      DataColumn(label: Text('World Name')),
                                      DataColumn(label: Text('Creator')),
                                      DataColumn(label: Text('Seed')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows: vm.worlds.map((world) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            SizedBox(
                                              width: 250,
                                              child: Text(world.id),
                                            ),
                                          ),
                                          DataCell(
                                            SizedBox(
                                              width: 200,
                                              child:
                                                  Text(world.worldname),
                                            ),
                                          ),
                                          DataCell(
                                            SizedBox(
                                              width: 120,
                                              child: Text(
                                                  world.creatorname),
                                            ),
                                          ),
                                          DataCell(
                                            SizedBox(
                                              width: 120,
                                              child:
                                                  Text(world.worldSeed),
                                            ),
                                          ),
                                          DataCell(
                                            SizedBox(
                                              width: 120,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: colors.error,
                                                ),
                                                onPressed: () => vm
                                                    .showOverlay(
                                                  WorldOverlay.delete,
                                                  world,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),

          // ─────────── CREATE OVERLAY ───────────
          if (vm.activeOverlay == WorldOverlay.create)
            CreateWorldOverlay(
              onDiscard: vm.closeOverlay,
              onCreate: (name, seed, mode) async {
                await vm.createWorld(
                  worldname: name,
                  worldMode: mode,
                  worldSeed: seed,
                );
                vm.closeOverlay();
              },
            ),

          // ─────────── DELETE OVERLAY ───────────
          if (vm.activeOverlay == WorldOverlay.delete &&
              vm.selectedWorld != null)
            DeleteWorldOverlay(
              world: vm.selectedWorld!,
              onCancel: vm.closeOverlay,
              onConfirm: (id) async {
                await vm.deleteWorld(id);
                vm.closeOverlay();
              },
            ),
        ],      
      ),
    );
  }
}
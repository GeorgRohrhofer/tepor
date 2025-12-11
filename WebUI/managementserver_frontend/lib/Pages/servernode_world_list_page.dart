import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/servernode_provider.dart';
import '../viewmodels/world_list_viewmodel.dart';
import '../widgets/overlays/create_world_overlay.dart';
import '../widgets/overlays/edit_world_overlay.dart';
import '../widgets/overlays/delete_world_overlay.dart';

class ServerNodeWorldListPage extends StatelessWidget {
  const ServerNodeWorldListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorldListViewModel>();
    final server = context.watch<ServerNodeProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Worlds of Servernode ${server.servernodes}!",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
                // Buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () => vm.showOverlay(WorldOverlay.create),
                      child: const Text("Create New World"),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),

                const SizedBox(height: 20),

                // Table
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowColor: WidgetStatePropertyAll(const Color.fromARGB(255, 140, 226, 212)),
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('World Name')),
                            DataColumn(label: Text('Creator')),
                            DataColumn(label: Text('WorldSeed')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: vm.worlds.map((world) {
                            return DataRow(
                              cells: [
                                DataCell(SizedBox(width: 250, child: Text(world.id))),
                                DataCell(SizedBox(width: 200, child: Text(world.worldname))),
                                DataCell(SizedBox(width: 120, child: Text(world.creatorname))),
                                DataCell(SizedBox(width: 120, child: Text(world.worldSeed))),
                                DataCell(SizedBox(
                                  width: 150,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => vm.showOverlay(WorldOverlay.edit, world),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => vm.showOverlay(WorldOverlay.delete, world),
                                      ),
                                    ],
                                  ),
                                )),
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

          // -----------------------------
          // OVERLAYS
          // -----------------------------
          if (vm.activeOverlay == WorldOverlay.create)
            CreateWorldOverlay(
              onDiscard: vm.closeOverlay,
              onCreate: (name, seed, mode){
                vm.createWorld(
                  worldname: name,
                  worldMode: mode,
                  worldSeed: seed,
                  context: context,
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
            )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModels/servernode_world_list_viewmodel.dart';

class ServerNodeWorldListPage extends StatefulWidget {
  final String nodeId;

  const ServerNodeWorldListPage({
    super.key,
    required this.nodeId,
  });

  @override
  State<ServerNodeWorldListPage> createState() =>
      _ServerNodeWorldListPageState();
}

class _ServerNodeWorldListPageState
    extends State<ServerNodeWorldListPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ServerWorldListViewModel>()
          .loadWorldsByNode(widget.nodeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServerWorldListViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Text(
          "Worlds of ServerNode ${widget.nodeId}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(
                        colors.surfaceContainerHigh,
                      ),
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('World Name')),
                        DataColumn(label: Text('Creator')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: vm.worlds.map((world) {
                        return DataRow(
                          cells: [
                            DataCell(Text(world.id)),
                            DataCell(Text(world.name)),
                            DataCell(Text(world.ownerId)),
                            DataCell(
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: colors.error,
                                ),
                                onPressed: () async {
                                  final confirmed =
                                      await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title:
                                          const Text("Confirm Delete"),
                                      content: Text(
                                        "Delete world '${world.name}'?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child:
                                              const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child:
                                              const Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    await vm.deleteWorld(world.id);
                                  }
                                },
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
    );
  }
}

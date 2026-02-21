import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModels/servernode_list_viewmodel.dart';
import 'servernode_world_list_page.dart';
import '../ViewModels/servernode_world_list_viewmodel.dart';
import '../API/API_UIData.dart';

class ServerNodeListPage extends StatefulWidget {
  const ServerNodeListPage({super.key});

  @override
  State<ServerNodeListPage> createState() => _ServerNodeListPageState();
}

class _ServerNodeListPageState extends State<ServerNodeListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServerNodeListViewModel>().loadServernodes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServerNodeListViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        toolbarHeight: 70,
        title: const Text(
          "ServerNodes",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(
                      colors.surfaceContainerHigh,
                    ),
                    columns: const [
                      DataColumn(label: Text("ServerNode-ID")),
                      DataColumn(label: Text("CPU")),
                      DataColumn(label: Text("RAM")),
                      DataColumn(label: Text("Action")),
                    ],
                    rows: vm.servernodes.map((node) {
                      return DataRow(
                        cells: [
                          DataCell(Text(node.id)),
                          DataCell(Text(node.cpu.toString())),
                          DataCell(Text(node.ram.toString())),
                          DataCell(
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider(
                                      create: (context) => ServerWorldListViewModel(
                                        apiService: context.read<UiApiService>(),
                                      ),
                                      child: ServerNodeWorldListPage(nodeId: node.id),
                                    ),
                                  ),
                                );
                              },
                              child: const Text("View"),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() {}),
          child: const Icon(Icons.refresh),
      ),
    );
  }
}

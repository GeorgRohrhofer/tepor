import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/servernode_list_viewmodel.dart';
import 'servernode_world_list_page.dart';

class ServerNodeListPage extends StatefulWidget {
  const ServerNodeListPage({super.key});

  @override
  State<ServerNodeListPage> createState() => _ServerNodeListPageState();
}

class _ServerNodeListPageState extends State<ServerNodeListPage> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final vm = Provider.of<ServerNodeListViewModel>(context, listen: false);
      vm.fetchServernodes();
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServerNodeListViewModel>();
    final colors = Theme.of(context).colorScheme;

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        toolbarHeight: 70,
        title: const Text(
          "ServerNodes",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
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
              headingTextStyle: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              columns: const [
                DataColumn(label: Text("ServerNode-ID")),
                DataColumn(label: Text("CPU")),
                DataColumn(label: Text("RAM")),
                DataColumn(label: Text("Netzwerknutzung")),
                DataColumn(label: Text("Disk Usage")),
                DataColumn(label: Text("Action")),
              ],
              rows: vm.servernodes.map((node) {
                return DataRow(
                  cells: [
                    DataCell(Text(node.id)),
                    DataCell(Text(node.cpu)),
                    DataCell(Text(node.ram)),
                    DataCell(Text(node.network)),
                    DataCell(Text(node.disk)),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ServerNodeWorldListPage(nodeId: node.id),
                            ),
                          );
                        },
                        child: const Text("V"),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

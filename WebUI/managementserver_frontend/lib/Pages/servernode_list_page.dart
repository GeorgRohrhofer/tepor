import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/servernode_provider.dart';
import '../provider/user_provider.dart';

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
      Provider.of<ServerNodeProvider>(context, listen: false).loadServerNodes();
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverNodeProvider = context.watch<ServerNodeProvider>();
    final userProvider = context.watch<UserProvider>();

    final colors = Theme.of(context).colorScheme;

    if (serverNodeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome ${userProvider.username}!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface, 
              ),
            ),
            Text(
              "Role: ${userProvider.role}",
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:Container(
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
              rows: serverNodeProvider.servernodes.map((node) {
                return DataRow(
                  color: WidgetStatePropertyAll(colors.surface), // optional row color
                  cells: [
                    DataCell(Text(node.id)),
                    DataCell(Text(node.cpu)),
                    DataCell(Text(node.ram)),
                    DataCell(Text(node.network)),
                    DataCell(Text(node.disk)),
                    DataCell(
                      ElevatedButton(
                        onPressed: () => debugPrint("V pressed for ${node.id}"),
                        child: const Text("V"),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          )
        ),
      ),
    );
  }
}

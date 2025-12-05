import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class ServerNodeListPage extends StatelessWidget {
  const ServerNodeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>(); // <-- WICHTIG!

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome ${user.username}!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Role: ${user.role}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(Colors.grey[300]),
                  columns: const [
                    DataColumn(label: Text("ServerNode-ID")),
                    DataColumn(label: Text("CPU")),
                    DataColumn(label: Text("RAM")),
                    DataColumn(label: Text("Netzwerknutzung")),
                    DataColumn(label: Text("Disk Usage")),
                    DataColumn(label: Text(" ")),
                  ],
                  rows: List.generate(
                    10,
                    (_) => DataRow(
                      cells: [
                        const DataCell(Text("ID - 123345533243252")),
                        const DataCell(Text("90 %")),
                        const DataCell(Text("101%")),
                        const DataCell(Text("U: 25 Mb/s D: 4Mb/s")),
                        const DataCell(Text("R/W: 50 Kb/s\nS: 1Tb / 5Tb")),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              debugPrint("V button pressed!");
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                            ),
                            child: const Text("V"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

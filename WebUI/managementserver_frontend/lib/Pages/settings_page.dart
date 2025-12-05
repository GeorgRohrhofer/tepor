import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
                style: const TextStyle(
                fontSize: 40,
                color: Colors.black
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: EdgeInsets.only(left:50, top:30),
        child: Column(
          children:[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Discord-Bot Chat ID',
                      border: OutlineInputBorder()
                    ),
                    validator: (value) =>
                      (value == null || value.isEmpty) ? 'Enter a Discord Chat ID' : null,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),

            Row(children: [
                TextFormField(

                )
              ],
            )
          ]
        ),
      )
    );
  }
}
import 'package:flutter/material.dart';

class SidebarContent extends StatelessWidget {
  const SidebarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text("Dashboard"),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CompletedPage extends StatefulWidget {
  const CompletedPage({super.key});

  @override
  State<CompletedPage> createState() => _CompletedPageState();
}

class _CompletedPageState extends State<CompletedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Completed"),
        centerTitle: true,
      ),
      body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.list),
                title: Text("Item 1"),
              ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text("Item 2"),
              )
            ],
          )
      ),
    );
  }
}

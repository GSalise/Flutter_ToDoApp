import 'package:flutter/material.dart';
import 'package:todo_app/pages/todo.dart';
import 'package:todo_app/pages/completed.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  final List<Widget> pages = const [
    TodoPage(),
    CompletedPage(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.article),
              icon: Icon(Icons.article_outlined),
              label: 'To Do',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.check_box),
              icon: Icon(Icons.check_box_outlined),
              label: 'Completed',
            ),
          ]
      ),
    );
  }
}




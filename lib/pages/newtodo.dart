import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/notes.dart';
import '../services/database.dart';

class NewToDoPage extends StatefulWidget {
  final Notes? existingNote;
  /*
  Okay apparently in dart, method overloading is not a thing unlike Java,
  so you have to create "named constructors" using the .named constructor syntax
  */
  const NewToDoPage({super.key}) : existingNote = null;

  const NewToDoPage.withNote({super.key, required this.existingNote});

  @override
  State<NewToDoPage> createState() => _NewToDoPageState();
}

class _NewToDoPageState extends State<NewToDoPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New ToDo"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              if(titleController.text.isNotEmpty && contentController.text.isNotEmpty){
                late Notes newNote;
                newNote = Notes().copyWith(
                    title: titleController.text,
                    content: contentController.text,
                    status: Status.pending,
                );

                await Database.db.writeTxn(() async {
                  await Database.db.notes.put(newNote);
                });

                Navigator.pop(context);
              }
            },
          )
        ],
      ),


      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),



            child: Container(
              decoration: BoxDecoration(
                color: Color(0xCCC1C1C1),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Title",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),



          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xCCC1C1C1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: contentController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: "Enter your content here...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )
          )


        ]
      ),
    );
  }

/*

dispose() is a lifecycle method in Flutter that cleans up resources when a
StatefulWidget is removed from the widget tree permanently. Failing to dispose
of controllers, listeners, or streams can lead to:

- Memory leaks (objects stay in memory unnecessarily)
- Performance issues (unnecessary rebuilds, stuck animations)
- Unexpected behavior (old listeners firing after widget removal)

*/

  @override
  void dispose(){
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

}

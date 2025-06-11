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
  late final TextEditingController titleController;
  late final TextEditingController contentController;
  late final Status status;

  /*

  If you need to initialize data before the widget is built, use the initState()

  */

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.existingNote?.title ?? "");
    contentController =
        TextEditingController(text: widget.existingNote?.content ?? "");
    status = widget.existingNote?.status ?? Status.pending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingNote != null ? "Edit ToDo" : "Add new ToDo"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await _addOrEditTodo();
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
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
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


  /*

      Future<void>
      - a dart async type that represents an operation that:
        - will complete at some point in the future
        - will return a value of a specific type (in this case, none)


  */

  Future<void> _addOrEditTodo() async {
    if(titleController.text.isNotEmpty && contentController.text.isNotEmpty){
      final Notes newNote;
      if (widget.existingNote != null){
        print("note exists");
        newNote = widget.existingNote!.copyWith(
          title: titleController.text,
          content: contentController.text,
          status: status,
        );
      }else{
        print("creating new note");
        newNote = Notes().copyWith(
          title: titleController.text,
          content: contentController.text,
          status: status,
        );


      }


      try{

        print("Here is the note: {"
            "id: ${newNote.id}, "
            "title: ${newNote.title}, "
            "content: ${newNote.content}, "
            "status: ${newNote.status}, "
            "createdAt: ${newNote.createdAt}, "
            "updatedAt: ${newNote.updatedAt}"
            "}");
        await Database.db.writeTxn(() async {
          final newId = await Database.db.notes.put(newNote);
          final savedNote = await Database.db.notes.get(newId);
          print("Saved note: ${savedNote?.id}, ${savedNote?.title}, etc...");
        });

        if (mounted) Navigator.pop(context);
      }catch(e){
        print("ERROR HERE: ${e.toString()}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: ${e.toString()}'))
          );
        }
      }
      /*

         => is basically a shorthand syntax for a one-line function

         (mounted) Check
         What:
         - bool property on State classes
         - true = widget is currently in a widget tree
         - false = widget is not in a widget tree
         Why:
         - After await, the user might have closed the screen
         - Calling pop() or showSnackBar() on a disposed widget causes errors
         - Example dangerous scenario:
            - User taps "Save"
            - During slow database operation, user presses back button
            - Screen gets disposed
            - Original save operation completes and tries to interact with dead widgets

         Scaffold Messenger
         - shows a temporary message at the bottom of the screen
     */


    }
  }

}

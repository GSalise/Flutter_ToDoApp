import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo_app/models/enums.dart';
import 'package:todo_app/models/notes.dart';
import 'package:todo_app/pages/newtodo.dart';
import '../services/database.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Notes> notes = <Notes>[];
  StreamSubscription? notesStream;

  @override
  void initState(){
    super.initState();
    notesStream = Database.db.notes
        .buildQuery<Notes>()
        .watch(fireImmediately: true,)
        .listen(
          (data) {
                setState(() {
                  notes = data;
                });
          },
        );
  }

  @override
  void dispose(){
    notesStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To Do"),
        centerTitle: true,
      ),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NewToDoPage()));
          },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildUI() {
    return Padding(
        padding:EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        child: ListView.builder(
            itemCount: notes.length,
            itemBuilder: (content, index) {
              final note = notes[index];
              return Card(


                child: ListTile(


                  contentPadding: EdgeInsets.only(
                    left: 10,
                  ),


                  title: Text(
                    note.title ?? "",
                  ),


                  trailing: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _addOrEditTodo(note: note);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await Database.db.writeTxn(() async {
                              await Database.db.notes.delete(note.id);
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {  },
                        ),
                      ],
                    ),
                  )
                ),
              );
            }
        ),

    );

  }

  void _addOrEditTodo({Notes? note}){
    TextEditingController titleController = TextEditingController(text: note?.title ?? "");
    TextEditingController contentController = TextEditingController(text: note?.content ?? "");
    Status status = note?.status ?? Status.pending;


    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(note != null ? "Edit ToDo" : "Add new ToDo"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [


                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Title",
                  ),
                ),

                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    hintText: "Content",
                  ),
                ),



                DropdownButtonFormField<Status>(
                    value: status,
                    items: Status.values.map(
                            (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.name,
                                ),
                            ),
                    ).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        status = value;
                      });
                    }
                )



              ],
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),

              TextButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                    late Notes newNote;
                    if (note != null){
                      newNote = note.copyWith(
                          title: titleController.text,
                          content: contentController.text,
                          status: status
                      );
                    } else {
                      newNote = Notes().copyWith(
                          title: titleController.text,
                          content: contentController.text,
                          status: status
                      );
                    }

                    await Database.db.writeTxn(() async {
                      await Database.db.notes.put(newNote);
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text("Save"),
              )
            ],
          );
        },
    );
  }
}

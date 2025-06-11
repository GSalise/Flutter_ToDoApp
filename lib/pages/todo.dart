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
    final pendingNotes = notes.where((note) => note.status == Status.pending).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("To Do"),
        centerTitle: true,
      ),
      body: _buildUI(pendingNotes),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NewToDoPage()));
          },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildUI(List<Notes> pendingNotes) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 10,
      ),
      child: ListView.builder(
          itemCount: pendingNotes.length,
          itemBuilder: (content, index) {
            final note = pendingNotes[index];
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
                              /*_addOrEditTodo(note: note);*/
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      NewToDoPage.withNote(
                                          existingNote: note)));
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
                            onPressed: () {
                              _updateStatus(note: note);
                            },
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

  void _updateStatus({required Notes note}) async {
    await Database.db.writeTxn(() async {
      await Database.db.notes.put(note.changeStatus(note.id));
    });
  }



}

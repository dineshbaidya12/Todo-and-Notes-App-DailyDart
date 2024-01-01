// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, must_be_immutable, unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp1/pages/edit_todo.dart';
import 'package:todoapp1/pages/homepage.dart';
import 'dart:convert';

class ViewTodo extends StatefulWidget {
  final Function updateCallback;
  final String id;
  ViewTodo({
    required this.id,
    required this.updateCallback,
  });
  var sharedMemoryName = "Todo";

  @override
  State<ViewTodo> createState() => _ViewTodoState();

  var index = 0;
}

class _ViewTodoState extends State<ViewTodo> {
  List<Map<String, String>> notes = [];
  var sharedMemoryName = "Todo";
  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  //loaddata
  _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notes = prefs
              .getStringList(sharedMemoryName)
              ?.map((note) => Map<String, String>.from(json.decode(note)))
              .where((note) => note['id'] == widget.id)
              .toList() ??
          [];
    });

    if (notes == []) {
      Navigator.pop(context, true);
    }
  }

  // Save notes
  _saveNotes(String sharedMemoryName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesStringList =
        notes.map((note) => json.encode(note)).toList();
    prefs.setStringList(sharedMemoryName, notesStringList);
  }

  // Delete note
  _deleteNote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? todosStringList = prefs.getStringList(sharedMemoryName);

    if (todosStringList != null) {
      todosStringList.removeWhere((todoString) {
        Map<String, dynamic> todo =
            Map<String, dynamic>.from(json.decode(todoString));
        return todo['id'] == widget.id;
      });

      prefs.setStringList(sharedMemoryName, todosStringList);
    }

    Fluttertoast.showToast(
      msg: 'To-Do Deleted Successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromARGB(255, 201, 12, 12),
      textColor: Colors.white,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Container(
        color: Color.fromARGB(255, 255, 240, 179),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 2),
              child: Text(
                '${notes[widget.index]['title']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 10),
              child: Text(
                '${notes[widget.index]['description']}',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),

            // Description

            SizedBox(height: 20.0),
            // Edit and Delete Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTodo(id: widget.id!),
                      ),
                    );

                    if (result == true) {
                      _loadNotes();
                      widget.updateCallback();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 68, 171, 255),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'popins',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    bool deleteConfirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Color.fromARGB(255, 247, 108, 84),
                        title: Text('Delete To-Do?'),
                        content: Text(
                            'Are you sure you want to delete this To-Do: ${notes[widget.index]['title']}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'No',
                              selectionColor: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Yes'),
                          ),
                        ],
                      ),
                    );

                    if (deleteConfirmed == true) {
                      _deleteNote();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 83, 60),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'popins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

AppBar appBar() {
  return AppBar(
    title: const Text(
      'View To-Do',
      style: TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: Color.fromARGB(244, 77, 179, 163),
    centerTitle: true,
    // actions: [
    //   IconButton(
    //     icon: const Icon(Icons.delete),
    //     onPressed: () {},
    //     color: Colors.white,
    //   ),
    // ],
  );
}

// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditTodo extends StatefulWidget {
  final String id;

  EditTodo({required this.id});
  @override
  State<EditTodo> createState() => _EditTodoState();

  var index = 0;
}

class _EditTodoState extends State<EditTodo> {
  List<Map<String, String>> notes = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
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

    if (notes.isEmpty) {
      Navigator.pop(context, true);
      return;
    }

    _titleController.text = notes[0]['title']!;
    _descriptionController.text = notes[0]['description']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Container(
        color: Color.fromARGB(255, 255, 240, 179),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Modify To-Do",
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 2, 85, 117),
              ),
            ),
            SizedBox(height: 8.0),
            TextFormField(
              style: TextStyle(
                fontSize: 14,
              ),
              controller: _titleController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Your To-Do Title',
                labelStyle: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              style: TextStyle(
                fontSize: 14,
              ),
              controller: _descriptionController,
              decoration: InputDecoration(
                  labelText: 'More Details',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                  labelStyle: TextStyle(fontSize: 12)),
              minLines: 1,
              maxLines: 4,
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Align(
                alignment: Alignment.center,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () async {
                    if (_titleController.text.isNotEmpty) {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      List<String>? notesStringList =
                          prefs.getStringList(sharedMemoryName);

                      if (notesStringList != null) {
                        int index = notesStringList.indexWhere((noteString) =>
                            Map<String, dynamic>.from(
                                json.decode(noteString))['id'] ==
                            widget.id);

                        if (index != -1) {
                          // Update the note in the list directly
                          Map<String, dynamic> updatedNote =
                              Map<String, dynamic>.from(
                                  json.decode(notesStringList[index]));
                          updatedNote['title'] = _titleController.text;
                          updatedNote['description'] =
                              _descriptionController.text;

                          // Update the list with the modified note
                          notesStringList[index] = json.encode(updatedNote);

                          // Save the updated list to SharedPreferences
                          prefs.setStringList(
                              sharedMemoryName, notesStringList);

                          Navigator.pop(context, true);

                          Fluttertoast.showToast(
                            msg: 'To-Do Modified',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Color.fromARGB(255, 41, 174, 226),
                            textColor: Colors.white,
                          );
                        }
                      }
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Please Provide To-Do Title',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Color.fromARGB(255, 201, 12, 12),
                        textColor: Colors.white,
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Text(
                      "Update",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

AppBar appBar() {
  return AppBar(
    title: const Text(
      'Modify To-Do',
      style: TextStyle(
        color: Color.fromARGB(255, 70, 70, 70),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: const Color.fromARGB(206, 122, 217, 255),
    centerTitle: true,
  );
}

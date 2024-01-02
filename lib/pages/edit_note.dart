// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditNote extends StatefulWidget {
  final String id;
  final Function updatecallback;
  EditNote({super.key, required this.id, required this.updatecallback});

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  List<Map<String, String>> notes = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  var sharedMemoryName = 'Notes';
  var index = 0;
  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notes = prefs
              .getStringList(sharedMemoryName)
              ?.map((note) => Map<String, String>.from(json.decode(note)))
              .where((note) => note['id'] == widget.id)
              .toList() ??
          [];
      if (notes.isEmpty) {
        Navigator.pop(context, true);
      }
    });
    _titleController.text = notes[index]['title']!;
    _descriptionController.text = notes[index]['description']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Container(
        color: Colors.green.shade100,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Modify Note",
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
                labelText: 'Your Note Title',
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
                          Map<String, dynamic> updatedNote =
                              Map<String, dynamic>.from(
                                  json.decode(notesStringList[index]));
                          updatedNote['title'] = _titleController.text;
                          updatedNote['description'] =
                              _descriptionController.text;

                          // Update the list with the modified note
                          notesStringList[index] = json.encode(updatedNote);

                          prefs.setStringList(
                              sharedMemoryName, notesStringList);

                          Navigator.pop(context, true);

                          Fluttertoast.showToast(
                            msg: 'Notes Modified',
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
                        msg: 'Please Provide Note Title',
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
      'Modify Note',
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

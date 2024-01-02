// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, list_remove_unrelated_type, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp1/pages/edit_note.dart';

class ViewNotes extends StatefulWidget {
  final String id;
  final Function updateCallback;
  const ViewNotes({super.key, required this.id, required this.updateCallback});

  @override
  State<ViewNotes> createState() => _ViewNotesState();
}

class _ViewNotesState extends State<ViewNotes> {
  List<Map<String, String>> notes = [];
  var sharedMemoryName = "Notes";
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
  }

  _deleteNote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? dataStringList = prefs.getStringList(sharedMemoryName);
    if (dataStringList != null) {
      List<String> updatedDataStringList = dataStringList
          .map((item) => Map<String, String>.from(json.decode(item)))
          .where((item) => item['id'] != widget.id)
          .map((item) => json.encode(item))
          .toList();
      prefs.setStringList(sharedMemoryName, updatedDataStringList);
      Navigator.pop(context, true);
      Fluttertoast.showToast(
        msg: 'Note Deleted',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromARGB(255, 201, 12, 12),
        textColor: Colors.white,
      );
    }
  }

  updatecallback() {
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.green.shade100,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "${notes[index]['title']}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "${notes[index]['description']}",
                      style: TextStyle(),
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 10.0, top: 20.0),
                          child: TextButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditNote(
                                      id: widget.id,
                                      updatecallback: updatecallback),
                                ),
                              );

                              if (result) {
                                updatecallback();
                                widget.updateCallback();
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue.shade400,
                              padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            ),
                            child: Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20.0),
                          child: TextButton(
                            onPressed: () async {
                              bool deleteConfirmed = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor:
                                      Color.fromARGB(255, 247, 108, 84),
                                  title: Text('Delete Note?'),
                                  content: Text(
                                      'Are you sure you want to delete this Note: ${notes[index]['title']}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(
                                        'No',
                                        selectionColor: Colors.white,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                              );

                              if (deleteConfirmed == true) {
                                _deleteNote();
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            ),
                            child: Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

AppBar appBar() {
  return AppBar(
    title: const Text(
      'View Note',
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

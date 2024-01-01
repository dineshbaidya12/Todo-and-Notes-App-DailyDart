// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors, unused_local_variable, unused_import, avoid_unnecessary_containers, use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:todoapp1/pages/add_notes.dart';
import 'package:todoapp1/pages/edit_todo.dart';
import 'package:todoapp1/pages/homepage.dart';
import 'package:todoapp1/pages/notes.dart';
import 'package:todoapp1/pages/view_todo.dart';
import 'add_todo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';

class MyNotes extends StatefulWidget {
  const MyNotes({super.key});

  @override
  State<MyNotes> createState() => _MyNotesState();
}

class _MyNotesState extends State<MyNotes> {
  List<Map<String, String>> allNotes = [];
  List<Map<String, String>> notes = [];
  var sharedMemoryName = "Notes";
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void updateNotes() {
    _loadNotes();
  }

  final List<Color> sequenceColors = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.yellow.shade100,
    Colors.green.shade100,
    Colors.pink.shade100,
    Colors.orange.shade100
  ];

  Color getNextColor(int currentIndex) {
    if (currentIndex >= 0 && currentIndex < sequenceColors.length) {
      return sequenceColors[currentIndex];
    } else {
      // If index goes out of bounds, wrap around to the beginning
      return sequenceColors[currentIndex % sequenceColors.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        if (_scaffoldKey.currentState!.isDrawerOpen) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: appBar(context),
        body: Column(
          children: [
            Container(
              height: 200.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/notes_bg.jpg'),
                  opacity: .8,
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      _filterNotes(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Color.fromARGB(255, 207, 242, 255),
                child: notes.isEmpty
                    ? Center(
                        child: Text(
                          "No Notes Available",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(5.0),
                        child: MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  left: 3.0, right: 3.0, top: 5.0, bottom: 5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: getNextColor(index),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notes[index]['title']!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        (notes[index]['description']!.length >
                                                150)
                                            ? '${notes[index]['description']!.substring(0, 150)}...'
                                            : notes[index]['description']!,
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
        drawer: buildDrawer(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNotesNotes()),
            );

            if (result != null) {
              String title = result['title'];
              String description = result['description'];
              _addNote({
                'title': title,
                'description': description,
                'id': Uuid().v4(),
              });
            }
          },
          // ignore: sort_child_properties_last
          child: Icon(Icons.add),
          backgroundColor: const Color.fromARGB(206, 122, 217, 255),
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
          shape: CircleBorder(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

//----------loadnotes note -----//
  _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notes = prefs.getStringList(sharedMemoryName)?.map((note) {
            return Map<String, String>.from(json.decode(note));
          }).toList() ??
          [];
    });
    searchController.text = "";
  }
  //----------loadnotes note -----//

  //------add note ---------//
  // ignore: unused_element
  _addNote(Map<String, String> newNote) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    allNotes = prefs.getStringList(sharedMemoryName)?.map((savedNote) {
          return Map<String, String>.from(json.decode(savedNote));
        }).toList() ??
        [];
    allNotes.add(newNote);
    _saveNotes(sharedMemoryName, allNotes);
    _loadNotes();
    Fluttertoast.showToast(
      msg: 'Note Added Successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromARGB(255, 6, 177, 57),
      textColor: Colors.white,
    );
  }

  //------add note ---------//

  //------dave note note ---------//
  // ignore: unused_element
  _saveNotes(
      String sharedMemoryName, List<Map<String, String>> updatedNotes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesStringList =
        updatedNotes.map((note) => json.encode(note)).toList();
    prefs.setStringList(sharedMemoryName, notesStringList);
  }
  //------add note ---------//

  _filterNotes(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      allNotes = prefs.getStringList(sharedMemoryName)?.map((note) {
            return Map<String, String>.from(json.decode(note));
          }).toList() ??
          [];

      notes = allNotes
          .where((note) =>
              note['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}

Drawer buildDrawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        SizedBox(
          height: 200.0,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/notes-bg2.jpg'),
                opacity: 0.8,
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Notes List",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 53, 53, 53),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.check),
                title: Text(
                  "My To-Do's",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.notes),
                title: Text(
                  'My Notes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyNotes(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

AppBar appBar(BuildContext context) {
  return AppBar(
    title: const Text(
      'Notes',
      style: TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: Color.fromARGB(244, 77, 179, 163),
    centerTitle: true,
    automaticallyImplyLeading: false,
    leading: Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        color: Colors.white,
      ),
    ),
    // actions: [
    //   IconButton(
    //     icon: const Icon(Icons.delete),
    //     onPressed: () {},
    //     color: Colors.white,
    //   ),
    // ],
  );
}

// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors, unused_local_variable, unused_import, avoid_unnecessary_containers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:todoapp1/pages/edit_todo.dart';
import 'package:todoapp1/pages/notes.dart';
import 'package:todoapp1/pages/view_todo.dart';
import 'add_todo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, String>> allNotes = [];
  List<Map<String, String>> notes = [];
  var sharedMemoryName = "Todo";
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void updateNotes() {
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    var ListBgColor = const Color.fromARGB(255, 109, 189, 255);
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
                  image: AssetImage('assets/home_bg.jpg'),
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
                color: Color.fromARGB(255, 255, 240, 179),
                child: notes.isEmpty
                    ? Center(
                        child: Text(
                          "No To-Do Available",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final noteTitle = notes[index]['title'] ?? '';
                          if (noteTitle
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase())) {
                            return Padding(
                              padding: EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewTodo(
                                        id: notes[index]['id']!,
                                        updateCallback: updateNotes,
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    _loadNotes();
                                  }
                                },
                                onLongPress: () async {
                                  bool deleteConfirmed = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor:
                                          Color.fromARGB(255, 247, 108, 84),
                                      title: Text('Delete To-Do?'),
                                      content: Text(
                                          'Are you sure you want to delete this To-Do: ${notes[index]['title']}?'),
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
                                    _deleteNote(notes[index]['id']!);
                                  }
                                },
                                onDoubleTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditTodo(id: notes[index]['id']!),
                                    ),
                                  );

                                  if (result == true) {
                                    _loadNotes();
                                  }

                                  // Handle double tap
                                  // Fluttertoast.showToast(
                                  //   msg: 'Double Tapped: ${notes[index]['title']}',
                                  //   toastLength: Toast.LENGTH_SHORT,
                                  //   gravity: ToastGravity.BOTTOM,
                                  //   timeInSecForIosWeb: 1,
                                  //   backgroundColor: Colors.blue,
                                  //   textColor: Colors.white,
                                  // );
                                },
                                child: Container(
                                  color:
                                      notes[index]['backgroundColor'] == 'red'
                                          ? Colors.red
                                          : ListBgColor,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: notes[index]['status'] == 'done'
                                            ? true
                                            : false,
                                        onChanged: (value) {
                                          if (value != null) {
                                            if (value) {
                                              _updateStatus(
                                                  notes[index]['id'] as String,
                                                  'done');
                                            } else {
                                              _updateStatus(
                                                  notes[index]['id'] as String,
                                                  'working');
                                            }
                                          }
                                        },

                                        // Set the width of the checkbox
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      // Use Expanded to make the Text take up the remaining space
                                      Expanded(
                                        child: Text(
                                          notes[index]['title'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            decoration:
                                                notes[index]['status'] == 'done'
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.arrow_forward_rounded),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewTodo(
                                                id: notes[index]['id']!,
                                                updateCallback: updateNotes,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
              ),
            )
          ],
        ),
        drawer: buildDrawer(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNotes()),
            );

            if (result != null) {
              String title = result['title'];
              String description = result['description'];

              _addNote({
                'title': title,
                'description': description,
                'status': 'working',
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
      msg: 'To-Do Added Successfully',
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

  //----------delete note -----//
  _deleteNote(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    allNotes = prefs.getStringList(sharedMemoryName)?.map((note) {
          return Map<String, String>.from(json.decode(note));
        }).toList() ??
        [];
    int index = allNotes.indexWhere((note) => note['id'] == id);
    if (index != -1) {
      allNotes.removeAt(index);
      _saveNotes(sharedMemoryName, allNotes);
      _filterNotes(searchController.text);
    }

    Fluttertoast.showToast(
      msg: 'To-Do Deleted Successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromARGB(255, 201, 12, 12),
      textColor: Colors.white,
    );
  }
//----------delete note -----//

//-------update note----------//
  _updateStatus(String id, status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      allNotes = prefs.getStringList(sharedMemoryName)?.map((note) {
            return Map<String, String>.from(json.decode(note));
          }).toList() ??
          [];
      int index = allNotes.indexWhere((note) => note['id'] == id);

      if (index != -1) {
        List<String>? notesStringList = prefs.getStringList(sharedMemoryName);
        Map<String, String> updatedNote = Map<String, String>.from(
            json.decode(notesStringList![index]) as Map<String, dynamic>);
        updatedNote['status'] = status;

        notesStringList[index] = json.encode(updatedNote);

        prefs.setStringList(sharedMemoryName, notesStringList);
        allNotes[index] = updatedNote;
        _filterNotes(searchController.text);
      }
    });

    Fluttertoast.showToast(
      msg: 'To-Do Status Updated',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromARGB(255, 6, 177, 57),
      textColor: Colors.white,
    );
  }

//-------update note----------//

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

AppBar appBar(BuildContext context) {
  return AppBar(
    title: const Text(
      'To-Do Lists',
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
                image: AssetImage('assets/todo-bg.jpg'),
                opacity: 0.8,
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "To Do Lists",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(
                        255, 14, 78, 104), // Set the desired text color
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

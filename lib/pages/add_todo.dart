// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, unused_import
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddNotes extends StatefulWidget {
  @override
  _AddNotesState createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
              "Create a New To-Do",
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
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      Navigator.pop(
                        context,
                        {
                          'title': _titleController.text,
                          'description': _descriptionController.text,
                        },
                      );
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
                      "Save",
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
      'Add New To-Do',
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewToDo extends StatefulWidget {
  @override
  _NewToDoState createState() => _NewToDoState();
}

class _NewToDoState extends State<NewToDo> {
  var _key = GlobalKey<FormState>();
  bool _isLoading = false;

  AutovalidateMode _autoValidation = AutovalidateMode.disabled;

  TextEditingController _todoController = TextEditingController();

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New ToDo"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: _saveToDo,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: _isLoading ? _loading(context) : _form(context),
      ),
    );
  }

  void _saveToDo() async {
    if (!_key.currentState.validate()) {
      setState(() {
        _autoValidation = AutovalidateMode.disabled;
      });
    } else {
      setState(() {
        _isLoading = true;
        _autoValidation = AutovalidateMode.always;
      });

      FirebaseAuth.instance.currentUser().then((user) {
        Firestore.instance
            .collection("todos")
            .document()
            .setData({
          'body': _todoController.text,
          'user_id': user.uid,
          'done':false,
        });
      }).then((_){
        Navigator.of(context).pop();
      });
    }
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _key,
        autovalidateMode: _autoValidation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFormField(
              controller: _todoController,
              decoration: InputDecoration(
                hintText: "Enter todo",
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:great_tolist/auth/login.dart';
import 'package:great_tolist/todo/newtodo.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseUser _userID;
  bool _hasError = false;
  bool _isLoading = false;
  String _errorMessege;

  String _name;

  @override

  initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection("profiles")
          .where("user_id", isEqualTo: user.uid)
          .getDocuments()
          .then((snapShotQuery) {
        setState(() {
          _name = snapShotQuery.documents[0]['name'];

          _userID = user;
          _hasError = false;
          _isLoading = false;
        });
      });
    }).catchError((error) {
      setState(() {
        _hasError = true;
        _errorMessege = error.toString();
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? Text("Home")
            : (_hasError ? _error(context, _errorMessege) : Text(_name)),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
                child: ListTile(
              onTap: () async {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                });
              },
              title: Text("Logout"),
              trailing: Icon(Icons.exit_to_app),
            ))
          ],
        ),
        elevation: 3,
      ),
      body: _isLoading
          ? _loading(context)
          : (_hasError ? _error(context, _errorMessege) : _content(context)),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _newTodo,
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Container(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('todos')
              .where('user_id', isEqualTo: _userID.uid)
              .orderBy('done', descending: true)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return _error(context, "no connection is made");
                break;
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return _error(context, snapshot.error.toString());
                }
                if (!snapshot.hasData) {
                  return _error(context, "No data");
                }
                return _drawScreen(context, snapshot.data);

                break;
            }
          },
        ),
      ),
    );
  }

  Widget _error(BuildContext context, String error) {}

  Widget _loading(
    BuildContext context,
  ) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _drawScreen(BuildContext context, QuerySnapshot data) {
    return ListView.builder(
        itemCount: data.documents.length,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            child: ListTile(
              title: Text(
                "${data.documents[position]['body']}",
                style: TextStyle(
                  decoration: (data.documents[position]['done'])
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              leading: IconButton(
                  onPressed: () {
                    Firestore.instance
                        .collection('todos')
                        .document(data.documents[position].documentID)
                        .updateData({
                      'done': (data.documents[position]['done']) ? false : true,
                    });
                  },
                  icon: Icon(Icons.check_box),
                  color: (data.documents[position]['done'])
                      ? Colors.teal
                      : Colors.grey.shade300),
              trailing: IconButton(
                onPressed: () {
                  Firestore.instance
                      .collection('todos')
                      .document(data.documents[position].documentID)
                      .delete();
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red.shade300,
                ),
              ),
            ),
          );
        });
  }

  _newTodo() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewToDo()));
  }
}

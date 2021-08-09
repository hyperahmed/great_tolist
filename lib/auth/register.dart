import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:great_tolist/auth/login.dart';
import 'package:great_tolist/todo/home.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  var _key = GlobalKey<FormState>();
  AutovalidateMode _autoValidation = AutovalidateMode.disabled;

  bool _isLoading = false;
  String _error;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Screen"),
        centerTitle: true,
      ),
      body: _isLoading ? _loading(context) : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return Form(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.all(15)),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "name",
                ),
                validator: (value) {
                  if (value.isEmpty)
                    return "name is required ";
                  else
                    return null;
                },
              ),
              Padding(padding: EdgeInsets.all(15)),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                ),
                validator: (value) {
                  if (value.isEmpty)
                    return "Email is required ";
                  else
                    return null;
                },
              ),
              Padding(padding: EdgeInsets.all(15)),
              TextFormField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: "password",
                  ),
                  validator: (value) {
                    if (value.isEmpty)
                      return "Password is required ";
                    else
                      return null;
                  }),
              Padding(padding: EdgeInsets.all(15)),
              TextFormField(
                obscureText: true,
                controller: _passwordConfirmController,
                decoration: InputDecoration(
                  hintText: "confirm password",
                ),
                validator: (value) {
                  if (_passwordController.text != value)
                    return "wrong password confirmation";
                  if (value.isEmpty)
                    return "password confirmation is required ";
                  else
                    return null;
                },
              ),
              Padding(padding: EdgeInsets.all(25)),
              ElevatedButton(
                child: Text("Register"),
                onPressed: _onRegisterClick,
              ),
              Padding(padding: EdgeInsets.all(15)),
              _erroMessage(context),
              Padding(padding: EdgeInsets.all(15)),
              Row(
                children: [
                  Text("Do you have an account already?"),
                  Padding(padding: EdgeInsets.all(15)),
                  TextButton(
                    child: Text("Login."),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ));
                    },
                  )
                ],
              ),
              Padding(padding: EdgeInsets.all(15)),
            ],
          ),
        ),
      ),
      autovalidateMode: _autoValidation,
      key: _key,
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  _onRegisterClick()  {
    if (!_key.currentState.validate()) {
      setState(() {
        _autoValidation = AutovalidateMode.disabled;
      });
    } else {
      setState(() {
        _isLoading = true;
        _autoValidation = AutovalidateMode.always;
      });

      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text)
          .then((authResult) {
        Firestore.instance.collection("profiles").document().setData({
          "name": _nameController.text,
          "user_id": authResult.user.uid,
        }).then((_) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
        }).catchError((error) {
          setState(() {
            _isLoading = false;
            _error = error.toString();
          });
        });
      });
    }
  }

  Widget _erroMessage(BuildContext context) {
    if (_error == null) {
      return Container();
    } else {
      return Container(
        child: Text(
          "error: $_error",
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }
}

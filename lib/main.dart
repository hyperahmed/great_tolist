import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:great_tolist/todo/newtodo.dart';
import 'auth/login.dart';
import 'auth/register.dart';
import 'todo/home.dart';

main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Widget homeScreen = LoginScreen();

  FirebaseUser user = await FirebaseAuth.instance.currentUser();

if(user == null){
  homeScreen = LoginScreen();
}

runApp(ToDoApp(homeScreen));

}


class ToDoApp extends StatelessWidget {
final Widget home;
ToDoApp(this.home);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: this.home,
    );
  }
}

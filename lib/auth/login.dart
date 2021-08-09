import 'package:flutter/material.dart';
import 'register.dart';
import 'package:great_tolist/todo/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  var _key = GlobalKey<FormState>();
  AutovalidateMode _autoValidation = AutovalidateMode.disabled;

  bool _isLoading = false;
  String _error;





  @override
  dispose(){
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Screen"),
        centerTitle: true,
      ),
      body:_isLoading?_loading(context):_form(context),
    );
  }


  Widget _form (BuildContext context){
    return Form(
      key: _key,
      autovalidateMode: _autoValidation,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextFormField(
                    decoration: InputDecoration(hintText: "your Email"),
                controller: _emailController,
                validator: (value){
                      if(value.isEmpty){
                        return "Email is required";
                      }else{
                        return null;
                      }
                },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 24),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(hintText: "Password"),
                  validator: (value){
                    if(value.isEmpty){
                      return "password is required";
                    }return null;
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 100),
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text("login"),
                    onPressed: _onLogin,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 48),
                ),
                Row(
                  children: [
                    Text("Don't have an account?"),
                    TextButton(child: Text("Register"),onPressed: (){
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>RegisterScreen()));
                    },)
                  ],
                ),

                _erroMessage(context),
              ],
            ),
          ),
        ),
      ),
    );

  }
  _onLogin()async{
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
          .signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text)
          .then((_) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
        }).catchError((error) {
          setState(() {
            _isLoading = false;
            _error = error.toString();
          });
        });
      }
    }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
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



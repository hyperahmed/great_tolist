import 'package:flutter/material.dart';

class ToDo {
  String body;
  String user_id;
  bool done;

  ToDo(this.body, this.user_id,this.done);

   ToDo.fromJson(Map<String, dynamic> map) {
    this.body = map['body'];
    this.user_id = map['user_id'];
    this.done = map['done'];
  }

  Map<String,dynamic> toMap(){
    return {
      'body':this.body,
      'user_id':this.user_id,
      'done':this.done
    };
  }
}

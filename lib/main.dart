import 'package:flutter/material.dart';
import 'package:notekeepar/screens/note_list.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:notekeepar/models/note.dart';

void main(){
  runApp(
    MyApp()
  );

}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteKeeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       primarySwatch: Colors.orange,
      ),
      home: NoteList(),
    );
  }
}


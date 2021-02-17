import 'package:flutter/material.dart';
import 'package:notekeepar/screens/note_detail.dart';
import 'package:notekeepar/models/note.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notekeepar/utils/database_helper.dart';

class NoteList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NoteListSate();
    throw UnimplementedError();
  }
}

class NoteListSate extends State<NoteList> {
  int count = 0;
  DatabaseHelper databaseHelper =DatabaseHelper();
  List<Note> noteList;

  @override
  Widget build(BuildContext context) {
      if(noteList == null){
        noteList = List<Note>();
      updateListView();

      }

    return Scaffold(
      appBar: AppBar(
        title: Text('Keep My notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB Clicked');
          navigateToDetail(Note('','',2), 'Add Note');

        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
    throw UnimplementedError();
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor( this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(
              this.noteList[position].title,
              style: titleStyle,
            ),
            subtitle: Text(this.noteList[position].date),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete_rounded,
                color: Colors.grey,
              ),
              onTap: (){
                _delete(context, noteList[position]);
              },
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.noteList[position] ,'Edit Note');
            },
          ),
        );
      },
    );
  }
  //Return the priority color
  Color getPriorityColor(int priority){
    switch(priority){
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellowAccent;
        break;
      default:
        return Colors.yellowAccent;
    }
  }
  //Return Priority Icon
  Icon getPriorityIcon(int priority){
    switch (priority){
      case 1:
        return Icon(Icons.arrow_upward);
        break;
      case 2:
        return Icon(Icons.arrow_downward);
        break;
      default:
        return Icon(Icons.arrow_downward);
    }
  }
 void _delete(BuildContext context,Note note)async {
   int result = await databaseHelper.deleteNote(note.id);
  if(result!=0)
   { __showSnackBar(context, 'Note Deleted Successfully');
   updateListView();
 }
 }
void __showSnackBar(BuildContext context, String message)
{
  final snackbar= SnackBar(content: Text(message));
  Scaffold.of(context).showSnackBar(snackbar);
}

  void navigateToDetail(Note note, String title)async{
   bool result= await Navigator.push(context, MaterialPageRoute(builder: (context){
      return NoteDetail(note, title);
    }));
  if(result == true){
    updateListView();
  }

  }


  void updateListView(){
    final Future<Database> dbFuture= databaseHelper.initializeDatabase();
    dbFuture.then((database){
      Future<List<Note>> noteListFuture= databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState((){
          this.noteList = noteList;
          this.count = noteList.length;
    });
    });
    });
  }
}

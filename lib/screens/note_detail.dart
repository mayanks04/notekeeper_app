import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:notekeepar/utils/database_helper.dart';
import 'package:notekeepar/models/note.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
class NoteDetail extends StatefulWidget {
  final String appBarTitle;
   final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  String appBarTitle;
  static var _priorities = ['High', 'Low'];

  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  DatabaseHelper helper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme
        .of(context)
        .textTheme
        .title;
    // TODO: implement build
    titleController.text = note.title;
    descriptionController.text = note.description;
    return WillPopScope
      (
        // ignore: missing_return
        onWillPop: () {
          moveToLastScreen();
        },

        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(
                  Icons.arrow_back_ios_outlined
              ), onPressed: () {
              moveToLastScreen();
            },),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                //First Element
                ListTile(
                  title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    style: textStyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        debugPrint('User Selected $valueSelectedByUser');
                        updatePriorityAsInt(valueSelectedByUser);
                      });
                    },
                  ),
                ),
                //Second Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Filed');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                  ),
                ),
                //Third Element

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Filed');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                  ),
                ),
                //fourth Element
                Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        //first Button
                        Expanded(
                            child: RaisedButton(
                              color: Theme
                                  .of(context)
                                  .primaryColorDark,
                              textColor: Theme
                                  .of(context)
                                  .primaryColorLight,
                              child: Text(
                                'Save',
                                textScaleFactor: 1.5,
                              ),
                              onLongPress: () {
                                setState(() {
                                  debugPrint("Save Button Click");
                                  _save();
                                });
                              },
                            )),
                        Container(
                          width: 5.0,
                        ),
                        //Second Button
                        Expanded(
                            child: RaisedButton(
                              color: Theme
                                  .of(context)
                                  .primaryColorDark,
                              textColor: Theme
                                  .of(context)
                                  .primaryColorLight,
                              child: Text(
                                'Delete',
                                textScaleFactor: 1.5,
                              ),
                              onLongPress: () {
                                setState(() {
                                  debugPrint("Delete Button Click");
                                  _delete();
                                });
                              },
                            ))
                      ],
                    ))
              ],
            ),
          ),
        ));
    throw UnimplementedError();
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

//Convert the Priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

//convert int priority to string priority it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //high
        break;
      case 2:
        priority = _priorities[1]; //Low
        break;
    }
    return priority;
  }

//Upgarade the title Of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

//Update the Description of the note object
  void updateDescription() {
    descriptionController.text = note.description;
  }

//Save Data to Database

  void _save() async {

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {  // Case 1: Update operation
      result = await helper.updateNote(note);
    } else { // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {  // Success
      _ShowAlertDialog('Status', 'Note Saved Successfully');
    } else {  // Failure
      _ShowAlertDialog('Status', 'Problem Saving Note');
    }

  }


  void _ShowAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

  void _delete() async {
    moveToLastScreen();
    /*Case1: If user is trying to delete the NEW NOTE i.e. he has been come to the detail page by pressing FAB of Note List */
    if(note.id==null){
      _ShowAlertDialog('Status','No Note was Deleted');
      return;
    }
    // Case 2; User is trying to Delete the old note that already has a valid ID,
  int result=   await helper.deleteNote(note.id);
    if (result != 0) {
      //Success
      _ShowAlertDialog('Status', 'Note Save Successfully');
    }
    else {
      //Failure
      _ShowAlertDialog('Status', 'Problem Saving Note');
    }

  }
}

// ignore_for_file: unused_field, prefer_final_fields, prefer_const_constructors, deprecated_member_use, import_of_legacy_library_into_null_safe

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistant_storage_crud_app/helper_classes/database.dart';

class EditEntry extends StatefulWidget {
  //add the extras you are getting from the previous page as arguments
  final bool add;
  final int index;
  final JournalEdit journalEdit;
  const EditEntry(
      {Key? key,
      required this.add,
      required this.index,
      required this.journalEdit})
      : super(key: key);

  @override
  _EditEntryState createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  late JournalEdit _journalEdit;
  late String _title;
  late DateTime _selectedDate;

  TextEditingController _moodController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  FocusNode _moodFocus = FocusNode();
  FocusNode _noteFocus = FocusNode();

  @override
  void initState() {


    /*
    To populate the entry fields on the page, add an if-else statement. If the widget.add value is
    true, meaning adding a new journal record, then initialize the _selectedDate variable with the
    current date by using the DateTime.now() constructor and initialize the _moodController.text
    and _noteController.text to an empty string. If the widget.add value is false, meaning
    editing a current journal record, then initialize the _selectedDate variable with the _journal-
    Edit.journal.date and use the DateTime.parse to convert the date from String to a DateTime
    format. Also initialize the _moodController.text with the _journalEdit.journal.mood and
    the _noteController.text with the _journalEdit.journal.note. When you override the
    initState() method, make sure you start the method with a call to super.initState().
   */
    _journalEdit = JournalEdit(action: 'Cancel', journal: widget.journalEdit.journal);
    //widget.add or widget.index to access our extra    
    if (widget.add == true) {
      _title = 'Add';
    } else {
      _title = 'Edit';
    }

    _journalEdit.journal = widget.journalEdit.journal;
    if (widget.add == true) {
      _selectedDate = DateTime.now();
      _moodController.text = '';
      _noteController.text = '';
    } else {
      _selectedDate = DateTime.parse(_journalEdit.journal.date);
      _moodController.text = _journalEdit.journal.mood;
      _noteController.text = _journalEdit.journal.note;
    }
    super.initState();
  }


@override
void dispose() {
    _moodController.dispose();
    _noteController.dispose();
    _moodFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text('$_title Entry'),
      automaticallyImplyLeading: false,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[

              FlatButton(
                padding: EdgeInsets.all(0.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                    Icons.calendar_today,
                    size: 22.0,
                    color: Colors.black54,
                    ),
                    SizedBox(width: 16.0,),
                    Text(DateFormat.yMMMEd().format(_selectedDate),
                    style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold),
                    ),
                    Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black54,
                    ),
                ],
                ),
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  
                  setState(() {
                  _selectedDate = DateTime.now();
                  });
                },
              ),

              TextField(
                controller: _moodController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                focusNode: _moodFocus,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                labelText: 'Mood',
                icon: Icon(Icons.mood),
                ),
                onSubmitted: (submitted) {
                FocusScope.of(context).requestFocus(_noteFocus);
                },
              ),

              TextField(
                controller: _noteController,
                textInputAction: TextInputAction.newline,
                focusNode: _noteFocus,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                labelText: 'Note',
                icon: Icon(Icons.subject),
                ),
                maxLines: null,
              ),


                Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  color: Colors.grey.shade100,
                    onPressed: () {
                      //call the Navigator.pop(context, _journalEdit) to dismiss the entry form and pass the value back to the calling page.
                      _journalEdit.action = 'Cancel';
                      Navigator.pop(context, _journalEdit);
                    },
                ),
                SizedBox(width: 8.0),
                FlatButton(
                  child: Text('Save'),
                  color: Colors.lightGreen.shade100,
                    onPressed: () {
                      //Call the Navigator.pop(context, _journalEdit) to dismiss the entry form and pass the value back to the calling page
                      _journalEdit.action = 'Save';

                      String _id = widget.add ? Random().nextInt(9999999).toString() : _journalEdit.journal.id;

                      _journalEdit.journal = Journal(
                      id: _id,
                      date: _selectedDate.toString(),
                      mood: _moodController.text,
                      note: _noteController.text,
                      );

                      Navigator.pop(context, _journalEdit);
                    },
                ),
                ],
                ),            
            ],
          ),
        ),
      ),
    );
  }



}

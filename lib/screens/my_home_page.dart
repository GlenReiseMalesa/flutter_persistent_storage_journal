// ignore_for_file: file_names, prefer_const_constructors, unused_element, unused_local_variable, import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistant_storage_crud_app/helper_classes/database.dart';
import 'package:persistant_storage_crud_app/screens/add_or_edit_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    late Database _database;

    //the _loadJournals() async method returns a Future<List<Journal>>, which is a List of the Journal class entries.
    Future<List<Journal>> _loadJournals() async {
      await DatabaseFileRoutines().readJournals().then((journalsJson) {
        _database = databaseFromJson(journalsJson);
        _database.journal
            .sort((comp1, comp2) => comp2.date.compareTo(comp1.date));
      });
      return _database.journal;
    }

    /*
      the _addOrEditJournal() method handles presenting the edit entry page to either add
      or modify a journal entry. You use Navigator.push() to present the entry page and wait for the
      result of the user’s actions. If the user pressed the Cancel button, nothing happens, but if they
      pressed Save, then you either add the new journal entry or save the changes to the current
      edited entry.
    */
    void _addOrEditJournal(
        {required bool add,
        required int index,
        required Journal journal}) async {
      JournalEdit _journalEdit = JournalEdit(action: '', journal: journal);
      /*
        you are going to use the Navigator to pass the constructor values to the edit entry
        page by using the await keyword that passes the value back to the local _journalEdit variable.
        For the MaterialPageRoute builder, pass the constructor values to the EditEntry() class and
        set the fullscreenDialog property to true.
      */
      //simply put: this is like putIntent(pushing an intent extra to the next page)
      _journalEdit = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditEntry(
            add: add,
            index: index,
            journalEdit: _journalEdit,
          ),
          fullscreenDialog: true,
        ),
      );

      /*
        Once the edit entry page is dismissed, the switch statement executes next, and you’ll take
        appropriate action depending on the user’s selection. The switch statement evaluates the
        _journalEdit.action to check whether the Save button was pressed and then checks whether
        you are adding or saving the entry with an if-else statement.
      */
      switch (_journalEdit.action) {
        case 'Save':
          if (add == true) {
            setState(() {
              _database.journal.add(_journalEdit.journal);
            });
          } else {
            setState(() {
              _database.journal[index] = _journalEdit.journal;
            });
          }
          //To save the journal entry values to the device local storage documents directory,
          DatabaseFileRoutines().writeJournals(databaseToJson(_database));
          break;
        case 'Cancel':
          break;
        default:
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        initialData: [],
        future: _loadJournals(),//getting the list data
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.separated(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                      //variables
                      String _titleDate = DateFormat.yMMMd().format(DateTime.parse(snapshot
                      .data[index].date));
                      String _subtitle = snapshot.data[index].mood + "\n" + snapshot
                      .data[index].note;

                      return Dismissible(
                      key: Key(snapshot.data[index].id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 16.0),
                        child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        ),
                      ),
                      child: ListTile(
                        leading: Column(
                        children: <Widget>[
                          Text(DateFormat.d().format(DateTime.parse(snapshot.data[index].date)),
                          style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32.0,
                          color: Colors.blue),
                          ),
                          Text(DateFormat.E().format(DateTime.parse(snapshot.data[index].date))),
                          ],
                        ),
                        title: Text(
                          _titleDate,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(_subtitle),
                        onTap: () {
                          //putExtra
                          _addOrEditJournal(
                          add: false,
                          index: index,
                          journal: snapshot.data[index],
                          );
                        },
                      ),
                      onDismissed: (direction) {
                        //Deleting a journal entry
                        setState(() {
                        _database.journal.removeAt(index);
                        });
                        DatabaseFileRoutines().writeJournals(databaseToJson(_database));
                      },
                      );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                        color: Colors.grey,
                        );
                      },
                    );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrEditJournal(add: true, index: -1, journal: Journal(id: "", date: "", mood: "", note: ""));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

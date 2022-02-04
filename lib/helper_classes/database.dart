// ignore_for_file: unused_element, import_of_legacy_library_into_null_safe, unused_import, unnecessary_string_interpolations

import 'dart:io'; //Used by file
import 'dart:convert'; //Used by JSON
import 'package:path_provider/path_provider.dart'; //filesystem locations

//uses the file class to retrive the device local document directory,saves and reads the data file
class DatabaseFileRoutines {
  //the _localPath async method returns a Future<String>, which is the documents directory path.
  Future<String> get _localPath async {
    final _directory = await getApplicationDocumentsDirectory();
    return _directory.path;
  }

  //the _localFile async method returns a Future<File> with the reference to the local_persistence.json file, which is the path, combined with the filename.
  Future<File> get _localFile async {
    final _path = await _localPath;
    return File('$_path/local_persistence.json');
  }

  //the writeJournals(String json) async method returning a Future<File> to save the JSON objects to file.
  Future<File> writeJournals(String json) async {
    final _file = await _localFile;

    //write the file
    return _file.writeAsString('$json');
  }

  //the readJournals() async method that returns a Future<String> containing the JSON objects.
  Future<String> readJournals() async {
    try {
      final _file = await _localFile;

      if (!_file.existsSync()) {
        await writeJournals('{"journals": []}');
      }

      //read the file
      String _contents = await _file.readAsString();
      return _contents;
    } catch (e) {
      return "";
    }
  }
}

//maps each journal entry from and to json
class Journal {
  String id;
  String date;
  String mood;
  String note;

  Journal(
      {required this.id,
      required this.date,
      required this.mood,
      required this.note});

/*  
  To retrieve and convert the JSON object to a Journal class, create the factory Journal.fromJson()
  named constructor. The constructor takes the argument of Map<String, dynamic>, which
  maps the String key with a dynamic value, the JSON key/value pair.
*/
  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
      id: json["id"],
      date: json["date"],
      mood: json["mood"],
      note: json["note"]);

//To convert the Journal class to a JSON object, create the toJson() method that parses the Journal class to a JSON object.
  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "mood": mood,
        "note": note,
      };
}

//responsible for encoding and decoding the JSON file and mapping it to a list
class Database {
  List<Journal> journal;
  Database({required this.journal});

  /*
  To retrieve and map the JSON objects to a List<Journal> (list of Journal classes), create the
  factory Database.fromJson() named constructor. Note that the factory constructor does not
  always create a new instance but might return an instance from a cache. The constructor takes the
  argument of Map<String, dynamic>, which maps the String key with a dynamic value, the
  JSON key/value pair. The constructor returns the List<Journal> by taking the JSON 'journals'
  key objects and mapping it from the Journal class that parses the JSON string to the Journal
  object containing each field such as the id, date, mood, and note.
  */
  factory Database.fromJson(Map<String, dynamic> json) => Database(
        journal: List<Journal>.from(
            json["journals"].map((x) => Journal.fromJson(x))),
      );

  //To convert the List<Journal> to JSON objects, create the toJson method that parses each Journal class to JSON objects.
  Map<String, dynamic> toJson() => {
        "journals": List<dynamic>.from(journal.map((e) => e.toJson())),
      };
}

//To read and parse from JSON data
Database databaseFromJson(String str) {
  final dataFromJson = json.decode(str);
  return Database.fromJson(dataFromJson);
}

//To save and parse to JSON data
String databaseToJson(Database data) {
  final dataToJson = data.toJson();
  return json.encode(dataToJson);
}

//is used to pass an action(save or cancel) and a journal entry between pages(putIntent extra)
class JournalEdit {
  Journal journal;
  String action;

  JournalEdit({required this.action, required this.journal});
}

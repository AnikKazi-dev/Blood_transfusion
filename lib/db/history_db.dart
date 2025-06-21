import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:secureblood/db/history_class.dart';
import 'package:secureblood/db/migrations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HistoryDB {
  static final HistoryDB _instance = HistoryDB._internal();

  factory HistoryDB() {
    return _instance;
  }

  HistoryDB._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database if it's not already initialized
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'history.db');

    // Open the database, and create the table if it doesn't exist
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE collected_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            begleitscheinRecieverBloodType TEXT,
            begleitscheinBlutkonserveBloodType TEXT,
            begleitscheinFallnummer TEXT,
            begleitscheinBlutkonservenNummer TEXT,
            blutKonservenNummer TEXT,
            blutkonservenBloodType TEXT,
            blutkonservenProductType TEXT,
            patientWristBandFallnummer TEXT,
            bedsideTestResult TEXT,
            scanSuccess INTEGER, 
            created_at TEXT,
            isFullTransfusion INTEGER,
            begleitscheinPatientName TEXT,
            begleitscheinBirthDate TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await migrateToVersion2(db);
        }
        if (oldVersion < 3) {
          await migrateToVersion3(db);
        }
      },
    );
  }

  Future<int> insertCollectedData(HistoryEntry entry) async {
    Map<String, dynamic> data = entry.toJson();

    final db = await database;

    data['created_at'] =
        DateTime.now().toIso8601String(); // Add the current date and time

    return await db.insert('collected_data', data);
  }

  Future<List<HistoryEntry>> getAllCollectedData() async {
    final db = await database;

    var jsonList = await db.query('collected_data', orderBy: 'created_at DESC');

    return jsonList.map((json) => HistoryEntry.fromJson(json)).toList();
  }

  Future<int> updateCollectedData(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update(
      'collected_data',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCollectedData(int id) async {
    final db = await database;

    return await db.delete(
      'collected_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> wipeAllData() async {
    final db = await database;

    return await db.delete('collected_data');
  }

  Future<void> exportToCSV() async {
    final db = await database;
    var data = await db.query('collected_data');

    List<List<dynamic>> rows = [];

    // Add header row
    rows.add([
      "id",
      "Begleitschein Blutgruppe Empfänger",
      "Begleitschein Blutgruppe Blutkonserve",
      "Begleitschein Fallnummer",
      "Begleitschein Blutkonservennummer",
      "Begleitschein Patient Name",
      "Begleitschein Birth Date",
      "Blutkonservennummer",
      "Blutkonserven Blutgruppe",
      "Blutkonserven Produkttyp",
      "Austauschtransfusion",
      "Patientenarmband Fallnummer",
      "Bedsidetest Ergebnis",
      "Datensatz korrekt",
      "Datum der Erfassung"
    ]);

    // Add data rows
    for (var row in data) {
      List<dynamic> rowData = [];
      rowData.add(row["id"]);
      rowData.add(row["begleitscheinRecieverBloodType"]);
      rowData.add(row["begleitscheinBlutkonserveBloodType"]);
      rowData.add(row["begleitscheinFallnummer"]);
      rowData.add(row["begleitscheinBlutkonservenNummer"]);
      rowData.add(row["begleitscheinPatientName"]);
      rowData.add(row["begleitscheinBirthDate"]);
      rowData.add(row["blutKonservenNummer"]);
      rowData.add(row["blutkonservenBloodType"]);
      rowData.add(row["isFullTransfusion"]);
      rowData.add(row["blutkonservenProductType"]);
      rowData.add(row["patientWristBandFallnummer"]);
      rowData.add(row["bedsideTestResult"]);
      rowData.add(row["scanSuccess"]);
      rowData.add(row["created_at"]);
      rows.add(rowData);
    }

    String csv = const ListToCsvConverter().convert(rows);

    await Share.shareXFiles(
        [XFile.fromData(utf8.encode(csv), mimeType: 'text/plain')],
        fileNameOverrides: ['secureblood_history.csv']);
  }

  Future<void> close() async {
    final db = await _instance.database;
    await db.close();
  }
}

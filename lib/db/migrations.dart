import 'package:sqflite/sqflite.dart';

Future<void> migrateToVersion2(Database db) async {
  //adding isFullTransfusion column to collected_data table
  await db.execute('''
    ALTER TABLE collected_data ADD COLUMN isFullTransfusion INTEGER;
  ''');
}

Future<void> migrateToVersion3(Database db) async {
  await db.execute('''
    ALTER TABLE collected_data ADD COLUMN begleitscheinPatientName TEXT;
  ''');
  await db.execute('''
    ALTER TABLE collected_data ADD COLUMN begleitscheinBirthDate TEXT;
  ''');
}

import 'package:chronospin/core/database/local_database.dart';
import 'package:chronospin/features/history/domain/solve.dart';
import 'package:sqflite/sqflite.dart';

class SolvesRepository {
  Future<void> saveSolve(Solve solve) async {
    final db = await LocalDatabase.instance.database;
    await db.insert(
      'solves',
      solve.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Solve>> getSolves(String puzzleType) async {
    final db = await LocalDatabase.instance.database;
    final result = await db.query(
      'solves',
      where: 'puzzle = ?',
      whereArgs: [puzzleType],
      orderBy: 'timestamp DESC',
    );

    return result.map((json) => Solve.fromMap(json)).toList();
  }

  Future<void> deleteSolve(String id) async {
    final db = await LocalDatabase.instance.database;
    await db.delete('solves', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await LocalDatabase.instance.database;
    await db.delete('solves');
  }
}

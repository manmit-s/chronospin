import 'package:uuid/uuid.dart';
import 'package:chronospin/features/timer/domain/puzzle_type.dart';

enum Penalty { none, plus2, dnf }

class Solve {
  final String id;
  final Duration time;
  final String scramble;
  final DateTime timestamp;
  final Penalty penalty;
  final String? notes;
  final PuzzleType puzzle;

  Solve({
    String? id,
    required this.time,
    required this.scramble,
    required this.timestamp,
    this.penalty = Penalty.none,
    this.notes,
    this.puzzle = PuzzleType.cube3x3,
  }) : id = id ?? const Uuid().v4();

  Duration get effectiveTime {
    if (penalty == Penalty.plus2) {
      return time + const Duration(seconds: 2);
    }
    return time; // DNF should be handled separately in logic, typically treated as infinity or special display
  }

  Solve copyWith({
    String? id,
    Duration? time,
    String? scramble,
    DateTime? timestamp,
    Penalty? penalty,
    String? notes,
    PuzzleType? puzzle,
  }) {
    return Solve(
      id: id ?? this.id,
      time: time ?? this.time,
      scramble: scramble ?? this.scramble,
      timestamp: timestamp ?? this.timestamp,
      penalty: penalty ?? this.penalty,
      notes: notes ?? this.notes,
      puzzle: puzzle ?? this.puzzle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.inMilliseconds,
      'scramble': scramble,
      'timestamp': timestamp.toIso8601String(),
      'penalty': penalty.name,
      'notes': notes ?? '',
      'puzzle': puzzle.name, // Store as enum name (e.g., 'cube3x3')
    };
  }

  factory Solve.fromMap(Map<String, dynamic> map) {
    return Solve(
      id: map['id'],
      time: Duration(milliseconds: map['time']),
      scramble: map['scramble'],
      timestamp: DateTime.parse(map['timestamp']),
      penalty: Penalty.values.firstWhere(
        (e) => e.name == map['penalty'],
        orElse: () => Penalty.none,
      ),
      notes: map['notes'] == '' ? null : map['notes'],
      puzzle: PuzzleType.values.firstWhere(
        // Handle migration: if 'puzzle' is null (old db), default to 3x3
        (e) => e.name == map['puzzle'],
        orElse: () => PuzzleType.cube3x3,
      ),
    );
  }
}

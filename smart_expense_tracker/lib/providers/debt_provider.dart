import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/person.dart';
import '../models/debt_record.dart';

class DebtProvider extends ChangeNotifier {
  List<Person> _people = [];
  List<DebtRecord> _debtRecords = [];
  final Box<Person> _personBox = Hive.box<Person>('people');
  final Box<DebtRecord> _debtRecordBox = Hive.box<DebtRecord>('debt_records');
  String? _currentUserId;

  List<Person> get people => _people;
  List<DebtRecord> get debtRecords => _debtRecords;

  double get totalDebt {
    return _debtRecords
        .where((record) => record.type == 'debt')
        .fold(0, (sum, record) => sum + record.amount);
  }

  double get totalPayback {
    return _debtRecords
        .where((record) => record.type == 'payback')
        .fold(0, (sum, record) => sum + record.amount);
  }

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    loadData();
  }

  Future<void> loadData() async {
    if (_currentUserId == null) {
      _people = [];
      _debtRecords = [];
    } else {
      _people = _personBox.values
          .where((person) => person.userId == _currentUserId)
          .toList();
      _debtRecords = _debtRecordBox.values
          .where((record) => record.userId == _currentUserId)
          .toList();
    }
    notifyListeners();
  }

  Future<void> addPerson(Person person) async {
    if (_currentUserId != null) {
      person.userId = _currentUserId!;
      await _personBox.add(person);
      await loadData();
    }
  }

  Future<void> addDebtRecord(DebtRecord record) async {
    if (_currentUserId != null) {
      record.userId = _currentUserId!;
      await _debtRecordBox.add(record);
      await loadData();
    }
  }

  List<DebtRecord> getRecordsForPerson(String personId) {
    return _debtRecords
        .where((record) => record.personId == personId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getPersonBalance(String personId) {
    final records = getRecordsForPerson(personId);
    double balance = 0;
    for (final record in records) {
      if (record.type == 'debt') {
        balance += record.amount;
      } else {
        balance -= record.amount;
      }
    }
    return balance;
  }
}
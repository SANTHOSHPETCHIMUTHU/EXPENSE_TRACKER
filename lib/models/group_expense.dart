import 'package:uuid/uuid.dart';

class GroupPerson {
  final String name;
  final double amount;

  GroupPerson({required this.name, required this.amount});

  Map<String, dynamic> toJson() {
    return {'name': name, 'amount': amount};
  }

  factory GroupPerson.fromJson(Map<String, dynamic> json) {
    return GroupPerson(
      name: json['name'] as String,
      amount: json['amount'] as double,
    );
  }
}

class GroupExpense {
  final String id;
  final String description;
  final double totalAmount;
  final List<GroupPerson> people;
  final DateTime date;

  GroupExpense({
    String? id,
    required this.description,
    required this.totalAmount,
    required this.people,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'totalAmount': totalAmount,
      'people': people.map((p) => p.toJson()).toList(),
      'date': date.toIso8601String(),
    };
  }

  factory GroupExpense.fromJson(Map<String, dynamic> json) {
    return GroupExpense(
      id: json['id'] as String,
      description: json['description'] as String,
      totalAmount: json['totalAmount'] as double,
      people:
          (json['people'] as List)
              .map((p) => GroupPerson.fromJson(p as Map<String, dynamic>))
              .toList(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}

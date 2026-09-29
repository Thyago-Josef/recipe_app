import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class Ingredient {
  final String id;
  final String name;
  final bool isSelected;
  final DateTime createdAt;

  Ingredient({
    String? id,
    required this.name,
    this.isSelected = false,
    DateTime? createdAt,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now();

  Ingredient copyWith({
    String? id,
    String? name,
    bool? isSelected,
    DateTime? createdAt,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isSelected': isSelected,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    id: json['id'],
    name: json['name'],
    isSelected: json['isSelected'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Ingredient(id: $id, name: $name, isSelected: $isSelected)';
}